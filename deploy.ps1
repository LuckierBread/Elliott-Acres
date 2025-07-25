# Elliott Acres Farm Website Deployment Script for Windows
# This script sets up the complete production environment on Windows

param(
    [switch]$Development,
    [switch]$Production
)

# Color output functions
function Write-Status {
    param($Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warning {
    param($Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param($Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

Write-Host "🌾 Elliott Acres Farm - Windows Deployment Script" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Check if Docker is installed
try {
    docker --version | Out-Null
    Write-Status "Docker found"
} catch {
    Write-Error "Docker is not installed or not in PATH. Please install Docker Desktop."
    exit 1
}

# Check if Docker Compose is installed
try {
    docker-compose --version | Out-Null
    Write-Status "Docker Compose found"
} catch {
    Write-Error "Docker Compose is not installed or not in PATH."
    exit 1
}

# Determine environment
if ($Development) {
    $envFile = ".env"
    Write-Status "Setting up for DEVELOPMENT environment"
} elseif ($Production) {
    $envFile = ".env.production"
    Write-Status "Setting up for PRODUCTION environment"
    
    if (-not (Test-Path $envFile)) {
        Write-Error "$envFile file not found. Please create it from .env.production template."
        exit 1
    }
    Copy-Item $envFile ".env" -Force
} else {
    Write-Status "No environment specified. Using existing .env file or development defaults."
}

Write-Status "Creating necessary directories..."
$directories = @(
    "static\uploads\blog",
    "static\uploads\gallery",
    "ssl",
    "backups",
    "instance"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Status "Created directory: $dir"
    }
}

# For development, start without Docker
if ($Development) {
    Write-Status "Starting development server..."
    
    # Activate virtual environment if it exists
    if (Test-Path "venv\Scripts\Activate.ps1") {
        Write-Status "Activating virtual environment..."
        & "venv\Scripts\Activate.ps1"
    }
    
    # Install requirements if needed
    if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
        Write-Error "Python is not installed or not in PATH."
        exit 1
    }
    
    Write-Status "Installing Python dependencies..."
    pip install -r requirements.txt
    
    Write-Status "Starting Flask development server..."
    python app.py
    
} else {
    # Production deployment with Docker
    Write-Status "Building Docker images..."
    docker-compose build
    
    Write-Status "Starting services..."
    docker-compose up -d
    
    Write-Status "Waiting for services to start..."
    Start-Sleep -Seconds 30
    
    Write-Status "Running database migrations..."
    docker-compose exec web python -c "
from app import app, db
with app.app_context():
    db.create_all()
    print('Database tables created successfully!')
"
    
    Write-Status "Creating admin user..."
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
    
    Write-Status "Initializing sample data..."
    docker-compose exec web python -c "
from app import app, init_sample_data
with app.app_context():
    init_sample_data()
    print('Sample data initialized successfully!')
"
    
    Write-Status "Creating backup script..."
    $backupScript = @"
# Database backup script for Windows
`$BackupDir = "backups"
`$Date = Get-Date -Format "yyyyMMdd_HHmmss"
`$ContainerName = "elliott-acres_db_1"

# Create backup
docker exec `$ContainerName pg_dump -U elliott_user elliott_acres > "`$BackupDir\elliott_acres_`$Date.sql"

# Keep only last 7 days of backups
Get-ChildItem `$BackupDir -Name "elliott_acres_*.sql" | Where-Object { `$_.CreationTime -lt (Get-Date).AddDays(-7) } | Remove-Item

Write-Host "Backup completed: elliott_acres_`$Date.sql"
"@
    
    $backupScript | Out-File -FilePath "backup_script.ps1" -Encoding UTF8
    
    Write-Status "Deployment completed successfully! 🎉"
    Write-Host ""
    Write-Host "Services Status:" -ForegroundColor Cyan
    docker-compose ps
    
    Write-Host ""
    Write-Host "Access URLs:" -ForegroundColor Cyan
    Write-Host "🌐 Website: http://localhost" -ForegroundColor White
    Write-Host "🔐 Admin Panel: http://localhost/admin (username: admin, password: admin123)" -ForegroundColor White
    Write-Host "📊 Database: PostgreSQL on localhost:5432" -ForegroundColor White
    
    Write-Host ""
    Write-Host "Useful Commands:" -ForegroundColor Cyan
    Write-Host "📋 View logs: docker-compose logs -f" -ForegroundColor White
    Write-Host "🔄 Restart services: docker-compose restart" -ForegroundColor White
    Write-Host "🛑 Stop services: docker-compose down" -ForegroundColor White
    Write-Host "🗄️ Database backup: .\backup_script.ps1" -ForegroundColor White
}

Write-Host ""
Write-Warning "Remember to:"
Write-Warning "1. Change default admin password"
Write-Warning "2. Update .env.production with real credentials"
Write-Warning "3. Configure proper SSL certificates for production"
Write-Warning "4. Set up monitoring and alerting"
Write-Warning "5. Configure firewall rules"
