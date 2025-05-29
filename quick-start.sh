#!/bin/bash

# Open WebUI Quick Start Script
# This script sets up and runs Open WebUI with network access in one command

set -e

# Define color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
WEBUI_PORT=3000
OLLAMA_PORT=11434
CONTAINER_NAME="open-webui-quick"
OLLAMA_CONTAINER_NAME="ollama-quick"
NETWORK_NAME="openwebui-network"

echo -e "${BLUE}🚀 Open WebUI Quick Start${NC}"
echo -e "${BLUE}=========================${NC}"

# Function to check if Docker is installed and running
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker is not installed. Please install Docker first.${NC}"
        echo -e "${YELLOW}Visit: https://docs.docker.com/get-docker/${NC}"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Docker is installed and running${NC}"
}

# Function to get local IP address
get_local_ip() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        LOCAL_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -n1)
    else
        # Linux
        LOCAL_IP=$(hostname -I | awk '{print $1}')
    fi
    echo $LOCAL_IP
}

# Function to cleanup existing containers
cleanup() {
    echo -e "${YELLOW}🧹 Cleaning up existing containers...${NC}"
    docker stop $CONTAINER_NAME $OLLAMA_CONTAINER_NAME 2>/dev/null || true
    docker rm $CONTAINER_NAME $OLLAMA_CONTAINER_NAME 2>/dev/null || true
    docker network rm $NETWORK_NAME 2>/dev/null || true
}

# Function to create Docker network
create_network() {
    echo -e "${YELLOW}🌐 Creating Docker network...${NC}"
    docker network create $NETWORK_NAME 2>/dev/null || true
}

# Function to start Ollama container
start_ollama() {
    echo -e "${YELLOW}🦙 Starting Ollama container...${NC}"
    docker run -d \
        --name $OLLAMA_CONTAINER_NAME \
        --network $NETWORK_NAME \
        -p $OLLAMA_PORT:11434 \
        -v ollama-data:/root/.ollama \
        --restart unless-stopped \
        ollama/ollama:latest
    
    echo -e "${GREEN}✅ Ollama container started${NC}"
    
    # Wait for Ollama to be ready
    echo -e "${YELLOW}⏳ Waiting for Ollama to be ready...${NC}"
    sleep 10
    
    # Pull a default model
    echo -e "${YELLOW}📥 Pulling default model (llama3.2:1b)...${NC}"
    docker exec $OLLAMA_CONTAINER_NAME ollama pull llama3.2:1b || {
        echo -e "${YELLOW}⚠️  Failed to pull llama3.2:1b, trying llama3.2:3b...${NC}"
        docker exec $OLLAMA_CONTAINER_NAME ollama pull llama3.2:3b || {
            echo -e "${YELLOW}⚠️  Failed to pull models automatically. You can pull them later via the UI.${NC}"
        }
    }
}

# Function to start Open WebUI container
start_webui() {
    echo -e "${YELLOW}🌐 Starting Open WebUI container...${NC}"
    docker run -d \
        --name $CONTAINER_NAME \
        --network $NETWORK_NAME \
        -p $WEBUI_PORT:8080 \
        -v open-webui-data:/app/backend/data \
        -e OLLAMA_BASE_URL=http://$OLLAMA_CONTAINER_NAME:11434 \
        -e WEBUI_SECRET_KEY=$(openssl rand -hex 32 2>/dev/null || echo "fallback-secret-key-$(date +%s)") \
        --restart unless-stopped \
        ghcr.io/open-webui/open-webui:main
    
    echo -e "${GREEN}✅ Open WebUI container started${NC}"
}

# Function to wait for services to be ready
wait_for_services() {
    echo -e "${YELLOW}⏳ Waiting for services to be ready...${NC}"
    
    # Wait for Open WebUI to be ready
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s http://localhost:$WEBUI_PORT/health > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Open WebUI is ready!${NC}"
            break
        fi
        
        if [ $attempt -eq $max_attempts ]; then
            echo -e "${YELLOW}⚠️  Services may still be starting up. Check manually if needed.${NC}"
            break
        fi
        
        echo -e "${YELLOW}   Attempt $attempt/$max_attempts - waiting...${NC}"
        sleep 5
        ((attempt++))
    done
}

# Function to display access information
show_access_info() {
    local local_ip=$(get_local_ip)
    
    echo -e "\n${GREEN}🎉 Open WebUI is now running!${NC}"
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}Local access:${NC}     http://localhost:$WEBUI_PORT"
    echo -e "${GREEN}Network access:${NC}   http://$local_ip:$WEBUI_PORT"
    echo -e "${GREEN}Ollama API:${NC}       http://$local_ip:$OLLAMA_PORT"
    echo -e "\n${BLUE}📱 Access from any device on your network using: http://$local_ip:$WEBUI_PORT${NC}"
    echo -e "\n${YELLOW}📝 First-time setup:${NC}"
    echo -e "   1. Open the URL above in your browser"
    echo -e "   2. Create an admin account (first user becomes admin)"
    echo -e "   3. Start chatting with AI models!"
    echo -e "\n${YELLOW}🛠️  Management commands:${NC}"
    echo -e "   Stop:    docker stop $CONTAINER_NAME $OLLAMA_CONTAINER_NAME"
    echo -e "   Start:   docker start $OLLAMA_CONTAINER_NAME && docker start $CONTAINER_NAME"
    echo -e "   Logs:    docker logs $CONTAINER_NAME"
    echo -e "   Remove:  docker stop $CONTAINER_NAME $OLLAMA_CONTAINER_NAME && docker rm $CONTAINER_NAME $OLLAMA_CONTAINER_NAME"
}

# Main execution
main() {
    echo -e "${BLUE}Starting Open WebUI setup...${NC}\n"
    
    check_docker
    cleanup
    create_network
    start_ollama
    start_webui
    wait_for_services
    show_access_info
    
    echo -e "\n${GREEN}🚀 Setup complete! Enjoy using Open WebUI!${NC}"
}

# Handle script interruption
trap 'echo -e "\n${RED}❌ Setup interrupted. Run the script again to retry.${NC}"; exit 1' INT

# Run main function
main 