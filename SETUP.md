# X1 Directory — Setup Guide

This document covers everything needed to deploy, run, and hand over the X1 Directory from scratch. A new owner should be able to follow this guide and have the site fully running in under an hour.

---

## What this project is

X1 Directory is a community-curated launchpad for dApps, tools, and projects built on the X1 blockchain. It has three parts:

- **Public directory** — anyone can browse and search approved projects
- **Submission form** — anyone can submit a project for review
- **Admin panel** — approved admins can review, approve, reject, and verify submissions

---

## Tech stack

| Layer | Tool | Why |
|-------|------|-----|
| Frontend | Plain HTML/CSS/JS | No build step, easy to edit |
| Hosting | Vercel | Free tier, instant deploys from GitHub |
| Database | Supabase (PostgreSQL) | Free tier, built-in auth, easy export |
| Auth | Supabase Auth | Secure admin login, no passwords in code |
| Security | Cloudflare | DDoS protection, rate limiting, DNS |

---

## Prerequisites

Before starting you will need free accounts at:

- [github.com](https://github.com) — code hosting
- [supabase.com](https://supabase.com) — database and auth
- [vercel.com](https://vercel.com) — deployment
- [cloudflare.com](https://cloudflare.com) — DNS and security (optional but recommended)

---

## Step 1 — Fork or clone the repo

If you are taking over from a previous owner, ask them to transfer the GitHub repository to your account directly. If you are starting fresh, clone this repo and push it to your own GitHub account.

```bash
git clone https://github.com/YOUR_USERNAME/x1-directory.git
cd x1-directory
```

---

## Step 2 — Create a Supabase project

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Choose a region close to your users
3. Save your database password somewhere safe — you only see it once
4. Wait for the project to finish provisioning (~2 minutes)

Once ready, go to **Settings → API** and copy:

- `Project URL` — this is your `SUPABASE_URL`
- `anon public` key — this is your `SUPABASE_ANON_KEY`

The `anon` key is **safe to ship in the browser**. All database access is controlled by Row-Level Security (RLS) policies — see `db/schema.sql`. Never put the `service_role` key in client code; it bypasses RLS and is admin-equivalent.

---

## Step 3 — Set up the database

In your Supabase project, go to **SQL Editor** and run the contents of `db/schema.sql`. This creates both tables, all indexes, and the RLS policies in one go.

Then run `db/seed.sql` if you want to start with the example projects already loaded.

To verify everything worked, go to **Table Editor** and confirm you can see the `projects` and `submissions` tables.

---

## Step 4 — Create your admin account

In Supabase, go to **Authentication → Users** and click **Invite user**. Enter your email address. You will receive a link to set your password. This is the account you will use to log into the admin panel.

To give admin access to additional people, add their email address the same way. Anyone signed in via Supabase Auth gets admin permissions through the RLS policies in `db/schema.sql`.

---

## Step 5 — Wire your Supabase keys into the site

This is a no-build static site, so the keys live directly in `public/index.html`. Open it and find these two lines near the top of the `<script>` block:

```js
const SUPABASE_URL = 'YOUR_SUPABASE_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
```

Replace the placeholders with the values you copied from Supabase **Settings → API**. Commit and push.

---

## Step 6 — Deploy to Vercel

1. Go to [vercel.com](https://vercel.com) and click **Add New Project**
2. Import your GitHub repository
3. Leave the framework preset as **Other** (this is a static site; `vercel.json` already points the deploy at `public/`)
4. Click **Deploy**

Vercel will give you a URL like `x1-directory.vercel.app`. The site is now live. Every push to your default branch will redeploy automatically.

---

## Step 7 — Connect your domain (optional but recommended)

1. Buy a domain from [Cloudflare Registrar](https://www.cloudflare.com/products/registrar/) or Namecheap
2. In Vercel, go to your project → **Settings → Domains** and add your domain
3. Update your domain's DNS nameservers to point to Cloudflare (if using Cloudflare)
4. In Cloudflare, add a CNAME record pointing to your Vercel deployment URL

Keep the domain registered in **your name or the project's name**, not tied to any personal account that might change hands later.

---

## Step 8 — Enable Cloudflare security (recommended)

Once your domain is on Cloudflare:

1. Turn on **DDoS protection** (on by default)
2. Go to **Security → WAF** and enable the free managed ruleset
3. Go to **Security → Rate Limiting** and add a rule capping requests to roughly 30 per minute per IP for your site

The submission form also has a built-in honeypot field that catches most automated bots before they hit Supabase.

---

## Handing the project over to someone new

Transferring the site to a new owner takes about 30 minutes. Here is the full checklist:

### 1. Transfer the GitHub repo
Go to your repo → **Settings → Danger Zone → Transfer ownership**. Enter the new owner's GitHub username.

### 2. Export the Supabase database
In your Supabase project, go to **Settings → Database → Backups** and download the latest backup. Alternatively run:

```bash
pg_dump "postgresql://postgres:[PASSWORD]@[HOST]:5432/postgres" > x1-directory-backup.sql
```

Send the `.sql` file to the new owner.

### 3. New owner: import the database
The new owner creates their own Supabase project and runs the backup SQL file in the SQL editor to restore all data.

### 4. New owner: wire in their own Supabase keys
The new owner edits `public/index.html` and replaces `SUPABASE_URL` / `SUPABASE_ANON_KEY` with values from their own Supabase project. They never need to know your keys.

### 5. New owner: create their admin account
The new owner creates a new user in Supabase Auth with their email. The old admin account can then be deleted from the previous owner's project (or that whole project can be deleted once the new one is verified).

### 6. Transfer or re-point the domain
If the domain is on Cloudflare, transfer the account or just update the Vercel CNAME in DNS to point to the new owner's deployment. The URL stays the same for end users.

### 7. Delete the old deployment
Once the new owner confirms everything is working, delete the old Vercel project to avoid any confusion.

---

## Folder structure

```
x1-directory/
├── public/
│   └── index.html          # Main site (directory, submit form, admin panel)
├── db/
│   ├── schema.sql          # Full database schema with RLS policies
│   └── seed.sql            # Optional: initial project data
├── .gitignore              # Prevents local / OS / secret files from being committed
├── vercel.json             # Vercel static deploy config (serves public/ at root)
└── SETUP.md                # This file
```

---

## Getting help

If you are stuck, the best resources are:

- [Supabase docs](https://supabase.com/docs) — thorough and well-maintained
- [Vercel docs](https://vercel.com/docs) — especially the static-site hosting section
- [Cloudflare docs](https://developers.cloudflare.com) — for DNS and rate limiting setup

For project-specific questions, open an issue on the GitHub repository.
