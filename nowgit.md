# Git Repositories - SpoilAlert

## Main App Repository

| Property | Value |
|----------|-------|
| **App Name** | SpoilAlert |
| **Description** | SpoilAlert - Skincare Expiry Tracker: Never use expired products again |
| **Git URL** | `git@github.com:asunnyboy861/SpoilAlert.git` |
| **Web URL** | https://github.com/asunnyboy861/SpoilAlert |
| **Visibility** | Public |
| **Created** | 2026-04-23T03:34:07Z |

### Repository Contents
- iOS App Source Code (Swift/SwiftUI)
- Xcode Project Files
- Documentation (us.md, price.md, capabilities.md, keytext.md, etc.)
- StoreKit Configuration (Products.storekit)
- App Icon Assets

---

## Policy Pages Repositories

**Note**: Policy pages are deployed via GitHub Pages for App Store compliance.

### Support Page
| Property | Value |
|----------|-------|
| **Repository** | `asunnyboy861/SpoilAlert-support` |
| **Git URL** | `git@github.com:asunnyboy861/SpoilAlert-support.git` |
| **Web URL** | https://github.com/asunnyboy861/SpoilAlert-support |
| **GitHub Pages** | https://asunnyboy861.github.io/SpoilAlert-support/ |
| **Status** | ⏳ To be created |

### Privacy Policy Page
| Property | Value |
|----------|-------|
| **Repository** | `asunnyboy861/SpoilAlert-privacy` |
| **Git URL** | `git@github.com:asunnyboy861/SpoilAlert-privacy.git` |
| **Web URL** | https://github.com/asunnyboy861/SpoilAlert-privacy |
| **GitHub Pages** | https://asunnyboy861.github.io/SpoilAlert-privacy/ |
| **Status** | ⏳ To be created |

### Terms of Use Page
| Property | Value |
|----------|-------|
| **Repository** | `asunnyboy861/SpoilAlert-terms` |
| **Git URL** | `git@github.com:asunnyboy861/SpoilAlert-terms.git` |
| **Web URL** | https://github.com/asunnyboy861/SpoilAlert-terms |
| **GitHub Pages** | https://asunnyboy861.github.io/SpoilAlert-terms/ |
| **Status** | ⏳ To be created |

---

## Git Configuration

### Local Repository
```bash
# Project Location
/Volumes/ORICO-APFS/app/20260423/SpoilAlert

# Remote Origin
git@github.com:asunnyboy861/SpoilAlert.git

# Default Branch
main
```

### Environment Variables
```bash
GITHUB_USER=asunnyboy861
GITHUB_TOKEN=*** (from .env)
CONTACT_EMAIL=iocompile67692@gmail.com
```

---

## Deployment Status

| Component | Repository | Deployed | URL |
|-----------|------------|----------|-----|
| Main App | SpoilAlert | ✅ | https://github.com/asunnyboy861/SpoilAlert |
| Support Page | SpoilAlert-support | ⏳ | https://asunnyboy861.github.io/SpoilAlert-support/ |
| Privacy Policy | SpoilAlert-privacy | ⏳ | https://asunnyboy861.github.io/SpoilAlert-privacy/ |
| Terms of Use | SpoilAlert-terms | ⏳ | https://asunnyboy861.github.io/SpoilAlert-terms/ |

---

## Quick Commands

```bash
# Load environment
set -a && source /Users/macmini4/.trae-cn/skills/ios-app-developer/.env && set +a

# Push main app
git add -A && git commit -m "Update" && git push

# Create policy repos
gh repo create ${GITHUB_USER}/SpoilAlert-support --public
gh repo create ${GITHUB_USER}/SpoilAlert-privacy --public
gh repo create ${GITHUB_USER}/SpoilAlert-terms --public

# Enable GitHub Pages
gh api repos/${GITHUB_USER}/SpoilAlert-support/pages -X POST -F source[branch]=main -F source[path]=/
gh api repos/${GITHUB_USER}/SpoilAlert-privacy/pages -X POST -F source[branch]=main -F source[path]=/
gh api repos/${GITHUB_USER}/SpoilAlert-terms/pages -X POST -F source[branch]=main -F source[path]=/
```

---

## Last Updated
2026-04-23
