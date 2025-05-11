# Use the official Node.js image as the base image
FROM node:18

# Set the working directory
WORKDIR /usr/src/app

# Copy package.json and install dependencies
COPY package.json ./
RUN npm install

# Copy the rest of the application code
COPY . ./

# Expose the default application port (informative only)
EXPOSE 3000

# Start the application
CMD ["node", "server.js"]