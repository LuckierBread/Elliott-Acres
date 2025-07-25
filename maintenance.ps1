# Elliott Acres Farm - Maintenance Script
# Common maintenance tasks for the website

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("backup", "logs", "restart", "update", "clean", "status", "reset-admin")]
    [string]$Task
)

function Write-Status {
    param($Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warning {
    param($Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

Write-Host "🌾 Elliott Acres Farm - Maintenance Tools" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

switch ($Task) {
    "backup" {
        Write-Status "Creating database backup..."
        $Date = Get-Date -Format "yyyyMMdd_HHmmss"
        
        if (Test-Path "docker-compose.yml") {
            # Docker deployment
            docker-compose exec db pg_dump -U elliott_user elliott_acres > "backups\elliott_acres_$Date.sql"
            Write-Status "Backup created: backups\elliott_acres_$Date.sql"
        } else {
            # Development deployment
            if (Test-Path "instance\farm.db") {
                Copy-Item "instance\farm.db" "backups\farm_$Date.db"
                Write-Status "Backup created: backups\farm_$Date.db"
            } else {
                Write-Warning "No database found to backup"
            }
        }
    }
    
    "logs" {
        Write-Status "Showing recent logs..."
        if (Test-Path "docker-compose.yml") {
            docker-compose logs --tail=50 -f
        } else {
            if (Test-Path "app.log") {
                Get-Content "app.log" -Tail 50 -Wait
            } else {
                Write-Warning "No log files found"
            }
        }
    }
    
    "restart" {
        Write-Status "Restarting services..."
        if (Test-Path "docker-compose.yml") {
            docker-compose restart
            Write-Status "Services restarted"
        } else {
            Write-Warning "This command is for Docker deployments only"
        }
    }
    
    "update" {
        Write-Status "Updating application..."
        
        # Git pull if in a git repository
        if (Test-Path ".git") {
            git pull origin main
        }
        
        # Rebuild containers if Docker deployment
        if (Test-Path "docker-compose.yml") {
            docker-compose build --no-cache
            docker-compose up -d
            Write-Status "Application updated and restarted"
        } else {
            # Update Python packages
            pip install -r requirements.txt --upgrade
            Write-Status "Dependencies updated"
        }
    }
    
    "clean" {
        Write-Status "Cleaning up old files..."
        
        # Clean old backups (keep last 7)
        if (Test-Path "backups") {
            Get-ChildItem "backups" -File | Sort-Object CreationTime -Descending | Select-Object -Skip 7 | Remove-Item
            Write-Status "Old backups cleaned"
        }
        
        # Clean temp files
        Get-ChildItem "." -Name "*.tmp", "*.log", "*.pyc" -Recurse | Remove-Item -Force
        
        # Docker cleanup
        if (Test-Path "docker-compose.yml") {
            docker system prune -f
            Write-Status "Docker cleanup completed"
        }
    }
    
    "status" {
        Write-Status "System Status:"
        Write-Host ""
        
        if (Test-Path "docker-compose.yml") {
            Write-Host "🐳 Docker Services:" -ForegroundColor Cyan
            docker-compose ps
            
            Write-Host "`n📊 Resource Usage:" -ForegroundColor Cyan
            docker stats --no-stream
        } else {
            Write-Host "💻 Development Mode" -ForegroundColor Cyan
            if (Get-Process python -ErrorAction SilentlyContinue) {
                Write-Host "✅ Flask application is running" -ForegroundColor Green
            } else {
                Write-Host "❌ Flask application is not running" -ForegroundColor Red
            }
        }
        
        Write-Host "`n💾 Database:" -ForegroundColor Cyan
        if (Test-Path "instance\farm.db") {
            $size = (Get-Item "instance\farm.db").Length / 1KB
            Write-Host "SQLite database size: $([math]::Round($size, 2)) KB"
        }
        
        Write-Host "`n📁 Upload Directory:" -ForegroundColor Cyan
        if (Test-Path "static\uploads") {
            $uploadSize = (Get-ChildItem "static\uploads" -Recurse -File | Measure-Object Length -Sum).Sum / 1MB
            Write-Host "Upload directory size: $([math]::Round($uploadSize, 2)) MB"
        }
    }
    
    "reset-admin" {
        Write-Status "Resetting admin password..."
        
        $newPassword = Read-Host "Enter new admin password" -AsSecureString
        $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($newPassword))
        
        if (Test-Path "docker-compose.yml") {
            docker-compose exec web python -c "
from app import app, db, User
import bcrypt
with app.app_context():
    admin = User.query.filter_by(username='admin').first()
    if admin:
        hashed_password = bcrypt.hashpw('$plainPassword'.encode('utf-8'), bcrypt.gensalt())
        admin.password_hash = hashed_password.decode('utf-8')
        db.session.commit()
        print('Admin password updated successfully!')
    else:
        print('Admin user not found!')
"
        } else {
            # For development mode
            python -c "
from app import app, db, User
import bcrypt
with app.app_context():
    admin = User.query.filter_by(username='admin').first()
    if admin:
        hashed_password = bcrypt.hashpw('$plainPassword'.encode('utf-8'), bcrypt.gensalt())
        admin.password_hash = hashed_password.decode('utf-8')
        db.session.commit()
        print('Admin password updated successfully!')
    else:
        print('Admin user not found!')
"
        }
        
        Write-Status "Admin password has been reset"
    }
}

Write-Host "`nMaintenance task completed!" -ForegroundColor Green
