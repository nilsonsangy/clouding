// Substitua a URL pelo link gerado no Render para o backend
const backendUrl = "https://clouding-backend.onrender.com"; // URL da API do backend

// Buscar e exibir repositórios do GitHub
fetch(`${backendUrl}/api/github`)
  .then(res => res.json())
  .then(repos => {
    const list = document.getElementById('repo-list');
    repos.forEach(repo => {
      const item = document.createElement('li');
      item.innerHTML = `<a href="${repo.html_url}" target="_blank">${repo.name}</a>: ${repo.description || 'Sem descrição'}`;
      list.appendChild(item);
    });
  });

// Buscar e exibir vídeos do YouTube
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
  });
