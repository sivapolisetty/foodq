// Comprehensive Indian Cuisine List - 200 Items
// Covering all major regions and categories

export const indianCuisineList = [
  // ===== NORTH INDIAN =====
  // Punjabi
  "butter chicken",
  "chicken tikka masala", 
  "tandoori chicken",
  "dal makhani",
  "paneer butter masala",
  "palak paneer",
  "kadai paneer",
  "shahi paneer",
  "aloo gobi",
  "chole bhature",
  "rajma chawal",
  "sarson ka saag with makki di roti",
  "amritsari kulcha",
  "paneer tikka",
  "malai kofta",
  "mushroom masala",
  
  // Mughlai
  "mutton rogan josh",
  "chicken korma",
  "mutton korma",
  "seekh kebab",
  "shammi kebab",
  "galouti kebab",
  "chicken biryani",
  "mutton biryani",
  "sheer khurma",
  
  // Delhi Street Food
  "aloo tikki chaat",
  "papdi chaat",
  "dahi bhalla",
  "gol gappa pani puri",
  "bhel puri",
  "raj kachori",
  "chole kulche",
  "stuffed parantha",
  
  // ===== SOUTH INDIAN =====
  // Tamil Nadu
  "masala dosa",
  "plain dosa",
  "rava dosa",
  "onion uttapam",
  "idli sambar",
  "medu vada",
  "pongal",
  "chicken chettinad",
  "mutton kola urundai",
  "fish curry tamil style",
  "rasam",
  "coconut rice",
  "lemon rice",
  "curd rice",
  "filter coffee",
  
  // Kerala
  "appam with stew",
  "puttu kadala curry",
  "kerala fish curry",
  "beef fry kerala style",
  "chicken roast kerala",
  "prawn moilee",
  "avial",
  "olan",
  "payasam",
  "banana chips",
  
  // Andhra/Telangana
  "hyderabadi chicken biryani",
  "mirchi ka salan",
  "bagara baingan",
  "gongura mutton",
  "andhra chicken curry",
  "pesarattu dosa",
  "upma",
  "pachi pulusu",
  
  // Karnataka
  "bisi bele bath",
  "mysore masala dosa",
  "ragi mudde",
  "jolada rotti",
  "mangalore buns",
  "neer dosa",
  "chicken ghee roast",
  "kane rava fry",
  
  // ===== EAST INDIAN =====
  // Bengali
  "machher jhol fish curry",
  "kosha mangsho",
  "chingri malai curry",
  "aloo posto",
  "shukto",
  "begun bhaja",
  "mishti doi",
  "rasgulla",
  "sandesh",
  "chicken rezala",
  "kolkata biryani",
  "fish kalia",
  
  // Odia
  "dalma",
  "pakhala bhata",
  "chhena poda",
  "macha ghanta",
  
  // Assamese
  "assamese fish tenga",
  "duck curry",
  "pitha",
  "xaak bhaji",
  
  // ===== WEST INDIAN =====
  // Gujarati
  "dhokla",
  "khandvi",
  "thepla",
  "undhiyu",
  "gujarati kadhi",
  "dal dhokli",
  "fafda jalebi",
  "handvo",
  "gujarati thali items",
  
  // Rajasthani
  "dal baati churma",
  "laal maas",
  "gatte ki sabzi",
  "ker sangri",
  "pyaaz kachori",
  "mirchi vada",
  "ghevar",
  "mawa kachori",
  
  // Maharashtrian
  "vada pav",
  "pav bhaji",
  "misal pav",
  "poha",
  "sabudana khichdi",
  "puran poli",
  "modak",
  "bhakri",
  "chicken kolhapuri",
  "mutton sukka",
  "bombay sandwich",
  "dabeli",
  
  // Goan
  "goan fish curry",
  "chicken xacuti",
  "pork vindaloo",
  "sorpotel",
  "bebinca",
  "prawn balchao",
  
  // ===== NORTHEAST INDIAN =====
  "momos steamed",
  "momos fried", 
  "thukpa",
  "churpi soup",
  "pork with bamboo shoot",
  "jadoh",
  "tungrymbai",
  
  // ===== BIRYANI VARIETIES =====
  "lucknowi biryani",
  "kolkata biryani",
  "malabar biryani",
  "ambur biryani",
  "donne biryani",
  "veg biryani",
  "egg biryani",
  "prawn biryani",
  
  // ===== INDIAN CHINESE =====
  "chicken manchurian",
  "veg manchurian",
  "hakka noodles",
  "schezwan fried rice",
  "chilli chicken",
  "chilli paneer",
  "crispy honey chicken",
  "dragon chicken",
  
  // ===== DESSERTS =====
  "gulab jamun",
  "jalebi",
  "ras malai",
  "kulfi",
  "gajar ka halwa",
  "moong dal halwa",
  "kheer",
  "phirni",
  "shrikhand",
  "malpua",
  "balushahi",
  "kaju katli",
  "soan papdi",
  "ladoo varieties",
  "barfi varieties",
  
  // ===== BEVERAGES =====
  "masala chai",
  "lassi sweet",
  "lassi salted",
  "mango lassi",
  "buttermilk",
  "thandai",
  "badam milk",
  "rose milk",
  "fresh lime soda",
  "kokum sharbat",
  "aam panna",
  "sugarcane juice",
  
  // ===== BREAKFAST ITEMS =====
  "aloo paratha",
  "paneer paratha",
  "puri bhaji",
  "bedmi puri",
  "kachori sabzi",
  "bread pakora",
  "samosa",
  "aloo bonda",
  "batata vada",
  "cutlet",
  "bread omelette",
  "masala omelette",
  "egg bhurji"
];

// Categories for tag generation reference
export const tagCategories = {
  cuisines: [
    "north-indian", "south-indian", "bengali", "punjabi", "gujarati", 
    "rajasthani", "maharashtrian", "kerala", "tamil", "andhra", 
    "karnataka", "goan", "mughlai", "indo-chinese", "street-food"
  ],
  dietary: [
    "vegetarian", "non-vegetarian", "vegan", "jain", "gluten-free", 
    "dairy-free", "nut-free", "egg-free"
  ],
  spiceLevel: [
    "mild", "medium-spicy", "spicy", "extra-spicy", "tangy"
  ],
  proteins: [
    "chicken", "mutton", "fish", "prawns", "egg", "paneer", 
    "dal", "soya", "mixed-seafood", "beef", "pork"
  ],
  courses: [
    "appetizer", "main-course", "dessert", "beverage", "snack", 
    "breakfast", "soup", "salad", "bread", "rice-dish"
  ],
  methods: [
    "tandoor", "curry", "grilled", "fried", "steamed", "roasted", 
    "baked", "raw", "fermented", "stir-fried", "slow-cooked"
  ],
  special: [
    "bestseller", "healthy", "kid-friendly", "festive", "comfort-food",
    "party-special", "seasonal", "chef-special", "traditional", "fusion"
  ]
};