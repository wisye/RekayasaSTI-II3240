'use client';

import { useState, useEffect } from 'react';
import { UserCircleIcon, PlusIcon } from '@heroicons/react/24/outline';
import { useAuth } from '@/contexts/AuthContext';
import ProductDetail from '@/components/ProductDetail';
import ProductForm from '@/components/ProductForm';
import { Product } from '@/types';
import { getProducts } from '@/lib/api';

export default function Products() {
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [selectedProduct, setSelectedProduct] = useState<Product | null>(null);
  const [showForm, setShowForm] = useState(false);
  const { username } = useAuth();

  useEffect(() => {
    fetchProducts();
  }, []);

  const fetchProducts = async () => {
    try {
      const data = await getProducts();
      setProducts(data);
    } catch (err) {
      setError('Failed to load products');
    } finally {
      setLoading(false);
    }
  };

  const handleCreateProduct = async (product: any) => {
    // Implement create product logic
    await fetchProducts();
    setShowForm(false);
  };

  return (
    <div className="p-8 relative">
      {/* Header */}
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-xl font-medium text-purple-600">
            Products
          </h1>
          <p className="text-sm text-gray-500">
            Manage your products and their storage requirements
          </p>
        </div>
        <div>
          <UserCircleIcon className="h-8 w-8 text-gray-400" />
        </div>
      </div>

      {/* Main Content */}
      <div>
        <div className="bg-gradient-to-r from-purple-100 to-pink-100 rounded-lg p-4 mb-4">
          <h2 className="text-lg font-medium text-gray-900">
            All Products
          </h2>
        </div>

        {loading ? (
          <p>Loading...</p>
        ) : error ? (
          <p className="text-red-500">{error}</p>
        ) : products.length === 0 ? (
          <div className="text-center py-12">
            <p className="text-gray-500 mb-4">No products found</p>
            <button
              onClick={() => setShowForm(true)}
              className="inline-flex items-center px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700"
            >
              <PlusIcon className="h-5 w-5 mr-2" />
              Add New Product
            </button>
          </div>
        ) : (
          <div className="grid gap-4">
            {products.map((product) => (
              <div
                key={product.id}
                onClick={() => setSelectedProduct(product)}
                className="bg-white rounded-lg shadow p-4 cursor-pointer hover:bg-gray-50 transition-colors"
              >
                <div className="flex justify-between items-start">
                  <div>
                    <p className="font-medium text-gray-900">
                      {product.name}
                    </p>
                    <p className="text-sm text-gray-700 mt-1">
                      Temperature: {product.min_temperature}°C to {product.max_temperature}°C
                    </p>
                    <p className="text-sm text-gray-700">
                      Humidity: {product.min_humidity}% to {product.max_humidity}%
                    </p>
                  </div>
                  <div className="flex flex-col items-end space-y-2">
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-purple-100 text-purple-800">
                      Code: {product.product_code}
                    </span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Floating Action Button */}
      <button
        onClick={() => setShowForm(true)}
        className="fixed bottom-8 right-8 w-14 h-14 bg-purple-600 rounded-full shadow-lg hover:bg-purple-700 flex items-center justify-center text-white transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500"
      >
        <PlusIcon className="h-8 w-8" />
        <span className="sr-only">New Product</span>
      </button>

      {/* Modals */}
      {selectedProduct && (
        <ProductDetail
          product={selectedProduct}
          onClose={() => setSelectedProduct(null)}
        />
      )}

      {showForm && (
        <ProductForm
          onClose={() => setShowForm(false)}
          onSubmit={handleCreateProduct}
        />
      )}
    </div>
  );
}