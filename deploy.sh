#!/bin/bash

# Set variables
BUCKET_NAME="shulamit-vizel-bucket"
BRANCH="main"  # Specify the branch name explicitly

# Log function for better output readability
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Step 1: Check for unstaged changes and commit them
log "Checking for unstaged changes..."
if git status --porcelain > /dev/null 2>&1; then
    if [[ -n $(git status --porcelain) ]]; then
        log "Changes detected. Staging changes..."
        git add .
        log "Enter a commit message:"
        read -r COMMIT_MESSAGE
        if [[ -z "$COMMIT_MESSAGE" ]]; then
            log "Error: Commit message cannot be empty. Exiting."
            exit 1
        fi
        git commit -m "$COMMIT_MESSAGE"
    else
        log "No changes detected. Skipping commit step."
    fi
else
    log "Error: Failed to check git status. Exiting."
    exit 1
fi

# Step 2: Push changes to GitHub
log "Pushing changes to GitHub..."
if git push origin $BRANCH; then
    log "Changes pushed successfully."
else
    log "Error: Failed to push changes. Exiting."
    exit 1
fi

# Step 3: Install dependencies and build the React app
log "Checking for package.json..."
if [[ ! -f "package.json" ]]; then
    log "Error: package.json not found. Exiting."
    exit 1
fi

log "Installing dependencies..."
if [[ ! -d "node_modules" ]]; then
    npm install || { log "Error: npm install failed. Exiting."; exit 1; }
else
    log "Dependencies already installed. Skipping npm install."
fi

log "Building React app..."
if npm run build; then
    log "React app built successfully."
else
    log "Error: React app build failed. Exiting."
    exit 1
fi

# Step 4: Upload the built files to the GCS bucket
log "Uploading files to GCS bucket ($BUCKET_NAME)..."
if gsutil -m cp -r build/* gs://$BUCKET_NAME; then
    log "Files uploaded successfully to GCS bucket."
else
    log "Error: Failed to upload files to GCS bucket. Exiting."
    exit 1
fi

log "Automation script completed successfully!"

