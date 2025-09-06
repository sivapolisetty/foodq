import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'http://127.0.0.1:58321';
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU';

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function createFunction() {
  try {
    console.log('Creating simple test function...');
    
    // First, let's create a function that returns JSONB to avoid type issues
    const { data, error } = await supabase
      .from('pg_proc')
      .select('*')
      .eq('proname', 'get_nearby_deals')
      .limit(1);

    console.log('Existing function check:', { data, error });
    
    // Test our function parameters
    const testResult = await supabase.rpc('get_nearby_deals', {
      user_lat: 17.47060544,
      user_lng: 78.26001714,
      radius_meters: 10000,
      result_limit: 10
    });
    
    console.log('Function test result:', testResult);
    
  } catch (error) {
    console.error('Error:', error);
  }
}

createFunction();