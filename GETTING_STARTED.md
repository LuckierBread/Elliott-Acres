# 🌾 Elliott Acres Farm - Getting Started Guide

Welcome to your new farm website! This guide will help you get started with managing your Elliott Acres Farm website.

## 🚀 First Steps

### 1. Access Your Website

Your website is now running and accessible at:

- **Main Website**: http://localhost:5000
- **Admin Portal**: http://localhost:5000/admin

### 2. Admin Login

Use these default credentials to access the admin portal:

- **Username**: `admin`
- **Password**: `admin123`

⚠️ **Important**: Change these credentials immediately after your first login!

### 3. Change Admin Password

1. Go to the admin portal
2. Log in with the default credentials
3. Use the maintenance script to change password:
   ```powershell
   .\maintenance.ps1 -Task reset-admin
   ```

## 📝 Content Management

### Adding Blog Posts

1. Navigate to Admin > Blog Management
2. Click "New Post"
3. Fill in the title, content, and upload images
4. Save and publish

### Managing Products

Products are pre-configured with these categories:

- 🍓 Strawberries
- 🌿 Asparagus
- 🧄 Garlic
- 🍎 Seasonal Fruits
- 🌶️ Farm Spices

### Photo Gallery

1. Go to Admin > Gallery
2. Upload high-quality farm photos
3. Add descriptions and organize by categories

### Handling Customer Messages

- Check the Messages section regularly
- Respond to customer inquiries
- Review product requests for demand insights

## 🎨 Customizing Your Website

### Updating Farm Information

Edit these files to customize your content:

- `templates/about.html` - Your farm story
- `templates/home.html` - Homepage content
- `static/css/style.css` - Colors and styling

### Adding Your Logo

1. Replace placeholder images in `static/images/`
2. Update the logo reference in `templates/base.html`

### Farm Photos

Replace the placeholder images with:

- Hero images (1200x600 pixels)
- Product photos (800x600 pixels)
- Gallery photos (various sizes)

## 📱 Mobile Optimization

Your website is fully responsive and works on:

- 📱 Mobile phones
- 📱 Tablets
- 💻 Desktop computers

## 🔒 Security Best Practices

### Essential Security Steps

1. **Change default passwords immediately**
2. **Keep software updated**
3. **Regular backups**
4. **Monitor access logs**

### Regular Maintenance

Run these commands weekly:

```powershell
# Create backup
.\maintenance.ps1 -Task backup

# Check system status
.\maintenance.ps1 -Task status

# Clean old files
.\maintenance.ps1 -Task clean
```

## 📊 Understanding Your Dashboard

### Admin Dashboard Overview

- **📝 Recent Posts**: Latest blog entries
- **💬 Messages**: Customer inquiries
- **📋 Requests**: Product interest
- **📸 Gallery**: Photo management

### Key Metrics to Monitor

- Customer message volume
- Product request trends
- Blog post engagement
- Gallery photo views

## 🌐 Going Live (Production)

### For Production Deployment

1. **Get a domain name** (e.g., elliottacres.com)
2. **Set up hosting** (VPS or cloud provider)
3. **Configure SSL certificate** for HTTPS
4. **Update .env.production** with real credentials
5. **Deploy using Docker**:
   ```powershell
   .\deploy.ps1 -Production
   ```

### Recommended Hosting Providers

- **DigitalOcean** - Simple cloud hosting
- **AWS** - Scalable cloud platform
- **Linode** - Developer-friendly hosting
- **Vultr** - Fast SSD cloud servers

## 📞 Getting Help

### Common Issues

**Q: I forgot my admin password**
A: Run `.\maintenance.ps1 -Task reset-admin`

**Q: Website is slow**
A: Check system status with `.\maintenance.ps1 -Task status`

**Q: Images not uploading**
A: Check the `static/uploads/` directory permissions

**Q: Database errors**
A: Restart services with `.\maintenance.ps1 -Task restart`

### Support Resources

- Check the README.md for detailed documentation
- Review error logs with `.\maintenance.ps1 -Task logs`
- Create backups before making changes

## 🎯 Next Steps

### Week 1

- [ ] Change admin password
- [ ] Upload your farm photos
- [ ] Write your first blog post
- [ ] Update the About page with your story

### Week 2

- [ ] Add product photos and descriptions
- [ ] Set up regular backup schedule
- [ ] Test contact forms
- [ ] Plan your content calendar

### Month 1

- [ ] Add seasonal recipes
- [ ] Optimize for search engines
- [ ] Set up social media links
- [ ] Plan production deployment

## 🌟 Success Tips

### Content Strategy

- **Post regularly** - Weekly blog updates
- **Seasonal content** - Harvest updates, recipes
- **Customer stories** - Testimonials and photos
- **Behind the scenes** - Farm life and processes

### Engagement

- **Respond quickly** to customer messages
- **Share recipes** using your produce
- **Post harvest updates** during season
- **Showcase farm events** and activities

---

**Happy farming! 🌾** Your Elliott Acres website is ready to help you connect with customers and grow your business.
