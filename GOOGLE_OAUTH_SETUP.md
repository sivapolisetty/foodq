# 🔐 Google OAuth Setup for GraBeat Local Development

## Current Status

✅ **Google OAuth is now configured** in Supabase config  
✅ **Google logo asset** has been added  
✅ **Auth redirect URL** is properly set  
❌ **Google OAuth credentials** need to be configured  

## 🚀 Quick Setup Steps

### 1. Get Google OAuth Credentials

1. **Go to Google Cloud Console**: https://console.cloud.google.com/
2. **Create or select a project**
3. **Enable Google+ API**:
   - Navigate to "APIs & Services" > "Library"
   - Search for "Google+ API" 
   - Click "Enable"
4. **Create OAuth 2.0 Credentials**:
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "OAuth 2.0 Client IDs"
   - Choose "Web application"
   - Add authorized redirect URI: `http://127.0.0.1:58321/auth/v1/callback`

### 2. Configure Local Environment

Edit `/Users/sivapolisetty/vscode-workspace/claude_workspace/grabeat_new/supabase/.env`:

```env
# Replace with your actual Google OAuth credentials
GOOGLE_CLIENT_ID=your-actual-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-actual-client-secret
```

### 3. Restart Supabase

```bash
cd grabeat_new
supabase stop
supabase start
```

## 🔧 What's Already Configured

### ✅ Supabase Configuration
```toml
[auth.external.google]
enabled = true
client_id = "env(GOOGLE_CLIENT_ID)"
secret = "env(GOOGLE_CLIENT_SECRET)"
skip_nonce_check = true
redirect_uri = "http://127.0.0.1:58321/auth/v1/callback"
```

### ✅ Redirect URLs
- **Site URL**: `http://127.0.0.1:3000`
- **Additional redirect URLs**: `https://127.0.0.1:3000`
- **OAuth callback**: `http://127.0.0.1:58321/auth/v1/callback`

### ✅ Assets
- **Google logo**: `/mobile-client/assets/images/google_logo.png`

## 🧪 Testing Google OAuth

### 1. After Setting Up Credentials

1. **Start the development environment**:
   ```bash
   cd grabeat_new
   npm run dev
   ```

2. **Test Google sign-in**:
   - Open Flutter app at http://localhost:3000
   - Click "Sign in with Google"
   - Should redirect to Google OAuth flow
   - After authentication, should redirect back to app

### 2. Expected Flow

```
Flutter App → Google OAuth → Google Login → Callback → Supabase → Flutter App
```

### 3. Debug URLs

- **Flutter App**: http://localhost:3000
- **Supabase Studio**: http://127.0.0.1:58323
- **Auth callback**: http://127.0.0.1:58321/auth/v1/callback

## 🐛 Troubleshooting

### Issue: "OAuth client not found"
**Solution**: Double-check Google Client ID in `.env` file

### Issue: "Redirect URI mismatch"  
**Solution**: Ensure Google Console has exact URI: `http://127.0.0.1:58321/auth/v1/callback`

### Issue: "Google logo not loading"
**Solution**: Google logo is now fixed at `/assets/images/google_logo.png`

### Issue: "skip_nonce_check" errors
**Solution**: This is already set to `true` for local development

## 📱 For Production Deployment

When deploying to production:

1. **Update redirect URIs** in Google Console:
   ```
   https://your-production-domain.com/auth/callback
   https://your-supabase-project.supabase.co/auth/v1/callback
   ```

2. **Set production environment variables** in Cloudflare Pages:
   - `GOOGLE_CLIENT_ID`
   - `GOOGLE_CLIENT_SECRET`

3. **Update Supabase production config** with production OAuth settings

## 🎯 Current Auth Flow Status

- ✅ **Local Supabase**: Running with Google OAuth enabled
- ✅ **Auth configuration**: Properly set up
- ✅ **Redirect handling**: Configured for local development  
- ⏳ **Google credentials**: Waiting for your configuration
- ✅ **Flutter integration**: Ready to handle OAuth flow

Once you add the Google OAuth credentials to `/supabase/.env`, the Google sign-in should work perfectly! 🚀