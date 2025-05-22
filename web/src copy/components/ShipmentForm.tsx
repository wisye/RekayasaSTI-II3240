'use client';

import { useState, useEffect } from 'react';
import { CreateShipmentData, CreateShipmentItem, Product } from '@/types';
import { getProducts } from '@/lib/api';

interface ShipmentFormProps {
  onClose: () => void;
  onSubmit: (data: CreateShipmentData) => void;
}

export default function ShipmentForm({ onClose, onSubmit }: ShipmentFormProps) {
  const [loading, setLoading] = useState(false);
  const [products, setProducts] = useState<Product[]>([]);
  const [items, setItems] = useState<CreateShipmentItem[]>([{ 
    product_code: '', 
    quantity: 1 
  }]);

  useEffect(() => {
    fetchProducts();
  }, []);

  const fetchProducts = async () => {
    try {
      const data = await getProducts();
      setProducts(data);
    } catch (err) {
      console.error('Failed to fetch products:', err);
    }
  };

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setLoading(true);

    const formData = new FormData(e.currentTarget);
    const data: CreateShipmentData = {
      shipping_date: formData.get('shipping_date') as string,
      recipient_name: formData.get('recipient_name') as string,
      recipient_address: formData.get('recipient_address') as string,
      recipient_phone: formData.get('recipient_phone') as string,
      items: items.filter(item => item.product_code && item.quantity > 0),
      additional_info: formData.get('additional_info') as string || undefined
    };

    try {
      await onSubmit(data);
    } finally {
      setLoading(false);
    }
  };

  const addItem = () => {
    setItems([...items, { product_code: '', quantity: 1 }]);
  };

  return (
    <div className="fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center p-4">
      <div className="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div className="px-6 py-4 border-b border-gray-200">
          <h3 className="text-xl font-semibold text-gray-900">Create New Shipment</h3>
        </div>
        
        <form onSubmit={handleSubmit} className="p-6 space-y-6">
          <div>
            <label className="block text-sm font-semibold text-gray-900 mb-1">
              Shipping Date
            </label>
            <input
              type="date"
              name="shipping_date"
              required
              className="mt-1 h-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 text-gray-900 bg-white"
            />
          </div>

          <div>
            <label className="block text-sm font-semibold text-gray-900 mb-1">
              Recipient Name
            </label>
            <input
              type="text"
              name="recipient_name"
              required
              className="mt-1 h-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 text-gray-900 bg-white"
            />
          </div>

          <div>
            <label className="block text-sm font-semibold text-gray-900 mb-1">
              Recipient Address
            </label>
            <textarea
              name="recipient_address"
              required
              rows={3}
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 text-gray-900 bg-white"
            />
          </div>

          <div>
            <label className="block text-sm font-semibold text-gray-900 mb-1">
              Recipient Phone
            </label>
            <input
              type="tel"
              name="recipient_phone"
              required
              className="mt-1 h-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 text-gray-900 bg-white"
            />
          </div>

          <div>
            <div className="flex justify-between items-center mb-2">
              <label className="block text-sm font-semibold text-gray-900">
                Items
              </label>
              <button
                type="button"
                onClick={addItem}
                className="text-sm font-medium text-blue-600 hover:text-blue-700"
              >
                + Add Item
              </button>
            </div>
            <div className="space-y-4">
              {items.map((item, index) => (
                <div key={index} className="grid grid-cols-2 gap-4">
                  <select
                    value={item.product_code}
                    onChange={(e) => {
                      const newItems = [...items];
                      newItems[index].product_code = e.target.value;
                      setItems(newItems);
                    }}
                    required
                    className="h-10 rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 text-gray-900 bg-white"
                  >
                    <option value="">Select Product</option>
                    {products.map((product) => (
                      <option key={product.product_code} value={product.product_code}>
                        {product.name}
                      </option>
                    ))}
                  </select>
                  <input
                    type="number"
                    min="1"
                    value={item.quantity}
                    onChange={(e) => {
                      const newItems = [...items];
                      newItems[index].quantity = parseInt(e.target.value);
                      setItems(newItems);
                    }}
                    required
                    className="h-10 rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 text-gray-900 bg-white"
                  />
                </div>
              ))}
            </div>
          </div>

          <div>
            <label className="block text-sm font-semibold text-gray-900 mb-1">
              Additional Info
            </label>
            <textarea
              name="additional_info"
              rows={2}
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 text-gray-900 bg-white"
            />
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
              {loading ? 'Creating...' : 'Create Shipment'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}