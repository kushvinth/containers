# User Dashboard

A centralized dashboard for managing and accessing all self-hosted services in this repository.

## Overview

This dashboard uses [Dashy](https://github.com/Lissy93/dashy), a modern, configurable dashboard application that provides:

- **Unified Access**: Single entry point to all your services
- **Status Monitoring**: Real-time health checks for your services
- **Customizable Layout**: Organized sections for different service categories
- **Modern UI**: Material design with dark/light theme support
- **Search**: Quick search functionality to find services
- **Multi-language**: Support for multiple languages

## Quick Start

1. **Start the dashboard**:
   ```bash
   cd user-dashboard
   docker-compose up -d
   ```

2. **Access the dashboard**:
   Open your browser and navigate to `http://localhost:4000`

3. **Stop the dashboard**:
   ```bash
   docker-compose down
   ```

## Configuration

The dashboard configuration is stored in `config/dashy-config.yml`. You can customize:

- **Service URLs**: Update URLs to match your network setup
- **Icons**: Change icons for better visual representation
- **Sections**: Add, remove, or reorganize service categories
- **Theme**: Switch between light, dark, or custom themes
- **Status Checks**: Enable/disable health monitoring per service

### Example Customization

To add a new service, edit `config/dashy-config.yml`:

```yaml
- name: Your Service Category
  icon: fas fa-icon-name
  items:
    - title: Your Service
      description: Service description
      icon: hl-service-icon
      url: http://localhost:port
      statusCheck: true
```

## Features

### Service Categories

- **Media Management**: Jellyfin, Radarr, Sonarr, Lidarr, Prowlarr, Jellyseerr
- **Download & Networking**: qBittorrent, Cloudflared, Pi-hole
- **Monitoring & Utilities**: Uptime Kuma, Glance, Homepage, Speedtest Tracker
- **Productivity & Communication**: n8n, Immich
- **Gaming & Remote Access**: Minecraft, RustDesk
- **System Management**: Watchtower, BentoPDF

### Status Monitoring

The dashboard performs automatic health checks on configured services every 5 minutes (300 seconds). Services with `statusCheck: true` will show:
- 🟢 Green: Service is running and accessible
- 🔴 Red: Service is down or unreachable
- 🟡 Yellow: Service is loading or status unknown

## Advanced Configuration

### Changing the Port

To use a different port, edit `docker-compose.yml`:

```yaml
ports:
  - "YOUR_PORT:80"  # Change YOUR_PORT to desired port
```

### Adding Authentication

To add authentication, update the `appConfig` section in `dashy-config.yml`:

```yaml
appConfig:
  auth:
    users:
      - user: admin
        hash: your-hashed-password
```

Generate a hash using:
```bash
echo -n 'your-password' | sha256sum
```

### Backup Configuration

To backup your configuration:
```bash
cp config/dashy-config.yml config/dashy-config.yml.backup
```

## Troubleshooting

### Dashboard not accessible
- Check if container is running: `docker ps | grep dashy`
- View logs: `docker logs dashy_dashboard`
- Verify port is not in use: `netstat -tulpn | grep 4000`

### Services showing as down
- Ensure services are running: `docker ps`
- Check if URLs in config match your setup
- Verify network connectivity between containers

### Configuration changes not reflecting
- Restart the container: `docker-compose restart`
- Clear browser cache
- Check config file syntax: `yamllint config/dashy-config.yml`

## Resources

- [Dashy Documentation](https://dashy.to/docs/)
- [Dashy GitHub Repository](https://github.com/Lissy93/dashy)
- [Icon Reference](https://dashy.to/docs/icons)
- [Configuration Guide](https://dashy.to/docs/configuring)

## Updates

The dashboard automatically pulls the latest version when you run:
```bash
docker-compose pull
docker-compose up -d
```

## Support

For issues specific to this dashboard setup, open an issue in the repository.
For Dashy-specific questions, refer to the [Dashy documentation](https://dashy.to/docs/).
