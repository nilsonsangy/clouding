# Clouding with Me!!!

**Clouding with Me!!!** is a lightweight web application designed to serve as a general-purpose blog. It showcases dynamic content such as GitHub repositories and recent videos from a YouTube channel. The project is containerized using Docker and can be deployed locally or in a cloud environment using Kubernetes. It also features a CI/CD pipeline to automate Docker image updates on Docker Hub.

## 🌟 Features

- General-purpose blog functionality
- View public **GitHub repositories** from a user
- Watch **recent YouTube videos** from a YouTube channel
- Clean and responsive web interface using **HTML**, **CSS**, and **JavaScript**
- Backend API built with **Node.js** and **Express**
- Containerized with **Docker**
- Deployable with **Kubernetes**
- Automated CI/CD pipeline for Docker image updates

## 🔗 Live Demo

- **Frontend (Vercel)**: [https://clouding.vercel.app/](https://clouding.vercel.app/)
- **Frontend (AWS Amplify)**: [https://main.d1xzwmewjfc8y0.amplifyapp.com/](https://main.d1xzwmewjfc8y0.amplifyapp.com/)

## 🛠 Technologies Used

### Frontend:
- HTML
- CSS
- JavaScript
- Hosted on [Vercel](https://vercel.com/) and [AWS Amplify](https://aws.amazon.com/amplify/)

### Backend:
- Node.js
- Express.js
- Axios (for API requests)
- Running on [Render](https://render.com/) and [AWS](https://aws.amazon.com/)

### Containerization and Orchestration:
- Docker
- Kubernetes

### APIs:
- [GitHub REST API](https://docs.github.com/en/rest)
- [YouTube Data API](https://developers.google.com/youtube/v3)

## 🔧 Configuration

The application allows you to configure the GitHub repository and YouTube channel dynamically. By default, it uses the following:

- **GitHub Repository**: [https://github.com/nilsonsangy/](https://github.com/nilsonsangy/)
- **YouTube Channel**: [https://www.youtube.com/@KnowTree](https://www.youtube.com/@KnowTree)

To customize these values, create a `config.json` file in the `backend` directory with the following structure:

```json
{
  "githubRepo": "<your-github-repo>",
  "youtubeChannel": "<your-youtube-channel>"
}
```

## 🚀 Getting Started (Local Development)

### Prerequisites

- Docker and Docker Compose installed
- Kubernetes CLI (kubectl) installed
- Node.js and npm installed
- GitHub account
- YouTube Data API key from Google Cloud Console

### Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/nilsonsangy/clouding.git
   cd clouding
   ```

2. **Set up environment variables:**
   Copy the `env-sample` file to `.env` and update the values as needed.

3. **Run locally with Docker Compose:**
   ```bash
   docker-compose up --build
   ```

4. **Access the application:**
   - Backend: [http://localhost:3000](http://localhost:3000)
   - Frontend: [http://localhost:8080](http://localhost:8080)

## 🌐 Deployment with Kubernetes

### Steps

1. **Apply backend deployment and service:**
   ```bash
   kubectl apply -f backend/deployment.yaml
   kubectl apply -f backend/service.yaml
   ```

2. **Apply frontend deployment and service:**
   ```bash
   kubectl apply -f frontend/deployment.yaml
   kubectl apply -f frontend/service.yaml
   ```

3. **Verify deployments:**
   ```bash
   kubectl get pods
   kubectl get services
   ```

## 🔄 CI/CD Pipeline

The project includes a GitHub Actions workflow to automate Docker image updates:

- On every push to the `main` branch, the workflow:
  1. Builds Docker images for the backend and frontend.
  2. Pushes the images to Docker Hub under the repository `nilsonsangy/clouding`.

Ensure the following secrets are configured in your GitHub repository:

- `DOCKER_USERNAME`: Your Docker Hub username.
- `DOCKER_PASSWORD`: Your Docker Hub password.

## 📂 Project Structure

```
clouding/
├── backend/
│   ├── config.json
│   ├── deployment.yaml
│   ├── Dockerfile
│   ├── package.json
│   ├── server.js
│   ├── service.yaml
├── frontend/
│   ├── deployment.yaml
│   ├── Dockerfile
│   ├── favicon.png
│   ├── index.html
│   ├── main.js
│   ├── package.json
│   ├── service.yaml
│   ├── style.css
│   ├── scripts/
│   │   ├── generate-env.js
├── docker-compose.yml
├── env-sample
├── README.md
```

## 📝 License

This project is licensed under the MIT License.
