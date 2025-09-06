const { createClient } = require('@supabase/supabase-js');

// Supabase configuration
const supabaseUrl = 'https://zobhorsszzthyljriiim.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvYmhvcnNzenp0aHlsanJpaWltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5ODIzNzYsImV4cCI6MjA2OTU1ODM3Nn0.91GlHZxmJGg5E-T2iR5rzgLrQJzNPNW-SzS2VhqlymA';

const supabase = createClient(supabaseUrl, supabaseKey);

// Sample restaurant data
const restaurants = [
  {
    name: "Bella Italia",
    description: "Authentic Italian cuisine with fresh pasta and wood-fired pizza",
    address: "123 Main Street, Downtown",
    latitude: 37.7749,
    longitude: -122.4194,
    phone: "(555) 123-4567",
    email: "info@bellaitalia.com",
    category: "Italian",
    owner_id: "00000000-0000-0000-0000-000000000001", // Placeholder owner ID
    logo_url: "https://images.unsplash.com/photo-1552566626-52f8b828add9?w=400&h=400&fit=crop",
    cover_image_url: "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&h=400&fit=crop",
    is_approved: true,
    is_active: true
  },
  {
    name: "Tokyo Sushi Bar",
    description: "Fresh sushi and Japanese delicacies made by master chefs",
    address: "456 Oak Avenue, Japantown",
    latitude: 37.7849,
    longitude: -122.4094,
    phone: "(555) 987-6543",
    email: "hello@tokyosushibar.com",
    category: "Japanese",
    owner_id: "00000000-0000-0000-0000-000000000002", // Placeholder owner ID
    logo_url: "https://images.unsplash.com/photo-1579952363873-27d3bfad9c0d?w=400&h=400&fit=crop",
    cover_image_url: "https://images.unsplash.com/photo-1579027989054-b11ce61b83d3?w=800&h=400&fit=crop",
    is_approved: true,
    is_active: true
  }
];

