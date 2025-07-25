#!/bin/bash
# SSL Certificate Management Script for Elliott Acres

set -e

DOMAIN_NAME=${DOMAIN_NAME:-elliottacres.com}
ADMIN_EMAIL=${ADMIN_EMAIL:-admin@elliottacres.com}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

# Function to obtain SSL certificate
obtain_certificate() {
    log "Obtaining SSL certificate for $DOMAIN_NAME"
    
    # Create temporary nginx config for certificate challenge
    cat > /tmp/nginx-cert-challenge.conf << EOF
events {
    worker_connections 1024;
}

http {
    server {
        listen 80;
        server_name $DOMAIN_NAME www.$DOMAIN_NAME;
        
        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }
        
        location / {
            return 301 https://\$server_name\$request_uri;
        }
    }
}
EOF

    # Start nginx with challenge config
    docker run --rm -d \
        --name nginx-cert-challenge \
        -p 80:80 \
        -v /tmp/nginx-cert-challenge.conf:/etc/nginx/nginx.conf:ro \
        -v certbot_www:/var/www/certbot \
        nginx:alpine

    # Obtain certificate
    docker-compose --profile certbot run --rm certbot

    # Stop challenge nginx
    docker stop nginx-cert-challenge

    log "SSL certificate obtained successfully"
}

# Function to renew SSL certificate
renew_certificate() {
    log "Renewing SSL certificate"
    docker-compose --profile certbot run --rm certbot renew
    
    if [ $? -eq 0 ]; then
        log "Certificate renewed successfully, reloading nginx"
        docker-compose exec nginx nginx -s reload
    else
        warn "Certificate renewal failed or not needed"
    fi
}

# Function to setup automatic renewal
setup_auto_renewal() {
    log "Setting up automatic certificate renewal"
    
    # Create renewal script
    cat > /usr/local/bin/renew-ssl.sh << 'EOF'
#!/bin/bash
cd /path/to/elliott-acres
docker-compose --profile certbot run --rm certbot renew
if [ $? -eq 0 ]; then
    docker-compose exec nginx nginx -s reload
fi
EOF

    chmod +x /usr/local/bin/renew-ssl.sh

    # Add to crontab (runs twice daily)
    (crontab -l 2>/dev/null; echo "0 12,23 * * * /usr/local/bin/renew-ssl.sh >> /var/log/ssl-renewal.log 2>&1") | crontab -
    
    log "Automatic renewal set up - certificates will be checked twice daily"
}

# Main execution
case "${1:-}" in
    "obtain")
        obtain_certificate
        ;;
    "renew")
        renew_certificate
        ;;
    "setup-auto")
        setup_auto_renewal
        ;;
    *)
        echo "Usage: $0 {obtain|renew|setup-auto}"
        echo ""
        echo "Commands:"
        echo "  obtain     - Obtain initial SSL certificate"
        echo "  renew      - Renew existing SSL certificate"
        echo "  setup-auto - Setup automatic renewal via cron"
        exit 1
        ;;
esac
