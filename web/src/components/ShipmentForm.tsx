'use client';

import { useState } from 'react';

interface ShipmentFormProps {
  onClose: () => void;
  onSubmit: (data: any) => void;
}

export default function ShipmentForm({ onClose, onSubmit }: ShipmentFormProps) {
  const [products, setProducts] = useState([{ name: '', quantity: 1 }]);

  const addProduct = () => {
    setProducts([...products, { name: '', quantity: 1 }]);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const form = e.target as HTMLFormElement;
    const formData = new FormData(form);
    
    const data = {
      orderCode: formData.get('orderCode'),
      shippingDate: formData.get('shippingDate'),
      recipientName: formData.get('recipientName'),
      recipientAddress: formData.get('recipientAddress'),
      phoneNumber: formData.get('phoneNumber'),
      additionalInfo: formData.get('additionalInfo'),
      products: products,
    };

    onSubmit(data);
  };

  return (
    <div className="fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center p-4">
      <div className="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div className="px-6 py-4 border-b border-gray-200">
          <h3 className="text-xl font-semibold text-gray-900">New Shipment</h3>
        </div>
        
        <form onSubmit={handleSubmit} className="p-6 space-y-6">
          <div className="grid grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-semibold text-gray-900 mb-1">
                Order Code
              </label>
              <input
                type="text"
                name="orderCode"
                required
                className="mt-1 h-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 text-gray-900 bg-white placeholder-gray-500"
              />
            </div>
            <div>
              <label className="block text-sm font-semibold text-gray-900 mb-1">
                Shipping Date
              </label>
              <input
                type="date"
                name="shippingDate"
                required
                className="mt-1 h-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 text-gray-900 bg-white"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-semibold text-gray-900 mb-1">
              Recipient Name
            </label>
            <input
              type="text"
              name="recipientName"
              required
              className="mt-1 h-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 text-gray-900 bg-white placeholder-gray-500"
            />
          </div>

          <div>
            <label className="block text-sm font-semibold text-gray-900 mb-1">
              Recipient Address
            </label>
            <textarea
              name="recipientAddress"
              required
              rows={3}
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 text-gray-900 bg-white placeholder-gray-500"
            />
          </div>

          <div>
            <label className="block text-sm font-semibold text-gray-900 mb-1">
              Phone Number
            </label>
            <input
              type="tel"
              name="phoneNumber"
              required
              className="mt-1 h-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 text-gray-900 bg-white placeholder-gray-500"
            />
          </div>

          <div>
            <label className="block text-sm font-semibold text-gray-900 mb-1">
              Additional Info
            </label>
            <textarea
              name="additionalInfo"
              rows={2}
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 text-gray-900 bg-white placeholder-gray-500"
            />
          </div>

          <div>
            <div className="flex justify-between items-center mb-2">
              <label className="block text-sm font-semibold text-gray-900">Products</label>
              <button
                type="button"
                onClick={addProduct}
                className="text-sm font-medium text-blue-600 hover:text-blue-700"
              >
                + Add Product
              </button>
            </div>
            <div className="space-y-4">
              {products.map((_, index) => (
                <div key={index} className="grid grid-cols-2 gap-4">
                  <input
                    type="text"
                    name={`product-${index}-name`}
                    placeholder="Product name"
                    required
                    className="h-10 rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 text-gray-900 bg-white placeholder-gray-500"
                    onChange={e => {
                      const newProducts = [...products];
                      newProducts[index].name = e.target.value;
                      setProducts(newProducts);
                    }}
                  />
                  <input
                    type="number"
                    name={`product-${index}-quantity`}
                    placeholder="Quantity"
                    min="1"
                    required
                    className="h-10 rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 text-gray-900 bg-white placeholder-gray-500"
                    onChange={e => {
                      const newProducts = [...products];
                      newProducts[index].quantity = parseInt(e.target.value);
                      setProducts(newProducts);
                    }}
                  />
                </div>
              ))}
            </div>
          </div>

          <div className="flex justify-end space-x-3">
            <button
              type="button"
              onClick={onClose}
              className="h-10 px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="h-10 px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              Create Shipment
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}