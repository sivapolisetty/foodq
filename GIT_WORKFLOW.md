# Git Workflow for FoodQ Multi-Repo Setup

## Repository Structure
- **Root** (`foodqapp/`) → `grabeat` repo (backend, infrastructure)
- **Mobile** (`mobile-client/`) → `foodq-mobile-app` repo (Flutter app)

## Proper Commit Order ⚠️ IMPORTANT

### 1️⃣ **FIRST: Commit Mobile Changes**
```bash
cd mobile-client/
git add .
git commit -m "Mobile app changes"
git push origin main  # → foodq-mobile-app repo
```

### 2️⃣ **SECOND: Commit Root/Backend Changes**
```bash
cd ..  # back to root
git add functions/ admin-client/ *.md *.js
git commit -m "Backend/infrastructure changes"
git push origin main  # → grabeat repo
```

## Why This Order Matters
- Mobile changes are independent and should be versioned separately
- Root repo might reference mobile-client as a submodule/folder
- Committing mobile first ensures clean separation of concerns

## Quick Commands

### Mobile-only changes:
```bash
cd mobile-client && git add . && git commit -m "msg" && git push
```

### Backend-only changes:
```bash
git add functions/ admin-client/ && git commit -m "msg" && git push
```

### Full-stack changes:
```bash
# Mobile first
cd mobile-client && git add . && git commit -m "Mobile: msg" && git push

# Then backend
cd .. && git add functions/ admin-client/ && git commit -m "Backend: msg" && git push
```

## Current Status ✅
- Both repos are now in sync after expired deals fixes
- This workflow is established for future changes