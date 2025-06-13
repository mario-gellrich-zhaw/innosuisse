# Project Overview

This repository contains two primary components for AI-based career guidance and skill development systems:

- **`career_counseling_chatbot/`**: A system focused on providing career guidance using a chatbot interface, likely backed by a Neo4j knowledge graph.
- **`skill_framework/`**: A skill assessment and development framework, possibly integrated or complementary to the chatbot module.

It also includes scripts and dependencies for setup and deployment, especially within an AWS SageMaker environment.

---

## Directory Structure

### 📁 `career_counseling_chatbot/`

This module implements the career counseling chatbot, using a combination of data sources and possibly graph-based reasoning.

- **`data/`**: Raw or processed datasets used by the chatbot model.
- **`neo4j_db/`**: Likely contains configurations, scripts, or dumps for managing a Neo4j database (used for knowledge graph operations).
- **`notebooks/`**: Jupyter notebooks for development, prototyping, or experimentation.
- **`src/`**: Core source code for the chatbot’s backend logic, including interfaces with Neo4j and possibly NLP modules.
- **`.env`**: Environment variable configuration (e.g., API keys, DB paths, credentials).

---

### 📁 `skill_framework/`

This directory supports the evaluation or development of skills in conjunction with career counseling.

- **`data/`**: Data relevant to skill assessment or tracking.
- **`notebooks/`**: Analysis, training, or usage notebooks for this module.
- **`src/`**: Python source code for skill evaluation, feature extraction, model inference, etc.
- **`.env`**: Module-specific environment variables.

---

### 🐳 `docker-compose.yml`

Defines and configures multi-container Docker applications. Likely used to deploy components like the Neo4j DB, chatbot services, and API gateways in a consistent local or cloud environment.

---

### ⚙️ `setup.sh`

Shell script for setting up the environment — may install dependencies, configure services, or prepare data for local use or SageMaker deployment.

---

### 📄 `requirements.txt`

List of Python dependencies for the entire project. Used by `pip` to install packages.

---

### 📄 `README.md`

This file. Explains the project structure and purpose.

---

### 📄 `.gitignore`

Specifies intentionally untracked files to ignore in version control (e.g., `__pycache__`, `.env`, etc.).

---

### 📦 `code-server-4.6.0-amd64.rpm`

RPM package for installing `code-server` — a cloud IDE based on Visual Studio Code. Useful for coding remotely within SageMaker or other cloud environments.

---

## Getting Started

1. Clone the repository and navigate into the project directory.
2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Run the setup:
   ```bash
   bash setup.sh
   ```
4. Launch services using Docker:
   ```bash
   docker-compose up
   ```
5. Launch Jupyter notebooks or code-server as needed.

---

