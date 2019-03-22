variable "name" {}
variable "environment" {}
variable "project" {}

resource "aws_sqs_queue" "this" {
  name = "${var.project}-${var.environment}-${var.name}"

  tags {
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}

output "queue-url" {
  description = "Die Url der Queue: ${var.name}"
  value       = "${aws_sqs_queue.this.id}"
}