// Sample deal data templates
const dealTemplates = {
  italian: [
    {
      title: "Margherita Pizza Special",
      description: "Classic wood-fired Margherita pizza with fresh mozzarella, tomato sauce, and basil",
      original_price: 24.99,
      discounted_price: 18.99,
      quantity_available: 25,
      image_url: "https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=600&h=400&fit=crop",
      allergen_info: "Contains gluten, dairy"
    },
    {
      title: "Pasta Carbonara Combo",
      description: "Creamy carbonara pasta served with garlic bread and Caesar salad",
      original_price: 28.99,
      discounted_price: 21.99,
      quantity_available: 20,
      image_url: "https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=600&h=400&fit=crop",
      allergen_info: "Contains gluten, dairy, eggs"
    },
    {
      title: "Lasagna Family Size",
      description: "Homemade meat lasagna with ricotta, mozzarella, and meat sauce - serves 4",
      original_price: 45.99,
      discounted_price: 34.99,
      quantity_available: 15,
      image_url: "https://images.unsplash.com/photo-1574894709920-11b28e7367e3?w=600&h=400&fit=crop",
      allergen_info: "Contains gluten, dairy"
    },
    {
      title: "Chicken Parmigiana",
      description: "Breaded chicken breast topped with marinara sauce and melted cheese",
      original_price: 26.99,
      discounted_price: 19.99,
      quantity_available: 18,
      image_url: "https://images.unsplash.com/photo-1632778149955-e80f8ceca2e8?w=600&h=400&fit=crop",
      allergen_info: "Contains gluten, dairy"
    },
    {
      title: "Seafood Risotto",
      description: "Creamy arborio rice with fresh shrimp, scallops, and mussels",
      original_price: 32.99,
      discounted_price: 26.99,
      quantity_available: 12,
      image_url: "https://images.unsplash.com/photo-1476124369491-e7addf5db371?w=600&h=400&fit=crop",
      allergen_info: "Contains dairy, shellfish"
    },
    {
      title: "Tiramisu Dessert",
      description: "Traditional Italian dessert with coffee-soaked ladyfingers and mascarpone",
      original_price: 12.99,
      discounted_price: 8.99,
      quantity_available: 30,
      image_url: "https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=600&h=400&fit=crop",
      allergen_info: "Contains dairy, eggs, alcohol"
    },
    {
      title: "Caesar Salad Large",
      description: "Fresh romaine lettuce with parmesan, croutons, and Caesar dressing",
      original_price: 16.99,
      discounted_price: 12.99,
      quantity_available: 35,
      image_url: "https://images.unsplash.com/photo-1512852939750-1305098529bf?w=600&h=400&fit=crop",
      allergen_info: "Contains gluten, dairy, eggs"
    },
    {
      title: "Minestrone Soup Bowl",
      description: "Hearty vegetable soup with beans, pasta, and Italian herbs",
      original_price: 14.99,
      discounted_price: 10.99,
      quantity_available: 40,
      image_url: "https://images.unsplash.com/photo-1547592180-85f173990554?w=600&h=400&fit=crop",
      allergen_info: "Contains gluten"
    },
    {
      title: "Bruschetta Appetizer",
      description: "Toasted bread topped with fresh tomatoes, garlic, basil, and olive oil",
      original_price: 11.99,
      discounted_price: 8.99,
      quantity_available: 45,
      image_url: "https://images.unsplash.com/photo-1572441713132-51c75654db73?w=600&h=400&fit=crop",
      allergen_info: "Contains gluten"
    },
    {
      title: "Calzone Deluxe",
      description: "Folded pizza filled with ricotta, mozzarella, pepperoni, and Italian sausage",
      original_price: 22.99,
      discounted_price: 17.99,
      quantity_available: 22,
      image_url: "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600&h=400&fit=crop",
      allergen_info: "Contains gluten, dairy"
    }
  ],
  japanese: [
    {
      title: "Sushi Platter for Two",
      description: "Assorted fresh sushi including salmon, tuna, yellowtail, and California rolls",
      original_price: 65.99,
      discounted_price: 49.99,
      quantity_available: 15,
      image_url: "https://images.unsplash.com/photo-1579952363873-27d3bfad9c0d?w=600&h=400&fit=crop",
      allergen_info: "Contains fish, shellfish, soy"
    },
    {
      title: "Dragon Roll Special",
      description: "Eel and cucumber inside, topped with avocado and eel sauce",
      original_price: 18.99,
      discounted_price: 14.99,
      quantity_available: 25,
      image_url: "https://images.unsplash.com/photo-1576013551627-0cc20b96c2a7?w=600&h=400&fit=crop",
      allergen_info: "Contains fish, soy"
    },
    {
      title: "Chicken Teriyaki Bento",
      description: "Grilled chicken teriyaki with rice, miso soup, and vegetable tempura",
      original_price: 22.99,
      discounted_price: 17.99,
      quantity_available: 20,
      image_url: "https://images.unsplash.com/photo-1617093727343-374698b1b08d?w=600&h=400&fit=crop",
      allergen_info: "Contains soy, gluten"
    },
    {
      title: "Salmon Sashimi Deluxe",
      description: "Fresh salmon sashimi served with wasabi, pickled ginger, and soy sauce",
      original_price: 29.99,
      discounted_price: 24.99,
      quantity_available: 18,
      image_url: "https://images.unsplash.com/photo-1559339553-1337bbfedf3b?w=600&h=400&fit=crop",
      allergen_info: "Contains fish, soy"
    },
    {
      title: "Ramen Bowl Tonkotsu",
      description: "Rich pork bone broth ramen with chashu pork, egg, and green onions",
      original_price: 19.99,
      discounted_price: 15.99,
      quantity_available: 30,
      image_url: "https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600&h=400&fit=crop",
      allergen_info: "Contains eggs, gluten, soy"
    },
    {
      title: "Tempura Combo Platter",
      description: "Mixed tempura with shrimp, vegetables, and dipping sauce",
      original_price: 24.99,
      discounted_price: 19.99,
      quantity_available: 25,
      image_url: "https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=600&h=400&fit=crop",
      allergen_info: "Contains shellfish, gluten"
    },
    {
      title: "Maki Roll Combination",
      description: "California roll, spicy tuna roll, and Philadelphia roll combo",
      original_price: 28.99,
      discounted_price: 22.99,
      quantity_available: 20,
      image_url: "https://images.unsplash.com/photo-1579027989054-b11ce61b83d3?w=600&h=400&fit=crop",
      allergen_info: "Contains fish, shellfish, dairy"
    },
    {
      title: "Gyoza Dumplings",
      description: "Pan-fried pork dumplings served with ponzu dipping sauce",
      original_price: 14.99,
      discounted_price: 10.99,
      quantity_available: 35,
      image_url: "https://images.unsplash.com/photo-1496116218417-1a781b1c416c?w=600&h=400&fit=crop",
      allergen_info: "Contains gluten, soy"
    },
    {
      title: "Chirashi Bowl",
      description: "Assorted sashimi over seasoned sushi rice with miso soup",
      original_price: 26.99,
      discounted_price: 21.99,
      quantity_available: 16,
      image_url: "https://images.unsplash.com/photo-1563612116625-3012372fccce?w=600&h=400&fit=crop",
      allergen_info: "Contains fish, soy"
    },
    {
      title: "Udon Noodle Soup",
      description: "Thick wheat noodles in savory broth with green onions and kamaboko",
      original_price: 17.99,
      discounted_price: 13.99,
      quantity_available: 28,
      image_url: "https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=600&h=400&fit=crop",
      allergen_info: "Contains gluten, fish, soy"
    }
  ]
};

