# DNS Configuration Guide for foodqapp.com

## Prerequisites
- Access to Cloudflare dashboard
- Domain `foodqapp.com` already added to your Cloudflare account
- Deployments completed (✅ Already done)

## Step-by-Step DNS Configuration

### Step 1: Login to Cloudflare Dashboard
1. Go to https://dash.cloudflare.com
2. Select your account
3. Click on the `foodqapp.com` domain

### Step 2: Configure DNS Records

Navigate to **DNS → Records** in the left sidebar and add the following records:

#### A. Root Domain (foodqapp.com)
1. Click **Add record**
2. Configure:
   - **Type:** CNAME
   - **Name:** @ (or foodqapp.com)
   - **Target:** foodq-landing.pages.dev
   - **Proxy status:** Proxied (orange cloud ON)
   - **TTL:** Auto
3. Click **Save**

#### B. API Subdomain (api.foodqapp.com)
1. Click **Add record**
2. Configure:
   - **Type:** CNAME
   - **Name:** api
   - **Target:** foodq-api-router.sivapolisetty813.workers.dev
   - **Proxy status:** Proxied (orange cloud ON)
   - **TTL:** Auto
3. Click **Save**

#### C. Admin Subdomain (admin.foodqapp.com)
1. Click **Add record**
2. Configure:
   - **Type:** CNAME
   - **Name:** admin
   - **Target:** foodq-admin.pages.dev
   - **Proxy status:** Proxied (orange cloud ON)
   - **TTL:** Auto
3. Click **Save**

### Step 3: Configure Custom Domains in Pages Projects

#### For Landing Page (foodqapp.com):
1. Go to **Workers & Pages** in Cloudflare dashboard
2. Click on `foodq-landing` project
3. Go to **Settings** → **Custom domains**
4. Click **Set up a custom domain**
5. Enter: `foodqapp.com`
6. Click **Continue** → **Activate domain**

#### For Admin Portal (admin.foodqapp.com):
1. Go to **Workers & Pages** in Cloudflare dashboard
2. Click on `foodq-admin` project
3. Go to **Settings** → **Custom domains**
4. Click **Set up a custom domain**
5. Enter: `admin.foodqapp.com`
6. Click **Continue** → **Activate domain**

### Step 4: Configure Worker Route (for API)
1. Go to **Workers & Pages** → **Overview**
2. Click on `foodq-api-router` worker
3. Go to **Settings** → **Triggers**
4. Under **Custom Domains**, click **Add Custom Domain**
5. Enter: `api.foodqapp.com`
6. Click **Add Custom Domain**

## Verification Steps

### Immediate Verification (DNS Records)
```bash
# Check DNS records are saved
dig foodqapp.com
dig api.foodqapp.com
dig admin.foodqapp.com

# Check CNAME records specifically
dig CNAME foodqapp.com
dig CNAME api.foodqapp.com
dig CNAME admin.foodqapp.com
```

### After DNS Propagation (5-30 minutes with Cloudflare Proxy)
```bash
# Test root domain
curl -I https://foodqapp.com

# Test API subdomain
curl https://api.foodqapp.com/health

# Test admin subdomain
curl -I https://admin.foodqapp.com
```

## Expected DNS Records Table

| Type  | Name  | Content                                    | Proxy | TTL  |
|-------|-------|-------------------------------------------|-------|------|
| CNAME | @     | foodq-landing.pages.dev                  | ✅    | Auto |
| CNAME | api   | foodq-api-router.sivapolisetty813.workers.dev | ✅    | Auto |
| CNAME | admin | foodq-admin.pages.dev                    | ✅    | Auto |

## Troubleshooting

### Issue: Domain not resolving
**Solution:** Wait for DNS propagation (up to 24-48 hours globally, but usually 5-30 minutes with Cloudflare)

### Issue: SSL Certificate Error
**Solution:** 
1. Ensure Cloudflare proxy is enabled (orange cloud)
2. Go to SSL/TLS → Overview
3. Set encryption mode to "Full" or "Full (strict)"

### Issue: 404 Error on Custom Domain
**Solution:**
1. Verify custom domain is added in Pages project settings
2. Check deployment is successful
3. Verify DNS record points to correct target

### Issue: API Returns 500 Error
**Solution:** The worker needs to be updated to proxy mode (see api-proxy-worker.js)

## Quick Test Commands

```bash
# After DNS configuration, test all endpoints
echo "Testing Landing Page..."
curl -s -o /dev/null -w "%{http_code}" https://foodqapp.com
echo ""

echo "Testing Admin Portal..."
curl -s -o /dev/null -w "%{http_code}" https://admin.foodqapp.com
echo ""

echo "Testing API Health..."
curl -s https://api.foodqapp.com/health | jq '.'
echo ""

echo "Testing API Deals..."
curl -s https://api.foodqapp.com/deals | jq '.success'
```

## Timeline

1. **Immediate**: DNS records visible in Cloudflare dashboard
2. **5-30 minutes**: Domains start resolving (with Cloudflare proxy)
3. **1-4 hours**: Full global propagation
4. **24-48 hours**: Complete worldwide DNS propagation

## Next Steps After DNS Configuration

1. ✅ Test all domains are resolving
2. ✅ Verify SSL certificates are active
3. ✅ Test API endpoints through new domain
4. ✅ Update mobile app to use new endpoints
5. ✅ Monitor for any issues

## Support

If you encounter issues:
1. Check Cloudflare dashboard for DNS record status
2. Verify in **Workers & Pages** that custom domains are active
3. Use `dig` or `nslookup` to verify DNS resolution
4. Check browser developer console for specific errors