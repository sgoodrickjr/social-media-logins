#
# Stage 1: Build the frontend
#
FROM node:18-alpine AS build-client

# Create app directory
WORKDIR /app

# Copy only the client folder
COPY logins-client ./logins-client

# Install dependencies and build
WORKDIR /app/logins-client
RUN npm install
RUN npm run build
# This produces a production-ready build in "logins-client/dist" (or "build" depending on your framework)

#
# Stage 2: Build the API
#
FROM node:18-alpine AS build-api

WORKDIR /app

# Copy only the API folder
COPY logins-api ./logins-api

# Install dependencies and build
WORKDIR /app/logins-api
RUN npm install
RUN npm run build
# This should produce a compiled server in "logins-api/dist" (or wherever your build output is)

#
# Stage 3: Production container
#
FROM node:18-alpine

# Create app directory
WORKDIR /app

# Copy API build from the previous stage
COPY --from=build-api /app/logins-api/dist ./logins-api/dist
COPY --from=build-api /app/logins-api/package*.json ./logins-api/
# (Optional) If you need node_modules from build stage, either copy them or reinstall:
WORKDIR /app/logins-api
RUN npm install --production

# (Optional) Copy the built frontend into a folder the API can serve
WORKDIR /app
COPY --from=build-client /app/logins-client/dist ./public
# The API needs to be configured to serve from "/app/public" (or whichever folder you choose).

# Expose the API port
EXPOSE 3000

# Adjust the start command to match how your API starts
CMD ["node", "/app/logins-api/dist/index.js"]
