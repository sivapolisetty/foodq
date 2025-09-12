import React, { useState, useEffect } from 'react';
import { 
  Search, RefreshCw, Download, Trash2, 
  ChefHat, Clock, Users, DollarSign, Image,
  Loader2, CheckCircle, Edit
} from 'lucide-react';
import { API_ENDPOINTS, API_KEY } from '../config/api';

interface FoodLibraryItem {
  id: string;
  name: string;
  description: string;
  image_url: string | null;
  image_prompt?: string;
  r2_image_key?: string;
  cdn_url?: string;
  prep_time_minutes: number;
  serving_size: string;
  base_price_range: string;
  tags: string[];
  usage_count: number;
  created_at: string;
  updated_at: string;
}

const FoodLibrary: React.FC = () => {
  const [items, setItems] = useState<FoodLibraryItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedTags] = useState<string[]>([]);
  const [showGenerator, setShowGenerator] = useState(false);
  const [generatorPrompt, setGeneratorPrompt] = useState('');
  const [generating, setGenerating] = useState(false);
  const [batchMode, setBatchMode] = useState(false);
  const [batchCount, setBatchCount] = useState(10);
  const [generationProgress, setGenerationProgress] = useState(0);
  const [editingItem, setEditingItem] = useState<FoodLibraryItem | null>(null);
  const [showEditModal, setShowEditModal] = useState(false);
  const [editForm, setEditForm] = useState<Partial<FoodLibraryItem>>({});
  const [searchResults, setSearchResults] = useState<FoodLibraryItem[]>([]);
  const [showSearchResults, setShowSearchResults] = useState(false);

  // Fetch food library items
  const fetchItems = async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams();
      if (searchQuery) params.append('search', searchQuery);
      if (selectedTags.length > 0) params.append('tags', selectedTags.join(','));
      
      const response = await fetch(`${API_ENDPOINTS.FOOD_LIBRARY}?${params}`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('auth_token')}`,
          'X-API-Key': API_KEY,
        }
      });
      
      const data = await response.json();
      if (data.success) {
        setItems(data.data);
      }
    } catch (error) {
      console.error('Failed to fetch food library:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchItems();
  }, [searchQuery, selectedTags]);

  // Fuzzy search function
  const fuzzySearch = (query: string) => {
    if (!query || query.length < 2) {
      setSearchResults([]);
      setShowSearchResults(false);
      return;
    }

    const lowerQuery = query.toLowerCase();
    const results = items.filter(item => {
      const name = item.name.toLowerCase();
      const description = item.description.toLowerCase();
      const tags = item.tags.join(' ').toLowerCase();
      
      // Check for exact or partial matches
      return name.includes(lowerQuery) || 
             description.includes(lowerQuery) || 
             tags.includes(lowerQuery) ||
             // Check for word-by-word match
             lowerQuery.split(' ').every(word => 
               name.includes(word) || description.includes(word)
             );
    }).slice(0, 5); // Limit to top 5 results

    setSearchResults(results);
    setShowSearchResults(results.length > 0);
  };

  // Handle generator prompt change
  const handleGeneratorPromptChange = (value: string) => {
    setGeneratorPrompt(value);
    fuzzySearch(value);
  };

  // Generate single food item
  const generateSingleItem = async () => {
    if (!generatorPrompt.trim()) return;
    
    setGenerating(true);
    try {
      const response = await fetch(API_ENDPOINTS.FOOD_LIBRARY, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('auth_token')}`,
          'X-API-Key': API_KEY,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ prompt: generatorPrompt, dataOnly: true })
      });
      
      const data = await response.json();
      if (data.success) {
        setItems([data.data, ...items]);
        setGeneratorPrompt('');
        setShowGenerator(false);
      }
    } catch (error) {
      console.error('Failed to generate item:', error);
    } finally {
      setGenerating(false);
    }
  };

  // Batch generate items
  const batchGenerate = async () => {
    setGenerating(true);
    setGenerationProgress(0);
    
    try {
      const response = await fetch(API_ENDPOINTS.FOOD_LIBRARY, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('auth_token')}`,
          'X-API-Key': API_KEY,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ 
          batch: true, 
          dataOnly: true,
          count: batchCount 
        })
      });
      
      const data = await response.json();
      if (data.success) {
        await fetchItems();
        setBatchMode(false);
      }
    } catch (error) {
      console.error('Failed to batch generate:', error);
    } finally {
      setGenerating(false);
      setGenerationProgress(0);
    }
  };


  // Generate image for item
  const generateImage = async (itemId: string, customPrompt?: string) => {
    try {
      const response = await fetch(API_ENDPOINTS.GENERATE_IMAGE, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('auth_token')}`,
          'X-API-Key': API_KEY,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          itemId,
          customPrompt
        })
      });
      
      const data = await response.json();
      if (data.success) {
        setItems(items.map(i => i.id === itemId ? data.data.item : i));
      }
    } catch (error) {
      console.error('Failed to generate image:', error);
    }
  };

  // Batch generate images
  const batchGenerateImages = async () => {
    try {
      const response = await fetch(API_ENDPOINTS.BATCH_GENERATE_IMAGES, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('auth_token')}`,
          'X-API-Key': API_KEY,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          batchSize: 10
        })
      });
      
      const data = await response.json();
      if (data.success) {
        await fetchItems();
      }
    } catch (error) {
      console.error('Failed to batch generate images:', error);
    }
  };

  // Delete item
  const deleteItem = async (itemId: string) => {
    if (!confirm('Are you sure you want to delete this item?')) return;
    
    try {
      const response = await fetch(API_ENDPOINTS.FOOD_LIBRARY, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('auth_token')}`,
          'X-API-Key': API_KEY,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ 
          itemId: itemId,
          delete: true 
        })
      });
      
      const data = await response.json();
      if (data.success) {
        setItems(items.filter(i => i.id !== itemId));
      }
    } catch (error) {
      console.error('Failed to delete item:', error);
    }
  };

  // Edit item
  const editItem = (item: FoodLibraryItem) => {
    setEditingItem(item);
    setEditForm({
      name: item.name,
      description: item.description,
      image_prompt: item.image_prompt || '',
      prep_time_minutes: item.prep_time_minutes,
      serving_size: item.serving_size,
      base_price_range: item.base_price_range,
      tags: item.tags
    });
    setShowEditModal(true);
  };

  // Update item
  const updateItem = async () => {
    if (!editingItem || !editForm.name?.trim()) return;
    
    try {
      const response = await fetch(API_ENDPOINTS.FOOD_LIBRARY, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('auth_token')}`,
          'X-API-Key': API_KEY,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          ...editForm,
          itemId: editingItem.id
        })
      });
      
      const data = await response.json();
      if (data.success) {
        setItems(items.map(i => i.id === editingItem.id ? data.data.item : i));
        setShowEditModal(false);
        setEditingItem(null);
        setEditForm({});
      }
    } catch (error) {
      console.error('Failed to update item:', error);
    }
  };

  // Cancel edit
  const cancelEdit = () => {
    setShowEditModal(false);
    setEditingItem(null);
    setEditForm({});
  };

  // Tag color helper
  const getTagColor = (tag: string) => {
    if (tag.includes('vegetarian')) return 'bg-green-100 text-green-800';
    if (tag.includes('non-vegetarian')) return 'bg-red-100 text-red-800';
    if (tag.includes('spicy')) return 'bg-orange-100 text-orange-800';
    if (tag.includes('dessert')) return 'bg-pink-100 text-pink-800';
    if (tag.includes('beverage')) return 'bg-blue-100 text-blue-800';
    return 'bg-gray-100 text-gray-800';
  };

  return (
    <div className="p-6 max-w-7xl mx-auto">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 flex items-center gap-3">
          <ChefHat className="h-8 w-8 text-orange-500" />
          Food Library
        </h1>
        <p className="text-gray-600 mt-2">
          AI-powered food catalog for Indian cuisine. Generate, manage, and organize food items.
        </p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-4 gap-4 mb-8">
        <div className="bg-white rounded-lg shadow p-4">
          <div className="text-sm text-gray-600">Total Items</div>
          <div className="text-2xl font-bold">{items.length}</div>
        </div>
        <div className="bg-white rounded-lg shadow p-4">
          <div className="text-sm text-gray-600">Most Used</div>
          <div className="text-lg font-semibold">
            {items[0]?.name || 'N/A'}
          </div>
        </div>
        <div className="bg-white rounded-lg shadow p-4">
          <div className="text-sm text-gray-600">Categories</div>
          <div className="text-2xl font-bold">
            {new Set(items.flatMap(i => i.tags)).size}
          </div>
        </div>
        <div className="bg-white rounded-lg shadow p-4">
          <div className="text-sm text-gray-600">Total Usage</div>
          <div className="text-2xl font-bold">
            {items.reduce((sum, i) => sum + i.usage_count, 0)}
          </div>
        </div>
      </div>

      {/* Actions Bar */}
      <div className="flex gap-4 mb-6">
        <div className="flex-1 relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-5 w-5" />
          <input
            type="text"
            placeholder="Search food items..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
          />
        </div>
        <button
          onClick={() => setShowGenerator(true)}
          className="px-4 py-2 bg-orange-500 text-white rounded-lg hover:bg-orange-600 flex items-center gap-2"
        >
          <Search className="h-5 w-5" />
          Search / Generate Item
        </button>
        <button
          onClick={() => setBatchMode(true)}
          className="px-4 py-2 bg-purple-500 text-white rounded-lg hover:bg-purple-600 flex items-center gap-2"
        >
          <Download className="h-5 w-5" />
          Batch Generate Data
        </button>
        <button
          onClick={batchGenerateImages}
          className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 flex items-center gap-2"
        >
          <Image className="h-5 w-5" />
          Batch Generate Images
        </button>
        <button
          onClick={fetchItems}
          className="px-4 py-2 border rounded-lg hover:bg-gray-50 flex items-center gap-2"
        >
          <RefreshCw className="h-5 w-5" />
          Refresh
        </button>
      </div>

      {/* Generator Modal */}
      {showGenerator && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
            <h2 className="text-xl font-bold mb-4">Search or Generate Food Item</h2>
            <input
              type="text"
              placeholder="Enter food name (e.g., 'butter chicken')"
              value={generatorPrompt}
              onChange={(e) => handleGeneratorPromptChange(e.target.value)}
              className="w-full px-4 py-2 border rounded-lg mb-4"
              disabled={generating}
            />
            
            {/* Search Results */}
            {showSearchResults && (
              <div className="mb-4">
                <h3 className="text-sm font-semibold text-gray-600 mb-2">
                  Existing items found ({searchResults.length}):
                </h3>
                <div className="space-y-2 max-h-60 overflow-y-auto border rounded-lg p-2">
                  {searchResults.map((item) => (
                    <div 
                      key={item.id} 
                      className="p-3 bg-gray-50 rounded-lg hover:bg-gray-100 cursor-pointer transition-colors"
                      onClick={() => {
                        editItem(item);
                        setShowGenerator(false);
                      }}
                    >
                      <div className="flex items-start gap-3">
                        {item.cdn_url || item.image_url ? (
                          <img 
                            src={item.cdn_url || item.image_url || ''} 
                            alt={item.name}
                            className="w-16 h-16 object-cover rounded"
                          />
                        ) : (
                          <div className="w-16 h-16 bg-gray-200 rounded flex items-center justify-center">
                            <Image className="h-6 w-6 text-gray-400" />
                          </div>
                        )}
                        <div className="flex-1">
                          <h4 className="font-semibold text-sm">{item.name}</h4>
                          <p className="text-xs text-gray-600 line-clamp-2">{item.description}</p>
                          <div className="flex gap-2 mt-1">
                            {item.tags.slice(0, 3).map((tag) => (
                              <span 
                                key={tag} 
                                className={`text-xs px-2 py-0.5 rounded-full ${getTagColor(tag)}`}
                              >
                                {tag}
                              </span>
                            ))}
                          </div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
                <p className="text-xs text-gray-500 mt-2">
                  Click on an item to edit it, or proceed below to generate a new variant
                </p>
              </div>
            )}

            {/* No results message */}
            {generatorPrompt.length >= 2 && !showSearchResults && (
              <div className="mb-4 p-3 bg-blue-50 rounded-lg">
                <p className="text-sm text-blue-700">
                  No existing items found. You can generate a new item.
                </p>
              </div>
            )}

            <div className="flex gap-3">
              <button
                onClick={generateSingleItem}
                disabled={generating || !generatorPrompt.trim()}
                className="flex-1 px-4 py-2 bg-orange-500 text-white rounded-lg hover:bg-orange-600 disabled:opacity-50 flex items-center justify-center gap-2"
              >
                {generating ? (
                  <>
                    <Loader2 className="h-5 w-5 animate-spin" />
                    Generating...
                  </>
                ) : (
                  <>
                    <CheckCircle className="h-5 w-5" />
                    {showSearchResults ? 'Generate New Variant' : 'Generate New Item'}
                  </>
                )}
              </button>
              <button
                onClick={() => {
                  setShowGenerator(false);
                  setGeneratorPrompt('');
                  setSearchResults([]);
                  setShowSearchResults(false);
                }}
                className="px-4 py-2 border rounded-lg hover:bg-gray-50"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Batch Generate Modal */}
      {batchMode && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h2 className="text-xl font-bold mb-4">Batch Generate Food Items</h2>
            <p className="text-gray-600 mb-4">
              Generate multiple Indian cuisine items automatically using AI
            </p>
            <div className="mb-4">
              <label className="block text-sm font-medium mb-2">Number of items</label>
              <input
                type="number"
                min="1"
                max="200"
                value={batchCount}
                onChange={(e) => setBatchCount(parseInt(e.target.value))}
                className="w-full px-4 py-2 border rounded-lg"
                disabled={generating}
              />
            </div>
            {generating && (
              <div className="mb-4">
                <div className="bg-gray-200 rounded-full h-2 mb-2">
                  <div 
                    className="bg-orange-500 h-2 rounded-full transition-all"
                    style={{ width: `${generationProgress}%` }}
                  />
                </div>
                <p className="text-sm text-gray-600 text-center">
                  Generating... {generationProgress}%
                </p>
              </div>
            )}
            <div className="flex gap-3">
              <button
                onClick={batchGenerate}
                disabled={generating}
                className="flex-1 px-4 py-2 bg-purple-500 text-white rounded-lg hover:bg-purple-600 disabled:opacity-50 flex items-center justify-center gap-2"
              >
                {generating ? (
                  <>
                    <Loader2 className="h-5 w-5 animate-spin" />
                    Generating {batchCount} items...
                  </>
                ) : (
                  <>
                    <Download className="h-5 w-5" />
                    Start Batch Generation
                  </>
                )}
              </button>
              <button
                onClick={() => setBatchMode(false)}
                disabled={generating}
                className="px-4 py-2 border rounded-lg hover:bg-gray-50"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Edit Modal */}
      {showEditModal && editingItem && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
            <h2 className="text-xl font-bold mb-4">Edit Food Item</h2>
            
            {/* Name */}
            <div className="mb-4">
              <label className="block text-sm font-medium mb-2">Name *</label>
              <input
                type="text"
                value={editForm.name || ''}
                onChange={(e) => setEditForm({...editForm, name: e.target.value})}
                className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
                required
              />
            </div>

            {/* Description */}
            <div className="mb-4">
              <label className="block text-sm font-medium mb-2">Description</label>
              <textarea
                value={editForm.description || ''}
                onChange={(e) => setEditForm({...editForm, description: e.target.value})}
                rows={3}
                className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
              />
            </div>

            {/* Image Prompt */}
            <div className="mb-4">
              <label className="block text-sm font-medium mb-2">
                Image Prompt 
                <span className="text-xs text-gray-500">(for image generation/regeneration)</span>
              </label>
              <textarea
                value={editForm.image_prompt || ''}
                onChange={(e) => setEditForm({...editForm, image_prompt: e.target.value})}
                rows={2}
                placeholder="e.g., Traditional butter chicken served in a restaurant style with garnish"
                className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
              />
            </div>

            {/* Prep Time and Serving Size */}
            <div className="grid grid-cols-2 gap-4 mb-4">
              <div>
                <label className="block text-sm font-medium mb-2">Prep Time (minutes)</label>
                <input
                  type="number"
                  value={editForm.prep_time_minutes || ''}
                  onChange={(e) => setEditForm({...editForm, prep_time_minutes: parseInt(e.target.value) || 0})}
                  className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Serving Size</label>
                <input
                  type="text"
                  value={editForm.serving_size || ''}
                  onChange={(e) => setEditForm({...editForm, serving_size: e.target.value})}
                  placeholder="e.g., 2-3 people"
                  className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
                />
              </div>
            </div>

            {/* Price Range */}
            <div className="mb-4">
              <label className="block text-sm font-medium mb-2">Price Range</label>
              <input
                type="text"
                value={editForm.base_price_range || ''}
                onChange={(e) => setEditForm({...editForm, base_price_range: e.target.value})}
                placeholder="e.g., ₹200-400"
                className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
              />
            </div>

            {/* Tags */}
            <div className="mb-6">
              <label className="block text-sm font-medium mb-2">Tags (comma-separated)</label>
              <input
                type="text"
                value={editForm.tags?.join(', ') || ''}
                onChange={(e) => setEditForm({...editForm, tags: e.target.value.split(',').map(t => t.trim()).filter(t => t)})}
                placeholder="e.g., vegetarian, north-indian, spicy"
                className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
              />
            </div>

            {/* Actions */}
            <div className="flex gap-3">
              <button
                onClick={updateItem}
                disabled={!editForm.name?.trim()}
                className="flex-1 px-4 py-2 bg-orange-500 text-white rounded-lg hover:bg-orange-600 disabled:opacity-50 flex items-center justify-center gap-2"
              >
                <CheckCircle className="h-5 w-5" />
                Update Item
              </button>
              <button
                onClick={cancelEdit}
                className="px-4 py-2 border rounded-lg hover:bg-gray-50"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Items Grid */}
      {loading ? (
        <div className="flex justify-center py-12">
          <Loader2 className="h-8 w-8 animate-spin text-orange-500" />
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {items.map((item) => (
            <div key={item.id} className="bg-white rounded-lg shadow-lg overflow-hidden hover:shadow-xl transition-shadow">
              <div className="relative h-48">
                {item.image_url || item.cdn_url ? (
                  <img
                    src={item.cdn_url || item.image_url || ''}
                    alt={item.name}
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <div className="w-full h-full bg-gray-200 flex items-center justify-center">
                    <Image className="h-12 w-12 text-gray-400" />
                    <div className="ml-2">
                      <div className="text-sm font-medium text-gray-600">No Image</div>
                      <div className="text-xs text-gray-500">Generate image</div>
                    </div>
                  </div>
                )}
                <div className="absolute top-2 right-2 bg-white rounded-full px-2 py-1 text-xs font-semibold">
                  Used {item.usage_count}x
                </div>
              </div>
              <div className="p-4">
                <h3 className="text-lg font-bold mb-2">{item.name}</h3>
                <p className="text-sm text-gray-600 mb-3 line-clamp-2">
                  {item.description}
                </p>
                
                {/* Item Details */}
                <div className="grid grid-cols-3 gap-2 mb-3 text-xs">
                  <div className="flex items-center gap-1">
                    <Clock className="h-3 w-3 text-gray-400" />
                    <span>{item.prep_time_minutes} min</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <Users className="h-3 w-3 text-gray-400" />
                    <span>{item.serving_size}</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <DollarSign className="h-3 w-3 text-gray-400" />
                    <span>{item.base_price_range}</span>
                  </div>
                </div>
                
                {/* Tags */}
                <div className="flex flex-wrap gap-1 mb-3">
                  {item.tags.slice(0, 4).map((tag) => (
                    <span
                      key={tag}
                      className={`px-2 py-1 rounded-full text-xs ${getTagColor(tag)}`}
                    >
                      {tag}
                    </span>
                  ))}
                  {item.tags.length > 4 && (
                    <span className="px-2 py-1 bg-gray-100 text-gray-600 rounded-full text-xs">
                      +{item.tags.length - 4} more
                    </span>
                  )}
                </div>
                
                {/* Actions */}
                <div className="flex gap-2">
                  {!item.image_url && !item.cdn_url ? (
                    <button
                      onClick={() => generateImage(item.id)}
                      className="flex-1 px-3 py-1 bg-blue-500 text-white rounded hover:bg-blue-600 text-sm flex items-center justify-center gap-1"
                    >
                      <Image className="h-3 w-3" />
                      Generate Image
                    </button>
                  ) : (
                    <button
                      onClick={() => generateImage(item.id)}
                      className="flex-1 px-3 py-1 border rounded hover:bg-gray-50 text-sm flex items-center justify-center gap-1"
                    >
                      <RefreshCw className="h-3 w-3" />
                      Regenerate Image
                    </button>
                  )}
                  <button
                    onClick={() => editItem(item)}
                    className="px-3 py-1 border rounded hover:bg-gray-50 text-sm flex items-center justify-center gap-1"
                  >
                    <Edit className="h-3 w-3" />
                    Edit
                  </button>
                  <button
                    onClick={() => deleteItem(item.id)}
                    className="px-3 py-1 border border-red-200 text-red-600 rounded hover:bg-red-50 text-sm"
                  >
                    <Trash2 className="h-3 w-3" />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default FoodLibrary;