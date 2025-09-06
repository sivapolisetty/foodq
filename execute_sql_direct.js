import { createClient } from '@supabase/supabase-js';
import fs from 'fs';

const supabaseUrl = 'http://127.0.0.1:58321';
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU';

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function executeSQL() {
  try {
    console.log('🔧 Creating minimal geospatial function...');
    
    const sql = fs.readFileSync('minimal_geospatial_function.sql', 'utf8');
    
    // Try using the raw SQL connection
    const { data, error } = await supabase
      .from('_realtime')
      .select('*')
      .limit(0);
      
    console.log('Connection test:', { data, error });
    
    // Try different approaches
    console.log('Attempting to create function via RPC...');
    
    // Method 1: Try to use a built-in SQL execution function
    const methods = ['exec_sql', 'execute', 'run_sql', 'sql', 'query'];
    
    for (const method of methods) {
      try {
        const result = await supabase.rpc(method, { query: sql });
        console.log(`✅ Success with method: ${method}`, result);
        break;
      } catch (err) {
        console.log(`❌ Failed with method: ${method}`, err?.error || err);
      }
    }
    
    // Method 2: Try manual HTTP request to Supabase
    console.log('Trying direct HTTP approach...');
    const response = await fetch(`${supabaseUrl}/rest/v1/rpc/exec_sql`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': supabaseServiceKey,
        'Authorization': `Bearer ${supabaseServiceKey}`
      },
      body: JSON.stringify({ query: sql })
    });
    
    const result = await response.text();
    console.log('HTTP Response:', response.status, result);
    
  } catch (error) {
    console.error('❌ Error:', error);
  }
}

executeSQL();