const fs = require('fs');
const path = require('path');
const { createClient } = require('@supabase/supabase-js');

// Local Supabase configuration
const supabaseUrl = 'http://127.0.0.1:58321';
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU';

// Create Supabase client
const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function applyMigration() {
  try {
    // Read the SQL migration file
    const migrationPath = path.join(__dirname, '../supabase/migrations/20250904000000_create_nearby_deals_function.sql');
    const migrationSQL = fs.readFileSync(migrationPath, 'utf8');
    
    console.log('📝 Applying geospatial migration to local database...');
    
    // Split the SQL into individual statements
    const statements = migrationSQL
      .split(';')
      .map(stmt => stmt.trim())
      .filter(stmt => stmt.length > 0 && !stmt.startsWith('--'));
    
    console.log(`Found ${statements.length} SQL statements to execute`);
    
    // Execute each statement
    for (let i = 0; i < statements.length; i++) {
      const statement = statements[i];
      if (statement.trim()) {
        console.log(`\n🔄 Executing statement ${i + 1}/${statements.length}:`);
        console.log(statement.substring(0, 100) + (statement.length > 100 ? '...' : ''));
        
        try {
          const { data, error } = await supabase.rpc('exec', {
            sql: statement
          });
          
          if (error) {
            console.error(`❌ Error in statement ${i + 1}:`, error);
            
            // Try direct SQL execution for some statements
            const { data: directData, error: directError } = await supabase
              .from('_sql')
              .select('*')
              .limit(0);
              
            if (directError) {
              console.error('Direct SQL also failed:', directError);
            }
          } else {
            console.log(`✅ Statement ${i + 1} executed successfully`);
          }
        } catch (execError) {
          console.error(`❌ Exception in statement ${i + 1}:`, execError.message);
        }
      }
    }
    
    console.log('\n🎉 Migration application completed!');
    
    // Test the function
    console.log('\n🧪 Testing the function...');
    const { data: testData, error: testError } = await supabase
      .rpc('get_nearby_deals', {
        user_lat: 17.47060544,
        user_lng: 78.26001714,
        radius_meters: 10000,
        result_limit: 10
      });
      
    if (testError) {
      console.error('❌ Function test failed:', testError);
    } else {
      console.log('✅ Function test successful! Found', testData?.length || 0, 'deals');
      if (testData && testData.length > 0) {
        console.log('Sample deal:', testData[0].title);
      }
    }
    
  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  }
}

applyMigration();