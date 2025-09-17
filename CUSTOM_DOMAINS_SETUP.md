# Custom Domains Setup Guide

## Part 1: Add Custom Domains to Pages Projects

### For Landing Page (foodqapp.com)
1. Go to **Cloudflare Dashboard** → **Workers & Pages**
2. Click on **foodq-landing** project
3. Go to **Settings** tab
4. Scroll to **Custom domains** section
5. Click **Set up a custom domain**
6. Enter: `foodqapp.com`
7. Click **Continue**
8. Click **Activate domain**

### For Admin Portal (admin.foodqapp.com)
1. Go to **Cloudflare Dashboard** → **Workers & Pages**
2. Click on **foodq-admin** project
3. Go to **Settings** tab
4. Scroll to **Custom domains** section
5. Click **Set up a custom domain**
6. Enter: `admin.foodqapp.com`
7. Click **Continue**
8. Click **Activate domain**

## Part 2: Add Custom Domain to Worker

### For API Worker (api.foodqapp.com)
1. Go to **Cloudflare Dashboard** → **Workers & Pages**
2. Click on **foodq-api-router** worker
3. Go to **Settings** tab
4. Scroll to **Triggers** section
5. Under **Custom Domains**, click **Add Custom Domain**
6. Enter: `api.foodqapp.com`
7. Click **Add Custom Domain**

## Verification Checklist

After completing the setup:

- [ ] DNS records added in Cloudflare
- [ ] Custom domain added to foodq-landing project
- [ ] Custom domain added to foodq-admin project
- [ ] Custom domain added to foodq-api-router worker
- [ ] All domains show "Active" status
- [ ] SSL certificates are provisioned

## Expected Status

All three domains should show:
- ✅ **Status:** Active
- ✅ **SSL:** Active
- ✅ **Edge Certificate:** Active

## Testing Commands

```bash
# Test all domains (run after setup)
curl -I https://foodqapp.com
curl -I https://admin.foodqapp.com
curl https://api.foodqapp.com/health
```