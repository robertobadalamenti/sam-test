#!/bin/bash

# Validate input
if [ -z "$LAMBDA" ]; then
  echo "Error: No Lambda function name provided."
  exit 1
fi

# Extract the runtime of the specified Lambda function from template.yaml
runtime=$(awk "/$LAMBDA/{f=1} f && /Runtime:/ {print \$2; exit}" template.yaml | tr -d '"')
# Extract the architecture (default to x86_64 if not found)
architecture=$(awk "/$lambda_name/{f=1} f && /Architectures:/ {getline; print \$2; exit}" template.yaml | tr -d '"')

if [ -z "$architecture" ]; then
  architecture="x86_64"  # Default to x86_64 if Architectures is not specified
fi
# Check if runtime was found
if [ -z "$runtime" ]; then
  echo "Error: Could not find the runtime for Lambda function '$LAMBDA'."
  exit 1
fi

# Map runtime to the corresponding AWS Lambda Docker image
case "$runtime" in
  nodejs10.x) image="public.ecr.aws/lambda/nodejs:10-rapid-$architecture" ;;
  nodejs12.x) image="public.ecr.aws/lambda/nodejs:12-rapid-$architecture" ;;
  nodejs14.x) image="public.ecr.aws/lambda/nodejs:14-rapid-$architecture" ;;
  nodejs16.x) image="public.ecr.aws/lambda/nodejs:16-rapid-$architecture" ;;
  nodejs18.x) image="public.ecr.aws/lambda/nodejs:18-rapid-$architecture" ;;
  nodejs20.x) image="public.ecr.aws/lambda/nodejs:20-rapid-$architecture" ;;
  nodejs22.x) image="public.ecr.aws/lambda/nodejs:22-rapid-$architecture" ;;
  *) echo "Error: Unsupported runtime '$runtime'"; exit 1 ;;
esac

# Get container ID
container_id=$(docker ps -q --filter "ancestor=$image")

# Check if a container was found
if [ -z "$container_id" ]; then

  # Try invoking the function locally using SAM CLI
  if [ -n "$EVENT" ]; then
    sam local invoke "$LAMBDA" -e "$EVENT"
  else
    sam local invoke "$LAMBDA"
  fi
  # Check if sam local invoke succeeded
  if [ $? -eq 0 ]; then
    echo "Successfully invoked Lambda function locally."
    exit 0
  else
    echo "Error: Local invocation failed. Please check your SAM setup or function configuration."
    exit 1
  fi
fi

# Get container name
container_name=$(docker ps --filter "id=$container_id" --format "{{.Names}}")

# Check if a name was found
if [ -z "$container_name" ]; then
  echo "Error: Could not determine container name."
  exit 1
fi

# Restart the container
echo "Restarting container $container_name..."
docker restart "$container_name"
