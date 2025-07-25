# 🌾 Elliott Acres Farm Website

A comprehensive small farm local produce website built with Flask, featuring a complete admin portal, product showcase, blog, gallery, and customer management system.

## 🚀 Features

### 🏠 Frontend Features

- **Responsive Design**: Mobile-first design with Bootstrap 5
- **Product Showcase**: Organized by categories (strawberries, asparagus, garlic, fruits, spices)
- **Interactive Gallery**: Masonry layout with lightbox functionality
- **Blog System**: Farm updates, recipes, and seasonal information
- **Contact Forms**: Customer inquiries and product requests
- **Recipe Cards**: Flip animations with ingredients and instructions
- **Modern UI**: Custom CSS with farm-themed color scheme and animations

### 🔧 Backend Features

- **Flask Application**: Robust Python web framework
- **SQLAlchemy ORM**: Database management with 7 models
- **User Authentication**: Secure admin login with bcrypt hashing
- **File Upload System**: Image management for blog and gallery
- **AJAX Integration**: Seamless form submissions
- **Database Support**: SQLite for development, PostgreSQL for production

### 👨‍💼 Admin Portal

- **Dashboard**: Overview of requests, messages, and content
- **Blog Management**: Create, edit, and publish blog posts
- **Message Center**: View and respond to customer inquiries
- **Product Requests**: Track customer interest in products
- **Gallery Management**: Upload and organize farm photos
- **User Management**: Admin user controls

### 🛠 Production Ready

- **Docker Deployment**: Complete containerization with docker-compose
- **Nginx Reverse Proxy**: Load balancing and static file serving
- **PostgreSQL Database**: Production-grade database support
- **Health Checks**: Monitoring and uptime verification
- **Backup System**: Automated database backups
- **Security Headers**: Production security configurations

## 📁 Project Structure

```
Elliott Acres/
├── app.py                      # Main Flask application
├── requirements.txt            # Python dependencies
├── docker-compose.yml          # Docker services configuration
├── Dockerfile                  # Application container
├── nginx.conf                  # Nginx configuration
├── deploy.ps1                  # Windows deployment script
├── deploy.sh                   # Linux deployment script
├── .env.production             # Production environment template
├── .gitignore                  # Git ignore rules
├── README.md                   # This file
├── templates/                  # Jinja2 templates
│   ├── base.html              # Base template
│   ├── home.html              # Homepage
│   ├── about.html             # About page
│   ├── products.html          # Products overview
│   ├── product_category.html  # Category-specific products
│   ├── blog.html              # Blog listing
│   ├── gallery.html           # Photo gallery
│   ├── contact.html           # Contact form
│   └── admin/                 # Admin templates
│       ├── base.html          # Admin base template
│       ├── login.html         # Admin login
│       ├── dashboard.html     # Admin dashboard
│       ├── blog.html          # Blog management
│       ├── blog_form.html     # Blog editor
│       ├── requests.html      # Product requests
│       └── messages.html      # Contact messages
├── static/                    # Static assets
│   ├── css/
│   │   └── style.css         # Custom styles
│   ├── js/
│   │   └── main.js           # JavaScript functionality
│   ├── images/               # Static images
│   └── uploads/              # User uploaded content
│       ├── blog/             # Blog images
│       └── gallery/          # Gallery images
└── instance/
    └── farm.db               # SQLite database (development)
```

## 🏗 Database Schema

### Models

1. **User**: Admin user management
2. **BlogPost**: Blog content and metadata
3. **ProductRequest**: Customer product inquiries
4. **ContactMessage**: General customer messages
5. **GalleryImage**: Photo gallery management
6. **Product**: Farm product catalog
7. **Recipe**: Recipe cards with ingredients and instructions

### Relationships

- Products have many recipes
- Blog posts belong to users
- Gallery images have metadata and categories

## 🚀 Quick Start

### Development Setup

1. **Clone and Setup**

   ```bash
   git clone <repository-url>
   cd "Elliott Acres"
   ```

2. **Create Virtual Environment**

   ```bash
   python -m venv venv
   venv\Scripts\Activate.ps1  # Windows
   # or
   source venv/bin/activate   # Linux/Mac
   ```

3. **Install Dependencies**

   ```bash
   pip install -r requirements.txt
   ```

4. **Run Development Server**

   ```bash
   python app.py
   ```

5. **Access Application**
   - Website: http://localhost:5000
   - Admin: http://localhost:5000/admin
   - Default login: admin/admin123

### Windows Deployment

```powershell
# Development
.\deploy.ps1 -Development

# Production
.\deploy.ps1 -Production
```

### Docker Deployment

1. **Setup Environment**

   ```bash
   cp .env.production .env
   # Edit .env with your production values
   ```

2. **Deploy with Docker**

   ```bash
   docker-compose up -d
   ```

3. **Access Services**
   - Website: http://localhost
   - Admin: http://localhost/admin
   - Database: localhost:5432

## 🔧 Configuration

### Environment Variables

```env
# Flask Configuration
FLASK_ENV=production
SECRET_KEY=your-secret-key
DEBUG=False

# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/elliott_acres

# File Uploads
MAX_CONTENT_LENGTH=16777216
UPLOAD_FOLDER=static/uploads

# Email (Optional)
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=True
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password
```

### Admin Access

Default admin credentials:

- Username: `admin`
- Password: `admin123`

**⚠️ Change these in production!**

## 📝 Content Management

### Adding Products

Products are managed through the database. Sample categories include:

- Strawberries
- Asparagus
- Garlic
- Seasonal Fruits
- Farm Spices

### Blog Management

- Create posts through admin panel
- Upload images for blog content
- Organize by categories and tags
- Schedule publishing dates

### Gallery Management

- Upload high-quality farm photos
- Organize by seasons or categories
- Automatic thumbnail generation
- Lightbox viewing experience

## 🔒 Security Features

- **Password Hashing**: bcrypt for secure password storage
- **Session Management**: Flask-Login for user sessions
- **CSRF Protection**: Flask-WTF for form security
- **File Upload Security**: Secure filename handling
- **SQL Injection Prevention**: SQLAlchemy ORM
- **XSS Protection**: Jinja2 template escaping

## 📊 Monitoring & Maintenance

### Health Checks

- Endpoint: `/health`
- Monitors database connectivity
- Returns JSON status response

### Backups

- Automated daily database backups
- Retention policy: 7 days
- PostgreSQL pg_dump format

### Logs

```bash
# View application logs
docker-compose logs -f web

# View nginx logs
docker-compose logs -f nginx

# View database logs
docker-compose logs -f db
```

## 🎨 Customization

### Styling

- Custom CSS in `static/css/style.css`
- Bootstrap 5 framework
- Farm-themed color palette
- Responsive breakpoints

### Templates

- Jinja2 templating engine
- Modular template structure
- Easy theme customization
- SEO-friendly markup

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

For questions or support:

- Email: admin@elliottacres.com
- Create an issue in the repository
- Check the documentation

## 📄 License

This project is licensed under the MIT License. See LICENSE file for details.

## 🙏 Acknowledgments

- Flask and its ecosystem
- Bootstrap for responsive design
- PostgreSQL for reliable data storage
- Docker for containerization
- The open-source community

---

**Built with ❤️ for Elliott Acres Farm** 🌾
