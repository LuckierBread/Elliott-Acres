# Elliott Acres Farm Website

A static website for Elliott Acres Farm showcasing fresh, locally grown produce.

## 🌱 About

This is the official website for Elliott Acres Farm, featuring information about our sustainable farming practices, products, and the farmers behind the operation.

## 🚀 Deployment on GitHub Pages

This site is designed to run on GitHub Pages as a static website.

### Setup Instructions

1. **Enable GitHub Pages**:
   - Go to your repository settings
   - Navigate to "Pages" in the left sidebar
   - Under "Source", select the branch you want to deploy (usually `main` or `gh-pages`)
   - Select "/ (root)" as the folder
   - Click "Save"

2. **Access Your Site**:
   - Your site will be available at: `https://yourusername.github.io/Elliott-Acres/`
   - Or with a custom domain if configured

3. **Custom Domain (Optional)**:
   - Add a CNAME file with your custom domain
   - Configure DNS settings with your domain provider
   - Enable HTTPS in repository settings

## 📁 Project Structure

```
Elliott-Acres/
├── index.html          # Home page
├── about.html          # About us page
├── products.html       # Products page
├── blog.html           # Blog page
├── gallery.html        # Photo gallery
├── contact.html        # Contact page
├── static/
│   ├── css/           # Stylesheets
│   ├── js/            # JavaScript files
│   └── images/        # Image assets
└── README.md          # This file
```

## 🛠️ Technologies Used

- **HTML5** - Structure and content
- **CSS3** - Styling (via Bootstrap 5 and custom CSS)
- **JavaScript** - Interactivity and animations
- **Bootstrap 5.3** - Responsive framework
- **Font Awesome 6** - Icons

## ✨ Features

- **Responsive Design**: Works on all devices (mobile, tablet, desktop)
- **Product Showcase**: Detailed information about farm products
- **Photo Gallery**: Visual journey through the farm
- **Contact Form**: Integrated with Formspree for contact submissions
- **SEO Optimized**: Meta tags and semantic HTML
- **Fast Loading**: Optimized images and minimal dependencies

## 📧 Contact Form Setup

The contact form uses Formspree. To set it up:

1. Go to [formspree.io](https://formspree.io)
2. Create a free account
3. Create a new form
4. Replace `your-form-id` in `contact.html` and `blog.html` with your actual Formspree form ID:
   ```html
   <form action="https://formspree.io/f/YOUR-FORM-ID" method="POST">
   ```

## 🎨 Customization

### Updating Content

- **Home Page**: Edit `index.html`
- **About Page**: Edit `about.html`
- **Products**: Edit `products.html`
- **Contact Info**: Update contact information in all HTML files (footer section)

### Styling

- Custom styles are in `static/css/style.css`
- Bootstrap variables can be overridden in the custom CSS file

### Images

- Replace images in `static/images/` with your own
- Keep the same filenames or update references in HTML files

## 📱 Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)
- Mobile browsers

## 🐛 Troubleshooting

### Images Not Loading

- Ensure all image paths use relative paths (e.g., `static/images/photo.jpg`)
- Check that images exist in the `static/images/` directory
- Verify file names match exactly (case-sensitive)

### Contact Form Not Working

- Verify Formspree form ID is correct
- Check that the form action URL is properly formatted
- Test form submission on the live site (forms may not work locally)

## 📝 License

This website is proprietary to Elliott Acres Farm.

## 🤝 Contributing

This is a private farm website. For questions or updates, please contact the farm directly.

---

**Elliott Acres Farm**  
Fresh. Local. Sustainable.  
📍 123 Farm Road, Rural Valley  
📞 (555) 123-4567  
📧 hello@elliottacres.com
