/// Service for handling image URLs with CORS support
/// Handles different environments and CDN configurations
class ImageService {
  // CORS-enabled CDN worker URL
  static const String _corsWorkerUrl = 'https://foodq-cdn.sivapolisetty813.workers.dev';
  
  // Original CDN domain (has CORS issues)
  static const String _originalCdnUrl = 'https://cdn.foodqapp.com';
  
  /// Convert a CDN URL to a CORS-enabled URL
  /// This is a temporary fix until the main CDN domain is configured with CORS
  static String? getCorsEnabledImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return null;
    
    // If it's already using the CORS worker, return as-is
    if (imageUrl.startsWith(_corsWorkerUrl)) {
      return imageUrl;
    }
    
    // If it's using the original CDN domain, replace with CORS worker
    if (imageUrl.startsWith(_originalCdnUrl)) {
      return imageUrl.replaceFirst(_originalCdnUrl, _corsWorkerUrl);
    }
    
    // For other domains (like direct OpenAI URLs), return as-is
    return imageUrl;
  }
  
  /// Get the best image URL from multiple sources with CORS support
  static String? getBestImageUrl({
    String? cdnUrl,
    String? imageUrl,
    String? r2ImageKey,
  }) {
    // Priority: cdnUrl > imageUrl > constructed from r2ImageKey
    String? url;
    
    if (cdnUrl != null && cdnUrl.isNotEmpty) {
      url = cdnUrl;
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      url = imageUrl;
    } else if (r2ImageKey != null && r2ImageKey.isNotEmpty) {
      // Construct CDN URL from R2 key
      url = '$_originalCdnUrl/$r2ImageKey';
    }
    
    return getCorsEnabledImageUrl(url);
  }
}