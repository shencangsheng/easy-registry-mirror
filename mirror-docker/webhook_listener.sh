#!/bin/bash

PORT=8080

SOCK="/var/run/docker.sock"

TARGET_REGISTRY="mirror-docker:5000"

while true; do

    echo -e "HTTP/1.1 200 OK\n\nWebhook received!" | nc -l -p $PORT -q 1 >request.log

    BODY=$(awk 'NR>1{print}' request.log)
    echo "Received Body: $BODY"

    IMAGE_NAME=$(echo "$BODY" | jq -r '.events[0].target.repository')
    IMAGE_TAG=$(echo "$BODY" | jq -r '.events[0].target.tag // "latest"')

    echo "Image pulled: ${IMAGE_NAME}:${IMAGE_TAG}"

    if [ -S "$SOCK" ]; then
        echo "{\"fromImage\": \"${IMAGE_NAME}\", \"tag\": \"${IMAGE_TAG}\"}" |
            curl --unix-socket /var/run/docker.sock -X POST -H "Content-Type: application/json" -d @- http:/v1.24/images/create?fromImage=${IMAGE_NAME} &
        tag=${IMAGE_TAG}

        echo "Pulling image ${IMAGE_NAME}:${IMAGE_TAG} completed."

        NEW_IMAGE="${TARGET_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
        echo "{\"fromImage\": \"${IMAGE_NAME}\", \"repo\": \"${NEW_IMAGE}\"}" |
            curl --unix-socket /var/run/docker.sock -X POST -H "Content-Type: application/json" -d @- http:/v1.24/images/${IMAGE_NAME}:${IMAGE_TAG}/tag?repo=${NEW_IMAGE}

        echo "Tagging image as ${NEW_IMAGE} completed."

        echo "{\"tag\": \"${NEW_IMAGE}\"}" |
            curl --unix-socket /var/run/docker.sock -X POST -H "Content-Type: application/json" -d @- http:/v1.24/images/${NEW_IMAGE}/push

        echo "Pushing image ${NEW_IMAGE} completed."
    else
        echo "Docker socket not found at ${SOCK}"
    fi
done
