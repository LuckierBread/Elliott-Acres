-- Elliott Acres D1 Database Schema
-- Run this with: wrangler d1 execute elliott-acres-db --file=schema.sql

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Blog posts table
CREATE TABLE IF NOT EXISTS blog_posts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    image_url TEXT,
    author_id INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    published BOOLEAN DEFAULT 0,
    FOREIGN KEY (author_id) REFERENCES users (id)
);

-- Product requests table
CREATE TABLE IF NOT EXISTS product_requests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_name TEXT NOT NULL,
    customer_email TEXT NOT NULL,
    customer_phone TEXT,
    product_category TEXT NOT NULL,
    message TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    status TEXT DEFAULT 'pending'
);

-- Contact messages table
CREATE TABLE IF NOT EXISTS contact_messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    subject TEXT NOT NULL,
    message TEXT NOT NULL,
    product_interest TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    read BOOLEAN DEFAULT 0
);

-- Gallery images table
CREATE TABLE IF NOT EXISTS gallery_images (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    filename TEXT NOT NULL,
    caption TEXT,
    category TEXT,
    uploaded_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Products table
CREATE TABLE IF NOT EXISTS products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    price TEXT,
    description TEXT,
    image_url TEXT,
    available BOOLEAN DEFAULT 1
);

-- Recipes table
CREATE TABLE IF NOT EXISTS recipes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    ingredients TEXT NOT NULL,
    instructions TEXT NOT NULL,
    image_url TEXT,
    product_id INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products (id)
);

-- Insert default admin user (password: admin123)
INSERT OR IGNORE INTO users (username, email, password_hash)
VALUES ('admin', 'admin@elliottacres.com', 'scrypt:32768:8:1$OxJLRvIjZOpSzQKQ$f9b8c9c8e1b8e9f1a1b8e9f1a1b8e9f1a1b8e9f1a1b8e9f1a1b8e9f1a1b8e9f1a1b8e9f1a1b8e9f1');

-- Insert sample products
INSERT OR IGNORE INTO products (name, category, price, description, available) VALUES
('Fresh Strawberries', 'Strawberries', '$6.00/lb', 'Sweet, juicy strawberries picked fresh daily', 1),
('Strawberry Jam', 'Strawberries', '$8.50', 'Homemade strawberry jam made from our farm-fresh berries', 1),
('Frozen Strawberries', 'Strawberries', '$5.00/lb', 'Flash-frozen strawberries perfect for smoothies', 1),
('Fresh Asparagus', 'Asparagus', '$4.50/lb', 'Tender asparagus spears harvested at peak freshness', 1),
('Pickled Asparagus', 'Asparagus', '$7.25', 'Crispy pickled asparagus with herbs and spices', 1),
('Fresh Garlic Bulbs', 'Garlic', '$12.00/lb', 'Aromatic hardneck garlic bulbs', 1),
('Garlic Powder', 'Garlic', '$5.00', 'Fine ground garlic powder from our farm-grown garlic', 1),
('Garlic Scapes', 'Garlic', '$3.50/bunch', 'Tender garlic scapes perfect for stir-fries', 1);

-- Insert sample recipes
INSERT OR IGNORE INTO recipes (title, ingredients, instructions, product_id) VALUES
('Strawberry Shortcake', 'Fresh strawberries, Biscuits, Whipped cream, Sugar', '1. Slice strawberries and mix with sugar. 2. Split biscuits in half. 3. Layer with strawberries and whipped cream.', 1),
('Roasted Asparagus', 'Fresh asparagus, Olive oil, Salt, Pepper, Garlic', '1. Preheat oven to 400°F. 2. Toss asparagus with oil and seasonings. 3. Roast for 15-20 minutes.', 4),
('Garlic Butter', 'Fresh garlic, Butter, Salt, Herbs', '1. Mince garlic finely. 2. Mix with softened butter. 3. Add salt and herbs to taste.', 6);
