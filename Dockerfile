# Stage 1: Build the ReactJS application
FROM node:18 AS build

WORKDIR /app

# Copy the package.json and package-lock.json
COPY package.json package-lock.json ./

# Install all dependencies, including react-redux
RUN npm install

# Set NODE_OPTIONS to use the legacy OpenSSL provider
ENV NODE_OPTIONS=--openssl-legacy-provider

# Copy the rest of the application code
COPY . .

# Build the ReactJS application
RUN npm run build

# Stage 2: Serve the ReactJS application
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
