-- ==============================================================================
-- AVTIVE PROFILES: COMPLETE SUPABASE DATABASE & STORAGE INITIALIZATION SCRIPT
-- Purpose: Consolidated, idempotent setup script for a new Supabase project.
-- Safe to run on empty databases or existing projects (uses IF NOT EXISTS).
-- ==============================================================================
-- Instructions:
-- 1. Open your Supabase Dashboard: https://supabase.com/dashboard/project/<YOUR_PROJECT_REF>
-- 2. Go to "SQL Editor" in the left sidebar.
-- 3. Click "New query", paste this entire script, and click "Run".
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. USERS TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.users (
  id TEXT PRIMARY KEY,
  name TEXT,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT,
  avatar_url TEXT,
  role TEXT,
  preferred_theme TEXT,
  onboarding_completed BOOLEAN DEFAULT FALSE,
  reset_token TEXT,
  reset_token_expires TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ensure all optional columns exist if table was previously created
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS preferred_theme TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS avatar_url TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS onboarding_completed BOOLEAN DEFAULT FALSE;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS reset_token TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS reset_token_expires TIMESTAMPTZ;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- ------------------------------------------------------------------------------
-- 2. PROFILES TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
  id TEXT PRIMARY KEY,
  user_id TEXT REFERENCES public.users(id) ON DELETE CASCADE,
  slug TEXT UNIQUE NOT NULL,
  name TEXT,
  email TEXT,
  designation TEXT DEFAULT 'Professional',
  company TEXT DEFAULT '',
  location TEXT DEFAULT '',
  avatar TEXT,
  cover_image TEXT,
  short_bio TEXT DEFAULT '',
  full_bio TEXT DEFAULT '',
  phone TEXT DEFAULT '',
  whatsapp TEXT DEFAULT '',
  website TEXT DEFAULT '',
  booking_url TEXT DEFAULT '',
  tagline TEXT DEFAULT '',
  type TEXT DEFAULT 'individual',
  theme TEXT DEFAULT 'editorial',
  skills JSONB DEFAULT '[]'::jsonb,
  socials JSONB DEFAULT '[]'::jsonb,
  services JSONB DEFAULT '{}'::jsonb,
  experiences JSONB DEFAULT '[]'::jsonb,
  projects JSONB DEFAULT '[]'::jsonb,
  certifications JSONB DEFAULT '[]'::jsonb,
  data JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ensure all profile columns exist if table was previously created with minimal schema
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS designation TEXT DEFAULT 'Professional';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS company TEXT DEFAULT '';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS location TEXT DEFAULT '';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS short_bio TEXT DEFAULT '';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS full_bio TEXT DEFAULT '';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS phone TEXT DEFAULT '';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS whatsapp TEXT DEFAULT '';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS website TEXT DEFAULT '';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS booking_url TEXT DEFAULT '';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS tagline TEXT DEFAULT '';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS skills JSONB DEFAULT '[]'::jsonb;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS socials JSONB DEFAULT '[]'::jsonb;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS services JSONB DEFAULT '{}'::jsonb;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS experiences JSONB DEFAULT '[]'::jsonb;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS projects JSONB DEFAULT '[]'::jsonb;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS certifications JSONB DEFAULT '[]'::jsonb;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS data JSONB DEFAULT '{}'::jsonb;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- ------------------------------------------------------------------------------
-- 3. COMPANIES TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.companies (
  id TEXT PRIMARY KEY,
  owner_user_id TEXT NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  tagline TEXT DEFAULT '',
  description TEXT DEFAULT '',
  industry TEXT DEFAULT '',
  size TEXT DEFAULT '',
  website TEXT DEFAULT '',
  location TEXT DEFAULT '',
  logo_url TEXT DEFAULT '',
  cover_url TEXT DEFAULT '',
  theme TEXT DEFAULT 'editorial',
  visibility JSONB DEFAULT '{"about": true, "team": true, "services": true, "projects": true, "contact": true}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ------------------------------------------------------------------------------
-- 4. COMPANY_MEMBERS TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.company_members (
  id TEXT PRIMARY KEY,
  company_id TEXT NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  user_id TEXT REFERENCES public.users(id) ON DELETE SET NULL,
  email TEXT NOT NULL,
  name TEXT NOT NULL,
  title TEXT DEFAULT '',
  department TEXT DEFAULT '',
  bio TEXT DEFAULT '',
  avatar_url TEXT DEFAULT '',
  role TEXT NOT NULL CHECK (role IN ('OWNER', 'ADMIN', 'MEMBER')),
  status TEXT NOT NULL CHECK (status IN ('PENDING', 'ACTIVE', 'REMOVED')),
  invite_token TEXT,
  invite_expires_at TIMESTAMPTZ,
  invited_by_user_id TEXT REFERENCES public.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT uq_company_member_email UNIQUE (company_id, email)
);

-- ------------------------------------------------------------------------------
-- 5. PERFORMANCE INDEXES
-- ------------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON public.profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_profiles_slug ON public.profiles(slug);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_companies_slug ON public.companies(slug);
CREATE INDEX IF NOT EXISTS idx_companies_owner ON public.companies(owner_user_id);
CREATE INDEX IF NOT EXISTS idx_company_members_company ON public.company_members(company_id);
CREATE INDEX IF NOT EXISTS idx_company_members_user ON public.company_members(user_id);
CREATE INDEX IF NOT EXISTS idx_company_members_email ON public.company_members(email);

-- ------------------------------------------------------------------------------
-- 6. PERMISSIONS & ROLES
-- ------------------------------------------------------------------------------
GRANT ALL ON TABLE public.users TO service_role;
GRANT ALL ON TABLE public.users TO postgres;
GRANT SELECT, INSERT, UPDATE ON TABLE public.users TO authenticated;
GRANT SELECT, INSERT ON TABLE public.users TO anon;

GRANT ALL ON TABLE public.profiles TO service_role;
GRANT ALL ON TABLE public.profiles TO postgres;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.profiles TO authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE public.profiles TO anon;

GRANT ALL ON TABLE public.companies TO service_role;
GRANT ALL ON TABLE public.companies TO postgres;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.companies TO authenticated;
GRANT SELECT ON TABLE public.companies TO anon;

GRANT ALL ON TABLE public.company_members TO service_role;
GRANT ALL ON TABLE public.company_members TO postgres;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.company_members TO authenticated;
GRANT SELECT ON TABLE public.company_members TO anon;

-- ------------------------------------------------------------------------------
-- 7. ROW LEVEL SECURITY (RLS) POLICIES
-- ------------------------------------------------------------------------------
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.company_members ENABLE ROW LEVEL SECURITY;

-- Users Policies
DROP POLICY IF EXISTS "Allow service role full access to users" ON public.users;
CREATE POLICY "Allow service role full access to users" 
  ON public.users FOR ALL TO service_role USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public select users" ON public.users;
CREATE POLICY "Public select users" 
  ON public.users FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public insert users" ON public.users;
CREATE POLICY "Public insert users" 
  ON public.users FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Public update users" ON public.users;
CREATE POLICY "Public update users" 
  ON public.users FOR UPDATE USING (true);

-- Profiles Policies
DROP POLICY IF EXISTS "Allow service role full access to profiles" ON public.profiles;
CREATE POLICY "Allow service role full access to profiles" 
  ON public.profiles FOR ALL TO service_role USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public select profiles" ON public.profiles;
CREATE POLICY "Public select profiles" 
  ON public.profiles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public insert profiles" ON public.profiles;
CREATE POLICY "Public insert profiles" 
  ON public.profiles FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Public update profiles" ON public.profiles;
CREATE POLICY "Public update profiles" 
  ON public.profiles FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Public delete profiles" ON public.profiles;
CREATE POLICY "Public delete profiles" 
  ON public.profiles FOR DELETE USING (true);

-- Companies Policies
DROP POLICY IF EXISTS "Allow service role full access to companies" ON public.companies;
CREATE POLICY "Allow service role full access to companies" 
  ON public.companies FOR ALL TO service_role USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public select companies" ON public.companies;
CREATE POLICY "Public select companies" 
  ON public.companies FOR SELECT USING (true);

-- Company Members Policies
DROP POLICY IF EXISTS "Allow service role full access to company_members" ON public.company_members;
CREATE POLICY "Allow service role full access to company_members" 
  ON public.company_members FOR ALL TO service_role USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public select company_members" ON public.company_members;
CREATE POLICY "Public select company_members" 
  ON public.company_members FOR SELECT USING (status = 'ACTIVE');

-- ------------------------------------------------------------------------------
-- 8. STORAGE BUCKETS INITIALIZATION
-- ------------------------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
  ('profiles', 'profiles', true, 10485760, ARRAY['image/png', 'image/jpeg', 'image/jpg', 'image/webp', 'image/svg+xml', 'image/gif']),
  ('avatars', 'avatars', true, 10485760, ARRAY['image/png', 'image/jpeg', 'image/jpg', 'image/webp', 'image/svg+xml', 'image/gif']),
  ('links', 'links', true, 10485760, ARRAY['image/png', 'image/jpeg', 'image/jpg', 'image/webp', 'image/svg+xml', 'image/gif'])
ON CONFLICT (id) DO UPDATE SET 
  public = true,
  file_size_limit = 10485760,
  allowed_mime_types = ARRAY['image/png', 'image/jpeg', 'image/jpg', 'image/webp', 'image/svg+xml', 'image/gif'];

-- Storage RLS Policies
DROP POLICY IF EXISTS "Public storage read" ON storage.objects;
CREATE POLICY "Public storage read" 
  ON storage.objects FOR SELECT 
  USING (bucket_id IN ('profiles', 'avatars', 'links'));

DROP POLICY IF EXISTS "Public storage insert" ON storage.objects;
CREATE POLICY "Public storage insert" 
  ON storage.objects FOR INSERT 
  WITH CHECK (bucket_id IN ('profiles', 'avatars', 'links'));

DROP POLICY IF EXISTS "Public storage update" ON storage.objects;
CREATE POLICY "Public storage update" 
  ON storage.objects FOR UPDATE 
  USING (bucket_id IN ('profiles', 'avatars', 'links'));

DROP POLICY IF EXISTS "Public storage delete" ON storage.objects;
CREATE POLICY "Public storage delete" 
  ON storage.objects FOR DELETE 
  USING (bucket_id IN ('profiles', 'avatars', 'links'));