async function createDealsForRestaurants(restaurantsData) {
  // Insert deals for each restaurant
  for (let i = 0; i < restaurantsData.length; i++) {
    const restaurant = restaurantsData[i];
    
    // Determine restaurant type based on name or category
    const isItalian = restaurant.name.toLowerCase().includes('italia') || restaurant.category === 'Italian';
    const dealTemplate = isItalian ? dealTemplates.italian : dealTemplates.japanese;
    const restaurantType = isItalian ? 'Italian' : 'Japanese';
    
    console.log(`🍽️  Loading deals for ${restaurant.name} (${restaurantType})...`);
    
    // Check for existing deals to avoid duplicates
    const { data: existingDeals, error: dealCheckError } = await supabase
      .from('deals')
      .select('title')
      .eq('business_id', restaurant.id);
    
    if (dealCheckError) {
      console.error(`❌ Error checking existing deals for ${restaurant.name}:`, dealCheckError);
      continue;
    }
    
    let dealsToCreate = dealTemplate;
    if (existingDeals && existingDeals.length > 0) {
      const existingTitles = existingDeals.map(d => d.title);
      dealsToCreate = dealTemplate.filter(deal => !existingTitles.includes(deal.title));
      console.log(`⚠️  Found ${existingDeals.length} existing deals for ${restaurant.name}. Creating ${dealsToCreate.length} new deals.`);
    }
    
    if (dealsToCreate.length === 0) {
      console.log(`ℹ️  All deals already exist for ${restaurant.name}. Skipping.`);
      continue;
    }
    
    // Prepare deals with restaurant ID and expiration dates
    const deals = dealsToCreate.map(deal => ({
      ...deal,
      business_id: restaurant.id,
      expires_at: new Date(Date.now() + (7 * 24 * 60 * 60 * 1000)).toISOString(), // 7 days from now
      status: 'active',
      quantity_sold: Math.floor(Math.random() * 5) // Random sold quantity (0-4)
    }));

    const { data: dealsData, error: dealsError } = await supabase
      .from('deals')
      .insert(deals)
      .select();

    if (dealsError) {
      console.error(`❌ Error inserting deals for ${restaurant.name}:`, dealsError);
      continue;
    }

    console.log(`✅ Inserted ${dealsData.length} deals for ${restaurant.name}`);
  }
}

