# Elliott Acres Farm - Automated Test Suite
import unittest
import tempfile
import os
import sys
from datetime import datetime

# Add the app directory to the path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import app, db, User, BlogPost, Product, Recipe, ContactMessage, ProductRequest, GalleryImage
import bcrypt

class ElliottAcresTestCase(unittest.TestCase):
    """Base test case for Elliott Acres Farm website"""
    
    def setUp(self):
        """Set up test fixtures before each test method"""
        self.db_fd, app.config['DATABASE'] = tempfile.mkstemp()
        app.config['TESTING'] = True
        app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
        app.config['WTF_CSRF_ENABLED'] = False
        
        self.app = app.test_client()
        
        with app.app_context():
            db.create_all()
            self.create_test_data()
    
    def tearDown(self):
        """Clean up after each test method"""
        with app.app_context():
            db.session.remove()
            db.drop_all()
        os.close(self.db_fd)        os.unlink(app.config['DATABASE'])
    
    def create_test_data(self):
        """Create test data for testing"""
        # Create admin user
        admin = User(
            username='testadmin',
            email='test@example.com'
        )
        admin.set_password('testpassword')
        db.session.add(admin)
        
        # Create test products
        products_data = [
            {'name': 'Test Strawberries', 'category': 'strawberries', 'description': 'Sweet test berries'},
            {'name': 'Test Asparagus', 'category': 'asparagus', 'description': 'Fresh test spears'},
            {'name': 'Test Garlic', 'category': 'garlic', 'description': 'Aromatic test bulbs'}
        ]
        
        for product_data in products_data:
            product = Product(**product_data)
            db.session.add(product)
        
        # Create test blog post
        blog_post = BlogPost(
            title='Test Blog Post',
            content='This is a test blog post content.',
            author_id=1,
            created_at=datetime.utcnow()
        )
        db.session.add(blog_post)
        
        # Create test recipe
        recipe = Recipe(
            title='Test Recipe',
            ingredients='Test ingredients',
            instructions='Test instructions',
            product_id=1
        )
        db.session.add(recipe)
        
        db.session.commit()

class TestHomepage(ElliottAcresTestCase):
    """Test homepage functionality"""
    
    def test_homepage_loads(self):
        """Test that homepage loads successfully"""
        response = self.app.get('/')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Elliott Acres Farm', response.data)
    
    def test_homepage_shows_products(self):
        """Test that homepage displays featured products"""
        response = self.app.get('/')
        self.assertIn(b'Our Fresh Produce', response.data)
    
    def test_homepage_shows_blog_posts(self):
        """Test that homepage displays recent blog posts"""
        response = self.app.get('/')
        self.assertIn(b'Test Blog Post', response.data)

class TestProductPages(ElliottAcresTestCase):
    """Test product-related pages"""
    
    def test_products_page_loads(self):
        """Test products page loads successfully"""
        response = self.app.get('/products')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Our Products', response.data)
    
    def test_product_category_page_loads(self):
        """Test product category pages load"""
        categories = ['strawberries', 'asparagus', 'garlic', 'fruits', 'spices']
        for category in categories:
            response = self.app.get(f'/products/{category}')
            self.assertEqual(response.status_code, 200)
    
    def test_product_request_submission(self):
        """Test product request form submission"""
        response = self.app.post('/api/product-request', data={
            'name': 'Test Customer',
            'email': 'customer@test.com',
            'phone': '123-456-7890',
            'product_id': 1,
            'message': 'Test request message'
        })
        self.assertEqual(response.status_code, 200)
        
        # Verify request was saved
        with app.app_context():
            request = ProductRequest.query.first()
            self.assertIsNotNone(request)
            self.assertEqual(request.name, 'Test Customer')

class TestBlogPages(ElliottAcresTestCase):
    """Test blog functionality"""
    
    def test_blog_page_loads(self):
        """Test blog page loads successfully"""
        response = self.app.get('/blog')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Farm Blog', response.data)
    
    def test_blog_shows_posts(self):
        """Test blog page displays posts"""
        response = self.app.get('/blog')
        self.assertIn(b'Test Blog Post', response.data)

class TestContactFunctionality(ElliottAcresTestCase):
    """Test contact form functionality"""
    
    def test_contact_page_loads(self):
        """Test contact page loads successfully"""
        response = self.app.get('/contact')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Contact Us', response.data)
    
    def test_contact_form_submission(self):
        """Test contact form submission"""
        response = self.app.post('/contact', data={
            'name': 'Test Contact',
            'email': 'contact@test.com',
            'subject': 'Test Subject',
            'message': 'Test contact message'
        })
        
        # Should redirect after successful submission
        self.assertEqual(response.status_code, 302)
        
        # Verify message was saved
        with app.app_context():
            message = ContactMessage.query.first()
            self.assertIsNotNone(message)
            self.assertEqual(message.name, 'Test Contact')

