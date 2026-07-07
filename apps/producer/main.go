package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/segmentio/kafka-go"
)

type NotifyRequest struct {
	Email   string `json:"email"`
	Message string `json:"message"`
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func main() {
	brokers := strings.Split(getEnv("KAFKA_BROKERS", "localhost:9092"), ",")
	topic := getEnv("KAFKA_TOPIC", "notifications")
	port := getEnv("PORT", "8080")

	writer := &kafka.Writer{
		Addr:         kafka.TCP(brokers...),
		Topic:        topic,
		Balancer:     &kafka.LeastBytes{},
		RequiredAcks: kafka.RequireOne,
	}
	defer writer.Close()

	router := gin.Default()

	router.GET("/healthz", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "ok"})
	})

	router.POST("/notify", func(c *gin.Context) {
		var req NotifyRequest
		if err := c.ShouldBindJSON(&req); err != nil || req.Email == "" || req.Message == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "email and message are required"})
			return
		}

		ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
		defer cancel()

		body, err := c.GetRawData()
		if err != nil {
			body = nil
		}
		_ = body // request already bound above; re-marshal explicitly below

		payload := gin.H{"email": req.Email, "message": req.Message}
		value, err := jsonMarshal(payload)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to queue message"})
			return
		}

		err = writer.WriteMessages(ctx, kafka.Message{
			Key:   []byte(req.Email),
			Value: value,
		})
		if err != nil {
			log.Printf("failed to write message to kafka: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to queue message"})
			return
		}

		c.JSON(http.StatusAccepted, gin.H{"status": "queued"})
	})

	log.Printf("producer listening on :%s (topic=%s, brokers=%v)", port, topic, brokers)
	if err := router.Run(":" + port); err != nil {
		log.Fatalf("server failed: %v", err)
	}
}
