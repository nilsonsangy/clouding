const fs = require("fs");
const path = require("path");

const backendUrl = process.env.BACKEND_URL || "http://localhost:3000";

const content = `window.env = {
  BACKEND_URL: "${backendUrl}"
};`;

const outputPath = path.join(__dirname, "env.js");
fs.writeFileSync(outputPath, content);
console.log("✅ env.js generated with BACKEND_URL =", backendUrl);
