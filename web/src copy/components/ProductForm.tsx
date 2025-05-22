'use client';

import { useState } from 'react';
import { CreateProductData } from '@/types';

interface ProductFormProps {
  onClose: () => void;
  onSubmit: (data: CreateProductData) => void;
}

export default function ProductForm({ onClose, onSubmit }: ProductFormProps) {
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setLoading(true);

    const formData = new FormData(e.currentTarget);
    const data: CreateProductData = {
      name: formData.get('name') as string,
      description: formData.get('description') as string,
      max_temperature: Number(formData.get('max_temperature')),
      min_temperature: Number(formData.get('min_temperature')),
      max_humidity: Number(formData.get('max_humidity')),
      min_humidity: Number(formData.get('min_humidity')),
    };

    try {
      await onSubmit(data);
      onClose();
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center p-4">
      <div className="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div className="px-6 py-4 border-b border-gray-200">
          <h3 className="text-xl font-semibold text-gray-900">Add New Product</h3>
        </div>
        
        <form onSubmit={handleSubmit} className="p-6 space-y-6">
          <div>
            <label className="block text-sm font-semibold text-gray-900 mb-1">
              Product Name
            </label>
            <input
              type="text"
              name="name"
              required
              className="mt-1 h-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 text-gray-900 bg-white"
            />
          </div>

          <div>
            <label className="block text-sm font-semibold text-gray-900 mb-1">
              Description
            </label>
            <textarea
              name="description"
              required
              rows={3}
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 text-gray-900 bg-white"
            />
          </div>

          <div className="grid grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-semibold text-gray-900 mb-1">
                Minimum Temperature (°C)
              </label>
              <input
                type="number"
                name="min_temperature"
                required
                className="mt-1 h-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 text-gray-900 bg-white"
              />
            </div>
            <div>
              <label className="block text-sm font-semibold text-gray-900 mb-1">
                Maximum Temperature (°C)
              </label>
              <input
                type="number"
                name="max_temperature"
                required
                className="mt-1 h-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 text-gray-900 bg-white"
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-semibold text-gray-900 mb-1">
                Minimum Humidity (%)
              </label>
              <input
                type="number"
                name="min_humidity"
                required
                className="mt-1 h-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 text-gray-900 bg-white"
              />
            </div>
            <div>
              <label className="block text-sm font-semibold text-gray-900 mb-1">
                Maximum Humidity (%)
              </label>
              <input
                type="number"
                name="max_humidity"
                required
                className="mt-1 h-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 text-gray-900 bg-white"
              />
            </div>
          </div>

          <div className="flex justify-end space-x-3">
            <button
              type="button"
              onClick={onClose}
              disabled={loading}
              className="h-10 px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={loading}
              className="h-10 px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md hover:bg-blue-700"
            >
              {loading ? 'Creating...' : 'Create Product'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}