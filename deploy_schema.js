#!/usr/bin/env node

/**
 * Deploy notification schema to production Supabase
 * This script creates the necessary tables and triggers programmatically
 */

import { createClient } from '@supabase/supabase-js';

// Production credentials
const SUPABASE_URL = 'https://zobhorsszzthyljriiim.supabase.co';
const SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvYmhvcnNzenp0aHlsanJpaWltIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1Mzk4MjM3NiwiZXhwIjoyMDY5NTU4Mzc2fQ.bH-ROAAkSODqVzjoofUmEfV3WrYQqJcsg68Ad4fbvRU';

// Create Supabase client with service role
const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

async function deploySchema() {
  console.log('🚀 Starting deployment to production Supabase...');
  
  try {
    // Test connection first
    console.log('Testing connection...');
    const { data: businesses, error: testError } = await supabase
      .from('businesses')
      .select('id')
      .limit(1);
    
    if (testError) {
      console.error('❌ Connection test failed:', testError);
      return;
    }
    console.log('✅ Connection successful');
    
    // Since we can't execute raw SQL via the JS SDK, we'll need to use the SQL editor
    // Let's at least verify what tables exist
    console.log('\n📋 Checking existing tables...');
    
    // Check if event_queue exists
    const { error: eventQueueError } = await supabase
      .from('event_queue')
      .select('id')
      .limit(1);
    
    if (eventQueueError?.code === 'PGRST204' || eventQueueError?.message?.includes('not exist')) {
      console.log('❌ event_queue table does not exist - needs creation');
    } else if (!eventQueueError) {
      console.log('✅ event_queue table already exists');
    }
    
    // Check if notifications exists
    const { error: notificationsError } = await supabase
      .from('notifications')
      .select('id')
      .limit(1);
    
    if (notificationsError?.code === 'PGRST204' || notificationsError?.message?.includes('not exist')) {
      console.log('❌ notifications table does not exist - needs creation');
    } else if (!notificationsError) {
      console.log('✅ notifications table already exists');
    }
    
    // Check if user_locations exists
    const { error: locationsError } = await supabase
      .from('user_locations')
      .select('id')
      .limit(1);
    
    if (locationsError?.code === 'PGRST204' || locationsError?.message?.includes('not exist')) {
      console.log('❌ user_locations table does not exist - needs creation');
    } else if (!locationsError) {
      console.log('✅ user_locations table already exists');
    }
    
    // Check if push_tokens exists
    const { error: tokensError } = await supabase
      .from('push_tokens')
      .select('id')
      .limit(1);
    
    if (tokensError?.code === 'PGRST204' || tokensError?.message?.includes('not exist')) {
      console.log('❌ push_tokens table does not exist - needs creation');
    } else if (!tokensError) {
      console.log('✅ push_tokens table already exists');
    }
    
    console.log('\n⚠️  MANUAL DEPLOYMENT REQUIRED');
    console.log('=====================================');
    console.log('The Supabase JS SDK cannot execute raw SQL.');
    console.log('Please follow these steps:');
    console.log('');
    console.log('1. Go to: https://supabase.com/dashboard/project/zobhorsszzthyljriiim/sql/new');
    console.log('2. Copy the contents of COMPLETE_NOTIFICATION_SCHEMA.sql');
    console.log('3. Paste and execute in the SQL editor');
    console.log('4. Verify deployment with this script again');
    console.log('');
    console.log('The SQL file is located at:');
    console.log('  /Users/sivapolisetty/vscode-workspace/claude_workspace/foodqapp/COMPLETE_NOTIFICATION_SCHEMA.sql');
    
  } catch (error) {
    console.error('❌ Deployment failed:', error);
  }
}

// Run the deployment
deploySchema();