import React from 'react';
import { Link } from 'react-router-dom';
import { 
  Smartphone, 
  MapPin, 
  Clock, 
  Percent,
  Download,
  ArrowRight,
  Search,
  Bell,
  Heart
} from 'lucide-react';

const CustomerPage: React.FC = () => {
  return (
    <div className="min-h-screen bg-white">
      {/* Navigation */}
      <nav className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <Link to="/" className="flex items-center">
              <div className="text-2xl font-bold text-green-600">Grabeat</div>
              <span className="ml-2 text-sm text-gray-500">How It Works</span>
            </Link>
            <div className="flex items-center space-x-4">
              <Link to="/" className="text-gray-700 hover:text-green-600 font-medium">
                Back to Home
              </Link>
            </div>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="bg-gradient-to-br from-green-50 to-green-100 py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <h1 className="text-5xl md:text-6xl font-bold text-gray-900 mb-6">
              How Grabeat
              <span className="text-green-600 block">Works for You</span>
            </h1>
            <p className="text-xl text-gray-600 mb-8 max-w-2xl mx-auto">
              Discover amazing deals from local restaurants, save money on delicious meals, 
              and support your community—all through the Grabeat app.
            </p>
            
            <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
              <button className="bg-black text-white px-8 py-4 rounded-lg flex items-center space-x-3 hover:bg-gray-800 transition-colors">
                <Download className="h-5 w-5" />
                <div className="text-left">
                  <div className="text-xs text-gray-300">Download on the</div>
                  <div className="text-sm font-semibold">App Store</div>
                </div>
              </button>
              <button className="bg-black text-white px-8 py-4 rounded-lg flex items-center space-x-3 hover:bg-gray-800 transition-colors">
                <Download className="h-5 w-5" />
                <div className="text-left">
                  <div className="text-xs text-gray-300">Get it on</div>
                  <div className="text-sm font-semibold">Google Play</div>
                </div>
              </button>
            </div>
          </div>
        </div>
      </section>

      {/* How It Works */}
      <section className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold text-gray-900 mb-4">
              Find Great Deals in 3 Simple Steps
            </h2>
            <p className="text-xl text-gray-600 max-w-2xl mx-auto">
              Saving money on delicious food has never been easier.
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            <div className="text-center">
              <div className="bg-green-600 text-white rounded-full w-16 h-16 flex items-center justify-center mx-auto mb-6 text-2xl font-bold">
                1
              </div>
              <Search className="h-12 w-12 text-green-600 mx-auto mb-4" />
              <h3 className="text-2xl font-bold text-gray-900 mb-4">Discover Deals</h3>
              <p className="text-gray-600">
                Browse real-time deals from restaurants near you. Filter by cuisine type, price, or pickup time.
              </p>
            </div>

            <div className="text-center">
              <div className="bg-green-600 text-white rounded-full w-16 h-16 flex items-center justify-center mx-auto mb-6 text-2xl font-bold">
                2
              </div>
              <Smartphone className="h-12 w-12 text-green-600 mx-auto mb-4" />
              <h3 className="text-2xl font-bold text-gray-900 mb-4">Order & Pay</h3>
              <p className="text-gray-600">
                Reserve your deal with a tap. Pay securely through the app and get instant confirmation.
              </p>
            </div>

            <div className="text-center">
              <div className="bg-green-600 text-white rounded-full w-16 h-16 flex items-center justify-center mx-auto mb-6 text-2xl font-bold">
                3
              </div>
              <MapPin className="h-12 w-12 text-green-600 mx-auto mb-4" />
              <h3 className="text-2xl font-bold text-gray-900 mb-4">Pick Up & Enjoy</h3>
              <p className="text-gray-600">
                Head to the restaurant during your pickup window and enjoy your discounted meal.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* App Features */}
      <section className="py-20 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold text-gray-900 mb-4">
              App Features You'll Love
            </h2>
            <p className="text-xl text-gray-600 max-w-2xl mx-auto">
              Everything you need to find and enjoy amazing food deals is built right into the app.
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            <div className="bg-white p-8 rounded-2xl shadow-lg">
              <div className="bg-green-100 rounded-full p-4 w-16 h-16 flex items-center justify-center mb-6">
                <Clock className="h-8 w-8 text-green-600" />
              </div>
              <h3 className="text-xl font-bold text-gray-900 mb-4">Real-Time Updates</h3>
              <p className="text-gray-600">
                See live availability and pickup times. Never arrive to find out your deal is sold out.
              </p>
            </div>

            <div className="bg-white p-8 rounded-2xl shadow-lg">
              <div className="bg-green-100 rounded-full p-4 w-16 h-16 flex items-center justify-center mb-6">
                <MapPin className="h-8 w-8 text-green-600" />
              </div>
              <h3 className="text-xl font-bold text-gray-900 mb-4">Location-Based</h3>
              <p className="text-gray-600">
                Find deals near you automatically. Set your preferred radius and discover new favorites.
              </p>
            </div>

            <div className="bg-white p-8 rounded-2xl shadow-lg">
              <div className="bg-green-100 rounded-full p-4 w-16 h-16 flex items-center justify-center mb-6">
                <Bell className="h-8 w-8 text-green-600" />
              </div>
              <h3 className="text-xl font-bold text-gray-900 mb-4">Smart Notifications</h3>
              <p className="text-gray-600">
                Get notified when your favorite restaurants post new deals or when great deals are near you.
              </p>
            </div>

            <div className="bg-white p-8 rounded-2xl shadow-lg">
              <div className="bg-green-100 rounded-full p-4 w-16 h-16 flex items-center justify-center mb-6">
                <Heart className="h-8 w-8 text-green-600" />
              </div>
              <h3 className="text-xl font-bold text-gray-900 mb-4">Favorites List</h3>
              <p className="text-gray-600">
                Save your favorite restaurants and get priority notifications when they post deals.
              </p>
            </div>

            <div className="bg-white p-8 rounded-2xl shadow-lg">
              <div className="bg-green-100 rounded-full p-4 w-16 h-16 flex items-center justify-center mb-6">
                <Search className="h-8 w-8 text-green-600" />
              </div>
              <h3 className="text-xl font-bold text-gray-900 mb-4">Smart Filters</h3>
              <p className="text-gray-600">
                Filter by cuisine type, price range, dietary preferences, or distance from you.
              </p>
            </div>

            <div className="bg-white p-8 rounded-2xl shadow-lg">
              <div className="bg-green-100 rounded-full p-4 w-16 h-16 flex items-center justify-center mb-6">
                <Percent className="h-8 w-8 text-green-600" />
              </div>
              <h3 className="text-xl font-bold text-gray-900 mb-4">Exclusive Deals</h3>
              <p className="text-gray-600">
                Access exclusive deals on all types of cuisines. Save up to 50% on your favorite meals.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Benefits Section */}
      <section className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold text-gray-900 mb-4">
              Why Food Lovers Choose Grabeat
            </h2>
            <p className="text-xl text-gray-600 max-w-2xl mx-auto">
              More than just discounts—discover new restaurants and support your local community.
            </p>
          </div>

          <div className="grid md:grid-cols-2 gap-12 items-center">
            <div>
              <h3 className="text-3xl font-bold text-gray-900 mb-6">Save Money & Discover New Favorites</h3>
              <div className="space-y-4">
                <div className="flex items-start">
                  <div className="bg-green-100 rounded-full p-2 mt-1">
                    <Percent className="h-4 w-4 text-green-600" />
                  </div>
                  <div className="ml-4">
                    <h4 className="font-semibold text-gray-900">Up to 50% Off</h4>
                    <p className="text-gray-600">Get significant discounts on high-quality meals from local restaurants.</p>
                  </div>
                </div>
                <div className="flex items-start">
                  <div className="bg-green-100 rounded-full p-2 mt-1">
                    <Search className="h-4 w-4 text-green-600" />
                  </div>
                  <div className="ml-4">
                    <h4 className="font-semibold text-gray-900">Discover Hidden Gems</h4>
                    <p className="text-gray-600">Find amazing restaurants you might never have tried otherwise.</p>
                  </div>
                </div>
                <div className="flex items-start">
                  <div className="bg-green-100 rounded-full p-2 mt-1">
                    <Heart className="h-4 w-4 text-green-600" />
                  </div>
                  <div className="ml-4">
                    <h4 className="font-semibold text-gray-900">Support Local Business</h4>
                    <p className="text-gray-600">Help reduce food waste while supporting neighborhood restaurants.</p>
                  </div>
                </div>
              </div>
            </div>
            <div className="bg-gradient-to-br from-green-50 to-green-100 p-8 rounded-2xl">
              <div className="text-center">
                <div className="text-4xl font-bold text-green-600 mb-2">$500+</div>
                <p className="text-gray-700 mb-4">Average annual savings per user</p>
                <div className="text-4xl font-bold text-green-600 mb-2">200+</div>
                <p className="text-gray-700 mb-4">Partner restaurants</p>
                <div className="text-4xl font-bold text-green-600 mb-2">50k+</div>
                <p className="text-gray-700">Happy customers served</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-green-600">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-4xl font-bold text-white mb-4">
            Ready to Start Saving?
          </h2>
          <p className="text-xl text-green-100 mb-8 max-w-2xl mx-auto">
            Download Grabeat today and discover amazing food deals in your neighborhood.
          </p>
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <button className="bg-black text-white px-8 py-4 rounded-lg flex items-center space-x-3 hover:bg-gray-800 transition-colors">
              <Download className="h-5 w-5" />
              <div className="text-left">
                <div className="text-xs text-gray-300">Download on the</div>
                <div className="text-sm font-semibold">App Store</div>
              </div>
            </button>
            <button className="bg-black text-white px-8 py-4 rounded-lg flex items-center space-x-3 hover:bg-gray-800 transition-colors">
              <Download className="h-5 w-5" />
              <div className="text-left">
                <div className="text-xs text-gray-300">Get it on</div>
                <div className="text-sm font-semibold">Google Play</div>
              </div>
            </button>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-white py-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <div className="text-2xl font-bold text-green-400 mb-4">Grabeat</div>
            <p className="text-gray-400">
              Connecting food lovers with amazing local restaurants through exclusive deals.
            </p>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default CustomerPage;