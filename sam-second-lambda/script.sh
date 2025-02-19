#!/bin/bash

# Estrai il runtime dal file template.yaml
runtime=$(grep 'Runtime:' template.yaml | awk '{print $2}' | tr -d '"')

# Mappatura dei runtime Node.js a immagini Docker
case "$runtime" in
  nodejs16.x)
    image="public.ecr.aws/lambda/nodejs:16"
    ;;
  nodejs14.x)
    image="public.ecr.aws/lambda/nodejs:14"
    ;;
  nodejs12.x)
    image="public.ecr.aws/lambda/nodejs:12"
    ;;
  nodejs10.x)
    image="public.ecr.aws/lambda/nodejs:10"
    ;;
  nodejs18.x)
    image="public.ecr.aws/lambda/nodejs:18"
    ;;
  nodejs22.x)
    image="public.ecr.aws/lambda/nodejs:22-rapid-x86_64"
    ;;
  *)
    echo "Runtime non supportato o non riconosciuto: $runtime"
    exit 1
    ;;
esac

# Trova il container associato all'immagine
container_id=$(docker ps -q --filter "ancestor=$image")

# Controlla se il container esiste
if [ -z "$container_id" ]; then
  echo "Nessun contenitore trovato per l'immagine '$image'."
  exit 1
fi

# Estrai il nome del container
container_name=$(docker ps --filter "id=$container_id" --format "{{.Names}}")

# Controlla se è stato trovato un nome di container
if [ -z "$container_name" ]; then
  echo "Impossibile trovare il nome del contenitore."
  exit 1
fi

# Riavvia il contenitore
echo "Riavviando il contenitore $container_name..."
docker restart "$container_name"
