# GitHub Pages Setup Guide for Elliott Acres

This guide will help you deploy the Elliott Acres website to GitHub Pages.

## Quick Start

### Option 1: Manual Deployment (Recommended for first-time setup)

1. **Push your code to GitHub** (if not already done):
   ```bash
   git add .
   git commit -m "Prepare for GitHub Pages deployment"
   git push origin main
   ```

2. **Enable GitHub Pages**:
   - Go to your repository on GitHub
   - Click on "Settings" tab
   - Scroll down to "Pages" in the left sidebar
   - Under "Source":
     - Select branch: `main` (or your default branch)
     - Select folder: `/ (root)`
   - Click "Save"

3. **Wait for deployment**:
   - GitHub will build and deploy your site
   - This usually takes 1-3 minutes
   - Your site will be available at: `https://yourusername.github.io/Elliott-Acres/`

### Option 2: Automatic Deployment with GitHub Actions

The repository includes a GitHub Actions workflow that can automatically deploy your site.

1. **Enable GitHub Pages (same as Option 1, steps 2-3)**

2. **Enable GitHub Actions** (if not already enabled):
   - Go to "Settings" > "Actions" > "General"
   - Enable "Allow all actions and reusable workflows"

3. **Trigger deployment**:
   - Any push to `main` branch will automatically deploy
   - Or manually trigger from "Actions" tab > "Deploy to GitHub Pages" > "Run workflow"

## Customization

### Contact Form Setup

The contact forms use Formspree. To enable them:

1. Sign up at [https://formspree.io](https://formspree.io)
2. Create a new form
3. Copy your form ID
4. Update these files:
   - `contact.html`: Line ~33
   - `blog.html`: Line ~35
   
   Replace `your-form-id` with your actual form ID:
   ```html
   <form action="https://formspree.io/f/YOUR-FORM-ID" method="POST">
   ```

### Update Contact Information

Update the following in all HTML files (footer section):

- **Address**: 123 Farm Road, Rural Valley
- **Phone**: (555) 123-4567
- **Email**: hello@elliottacres.com

Search and replace these values in:
- `index.html`
- `about.html`
- `products.html`
- `blog.html`
- `gallery.html`
- `contact.html`

### Replace Images

1. Add your images to `static/images/`
2. Keep the same filenames, or
3. Update references in HTML files

Required images:
- `barn.jpg` - Farm barn photo
- `farmers.jpg` - Photo of farmers
- `Strawberries photo 1.png` - Strawberry photo
- `asparagus.jpg` - Asparagus photo
- `garlic.jpg` - Garlic photo
- `apples.jpg` - Fruits photo
- `spices.jpg` - Spices photo
- `dog.jpg` - Farm dog photo
- `horse.jpg` - Horses photo
- `chickens.jpg` - Chickens photo
- `fresh harvest.jpg` - Harvest photo
- `house.jpg` - Farm house (optional)

### Custom Domain (Optional)

1. **Add CNAME file**:
   ```bash
   echo "www.elliottacres.com" > CNAME
   git add CNAME
   git commit -m "Add custom domain"
   git push
   ```

2. **Configure DNS** with your domain provider:
   - Add a CNAME record pointing to: `yourusername.github.io`
   - Or add A records pointing to GitHub's IPs:
     - `185.199.108.153`
     - `185.199.109.153`
     - `185.199.110.153`
     - `185.199.111.153`

3. **Update GitHub Settings**:
   - Go to Settings > Pages
   - Enter your custom domain
   - Enable "Enforce HTTPS" (recommended)

## Testing Locally

To test the site on your local machine:

```bash
# Using Python (Python 3)
python3 -m http.server 8000

# Using Python (Python 2)
python -m SimpleHTTPServer 8000

# Using Node.js
npx http-server

# Then open: http://localhost:8000
```

## Troubleshooting

### Site not loading after deployment

1. Check GitHub Actions logs for errors
2. Verify Pages is enabled in Settings
3. Ensure branch and folder are correctly selected
4. Wait 5-10 minutes for DNS propagation

### Images not displaying

1. Check image paths are relative: `static/images/photo.jpg`
2. Verify images exist in repository
3. Check file names match exactly (case-sensitive)
4. Clear browser cache

### Contact form not working

1. Verify Formspree form ID is correct
2. Test on the live site (forms won't work with `file://` protocol)
3. Check browser console for errors

### CSS/JS not loading

1. Verify paths in HTML files
2. Check .nojekyll file exists in root
3. Clear browser cache
4. Check browser console for 404 errors

## Site Structure

```
Elliott-Acres/
├── index.html              # Home page
├── about.html              # About the farm
├── products.html           # Products catalog
├── blog.html               # Blog (placeholder)
├── gallery.html            # Photo gallery
├── contact.html            # Contact form
├── static/
│   ├── css/
│   │   └── style.css      # Custom styles
│   ├── js/
│   │   └── main.js        # Custom JavaScript
│   └── images/            # All images
├── .nojekyll              # Disable Jekyll processing
├── README.md              # Main readme
└── GITHUB_PAGES_SETUP.md  # This file
```

## Performance Optimization

The site is already optimized for GitHub Pages:
- ✅ Static HTML (no server-side processing needed)
- ✅ CDN-hosted libraries (Bootstrap, Font Awesome)
- ✅ Minimal custom JavaScript
- ✅ Responsive images

### Further optimization:

1. **Optimize images**:
   ```bash
   # Use tools like ImageOptim, TinyPNG, or:
   npm install -g imagemin-cli
   imagemin static/images/* --out-dir=static/images
   ```

2. **Enable caching** (done automatically by GitHub Pages)

3. **Use WebP format** for images (modern browsers)

## Support

For issues related to:
- **GitHub Pages**: [GitHub Pages Documentation](https://docs.github.com/en/pages)
- **Formspree**: [Formspree Help](https://help.formspree.io/)
- **General HTML/CSS**: [MDN Web Docs](https://developer.mozilla.org/)

## Next Steps

1. ✅ Deploy to GitHub Pages
2. ⬜ Set up Formspree for contact forms
3. ⬜ Replace placeholder images with real photos
4. ⬜ Update contact information
5. ⬜ Add actual blog posts (or remove blog page)
6. ⬜ Configure custom domain (optional)
7. ⬜ Add Google Analytics (optional)
8. ⬜ Set up social media links

---

**Happy deploying! 🚀**
