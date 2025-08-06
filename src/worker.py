"""
Cloudflare Workers entry point for Elliott Acres Flask application
"""
import sys
import os

# Add the parent directory to the path to import the Flask app
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from app import app

async def on_fetch(request, env, ctx):
    """
    Main entry point for Cloudflare Workers
    """
    try:
        # Set environment variables for Workers context
        os.environ['CF_WORKER'] = '1'
        os.environ['FLASK_ENV'] = 'production'
        
        # Extract request information
        url = str(request.url)
        method = request.method
        headers = dict(request.headers)
        
        # Get request body for POST/PUT requests
        body = None
        if method in ['POST', 'PUT', 'PATCH'] and request.headers.get('content-type'):
            if 'application/json' in request.headers.get('content-type', ''):
                body = await request.json()
            elif 'application/x-www-form-urlencoded' in request.headers.get('content-type', ''):
                body = await request.text()
            else:
                body = await request.text()
        
        # Parse the path from URL
        path = url.split('://', 1)[1].split('/', 1)
        path = '/' + (path[1] if len(path) > 1 else '')
        
        # Create Flask test request context
        with app.test_request_context(
            path=path,
            method=method,
            headers=headers,
            data=body,
            query_string=request.url.split('?', 1)[1] if '?' in url else None
        ):
            # Process the Flask request
            response = app.full_dispatch_request()
            
            # Convert Flask response to Workers Response
            from js import Response
            return Response.new(
                response.get_data(),
                {
                    "status": response.status_code,
                    "headers": dict(response.headers)
                }
            )
            
    except Exception as e:
        from js import Response
        return Response.new(
            f"Internal Server Error: {str(e)}", 
            {
                "status": 500,
                "headers": {"Content-Type": "text/plain"}
            }
        )

# Export the handler for Cloudflare Workers
fetch = on_fetch
