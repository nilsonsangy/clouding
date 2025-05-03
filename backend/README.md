# Clouding with Me!!! - Backend API

The backend API for the **Clouding with Me!!!** project is built using **Node.js** and **Express**. It provides two primary endpoints to fetch public GitHub repositories from the user `nilsonsangy` and the latest YouTube videos from a specific YouTube channel. The API is deployed on both **AWS** and **Render** and communicates with the frontend to provide dynamic data.

## 🌟 Features

- **GitHub Repositories**: Fetches a list of public repositories for user [`nilsonsangy`](https://github.com/nilsonsangy).
- **YouTube Videos**: Fetches the latest videos from YouTube channel using the YouTube Data API v3.

## 🛠 Technologies Used

- **Node.js**: JavaScript runtime for building the backend.
- **Express**: Web framework for building the RESTful API.
- **Axios**: Promise-based HTTP client for making external API requests.
- **dotenv**: Loads environment variables from a `.env` file.
- **CORS**: Middleware to enable Cross-Origin Resource Sharing.

## 🚀 Running the Backend API Locally

To run the backend API on your local machine, follow the steps below:

### Prerequisites

- Node.js and npm installed
- YouTube Data API v3 key (if using the YouTube endpoint)

### Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/nilsonsangy/clouding.git
   cd clouding/backend