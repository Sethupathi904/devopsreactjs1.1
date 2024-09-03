# Stage 1: Build the ReactJS application
FROM node:18 AS build

WORKDIR /app

# Copy package.json and package-lock.json first
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the ReactJS application
RUN npm run build

# Stage 2: Serve the ReactJS application
FROM nginx:alpine

COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
