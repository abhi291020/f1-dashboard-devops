# Use specific Node.js version with Alpine Linux for smaller size
FROM node:20.9.0-alpine

# Set environment variable for production
ENV NODE_ENV=production

# Create app directory and set ownership
RUN mkdir -p /home/node/app/node_modules && \
    chown -R node:node /home/node/app

# Set working directory
WORKDIR /home/node/app

# Copy package files with proper ownership
COPY --chown=node:node package*.json ./

# Switch to non-root user for security
USER node

# Install only production dependencies
RUN npm install --omit=dev


# Copy application code
COPY --chown=node:node . .

# Expose application port
EXPOSE 8080

# Health check for container
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:8080', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start application
CMD ["node", "server.js"]
