'use client';

import { useState, useEffect } from 'react';
import { XMarkIcon, PlusIcon, TrashIcon } from '@heroicons/react/24/outline';
import { Product } from '@/types';
import { getProducts } from '@/lib/api';

interface ShipmentFormProps {
  onClose: () => void;
  onSubmit: (data: any) => void;
}

interface SelectedProduct {
  product: Product;
  quantity: number;
}

export default function ShipmentForm({ onClose, onSubmit }: ShipmentFormProps) {
  const [loading, setLoading] = useState(false);
  const [products, setProducts] = useState<Product[]>([]);
  const [selectedProducts, setSelectedProducts] = useState<SelectedProduct[]>([]);

  useEffect(() => {
    fetchProducts();
  }, []);

  const fetchProducts = async () => {
    try {
      const data = await getProducts();
      setProducts(data);
    } catch (error) {
      console.error('Failed to fetch products:', error);
    }
  };

  const handleAddProduct = () => {
    setSelectedProducts([...selectedProducts, { product: products[0], quantity: 1 }]);
  };

  const handleRemoveProduct = (index: number) => {
    setSelectedProducts(selectedProducts.filter((_, i) => i !== index));
  };

  const handleProductChange = (index: number, productId: number) => {
    const product = products.find(p => p.id === Number(productId));
    if (product) {
      const newProducts = [...selectedProducts];
      newProducts[index] = { ...newProducts[index], product };
      setSelectedProducts(newProducts);
    }
  };

  const handleQuantityChange = (index: number, quantity: number) => {
    const newProducts = [...selectedProducts];
    newProducts[index] = { ...newProducts[index], quantity };
    setSelectedProducts(newProducts);
  };

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setLoading(true);
    const formData = new FormData(e.currentTarget);
    
    const data = {
      recipient_name: formData.get('recipient_name'),
      recipient_address: formData.get('recipient_address'),
      recipient_phone: formData.get('recipient_phone'),
      shipping_date: formData.get('shipping_date'),
      items: selectedProducts.map(sp => ({
        product_id: sp.product.id,
        quantity: sp.quantity
      }))
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
            <h3 className="text-lg font-medium text-gray-900">Create New Shipment</h3>
            <button onClick={onClose} className="p-2 rounded-full hover:bg-gray-100">
              <XMarkIcon className="h-5 w-5 text-gray-400" />
            </button>
          </div>

          <form onSubmit={handleSubmit} className="p-6 space-y-6">
            {/* Recipient Information */}
            <div className="bg-gray-50 rounded-lg p-4 space-y-4">
              <h4 className="text-sm font-medium text-gray-900">Recipient Information</h4>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label htmlFor="recipient_name" className="block text-sm font-medium text-gray-700">
                    Name
                  </label>
                  <input
                    type="text"
                    name="recipient_name"
                    id="recipient_name"
                    required
                    className="mt-1 h-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500 text-gray-900"
                  />
                </div>
                <div>
                  <label htmlFor="recipient_phone" className="block text-sm font-medium text-gray-700">
                    Phone Number
                  </label>
                  <input
                    type="tel"
                    name="recipient_phone"
                    id="recipient_phone"
                    required
                    className="mt-1 h-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500 text-gray-900"
                  />
                </div>
              </div>
              <div>
                <label htmlFor="recipient_address" className="block text-sm font-medium text-gray-700">
                  Address
                </label>
                <textarea
                  name="recipient_address"
                  id="recipient_address"
                  rows={3}
                  required
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500 text-gray-900"
                />
              </div>
            </div>

            {/* Shipping Date */}
            <div>
              <label htmlFor="shipping_date" className="block text-sm font-medium text-gray-700">
                Shipping Date
              </label>
              <input
                type="date"
                name="shipping_date"
                id="shipping_date"
                required
                className="mt-1 h-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500 text-gray-900"
              />
            </div>

            {/* Products Selection */}
            <div className="space-y-4">
              <div className="flex justify-between items-center">
                <h4 className="text-sm font-medium text-gray-900">Products</h4>
                <button
                  type="button"
                  onClick={handleAddProduct}
                  className="inline-flex items-center px-3 py-1.5 text-sm font-medium text-purple-600 hover:text-purple-700"
                >
                  <PlusIcon className="h-5 w-5 mr-1" />
                  Add Product
                </button>
              </div>

              <div className="space-y-3">
                {selectedProducts.map((sp, index) => (
                  <div key={index} className="flex items-center space-x-4 bg-gray-50 p-4 rounded-lg">
                    <div className="flex-grow">
                      <select
                        value={sp.product.id}
                        onChange={(e) => handleProductChange(index, Number(e.target.value))}
                        className="h-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500 text-gray-900"
                      >
                        {products.map(product => (
                          <option key={product.id} value={product.id}>
                            {product.name} ({product.product_code})
                          </option>
                        ))}
                      </select>
                    </div>
                    <div className="w-32">
                      <input
                        type="number"
                        min="1"
                        value={sp.quantity}
                        onChange={(e) => handleQuantityChange(index, Number(e.target.value))}
                        className="h-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500 text-gray-900"
                      />
                    </div>
                    <button
                      type="button"
                      onClick={() => handleRemoveProduct(index)}
                      className="p-2 text-gray-400 hover:text-red-500"
                    >
                      <TrashIcon className="h-5 w-5" />
                    </button>
                  </div>
                ))}
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
                disabled={loading || selectedProducts.length === 0}
                className="px-4 py-2 text-sm font-medium text-white bg-purple-600 hover:bg-purple-700 rounded-md disabled:opacity-50"
              >
                {loading ? 'Creating...' : 'Create Shipment'}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}