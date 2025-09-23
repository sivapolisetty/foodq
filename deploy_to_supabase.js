#!/usr/bin/env node

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/**
 * Deploy SQL schema to Supabase production database
 */
async function deployToSupabase() {
    const PROJECT_URL = 'https://zobhorsszzthyljriiim.supabase.co';
    const SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvYmhvcnNzenp0aHlsanJpaWltIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1Mzk4MjM3NiwiZXhwIjoyMDY5NTU4Mzc2fQ.bH-ROAAkSODqVzjoofUmEfV3WrYQqJcsg68Ad4fbvRU';
    
    try {
        // Read the SQL file
        const sqlFilePath = path.join(__dirname, 'deploy_notification_schema.sql');
        const sqlContent = fs.readFileSync(sqlFilePath, 'utf8');
        
        console.log('🚀 Starting deployment to Supabase production database...');
        console.log(`📁 Reading SQL from: ${sqlFilePath}`);
        console.log(`🎯 Target database: ${PROJECT_URL}`);
        
        // Execute SQL using Supabase REST API
        const response = await fetch(`${PROJECT_URL}/rest/v1/rpc/exec_sql`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'apikey': SERVICE_ROLE_KEY,
                'Authorization': `Bearer ${SERVICE_ROLE_KEY}`,
                'Prefer': 'return=minimal'
            },
            body: JSON.stringify({
                sql: sqlContent
            })
        });
        
        if (response.ok) {
            console.log('✅ SQL executed successfully!');
            
            // Verify tables were created
            await verifyDeployment(PROJECT_URL, SERVICE_ROLE_KEY);
            
        } else {
            const errorText = await response.text();
            console.error('❌ SQL execution failed:', response.status, response.statusText);
            console.error('Error details:', errorText);
            
            // Try alternative approach using direct database connection
            console.log('🔄 Trying alternative deployment method...');
            await deployUsingDirectSQL(PROJECT_URL, SERVICE_ROLE_KEY, sqlContent);
        }
        
    } catch (error) {
        console.error('💥 Deployment failed:', error.message);
        
        // Try alternative approach
        console.log('🔄 Trying alternative deployment method...');
        const sqlFilePath = path.join(__dirname, 'deploy_notification_schema.sql');
        const sqlContent = fs.readFileSync(sqlFilePath, 'utf8');
        await deployUsingDirectSQL(PROJECT_URL, SERVICE_ROLE_KEY, sqlContent);
    }
}

/**
 * Alternative deployment method using individual SQL statements
 */
async function deployUsingDirectSQL(projectUrl, serviceRoleKey, sqlContent) {
    console.log('📝 Executing SQL statements individually...');
    
    // Split SQL into individual statements
    const statements = sqlContent
        .split(';')
        .map(stmt => stmt.trim())
        .filter(stmt => stmt.length > 0 && !stmt.startsWith('--'));
    
    console.log(`🔢 Found ${statements.length} SQL statements to execute`);
    
    let successCount = 0;
    let errorCount = 0;
    
    for (let i = 0; i < statements.length; i++) {
        const statement = statements[i] + ';';
        
        try {
            const response = await fetch(`${projectUrl}/rest/v1/rpc/execute_sql`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'apikey': serviceRoleKey,
                    'Authorization': `Bearer ${serviceRoleKey}`
                },
                body: JSON.stringify({
                    query: statement
                })
            });
            
            if (response.ok) {
                console.log(`✅ Statement ${i + 1}/${statements.length} executed successfully`);
                successCount++;
            } else {
                const errorText = await response.text();
                console.warn(`⚠️  Statement ${i + 1}/${statements.length} failed:`, errorText);
                errorCount++;
            }
            
        } catch (error) {
            console.warn(`⚠️  Statement ${i + 1}/${statements.length} error:`, error.message);
            errorCount++;
        }
    }
    
    console.log(`\n📊 Deployment Summary:`);
    console.log(`✅ Successful: ${successCount}`);
    console.log(`❌ Failed: ${errorCount}`);
    console.log(`📋 Total: ${statements.length}`);
    
    if (successCount > 0) {
        console.log('\n🔍 Verifying deployment...');
        await verifyDeployment(projectUrl, serviceRoleKey);
    }
}

/**
 * Verify that the deployment was successful
 */
async function verifyDeployment(projectUrl, serviceRoleKey) {
    console.log('🔍 Verifying deployment...');
    
    try {
        // Check if event_queue table exists
        const eventQueueResponse = await fetch(`${projectUrl}/rest/v1/event_queue?limit=1`, {
            method: 'HEAD',
            headers: {
                'apikey': serviceRoleKey,
                'Authorization': `Bearer ${serviceRoleKey}`
            }
        });
        
        // Check if notifications table exists
        const notificationsResponse = await fetch(`${projectUrl}/rest/v1/notifications?limit=1`, {
            method: 'HEAD',
            headers: {
                'apikey': serviceRoleKey,
                'Authorization': `Bearer ${serviceRoleKey}`
            }
        });
        
        console.log('\n📋 Verification Results:');
        console.log(`📝 event_queue table: ${eventQueueResponse.ok ? '✅ Created' : '❌ Missing'}`);
        console.log(`📱 notifications table: ${notificationsResponse.ok ? '✅ Created' : '❌ Missing'}`);
        
        if (eventQueueResponse.ok && notificationsResponse.ok) {
            console.log('\n🎉 Deployment verification successful!');
            console.log('🚀 Notification system is ready for production use.');
        } else {
            console.log('\n⚠️  Some tables may not have been created properly.');
            console.log('Please check the Supabase dashboard for more details.');
        }
        
    } catch (error) {
        console.error('❌ Verification failed:', error.message);
    }
}

// Run the deployment
if (import.meta.url === `file://${process.argv[1]}`) {
    deployToSupabase()
        .then(() => {
            console.log('\n🏁 Deployment process completed.');
            process.exit(0);
        })
        .catch(error => {
            console.error('\n💥 Deployment process failed:', error);
            process.exit(1);
        });
}

export { deployToSupabase };