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
	@docker rmi $(IMAGE_NAME):$(TAG) || true
	@docker build -t $(IMAGE_NAME):$(TAG) .

# Run the Docker Compose (with building)
run: build run-only

# Run the Docker Compose without building
run-only:
	@echo "Running Docker Compose"
	@IMAGE_TAG=$(IMAGE_TAG) docker-compose up -d

stop:
	@echo "Stopping Docker Compose"
	@IMAGE_TAG=$(IMAGE_TAG) docker-compose down

# Clean up Docker images
clean: stop
	@docker rmi $(IMAGE_NAME):$(TAG) || true

restart: clean run




# make -f Makefile-dev restart
# make -f Makefile-dev run