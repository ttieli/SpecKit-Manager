# Quick Start Guide - GitHub Pages Deployment

## Choose Your Deployment Method

### 🚀 Option 1: GitHub Actions (Recommended)
**Best for**: Production, teams, automated deployments

#### Setup (5 minutes)

1. **Add Firebase secrets to GitHub**:
   - Go to your repo: `Settings` > `Secrets and variables` > `Actions`
   - Click `New repository secret`
   - Add these 6 secrets:

   ```
   FIREBASE_API_KEY              → Your Firebase API key
   FIREBASE_AUTH_DOMAIN          → your-project.firebaseapp.com
   FIREBASE_PROJECT_ID           → your-project-id
   FIREBASE_STORAGE_BUCKET       → your-project.appspot.com
   FIREBASE_MESSAGING_SENDER_ID  → 123456789012
   FIREBASE_APP_ID               → 1:123456789012:web:abc...
   ```

2. **Choose and activate a workflow**:

   Three workflows are available in `.github/workflows/`:
   - `deploy-simple.yml` - Basic deployment (recommended to start)
   - `deploy-official.yml` - Uses GitHub's official Pages action
   - `deploy-advanced.yml` - Includes validation and testing

   **Activate one workflow** by renaming it (remove others or keep disabled):
   ```bash
   # Keep only one active workflow
   mv .github/workflows/deploy-simple.yml .github/workflows/deploy.yml
   # Remove or disable others
   rm .github/workflows/deploy-official.yml
   rm .github/workflows/deploy-advanced.yml
   ```

3. **Enable GitHub Pages**:
   - Go to `Settings` > `Pages`
   - For `deploy-simple.yml` or `deploy-advanced.yml`:
     - Source: `Deploy from a branch`
     - Branch: `gh-pages` / `(root)`
   - For `deploy-official.yml`:
     - Source: `GitHub Actions`

4. **Deploy**:
   ```bash
   git add .
   git commit -m "Setup GitHub Actions deployment"
   git push origin main
   ```

5. **Done!** Check `Actions` tab for deployment status.
   - Your site: `https://YOUR_USERNAME.github.io/YOUR_REPO/`

---

### 🔧 Option 2: Manual Deployment
**Best for**: Quick tests, solo dev, learning

#### Setup (3 minutes)

1. **Create `.env` file**:
   ```bash
   cp .env.example .env
   # Edit .env with your Firebase values
   nano .env
   ```

2. **Add to .gitignore** (if not already):
   ```bash
   echo ".env" >> .gitignore
   ```

3. **Run deployment**:
   ```bash
   ./deploy-manual.sh
   ```

4. **Enable GitHub Pages**:
   - Go to `Settings` > `Pages`
   - Source: `Deploy from a branch`
   - Branch: `gh-pages` / `(root)`
   - Save

5. **Done!** Visit `https://YOUR_USERNAME.github.io/YOUR_REPO/`

---

## Get Firebase Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (or create new)
3. Click ⚙️ (Settings) > Project Settings
4. Scroll to "Your apps" section
5. Click on your web app (or create one with `+ Add app` > Web)
6. Copy the `firebaseConfig` values

---

## Update Your index.html

Replace hardcoded Firebase config with placeholders:

```html
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
</script>
```

**Or** use the provided `index-template.html` as a starting point.

---

## Troubleshooting

### GitHub Actions fails with "Permission denied"

**Solution**: Add workflow permissions
```yaml
permissions:
  contents: write
```

### Placeholders still visible on deployed site

**Solution**:
- Check GitHub Secrets are named exactly as shown
- Verify placeholders in HTML match sed patterns
- Check workflow logs for errors

### GitHub Pages shows 404

**Solution**:
- Wait 1-2 minutes after first deployment
- Check Settings > Pages is enabled
- Verify branch name matches workflow (`gh-pages`)

### Firebase error: "Invalid API key"

**Solution**:
- Check API key has no extra spaces
- Verify Firebase project is active
- Test API key locally first

---

## Comparison Table

| Feature | GitHub Actions | Manual |
|---------|---------------|--------|
| Setup time | 15 min | 3 min |
| Deploy time | 60 sec | 30 sec |
| Automation | ✅ | ❌ |
| Team-friendly | ✅ | ⚠️ |
| Error-prone | ❌ | ✅ |
| Best for | Production | Testing |

---

## Next Steps

After successful deployment:

1. **Test your site**: Visit deployment URL
2. **Check console**: Open browser DevTools > Console
3. **Verify Firebase**: Ensure no initialization errors
4. **Set up monitoring**: Firebase Console > Analytics

---

## Security Notes

✅ **Safe to expose**: Firebase API keys (client-side)
❌ **Keep secret**: FCM server keys, Admin SDK keys

**Recommended**: Enable Firebase App Check + Security Rules

See `DEPLOYMENT_GUIDE.md` for comprehensive security details.

---

## Resources

- 📖 Full guide: `DEPLOYMENT_GUIDE.md`
- 🔥 Firebase docs: https://firebase.google.com/docs
- 🐙 GitHub Actions: https://docs.github.com/actions
- 📄 Workflow examples: `.github/workflows/`

---

**Need Help?**
- Check `DEPLOYMENT_GUIDE.md` for detailed explanations
- Review workflow logs in GitHub Actions tab
- Test locally with `index-template.html`