class TestAdminAuthentication(ElliottAcresTestCase):
    """Test admin authentication"""
    
    def test_admin_login_page_loads(self):
        """Test admin login page loads"""
        response = self.app.get('/admin/login')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Admin Login', response.data)
    
    def test_admin_login_success(self):
        """Test successful admin login"""
        response = self.app.post('/admin/login', data={
            'username': 'testadmin',
            'password': 'testpassword'
        }, follow_redirects=True)
        
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Admin Dashboard', response.data)
    
    def test_admin_login_failure(self):
        """Test failed admin login"""
        response = self.app.post('/admin/login', data={
            'username': 'testadmin',
            'password': 'wrongpassword'
        })
        
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Invalid username or password', response.data)
    
    def test_admin_dashboard_requires_login(self):
        """Test admin dashboard requires authentication"""
        response = self.app.get('/admin/')
        self.assertEqual(response.status_code, 302)  # Redirect to login

class TestAdminFunctionality(ElliottAcresTestCase):
    """Test admin panel functionality"""
    
    def login_admin(self):
        """Helper method to login as admin"""
        return self.app.post('/admin/login', data={
            'username': 'testadmin',
            'password': 'testpassword'
        }, follow_redirects=True)
    
    def test_admin_dashboard_loads(self):
        """Test admin dashboard loads after login"""
        self.login_admin()
        response = self.app.get('/admin/')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Admin Dashboard', response.data)
    
    def test_admin_blog_management(self):
        """Test admin blog management page"""
        self.login_admin()
        response = self.app.get('/admin/blog')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Blog Management', response.data)
    
    def test_admin_messages_page(self):
        """Test admin messages page"""
        self.login_admin()
        response = self.app.get('/admin/messages')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Customer Messages', response.data)
    
    def test_admin_requests_page(self):
        """Test admin requests page"""
        self.login_admin()
        response = self.app.get('/admin/requests')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Product Requests', response.data)

class TestStaticPages(ElliottAcresTestCase):
    """Test static pages"""
    
    def test_about_page_loads(self):
        """Test about page loads successfully"""
        response = self.app.get('/about')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'About Elliott Acres', response.data)
    
    def test_gallery_page_loads(self):
        """Test gallery page loads successfully"""
        response = self.app.get('/gallery')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Farm Gallery', response.data)

class TestHealthCheck(ElliottAcresTestCase):
    """Test health check endpoint"""
    
    def test_health_check_endpoint(self):
        """Test health check returns proper response"""
        response = self.app.get('/health')
        self.assertEqual(response.status_code, 200)
        
        # Parse JSON response
        import json
        data = json.loads(response.data)
        self.assertEqual(data['status'], 'healthy')
        self.assertIn('timestamp', data)

class TestDatabaseModels(ElliottAcresTestCase):
    """Test database model functionality"""
      def test_user_model(self):
        """Test User model functionality"""
        with app.app_context():
            user = User.query.filter_by(username='testadmin').first()
            self.assertIsNotNone(user)
            self.assertTrue(user.check_password('testpassword'))
    
    def test_product_model(self):
        """Test Product model functionality"""
        with app.app_context():
            product = Product.query.filter_by(name='Test Strawberries').first()
            self.assertIsNotNone(product)
            self.assertEqual(product.category, 'strawberries')
    
    def test_blog_post_model(self):
        """Test BlogPost model functionality"""
        with app.app_context():
            post = BlogPost.query.filter_by(title='Test Blog Post').first()
            self.assertIsNotNone(post)
            self.assertEqual(post.author_id, 1)
    
    def test_recipe_model(self):
        """Test Recipe model functionality"""
        with app.app_context():
            recipe = Recipe.query.filter_by(title='Test Recipe').first()
            self.assertIsNotNone(recipe)
            self.assertEqual(recipe.product_id, 1)

if __name__ == '__main__':
    # Create test suite
    test_suite = unittest.TestLoader().loadTestsFromModule(sys.modules[__name__])
    
    # Run tests with verbose output
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(test_suite)
    
    # Print summary
    print(f"\n{'='*50}")
    print(f"TEST SUMMARY")
    print(f"{'='*50}")
    print(f"Tests run: {result.testsRun}")
    print(f"Failures: {len(result.failures)}")
    print(f"Errors: {len(result.errors)}")
    print(f"Success rate: {((result.testsRun - len(result.failures) - len(result.errors)) / result.testsRun * 100):.1f}%")
    
    if result.failures:
        print(f"\nFAILURES:")
        for test, traceback in result.failures:
            print(f"- {test}: {traceback}")
    
    if result.errors:
        print(f"\nERRORS:")
        for test, traceback in result.errors:
            print(f"- {test}: {traceback}")
    
    # Exit with appropriate code
    sys.exit(0 if result.wasSuccessful() else 1)
