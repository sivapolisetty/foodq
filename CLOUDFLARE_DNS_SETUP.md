# Cloudflare DNS Configuration for foodqapp.com

## DNS Records to Add

Login to Cloudflare Dashboard → Select foodqapp.com → DNS → Records

### Required DNS Records:

| Type  | Name  | Content                                    | Proxy | TTL  |
|-------|-------|-------------------------------------------|-------|------|
| CNAME | @     | foodq-landing.pages.dev                  | ✅    | Auto |
| CNAME | api   | foodq-api-router.sivapolisetty813.workers.dev | ✅    | Auto |
| CNAME | admin | foodq-admin.pages.dev                    | ✅    | Auto |

### Step-by-Step Instructions:

#### 1. Root Domain (foodqapp.com → Landing Page)
1. Click **+ Add record**
2. **Type:** CNAME
3. **Name:** @ (or leave blank for root)
4. **Target:** `foodq-landing.pages.dev`
5. **Proxy status:** ✅ Proxied (orange cloud)
6. Click **Save**

#### 2. API Subdomain (api.foodqapp.com → API Worker)
1. Click **+ Add record**
2. **Type:** CNAME
3. **Name:** `api`
4. **Target:** `foodq-api-router.sivapolisetty813.workers.dev`
5. **Proxy status:** ✅ Proxied (orange cloud)
6. Click **Save**

#### 3. Admin Subdomain (admin.foodqapp.com → Admin Portal)
1. Click **+ Add record**
2. **Type:** CNAME
3. **Name:** `admin`
4. **Target:** `foodq-admin.pages.dev`
5. **Proxy status:** ✅ Proxied (orange cloud)
6. Click **Save**

## After Adding DNS Records

The records should look like this in your DNS dashboard:

```
foodqapp.com        CNAME   foodq-landing.pages.dev                     Proxied
api.foodqapp.com    CNAME   foodq-api-router.sivapolisetty813.workers.dev  Proxied
admin.foodqapp.com  CNAME   foodq-admin.pages.dev                      Proxied
```

## Next: Custom Domains

After DNS records are added, we need to:
1. Add custom domains to Pages projects
2. Add custom domain to Worker
3. Test all endpoints