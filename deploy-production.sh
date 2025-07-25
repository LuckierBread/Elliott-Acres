#!/bin/bash
# Production Deployment Script for Elliott Acres

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

# Pre-deployment checks
check_requirements() {
    log "Checking deployment requirements..."
    
    # Check if .env file exists
    if [ ! -f ".env" ]; then
        error ".env file not found. Copy .env.example to .env and configure it."
    fi
    
    # Check if required environment variables are set
    source .env
    
    if [ -z "$SECRET_KEY" ] || [ "$SECRET_KEY" = "your-super-secure-secret-key-here-change-this" ]; then
        error "SECRET_KEY must be set to a secure value in .env"
    fi
    
    if [ -z "$DB_PASSWORD" ] || [ "$DB_PASSWORD" = "your-secure-database-password-here" ]; then
        error "DB_PASSWORD must be set to a secure value in .env"
    fi
    
    if [ -z "$DOMAIN_NAME" ]; then
        error "DOMAIN_NAME must be set in .env"
    fi
    
    if [ -z "$ADMIN_EMAIL" ]; then
        error "ADMIN_EMAIL must be set in .env"
    fi
    
    # Check if Docker is running
    if ! docker info > /dev/null 2>&1; then
        error "Docker is not running or not accessible"
    fi
    
    # Check if Docker Compose is available
    if ! command -v docker-compose > /dev/null 2>&1; then
        error "docker-compose is not installed or not in PATH"
    fi
    
    log "All requirements check passed"
}

# Backup existing data
backup_data() {
    log "Creating backup of existing data..."
    
    BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Backup database if it exists
    if docker-compose ps db | grep -q "Up"; then
        log "Backing up database..."
        docker-compose exec -T db pg_dump -U elliott_user elliott_acres > "$BACKUP_DIR/database.sql"
    fi
    
    # Backup uploads
    if [ -d "static/uploads" ]; then
        log "Backing up uploaded files..."
        cp -r static/uploads "$BACKUP_DIR/"
    fi
    
    log "Backup created in $BACKUP_DIR"
}

# Deploy application
deploy() {
    log "Starting production deployment..."
    
    # Pull latest images
    log "Pulling latest Docker images..."
    docker-compose pull
    
    # Build application
    log "Building application..."
    docker-compose build --no-cache
    
    # Start services
    log "Starting services..."
    docker-compose up -d
    
    # Wait for services to be healthy
    log "Waiting for services to be healthy..."
    timeout=60
    while [ $timeout -gt 0 ]; do
        if docker-compose ps | grep -q "Up (healthy)"; then
            break
        fi
        sleep 2
        timeout=$((timeout - 2))
    done
    
    if [ $timeout -eq 0 ]; then
        warn "Services may not be fully healthy, check with: docker-compose ps"
    else
        log "Services are healthy"
    fi
    
    # Run database migrations if needed
    log "Running database setup..."
    docker-compose exec web python -c "
from app import app, db
with app.app_context():
    db.create_all()
    print('Database tables created/updated')
"
    
    log "Deployment completed successfully"
}

# Setup SSL certificates
setup_ssl() {
    log "Setting up SSL certificates..."
    
    # Make ssl-manager.sh executable
    chmod +x ssl-manager.sh
    
    # Obtain certificate
    ./ssl-manager.sh obtain
    
    # Setup automatic renewal
    ./ssl-manager.sh setup-auto
    
    log "SSL setup completed"
}

# Post-deployment verification
verify_deployment() {
    log "Verifying deployment..."
    
    # Check if all services are running
    if ! docker-compose ps | grep -q "Up"; then
        error "Some services are not running properly"
    fi
    
    # Check health endpoint
    source .env
    if command -v curl > /dev/null 2>&1; then
        if curl -f "https://$DOMAIN_NAME/health" > /dev/null 2>&1; then
            log "Health check passed"
        else
            warn "Health check failed - check application logs"
        fi
    fi
    
    log "Deployment verification completed"
}

# Show post-deployment information
show_info() {
    source .env
    
    info "=================================="
    info "DEPLOYMENT COMPLETED SUCCESSFULLY"
    info "=================================="
    info ""
    info "Website URL: https://$DOMAIN_NAME"
    info "Admin Panel: https://$DOMAIN_NAME/admin"
    info ""
    info "Useful commands:"
    info "  View logs: docker-compose logs -f"
    info "  Check status: docker-compose ps"
    info "  Restart: docker-compose restart"
    info "  Update: ./deploy-production.sh"
    info ""
    info "SSL Certificate:"
    info "  Renew manually: ./ssl-manager.sh renew"
    info "  Auto-renewal is set up via cron"
    info ""
    info "Monitoring:"
    info "  Health check: https://$DOMAIN_NAME/health"
    info "  Database backups: Located in backups/ directory"
}

# Main execution
main() {
    case "${1:-deploy}" in
        "check")
            check_requirements
            ;;
        "backup")
            check_requirements
            backup_data
            ;;
        "deploy")
            check_requirements
            backup_data
            deploy
            verify_deployment
            show_info
            ;;
        "ssl")
            check_requirements
            setup_ssl
            ;;
        "verify")
            verify_deployment
            ;;
        *)
            echo "Usage: $0 {check|backup|deploy|ssl|verify}"
            echo ""
            echo "Commands:"
            echo "  check   - Check deployment requirements"
            echo "  backup  - Create backup of existing data"
            echo "  deploy  - Full deployment (default)"
            echo "  ssl     - Setup SSL certificates"
            echo "  verify  - Verify deployment status"
            exit 1
            ;;
    esac
}

main "$@"
