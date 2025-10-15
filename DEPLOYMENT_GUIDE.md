# GitHub Pages Deployment Guide
## Single HTML File with Firebase Config Injection

---

## Executive Summary

This guide compares manual vs. automated GitHub Pages deployment strategies for single HTML files, with specific focus on securely injecting Firebase configuration using GitHub Actions.

**Quick Recommendation:**
- **MVP/Quick Start**: Manual deployment (simpler setup)
- **Production/Team Environment**: GitHub Actions automation (reliable, consistent, audit trail)

---

## Table of Contents
1. [Comparison Overview](#comparison-overview)
2. [Manual Deployment](#manual-deployment)
3. [Automated GitHub Actions Deployment](#automated-github-actions-deployment)
4. [Firebase Config Injection Methods](#firebase-config-injection-methods)
5. [Complete Workflow Examples](#complete-workflow-examples)
6. [Security Considerations](#security-considerations)
7. [Setup Instructions](#setup-instructions)
8. [Decision Framework](#decision-framework)

---

## Comparison Overview

### Manual vs. Automated Deployment

| Aspect | Manual Deployment | GitHub Actions Automation |
|--------|-------------------|---------------------------|
| **Setup Complexity** | Minimal (5 minutes) | Moderate (15-30 minutes) |
| **Deployment Speed** | Fast (push to branch) | Fast (automatic on push) |
| **Human Error Risk** | High (forgot to inject config, wrong branch) | Low (scripted, consistent) |
| **Audit Trail** | Git commits only | Full workflow logs + commits |
| **Secret Management** | Local environment variables | GitHub Secrets (encrypted) |
| **Team Collaboration** | Manual coordination needed | Automatic, standardized |
| **Rollback** | Manual git revert | Can rollback via git or re-run workflow |
| **Testing Before Deploy** | Manual checks | Can add automated tests in workflow |
| **Cost** | Free | Free (within GitHub Actions limits) |
| **Best For** | Solo dev, MVP, prototypes | Production, teams, frequent updates |

### Key Findings from Research

1. **Firebase API Key Safety**: Firebase API keys are **safe to expose** in client-side code. They identify your project, not authorize access. Real security comes from Firebase Security Rules and Firebase App Check.

2. **GitHub Actions Maturity**: The `peaceiris/actions-gh-pages@v4` action is battle-tested and supports single HTML file deployment seamlessly.

3. **Secret Injection**: Multiple methods exist (sed, envsubst, dedicated actions), with varying complexity levels.

---

## Manual Deployment

### Pros
- **Simplicity**: No workflow configuration needed
- **Immediate Control**: Developer explicitly triggers each deployment
- **No CI/CD Knowledge Required**: Just git commands
- **Quick Setup**: Works in 5 minutes

### Cons
- **Manual Steps**: Remember to inject config, build, push to correct branch
- **Human Error**: Forgot to update config, pushed to wrong branch
- **No Validation**: Can't enforce checks before deployment
- **Poor Audit Trail**: Only git commits, no deployment metadata

### Manual Deployment Process

```bash
# Step 1: Prepare your HTML file with placeholders
# In index.html, use placeholders like:
# const firebaseConfig = {
#   apiKey: "FIREBASE_API_KEY_PLACEHOLDER",
#   authDomain: "FIREBASE_AUTH_DOMAIN_PLACEHOLDER",
#   ...
# };

# Step 2: Create deployment script
cat > deploy-manual.sh << 'EOF'
#!/bin/bash
set -e

# Load environment variables
source .env

# Create temporary deployment directory
rm -rf deploy-temp
mkdir deploy-temp

# Copy and inject Firebase config into HTML
cp index.html deploy-temp/index.html
sed -i '' "s/FIREBASE_API_KEY_PLACEHOLDER/$FIREBASE_API_KEY/g" deploy-temp/index.html
sed -i '' "s/FIREBASE_AUTH_DOMAIN_PLACEHOLDER/$FIREBASE_AUTH_DOMAIN/g" deploy-temp/index.html
sed -i '' "s/FIREBASE_PROJECT_ID_PLACEHOLDER/$FIREBASE_PROJECT_ID/g" deploy-temp/index.html
sed -i '' "s/FIREBASE_STORAGE_BUCKET_PLACEHOLDER/$FIREBASE_STORAGE_BUCKET/g" deploy-temp/index.html
sed -i '' "s/FIREBASE_MESSAGING_SENDER_ID_PLACEHOLDER/$FIREBASE_MESSAGING_SENDER_ID/g" deploy-temp/index.html
sed -i '' "s/FIREBASE_APP_ID_PLACEHOLDER/$FIREBASE_APP_ID/g" deploy-temp/index.html

# Deploy to gh-pages branch
cd deploy-temp
git init
git add index.html
git commit -m "Deploy to GitHub Pages"
git branch -M gh-pages
git remote add origin git@github.com:YOUR_USERNAME/YOUR_REPO.git
git push -f origin gh-pages

# Cleanup
cd ..
rm -rf deploy-temp
echo "Deployed successfully to GitHub Pages!"
EOF

chmod +x deploy-manual.sh

# Step 3: Create .env file (DO NOT commit this!)
cat > .env << 'EOF'
FIREBASE_API_KEY=your_api_key_here
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id
EOF

# Step 4: Add .env to .gitignore
echo ".env" >> .gitignore

# Step 5: Run deployment
./deploy-manual.sh
```

### Alternative: Simple Manual Process (No Config Injection)

If Firebase API keys are hardcoded (safe for client-side):

```bash
# Just push directly to gh-pages branch
git checkout -b gh-pages
git add index.html
git commit -m "Deploy to GitHub Pages"
git push -u origin gh-pages

# Enable GitHub Pages in repo settings:
# Settings > Pages > Source: gh-pages branch > Save
```

---

## Automated GitHub Actions Deployment

### Pros
- **Consistency**: Same process every time, no human error
- **Automated**: Push to main branch, auto-deploys
- **Secret Management**: GitHub Secrets encrypted at rest
- **Audit Trail**: Full workflow logs for debugging
- **Team-Friendly**: Everyone uses same deployment process
- **Extensible**: Easy to add tests, linting, notifications

### Cons
- **Initial Setup**: Requires workflow configuration
- **Learning Curve**: Need to understand YAML, GitHub Actions
- **Debugging**: Workflow failures require log inspection
- **Dependency**: Reliance on GitHub Actions availability (99.9% uptime)

---

## Firebase Config Injection Methods

### Method 1: sed (Simple, No Dependencies)

**Pros**: Built into Linux/Mac, no extra actions needed
**Cons**: Verbose for multiple variables, Mac/Linux syntax differences

```bash
sed -i 's/FIREBASE_API_KEY/${{ secrets.FIREBASE_API_KEY }}/g' index.html
```

**Note**: Use `-i ''` on Mac, `-i` on Linux.

### Method 2: envsubst (GNU Utility, Cleaner Syntax)

**Pros**: Designed for template substitution, cleaner
**Cons**: Requires GNU gettext, may need Docker action

```bash
# In HTML, use ${FIREBASE_API_KEY} syntax
export FIREBASE_API_KEY="${{ secrets.FIREBASE_API_KEY }}"
envsubst < index.html > index-output.html
```

### Method 3: GitHub Actions - envsubst Action

**Pros**: Cross-platform, no manual installation
**Cons**: Additional action dependency

```yaml
- name: Substitute environment variables
  uses: nowactions/envsubst@v2
  with:
    input: ./index.html
    output: ./index.html
  env:
    FIREBASE_API_KEY: ${{ secrets.FIREBASE_API_KEY }}
```

### Method 4: Inplace Environment Substitution Action

**Pros**: Handles multiple files, recursive search
**Cons**: Another dependency

```yaml
- name: Substitute variables
  uses: Slidem/inplace-envsubst-action@v1
  with:
    files: '*.html'
  env:
    FIREBASE_API_KEY: ${{ secrets.FIREBASE_API_KEY }}
```

### Recommended Approach

**For single HTML file**: Use **sed** (Method 1) for simplicity.
**For multiple files/complex projects**: Use **envsubst action** (Method 3).

---

## Complete Workflow Examples

### Option 1: Minimal Workflow with sed (Recommended for Single File)

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]
  workflow_dispatch:  # Allows manual triggering

permissions:
  contents: write  # Required to push to gh-pages branch

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Inject Firebase configuration
        run: |
          # Replace placeholders with actual values from secrets
          sed -i "s/FIREBASE_API_KEY_PLACEHOLDER/${{ secrets.FIREBASE_API_KEY }}/g" index.html
          sed -i "s/FIREBASE_AUTH_DOMAIN_PLACEHOLDER/${{ secrets.FIREBASE_AUTH_DOMAIN }}/g" index.html
          sed -i "s/FIREBASE_PROJECT_ID_PLACEHOLDER/${{ secrets.FIREBASE_PROJECT_ID }}/g" index.html
          sed -i "s/FIREBASE_STORAGE_BUCKET_PLACEHOLDER/${{ secrets.FIREBASE_STORAGE_BUCKET }}/g" index.html
          sed -i "s/FIREBASE_MESSAGING_SENDER_ID_PLACEHOLDER/${{ secrets.FIREBASE_MESSAGING_SENDER_ID }}/g" index.html
          sed -i "s/FIREBASE_APP_ID_PLACEHOLDER/${{ secrets.FIREBASE_APP_ID }}/g" index.html

          # Verify injection worked (optional)
          echo "Verifying Firebase config injection..."
          grep -q "${{ secrets.FIREBASE_PROJECT_ID }}" index.html && echo "✓ Config injected successfully" || exit 1

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./
          publish_branch: gh-pages
          force_orphan: true  # Clean history on gh-pages branch
```

### Option 2: Advanced Workflow with envsubst Action

```yaml
name: Deploy to GitHub Pages (Advanced)

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: write

jobs:
  deploy:
    runs-on: ubuntu-latest
    # Only deploy on push to main or manual trigger
    if: github.event_name == 'push' || github.event_name == 'workflow_dispatch'

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Validate HTML structure
        run: |
          # Optional: Add HTML validation here
          echo "Running HTML validation..."
          # Example: npm install -g html-validator-cli && html-validator --file=index.html

      - name: Substitute Firebase configuration
        uses: nowactions/envsubst@v2
        with:
          input: ./index.html
          output: ./index.html
        env:
          FIREBASE_API_KEY: ${{ secrets.FIREBASE_API_KEY }}
          FIREBASE_AUTH_DOMAIN: ${{ secrets.FIREBASE_AUTH_DOMAIN }}
          FIREBASE_PROJECT_ID: ${{ secrets.FIREBASE_PROJECT_ID }}
          FIREBASE_STORAGE_BUCKET: ${{ secrets.FIREBASE_STORAGE_BUCKET }}
          FIREBASE_MESSAGING_SENDER_ID: ${{ secrets.FIREBASE_MESSAGING_SENDER_ID }}
          FIREBASE_APP_ID: ${{ secrets.FIREBASE_APP_ID }}

      - name: Verify configuration
        run: |
          echo "Checking if Firebase config was injected..."
          if grep -q "FIREBASE_API_KEY_PLACEHOLDER" index.html; then
            echo "❌ Error: Placeholders still present!"
            exit 1
          fi
          echo "✓ Configuration injected successfully"

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./
          publish_branch: gh-pages
          user_name: 'github-actions[bot]'
          user_email: 'github-actions[bot]@users.noreply.github.com'
          commit_message: 'Deploy: ${{ github.event.head_commit.message }}'
          force_orphan: true

      - name: Notify deployment status
        if: success()
        run: |
          echo "🚀 Deployment successful!"
          echo "Site URL: https://${{ github.repository_owner }}.github.io/${{ github.event.repository.name }}/"
```

### Option 3: Official GitHub Pages Action (Modern Approach)

```yaml
name: Deploy to GitHub Pages (Official)

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

# Prevent concurrent deployments
concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Inject Firebase configuration
        run: |
          sed -i "s/FIREBASE_API_KEY_PLACEHOLDER/${{ secrets.FIREBASE_API_KEY }}/g" index.html
          sed -i "s/FIREBASE_AUTH_DOMAIN_PLACEHOLDER/${{ secrets.FIREBASE_AUTH_DOMAIN }}/g" index.html
          sed -i "s/FIREBASE_PROJECT_ID_PLACEHOLDER/${{ secrets.FIREBASE_PROJECT_ID }}/g" index.html
          sed -i "s/FIREBASE_STORAGE_BUCKET_PLACEHOLDER/${{ secrets.FIREBASE_STORAGE_BUCKET }}/g" index.html
          sed -i "s/FIREBASE_MESSAGING_SENDER_ID_PLACEHOLDER/${{ secrets.FIREBASE_MESSAGING_SENDER_ID }}/g" index.html
          sed -i "s/FIREBASE_APP_ID_PLACEHOLDER/${{ secrets.FIREBASE_APP_ID }}/g" index.html

      - name: Setup Pages
        uses: actions/configure-pages@v4

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: '.'

      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

---

## Security Considerations

### Firebase API Key Exposure

**Key Finding**: **It is SAFE to expose Firebase API keys in client-side code.**

#### Why It's Safe

1. **Identification, Not Authorization**: Firebase API keys only identify your Firebase project, they don't grant access to data.

2. **Security Through Other Layers**:
   - **Firebase Security Rules**: Control who can read/write data
   - **Firebase Authentication**: Verify user identity
   - **Firebase App Check**: Limit access to registered apps only

3. **Official Google Guidance**: Firebase documentation explicitly states API keys can be embedded in client code.

#### What's NOT Safe

❌ **FCM Server Keys** (legacy Firebase Cloud Messaging HTTP API) - Keep secret!
❌ **Service Account Private Keys** (Firebase Admin SDK) - Keep secret!
❌ **Database passwords, OAuth client secrets** - Never expose!

### Best Practices

1. **Apply API Restrictions**:
   - Go to Google Cloud Console > Credentials
   - Restrict API key to specific referrers (e.g., `*.github.io/*`)
   - Restrict to specific APIs only

2. **Enable Firebase App Check**:
   ```javascript
   import { initializeApp } from 'firebase/app';
   import { initializeAppCheck, ReCaptchaV3Provider } from 'firebase/app-check';

   const app = initializeApp(firebaseConfig);
   const appCheck = initializeAppCheck(app, {
     provider: new ReCaptchaV3Provider('your-recaptcha-site-key'),
     isTokenAutoRefreshEnabled: true
   });
   ```

3. **Configure Security Rules**:
   ```javascript
   // Firestore example
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

4. **Monitor Usage**:
   - Set up Firebase alerts for unusual activity
   - Check Firebase Console > Usage tabs regularly
   - Enable billing alerts to prevent abuse

### GitHub Secrets Security

- **Encrypted at Rest**: GitHub encrypts secrets using libsodium sealed boxes
- **Redacted in Logs**: Secrets are automatically redacted in workflow logs
- **Access Control**: Only workflows in the repository can access secrets
- **Environment Protection**: Can require manual approval before accessing secrets

---

## Setup Instructions

### Prerequisites

1. GitHub repository with your HTML file
2. Firebase project with configuration
3. GitHub account with repository access

### Step 1: Prepare Your HTML File

Update `index.html` to use placeholders:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My App</title>
</head>
<body>
    <div id="app"></div>

    <script type="module">
        import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js';

        const firebaseConfig = {
            apiKey: "FIREBASE_API_KEY_PLACEHOLDER",
            authDomain: "FIREBASE_AUTH_DOMAIN_PLACEHOLDER",
            projectId: "FIREBASE_PROJECT_ID_PLACEHOLDER",
            storageBucket: "FIREBASE_STORAGE_BUCKET_PLACEHOLDER",
            messagingSenderId: "FIREBASE_MESSAGING_SENDER_ID_PLACEHOLDER",
            appId: "FIREBASE_APP_ID_PLACEHOLDER"
        };

        const app = initializeApp(firebaseConfig);
        console.log('Firebase initialized:', app.name);
    </script>
</body>
</html>
```

### Step 2: Configure GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** > **Secrets and variables** > **Actions**
3. Click **New repository secret**
4. Add each Firebase configuration value:

| Secret Name | Example Value |
|-------------|---------------|
| `FIREBASE_API_KEY` | `AIzaSyC9X... (your API key)` |
| `FIREBASE_AUTH_DOMAIN` | `myproject.firebaseapp.com` |
| `FIREBASE_PROJECT_ID` | `myproject-12345` |
| `FIREBASE_STORAGE_BUCKET` | `myproject.appspot.com` |
| `FIREBASE_MESSAGING_SENDER_ID` | `123456789012` |
| `FIREBASE_APP_ID` | `1:123456789012:web:abc...` |

**Note**: `GITHUB_TOKEN` is automatically provided, no setup needed.

### Step 3: Create Workflow File

```bash
# Create directory structure
mkdir -p .github/workflows

# Create workflow file (choose one from examples above)
cat > .github/workflows/deploy.yml << 'EOF'
# Paste your chosen workflow here
EOF

# Commit and push
git add .github/workflows/deploy.yml
git commit -m "Add GitHub Actions deployment workflow"
git push origin main
```

### Step 4: Enable GitHub Pages

**For peaceiris/actions-gh-pages**:
1. Go to **Settings** > **Pages**
2. Source: **Deploy from a branch**
3. Branch: **gh-pages** > **/ (root)**
4. Click **Save**

**For official deploy-pages action**:
1. Go to **Settings** > **Pages**
2. Source: **GitHub Actions**
3. No branch selection needed (workflow handles it)

### Step 5: Trigger Deployment

**Automatic**: Push to main branch
```bash
git add index.html
git commit -m "Update app"
git push origin main
```

**Manual**: Go to **Actions** > **Deploy to GitHub Pages** > **Run workflow**

### Step 6: Verify Deployment

1. Check workflow status in **Actions** tab
2. Wait for completion (usually 30-60 seconds)
3. Visit your site: `https://YOUR_USERNAME.github.io/YOUR_REPO/`
4. Inspect page source to verify Firebase config was injected

---

## Decision Framework

### Choose Manual Deployment If:

✅ Solo developer or small team
✅ Infrequent deployments (once a week or less)
✅ Need immediate, ad-hoc control
✅ Comfortable with git and shell scripts
✅ MVP or prototype stage
✅ Want minimal setup time

### Choose GitHub Actions If:

✅ Team of 2+ developers
✅ Frequent deployments (multiple times per day)
✅ Want consistent, repeatable process
✅ Need audit trail and workflow logs
✅ Production application
✅ Want to add automated tests/validation
✅ Need integration with other CI/CD tools

### Migration Path

**Start Manual → Transition to Automated**

1. **Week 1-2**: Manual deployment, validate workflow
2. **Week 3**: Create GitHub Actions workflow (test in parallel)
3. **Week 4**: Switch to automated, keep manual script as backup
4. **Month 2+**: Remove manual script, full automation

---

## Troubleshooting

### Common Issues

#### 1. Workflow Fails: "Permission denied"

**Problem**: Missing `contents: write` permission

**Solution**:
```yaml
permissions:
  contents: write  # Add this to workflow
```

#### 2. Placeholders Still Visible in Deployed Site

**Problem**: sed replacement didn't work

**Solution**:
- Check secret names match exactly
- Verify placeholders in HTML match sed pattern
- Add verification step to workflow:
  ```bash
  grep "PLACEHOLDER" index.html && exit 1 || echo "OK"
  ```

#### 3. GitHub Pages Shows 404

**Problem**: Wrong branch or directory configured

**Solution**:
- Check Settings > Pages > Source is set to `gh-pages` branch
- For official action, set Source to "GitHub Actions"
- Verify `publish_dir` in workflow is correct

#### 4. Firebase Error: "Invalid API Key"

**Problem**: API key not properly injected

**Solution**:
- Check GitHub Secrets have correct values
- Verify no extra spaces in secret values
- Test locally with manual deployment first

#### 5. Workflow Runs But Doesn't Deploy

**Problem**: Missing `if` condition or wrong trigger

**Solution**:
```yaml
on:
  push:
    branches: [main]  # Ensure branch name matches
```

---

## Cost Analysis

| Aspect | Manual | GitHub Actions |
|--------|--------|----------------|
| GitHub Actions Minutes | 0 | ~1-2 minutes per deployment |
| Free Tier Limit | N/A | 2,000 minutes/month (free for public repos) |
| Storage | Git repo only | Git repo + Actions cache |
| Additional Costs | $0 | $0 (within free tier) |

**Verdict**: Both options are **free** for public repositories.

---

## Performance Comparison

| Metric | Manual | GitHub Actions |
|--------|--------|----------------|
| Time to Deploy (after push) | ~30 seconds | ~60-90 seconds |
| Setup Time | ~5 minutes | ~15-30 minutes |
| Maintenance | Low (update script occasionally) | Very Low (workflow mostly stable) |

---

## Recommendations by Scenario

### Scenario 1: Personal Portfolio Site
- **Audience**: Just you
- **Update Frequency**: Once a month
- **Recommendation**: **Manual Deployment**
- **Rationale**: Simple, fast setup, no need for automation overhead

### Scenario 2: Open Source Project Demo
- **Audience**: Community contributors
- **Update Frequency**: Weekly or more
- **Recommendation**: **GitHub Actions**
- **Rationale**: Standardized process, contributors can deploy via PR merges

### Scenario 3: Client Project MVP
- **Audience**: Client + small dev team
- **Update Frequency**: Daily during development
- **Recommendation**: **GitHub Actions**
- **Rationale**: Professional, consistent, easy client demos on every push

### Scenario 4: Internal Tool Prototype
- **Audience**: 1-2 developers
- **Update Frequency**: Ad-hoc
- **Recommendation**: **Manual Deployment** initially, transition to **GitHub Actions** if used long-term
- **Rationale**: Start simple, automate if it becomes permanent

---

## Additional Resources

### Official Documentation
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Firebase Security Documentation](https://firebase.google.com/docs/rules)
- [peaceiris/actions-gh-pages Repository](https://github.com/peaceiris/actions-gh-pages)

### Security
- [Firebase API Key Security](https://firebase.google.com/docs/projects/api-keys)
- [GitHub Actions Security Best Practices](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [Firebase App Check](https://firebase.google.com/docs/app-check)

### Community Resources
- [GitHub Actions Community Forum](https://github.community/c/code-to-cloud/github-actions/41)
- [Stack Overflow - GitHub Actions Tag](https://stackoverflow.com/questions/tagged/github-actions)

---

## Conclusion

**For your single HTML file deployment:**

1. **If starting fresh**: Use **GitHub Actions with sed injection** (Option 1 workflow)
2. **If already deploying manually**: Continue for now, plan migration to GitHub Actions within 1-2 weeks
3. **Firebase config**: Safe to expose API keys, but enable App Check and Security Rules for production

**Key Takeaway**: GitHub Actions provides the best long-term solution for consistency, security, and team collaboration, with minimal additional complexity over manual deployment.

---

## Quick Start Commands

### Manual Deployment (Right Now)
```bash
# 1. Create deploy script (see Manual Deployment section)
# 2. Add .env file with Firebase config
# 3. Run deployment
./deploy-manual.sh
```

### GitHub Actions (Recommended)
```bash
# 1. Add secrets to GitHub repo (Settings > Secrets)
# 2. Create workflow file
mkdir -p .github/workflows
# Copy Option 1 workflow into .github/workflows/deploy.yml
# 3. Commit and push
git add .github/workflows/deploy.yml
git commit -m "Add deployment workflow"
git push origin main
# 4. Enable GitHub Pages (Settings > Pages > Source: gh-pages)
```

---

**Document Version**: 1.0
**Last Updated**: 2025-10-15
**Author**: Claude (Anthropic)
**Based on**: Official GitHub/Firebase documentation + community best practices
