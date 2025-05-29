# 🚀 Open WebUI Quick Start

Get Open WebUI running on your network with a single command!

## Prerequisites

- **Docker** must be installed and running
- **Internet connection** for downloading containers and AI models

## One-Command Setup

```bash
./quick-start.sh
```

That's it! This single command will:

1. ✅ Check Docker installation
2. 🧹 Clean up any existing containers
3. 🌐 Create a Docker network
4. 🦙 Start Ollama (AI model server)
5. 📥 Download a default AI model
6. 🌐 Start Open WebUI interface
7. ⏳ Wait for services to be ready
8. 📱 Display network access URLs

## Access Your AI Chat

After running the script, you'll see output like:

```
🎉 Open WebUI is now running!
================================
Local access:     http://localhost:3000
Network access:   http://192.168.1.100:3000
Ollama API:       http://192.168.1.100:11434

📱 Access from any device on your network using: http://192.168.1.100:3000
```

### First-Time Setup

1. Open the network URL in any browser on your network
2. Create an admin account (first user becomes admin)
3. Start chatting with AI models!

## Network Access

The script automatically:
- Binds to `0.0.0.0` (all network interfaces)
- Detects your local IP address
- Makes the service accessible to your entire network

Any device on your network can access the chat interface using your computer's IP address.

## Management Commands

```bash
# Stop services
docker stop open-webui-quick ollama-quick

# Start services
docker start ollama-quick && docker start open-webui-quick

# View logs
docker logs open-webui-quick

# Remove everything
docker stop open-webui-quick ollama-quick && docker rm open-webui-quick ollama-quick
```

## Features

- 🤖 **AI Chat Interface** - Clean, modern web UI
- 🌐 **Network Access** - Available to all devices on your network
- 🦙 **Ollama Integration** - Local AI model server
- 📱 **Mobile Friendly** - Works on phones, tablets, computers
- 🔒 **User Management** - Admin controls and user accounts
- 📁 **File Upload** - Chat with documents
- 🎨 **Customizable** - Themes, settings, and more

## Troubleshooting

### Docker Not Found
```bash
# Install Docker Desktop from:
# https://docs.docker.com/get-docker/
```

### Port Already in Use
The script uses ports 3000 and 11434. If these are busy, stop other services or modify the script.

### Can't Access from Network
- Check your firewall settings
- Ensure your router allows local network communication
- Try accessing via the exact IP shown in the script output

### Models Not Loading
The script automatically downloads a small AI model. If it fails:
1. Open the web interface
2. Go to Settings → Models
3. Download models manually

## What's Running

After setup, you'll have:
- **Open WebUI** container on port 3000
- **Ollama** container on port 11434
- **Docker volumes** for persistent data
- **AI models** ready to use

Enjoy your local AI chat system! 🎉 