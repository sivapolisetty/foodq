import { createClient } from '@supabase/supabase-js';

// Supabase configuration
const supabaseUrl = 'https://zobhorsszzthyljriiim.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvYmhvcnNzenp0aHlsanJpaWltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5ODIzNzYsImV4cCI6MjA2OTU1ODM3Nn0.91GlHZxmJGg5E-T2iR5rzgLrQJzNPNW-SzS2VhqlymA';

// Create Supabase client for general use (non-admin functionality)
export const supabase = createClient(supabaseUrl, supabaseAnonKey);