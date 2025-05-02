// Backend base URL (Render)
const backendUrl = "https://clouding-backend.onrender.com";

// Fetch and display GitHub repositories
fetch(`${backendUrl}/api/github`)
  .then(res => res.json())
  .then(repos => {
    const list = document.getElementById('repo-list');
    repos.forEach(repo => {
      const item = document.createElement('li');
      item.innerHTML = `<a href="${repo.html_url}" target="_blank">${repo.name}</a>: ${repo.description || 'No description'}`;
      list.appendChild(item);
    });
  })
  .catch(err => console.error("GitHub fetch error:", err));

// Fetch and display YouTube videos
fetch(`${backendUrl}/api/youtube`)
  .then(res => res.json())
  .then(videos => {
    const container = document.getElementById('video-list');
    videos.forEach(video => {
      const frame = document.createElement('iframe');
      frame.src = `https://www.youtube.com/embed/${video.id.videoId}`;
      frame.allow = "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture";
      frame.allowFullscreen = true;
      container.appendChild(frame);
    });
  })
  .catch(err => console.error("YouTube fetch error:", err));
