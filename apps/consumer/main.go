package main

import (
	"context"
	"encoding/json"
	"log"
	"net/smtp"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/segmentio/kafka-go"
)

type NotificationMessage struct {
	Email   string `json:"email"`
	Message string `json:"message"`
}

type DLQMessage struct {
	Email    string `json:"email"`
	Message  string `json:"message"`
	Error    string `json:"error"`
	FailedAt string `json:"failed_at"`
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func getEnvInt(key string, fallback int) int {
	if v := os.Getenv(key); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			return n
		}
	}
	return fallback
}

func sendEmail(smtpHost, smtpPort, username, password, from, to, subject, body string) error {
	addr := smtpHost + ":" + smtpPort
	auth := smtp.PlainAuth("", username, password, smtpHost)
	msg := []byte("To: " + to + "\r\n" +
		"From: " + from + "\r\n" +
		"Subject: " + subject + "\r\n" +
		"\r\n" + body + "\r\n")
	return smtp.SendMail(addr, auth, from, []string{to}, msg)
}

func sendWithRetry(smtpHost, smtpPort, username, password, from string, notif NotificationMessage, maxRetries int, baseDelay time.Duration) error {
	var lastErr error
	delay := baseDelay

	for attempt := 1; attempt <= maxRetries; attempt++ {
		err := sendEmail(smtpHost, smtpPort, username, password, from, notif.Email, "Notification", notif.Message)
		if err == nil {
			return nil
		}
		lastErr = err
		log.Printf("attempt %d/%d failed for %s: %v", attempt, maxRetries, notif.Email, err)

		if attempt < maxRetries {
			time.Sleep(delay)
			delay *= 2
		}
	}
	return lastErr
}

func main() {
	brokers := strings.Split(getEnv("KAFKA_BROKERS", "localhost:9092"), ",")
	topic := getEnv("KAFKA_TOPIC", "notifications")
	dlqTopic := getEnv("KAFKA_DLQ_TOPIC", "notifications-dlq")
	groupID := getEnv("KAFKA_CONSUMER_GROUP", "notification-consumer-group")

	smtpHost := getEnv("SMTP_HOST", "localhost")
	smtpPort := getEnv("SMTP_PORT", "587")
	smtpUsername := getEnv("SMTP_USERNAME", "")
	smtpPassword := getEnv("SMTP_PASSWORD", "")
	smtpFrom := getEnv("SMTP_FROM", "noreply@kafka-lab.local")

	maxRetries := getEnvInt("MAX_RETRIES", 3)
	baseDelayMs := getEnvInt("RETRY_BASE_DELAY_MS", 500)
	baseDelay := time.Duration(baseDelayMs) * time.Millisecond

	reader := kafka.NewReader(kafka.ReaderConfig{
		Brokers: brokers,
		Topic:   topic,
		GroupID: groupID,
	})
	defer reader.Close()

	dlqWriter := &kafka.Writer{
		Addr:         kafka.TCP(brokers...),
		Topic:        dlqTopic,
		Balancer:     &kafka.LeastBytes{},
		RequiredAcks: kafka.RequireOne,
	}
	defer dlqWriter.Close()

	log.Printf("consumer started (topic=%s, group=%s, brokers=%v)", topic, groupID, brokers)

	for {
		ctx := context.Background()
		m, err := reader.FetchMessage(ctx)
		if err != nil {
			log.Printf("error fetching message: %v", err)
			continue
		}

		var notif NotificationMessage
		if err := json.Unmarshal(m.Value, &notif); err != nil {
			log.Printf("failed to unmarshal message, skipping: %v", err)
			if commitErr := reader.CommitMessages(ctx, m); commitErr != nil {
				log.Printf("failed to commit offset: %v", commitErr)
			}
			continue
		}

		err = sendWithRetry(smtpHost, smtpPort, smtpUsername, smtpPassword, smtpFrom, notif, maxRetries, baseDelay)
		if err != nil {
			log.Printf("all retries failed for %s, sending to DLQ", notif.Email)

			dlqMsg := DLQMessage{
				Email:    notif.Email,
				Message:  notif.Message,
				Error:    err.Error(),
				FailedAt: time.Now().UTC().Format(time.RFC3339),
			}
			dlqValue, marshalErr := json.Marshal(dlqMsg)
			if marshalErr != nil {
				log.Printf("failed to marshal DLQ message: %v", marshalErr)
			} else {
				writeCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
				if writeErr := dlqWriter.WriteMessages(writeCtx, kafka.Message{
					Key:   []byte(notif.Email),
					Value: dlqValue,
				}); writeErr != nil {
					log.Printf("failed to write to DLQ: %v", writeErr)
				}
				cancel()
			}
		} else {
			log.Printf("email sent successfully to %s", notif.Email)
		}

		if commitErr := reader.CommitMessages(ctx, m); commitErr != nil {
			log.Printf("failed to commit offset: %v", commitErr)
		}
	}
}