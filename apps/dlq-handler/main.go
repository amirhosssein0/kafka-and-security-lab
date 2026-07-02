package main

import (
	"context"
	"encoding/json"
	"log"
	"os"
	"strings"

	"github.com/segmentio/kafka-go"
)

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

func main() {
	brokers := strings.Split(getEnv("KAFKA_BROKERS", "localhost:9092"), ",")
	dlqTopic := getEnv("KAFKA_DLQ_TOPIC", "notifications-dlq")
	groupID := getEnv("KAFKA_CONSUMER_GROUP", "dlq-handler-group")

	reader := kafka.NewReader(kafka.ReaderConfig{
		Brokers: brokers,
		Topic:   dlqTopic,
		GroupID: groupID,
	})
	defer reader.Close()

	log.Printf("dlq-handler started (topic=%s, group=%s, brokers=%v)", dlqTopic, groupID, brokers)

	for {
		ctx := context.Background()
		m, err := reader.FetchMessage(ctx)
		if err != nil {
			log.Printf("error fetching message: %v", err)
			continue
		}

		var dlqMsg DLQMessage
		if err := json.Unmarshal(m.Value, &dlqMsg); err != nil {
			log.Printf("failed to unmarshal DLQ message: %v (raw=%s)", err, string(m.Value))
		} else {
			log.Printf("DLQ MESSAGE | email=%s | message=%q | error=%q | failed_at=%s",
				dlqMsg.Email, dlqMsg.Message, dlqMsg.Error, dlqMsg.FailedAt)
		}

		if commitErr := reader.CommitMessages(ctx, m); commitErr != nil {
			log.Printf("failed to commit offset: %v", commitErr)
		}
	}
}