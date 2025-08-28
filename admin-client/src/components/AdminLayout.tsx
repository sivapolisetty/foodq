import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { 
  Users, 
  Store, 
  ShoppingBag, 
  TrendingUp, 
  LogOut,
  Settings,
  Bell,
  Menu,
  RefreshCw
} from 'lucide-react';
import { useAuth } from '../hooks/useAuth';

interface AdminLayoutProps {
  children: React.ReactNode;
  title: string;
  onRefresh?: () => void;
  refreshing?: boolean;
}

const AdminLayout: React.FC<AdminLayoutProps> = ({ 
  children, 
  title, 
  onRefresh, 
  refreshing = false 
}) => {
  const { logout, currentUserEmail } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [sidebarOpen, setSidebarOpen] = React.useState(true);

  const handleLogout = async () => {
    await logout();
    navigate('/');
  };

  const menuItems = [
    { label: 'Dashboard', icon: TrendingUp, path: '/dashboard' },
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
                  location.pathname === item.path ? 'bg-green-50 text-green-600 border-r-4 border-green-600' : ''
                }`}
              >
                <item.icon className="h-5 w-5" />
                {sidebarOpen && <span className="ml-3">{item.label}</span>}
              </button>
            ) : (
              <a
                key={item.label}
                href="#"
                className="flex items-center px-4 py-3 text-gray-700 hover:bg-green-50 hover:text-green-600 transition-colors"
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
            <h2 className="text-2xl font-semibold text-gray-800">{title}</h2>
            <div className="flex items-center space-x-4">
              {onRefresh && (
                <button
                  onClick={onRefresh}
                  className="p-2 hover:bg-gray-100 rounded-lg"
                  disabled={refreshing}
                >
                  <RefreshCw className={`h-5 w-5 text-gray-600 ${refreshing ? 'animate-spin' : ''}`} />
                </button>
              )}
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

        {/* Page Content */}
        <div className="p-8">
          {children}
        </div>
      </div>
    </div>
  );
};

export default AdminLayout;