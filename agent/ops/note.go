package ops

import (
	"time"
)

type Note struct {
	Timestamp string    `json:"timestamp"`
	ExpireAt  time.Time `json:"expire_at"`
	CreatedBy string    `json:"created_by"`
	Text      string    `json:"text"`
}
