'use client';

import { Product } from '@/types';
import { useEffect } from 'react';
import { XMarkIcon } from '@heroicons/react/24/outline';

interface ProductDetailProps {
  product: Product;
  onClose: () => void;
}

export default function ProductDetail({ product, onClose }: ProductDetailProps) {
  useEffect(() => {
    document.body.style.overflow = 'hidden';
    return () => {
      document.body.style.overflow = 'unset';
    };
  }, []);

  return (
    <div className="fixed inset-0 z-50">
      <div 
        className="absolute inset-0 backdrop-blur-sm bg-white/30"
        onClick={onClose}
      />

      <div className="relative flex items-center justify-center min-h-screen p-4">
        <div className="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto shadow-xl">
          <div className="px-6 py-4 border-b border-gray-200 flex justify-between items-center sticky top-0 bg-white z-10">
            <div>
              <h3 className="text-lg font-medium text-gray-900">
                Product Details
              </h3>
              <p className="text-sm text-gray-500">Code: {product.product_code}</p>
            </div>
            <button
              onClick={onClose}
              className="p-2 rounded-full hover:bg-gray-100 transition-colors"
            >
              <XMarkIcon className="h-5 w-5 text-gray-400" />
            </button>
          </div>

          <div className="p-6 space-y-6">
            <div className="bg-gray-50 rounded-lg p-4">
              <h4 className="text-sm font-medium text-gray-500 mb-3">Basic Information</h4>
              <dl className="space-y-2">
                <div>
                  <dt className="text-sm font-medium text-gray-900">Name</dt>
                  <dd className="text-sm text-gray-700">{product.name}</dd>
                </div>
                {product.description && (
                  <div>
                    <dt className="text-sm font-medium text-gray-900">Description</dt>
                    <dd className="text-sm text-gray-700">{product.description}</dd>
                  </div>
                )}
                <div>
                  <dt className="text-sm font-medium text-gray-900">Manufacturer ID</dt>
                  <dd className="text-sm text-gray-700">{product.manufacturer_id}</dd>
                </div>
              </dl>
            </div>

            <div className="bg-gray-50 rounded-lg p-4">
              <h4 className="text-sm font-medium text-gray-500 mb-3">Storage Requirements</h4>
              <dl className="space-y-2">
                <div>
                  <dt className="text-sm font-medium text-gray-900">Temperature Range</dt>
                  <dd className="text-sm text-gray-700">{product.min_temperature}°C to {product.max_temperature}°C</dd>
                </div>
                <div>
                  <dt className="text-sm font-medium text-gray-900">Humidity Range</dt>
                  <dd className="text-sm text-gray-700">{product.min_humidity}% to {product.max_humidity}%</dd>
                </div>
              </dl>
            </div>

            <div className="bg-gray-50 rounded-lg p-4">
              <h4 className="text-sm font-medium text-gray-500 mb-3">Additional Information</h4>
              <dl className="space-y-2">
                <div>
                  <dt className="text-sm font-medium text-gray-900">Created At</dt>
                  <dd className="text-sm text-gray-700">
                    {new Date(product.created_at).toLocaleString()}
                  </dd>
                </div>
              </dl>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}