import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import BusinessOnboarding from './pages/BusinessOnboarding';
import OAuthCallback from './pages/OAuthCallback';
import FoodLibrary from './pages/FoodLibrary';
import ProtectedRoute from './components/ProtectedRoute';
import './App.css';

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Login />} />
        <Route path="/callback" element={<OAuthCallback />} />
        <Route 
          path="/dashboard" 
          element={
            <ProtectedRoute>
              <Dashboard />
            </ProtectedRoute>
          } 
        />
        <Route 
          path="/onboarding" 
          element={
            <ProtectedRoute>
              <BusinessOnboarding />
            </ProtectedRoute>
          } 
        />
        <Route 
          path="/food-library" 
          element={
            <ProtectedRoute>
              <FoodLibrary />
            </ProtectedRoute>
          } 
        />
      </Routes>
    </Router>
  );
}

export default App
