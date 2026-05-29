# Pi-hole Docker Setup

This project provides a complete Docker setup for running **Pi-hole**, an open-source network-wide ad blocker that acts as a DNS sink.

## 📋 What is Pi-hole?

Pi-hole is a DNS sinkhole that protects your devices from unwanted content, without installing any client-side software. It works by:
- Blocking ads and trackers at the DNS level
- Filtering DNS queries across your entire network
- Providing a web interface for management and statistics
- Supporting DHCP server functionality (optional)

## 🚀 Quick Start

### Prerequisites

- **Docker** installed and running
- **Docker Compose** installed
- At least 512MB RAM available
- Ports 53 (DNS), 80 (HTTP), and 443 (HTTPS) available on your host

### Installation

1. **Clone or navigate to this project directory**
   ```bash
   cd pihole
   ```

2. **Start the Pi-hole container**
   ```bash
   docker-compose up -d
   ```

3. **Access the web interface**
   - Open your browser and go to: `http://localhost/admin`
   - Login with password: `admin123` (⚠️ **Change this immediately!**)

4. **Configure your DNS**
   - Point your devices to the Pi-hole container's IP address as their DNS server
   - Or configure your router's DHCP to use Pi-hole as the DNS server

## 📝 Configuration

### Change Admin Password

1. Access the web interface at `http://localhost/admin`
2. Go to **Settings** → **Security** → **Admin Password**
3. Set a strong password

### Important Environment Variables

Edit the `docker-compose.yml` file to customize:

| Variable | Default | Description |
|----------|---------|-------------|
| `WEBPASSWORD` | `admin123` | Admin web interface password |
| `TZ` | `UTC` | Timezone (e.g., `Europe/Paris`, `America/New_York`) |
| `QUERY_LOGGING` | `true` | Enable DNS query logging |
| `TEMPERATURE_UNIT` | `C` | Temperature display (C or F) |

### Custom DNS Records (Adlists)

1. Go to **Adlists** in the web interface
2. Add blocklists to customize filtering
3. Examples:
   - https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
   - https://adaway.org/hosts.txt

## 🔧 Advanced Setup

### Configure DHCP Server

Edit `docker-compose.yml` and uncomment DHCP-related environment variables to enable DHCP functionality.

### Custom dnsmasq Configuration

Add custom DNS rules by creating `etc-dnsmasq.d/custom.conf`:
```conf
# Example: Local DNS records
address=/my-service.local/192.168.1.100
address=/another-service.local/192.168.1.101
```

### Whitelist/Blacklist Domains

1. Go to **Whitelist** or **Blacklist** in the web interface
2. Add domains to filter

## 🛑 Stop and Remove

### Stop the container (preserve data)
```bash
docker-compose down
```

### Stop and remove all data
```bash
docker-compose down -v
```

### View logs
```bash
docker-compose logs -f pihole
```

## 🌐 Connect Devices to Pi-hole

### Windows
1. Go to **Settings** → **Network & Internet** → **Change adapter options**
2. Right-click your network connection → **Properties**
3. Select **Internet Protocol Version 4 (TCP/IPv4)** → **Properties**
4. Set DNS to Pi-hole's IP address

### macOS
1. Go to **System Preferences** → **Network**
2. Select your connection → **Advanced** → **DNS**
3. Click **+** and add Pi-hole's IP address

### Linux
Edit `/etc/resolv.conf` or configure NetworkManager:
```bash
nameserver <pi-hole-ip>
```

### Router Configuration (Recommended)
Configure your router's DHCP settings to use Pi-hole as the default DNS server for all connected devices.

## 📊 Web Interface Features

- **Dashboard**: View blocked ads statistics
- **Whitelist/Blacklist**: Manage domain filtering
- **Adlists**: Add custom blocklists
- **Query Log**: See DNS queries in real-time
- **Settings**: Configure various options
- **Tools**: Gravity database, API access, and more

## 🐛 Troubleshooting

### Container won't start
```bash
docker-compose logs pihole
```
Check for port conflicts or permission issues.

### DNS queries not being blocked
- Ensure devices are configured to use Pi-hole as their DNS server
- Check the Query Log in the web interface
- Verify adlists are enabled

### Web interface not accessible
- Verify port 80 is not blocked by a firewall
- Check if the container is running: `docker-compose ps`
- Restart the container: `docker-compose restart pihole`

### Performance issues
- Increase container resources in `docker-compose.yml`
- Reduce the number of adlists

## 📚 Additional Resources

- [Official Pi-hole Documentation](https://docs.pi-hole.net/)
- [Docker Hub Pi-hole Image](https://hub.docker.com/r/pihole/pihole)
- [Pi-hole GitHub Repository](https://github.com/pi-hole/pi-hole)
- [dnsmasq Documentation](http://www.thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html)

## 🔐 Security Notes

⚠️ **Important:**
- Change the default password immediately
- Use a reverse proxy (Nginx, Traefik) for HTTPS in production
- Keep Docker and Pi-hole updated regularly
- Restrict access to the web interface on untrusted networks

## 📝 Project Structure

```
pihole/
├── Dockerfile              # Container definition
├── docker-compose.yml      # Docker Compose configuration
├── README.md              # This file
├── etc-pihole/            # Pi-hole configuration (created at runtime)
└── etc-dnsmasq.d/         # dnsmasq custom configuration (created at runtime)
```

## 💡 Tips

- Use Pi-hole with **DNS-over-HTTPS (DoH)** for enhanced privacy
- Set up **Conditional Forwarding** to resolve local network domains
- Enable **DNSSEC** for added security
- Use **Groups** to manage filtering rules for different devices

## 🛡️ Optional: Web Proxy Setup (Privoxy)

This project includes **Privoxy** for additional web filtering. If you wish to use it, you must configure your device's browser or system settings to route traffic through the proxy.

**Proxy Details:**
- **Proxy IP:** `<Your-Local-Machine-IP>`
- **Port:** `4747`

### How to configure:

#### Browser Setup (e.g., Firefox, Chrome/Edge via extensions)
1. In your browser's proxy settings, set the **HTTP/HTTPS Proxy** to your machine's local IP.
2. Set the port to `4747`.

#### System-Wide (Linux/macOS)
You can set the environment variables in your terminal:
```bash
export http_proxy=http://<YOUR_MACHINE_IP>:4747
export https_proxy=http://<YOUR_MACHINE_IP>:4747
```
## 📄 License

Pi-hole is released under the EUPL 1.2 license. See the [official repository](https://github.com/pi-hole/pi-hole) for details.

---

**Enjoy a cleaner, ad-free browsing experience! 🚀**
