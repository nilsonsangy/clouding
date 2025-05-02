require("dotenv").config();
const express = require("express");
const axios = require("axios");

const app = express();
const port = process.env.PORT || 3000;

// Serve static files from the "frontend" directory
app.use(express.static("frontend"));

// GitHub API route
app.get("/api/github", async (req, res) => {
  try {
    const response = await axios.get("https://api.github.com/users/nilsonsangy/repos");
    res.json(response.data);
  } catch (error) {
    console.error("Error fetching GitHub repositories:", error);
    res.status(500).json({ message: "Error fetching repositories" });
  }
});

// YouTube API route
app.get("/api/youtube", async (req, res) => {
  try {
    const apiKey = process.env.YOUTUBE_API_KEY;
    const channelId = "UC__PLZtCqybzHkMQ-7oz8vw"; // KnowTree YouTube Channel ID
    const response = await axios.get(`https://www.googleapis.com/youtube/v3/search?key=${apiKey}&channelId=${channelId}&order=date&part=snippet&type=video`);
    res.json(response.data.items);
  } catch (error) {
    console.error("Error fetching YouTube videos:", error);
    res.status(500).json({ message: "Error fetching videos" });
  }
});

// Start server
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
