# Google Places API Setup Guide

## Prerequisites
You need a Google Cloud Platform account with billing enabled.

## Steps to Set Up Google Places API

### 1. Create or Select a Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Note your project ID

### 2. Enable the Places API
1. Navigate to **APIs & Services > Library**
2. Search for "Places API"
3. Click on **Places API**
4. Click **Enable**

### 3. Create API Credentials
1. Go to **APIs & Services > Credentials**
2. Click **+ CREATE CREDENTIALS** > **API key**
3. Your API key will be created

### 4. Secure Your API Key (Recommended)
1. Click on your newly created API key
2. Under **Application restrictions**:
   - For development: Select **HTTP referrers (websites)**
   - Add your local development URLs:
     - `http://localhost:8788/*`
     - `http://localhost:8081/*`
   - For production, add your production domain
3. Under **API restrictions**:
   - Select **Restrict key**
   - Select **Places API** from the list
4. Click **Save**

### 5. Configure Your Local Environment

#### For Local Development:
Edit `wrangler.toml` and replace the placeholder with your API key:
```toml
GOOGLE_PLACES_API_KEY = "YOUR_ACTUAL_API_KEY_HERE"
```

#### For Production:
Set the secret using Wrangler CLI:
```bash
wrangler pages secret put GOOGLE_PLACES_API_KEY
# Enter your API key when prompted
```

### 6. Verify the Setup
After configuring the API key, restart your development server:
```bash
npm run dev
```

Test the endpoint:
```bash
curl 'http://localhost:8788/api/places/autocomplete?input=123%20main%20street&language=en&components=country:us'
```

## Troubleshooting

### "This API key is not authorized to use this service"
- Ensure the Places API is enabled in your Google Cloud project
- Check that your API key has the correct restrictions
- Wait a few minutes after enabling the API or creating the key

### "REQUEST_DENIED" errors
- Verify billing is enabled on your Google Cloud account
- Check the API key is correctly set in your environment
- Ensure no typos in the API key

### Rate Limiting
The Places API has usage quotas. Monitor your usage in the Google Cloud Console under **APIs & Services > Dashboard**.

## Cost Considerations
- Google provides $200 monthly credit for Maps APIs
- Place Autocomplete requests cost ~$2.83 per 1000 requests
- Monitor usage to avoid unexpected charges

## Security Best Practices
1. Never commit API keys to version control
2. Use different API keys for development and production
3. Restrict API keys by referrer/IP and API
4. Rotate keys periodically
5. Monitor usage for anomalies