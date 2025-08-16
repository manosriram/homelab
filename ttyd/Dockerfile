# Use Ubuntu as base image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV OLLAMA_HOST=0.0.0.0

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    build-essential \
    cmake \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install ttyd
RUN wget -qO- https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 > /usr/local/bin/ttyd \
    && chmod +x /usr/local/bin/ttyd

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# Create a startup script
RUN mkdir -p /app
COPY <<'EOF' /app/start.sh
#!/bin/bash

# Start Ollama server in the background
ollama serve &

# Wait for Ollama to start
echo "Waiting for Ollama to start..."
while ! curl -s http://localhost:11434/api/version > /dev/null; do
    sleep 1
done

# Pull the codellama:13b model
echo "Pulling deepseek-coder:6.7b model..."
ollama pull deepseek-coder:6.7b

if [ -f "/root/Modelfile" ]; then
    echo "Creating custom model from Modelfile..."
    ollama create deepseek-coder:6.7b -f /root/Modelfile
    MODEL_NAME="deepseek-coder:6.7b"
else
    echo "Using default deepseek-coder:6.7b model..."
    MODEL_NAME="deepseek-coder:6.7b"
fi

# Create a script that starts the ollama run command
cat > /tmp/console.sh << 'SCRIPT'
#!/bin/bash
echo "Starting Ollama console with deepseek-coder:6.7b model..."
echo "Type your messages and press Enter. Type '/bye' to exit."
exec ollama run deepseek-coder:6.7b
SCRIPT

chmod +x /tmp/console.sh

# Start ttyd with the ollama console script
exec ttyd -p 7681 -i 0.0.0.0 /tmp/console.sh
EOF

RUN chmod +x /app/start.sh

# Expose ports
EXPOSE 7681 11434

# Set working directory
WORKDIR /app

# Start the application
CMD ["/app/start.sh"]
