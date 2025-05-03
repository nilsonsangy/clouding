// Import the 'fs' and 'path' modules for file handling and path resolution
const fs = require("fs");
const path = require("path");

console.log("🔧 Starting environment variable injection...");

// Retrieve the backend URL from environment variables
const backendUrl = process.env.BACKEND_URL;

// Check if the environment variable is available
if (!backendUrl) {
  console.error("❌ BACKEND_URL is not defined. Please set it in your environment.");
  process.exit(1);
}

console.log(`✅ BACKEND_URL found: ${backendUrl}`);

// Create the content of the env.js file
const content = `window.env = { BACKEND_URL: "${backendUrl}" };`;

// Define the path where the env.js file should be written
const targetPath = path.join(__dirname, "../env.js");

try {
  // Write the content to the env.js file
  fs.writeFileSync(targetPath, content);
  console.log(`✅ env.js generated successfully at: ${targetPath}`);
} catch (err) {
  // Log and exit if an error occurs during file writing
  console.error("❌ Failed to write env.js:", err);
  process.exit(1);
}
