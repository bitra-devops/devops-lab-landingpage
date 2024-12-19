# Use an official Nginx image from Docker Hub as a base
FROM nginx:alpine

# Set the working directory inside the container
WORKDIR /usr/share/nginx/html

# Copy all the landing page files into the container
COPY . .

# Expose the default Nginx port (80)
EXPOSE 80

# Nginx runs by default, so no need to specify the entry point