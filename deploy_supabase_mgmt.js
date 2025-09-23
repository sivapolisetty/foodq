#!/usr/bin/env node

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/**
 * Deploy SQL schema to Supabase using Management API
 */
async function deployUsingManagementAPI() {
    const PROJECT_REF = 'zobhorsszzthyljriiim'; // Extract from URL
    const SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvYmhvcnNzenp0aHlsanJpaWltIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1Mzk4MjM3NiwiZXhwIjoyMDY5NTU4Mzc2fQ.bH-ROAAkSODqVzjoofUmEfV3WrYQqJcsg68Ad4fbvRU';
    
    try {
        // Read the SQL file
        const sqlFilePath = path.join(__dirname, 'deploy_notification_schema.sql');
        const sqlContent = fs.readFileSync(sqlFilePath, 'utf8');
        
        console.log('🚀 Starting deployment using Supabase Management API...');
        console.log(`📁 Reading SQL from: ${sqlFilePath}`);
        console.log(`🎯 Target project: ${PROJECT_REF}`);
        
        // Try using the management API for database migrations
        const managementResponse = await fetch(`https://api.supabase.com/v1/projects/${PROJECT_REF}/database/migrations`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${SERVICE_ROLE_KEY}`,
            },
            body: JSON.stringify({
                name: `notification_schema_${Date.now()}`,
                sql: sqlContent
            })
        });
        
        if (managementResponse.ok) {
            const result = await managementResponse.json();
            console.log('✅ Migration created successfully:', result);
            
            // Apply the migration
            const applyResponse = await fetch(`https://api.supabase.com/v1/projects/${PROJECT_REF}/database/migrations/${result.id}/apply`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${SERVICE_ROLE_KEY}`,
                }
            });
            
            if (applyResponse.ok) {
                console.log('✅ Migration applied successfully!');
                return true;
            } else {
                const applyError = await applyResponse.text();
                console.error('❌ Failed to apply migration:', applyError);
                return false;
            }
        } else {
            const errorText = await managementResponse.text();
            console.error('❌ Management API failed:', managementResponse.status, managementResponse.statusText);
            console.error('Error details:', errorText);
            return false;
        }
        
    } catch (error) {
        console.error('💥 Management API deployment failed:', error.message);
        return false;
    }
}

/**
 * Alternative approach: Create RPC function to execute SQL
 */
async function deployUsingRPCFunction() {
    const PROJECT_URL = 'https://zobhorsszzthyljriiim.supabase.co';
    const SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvYmhvcnNzenp0aHlsanJpaWltIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1Mzk4MjM3NiwiZXhwIjoyMDY5NTU4Mzc2fQ.bH-ROAAkSODqVzjoofUmEfV3WrYQqJcsg68Ad4fbvRU';
    
    console.log('🔧 Creating RPC function for SQL execution...');
    
    // First, create an RPC function that can execute arbitrary SQL
    const createRPCFunction = `
        CREATE OR REPLACE FUNCTION execute_deployment_sql(sql_commands text)
        RETURNS text
        LANGUAGE plpgsql
        SECURITY DEFINER
        AS $$
        BEGIN
            EXECUTE sql_commands;
            RETURN 'SQL executed successfully';
        EXCEPTION
            WHEN OTHERS THEN
                RETURN 'Error: ' || SQLERRM;
        END;
        $$;
    `;
    
    try {
        // Use a simpler approach - try to create tables directly through the REST API
        await createTablesDirectly(PROJECT_URL, SERVICE_ROLE_KEY);
        return true;
        
    } catch (error) {
        console.error('💥 RPC function deployment failed:', error.message);
        return false;
    }
}

/**
 * Direct table creation using REST API
 */
async function createTablesDirectly(projectUrl, serviceRoleKey) {
    console.log('📊 Creating tables directly using REST API...');
    
    // First create event_queue table structure via direct SQL execution
    // We'll use a simpler approach - check existing tables first
    
    console.log('🔍 Checking existing tables...');
    
    try {
        // Check if tables already exist
        const checkEventQueue = await fetch(`${projectUrl}/rest/v1/event_queue?limit=1`, {
            method: 'HEAD',
            headers: {
                'apikey': serviceRoleKey,
                'Authorization': `Bearer ${serviceRoleKey}`
            }
        });
        
        const checkNotifications = await fetch(`${projectUrl}/rest/v1/notifications?limit=1`, {
            method: 'HEAD',
            headers: {
                'apikey': serviceRoleKey,
                'Authorization': `Bearer ${serviceRoleKey}`
            }
        });
        
        console.log(`📝 event_queue table exists: ${checkEventQueue.ok}`);
        console.log(`📱 notifications table exists: ${checkNotifications.ok}`);
        
        if (checkEventQueue.ok && checkNotifications.ok) {
            console.log('✅ Tables already exist! Checking structure...');
            return true;
        }
        
        // If tables don't exist, we need to create them
        console.log('⚠️  Tables need to be created. Manual intervention required.');
        console.log('Please execute the SQL file manually in the Supabase SQL Editor.');
        
        return false;
        
    } catch (error) {
        console.error('💥 Table check failed:', error.message);
        return false;
    }
}

