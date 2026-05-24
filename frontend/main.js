const services = [
  { name: 'Users', url: 'http://localhost:3001/health' },
  { name: 'Orders', url: 'http://localhost:3002/health' },
  { name: 'Catalog', url: 'http://localhost:3003/health' },
];

const dataSources = [
  {
    name: 'Users',
    url: 'http://localhost:3001/users',
    renderItem: (item) => `${item.name} · ${item.role}`,
  },
  {
    name: 'Orders',
    url: 'http://localhost:3002/orders',
    renderItem: (item) => `#${item.id} · user ${item.userId} · item ${item.itemId} · ${item.status}`,
    extractItems: (payload) => payload.orders,
  },
  {
    name: 'Catalog',
    url: 'http://localhost:3003/items',
    renderItem: (item) => `${item.name} · ${item.type}`,
  },
];

const container = document.getElementById('service-status');
const dataContainer = document.getElementById('sample-data');

const renderList = (title, entries, formatter) => {
  const card = document.createElement('article');
  card.className = 'service-card';
  const items = entries.slice(0, 3);

  card.innerHTML = `
    <h3>${title}</h3>
    <p class="status">${items.length ? `${items.length} record(s) shown` : 'No records available'}</p>
    <ul class="data-list">
      ${items.map((item) => `<li>${formatter(item)}</li>`).join('')}
    </ul>
  `;

  return card;
};

services.forEach((service) => {
  const card = document.createElement('article');
  card.className = 'service-card';
  card.innerHTML = `
    <h3>${service.name}</h3>
    <p class="status">Checking...</p>
    <a href="${service.url}" target="_blank">Open health endpoint</a>
  `;
  container.appendChild(card);

  fetch(service.url)
    .then((response) => response.json())
    .then((payload) => {
      card.querySelector('.status').textContent = `${payload.service} is ${payload.status}`;
      card.dataset.state = 'up';
    })
    .catch(() => {
      card.querySelector('.status').textContent = 'Unavailable';
      card.dataset.state = 'down';
    });
});

dataSources.forEach((source) => {
  const card = document.createElement('article');
  card.className = 'service-card';
  card.innerHTML = `
    <h3>${source.name}</h3>
    <p class="status">Loading sample data...</p>
  `;
  dataContainer.appendChild(card);

  fetch(source.url)
    .then((response) => response.json())
    .then((payload) => {
      const entries = source.extractItems ? source.extractItems(payload) : payload;
      const limitedEntries = Array.isArray(entries) ? entries.slice(0, 3) : [];
      card.replaceWith(renderList(source.name, limitedEntries, source.renderItem));
    })
    .catch(() => {
      card.querySelector('.status').textContent = 'Unavailable';
      card.dataset.state = 'down';
    });
});
