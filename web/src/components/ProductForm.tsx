'use client';

import { useState } from 'react';
import { XMarkIcon } from '@heroicons/react/24/outline';

interface ProductFormProps {
  onClose: () => void;
  onSubmit: (data: any) => void;
}

export default function ProductForm({ onClose, onSubmit }: ProductFormProps) {
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setLoading(true);
    const formData = new FormData(e.currentTarget);
    
    const data = {
      name: formData.get('name'),
      description: formData.get('description'),
      product_code: formData.get('product_code'),
      min_temperature: Number(formData.get('min_temperature')),
      max_temperature: Number(formData.get('max_temperature')),
      min_humidity: Number(formData.get('min_humidity')),
      max_humidity: Number(formData.get('max_humidity')),
    };

    await onSubmit(data);
    setLoading(false);
  };

  return (
    <div className="fixed inset-0 z-50">
      <div className="absolute inset-0 backdrop-blur-sm bg-white/30" onClick={onClose} />
      
      <div className="relative flex items-center justify-center min-h-screen p-4">
        <div className="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto shadow-xl">
          <div className="px-6 py-4 border-b border-gray-200 flex justify-between items-center sticky top-0 bg-white z-10">
            <h3 className="text-lg font-medium text-gray-900">Add New Product</h3>
            <button onClick={onClose} className="p-2 rounded-full hover:bg-gray-100">
              <XMarkIcon className="h-5 w-5 text-gray-400" />
            </button>
          </div>

          <form onSubmit={handleSubmit} className="p-6 space-y-6">
            <div className="space-y-4">
              <div>
                <label htmlFor="name" className="block text-sm font-medium text-gray-700">
                  Product Name
                </label>
                <input
                  type="text"
                  name="name"
                  id="name"
                  required
                  className="mt-1 h-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500 text-gray-900"
                />
              </div>

              <div>
                <label htmlFor="product_code" className="block text-sm font-medium text-gray-700">
                  Product Code
                </label>
                <input
                  type="text"
                  name="product_code"
                  id="product_code"
                  required
                  className="mt-1 h-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500 text-gray-900"
                />
              </div>

              <div>
                <label htmlFor="description" className="block text-sm font-medium text-gray-700">
                  Description
                </label>
                <textarea
                  name="description"
                  id="description"
                  rows={3}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500 text-gray-900"
                />
              </div>

              <div className="bg-gray-50 rounded-lg p-4 space-y-4">
                <h4 className="text-sm font-medium text-gray-900">Storage Requirements</h4>
                
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label htmlFor="min_temperature" className="block text-sm font-medium text-gray-700">
                      Min Temperature (°C)
                    </label>
                    <input
                      type="number"
                      name="min_temperature"
                      id="min_temperature"
                      required
                      step="0.1"
                      className="mt-1 h-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500 text-gray-900"
                    />
                  </div>
                  <div>
                    <label htmlFor="max_temperature" className="block text-sm font-medium text-gray-700">
                      Max Temperature (°C)
                    </label>
                    <input
                      type="number"
                      name="max_temperature"
                      id="max_temperature"
                      required
                      step="0.1"
                      className="mt-1 h-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500 text-gray-900"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label htmlFor="min_humidity" className="block text-sm font-medium text-gray-700">
                      Min Humidity (%)
                    </label>
                    <input
                      type="number"
                      name="min_humidity"
                      id="min_humidity"
                      required
                      step="0.1"
                      className="mt-1 h-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500 text-gray-900"
                    />
                  </div>
                  <div>
                    <label htmlFor="max_humidity" className="block text-sm font-medium text-gray-700">
                      Max Humidity (%)
                    </label>
                    <input
                      type="number"
                      name="max_humidity"
                      id="max_humidity"
                      required
                      step="0.1"
                      className="mt-1 h-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500 text-gray-900"
                    />
                  </div>
                </div>
              </div>
            </div>

            <div className="flex justify-end space-x-3 pt-4 border-t border-gray-200">
              <button
                type="button"
                onClick={onClose}
                className="px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 rounded-md border border-gray-300"
              >
                Cancel
              </button>
              <button
                type="submit"
                disabled={loading}
                className="px-4 py-2 text-sm font-medium text-white bg-purple-600 hover:bg-purple-700 rounded-md disabled:opacity-50"
              >
                {loading ? 'Adding...' : 'Add Product'}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}