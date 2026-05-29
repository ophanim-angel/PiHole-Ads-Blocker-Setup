FROM pihole/pihole:latest

# Expose ports
# Port 53  - DNS (both TCP and UDP)
# Port 80  - Web interface HTTP
# Port 443 - Web interface HTTPS
# Port 67  - DHCP (optional)
EXPOSE 53/tcp 53/udp 80/tcp 443/tcp 67/udp

# Volume for configuration persistence
VOLUME ["/etc/pihole", "/etc/dnsmasq.d"]

# NOTE: Do NOT override CMD here — Pi-hole uses its own init system (s6-overlay)
# which is already set in the official base image. Overriding it breaks startup.
