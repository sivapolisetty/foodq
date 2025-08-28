import React, { useState, useEffect } from 'react';
import { 
  Store, 
  MapPin, 
  Phone, 
  Mail, 
  FileText,
  Check,
  X,
  Eye,
  AlertCircle,
  ArrowLeft,
  Loader2
} from 'lucide-react';
import { onboardingApiService } from '../services/onboardingApi';
import type { OnboardingRequest } from '../services/onboardingApi';
import AdminLayout from '../components/AdminLayout';

const BusinessOnboarding: React.FC = () => {
  const [requests, setRequests] = useState<OnboardingRequest[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedRequest, setSelectedRequest] = useState<OnboardingRequest | null>(null);
  const [actionLoading, setActionLoading] = useState<string | null>(null);
  const [showAllRequests, setShowAllRequests] = useState(false);

  const fetchRequests = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = showAllRequests 
        ? await onboardingApiService.getAllRequests()
        : await onboardingApiService.getPendingRequests();
      setRequests(data);
    } catch (err: any) {
      setError(err.message);
      console.error('Failed to fetch onboarding requests:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchRequests();
  }, [showAllRequests]);

  const handleApprove = async (requestId: string) => {
    try {
      setActionLoading(requestId);
      const request = requests.find(r => r.id === requestId);
      
      if (request?.status !== 'pending') {
        alert(`This request has already been ${request?.status}. Please refresh the page.`);
        return;
      }
      
      await onboardingApiService.approveRequest(requestId);
      
      // Refresh the list to get updated data
      await fetchRequests();
      setSelectedRequest(null);
      
      // Show success message (you could add a toast notification here)
      alert('Business approved successfully!');
    } catch (err: any) {
      if (err.message.includes('already approved')) {
        alert('This request has already been approved. Refreshing list...');
        await fetchRequests();
        setSelectedRequest(null);
      } else {
        alert(`Failed to approve business: ${err.message}`);
      }
    } finally {
      setActionLoading(null);
    }
  };

  const handleReject = async (requestId: string) => {
    try {
      setActionLoading(requestId);
      const request = requests.find(r => r.id === requestId);
      
      if (request?.status !== 'pending') {
        alert(`This request has already been ${request?.status}. Please refresh the page.`);
        return;
      }
      
      await onboardingApiService.rejectRequest(requestId);
      
      // Refresh the list to get updated data
      await fetchRequests();
      setSelectedRequest(null);
      
      // Show success message
      alert('Business request rejected successfully!');
    } catch (err: any) {
      alert(`Failed to reject business: ${err.message}`);
    } finally {
      setActionLoading(null);
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  if (selectedRequest) {
    return (
      <AdminLayout title="Business Details">
        <div className="max-w-4xl mx-auto">
          {/* Back Button */}
          <div className="flex items-center space-x-4 mb-8">
            <button
              onClick={() => setSelectedRequest(null)}
              className="p-2 hover:bg-gray-100 rounded-lg"
            >
              <ArrowLeft className="h-5 w-5 text-gray-600" />
            </button>
            <h1 className="text-2xl font-bold text-gray-800">Business Details</h1>
          </div>

          {/* Business Details Card */}
          <div className="bg-white rounded-xl shadow-sm p-8">
            <div className="flex items-start justify-between mb-6">
              <div>
                <h2 className="text-2xl font-bold text-gray-800 mb-2">{selectedRequest.restaurant_name}</h2>
                <div className="flex items-center text-gray-600 mb-4">
                  <Store className="h-4 w-4 mr-2" />
                  <span className="capitalize">{selectedRequest.cuisine_type}</span>
                </div>
              </div>
              <div className="text-right">
                <span className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-medium ${
                  selectedRequest.status === 'pending' ? 'bg-yellow-100 text-yellow-800' :
                  selectedRequest.status === 'approved' ? 'bg-green-100 text-green-800' :
                  'bg-red-100 text-red-800'
                }`}>
                  {selectedRequest.status === 'pending' ? 'Pending Review' :
                   selectedRequest.status === 'approved' ? 'Approved' : 'Rejected'}
                </span>
                <p className="text-xs text-gray-500 mt-2">
                  Submitted {formatDate(selectedRequest.created_at)}
                </p>
                {selectedRequest.reviewed_at && (
                  <p className="text-xs text-gray-500">
                    {selectedRequest.status === 'approved' ? 'Approved' : 'Rejected'} {formatDate(selectedRequest.reviewed_at)}
                  </p>
                )}
              </div>
            </div>

            {/* Contact Information */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
              <div>
                <h3 className="text-lg font-semibold text-gray-800 mb-4">Contact Information</h3>
                <div className="space-y-3">
                  <div className="flex items-center">
                    <Mail className="h-4 w-4 text-gray-400 mr-3" />
                    <span className="text-gray-700">{selectedRequest.owner_email}</span>
                  </div>
                  <div className="flex items-center">
                    <Phone className="h-4 w-4 text-gray-400 mr-3" />
                    <span className="text-gray-700">{selectedRequest.owner_phone}</span>
                  </div>
                  <div className="flex items-center">
                    <Store className="h-4 w-4 text-gray-400 mr-3" />
                    <span className="text-gray-700">Owner: {selectedRequest.owner_name}</span>
                  </div>
                </div>
              </div>

              <div>
                <h3 className="text-lg font-semibold text-gray-800 mb-4">Location</h3>
                <div className="flex items-start">
                  <MapPin className="h-4 w-4 text-gray-400 mr-3 mt-1" />
                  <div className="text-gray-700">
                    <p>{selectedRequest.address}</p>
                    <p>Zip Code: {selectedRequest.zip_code}</p>
                    {selectedRequest.latitude !== 0 && selectedRequest.longitude !== 0 && (
                      <p className="text-sm text-gray-500">
                        Coordinates: {selectedRequest.latitude}, {selectedRequest.longitude}
                      </p>
                    )}
                  </div>
                </div>
              </div>
            </div>

            {/* Description */}
            {selectedRequest.restaurant_description && (
              <div className="mb-8">
                <h3 className="text-lg font-semibold text-gray-800 mb-4 flex items-center">
                  <FileText className="h-4 w-4 mr-2" />
                  Restaurant Description
                </h3>
                <p className="text-gray-700 leading-relaxed bg-gray-50 p-4 rounded-lg">
                  {selectedRequest.restaurant_description}
                </p>
              </div>
            )}

            {/* Business License */}
            {selectedRequest.business_license && (
              <div className="mb-8">
                <h3 className="text-lg font-semibold text-gray-800 mb-4 flex items-center">
                  <FileText className="h-4 w-4 mr-2" />
                  Business License
                </h3>
                <div className="bg-gray-50 p-4 rounded-lg">
                  <p className="text-gray-700">{selectedRequest.business_license}</p>
                </div>
              </div>
            )}

            {/* Admin Notes */}
            {selectedRequest.admin_notes && (
              <div className="mb-8">
                <h3 className="text-lg font-semibold text-gray-800 mb-4 flex items-center">
                  <FileText className="h-4 w-4 mr-2" />
                  Admin Notes
                </h3>
                <div className="bg-gray-50 p-4 rounded-lg">
                  <p className="text-gray-700">{selectedRequest.admin_notes}</p>
                </div>
              </div>
            )}

            {/* Action Buttons - Only show for pending requests */}
            {selectedRequest.status === 'pending' && (
              <div className="flex justify-end space-x-4 pt-6 border-t">
                <button
                  onClick={() => handleReject(selectedRequest.id)}
                  disabled={actionLoading === selectedRequest.id}
                  className="flex items-center px-6 py-3 border border-red-300 text-red-700 rounded-lg hover:bg-red-50 transition-colors disabled:opacity-50"
                >
                  {actionLoading === selectedRequest.id ? (
                    <Loader2 className="animate-spin h-4 w-4 mr-2" />
                  ) : (
                    <X className="h-4 w-4 mr-2" />
                  )}
                  Reject
                </button>
                <button
                  onClick={() => handleApprove(selectedRequest.id)}
                  disabled={actionLoading === selectedRequest.id}
                  className="flex items-center px-6 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors disabled:opacity-50"
                >
                  {actionLoading === selectedRequest.id ? (
                    <Loader2 className="animate-spin h-4 w-4 mr-2" />
                  ) : (
                    <Check className="h-4 w-4 mr-2" />
                  )}
                  Approve
                </button>
              </div>
            )}
          </div>
        </div>
      </AdminLayout>
    );
  }

  return (
    <AdminLayout 
      title="Business Onboarding" 
      onRefresh={fetchRequests} 
      refreshing={loading}
    >
      <div className="max-w-6xl mx-auto">
        {/* Filter Tabs */}
        <div className="flex items-center space-x-4 mb-8">
          <button
            onClick={() => setShowAllRequests(false)}
            className={`px-3 py-1 text-sm rounded-lg transition-colors ${
              !showAllRequests 
                ? 'bg-green-100 text-green-800 font-medium' 
                : 'text-gray-600 hover:bg-gray-100'
            }`}
          >
            Pending ({requests.length})
          </button>
          <button
            onClick={() => setShowAllRequests(true)}
            className={`px-3 py-1 text-sm rounded-lg transition-colors ${
              showAllRequests 
                ? 'bg-blue-100 text-blue-800 font-medium' 
                : 'text-gray-600 hover:bg-gray-100'
            }`}
          >
            All Requests
          </button>
        </div>

        {/* Error State */}
        {error && (
          <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg flex items-start">
            <AlertCircle className="h-5 w-5 text-red-600 mr-2 flex-shrink-0 mt-0.5" />
            <span className="text-sm text-red-800">Failed to load onboarding requests: {error}</span>
          </div>
        )}

        {/* Loading State */}
        {loading ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {Array.from({ length: 6 }).map((_, i) => (
              <div key={i} className="bg-white rounded-xl shadow-sm p-6 animate-pulse">
                <div className="h-6 bg-gray-200 rounded mb-4"></div>
                <div className="h-4 bg-gray-200 rounded mb-2"></div>
                <div className="h-4 bg-gray-200 rounded mb-4"></div>
                <div className="flex justify-between">
                  <div className="h-8 w-20 bg-gray-200 rounded"></div>
                  <div className="h-8 w-16 bg-gray-200 rounded"></div>
                </div>
              </div>
            ))}
          </div>
        ) : requests.length === 0 ? (
          <div className="text-center py-12">
            <Store className="h-16 w-16 text-gray-300 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">No pending requests</h3>
            <p className="text-gray-500">All business onboarding requests have been processed.</p>
          </div>
        ) : (
          /* Requests Grid */
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {requests.map((request) => {
              const getStatusBadge = (status: string) => {
                switch (status) {
                  case 'pending':
                    return 'bg-yellow-100 text-yellow-800';
                  case 'approved':
                    return 'bg-green-100 text-green-800';
                  case 'rejected':
                    return 'bg-red-100 text-red-800';
                  default:
                    return 'bg-gray-100 text-gray-800';
                }
              };

              return (
                <div key={request.id} className="bg-white rounded-xl shadow-sm p-6 hover:shadow-md transition-shadow">
                  <div className="flex items-start justify-between mb-4">
                    <h3 className="text-lg font-semibold text-gray-800 truncate">{request.restaurant_name}</h3>
                    <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${getStatusBadge(request.status)}`}>
                      {request.status.charAt(0).toUpperCase() + request.status.slice(1)}
                    </span>
                  </div>
                
                <div className="space-y-2 mb-4">
                  <div className="flex items-center text-sm text-gray-600">
                    <Store className="h-4 w-4 mr-2" />
                    <span className="capitalize">{request.cuisine_type}</span>
                  </div>
                  <div className="flex items-center text-sm text-gray-600">
                    <MapPin className="h-4 w-4 mr-2" />
                    <span className="truncate">{request.address}</span>
                  </div>
                  <div className="flex items-center text-sm text-gray-600">
                    <Mail className="h-4 w-4 mr-2" />
                    <span className="truncate">{request.owner_email}</span>
                  </div>
                </div>

                <p className="text-xs text-gray-500 mb-4">
                  Submitted {formatDate(request.created_at)}
                </p>

                <div className="flex justify-between items-center">
                  <button
                    onClick={() => setSelectedRequest(request)}
                    className="flex items-center text-green-600 hover:text-green-700 text-sm font-medium"
                  >
                    <Eye className="h-4 w-4 mr-1" />
                    View Details
                  </button>
                  
                  {request.status === 'pending' ? (
                    <div className="flex space-x-2">
                      <button
                        onClick={() => handleReject(request.id)}
                        disabled={actionLoading === request.id}
                        className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors disabled:opacity-50"
                      >
                        <X className="h-4 w-4" />
                      </button>
                      <button
                        onClick={() => handleApprove(request.id)}
                        disabled={actionLoading === request.id}
                        className="p-2 text-green-600 hover:bg-green-50 rounded-lg transition-colors disabled:opacity-50"
                      >
                        {actionLoading === request.id ? (
                          <Loader2 className="animate-spin h-4 w-4" />
                        ) : (
                          <Check className="h-4 w-4" />
                        )}
                      </button>
                    </div>
                  ) : (
                    <div className="text-xs text-gray-500">
                      {request.status === 'approved' ? 'Approved' : 'Rejected'}
                      {request.reviewed_at && (
                        <div>{formatDate(request.reviewed_at)}</div>
                      )}
                    </div>
                  )}
                </div>
              </div>
              );
            })}
          </div>
        )}
      </div>
    </AdminLayout>
  );
};

export default BusinessOnboarding;