async function loadTestData() {
  console.log('🚀 Loading test data into Supabase...');
  
  try {
    // First, get existing users from app_users table
    console.log('👤 Fetching existing users...');
    const { data: existingUsers, error: usersError } = await supabase
      .from('app_users')
      .select('id, email')
      .limit(10);
    
    if (usersError || !existingUsers || existingUsers.length === 0) {
      console.error('❌ No users found in database. Please create some users first.');
      console.error('Users error:', usersError);
      return;
    }
    
    console.log(`✅ Found ${existingUsers.length} existing users`);
    
    // Check for existing businesses to avoid duplicates
    const { data: existingBusinesses, error: businessCheckError } = await supabase
      .from('businesses')
      .select('name')
      .in('name', restaurants.map(r => r.name));
      
    if (businessCheckError) {
      console.error('❌ Error checking existing businesses:', businessCheckError);
      return;
    }
    
    if (existingBusinesses && existingBusinesses.length > 0) {
      console.log(`⚠️  Found ${existingBusinesses.length} existing businesses with same names. Skipping duplicates.`);
      const existingNames = existingBusinesses.map(b => b.name);
      const filteredRestaurants = restaurants.filter(r => !existingNames.includes(r.name));
      
      if (filteredRestaurants.length === 0) {
        console.log('ℹ️  All test restaurants already exist. Skipping restaurant creation.');
        
        // Get existing restaurant data for deal creation
        const { data: existingRestaurantData, error: existingError } = await supabase
          .from('businesses')
          .select('*')
          .in('name', restaurants.map(r => r.name));
          
        if (existingError || !existingRestaurantData) {
          console.error('❌ Error fetching existing restaurants:', existingError);
          return;
        }
        
        await createDealsForRestaurants(existingRestaurantData);
        return;
      }
      
      restaurants.splice(0, restaurants.length, ...filteredRestaurants);
    }
    
    // Update restaurants with real user IDs
    const updatedRestaurants = restaurants.map((restaurant, index) => ({
      ...restaurant,
      owner_id: existingUsers[index % existingUsers.length].id // Cycle through available users
    }));
    
    // Insert restaurants
    console.log('📍 Inserting restaurants...');
    const { data: restaurantsData, error: restaurantsError } = await supabase
      .from('businesses')
      .insert(updatedRestaurants)
      .select();

    if (restaurantsError) {
      console.error('❌ Error inserting restaurants:', restaurantsError);
      return;
    }

    console.log(`✅ Inserted ${restaurantsData.length} restaurants`);
    
    // Insert deals for the new restaurants
    await createDealsForRestaurants(restaurantsData);

    console.log('🎉 Test data loaded successfully!');
    console.log('\nSummary:');
    console.log(`📍 Restaurants: ${restaurantsData.length}`);
    console.log(`🍽️  Total deals: ${dealTemplates.italian.length + dealTemplates.japanese.length}`);
    console.log('\nRestaurants loaded:');
    restaurantsData.forEach((restaurant, index) => {
      const dealCount = index === 0 ? dealTemplates.italian.length : dealTemplates.japanese.length;
      console.log(`  • ${restaurant.name} (${restaurant.category}) - ${dealCount} deals`);
    });

  } catch (error) {
    console.error('💥 Unexpected error:', error);
  }
}

// Run the script
if (require.main === module) {
  loadTestData().then(() => {
    console.log('\n✨ Script completed!');
    process.exit(0);
  }).catch((error) => {
    console.error('💥 Script failed:', error);
    process.exit(1);
  });
}

module.exports = { loadTestData };