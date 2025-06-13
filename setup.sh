#!/bin/bash

set -euo pipefail

#--------------------------------------------------------------------------
# SageMaker Configuration Script:
#   - Installs system updates and prerequisites
#   - Installs code-server and extensions
#   - Configures and starts code-server
#   - Installs and runs Ollama (via Docker)
#   - Creates configuration for Continue AI code assistant
#   - Sets up a new conda environment with Python 3.11
#   - Installs selected Python libraries
#
# Precondition:
#   CODE_SERVER_PASSWORD must be set in the terminal:
#   export CODE_SERVER_PASSWORD="YOUR_PASSWORD"
#--------------------------------------------------------------------------

# Ensure CODE_SERVER_PASSWORD is set
if [[ -z "${CODE_SERVER_PASSWORD:-}" ]]; then
  echo "ERROR: CODE_SERVER_PASSWORD is not set. Run:"
  echo '  export CODE_SERVER_PASSWORD="YOUR_PASSWORD"'
  exit 1
fi

echo "Starting setup..."

# System update and basic tools
echo "Updating system and installing prerequisites..."
sudo yum update -y
sudo yum install -y curl tar nano

# Install code-server
echo "Installing code-server..."
CODE_SERVER_VERSION="4.6.0"
RPM_FILE="code-server-${CODE_SERVER_VERSION}-amd64.rpm"

if [[ ! -f "$RPM_FILE" ]]; then
  curl -LO "https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/${RPM_FILE}"
else
  echo "RPM file already exists, skipping download."
fi

sudo rpm -Uvh "$RPM_FILE"

# Configure code-server
echo "Creating code-server configuration..."
CONFIG_DIR="/home/ec2-user/.config/code-server"
mkdir -p "$CONFIG_DIR"
cat <<EOF > "$CONFIG_DIR/config.yaml"
bind-addr: 127.0.0.1:8080
auth: password
password: $CODE_SERVER_PASSWORD
cert: false
EOF

# Set editor settings
SETTINGS_DIR="/home/ec2-user/.local/share/code-server/User"
mkdir -p "$SETTINGS_DIR"
cat <<'EOF' > "$SETTINGS_DIR/settings.json"
{
  "python.languageServer": "None",
  "workbench.colorTheme": "Default Dark+",
  "editor.rulers": [80],
  "workbench.iconTheme": "simple-icons",
  "files.exclude": {
    "**/.ipynb_checkpoints": true,
    "**/.Trash-1000": true,
    "**/.sparkmagic": true,
    "**/.virtual_documents": true,
    "**/lost+found": true
  },
  "search.exclude": {
    "**/.ipynb_checkpoints": true,
    "**/.Trash-1000": true,
    "**/.sparkmagic": true,
    "**/.virtual_documents": true,
    "**/lost+found": true
  }
}
EOF

# Start code-server
echo "Starting code-server..."
sudo -u ec2-user nohup code-server > /home/ec2-user/code-server.log 2>&1 &
sleep 10

# Install extensions
echo "Installing code-server extensions..."
EXTENSIONS=(
  ms-toolsai.jupyter
  ms-python.python
  ms-pyright.pyright
  grapecity.gc-excelviewer
  mechatroner.rainbow-csv
  continue.continue
  ms-azuretools.vscode-docker
  file-icons.file-icons
)

for ext in "${EXTENSIONS[@]}"; do
  sudo -u ec2-user code-server --install-extension "$ext"
done

echo "code-server setup completed."

# Start Ollama via Docker
echo "Starting Ollama container..."
docker run -d -p 11434:11434 --name ollama ollama/ollama
sleep 10

# Run test models
echo "Testing models inside Ollama..."
MODELS=("gemma3:1b" "qwen2.5:1.5b")

for model in "${MODELS[@]}"; do
  echo "Testing model: $model"
  docker exec -i ollama sh -c "echo '/bye' | ollama run $model > /dev/null 2>&1" \
    || echo "Warning: Docker exec failed for model $model."
  sleep 10
done

# Configure Continue AI
echo "Creating Continue AI config..."
CONTINUE_DIR="/home/ec2-user/.continue"
mkdir -p "$CONTINUE_DIR"
cat <<'EOF' > "$CONTINUE_DIR/config.yaml"
name: Local Assistant
version: 1.0.0
schema: v1
models:
  - name: gemma3:1b
    provider: ollama
    model: gemma3:1b
    url: http://localhost:11434
    completionOptions:
      temperature: 0.7
      top_p: 0.9

defaultModel: gemma3:1b

context:
  - provider: code
  - provider: docs
  - provider: diff
  - provider: terminal
  - provider: problems
  - provider: folder
  - provider: codebase
EOF

# Conda environment setup
echo "Creating conda environment..."
source ~/anaconda3/etc/profile.d/conda.sh
ENV_NAME="esi-001"

# Check if environment exists
if ! conda env list | awk '{print $1}' | grep -qx "$ENV_NAME"; then
  conda create -n "$ENV_NAME" python=3.11 -y
fi

# Activate the conda environment
conda activate "$ENV_NAME"

# Set PATH to ensure correct pip is used
export PATH="$HOME/anaconda3/envs/$ENV_NAME/bin:$PATH"

# Show pip path for confirmation
echo "Using pip from: $(which pip)"

# Rust setup
echo "Installing Rust..."
conda install -n "$ENV_NAME" -c conda-forge rust -y

# Python libraries
echo "Installing Python libraries..."
conda run -n "$ENV_NAME" pip install \
  jupyter \
  boto3 \
  pandas \
  matplotlib \
  openpyxl \
  openai \
  python-dotenv \
  datasets

# docker-compose setup
echo "Installing docker-compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Ensure docker-compose is in path within conda env
ACTIVATE_DIR="$HOME/anaconda3/envs/$ENV_NAME/etc/conda/activate.d"
mkdir -p "$ACTIVATE_DIR"
echo 'export PATH="/usr/local/bin:$PATH"' >> "$ACTIVATE_DIR/env_vars.sh"

echo "Setup completed successfully."
