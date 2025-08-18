import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Loader2, CheckCircle, XCircle } from 'lucide-react';
import { useAuth } from '../hooks/useAuth';

const OAuthCallback: React.FC = () => {
  const [status, setStatus] = useState<'loading' | 'success' | 'error'>('loading');
  const [error, setError] = useState<string>('');
  const { handleOAuthCallback } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    let mounted = true;
    
    const processCallback = async () => {
      try {
        if (!mounted) return;
        
        setStatus('loading');
        await handleOAuthCallback();
        
        if (mounted) {
          setStatus('success');
          setTimeout(() => {
            if (mounted) {
              navigate('/dashboard', { replace: true });
            }
          }, 2000);
        }
      } catch (err: any) {
        console.error('OAuth callback error:', err);
        if (mounted) {
          setError(err.message || 'Authentication failed');
          setStatus('error');
        }
      }
    };

    processCallback();
    
    return () => {
      mounted = false;
    };
  }, []);

  const getContent = () => {
    switch (status) {
      case 'loading':
        return {
          icon: <Loader2 className="h-16 w-16 text-green-600 animate-spin" />,
          title: 'Verifying your credentials...',
          subtitle: 'Please wait while we check your admin access',
        };
      
      case 'success':
        return {
          icon: <CheckCircle className="h-16 w-16 text-green-600" />,
          title: 'Authentication successful!',
          subtitle: 'Redirecting to admin dashboard...',
        };
      
      case 'error':
        return {
          icon: <XCircle className="h-16 w-16 text-red-600" />,
          title: 'Authentication failed',
          subtitle: error,
        };
    }
  };

  const content = getContent();

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 to-green-100 flex items-center justify-center px-4">
      <div className="max-w-md w-full">
        <div className="bg-white rounded-2xl shadow-xl p-8 text-center">
          <div className="mb-8">
            <h1 className="text-3xl font-black text-green-600">Grabeat Admin</h1>
          </div>

          <div className="flex justify-center mb-6">
            {content.icon}
          </div>

          <h2 className="text-2xl font-bold text-gray-900 mb-2">
            {content.title}
          </h2>
          <p className="text-gray-600 mb-8">
            {content.subtitle}
          </p>

          {status === 'error' && (
            <div className="space-y-4">
              <a
                href="/"
                className="w-full bg-green-600 hover:bg-green-700 text-white font-medium py-3 px-4 rounded-lg transition-colors duration-200 inline-block"
              >
                Try Again
              </a>
              <div className="mt-6 p-4 bg-red-50 rounded-lg">
                <h4 className="text-sm font-medium text-red-800 mb-2">
                  Common Issues:
                </h4>
                <ul className="text-xs text-red-700 space-y-1 text-left">
                  <li>• Your Google account email is not in the admin database</li>
                  <li>• Contact system administrator for access</li>
                </ul>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default OAuthCallback;