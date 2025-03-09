#!/bin/sh
sleep 3
for model in $OLLAMA_MODELS; do
  if [ -n "$model" ]; then
    ollama pull "$model"
  fi
done
