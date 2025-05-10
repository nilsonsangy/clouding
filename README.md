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

## 🌐 Kubernetes Environment Configuration

The `clouding-kubernetes-environment.yaml` file defines the Kubernetes setup for deploying the backend and frontend services. Below is an overview of its contents:

### Backend Deployment and Service
- **Deployment**:
  - Creates 2 replicas of the backend application for high availability.
  - Uses the Docker image `nilsonsangy/clouding-backend:latest`.
  - Exposes port `3000` and sets the `NODE_ENV` environment variable to `production`.
- **Service**:
  - Exposes the backend pods internally within the cluster on port `3000`.
  - Uses a `ClusterIP` service type, making it accessible only within the cluster.

### Frontend Deployment and Service
- **Deployment**:
  - Creates 2 replicas of the frontend application for high availability.
  - Uses the Docker image `nilsonsangy/clouding-frontend:latest`.
  - Exposes port `80`.
- **Service**:
  - Exposes the frontend pods internally within the cluster on port `80`.
  - Uses a `ClusterIP` service type, making it accessible only within the cluster.

### How to Apply the Configuration
To deploy the services to your Kubernetes cluster, run the following command:

```bash
kubectl apply -f clouding-kubernetes-environment.yaml
```

This will create the necessary deployments and services for both the backend and frontend.

## Running the Application with Kubernetes (K3d)

### Prerequisites
Make sure you have K3d and kubectl installed on your system.

- Install K3d:
  ```bash
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
  ```
- Install kubectl if it is not already installed:
  ```bash
  sudo apt-get install -y kubectl
  ```

### Steps to Run the Application

1. **Create a local Kubernetes cluster**
   - Use K3d to create a cluster named `clouding-cluster`:
     ```bash
     k3d cluster create clouding-cluster --servers 1 --agents 2
     ```

2. **Configure kubectl to use the cluster**
   - Ensure the kubectl context is set to the created cluster:
     ```bash
     kubectl config use-context k3d-clouding-cluster
     ```

3. **Prepare the Kubernetes configuration files**
   - Ensure the `clouding-kubernetes-environment.yaml` file contains the necessary manifests for the services (Deployments, Services, ConfigMaps, etc.).
   - Edit the file if needed to include the correct configurations for the backend and frontend.

4. **Apply the manifests to the cluster**
   - Apply the Kubernetes configuration file:
     ```bash
     kubectl apply -f clouding-kubernetes-environment.yaml
     ```

5. **Check the pods and services**
   - Verify that the pods are running:
     ```bash
     kubectl get pods
     ```
   - Check the services to get the access address:
     ```bash
     kubectl get services
     ```

6. **Access the application**
   - Use the address and port exposed by the service to access the application in your browser.

## 🔄 CI/CD Pipeline

The project includes a GitHub Actions workflow to automate Docker image updates:

- On every push to the `main` branch, the workflow:
  1. Builds Docker images for the backend and frontend.
  2. Pushes the images to Docker Hub under the repository `nilsonsangy/clouding`.

Ensure the following secrets are configured in your GitHub repository:

- `DOCKER_USERNAME`: Your Docker Hub username.
- `DOCKER_PASSWORD`: Your Docker Hub password.

## CI/CD Pipeline for Docker Images

The project includes a GitHub Actions workflow defined in `.github/workflows/docker-image.yml`. This workflow automates the process of building and pushing Docker images for the backend and frontend to Docker Hub.

### Workflow Overview

- **Trigger**: The workflow runs on every push to the `main` branch.
- **Steps**:
  1. **Checkout Code**: Clones the repository to the GitHub Actions runner.
  2. **Set up Docker Buildx**: Prepares the environment for building multi-platform Docker images.
  3. **Log in to Docker Hub**: Authenticates with Docker Hub using credentials stored in GitHub Secrets.
  4. **Build and Push Backend Image**: Builds the backend Docker image from the `./backend` directory and pushes it to Docker Hub with the tag `nilsonsangy/clouding-backend:latest`.
  5. **Build and Push Frontend Image**: Builds the frontend Docker image from the `./frontend` directory and pushes it to Docker Hub with the tag `nilsonsangy/clouding-frontend:latest`.

### Prerequisites

To use this workflow, ensure the following secrets are configured in your GitHub repository:

- `DOCKER_USERNAME`: Your Docker Hub username.
- `DOCKER_PASSWORD`: Your Docker Hub password.

### How to Modify

If you need to change the Docker image tags or paths, update the `tags` and `context` fields in the workflow file accordingly.

## 📝 License

This project is licensed under the MIT License.
