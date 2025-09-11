import React, { useState, useEffect } from 'react';
import { 
  Search, Plus, RefreshCw, Download, Trash2, 
  ChefHat, Clock, Users, DollarSign, Image,
  Loader2, CheckCircle
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
      const response = await fetch(`${API_ENDPOINTS.FOOD_LIBRARY}/${itemId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('auth_token')}`,
          'X-API-Key': API_KEY,
        }
      });
      
      const data = await response.json();
      if (data.success) {
        setItems(items.filter(i => i.id !== itemId));
      }
    } catch (error) {
      console.error('Failed to delete item:', error);
    }
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
          <Plus className="h-5 w-5" />
          Generate Item
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
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h2 className="text-xl font-bold mb-4">Generate Food Item with AI</h2>
            <input
              type="text"
              placeholder="Enter food name (e.g., 'butter chicken')"
              value={generatorPrompt}
              onChange={(e) => setGeneratorPrompt(e.target.value)}
              className="w-full px-4 py-2 border rounded-lg mb-4"
              disabled={generating}
            />
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
                    Generate
                  </>
                )}
              </button>
              <button
                onClick={() => setShowGenerator(false)}
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