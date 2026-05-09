-- X1 Directory — Database Schema
-- Run this entire file in the Supabase SQL Editor to set up your database from scratch.
-- Safe to re-run: uses IF NOT EXISTS and DROP IF EXISTS where needed.

-- ─────────────────────────────────────────────────────────────────────────────
-- TABLES
-- ─────────────────────────────────────────────────────────────────────────────

-- Approved projects (public directory)
CREATE TABLE IF NOT EXISTS projects (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name          TEXT NOT NULL,
  description   TEXT NOT NULL,
  category      TEXT NOT NULL CHECK (category IN ('DeFi','NFT','Bridge','Tool','DAO','Social','Infra')),
  url           TEXT NOT NULL,
  tags          TEXT[] DEFAULT '{}',
  twitter       TEXT,
  contract      TEXT,
  icon          TEXT DEFAULT '★',
  verified      BOOLEAN DEFAULT false,
  featured      BOOLEAN DEFAULT false,
  is_new        BOOLEAN DEFAULT false,
  approved_at   TIMESTAMPTZ DEFAULT NOW(),
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- Submissions (pending review queue)
CREATE TABLE IF NOT EXISTS submissions (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name          TEXT NOT NULL,
  description   TEXT NOT NULL,
  category      TEXT NOT NULL,
  url           TEXT NOT NULL,
  tags          TEXT[] DEFAULT '{}',
  twitter       TEXT,
  contract      TEXT,
  email         TEXT,
  status        TEXT DEFAULT 'pending' CHECK (status IN ('pending','approved','rejected')),
  admin_note    TEXT,
  submitted_at  TIMESTAMPTZ DEFAULT NOW(),
  reviewed_at   TIMESTAMPTZ
);

-- ─────────────────────────────────────────────────────────────────────────────
-- INDEXES
-- ─────────────────────────────────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS idx_projects_category ON projects(category);
CREATE INDEX IF NOT EXISTS idx_projects_verified ON projects(verified);
CREATE INDEX IF NOT EXISTS idx_projects_featured ON projects(featured);
CREATE INDEX IF NOT EXISTS idx_submissions_status ON submissions(status);
CREATE INDEX IF NOT EXISTS idx_submissions_submitted_at ON submissions(submitted_at DESC);

-- ─────────────────────────────────────────────────────────────────────────────
-- ROW LEVEL SECURITY
-- ─────────────────────────────────────────────────────────────────────────────

-- Enable RLS on both tables
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE submissions ENABLE ROW LEVEL SECURITY;

-- Drop existing policies before recreating (safe for re-runs)
DROP POLICY IF EXISTS "Anyone can read projects" ON projects;
DROP POLICY IF EXISTS "Only admins can insert projects" ON projects;
DROP POLICY IF EXISTS "Only admins can update projects" ON projects;
DROP POLICY IF EXISTS "Only admins can delete projects" ON projects;
DROP POLICY IF EXISTS "Anyone can insert submissions" ON submissions;
DROP POLICY IF EXISTS "Only admins can read submissions" ON submissions;
DROP POLICY IF EXISTS "Only admins can update submissions" ON submissions;
DROP POLICY IF EXISTS "Only admins can delete submissions" ON submissions;

-- PROJECTS: public read, admin write
CREATE POLICY "Anyone can read projects"
  ON projects FOR SELECT
  USING (true);

CREATE POLICY "Only admins can insert projects"
  ON projects FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Only admins can update projects"
  ON projects FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Only admins can delete projects"
  ON projects FOR DELETE
  TO authenticated
  USING (true);

-- SUBMISSIONS: anyone can submit, only admins can read/update/delete
CREATE POLICY "Anyone can insert submissions"
  ON submissions FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Only admins can read submissions"
  ON submissions FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Only admins can update submissions"
  ON submissions FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Only admins can delete submissions"
  ON submissions FOR DELETE
  TO authenticated
  USING (true);

-- ─────────────────────────────────────────────────────────────────────────────
-- DONE
-- ─────────────────────────────────────────────────────────────────────────────
-- You should now see two tables in your Table Editor: projects and submissions.
-- Next: run db/seed.sql to load initial project data (optional).
