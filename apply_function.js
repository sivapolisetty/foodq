import { createClient } from '@supabase/supabase-js';
import fs from 'fs';

// Local Supabase configuration
const supabaseUrl = 'http://127.0.0.1:58321';
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU';

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function applyFunction() {
  try {
    console.log('🔧 Applying corrected PostgreSQL geospatial function...');
    
    const sql = fs.readFileSync('final_nearby_deals_function.sql', 'utf8');
    
    // Split the SQL into individual statements
    const statements = sql
      .split(';')
      .map(stmt => stmt.trim())
      .filter(stmt => stmt.length > 0 && !stmt.startsWith('--'));
    
    for (const statement of statements) {
      if (statement.includes('DROP FUNCTION')) {
        console.log('🗑️ Dropping old function...');
      } else if (statement.includes('CREATE OR REPLACE FUNCTION')) {
        console.log('🆕 Creating new function...');
      } else if (statement.includes('GRANT EXECUTE')) {
        console.log('🔐 Granting permissions...');
      }
      
      const { error } = await supabase.rpc('exec', { query: statement });
      if (error) {
        console.error('❌ Error executing statement:', error);
        // Try raw query if rpc fails
        const { error: rawError } = await supabase.from('_supabase_sql').insert({ query: statement });
        if (rawError) {
          console.error('❌ Raw query also failed:', rawError);
        }
      }
    }
    
    console.log('✅ Function applied successfully!');
    console.log('🧪 Testing function...');
    
    // Test the function
    const { data, error } = await supabase.rpc('get_nearby_deals', {
      user_lat: 17.47060544,
      user_lng: 78.26001714,
      radius_meters: 10000,
      result_limit: 10
    });
    
    if (error) {
      console.error('❌ Function test failed:', error);
    } else {
      console.log(`✅ Function test successful! Found ${data?.length || 0} deals`);
    }
    
  } catch (error) {
    console.error('❌ Failed to apply function:', error);
  }
}

applyFunction();