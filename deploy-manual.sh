#!/bin/bash
# Manual deployment script for GitHub Pages
# This script injects Firebase config and deploys to gh-pages branch

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================"
echo "GitHub Pages Manual Deployment Script"
echo "========================================"
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}ERROR: .env file not found${NC}"
    echo "Please create a .env file with your Firebase configuration."
    echo "See .env.example for reference."
    exit 1
fi

# Load environment variables from .env
echo -e "${YELLOW}Loading Firebase configuration from .env...${NC}"
export $(cat .env | grep -v '^#' | xargs)

# Verify required environment variables
REQUIRED_VARS=(
    "FIREBASE_API_KEY"
    "FIREBASE_AUTH_DOMAIN"
    "FIREBASE_PROJECT_ID"
    "FIREBASE_STORAGE_BUCKET"
    "FIREBASE_MESSAGING_SENDER_ID"
    "FIREBASE_APP_ID"
)

MISSING_VARS=0
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo -e "${RED}ERROR: $var is not set in .env${NC}"
        MISSING_VARS=$((MISSING_VARS + 1))
    fi
done

if [ $MISSING_VARS -gt 0 ]; then
    echo -e "${RED}Please set all required variables in .env file${NC}"
    exit 1
fi

echo -e "${GREEN}✓ All Firebase config variables loaded${NC}"
echo ""

# Check if index.html exists
if [ ! -f index.html ]; then
    echo -e "${RED}ERROR: index.html not found${NC}"
    exit 1
fi

# Create temporary deployment directory
DEPLOY_DIR="deploy-temp"
echo -e "${YELLOW}Creating temporary deployment directory...${NC}"
rm -rf "$DEPLOY_DIR"
mkdir "$DEPLOY_DIR"

# Copy index.html to deployment directory
cp index.html "$DEPLOY_DIR/index.html"
echo -e "${GREEN}✓ index.html copied to deployment directory${NC}"

# Inject Firebase configuration
echo -e "${YELLOW}Injecting Firebase configuration...${NC}"
cd "$DEPLOY_DIR"

# Use different sed syntax for macOS vs Linux
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/FIREBASE_API_KEY_PLACEHOLDER/$FIREBASE_API_KEY/g" index.html
    sed -i '' "s/FIREBASE_AUTH_DOMAIN_PLACEHOLDER/$FIREBASE_AUTH_DOMAIN/g" index.html
    sed -i '' "s/FIREBASE_PROJECT_ID_PLACEHOLDER/$FIREBASE_PROJECT_ID/g" index.html
    sed -i '' "s/FIREBASE_STORAGE_BUCKET_PLACEHOLDER/$FIREBASE_STORAGE_BUCKET/g" index.html
    sed -i '' "s/FIREBASE_MESSAGING_SENDER_ID_PLACEHOLDER/$FIREBASE_MESSAGING_SENDER_ID/g" index.html
    sed -i '' "s/FIREBASE_APP_ID_PLACEHOLDER/$FIREBASE_APP_ID/g" index.html
else
    # Linux
    sed -i "s/FIREBASE_API_KEY_PLACEHOLDER/$FIREBASE_API_KEY/g" index.html
    sed -i "s/FIREBASE_AUTH_DOMAIN_PLACEHOLDER/$FIREBASE_AUTH_DOMAIN/g" index.html
    sed -i "s/FIREBASE_PROJECT_ID_PLACEHOLDER/$FIREBASE_PROJECT_ID/g" index.html
    sed -i "s/FIREBASE_STORAGE_BUCKET_PLACEHOLDER/$FIREBASE_STORAGE_BUCKET/g" index.html
    sed -i "s/FIREBASE_MESSAGING_SENDER_ID_PLACEHOLDER/$FIREBASE_MESSAGING_SENDER_ID/g" index.html
    sed -i "s/FIREBASE_APP_ID_PLACEHOLDER/$FIREBASE_APP_ID/g" index.html
fi

echo -e "${GREEN}✓ Firebase configuration injected${NC}"

# Verify injection worked
if grep -q "PLACEHOLDER" index.html; then
    echo -e "${RED}ERROR: Placeholders still present after injection${NC}"
    grep "PLACEHOLDER" index.html
    cd ..
    rm -rf "$DEPLOY_DIR"
    exit 1
fi

echo -e "${GREEN}✓ Injection verified${NC}"
echo ""

# Get git remote URL
cd ..
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")

if [ -z "$REMOTE_URL" ]; then
    echo -e "${RED}ERROR: No git remote 'origin' found${NC}"
    echo "Please add a remote: git remote add origin <your-repo-url>"
    rm -rf "$DEPLOY_DIR"
    exit 1
fi

echo -e "${YELLOW}Remote URL: $REMOTE_URL${NC}"
echo ""

# Ask for confirmation
echo -e "${YELLOW}Ready to deploy to gh-pages branch${NC}"
read -p "Continue? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Deployment cancelled${NC}"
    rm -rf "$DEPLOY_DIR"
    exit 0
fi

# Deploy to gh-pages branch
echo -e "${YELLOW}Deploying to gh-pages branch...${NC}"
cd "$DEPLOY_DIR"

git init
git add index.html
git commit -m "Deploy to GitHub Pages - $(date)"
git branch -M gh-pages
git remote add origin "$REMOTE_URL"

# Force push to gh-pages
if git push -f origin gh-pages; then
    echo -e "${GREEN}✓ Deployment successful!${NC}"
else
    echo -e "${RED}ERROR: Deployment failed${NC}"
    echo "Check your git credentials and remote URL"
    cd ..
    rm -rf "$DEPLOY_DIR"
    exit 1
fi

# Cleanup
cd ..
rm -rf "$DEPLOY_DIR"

echo ""
echo "========================================"
echo -e "${GREEN}Deployment Complete!${NC}"
echo "========================================"
echo ""
echo "Your site should be available at:"
echo "https://YOUR_USERNAME.github.io/YOUR_REPO/"
echo ""
echo "Note: It may take 1-2 minutes for GitHub Pages to update"
echo ""
