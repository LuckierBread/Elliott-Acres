# Elliott Acres - Cloudflare Workers Deployment Guide

## Prerequisites

1. Install Wrangler CLI:
   ```bash
   npm install -g wrangler
   ```

2. Login to Cloudflare:
   ```bash
   wrangler login
   ```

## Setup Steps

### 1. Create D1 Database

```bash
wrangler d1 create elliott-acres-db
```

Copy the database ID and update it in `wrangler.toml`:
```toml
[[d1_databases]]
binding = "DB"
database_name = "elliott-acres-db"
database_id = "your-database-id-here"
```

### 2. Create R2 Bucket for File Uploads

```bash
wrangler r2 bucket create elliott-acres-uploads
```

### 3. Apply Database Schema

```bash
wrangler d1 execute elliott-acres-db --file=schema.sql
```

### 4. Set Environment Variables

```bash
wrangler secret put SECRET_KEY
# Enter a secure 32+ character secret key

wrangler secret put ADMIN_PASSWORD
# Enter a secure admin password
```

### 5. Deploy to Workers

```bash
wrangler deploy
```

## Environment Configuration

The app automatically detects the environment:

- **Local Development**: Uses SQLite database and local file storage
- **Cloudflare Workers**: Uses D1 database and R2 storage
- **Production (External)**: Uses external PostgreSQL database

## Environment Variables

### Required for Workers:
- `SECRET_KEY`: Flask secret key (32+ characters)
- `ADMIN_PASSWORD`: Admin user password

### Optional:
- `FLASK_ENV`: Set to "production" for production builds
- `CF_WORKER`: Automatically set to "1" in Workers environment

## File Structure

```
elliott-acres/
├── src/
│   └── worker.py          # Workers entry point
├── templates/             # Flask templates
├── static/               # Static assets
├── app.py                # Main Flask application
├── schema.sql            # D1 database schema
├── wrangler.toml         # Workers configuration
└── requirements.txt      # Python dependencies
```

## Development vs Production

### Local Development:
```bash
python app.py
```

### Workers Development:
```bash
wrangler dev
```

### Workers Production:
```bash
wrangler deploy
```

## Database Access

### Local Development:
- Uses SQLite (`sqlite:///farm.db`)
- Full SQLAlchemy ORM support
- Automatic sample data generation

### Cloudflare Workers:
- Uses D1 database via binding
- Raw SQL queries (no ORM)
- Manual data management required

## File Uploads

### Local Development:
- Files saved to `static/uploads/`
- Direct file system access

### Cloudflare Workers:
- Files uploaded to R2 bucket
- CDN distribution available

## Admin Access

### Default Credentials:
- Username: `admin`
- Password: Set via `ADMIN_PASSWORD` secret or defaults to `admin123`

### Admin Routes:
- `/admin/login` - Admin login
- `/admin` - Dashboard
- `/admin/blog` - Blog management
- `/admin/requests` - Product requests
- `/admin/messages` - Contact messages

## Monitoring

### Health Check:
- Endpoint: `/health`
- Returns environment and database status

### Logs:
```bash
wrangler tail
```

## Troubleshooting

### Common Issues:

1. **D1 Database not found**:
   - Verify database ID in `wrangler.toml`
   - Ensure database was created successfully

2. **Secret not found**:
   - Set secrets using `wrangler secret put`
   - Verify secret names match app expectations

3. **Import errors**:
   - Ensure all files are in correct locations
   - Check Python path in `worker.py`

4. **Template not found**:
   - Verify templates are included in deployment
   - Check Flask template directory configuration

### Development Testing:

1. **Test locally first**:
   ```bash
   python app.py
   ```

2. **Test Workers locally**:
   ```bash
   wrangler dev
   ```

3. **Deploy to production**:
   ```bash
   wrangler deploy
   ```

## Migration Notes

The app is designed to work in both traditional Flask environments and Cloudflare Workers:

- Database operations are conditionally executed based on environment
- File uploads use different storage backends
- Session configuration adapts to environment security requirements
- Admin features work in both environments (with some limitations in Workers)

For full functionality, complete the TODO items in the code for D1 database operations.
