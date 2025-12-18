```
   _____            _        _                     
  / ____|          | |      (_)                    
 | |     ___  _ __ | |_ __ _ _ _ __   ___ _ __ ___ 
 | |    / _ \| '_ \| __/ _` | | '_ \ / _ \ '__/ __|
 | |___| (_) | | | | || (_| | | | | |  __/ |  \__ \
  \_____\___/|_| |_|\__\__,_|_|_| |_|\___|_|  |___/
                                                   
```

## 📊 User Dashboard

A centralized dashboard for managing all your self-hosted services in one place!

**Quick Start:**
```bash
cd user-dashboard
docker-compose up -d
```

**Access:** http://localhost:4000

The user dashboard provides:
- 🎯 Single entry point to all services
- 💚 Real-time health monitoring
- 🎨 Modern, customizable UI
- 🔍 Quick search functionality
- 📱 Mobile-responsive design

See [user-dashboard/README.md](user-dashboard/README.md) for detailed documentation.

---

## 📦 Available Services

This repository contains Docker Compose configurations for various self-hosted services:

### Media Management
- **arr/** - Radarr, Sonarr, Lidarr, Prowlarr, Jellyfin, Jellyseerr, qBittorrent
- **jellyfin/** - Media server configuration

### Monitoring & Dashboards
- **user-dashboard/** - Unified dashboard for all services (Dashy)
- **homepage/** - Alternative homepage dashboard
- **glance/** - At-a-glance dashboard
- **uptimekuma/** - Uptime monitoring

### Networking & Security
- **pihole/** - Network-wide ad blocking
- **cloudflared/** - Cloudflare tunnel
- **ddns/** - Dynamic DNS updates

### Productivity & Utilities
- **n8n/** - Workflow automation
- **immich/** - Photo management
- **bentopdf/** - PDF utilities
- **speedtest/** - Network speed monitoring

### Gaming & Remote Access
- **minecraft/** - Minecraft server
- **rustdesk/** - Remote desktop

### System Management
- **watchtower/** - Automated container updates

---

## 🚀 Getting Started

1. Clone this repository
2. Navigate to the service directory you want to use
3. Review and customize the `docker-compose.yml` file
4. Create any necessary `.env` files
5. Run `docker-compose up -d`

## 💡 Tips

- Use the **user-dashboard** as your central access point
- Check individual service READMEs for specific configuration details
- Ensure required directories and environment variables are set before starting services

## 🤝 Contributing

Feel free to open issues or submit pull requests for improvements!                                                   