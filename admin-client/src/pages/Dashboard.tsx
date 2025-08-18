import React from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  Users, 
  Store, 
  ShoppingBag, 
  TrendingUp, 
  LogOut,
  Settings,
  Bell,
  Menu,
  AlertCircle,
  RefreshCw
} from 'lucide-react';
import { useAuth } from '../hooks/useAuth';
import { useDashboardStats, useRecentActivities } from '../hooks/useDashboardData';

const Dashboard: React.FC = () => {
  const { logout, currentUserEmail } = useAuth();
  const navigate = useNavigate();
  const [sidebarOpen, setSidebarOpen] = React.useState(true);

  // Fetch dashboard data
  const { stats: statsData, loading: statsLoading, error: statsError, refetch: refetchStats } = useDashboardStats();
  const { activities, loading: activitiesLoading, error: activitiesError, refetch: refetchActivities } = useRecentActivities();

  const handleLogout = async () => {
    await logout();
    navigate('/');
  };

  const handleRefresh = () => {
    refetchStats();
    refetchActivities();
  };

  // Convert API data to display format
  const stats = statsData ? [
    { label: 'Total Users', value: statsData.totalUsers, icon: Users, change: statsData.userGrowth },
    { label: 'Active Businesses', value: statsData.totalBusinesses, icon: Store, change: statsData.businessGrowth },
    { label: 'Total Orders', value: statsData.totalOrders, icon: ShoppingBag, change: statsData.orderGrowth },
    { label: 'Revenue', value: statsData.totalRevenue, icon: TrendingUp, change: statsData.revenueGrowth },
  ] : [];

  const menuItems = [
    { label: 'Dashboard', icon: TrendingUp, active: true, path: '/dashboard' },
    { label: 'Business Onboarding', icon: Store, path: '/onboarding' },
    { label: 'Users', icon: Users },
    { label: 'Businesses', icon: Store },
    { label: 'Orders', icon: ShoppingBag },
    { label: 'Settings', icon: Settings },
  ];

  return (
    <div className="min-h-screen bg-gray-50 flex">
      {/* Sidebar */}
      <div className={`${sidebarOpen ? 'w-64' : 'w-20'} bg-white shadow-lg transition-all duration-300`}>
        <div className="p-4">
          <div className="flex items-center justify-between">
            <h1 className={`font-black text-green-600 ${sidebarOpen ? 'text-2xl' : 'text-xl'}`}>
              {sidebarOpen ? 'Grabeat Admin' : 'GA'}
            </h1>
            <button
              onClick={() => setSidebarOpen(!sidebarOpen)}
              className="p-2 hover:bg-gray-100 rounded-lg"
            >
              <Menu className="h-5 w-5 text-gray-600" />
            </button>
          </div>
        </div>

        <nav className="mt-8">
          {menuItems.map((item) => (
            item.path ? (
              <button
                key={item.label}
                onClick={() => navigate(item.path!)}
                className={`flex items-center px-4 py-3 text-gray-700 hover:bg-green-50 hover:text-green-600 transition-colors w-full text-left ${
                  item.active ? 'bg-green-50 text-green-600 border-r-4 border-green-600' : ''
                }`}
              >
                <item.icon className="h-5 w-5" />
                {sidebarOpen && <span className="ml-3">{item.label}</span>}
              </button>
            ) : (
              <a
                key={item.label}
                href="#"
                className={`flex items-center px-4 py-3 text-gray-700 hover:bg-green-50 hover:text-green-600 transition-colors ${
                  item.active ? 'bg-green-50 text-green-600 border-r-4 border-green-600' : ''
                }`}
              >
                <item.icon className="h-5 w-5" />
                {sidebarOpen && <span className="ml-3">{item.label}</span>}
              </a>
            )
          ))}
        </nav>

        <div className="absolute bottom-0 w-full p-4">
          <button
            onClick={handleLogout}
            className="flex items-center text-gray-700 hover:text-red-600 transition-colors w-full"
          >
            <LogOut className="h-5 w-5" />
            {sidebarOpen && <span className="ml-3">Logout</span>}
          </button>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1">
        {/* Header */}
        <header className="bg-white shadow-sm">
          <div className="flex items-center justify-between px-8 py-4">
            <h2 className="text-2xl font-semibold text-gray-800">Dashboard</h2>
            <div className="flex items-center space-x-4">
              <button
                onClick={handleRefresh}
                className="p-2 hover:bg-gray-100 rounded-lg"
                disabled={statsLoading || activitiesLoading}
              >
                <RefreshCw className={`h-5 w-5 text-gray-600 ${statsLoading || activitiesLoading ? 'animate-spin' : ''}`} />
              </button>
              <button className="p-2 hover:bg-gray-100 rounded-lg relative">
                <Bell className="h-5 w-5 text-gray-600" />
                <span className="absolute top-1 right-1 h-2 w-2 bg-red-500 rounded-full"></span>
              </button>
              <div className="flex items-center space-x-2">
                <div className="w-8 h-8 bg-green-600 rounded-full flex items-center justify-center text-white font-semibold">
                  {currentUserEmail.charAt(0).toUpperCase()}
                </div>
                <span className="text-gray-700 text-sm">{currentUserEmail}</span>
              </div>
            </div>
          </div>
        </header>

        {/* Stats Grid */}
        <div className="p-8">
          {statsError && (
            <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg flex items-start">
              <AlertCircle className="h-5 w-5 text-red-600 mr-2 flex-shrink-0 mt-0.5" />
              <span className="text-sm text-red-800">Failed to load statistics: {statsError}</span>
            </div>
          )}
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            {statsLoading ? (
              // Loading skeletons
              Array.from({ length: 4 }).map((_, i) => (
                <div key={i} className="bg-white rounded-xl shadow-sm p-6 animate-pulse">
                  <div className="flex items-center justify-between mb-4">
                    <div className="w-12 h-12 bg-gray-200 rounded-lg"></div>
                    <div className="w-12 h-4 bg-gray-200 rounded"></div>
                  </div>
                  <div className="w-20 h-8 bg-gray-200 rounded mb-2"></div>
                  <div className="w-24 h-4 bg-gray-200 rounded"></div>
                </div>
              ))
            ) : (
              stats.map((stat) => (
                <div key={stat.label} className="bg-white rounded-xl shadow-sm p-6">
                  <div className="flex items-center justify-between mb-4">
                    <div className="p-3 bg-green-100 rounded-lg">
                      <stat.icon className="h-6 w-6 text-green-600" />
                    </div>
                    <span className="text-green-600 text-sm font-medium">{stat.change}</span>
                  </div>
                  <h3 className="text-2xl font-bold text-gray-800">{stat.value}</h3>
                  <p className="text-gray-600 text-sm mt-1">{stat.label}</p>
                </div>
              ))
            )}
          </div>

          {/* Recent Activity */}
          <div className="bg-white rounded-xl shadow-sm p-6">
            <h3 className="text-lg font-semibold text-gray-800 mb-4">Recent Activity</h3>
            
            {activitiesError && (
              <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg flex items-start">
                <AlertCircle className="h-5 w-5 text-red-600 mr-2 flex-shrink-0 mt-0.5" />
                <span className="text-sm text-red-800">Failed to load activities: {activitiesError}</span>
              </div>
            )}
            
            <div className="space-y-4">
              {activitiesLoading ? (
                // Loading skeletons
                Array.from({ length: 5 }).map((_, i) => (
                  <div key={i} className="flex items-center justify-between py-3 border-b border-gray-100 last:border-0 animate-pulse">
                    <div className="flex items-center space-x-3">
                      <div className="w-10 h-10 bg-gray-200 rounded-full"></div>
                      <div>
                        <div className="w-32 h-4 bg-gray-200 rounded mb-2"></div>
                        <div className="w-48 h-3 bg-gray-200 rounded"></div>
                      </div>
                    </div>
                    <div className="w-16 h-3 bg-gray-200 rounded"></div>
                  </div>
                ))
              ) : activities.length > 0 ? (
                activities.map((activity) => (
                  <div key={activity.id} className="flex items-center justify-between py-3 border-b border-gray-100 last:border-0">
                    <div className="flex items-center space-x-3">
                      <div className="w-10 h-10 bg-green-100 rounded-full flex items-center justify-center">
                        {activity.icon === 'store' ? (
                          <Store className="h-5 w-5 text-green-600" />
                        ) : (
                          <Users className="h-5 w-5 text-green-600" />
                        )}
                      </div>
                      <div>
                        <p className="text-sm font-medium text-gray-800">{activity.title}</p>
                        <p className="text-xs text-gray-500">{activity.description}</p>
                      </div>
                    </div>
                    <span className="text-xs text-gray-500">{activity.timeAgo}</span>
                  </div>
                ))
              ) : (
                <div className="text-center py-8 text-gray-500">
                  <p>No recent activity</p>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;