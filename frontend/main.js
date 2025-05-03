// Retrieve the backend base URL from environment variables (e.g., for use in different environments like AWS or Render)
const backendUrl = window.env.BACKEND_URL;

/**
 * Fetch public GitHub repositories from the backend API
 * and dynamically render them into the 'repo-list' element.
 */
fetch(`${backendUrl}/api/github`)
  .then(res => res.json())
  .then(repos => {
    const list = document.getElementById('repo-list');

    // Iterate over each repository and create a list item with a link
    repos.forEach(repo => {
      const item = document.createElement('li');
      item.innerHTML = `<a href="${repo.html_url}" target="_blank">${repo.name}</a>: ${repo.description || 'No description'}`;
      list.appendChild(item);
    });
  })
  .catch(err => {
    // Log any errors that occur during the fetch
    console.error("GitHub fetch error:", err);
  });

/**
 * Fetch recent YouTube videos from the backend API
 * and embed them as iframes into the 'video-list' container.
 */
fetch(`${backendUrl}/api/youtube`)
  .then(res => res.json())
  .then(videos => {
    const container = document.getElementById('video-list');

    // Iterate over each video and create an embedded YouTube iframe
    videos.forEach(video => {
      const frame = document.createElement('iframe');
      frame.src = `https://www.youtube.com/embed/${video.id.videoId}`;
      frame.allow = "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture";
      frame.allowFullscreen = true;
      container.appendChild(frame);
    });
  })
  .catch(err => {
    // Log any errors that occur during the fetch
    console.error("YouTube fetch error:", err);
  });
