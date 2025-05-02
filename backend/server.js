require("dotenv").config();
const express = require("express");
const cors = require("cors");
const axios = require("axios");

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.static("frontend"));

// GitHub API route
app.get("/api/github", async (req, res) => {
  try {
    const response = await axios.get("https://api.github.com/users/nilsonsangy/repos");
    res.json(response.data);
  } catch (error) {
    console.error("Error fetching GitHub repositories:", error.message);
    res.status(500).json({ error: "Failed to fetch repositories" });
  }
});

// YouTube API route
app.get("/api/youtube", async (req, res) => {
  try {
    const apiKey = process.env.YOUTUBE_API_KEY;
    const channelId = process.env.YOUTUBE_CHANNEL_ID || "UC__PLZtCqybzHkMQ-7oz8vw";

    if (!apiKey) {
      return res.status(500).json({ error: "YouTube API key not configured" });
    }

    const response = await axios.get(
      `https://www.googleapis.com/youtube/v3/search?key=${apiKey}&channelId=${channelId}&order=date&part=snippet&type=video`
    );

    res.json(response.data.items);
  } catch (error) {
    console.error("Error fetching YouTube videos:", error.message);
    res.status(500).json({ error: "Failed to fetch videos" });
  }
});

// Start server
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
