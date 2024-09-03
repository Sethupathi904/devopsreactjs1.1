# Stage 1: Build the ReactJS application
FROM node:18 AS build

WORKDIR /app

# Install dependencies
COPY package.json package-lock.json ./
RUN npm install

# Copy the source code and build the application
COPY . .
ENV NODE_OPTIONS=--openssl-legacy-provider
RUN npm run build

# Stage 2: Serve the ReactJS application
FROM nginx:alpine

COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