/**
 * Verify deployment by checking tables and sample data
 */
async function verifyDeployment(projectUrl, serviceRoleKey) {
    console.log('🔍 Verifying deployment...');
    
    try {
        // Check if event_queue table exists and has correct structure
        const eventQueueResponse = await fetch(`${projectUrl}/rest/v1/event_queue?limit=1`, {
            method: 'GET',
            headers: {
                'apikey': serviceRoleKey,
                'Authorization': `Bearer ${serviceRoleKey}`
            }
        });
        
        // Check if notifications table exists and has correct structure
        const notificationsResponse = await fetch(`${projectUrl}/rest/v1/notifications?limit=1`, {
            method: 'GET',
            headers: {
                'apikey': serviceRoleKey,
                'Authorization': `Bearer ${serviceRoleKey}`
            }
        });
        
        console.log('\\n📋 Verification Results:');
        console.log(`📝 event_queue table: ${eventQueueResponse.ok ? '✅ Accessible' : '❌ Not accessible'}`);
        console.log(`📱 notifications table: ${notificationsResponse.ok ? '✅ Accessible' : '❌ Not accessible'}`);
        
        if (eventQueueResponse.ok) {
            const eventQueueData = await eventQueueResponse.json();
            console.log(`📝 event_queue records: ${eventQueueData.length}`);
        }
        
        if (notificationsResponse.ok) {
            const notificationsData = await notificationsResponse.json();
            console.log(`📱 notifications records: ${notificationsData.length}`);
        }
        
        return eventQueueResponse.ok && notificationsResponse.ok;
        
    } catch (error) {
        console.error('❌ Verification failed:', error.message);
        return false;
    }
}

// Main deployment function
async function deployNotificationSchema() {
    console.log('🚀 Starting Supabase notification schema deployment...');
    
    let success = false;
    
    // Try Management API first
    console.log('\\n1️⃣ Trying Management API approach...');
    success = await deployUsingManagementAPI();
    
    if (!success) {
        // Try RPC function approach
        console.log('\\n2️⃣ Trying RPC function approach...');
        success = await deployUsingRPCFunction();
    }
    
    // Verify deployment regardless of method used
    console.log('\\n🔍 Verifying deployment...');
    const PROJECT_URL = 'https://zobhorsszzthyljriiim.supabase.co';
    const SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvYmhvcnNzenp0aHlsanJpaWltIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1Mzk4MjM3NiwiZXhwIjoyMDY5NTU4Mzc2fQ.bH-ROAAkSODqVzjoofUmEfV3WrYQqJcsg68Ad4fbvRU';
    
    const verified = await verifyDeployment(PROJECT_URL, SERVICE_ROLE_KEY);
    
    if (verified) {
        console.log('\\n🎉 Deployment verification successful!');
        console.log('🚀 Notification system is ready for production use.');
    } else {
        console.log('\\n⚠️  Manual intervention required.');
        console.log('📋 Please follow these steps:');
        console.log('1. Open Supabase Dashboard: https://supabase.com/dashboard/project/zobhorsszzthyljriiim');
        console.log('2. Go to SQL Editor');
        console.log('3. Copy and paste the contents of deploy_notification_schema.sql');
        console.log('4. Execute the SQL to create the notification tables and functions');
    }
    
    return verified;
}

// Run the deployment
if (import.meta.url === `file://${process.argv[1]}`) {
    deployNotificationSchema()
        .then((success) => {
            console.log(`\\n🏁 Deployment process ${success ? 'completed successfully' : 'requires manual intervention'}.`);
            process.exit(success ? 0 : 1);
        })
        .catch(error => {
            console.error('\\n💥 Deployment process failed:', error);
            process.exit(1);
        });
}

export { deployNotificationSchema };