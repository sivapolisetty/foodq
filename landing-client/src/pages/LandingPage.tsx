import React from 'react';
import { Link } from 'react-router-dom';
import { 
  Smartphone, 
  MapPin, 
  Clock, 
  Percent,
  Download,
  ArrowRight,
  Star,
  Users,
  TrendingUp,
  Heart,
  ShoppingBag,
  Utensils,
  Gift,
  Check,
  ChevronRight,
  Menu,
  X,
  Search
} from 'lucide-react';

const LandingPage: React.FC = () => {
  const [mobileMenuOpen, setMobileMenuOpen] = React.useState(false);

  return (
    <div className="min-h-screen bg-white">
      {/* Navigation - Yindii Style */}
      <nav className="bg-white fixed top-0 w-full z-50 shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-20">
            <div className="flex items-center">
              <div className="text-3xl font-black text-green-600">Grabeat</div>
            </div>
            
            {/* Desktop Navigation */}
            <div className="hidden md:flex items-center space-x-8">
              <Link to="/restaurants" className="text-gray-700 hover:text-green-600 font-medium transition-colors">
                For Restaurants
              </Link>
              <Link to="/customers" className="text-gray-700 hover:text-green-600 font-medium transition-colors">
                How It Works
              </Link>
              <a href="#download" className="text-gray-700 hover:text-green-600 font-medium transition-colors">
                Download
              </a>
              <a href="#download" className="bg-green-600 hover:bg-green-700 text-white px-6 py-2.5 rounded-full font-semibold transition-all transform hover:scale-105">
                Get Started
              </a>
            </div>

            {/* Mobile menu button */}
            <button 
              className="md:hidden"
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            >
              {mobileMenuOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
            </button>
          </div>
        </div>

        {/* Mobile menu */}
        {mobileMenuOpen && (
          <div className="md:hidden bg-white border-t">
            <div className="px-4 py-4 space-y-3">
              <Link to="/restaurants" className="block text-gray-700 hover:text-green-600 font-medium py-2">
                For Restaurants
              </Link>
              <Link to="/customers" className="block text-gray-700 hover:text-green-600 font-medium py-2">
                How It Works
              </Link>
              <a href="#download" className="block text-gray-700 hover:text-green-600 font-medium py-2">
                Download
              </a>
              <a href="#download" className="block bg-green-600 text-white text-center px-6 py-3 rounded-full font-semibold">
                Get Started
              </a>
            </div>
          </div>
        )}
      </nav>

      {/* Hero Section - Yindii Style with Polka Dots */}
      <section className="relative bg-gradient-to-br from-green-50 via-white to-green-50 pt-32 pb-20 overflow-hidden">
        {/* Polka dot pattern */}
        <div className="absolute inset-0 opacity-10">
          <div className="absolute top-20 left-20 w-4 h-4 bg-green-400 rounded-full"></div>
          <div className="absolute top-40 left-60 w-6 h-6 bg-green-500 rounded-full"></div>
          <div className="absolute top-60 right-40 w-3 h-3 bg-green-400 rounded-full"></div>
          <div className="absolute bottom-20 left-40 w-5 h-5 bg-green-500 rounded-full"></div>
          <div className="absolute bottom-40 right-60 w-4 h-4 bg-green-400 rounded-full"></div>
          <div className="absolute top-1/2 right-20 w-6 h-6 bg-green-500 rounded-full"></div>
        </div>

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative">
          <div className="grid lg:grid-cols-2 gap-12 items-center">
            {/* Left Content */}
            <div>
              <div className="inline-flex items-center bg-green-100 text-green-700 px-4 py-2 rounded-full text-sm font-semibold mb-6">
                <Gift className="h-4 w-4 mr-2" />
                Save up to 50% on every meal
              </div>
              
              <h1 className="text-5xl md:text-6xl lg:text-7xl font-black text-gray-900 leading-tight mb-6">
                Rescue Food,
                <span className="text-green-600 block">Save Money!</span>
              </h1>
              
              <p className="text-xl text-gray-600 mb-8 leading-relaxed">
                Join thousands of food lovers who are fighting food waste while enjoying delicious meals at unbeatable prices. Find surprise bags from your favorite local restaurants!
              </p>
              
              {/* App Download Buttons - Yindii Style */}
              <div className="flex flex-col sm:flex-row gap-4 mb-8">
                <a href="#" className="inline-flex items-center justify-center bg-black hover:bg-gray-800 text-white px-8 py-4 rounded-2xl transition-all transform hover:scale-105">
                  <svg className="w-8 h-8 mr-3" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.12 1.87-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.54 4.09l.01-.01zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z"/>
                  </svg>
                  <div className="text-left">
                    <div className="text-xs opacity-80">Download on the</div>
                    <div className="text-lg font-semibold">App Store</div>
                  </div>
                </a>
                
                <a href="#" className="inline-flex items-center justify-center bg-black hover:bg-gray-800 text-white px-8 py-4 rounded-2xl transition-all transform hover:scale-105">
                  <svg className="w-8 h-8 mr-3" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M3,20.5V3.5C3,2.91 3.34,2.39 3.84,2.15L13.69,12L3.84,21.85C3.34,21.6 3,21.09 3,20.5M16.81,15.12L6.05,21.34L14.54,12.85L16.81,15.12M20.16,10.81C20.5,11.08 20.75,11.5 20.75,12C20.75,12.5 20.53,12.9 20.18,13.18L17.89,14.5L15.39,12L17.89,9.5L20.16,10.81M6.05,2.66L16.81,8.88L14.54,11.15L6.05,2.66Z"/>
                  </svg>
                  <div className="text-left">
                    <div className="text-xs opacity-80">Get it on</div>
                    <div className="text-lg font-semibold">Google Play</div>
                  </div>
                </a>
              </div>

              {/* Trust Indicators */}
              <div className="flex items-center gap-8">
                <div className="flex items-center">
                  <div className="flex -space-x-2">
                    <div className="w-10 h-10 bg-green-200 rounded-full border-2 border-white"></div>
                    <div className="w-10 h-10 bg-green-300 rounded-full border-2 border-white"></div>
                    <div className="w-10 h-10 bg-green-400 rounded-full border-2 border-white"></div>
                  </div>
                  <span className="ml-3 text-sm text-gray-600">50K+ Happy Users</span>
                </div>
                <div className="flex items-center">
                  <Star className="h-5 w-5 text-yellow-400 fill-current" />
                  <span className="ml-1 font-semibold">4.8</span>
                  <span className="ml-1 text-sm text-gray-600">(2.5k reviews)</span>
                </div>
              </div>
            </div>

            {/* Right Content - Phone Mockup */}
            <div className="relative">
              <div className="relative mx-auto max-w-md">
                {/* Phone Frame */}
                <div className="relative bg-gray-900 rounded-[3rem] p-4 shadow-2xl transform rotate-6 hover:rotate-3 transition-transform duration-300">
                  <div className="bg-white rounded-[2.5rem] overflow-hidden">
                    {/* Phone Screen Content */}
                    <div className="bg-gradient-to-b from-green-50 to-white p-6 h-[600px]">
                      <div className="flex items-center justify-between mb-6">
                        <div className="text-xl font-bold text-gray-900">Grabeat</div>
                        <MapPin className="h-5 w-5 text-green-600" />
                      </div>
                      
                      {/* Mock Food Cards */}
                      <div className="space-y-4">
                        <div className="bg-white rounded-2xl p-4 shadow-md">
                          <div className="flex items-start gap-4">
                            <div className="w-20 h-20 bg-green-100 rounded-xl flex items-center justify-center">
                              <Utensils className="h-8 w-8 text-green-600" />
                            </div>
                            <div className="flex-1">
                              <h3 className="font-semibold text-gray-900">Surprise Bag - Pizza Place</h3>
                              <p className="text-sm text-gray-600 mt-1">Save 3 meals from waste</p>
                              <div className="flex items-center justify-between mt-2">
                                <span className="text-2xl font-bold text-green-600">$4.99</span>
                                <span className="text-sm text-gray-500 line-through">$15.00</span>
                              </div>
                            </div>
                          </div>
                        </div>

                        <div className="bg-white rounded-2xl p-4 shadow-md">
                          <div className="flex items-start gap-4">
                            <div className="w-20 h-20 bg-orange-100 rounded-xl flex items-center justify-center">
                              <ShoppingBag className="h-8 w-8 text-orange-600" />
                            </div>
                            <div className="flex-1">
                              <h3 className="font-semibold text-gray-900">Bakery Magic Box</h3>
                              <p className="text-sm text-gray-600 mt-1">Fresh pastries & bread</p>
                              <div className="flex items-center justify-between mt-2">
                                <span className="text-2xl font-bold text-green-600">$3.99</span>
                                <span className="text-sm text-gray-500 line-through">$12.00</span>
                              </div>
                            </div>
                          </div>
                        </div>

                        <div className="bg-white rounded-2xl p-4 shadow-md">
                          <div className="flex items-start gap-4">
                            <div className="w-20 h-20 bg-purple-100 rounded-xl flex items-center justify-center">
                              <Heart className="h-8 w-8 text-purple-600" />
                            </div>
                            <div className="flex-1">
                              <h3 className="font-semibold text-gray-900">Healthy Bowl Surprise</h3>
                              <p className="text-sm text-gray-600 mt-1">Nutritious & delicious</p>
                              <div className="flex items-center justify-between mt-2">
                                <span className="text-2xl font-bold text-green-600">$5.99</span>
                                <span className="text-sm text-gray-500 line-through">$18.00</span>
                              </div>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Floating Elements */}
                <div className="absolute -top-4 -left-4 bg-yellow-400 text-gray-900 px-4 py-2 rounded-full font-bold text-sm animate-bounce">
                  -70% OFF
                </div>
                <div className="absolute -bottom-4 -right-4 bg-green-600 text-white px-4 py-2 rounded-full font-bold text-sm animate-pulse">
                  ECO FRIENDLY
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Stats Section - Yindii Style */}
      <section className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
            <div className="text-center">
              <div className="text-4xl md:text-5xl font-black text-green-600">2M+</div>
              <div className="text-gray-600 mt-2 font-medium">Meals Saved</div>
            </div>
            <div className="text-center">
              <div className="text-4xl md:text-5xl font-black text-green-600">50K+</div>
              <div className="text-gray-600 mt-2 font-medium">Active Users</div>
            </div>
            <div className="text-center">
              <div className="text-4xl md:text-5xl font-black text-green-600">500+</div>
              <div className="text-gray-600 mt-2 font-medium">Partner Stores</div>
            </div>
            <div className="text-center">
              <div className="text-4xl md:text-5xl font-black text-green-600">70%</div>
              <div className="text-gray-600 mt-2 font-medium">Avg. Savings</div>
            </div>
          </div>
        </div>
      </section>

      {/* How It Works - Yindii Style Cards */}
      <section className="py-20 bg-gradient-to-b from-white to-green-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <div className="inline-flex items-center bg-green-100 text-green-700 px-4 py-2 rounded-full text-sm font-semibold mb-4">
              <Check className="h-4 w-4 mr-2" />
              Super Simple Process
            </div>
            <h2 className="text-4xl md:text-5xl font-black text-gray-900 mb-4">
              How Grabeat Works
            </h2>
            <p className="text-xl text-gray-600 max-w-2xl mx-auto">
              Save food, save money, and discover amazing meals in just 3 simple steps
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            {/* Step 1 */}
            <div className="relative group">
              <div className="bg-white rounded-3xl p-8 shadow-lg hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-2">
                <div className="w-16 h-16 bg-green-100 text-green-600 rounded-2xl flex items-center justify-center text-2xl font-black mb-6">
                  1
                </div>
                <div className="w-20 h-20 bg-gradient-to-br from-green-400 to-green-600 rounded-2xl flex items-center justify-center mb-6">
                  <Search className="h-10 w-10 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-gray-900 mb-4">Browse & Discover</h3>
                <p className="text-gray-600 leading-relaxed">
                  Open the app to discover available Surprise Bags from stores near you. Filter by pickup time, dietary preferences, or store type.
                </p>
              </div>
              {/* Connector */}
              <div className="hidden md:block absolute top-1/2 right-0 transform translate-x-1/2 -translate-y-1/2 z-10">
                <ChevronRight className="h-8 w-8 text-green-400" />
              </div>
            </div>

            {/* Step 2 */}
            <div className="relative group">
              <div className="bg-white rounded-3xl p-8 shadow-lg hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-2">
                <div className="w-16 h-16 bg-green-100 text-green-600 rounded-2xl flex items-center justify-center text-2xl font-black mb-6">
                  2
                </div>
                <div className="w-20 h-20 bg-gradient-to-br from-orange-400 to-orange-600 rounded-2xl flex items-center justify-center mb-6">
                  <ShoppingBag className="h-10 w-10 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-gray-900 mb-4">Reserve & Pay</h3>
                <p className="text-gray-600 leading-relaxed">
                  Reserve your Surprise Bag with just a tap and pay directly through the app. It's quick, secure, and contactless.
                </p>
              </div>
              {/* Connector */}
              <div className="hidden md:block absolute top-1/2 right-0 transform translate-x-1/2 -translate-y-1/2 z-10">
                <ChevronRight className="h-8 w-8 text-green-400" />
              </div>
            </div>

            {/* Step 3 */}
            <div className="relative group">
              <div className="bg-white rounded-3xl p-8 shadow-lg hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-2">
                <div className="w-16 h-16 bg-green-100 text-green-600 rounded-2xl flex items-center justify-center text-2xl font-black mb-6">
                  3
                </div>
                <div className="w-20 h-20 bg-gradient-to-br from-purple-400 to-purple-600 rounded-2xl flex items-center justify-center mb-6">
                  <Heart className="h-10 w-10 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-gray-900 mb-4">Collect & Enjoy</h3>
                <p className="text-gray-600 leading-relaxed">
                  Pick up your Surprise Bag at the designated time, enjoy your delicious meal, and feel good about fighting food waste!
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Grid - Yindii Style */}
      <section className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-4xl md:text-5xl font-black text-gray-900 mb-4">
              Why Choose Grabeat?
            </h2>
            <p className="text-xl text-gray-600 max-w-2xl mx-auto">
              Join the food waste revolution and enjoy incredible benefits
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {/* Feature 1 */}
            <div className="bg-gradient-to-br from-green-50 to-green-100 rounded-3xl p-8 hover:shadow-xl transition-all duration-300">
              <div className="w-14 h-14 bg-green-600 rounded-2xl flex items-center justify-center mb-6">
                <Percent className="h-7 w-7 text-white" />
              </div>
              <h3 className="text-xl font-bold text-gray-900 mb-3">Save Big Money</h3>
              <p className="text-gray-600">Get premium meals at 50-70% off regular prices. Save hundreds of dollars every month!</p>
            </div>

            {/* Feature 2 */}
            <div className="bg-gradient-to-br from-orange-50 to-orange-100 rounded-3xl p-8 hover:shadow-xl transition-all duration-300">
              <div className="w-14 h-14 bg-orange-600 rounded-2xl flex items-center justify-center mb-6">
                <Clock className="h-7 w-7 text-white" />
              </div>
              <h3 className="text-xl font-bold text-gray-900 mb-3">Real-Time Updates</h3>
              <p className="text-gray-600">Get instant notifications when your favorite stores post new Surprise Bags.</p>
            </div>

            {/* Feature 3 */}
            <div className="bg-gradient-to-br from-purple-50 to-purple-100 rounded-3xl p-8 hover:shadow-xl transition-all duration-300">
              <div className="w-14 h-14 bg-purple-600 rounded-2xl flex items-center justify-center mb-6">
                <MapPin className="h-7 w-7 text-white" />
              </div>
              <h3 className="text-xl font-bold text-gray-900 mb-3">Near You</h3>
              <p className="text-gray-600">Discover hidden gems and favorite spots in your neighborhood.</p>
            </div>

            {/* Feature 4 */}
            <div className="bg-gradient-to-br from-blue-50 to-blue-100 rounded-3xl p-8 hover:shadow-xl transition-all duration-300">
              <div className="w-14 h-14 bg-blue-600 rounded-2xl flex items-center justify-center mb-6">
                <Gift className="h-7 w-7 text-white" />
              </div>
              <h3 className="text-xl font-bold text-gray-900 mb-3">Surprise Element</h3>
              <p className="text-gray-600">Every bag is a delightful surprise! Discover new favorites with each order.</p>
            </div>

            {/* Feature 5 */}
            <div className="bg-gradient-to-br from-red-50 to-red-100 rounded-3xl p-8 hover:shadow-xl transition-all duration-300">
              <div className="w-14 h-14 bg-red-600 rounded-2xl flex items-center justify-center mb-6">
                <Heart className="h-7 w-7 text-white" />
              </div>
              <h3 className="text-xl font-bold text-gray-900 mb-3">Feel Good</h3>
              <p className="text-gray-600">Every meal saved helps reduce food waste and protect our planet.</p>
            </div>

            {/* Feature 6 */}
            <div className="bg-gradient-to-br from-yellow-50 to-yellow-100 rounded-3xl p-8 hover:shadow-xl transition-all duration-300">
              <div className="w-14 h-14 bg-yellow-600 rounded-2xl flex items-center justify-center mb-6">
                <Star className="h-7 w-7 text-white" />
              </div>
              <h3 className="text-xl font-bold text-gray-900 mb-3">Top Rated</h3>
              <p className="text-gray-600">Join thousands of satisfied users who rate us 4.8/5 stars!</p>
            </div>
          </div>
        </div>
      </section>

      {/* Restaurant CTA - Yindii Style */}
      <section className="py-20 bg-gradient-to-br from-green-600 to-green-700 relative overflow-hidden">
        {/* Background Pattern */}
        <div className="absolute inset-0 opacity-10">
          <div className="absolute top-10 left-10 w-20 h-20 bg-white rounded-full"></div>
          <div className="absolute bottom-10 right-10 w-32 h-32 bg-white rounded-full"></div>
          <div className="absolute top-1/2 left-1/3 w-16 h-16 bg-white rounded-full"></div>
        </div>

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center relative">
          <div className="inline-flex items-center bg-white/20 text-white px-4 py-2 rounded-full text-sm font-semibold mb-6">
            <Utensils className="h-4 w-4 mr-2" />
            For Restaurant Partners
          </div>
          
          <h2 className="text-4xl md:text-5xl font-black text-white mb-4">
            Own a Restaurant?
          </h2>
          <p className="text-xl text-green-100 mb-8 max-w-2xl mx-auto">
            Turn your surplus food into profit while attracting new customers and reducing waste. Join 500+ successful partners!
          </p>
          
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link 
              to="/restaurants"
              className="inline-flex items-center justify-center bg-white text-green-600 px-8 py-4 rounded-full font-bold hover:bg-gray-50 transition-all transform hover:scale-105"
            >
              Become a Partner
              <ArrowRight className="ml-2 h-5 w-5" />
            </Link>
            <a 
              href="#"
              className="inline-flex items-center justify-center bg-transparent border-2 border-white text-white px-8 py-4 rounded-full font-bold hover:bg-white/10 transition-all"
            >
              Learn More
            </a>
          </div>

          {/* Partner Logos */}
          <div className="mt-12">
            <p className="text-green-100 text-sm mb-6">Trusted by leading brands</p>
            <div className="flex justify-center items-center gap-8 opacity-70">
              <div className="w-24 h-12 bg-white/20 rounded-lg"></div>
              <div className="w-24 h-12 bg-white/20 rounded-lg"></div>
              <div className="w-24 h-12 bg-white/20 rounded-lg"></div>
              <div className="w-24 h-12 bg-white/20 rounded-lg hidden md:block"></div>
              <div className="w-24 h-12 bg-white/20 rounded-lg hidden md:block"></div>
            </div>
          </div>
        </div>
      </section>

      {/* Download Section - Final CTA */}
      <section id="download" className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="bg-gradient-to-br from-green-50 to-green-100 rounded-3xl p-12 md:p-16 text-center relative overflow-hidden">
            {/* Decorative Elements */}
            <div className="absolute top-0 right-0 w-40 h-40 bg-green-200 rounded-full opacity-20 -translate-y-1/2 translate-x-1/2"></div>
            <div className="absolute bottom-0 left-0 w-32 h-32 bg-green-300 rounded-full opacity-20 translate-y-1/2 -translate-x-1/2"></div>
            
            <div className="relative">
              <h2 className="text-4xl md:text-5xl font-black text-gray-900 mb-4">
                Start Saving Today!
              </h2>
              <p className="text-xl text-gray-600 mb-8 max-w-2xl mx-auto">
                Download Grabeat now and join the food saving revolution. Your first Surprise Bag is waiting!
              </p>
              
              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <a href="#" className="inline-flex items-center justify-center bg-black hover:bg-gray-800 text-white px-8 py-4 rounded-2xl transition-all transform hover:scale-105">
                  <svg className="w-8 h-8 mr-3" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.12 1.87-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.54 4.09l.01-.01zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z"/>
                  </svg>
                  <div className="text-left">
                    <div className="text-xs opacity-80">Download on the</div>
                    <div className="text-lg font-semibold">App Store</div>
                  </div>
                </a>
                
                <a href="#" className="inline-flex items-center justify-center bg-black hover:bg-gray-800 text-white px-8 py-4 rounded-2xl transition-all transform hover:scale-105">
                  <svg className="w-8 h-8 mr-3" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M3,20.5V3.5C3,2.91 3.34,2.39 3.84,2.15L13.69,12L3.84,21.85C3.34,21.6 3,21.09 3,20.5M16.81,15.12L6.05,21.34L14.54,12.85L16.81,15.12M20.16,10.81C20.5,11.08 20.75,11.5 20.75,12C20.75,12.5 20.53,12.9 20.18,13.18L17.89,14.5L15.39,12L17.89,9.5L20.16,10.81M6.05,2.66L16.81,8.88L14.54,11.15L6.05,2.66Z"/>
                  </svg>
                  <div className="text-left">
                    <div className="text-xs opacity-80">Get it on</div>
                    <div className="text-lg font-semibold">Google Play</div>
                  </div>
                </a>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Footer - Yindii Style */}
      <footer className="bg-gray-900 text-white py-16">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8 mb-12">
            <div className="col-span-2 md:col-span-1">
              <div className="text-3xl font-black text-green-400 mb-4">Grabeat</div>
              <p className="text-gray-400 mb-6">
                Fighting food waste, one meal at a time.
              </p>
              <div className="flex gap-4">
                <a href="#" className="w-10 h-10 bg-gray-800 rounded-full flex items-center justify-center hover:bg-green-600 transition-colors">
                  <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
                  </svg>
                </a>
                <a href="#" className="w-10 h-10 bg-gray-800 rounded-full flex items-center justify-center hover:bg-green-600 transition-colors">
                  <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M23.953 4.57a10 10 0 01-2.825.775 4.958 4.958 0 002.163-2.723c-.951.555-2.005.959-3.127 1.184a4.92 4.92 0 00-8.384 4.482C7.69 8.095 4.067 6.13 1.64 3.162a4.822 4.822 0 00-.666 2.475c0 1.71.87 3.213 2.188 4.096a4.904 4.904 0 01-2.228-.616v.06a4.923 4.923 0 003.946 4.827 4.996 4.996 0 01-2.212.085 4.936 4.936 0 004.604 3.417 9.867 9.867 0 01-6.102 2.105c-.39 0-.779-.023-1.17-.067a13.995 13.995 0 007.557 2.209c9.053 0 13.998-7.496 13.998-13.985 0-.21 0-.42-.015-.63A9.935 9.935 0 0024 4.59z"/>
                  </svg>
                </a>
                <a href="#" className="w-10 h-10 bg-gray-800 rounded-full flex items-center justify-center hover:bg-green-600 transition-colors">
                  <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zM5.838 12a6.162 6.162 0 1112.324 0 6.162 6.162 0 01-12.324 0zM12 16a4 4 0 110-8 4 4 0 010 8zm4.965-10.405a1.44 1.44 0 112.881.001 1.44 1.44 0 01-2.881-.001z"/>
                  </svg>
                </a>
              </div>
            </div>

            <div>
              <h4 className="font-semibold text-white mb-4">Company</h4>
              <ul className="space-y-2">
                <li><a href="#" className="text-gray-400 hover:text-green-400 transition-colors">About Us</a></li>
                <li><a href="#" className="text-gray-400 hover:text-green-400 transition-colors">Careers</a></li>
                <li><a href="#" className="text-gray-400 hover:text-green-400 transition-colors">Press</a></li>
                <li><a href="#" className="text-gray-400 hover:text-green-400 transition-colors">Blog</a></li>
              </ul>
            </div>

            <div>
              <h4 className="font-semibold text-white mb-4">Support</h4>
              <ul className="space-y-2">
                <li><a href="#" className="text-gray-400 hover:text-green-400 transition-colors">Help Center</a></li>
                <li><a href="#" className="text-gray-400 hover:text-green-400 transition-colors">Contact Us</a></li>
                <li><a href="#" className="text-gray-400 hover:text-green-400 transition-colors">FAQs</a></li>
                <li><a href="#" className="text-gray-400 hover:text-green-400 transition-colors">Safety</a></li>
              </ul>
            </div>

            <div>
              <h4 className="font-semibold text-white mb-4">Legal</h4>
              <ul className="space-y-2">
                <li><a href="#" className="text-gray-400 hover:text-green-400 transition-colors">Terms</a></li>
                <li><a href="#" className="text-gray-400 hover:text-green-400 transition-colors">Privacy</a></li>
                <li><a href="#" className="text-gray-400 hover:text-green-400 transition-colors">Cookies</a></li>
              </ul>
            </div>
          </div>

          <div className="border-t border-gray-800 pt-8">
            <div className="flex flex-col md:flex-row justify-between items-center">
              <p className="text-gray-400 text-sm">
                © 2025 Grabeat. All rights reserved. Made with 💚 for the planet.
              </p>
              <div className="flex gap-6 mt-4 md:mt-0">
                <a href="#" className="text-gray-400 hover:text-green-400 text-sm transition-colors">Terms of Service</a>
                <a href="#" className="text-gray-400 hover:text-green-400 text-sm transition-colors">Privacy Policy</a>
                <a href="#" className="text-gray-400 hover:text-green-400 text-sm transition-colors">Cookie Policy</a>
              </div>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default LandingPage;