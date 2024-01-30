.PHONY: build run run-only clean

# Get the bit version from the system
BIT_VERSION := $(shell uname -m)
VERSION := $(BIT_VERSION)-1.2.1
TAG := latest
IMAGE_NAME := janus-webrtc-gateway-docker-$(VERSION)
IMAGE_TAG := $(VERSION):$(TAG)

# Default target
all: run

# Build the Docker image
build:
	@echo "Building Docker image with tag $(IMAGE_TAG)"
	@docker rmi $(IMAGE_TAG) || true
	@docker build -t $(IMAGE_NAME):$(TAG) .

# Run the Docker Compose (with building)
run: build run-only

# Run the Docker Compose without building
run-only:
	@echo "Running Docker Compose"
	@IMAGE_TAG=$(IMAGE_TAG) docker-compose up -d

# Clean up Docker images
clean:
	@docker rmi $(IMAGE_NAME):$(TAG) || true
