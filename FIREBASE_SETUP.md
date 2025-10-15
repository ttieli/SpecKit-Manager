# Firebase Setup Guide (Firebase 设置指南)

This guide will help you complete Phase 1 tasks (T001-T005) for setting up Firebase infrastructure.

## Prerequisites (前提条件)

- Google account (Gmail)
- Access to Firebase Console: https://console.firebase.google.com/

## Step-by-Step Instructions (分步说明)

### T001: Create Firebase Project (创建 Firebase 项目)

1. Go to https://console.firebase.google.com/
2. Click **"Add project"** (添加项目)
3. Project name: `SpecKit-Project-Manager` (or your preferred name)
4. Enable/Disable Google Analytics (optional, recommended: disable for faster setup)
5. Click **"Create project"**
6. Wait for project creation (~30 seconds)
7. Click **"Continue"** when done

**✅ Verification**: You should see the Firebase project overview dashboard.

---

### T002: Enable Firebase Authentication (启用 Firebase 身份验证)

1. In the left sidebar, click **"Build"** → **"Authentication"**
2. Click **"Get started"**
3. Go to **"Sign-in method"** tab
4. Click on **"Email/Password"**
5. Toggle **"Enable"** to ON
6. Leave **"Email link (passwordless sign-in)"** OFF
7. Click **"Save"**

**✅ Verification**: Email/Password should show "Enabled" status in the providers list.

---

### T003: Create Firebase Realtime Database (创建 Firebase 实时数据库)

1. In the left sidebar, click **"Build"** → **"Realtime Database"**
2. Click **"Create Database"**
3. **Database location**: Choose your region (e.g., `us-central1`, `asia-southeast1`)
   - Recommended for China/Asia users: `asia-southeast1` (Singapore)
   - Recommended for US/Europe users: `us-central1` (Iowa)
4. **Security rules**: Select **"Start in test mode"** (we'll update rules in T004)
5. Click **"Enable"**

**✅ Verification**:
- You should see the Realtime Database console
- The database URL should be visible (e.g., `https://your-project-default-rtdb.firebaseio.com/`)
- **Copy this URL** - you'll need it for `.env` file

---

### T004: Deploy Firebase Security Rules (部署 Firebase 安全规则)

1. In **Realtime Database** console, click on the **"Rules"** tab
2. **Delete** the existing test rules (everything in the editor)
3. **Copy** the following security rules:

```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    }
  }
}
```

4. **Paste** the rules into the editor
5. Click **"Publish"**
6. Confirm the warning (security rules will update)

**✅ Verification**:
- Rules should show "Last published" timestamp
- Test the rules using the **"Rules Playground"** button:
  - Location: `/users/test123`
  - Simulation type: `Read`
  - Authentication: Select "Unauthenticated"
  - Result should be: **"Denied"** (✅ correct)

**Security Rules Explanation (安全规则说明)**:
- Each user can only read/write their own data under `/users/{userId}`
- Unauthenticated users have no access
- Cross-user access is blocked

---

### T005: Get Firebase Config Credentials (获取 Firebase 配置凭证)

1. Click on the **gear icon** (⚙️) in the left sidebar → **"Project settings"**
2. Scroll down to **"Your apps"** section
3. If no web app exists:
   - Click **"</>"** (Web icon) to add a web app
   - App nickname: `SpecKit Web App`
   - **Do NOT** check "Also set up Firebase Hosting"
   - Click **"Register app"**
   - Click **"Continue to console"**
4. Find the **`firebaseConfig`** object (looks like this):

```javascript
const firebaseConfig = {
  apiKey: "AIzaSy...",
  authDomain: "your-project.firebaseapp.com",
  databaseURL: "https://your-project-default-rtdb.firebaseio.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456789012",
  appId: "1:123456789012:web:abcdef123456"
};
```

5. **Copy** these values
6. Open the `.env.example` file in this repository
7. Create a new file named **`.env`** (copy from `.env.example`)
8. Fill in the values from Firebase config:

```env
FIREBASE_API_KEY=AIzaSy...
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_DATABASE_URL=https://your-project-default-rtdb.firebaseio.com
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789012
FIREBASE_APP_ID=1:123456789012:web:abcdef123456
```

9. **Save** the `.env` file

**✅ Verification**:
- `.env` file exists in project root
- All 7 environment variables are filled in
- **Do NOT** commit `.env` to git (it's in `.gitignore`)

---

## Phase 1 Completion Checklist (阶段 1 完成检查清单)

- [ ] T001: Firebase project created
- [ ] T002: Email/Password authentication enabled
- [ ] T003: Realtime Database created with database URL copied
- [ ] T004: Security rules deployed and validated
- [ ] T005: `.env` file created with all 7 config values

**All complete?** You're ready to proceed to Phase 2! ✅

---

## Troubleshooting (故障排除)

### Issue: "Firebase project quota exceeded"
**Solution**: You've hit the free tier limit (10 Spark projects max). Delete unused projects or upgrade to Blaze plan.

### Issue: "Database URL not showing"
**Solution**: Make sure you created **Realtime Database**, not **Firestore**. They are different products.

### Issue: ".env file not being read"
**Solution**: This is expected. The `.env` file will be used in Phase 2 when we build the HTML file. For now, just ensure it exists and has correct values.

### Issue: "Security rules rejected"
**Solution**:
1. Verify JSON format is correct (no trailing commas)
2. Make sure you're in **Realtime Database Rules**, not **Firestore Rules**
3. Try publishing again

---

## Security Best Practices (安全最佳实践)

✅ **DO**:
- Keep `.env` file in `.gitignore`
- Use Firebase security rules as the primary access control
- Set up Firebase App Check before production deployment (Phase 8)

❌ **DON'T**:
- Commit `.env` to git
- Share your API credentials publicly
- Disable security rules (test mode rules expire after 30 days)

---

## Next Steps (下一步)

After completing Phase 1, you'll be ready to:
- **Phase 2**: Create `index.html` with Firebase SDK integration
- **Phase 3**: Implement user authentication UI
- **Phase 4**: Build auto-persistence features

**Time Estimate**: Phase 1 should take 15-30 minutes if following this guide.
