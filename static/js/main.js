// Elliott Acres Farm - Main JavaScript

// Common utility functions for admin
function getCookie(name) {
    let cookieValue = null;
    if (document.cookie && document.cookie !== '') {
        const cookies = document.cookie.split(';');
        for (let i = 0; i < cookies.length; i++) {
            const cookie = cookies[i].trim();
            if (cookie.substring(0, name.length + 1) === (name + '=')) {
                cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                break;
            }
        }
    }
    return cookieValue;
}

function showAlert(message, type) {
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type} alert-dismissible fade show`;
    alertDiv.innerHTML = `
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;
    
    const container = document.querySelector('.container-fluid') || document.querySelector('.container');
    if (container) {
        container.insertBefore(alertDiv, container.firstChild);
        
        // Auto-dismiss after 5 seconds
        setTimeout(() => {
            if (alertDiv.parentNode) {
                alertDiv.remove();
            }
        }, 5000);
    }
}

document.addEventListener('DOMContentLoaded', function() {
    // Initialize tooltips
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });

    // Product request form handling
    const productRequestForm = document.getElementById('productRequestForm');
    if (productRequestForm) {
        productRequestForm.addEventListener('submit', handleProductRequest);
    }

    // Product request buttons
    const productRequestButtons = document.querySelectorAll('.btn-product-request');
    productRequestButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            const category = this.getAttribute('data-category');
            openProductRequestModal(category);
        });
    });

    // Gallery lightbox
    initializeGalleryLightbox();

    // Smooth scrolling for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });

    // Add fade-in animation to elements when they come into view
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('fade-in-up');
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);

    // Observe elements for animation
    document.querySelectorAll('.product-showcase, .product-card, .blog-post, .recipe-card').forEach(el => {
        observer.observe(el);
    });

    // Auto-advance carousel with pause on hover
    const carousel = document.querySelector('#newsCarousel');
    if (carousel) {
        const bsCarousel = new bootstrap.Carousel(carousel, {
            interval: 5000,
            ride: 'carousel'
        });

        carousel.addEventListener('mouseenter', () => {
            bsCarousel.pause();
        });

        carousel.addEventListener('mouseleave', () => {
            bsCarousel.cycle();
        });
    }
});

function openProductRequestModal(category = '') {
    const modal = new bootstrap.Modal(document.getElementById('productRequestModal'));
    if (category) {
        document.getElementById('requestCategory').value = category;
    }
    modal.show();
}

async function handleProductRequest(e) {
    e.preventDefault();
    
    const form = e.target;
    const formData = new FormData(form);
    const submitButton = form.querySelector('button[type="submit"]');
    const originalText = submitButton.innerHTML;
    
    // Show loading state
    submitButton.innerHTML = '<span class="loading"></span> Submitting...';
    submitButton.disabled = true;
    
    try {
        const response = await fetch('/product-request', {
            method: 'POST',
            body: formData
        });
        
        const result = await response.json();
        
        if (result.success) {
            // Show success message
            showNotification('success', 'Request submitted successfully! We\'ll get back to you soon.');
            
            // Close modal and reset form
            const modal = bootstrap.Modal.getInstance(document.getElementById('productRequestModal'));
            modal.hide();
            form.reset();
        } else {
            showNotification('error', result.message || 'Something went wrong. Please try again.');
        }
    } catch (error) {
        console.error('Error submitting request:', error);
        showNotification('error', 'Network error. Please check your connection and try again.');
    } finally {
        // Reset button state
        submitButton.innerHTML = originalText;
        submitButton.disabled = false;
    }
}

function showNotification(type, message) {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `alert alert-${type === 'success' ? 'success' : 'danger'} alert-dismissible fade show position-fixed`;
    notification.style.cssText = 'top: 100px; right: 20px; z-index: 9999; max-width: 400px;';
    notification.innerHTML = `
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;
    
    // Add to page
    document.body.appendChild(notification);
    
    // Auto-remove after 5 seconds
    setTimeout(() => {
        if (notification.parentNode) {
            notification.remove();
        }
    }, 5000);
}

function initializeGalleryLightbox() {
    const galleryItems = document.querySelectorAll('.gallery-item img');
    
    galleryItems.forEach(img => {
        img.addEventListener('click', function() {
            openLightbox(this.src, this.alt);
        });
    });
}

function openLightbox(imageSrc, imageAlt) {
    // Create lightbox overlay
    const lightbox = document.createElement('div');
    lightbox.className = 'lightbox-overlay';
    lightbox.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0,0,0,0.9);
        z-index: 9999;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
    `;
    
    // Create image element
    const img = document.createElement('img');
    img.src = imageSrc;
    img.alt = imageAlt;
    img.style.cssText = `
        max-width: 90%;
        max-height: 90%;
        object-fit: contain;
        border-radius: 10px;
        box-shadow: 0 0 50px rgba(0,0,0,0.5);
    `;
    
    // Create close button
    const closeButton = document.createElement('button');
    closeButton.innerHTML = '&times;';
    closeButton.style.cssText = `
        position: absolute;
        top: 20px;
        right: 30px;
        background: none;
        border: none;
        color: white;
        font-size: 40px;
        cursor: pointer;
        z-index: 10000;
    `;
    
    lightbox.appendChild(img);
    lightbox.appendChild(closeButton);
    document.body.appendChild(lightbox);
    
    // Add event listeners
    lightbox.addEventListener('click', function(e) {
        if (e.target === lightbox || e.target === closeButton) {
            closeLightbox(lightbox);
        }
    });
    
    // Close on escape key
    const escapeHandler = function(e) {
        if (e.key === 'Escape') {
            closeLightbox(lightbox);
            document.removeEventListener('keydown', escapeHandler);
        }
    };
    document.addEventListener('keydown', escapeHandler);
    
    // Animate in
    lightbox.style.opacity = '0';
    setTimeout(() => {
        lightbox.style.transition = 'opacity 0.3s ease';
        lightbox.style.opacity = '1';
    }, 10);
}

