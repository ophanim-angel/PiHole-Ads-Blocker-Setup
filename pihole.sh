#!/bin/bash

# Pi-hole Docker Quick Start Script
# This script provides easy commands to manage Pi-hole

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[Pi-hole]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Ensure .env exists
check_env() {
    if [ ! -f ".env" ]; then
        print_warning "No .env file found. Copying from .env.example..."
        cp .env.example .env
        print_warning "Please edit .env and set a strong WEBPASSWORD before starting!"
        exit 1
    fi
}

# Commands
case "${1:-help}" in
    start)
        check_env
        print_status "Starting Pi-hole container..."
        docker compose up -d
        LOCAL_IP=$(ip route get 1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1); exit}')
        print_status "Pi-hole is starting. Access it at: http://${LOCAL_IP:-<your-ip>}/admin"
        print_warning "Check your .env for the admin password."
        ;;

    stop)
        print_status "Stopping Pi-hole container..."
        docker compose down
        print_status "Pi-hole stopped."
        ;;

    restart)
        print_status "Restarting Pi-hole container..."
        docker compose restart pihole
        print_status "Pi-hole restarted."
        ;;

    logs)
        print_status "Showing Pi-hole logs (Ctrl+C to stop)..."
        docker compose logs -f pihole
        ;;

    status)
        print_status "Pi-hole container status:"
        docker compose ps pihole
        ;;

    ip)
        print_status "Your machine's local IP addresses:"
        ip -4 addr show scope global | awk '/inet / {print $2}' | cut -d/ -f1
        print_status "Point your devices' DNS to one of the above IPs."
        ;;

    password)
        if [ -z "$2" ]; then
            print_status "Changing Pi-hole admin password (interactive)..."
            docker exec -it pihole pihole setpassword
        else
            print_status "Changing Pi-hole admin password..."
            docker exec -it pihole pihole setpassword "$2"
        fi
        print_status "Password changed successfully."
        ;;

    update)
        print_status "Pulling latest Pi-hole image..."
        docker compose pull
        docker compose up -d
        print_status "Pi-hole updated and restarted."
        ;;

    clean)
        print_warning "This will remove all Pi-hole data!"
        read -p "Are you sure? (y/N) " -r CONFIRM
        echo
        if [[ $CONFIRM =~ ^[Yy]$ ]]; then
            docker compose down -v
            rm -rf etc-pihole etc-dnsmasq.d
            print_status "Pi-hole cleaned up."
        else
            print_status "Cleanup cancelled."
        fi
        ;;

    adlists)
        print_status "Adding curated ad/popup blocklists to Pi-hole..."

        # Get the Pi-hole API password from .env
        API_PASS=$(grep '^WEBPASSWORD=' .env 2>/dev/null | cut -d= -f2)
        PIHOLE_IP=$(ip route get 1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1); exit}')
        BASE="http://${PIHOLE_IP:-localhost}/api"

        # Authenticate and get session ID
        SID=$(curl -s -X POST "$BASE/auth" \
            -H "Content-Type: application/json" \
            -d "{\"password\":\"${API_PASS}\"}" | grep -o '"sid":"[^"]*"' | cut -d'"' -f4)

        if [ -z "$SID" ]; then
            print_error "Could not authenticate with Pi-hole API. Is Pi-hole running? Check your WEBPASSWORD in .env"
            exit 1
        fi

        print_status "Authenticated. Adding blocklists..."

        # Curated blocklists — general ads, trackers, and popup networks
        LISTS=(
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            "https://v.firebog.net/hosts/AdguardDNS.txt"
            "https://v.firebog.net/hosts/Easylist.txt"
            "https://v.firebog.net/hosts/Easyprivacy.txt"
            "https://v.firebog.net/hosts/Prigent-Ads.txt"
            "https://raw.githubusercontent.com/nicehash/NiceHash-adblock/master/nhAdBlock.txt"
            "https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt"
            "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts"
            "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"
        )

        for URL in "${LISTS[@]}"; do
            RESULT=$(curl -s -X POST "$BASE/lists" \
                -H "Content-Type: application/json" \
                -H "X-FTL-SID: $SID" \
                -d "{\"address\":\"$URL\",\"type\":\"block\",\"comment\":\"Added by pihole.sh adlists\",\"enabled\":true}")
            if echo "$RESULT" | grep -q '"processed"'; then
                print_status "Added: $URL"
            else
                print_warning "Already exists or error: $URL"
            fi
        done

        # Refresh gravity (update the block database)
        print_status "Updating gravity database (this may take a minute)..."
        docker exec pihole pihole updateGravity
        print_status "Done! Popup and ad network blocking is now active on all devices."
        ;;

    help|--help|-h)
        echo "Pi-hole Docker Quick Start"
        echo ""
        echo "Usage: ./pihole.sh [command]"
        echo ""
        echo "Commands:"
        echo "  start            - Start Pi-hole container"
        echo "  stop             - Stop Pi-hole container"
        echo "  restart          - Restart Pi-hole container"
        echo "  logs             - Show Pi-hole logs (follow mode)"
        echo "  status           - Show container status"
        echo "  ip               - Show your machine's local IP addresses"
        echo "  password <pass>  - Change the admin password"
        echo "  update           - Pull latest image and restart"
        echo "  adlists          - Add curated popup/ad blocklists and refresh gravity"
        echo "  clean            - Remove container and all data"
        echo "  help             - Show this help message"
        echo ""
        echo "Examples:"
        echo "  ./pihole.sh start"
        echo "  ./pihole.sh password mysecurepassword"
        echo "  ./pihole.sh ip"
        ;;

    *)
        print_error "Unknown command: $1"
        echo "Run './pihole.sh help' for available commands"
        exit 1
        ;;
esac
