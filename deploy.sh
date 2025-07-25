#!/bin/bash

# Elliott Acres Farm Website Deployment Script
# This script sets up the complete production environment

set -e  # Exit on any error

echo "🌾 Elliott Acres Farm - Production Deployment Script"
echo "=================================================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

print_status "Creating production environment file..."
if [ ! -f .env.production ]; then
    print_error ".env.production file not found. Please create it from .env.production template."
    exit 1
fi

# Copy production environment
cp .env.production .env

print_status "Creating necessary directories..."
mkdir -p static/uploads/blog
mkdir -p static/uploads/gallery
mkdir -p ssl
mkdir -p backups

print_status "Setting up SSL certificates (self-signed for development)..."
if [ ! -f ssl/server.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout ssl/server.key \
        -out ssl/server.crt \
        -subj "/C=US/ST=State/L=City/O=Elliott Acres/CN=localhost"
    print_status "Self-signed SSL certificate created."
fi

print_status "Building Docker images..."
docker-compose build

print_status "Starting services..."
docker-compose up -d

print_status "Waiting for services to start..."
sleep 30

print_status "Running database migrations..."
docker-compose exec web python -c "
from app import app, db
with app.app_context():
    db.create_all()
    print('Database tables created successfully!')
"

print_status "Creating admin user..."
docker-compose exec web python -c "
from app import app, db, User
import bcrypt
with app.app_context():
    admin = User.query.filter_by(username='admin').first()
    if not admin:
        hashed_password = bcrypt.hashpw('admin123'.encode('utf-8'), bcrypt.gensalt())
        admin = User(username='admin', email='admin@elliottacres.com', password_hash=hashed_password.decode('utf-8'), is_admin=True)
        db.session.add(admin)
        db.session.commit()
        print('Admin user created successfully!')
    else:
        print('Admin user already exists.')
"

print_status "Initializing sample data..."
docker-compose exec web python -c "
from app import app, init_sample_data
with app.app_context():
    init_sample_data()
    print('Sample data initialized successfully!')
"

print_status "Setting up backup cron job..."
cat > backup_script.sh << 'EOF'
#!/bin/bash
# Database backup script
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
CONTAINER_NAME="elliott-acres_db_1"

# Create backup
docker exec $CONTAINER_NAME pg_dump -U elliott_user elliott_acres > "$BACKUP_DIR/elliott_acres_$DATE.sql"

# Keep only last 7 days of backups
find $BACKUP_DIR -name "elliott_acres_*.sql" -mtime +7 -delete

echo "Backup completed: elliott_acres_$DATE.sql"
EOF

chmod +x backup_script.sh

# Add to crontab (run daily at 2 AM)
(crontab -l 2>/dev/null; echo "0 2 * * * $(pwd)/backup_script.sh") | crontab -

print_status "Deployment completed successfully! 🎉"
echo ""
echo "Services Status:"
docker-compose ps

echo ""
echo "Access URLs:"
echo "🌐 Website: http://localhost"
echo "🔐 Admin Panel: http://localhost/admin (username: admin, password: admin123)"
echo "📊 Database: PostgreSQL on localhost:5432"

echo ""
echo "Useful Commands:"
echo "📋 View logs: docker-compose logs -f"
echo "🔄 Restart services: docker-compose restart"
echo "🛑 Stop services: docker-compose down"
echo "🗄️ Database backup: ./backup_script.sh"

print_warning "Remember to:"
print_warning "1. Change default admin password"
print_warning "2. Update .env.production with real credentials"
print_warning "3. Configure proper SSL certificates for production"
print_warning "4. Set up monitoring and alerting"
print_warning "5. Configure firewall rules"