function closeLightbox(lightbox) {
    lightbox.style.opacity = '0';
    setTimeout(() => {
        if (lightbox.parentNode) {
            lightbox.remove();
        }
    }, 300);
}

// Recipe card flip functionality for touch devices
document.addEventListener('touchstart', function(e) {
    const recipeCard = e.target.closest('.recipe-card');
    if (recipeCard && !recipeCard.classList.contains('flipped')) {
        recipeCard.classList.add('flipped');
        recipeCard.querySelector('.recipe-card-inner').style.transform = 'rotateY(180deg)';
        
        // Auto-flip back after 5 seconds
        setTimeout(() => {
            if (recipeCard.classList.contains('flipped')) {
                recipeCard.classList.remove('flipped');
                recipeCard.querySelector('.recipe-card-inner').style.transform = 'rotateY(0deg)';
            }
        }, 5000);
    }
});

// Contact form validation
const contactForm = document.querySelector('#contactForm');
if (contactForm) {
    contactForm.addEventListener('submit', function(e) {
        e.preventDefault();
        
        // Basic validation
        const requiredFields = contactForm.querySelectorAll('[required]');
        let isValid = true;
        
        requiredFields.forEach(field => {
            if (!field.value.trim()) {
                field.classList.add('is-invalid');
                isValid = false;
            } else {
                field.classList.remove('is-invalid');
            }
        });
        
        // Email validation
        const emailField = contactForm.querySelector('input[type="email"]');
        if (emailField && emailField.value) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(emailField.value)) {
                emailField.classList.add('is-invalid');
                isValid = false;
            }
        }
        
        if (isValid) {
            // Submit form normally
            contactForm.submit();
        } else {
            showNotification('error', 'Please fill in all required fields correctly.');
        }
    });
}

// Admin dashboard functionality
if (window.location.pathname.includes('/admin')) {
    initializeAdminFeatures();
}

function initializeAdminFeatures() {
    // Confirm delete actions
    document.querySelectorAll('.btn-delete').forEach(button => {
        button.addEventListener('click', function(e) {
            if (!confirm('Are you sure you want to delete this item?')) {
                e.preventDefault();
            }
        });
    });
    
    // Auto-save draft posts
    const postForm = document.querySelector('#blogPostForm');
    if (postForm) {
        const titleField = postForm.querySelector('#title');
        const contentField = postForm.querySelector('#content');
        
        if (titleField && contentField) {
            let saveTimeout;
            
            const autoSave = () => {
                clearTimeout(saveTimeout);
                saveTimeout = setTimeout(() => {
                    const draftData = {
                        title: titleField.value,
                        content: contentField.value
                    };
                    localStorage.setItem('blogDraft', JSON.stringify(draftData));
                    console.log('Draft saved');
                }, 2000);
            };
            
            titleField.addEventListener('input', autoSave);
            contentField.addEventListener('input', autoSave);
            
            // Load draft on page load
            const savedDraft = localStorage.getItem('blogDraft');
            if (savedDraft && !titleField.value && !contentField.value) {
                const draftData = JSON.parse(savedDraft);
                if (confirm('Found a saved draft. Would you like to restore it?')) {
                    titleField.value = draftData.title || '';
                    contentField.value = draftData.content || '';
                }
            }
            
            // Clear draft on successful submit
            postForm.addEventListener('submit', () => {
                localStorage.removeItem('blogDraft');
            });
        }
    }
}

// Performance optimization: Lazy load images
function lazyLoadImages() {
    const images = document.querySelectorAll('img[data-src]');
    
    const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                img.src = img.dataset.src;
                img.classList.remove('lazy');
                observer.unobserve(img);
            }
        });
    });
    
    images.forEach(img => imageObserver.observe(img));
}

// Initialize lazy loading
lazyLoadImages();
