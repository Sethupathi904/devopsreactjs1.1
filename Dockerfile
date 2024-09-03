# Stage 1: Build the React application
FROM node:18 AS build

# Set the working directory
WORKDIR /app

# Set environment variable for OpenSSL legacy provider
ENV NODE_OPTIONS=--openssl-legacy-provider

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy application code
COPY . .

# Build the React application
RUN npm run build

# Stage 2: Serve the application with Nginx
FROM nginx:alpine

# Copy built files from the previous stage
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 80 for the Nginx server
EXPOSE 80

# Run Nginx
CMD ["nginx", "-g", "daemon off;"]
