// Load environment variables from a .env file into process.env
require("dotenv").config();

// Import required modules
const express = require("express");
const cors = require("cors");
const axios = require("axios");
const fs = require('fs');

// Initialize the Express application
const app = express();

// Define the server port from environment variables or use default 3000
const port = process.env.PORT || 3000;

// Enable CORS (Cross-Origin Resource Sharing) for all routes
app.use(cors());

// Serve static frontend files from the 'frontend' directory
app.use(express.static("frontend"));

// Add support for dynamic configuration of GitHub repository and YouTube channel
const configPath = './config.json';

// Load configuration
let config = {
  githubRepo: 'https://github.com/nilsonsangy/',
  youtubeChannel: 'https://www.youtube.com/@KnowTree'
};

if (fs.existsSync(configPath)) {
  const fileContent = fs.readFileSync(configPath);
  config = JSON.parse(fileContent);
}

// Endpoint to fetch configuration
app.get('/api/config', (req, res) => {
  res.json(config);
});

/**
 * Route: GET /api/github
 * Description: Fetch public GitHub repositories of user 'nilsonsangy'
 * and return them as JSON.
 */
app.get("/api/github", async (req, res) => {
  try {
    const response = await axios.get("https://api.github.com/users/nilsonsangy/repos");
    res.json(response.data);
  } catch (error) {
    console.error("Error fetching GitHub repositories:", error.message);
    res.status(500).json({ error: "Failed to fetch repositories" });
  }
});

/**
 * Route: GET /api/youtube
 * Description: Fetch the latest YouTube videos from a specific channel.
 * Uses YouTube Data API v3.
 */
app.get("/api/youtube", async (req, res) => {
  try {
    const apiKey = process.env.YOUTUBE_API_KEY; // YouTube API key from environment

    // Validate that the API key is available
    if (!apiKey) {
      return res.status(500).json({ error: "YouTube API key not configured" });
    }

    // Fetch the YouTube channel name from the config.json file
    const channelName = config.youtubeChannel;

    // Make a request to the YouTube Data API for the latest videos
    const response = await axios.get(
      `https://www.googleapis.com/youtube/v3/search?key=${apiKey}&forUsername=${channelName}&order=date&part=snippet&type=video`
    );

    // Return only the video items
    res.json(response.data.items);
  } catch (error) {
    console.error("Error fetching YouTube videos:", error.message);
    res.status(500).json({ error: "Failed to fetch videos" });
  }
});

/**
 * Start the Express server and listen on the defined port.
 */
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
