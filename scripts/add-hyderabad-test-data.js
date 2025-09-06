const { createClient } = require('@supabase/supabase-js');

// Local Supabase configuration
const supabaseUrl = 'http://127.0.0.1:58321';
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU';

// Create Supabase client
const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function addHyderabadData() {
  try {
    console.log('🏪 Adding Briyani Grill (Hyderabad) to local database...');
    
    // Add Briyani grill business
    const { data: business, error: businessError } = await supabase
      .from('businesses')
      .insert({
        id: '4aef106d-9c91-40a1-a738-f29a21195ab9',
        name: 'briyani grill',
        description: 'Authentic Hyderabadi biryani and Indian cuisine',
        address: 'Tellapur, Hyderabad, Telangana, 502032, India',
        phone: '5517958785',
        email: 'sivapolisetty813@gmail.com',
        latitude: 17.47060544,
        longitude: 78.26001714,
        category: 'Indian',
        is_approved: true,
        is_active: true,
        city: 'Hyderabad',
        state: 'Telangana',
        country: 'India',
        zip_code: '502032',
        delivery_radius: 5,
        min_order_amount: 0,
        accepts_cash: true,
        accepts_cards: true,
        accepts_digital: false,
        onboarding_completed: true
      })
      .select()
      .single();
      
    if (businessError) {
      console.log('Business might already exist, continuing...');
    } else {
      console.log('✅ Business added:', business.name);
    }
    
    // Add deals for Briyani grill
    const deals = [
      {
        id: '6f391dde-f9d5-4488-8773-a994f1768106',
        business_id: '4aef106d-9c91-40a1-a738-f29a21195ab9',
        title: 'Fresh Samosa Deal',
        description: 'Hot and crispy samosas with mint chutney',
        original_price: 30,
        discounted_price: 20,
        quantity_available: 50,
        quantity_sold: 0,
        image_url: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=500',
        status: 'active',
        expires_at: '2025-12-31T23:59:59+00:00'
      },
      {
        id: '7549148a-303b-431f-8de2-e0d5ef9db601',
        business_id: '4aef106d-9c91-40a1-a738-f29a21195ab9',
        title: 'pizza',
        description: 'veg chicken pizza',
        original_price: 45,
        discounted_price: 35,
        quantity_available: 10,
        quantity_sold: 0,
        image_url: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=500',
        status: 'active',
        expires_at: '2025-09-10T15:00:00+00:00'
      }
    ];
    
    console.log('🍕 Adding deals...');
    const { data: dealsData, error: dealsError } = await supabase
      .from('deals')
      .insert(deals)
      .select();
      
    if (dealsError) {
      console.log('Deals might already exist:', dealsError.message);
    } else {
      console.log(`✅ Added ${dealsData.length} deals`);
    }
    
    console.log('\n🎉 Hyderabad test data added successfully!');
    console.log('\nNow you can test with:');
    console.log('curl "http://localhost:8788/api/deals?filter=nearby&lat=17.47060544&lng=78.26001714&radius=10&limit=10" -H "authorization: Bearer test-token"');
    
  } catch (error) {
    console.error('❌ Failed to add test data:', error);
  }
}

addHyderabadData();