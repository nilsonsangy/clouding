# Use the official Nginx image as the base image
FROM nginx:alpine

# Copy the frontend build to the Nginx HTML directory
COPY . /usr/share/nginx/html

# Expose the default Nginx port
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]