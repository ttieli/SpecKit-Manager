# Deployment Guide (部署指南)

**Feature**: Auto-Persistence & Enhanced Project Visualization
**Branch**: `008-1-html-json`
**Date**: 2025-10-15

---

## 📋 Pre-Deployment Checklist

Before deploying to production, ensure you have completed:

- [x] **Phase 1-7**: All MVP features implemented and tested
- [x] **Phase 8 (T043-T045)**: Polish completed
  - [x] T043: Input sanitization (XSS prevention)
  - [x] T044: Error logging
  - [x] T045: Loading states and spinners
- [ ] **Phase 8 (T046-T047)**: Security configuration (manual steps below)
- [ ] **Phase 8 (T048)**: GitHub Pages deployment

---

## 🔒 T046: Configure Firebase App Check

Firebase App Check protects your backend resources from abuse by ensuring requests come from your authentic app.

### Step 1: Enable App Check in Firebase Console

1. Go to https://console.firebase.google.com/
2. Select your project: **speckit-project-manager**
3. Navigate to **Build → App Check**
4. Click **Get started**

### Step 2: Register Web App

1. Click **Add app** → Select **Web**
2. Choose **reCAPTCHA v3** (recommended for web apps)
3. Click **Register**
4. Copy the reCAPTCHA site key (you'll need this)

### Step 3: Update index.html

Add the following code to `index.html` in the Firebase initialization section:

```html
<!-- Add to Firebase SDK imports -->
<script type="module">
    import { initializeAppCheck, ReCaptchaV3Provider } from
        'https://www.gstatic.com/firebasejs/12.4.0/firebase-app-check.js';

    // Initialize App Check after Firebase app
    const appCheck = initializeAppCheck(window.firebase.app, {
        provider: new ReCaptchaV3Provider('YOUR_RECAPTCHA_SITE_KEY'),
        isTokenAutoRefreshEnabled: true
    });

    window.firebase.appCheck = appCheck;
</script>
```

### Step 4: Enforce App Check

Back in Firebase Console:

1. Navigate to **App Check → APIs**
2. Select **Realtime Database**
3. Toggle **Enforce** to ON
4. Save changes

**⚠️ Warning**: Only enforce after verifying App Check works in your deployed app, or legitimate requests will be blocked!

---

## 💰 T047: Set API Quota Limits

Protect your Firebase project from unexpected costs by setting quota limits.

### Step 1: Configure Realtime Database Limits

1. Go to **Firebase Console → Realtime Database**
2. Click on **Usage** tab
3. Set the following limits:

   **Recommended Limits**:
   - **Concurrent Connections**: 100 (adjust based on expected users)
   - **Stored Data**: 1 GB (free tier limit)
   - **Downloads/Month**: 10 GB (free tier limit)
   - **Bandwidth**: 360 MB/day average

### Step 2: Configure Firebase Authentication Limits

1. Go to **Firebase Console → Authentication**
2. Click on **Usage** tab
3. Monitor:
   - **MAU (Monthly Active Users)**: Free tier allows 50,000
   - **Phone Auth**: Free tier allows 10,000/month

### Step 3: Set Budget Alerts (Optional but Recommended)

1. Go to **Google Cloud Console**: https://console.cloud.google.com/
2. Select your project
3. Navigate to **Billing → Budgets & alerts**
4. Click **Create budget**
5. Set budget amount (e.g., $10/month)
6. Configure alerts at 50%, 90%, 100%

### Step 4: Enable Billing Caps (Optional)

For maximum cost protection:

1. In **Google Cloud Console → Billing**
2. Set **Daily spending limit**
3. Enable **Spending alerts**

---

## 🚀 T048: Deploy to GitHub Pages

Deploy your Spec Kit application to GitHub Pages for free hosting.

### Option A: Deploy from Repository (Recommended)

#### Step 1: Push Code to GitHub

```bash
# Make sure you're on the 008-1-html-json branch
git checkout 008-1-html-json

# Commit all changes
git add .
git commit -m "feat: complete Phase 8 - Production ready with security enhancements"

# Push to GitHub
git push origin 008-1-html-json
```

#### Step 2: Enable GitHub Pages

1. Go to your GitHub repository
2. Navigate to **Settings → Pages**
3. Under **Source**, select:
   - **Branch**: `008-1-html-json`
   - **Folder**: `/ (root)`
4. Click **Save**

#### Step 3: Wait for Deployment

GitHub will automatically deploy your site. You can monitor progress in:
- **Actions** tab → Latest workflow run

#### Step 4: Access Your Deployed App

Your app will be available at:
```
https://<your-username>.github.io/<repository-name>/
```

### Option B: Deploy with Custom Domain (Optional)

1. **Purchase a domain** (e.g., from Cloudflare, Namecheap)
2. **Add CNAME file** to repository root:
   ```bash
   echo "your-domain.com" > CNAME
   git add CNAME
   git commit -m "Add custom domain"
   git push
   ```
3. **Configure DNS**:
   - Add **A records** pointing to GitHub Pages IPs:
     - `185.199.108.153`
     - `185.199.109.153`
     - `185.199.110.153`
     - `185.199.111.153`
   - Add **CNAME record**: `www` → `<your-username>.github.io`

4. **Enable HTTPS** in **Settings → Pages → Enforce HTTPS**

---

## 🔧 Post-Deployment Configuration

### Update Firebase Authorized Domains

1. Go to **Firebase Console → Authentication → Settings**
2. Scroll to **Authorized domains**
3. Add your GitHub Pages domain:
   - `<your-username>.github.io`
   - (Or your custom domain)
4. Click **Add domain**

### Update CORS Settings (If Needed)

If you encounter CORS issues:

1. Firebase Console → **Realtime Database → Rules**
2. Ensure rules allow your domain

---

## 🧪 Post-Deployment Testing

After deployment, test the following:

### 1. Authentication Flow
- [ ] User registration works
- [ ] User login works
- [ ] Session persistence across page reloads
- [ ] Logout works correctly

### 2. Data Persistence
- [ ] Projects save to Firebase
- [ ] Projects load from Firebase
- [ ] Real-time sync works across tabs
- [ ] Offline queue works when disconnected

### 3. Security Features
- [ ] App Check is enforcing (if enabled)
- [ ] Input sanitization prevents XSS
- [ ] Error logs are being stored
- [ ] Loading states display correctly

### 4. Performance
- [ ] Initial page load < 3 seconds
- [ ] Firebase operations < 500ms
- [ ] UI interactions feel responsive

---

## 📊 Monitoring & Maintenance

### Monitor Firebase Usage

1. **Daily Checks**:
   - Firebase Console → **Usage dashboard**
   - Check for unusual spikes in:
     - Concurrent connections
     - Bandwidth usage
     - Storage

2. **Weekly Checks**:
   - Review error logs in localStorage:
     ```javascript
     JSON.parse(localStorage.getItem('speckit_error_logs'))
     ```
   - Check Firebase Console → **Authentication → Users** for anomalies

3. **Monthly Checks**:
   - Review total costs in Google Cloud Billing
   - Optimize Firebase security rules if needed
   - Clean up old/inactive users

### Rollback Procedure

If you encounter issues after deployment:

```bash
# Roll back to previous working version
git revert HEAD
git push origin 008-1-html-json

# Or switch to a previous commit
git reset --hard <previous-commit-sha>
git push --force origin 008-1-html-json
```

---

## 🎯 Production Checklist

Before marking deployment as complete:

- [ ] **T046**: Firebase App Check enabled and verified
- [ ] **T047**: API quota limits configured with alerts
- [ ] **T048**: Deployed to GitHub Pages and accessible
- [ ] Firebase authorized domains updated
- [ ] Post-deployment tests passed (authentication, data, security)
- [ ] Monitoring dashboard bookmarked
- [ ] Team notified of production URL

---

## 🆘 Troubleshooting

### Issue: "App Check verification failed"

**Solution**:
- Verify reCAPTCHA site key is correct in code
- Check domain is registered in reCAPTCHA console
- Disable "Enforce" temporarily in Firebase App Check

### Issue: "Firebase quota exceeded"

**Solution**:
- Check Firebase Console → Usage for limits
- Temporarily increase limits or upgrade plan
- Review code for inefficient Firebase queries

### Issue: "GitHub Pages not updating"

**Solution**:
- Clear GitHub Actions cache
- Force rebuild by making a dummy commit
- Check GitHub Pages settings are correct

### Issue: "Authentication not working on deployed site"

**Solution**:
- Add deployed domain to Firebase authorized domains
- Check browser console for CORS errors
- Verify Firebase config credentials are correct

---

## 📚 Additional Resources

- **Firebase App Check Docs**: https://firebase.google.com/docs/app-check
- **Firebase Pricing**: https://firebase.google.com/pricing
- **GitHub Pages Docs**: https://docs.github.com/en/pages
- **Realtime Database Security Rules**: https://firebase.google.com/docs/database/security

---

**Deployment Version**: 1.0
**Last Updated**: 2025-10-15
**Deployed By**: Claude Code (Sonnet 4.5)
