import os
from datetime import datetime
from flask import Flask, render_template, request, redirect, url_for, flash, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user, current_user
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY')
if not app.config['SECRET_KEY']:
    raise ValueError("SECRET_KEY environment variable must be set in production")

app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL', 'sqlite:///farm.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['UPLOAD_FOLDER'] = os.path.join(app.root_path, 'static', 'uploads')
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size

# Production security settings
app.config['SESSION_COOKIE_SECURE'] = os.environ.get('FLASK_ENV') == 'production'
app.config['SESSION_COOKIE_HTTPONLY'] = True
app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'
app.config['PERMANENT_SESSION_LIFETIME'] = 3600  # 1 hour

# Ensure upload directory exists
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
os.makedirs(os.path.join(app.config['UPLOAD_FOLDER'], 'blog'), exist_ok=True)
os.makedirs(os.path.join(app.config['UPLOAD_FOLDER'], 'gallery'), exist_ok=True)

db = SQLAlchemy(app)
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'admin_login'

# Database Models
class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

class BlogPost(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    content = db.Column(db.Text, nullable=False)
    image_url = db.Column(db.String(255))
    author_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    published = db.Column(db.Boolean, default=False)
    
    author = db.relationship('User', backref=db.backref('posts', lazy=True))

class ProductRequest(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    customer_name = db.Column(db.String(100), nullable=False)
    customer_email = db.Column(db.String(100), nullable=False)
    customer_phone = db.Column(db.String(20))
    product_category = db.Column(db.String(50), nullable=False)
    message = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    status = db.Column(db.String(20), default='pending')

class ContactMessage(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(100), nullable=False)
    phone = db.Column(db.String(20))
    subject = db.Column(db.String(200), nullable=False)
    message = db.Column(db.Text, nullable=False)
    product_interest = db.Column(db.String(50))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    read = db.Column(db.Boolean, default=False)

class GalleryImage(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    filename = db.Column(db.String(255), nullable=False)
    caption = db.Column(db.String(200))
    category = db.Column(db.String(50))
    uploaded_at = db.Column(db.DateTime, default=datetime.utcnow)

class Product(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    category = db.Column(db.String(50), nullable=False)
    price = db.Column(db.String(20))
    description = db.Column(db.Text)
    image_url = db.Column(db.String(255))
    available = db.Column(db.Boolean, default=True)
    
    recipes = db.relationship('Recipe', backref='product', lazy=True)

class Recipe(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    ingredients = db.Column(db.Text, nullable=False)
    instructions = db.Column(db.Text, nullable=False)
    image_url = db.Column(db.String(255))
    product_id = db.Column(db.Integer, db.ForeignKey('product.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

@login_manager.user_loader
def load_user(user_id):
    return db.session.get(User, int(user_id))

# Routes
@app.route('/')
def home():
    latest_posts = BlogPost.query.filter_by(published=True).order_by(BlogPost.created_at.desc()).limit(3).all()
    return render_template('home.html', posts=latest_posts)

@app.route('/about')
def about():
    return render_template('about.html')

@app.route('/products')
def products():
    categories = ['Strawberries', 'Asparagus', 'Garlic', 'Fruits', 'Spices']
    return render_template('products.html', categories=categories)

@app.route('/products/<category>')
def product_category(category):
    products = Product.query.filter_by(category=category, available=True).all()
    recipes = Recipe.query.join(Product).filter(Product.category == category).all()
    return render_template('product_category.html', category=category, products=products, recipes=recipes)

@app.route('/blog')
def blog():
    page = request.args.get('page', 1, type=int)
    posts = BlogPost.query.filter_by(published=True).order_by(BlogPost.created_at.desc()).paginate(
        page=page, per_page=10, error_out=False)
    return render_template('blog.html', posts=posts)

@app.route('/gallery')
def gallery():
    images = GalleryImage.query.order_by(GalleryImage.uploaded_at.desc()).all()
    return render_template('gallery.html', images=images)

@app.route('/contact', methods=['GET', 'POST'])
def contact():
    if request.method == 'POST':
        message = ContactMessage(
            name=request.form['name'],
            email=request.form['email'],
            phone=request.form.get('phone'),
            subject=request.form['subject'],
            message=request.form['message'],
            product_interest=request.form.get('product_interest')
        )
        db.session.add(message)
        db.session.commit()
        flash('Thank you for your message! We\'ll get back to you soon.', 'success')
        return redirect(url_for('contact'))
    
    return render_template('contact.html')

@app.route('/product-request', methods=['POST'])
def product_request():
    if request.method == 'POST':
        req = ProductRequest(
            customer_name=request.form['name'],
            customer_email=request.form['email'],
            customer_phone=request.form.get('phone'),
            product_category=request.form['category'],
            message=request.form.get('message')
        )
        db.session.add(req)
        db.session.commit()
        return jsonify({'success': True, 'message': 'Request submitted successfully!'})
    
    return jsonify({'success': False, 'message': 'Invalid request'})

# Admin Routes
@app.route('/admin')
@login_required
def admin_dashboard():
    recent_requests = ProductRequest.query.order_by(ProductRequest.created_at.desc()).limit(5).all()
    recent_messages = ContactMessage.query.order_by(ContactMessage.created_at.desc()).limit(5).all()
    
    # Get all requests and messages for detailed breakdown
    all_requests = ProductRequest.query.all()
    all_messages = ContactMessage.query.all()
    
    post_count = BlogPost.query.count()
    
    # Calculate pending tasks
    pending_requests = ProductRequest.query.filter_by(status='pending').count()
    unread_messages = ContactMessage.query.filter_by(read=False).count()
    unpublished_posts = BlogPost.query.filter_by(published=False).count()
    
    # Create task breakdown
    task_breakdown = {
        'pending_requests': pending_requests,
        'unread_messages': unread_messages,
        'unpublished_posts': unpublished_posts,
        'total': pending_requests + unread_messages + unpublished_posts
    }
    
    return render_template('admin/dashboard.html', 
                         requests=all_requests, 
                         recent_requests=recent_requests,
                         messages=all_messages,
                         recent_messages=recent_messages,
                         post_count=post_count,
                         task_breakdown=task_breakdown)

@app.route('/admin/login', methods=['GET', 'POST'])
def admin_login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        user = User.query.filter_by(username=username).first()
        
        if user and user.check_password(password):
            login_user(user)
            return redirect(url_for('admin_dashboard'))
        else:
            flash('Invalid username or password', 'error')
    
    return render_template('admin/login.html')

@app.route('/admin/logout')
@login_required
def admin_logout():
    logout_user()
    return redirect(url_for('home'))

@app.route('/admin/blog')
@login_required
def admin_blog():
    posts = BlogPost.query.order_by(BlogPost.created_at.desc()).all()
    return render_template('admin/blog.html', posts=posts)

@app.route('/admin/blog/new', methods=['GET', 'POST'])
@login_required
def admin_blog_new():
    if request.method == 'POST':
        post = BlogPost(
            title=request.form['title'],
            content=request.form['content'],
            author_id=current_user.id,
            published=request.form.get('published') == 'on'
        )
        
        # Handle image upload
        if 'image' in request.files and request.files['image'].filename:
            file = request.files['image']
            if file:
                filename = secure_filename(file.filename)
                file.save(os.path.join(app.config['UPLOAD_FOLDER'], 'blog', filename))
                post.image_url = f'/static/uploads/blog/{filename}'
        
        db.session.add(post)
        db.session.commit()
        flash('Blog post created successfully!', 'success')
        return redirect(url_for('admin_blog'))
    
    return render_template('admin/blog_form.html')

@app.route('/admin/blog/<int:post_id>/delete', methods=['DELETE'])
@login_required
def admin_blog_delete(post_id):
    try:
        # Find the blog post to delete
        blog_post = db.get_or_404(BlogPost, post_id)
        
        # Delete the blog post
        db.session.delete(blog_post)
        db.session.commit()
        
        return jsonify({'success': True, 'message': 'Blog post deleted successfully'})
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': 'Failed to delete blog post'}), 500

@app.route('/admin/requests')
@login_required
def admin_requests():
    requests = ProductRequest.query.order_by(ProductRequest.created_at.desc()).all()
    return render_template('admin/requests.html', requests=requests)

@app.route('/admin/requests/<int:request_id>/delete', methods=['DELETE'])
@login_required
def admin_requests_delete(request_id):
    try:
        # Find the request to delete
        product_request = db.get_or_404(ProductRequest, request_id)
        
        # Delete the request
        db.session.delete(product_request)
        db.session.commit()
        
        return jsonify({'success': True, 'message': 'Request deleted successfully'})
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': 'Failed to delete request'}), 500

@app.route('/admin/messages')
@login_required
def admin_messages():
    messages = ContactMessage.query.order_by(ContactMessage.created_at.desc()).all()
    return render_template('admin/messages.html', messages=messages)

@app.route('/admin/messages/<int:message_id>/delete', methods=['DELETE'])
@login_required
def admin_messages_delete(message_id):
    try:
        # Find the message to delete
        contact_message = db.get_or_404(ContactMessage, message_id)
        
        # Delete the message
        db.session.delete(contact_message)
        db.session.commit()
        
        return jsonify({'success': True, 'message': 'Message deleted successfully'})
    except Exception as e:
        db.session.rollback()
        return jsonify({'success': False, 'message': 'Failed to delete message'}), 500
        return jsonify({'success': False, 'message': 'Failed to delete message'}), 500

@app.route('/admin/api/pending-tasks')
@login_required
def admin_api_pending_tasks():
    """API endpoint to get current pending tasks count"""
    try:
        # Calculate pending tasks
        pending_requests = ProductRequest.query.filter_by(status='pending').count()
        unread_messages = ContactMessage.query.filter_by(read=False).count()
        unpublished_posts = BlogPost.query.filter_by(published=False).count()
        
        # Create task breakdown
        task_breakdown = {
            'pending_requests': pending_requests,
            'unread_messages': unread_messages,
            'unpublished_posts': unpublished_posts,
            'total': pending_requests + unread_messages + unpublished_posts
        }
        
        return jsonify({
            'success': True,
            **task_breakdown
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/health')
def health_check():
    """Health check endpoint for monitoring and load balancers"""
    try:
        # Test database connection
        db.session.execute('SELECT 1')
        return jsonify({
            'status': 'healthy',
            'timestamp': datetime.utcnow().isoformat(),
            'database': 'connected'
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'unhealthy', 
            'timestamp': datetime.utcnow().isoformat(),
            'error': str(e)
        }), 503

def create_admin_user():
    """Create default admin user if none exists"""
    if not User.query.first():
        admin = User(
            username='admin',
            email='admin@elliottacres.com'
        )
        admin.set_password('admin123')  # Change this in production
        db.session.add(admin)
        db.session.commit()
        print("Admin user created - username: admin, password: admin123")

def init_sample_data():
    """Initialize sample data for development"""
    # Sample products
    products_data = [
        {'name': 'Fresh Strawberries', 'category': 'Strawberries', 'price': '$6.00/lb', 'description': 'Sweet, juicy strawberries picked fresh daily'},
        {'name': 'Strawberry Jam', 'category': 'Strawberries', 'price': '$8.50', 'description': 'Homemade strawberry jam made from our farm-fresh berries'},
        {'name': 'Frozen Strawberries', 'category': 'Strawberries', 'price': '$5.00/lb', 'description': 'Flash-frozen strawberries perfect for smoothies'},
        {'name': 'Fresh Asparagus', 'category': 'Asparagus', 'price': '$4.50/lb', 'description': 'Tender asparagus spears harvested at peak freshness'},
        {'name': 'Pickled Asparagus', 'category': 'Asparagus', 'price': '$7.25', 'description': 'Crispy pickled asparagus with herbs and spices'},
        {'name': 'Fresh Garlic Bulbs', 'category': 'Garlic', 'price': '$12.00/lb', 'description': 'Aromatic hardneck garlic bulbs'},
        {'name': 'Garlic Powder', 'category': 'Garlic', 'price': '$5.00', 'description': 'Fine ground garlic powder from our farm-grown garlic'},
        {'name': 'Garlic Scapes', 'category': 'Garlic', 'price': '$3.50/bunch', 'description': 'Tender garlic scapes perfect for stir-fries'},
    ]
    
    for product_data in products_data:
        if not Product.query.filter_by(name=product_data['name']).first():
            product = Product(**product_data)
            db.session.add(product)
    
    # Sample recipes
    recipes_data = [
        {
            'title': 'Strawberry Shortcake',
            'ingredients': 'Fresh strawberries, Biscuits, Whipped cream, Sugar',
            'instructions': '1. Slice strawberries and mix with sugar. 2. Split biscuits in half. 3. Layer with strawberries and whipped cream.',
            'product_id': 1
        },
        {
            'title': 'Roasted Asparagus',
            'ingredients': 'Fresh asparagus, Olive oil, Salt, Pepper, Garlic',
            'instructions': '1. Preheat oven to 400°F. 2. Toss asparagus with oil and seasonings. 3. Roast for 15-20 minutes.',
            'product_id': 4
        },
        {
            'title': 'Garlic Butter',
            'ingredients': 'Fresh garlic, Butter, Salt, Herbs',
            'instructions': '1. Mince garlic finely. 2. Mix with softened butter. 3. Add salt and herbs to taste.',
            'product_id': 6        }
    ]
    
    for recipe_data in recipes_data:
        if not Recipe.query.filter_by(title=recipe_data['title']).first():
            recipe = Recipe(**recipe_data)
            db.session.add(recipe)
    
    # Sample product requests for testing
    if not ProductRequest.query.first():
        sample_requests = [
            {
                'customer_name': 'John Smith',
                'customer_email': 'john.smith@email.com',
                'customer_phone': '(555) 123-4567',
                'product_category': 'Strawberries',
                'message': 'Interested in bulk strawberries for a wedding event. Need about 20 lbs.',
                'status': 'pending'
            },
            {
                'customer_name': 'Sarah Johnson',
                'customer_email': 'sarah.j@email.com',
                'customer_phone': '(555) 987-6543',
                'product_category': 'Asparagus',
                'message': 'Looking for fresh asparagus for my restaurant. Can you supply weekly?',
                'status': 'contacted'
            },
            {
                'customer_name': 'Mike Wilson',
                'customer_email': 'mwilson@email.com',
                'product_category': 'Garlic',
                'message': 'Need garlic scapes for farmers market. When will they be available?',
                'status': 'pending'
            },
            {
                'customer_name': 'Lisa Brown',
                'customer_email': 'lisa.brown@email.com',
                'customer_phone': '(555) 456-7890',
                'product_category': 'Fruits',
                'message': 'Do you have any seasonal fruits available? Looking for variety pack.',
                'status': 'completed'
            }
        ]
        
        for request_data in sample_requests:
            request = ProductRequest(**request_data)
            db.session.add(request)
    
    db.session.commit()

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
        create_admin_user()
        init_sample_data()
    
    app.run(debug=True, host='0.0.0.0', port=5000)
