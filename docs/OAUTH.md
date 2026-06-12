# FreshBooks OAuth — get access token

Your Developer app redirect URI (registered):

```
https://branchlesspay.com/connect/freshbooks/callback
```

This is **correct** for BranchlessPay production. OAuth completes on BP server — not localhost.

---

## 1. `.env` must match Developer Portal

```env
FRESHBOOKS_CLIENT_ID=your_client_id
FRESHBOOKS_CLIENT_SECRET=your_client_secret
FRESHBOOKS_REDIRECT_URI=https://branchlesspay.com/connect/freshbooks/callback
```

All three must match what is saved in https://my.freshbooks.com/#/developer

---

## 2. Run authorize (BP redirect flow)

```powershell
cd Freshbook
powershell -ExecutionPolicy Bypass -File scripts\freshbooks_oauth.ps1
```

1. Browser opens FreshBooks login → **Authorize**
2. Browser redirects to `https://branchlesspay.com/connect/freshbooks/callback?code=...`
3. **Quickly copy** the `code=` value from the address bar (before page changes)
4. Paste into PowerShell when prompted
5. Script saves `ACCESS_TOKEN`, `REFRESH_TOKEN`, `ACCOUNT_ID` to `.env`

### Paste code directly (if you already have it)

```powershell
powershell -ExecutionPolicy Bypass -File scripts\freshbooks_oauth.ps1 -PasteCode "YOUR_CODE"
```

---

## 3. If you cannot see the code

The BP callback page may consume the code immediately. Email suhono@branchlesspay.com:

> OAuth redirect is `https://branchlesspay.com/connect/freshbooks/callback`.  
> Can you provide the authorization `code` or completed tokens for my FreshBooks app?

---

## 4. Local dev only (optional alternative)

If you also register in Developer Portal:

```
http://localhost:8765/oauth/callback
```

Then:

```env
FRESHBOOKS_REDIRECT_URI=http://localhost:8765/oauth/callback
```

Script will auto-capture callback locally (no paste needed).

---

## Refresh token

```powershell
powershell -ExecutionPolicy Bypass -File scripts\freshbooks_oauth.ps1 -Refresh
```

---

## Register webhooks after OAuth

```powershell
powershell -ExecutionPolicy Bypass -File scripts\register_freshbooks_webhook.ps1
```

Contact: suhono@branchlesspay.com
