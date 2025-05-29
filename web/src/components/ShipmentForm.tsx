'use client';

import { useState, useEffect } from 'react';
import { PlusIcon, TrashIcon, XMarkIcon } from '@heroicons/react/24/outline';
import { createShipment, getProducts } from '@/lib/api';
import { Product, CreateShipmentData, CreateShipmentItem } from '@/types';

interface SelectedProduct {
  product: Product;
  quantity: number;
}

interface ShipmentFormProps {
  onClose: () => void;
  onSubmit?: (data: CreateShipmentData) => void;
}

// Common CSS classes for form elements
const inputClassName = "mt-1 block w-full h-10 rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500 text-gray-900";
const labelClassName = "block text-sm font-medium text-gray-800";

export default function ShipmentForm({ onClose, onSubmit }: ShipmentFormProps) {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [products, setProducts] = useState<Product[]>([]);
  const [selectedProducts, setSelectedProducts] = useState<SelectedProduct[]>([]);

  useEffect(() => {
    fetchProducts();
  }, []);

  const fetchProducts = async () => {
    try {
      const data = await getProducts();
      setProducts(data);
      if (data.length > 0) {
        setSelectedProducts([{ product: data[0], quantity: 1 }]);
      }
    } catch (error) {
      console.error('Failed to fetch products:', error);
      setError('Failed to load products. Please try again.');
    }
  };

  const handleAddProduct = () => {
    if (products.length > 0) {
      setSelectedProducts([...selectedProducts, { product: products[0], quantity: 1 }]);
    }
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
    setError('');

    try {
      const formData = new FormData(e.currentTarget);

      const shipmentData: CreateShipmentData = {
        recipient_name: formData.get('recipient_name') as string,
        recipient_address: formData.get('recipient_address') as string,
        recipient_phone: formData.get('recipient_phone') as string,
        shipping_date: formData.get('shipping_date') as string,
        additional_info: "",
        items: selectedProducts.map((sp): CreateShipmentItem => ({
          product_code: sp.product.product_code,
          quantity: sp.quantity
        }))
      };

      const response = await createShipment(shipmentData);

      if (onSubmit) {
        await onSubmit(response);
      }

      onClose();
    } catch (err) {
      console.error('Error creating shipment:', err);
      setError('Failed to create shipment. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50">
      <div className="absolute inset-0 backdrop-blur-sm bg-white/30" onClick={onClose} />

      <div className="relative flex items-center justify-center min-h-screen p-4">
        <div className="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto shadow-xl">
          <div className="px-6 py-4 border-b border-gray-200 flex justify-between items-center sticky top-0 bg-white z-10">
            <h3 className="text-xl font-semibold text-gray-900">Create New Shipment</h3>
            <button onClick={onClose} className="p-2 rounded-full hover:bg-gray-100">
              <XMarkIcon className="h-5 w-5 text-gray-400" />
            </button>
          </div>

          <form onSubmit={handleSubmit} className="p-6 space-y-6">
            {/* Recipient Information */}
            <div className="bg-gray-50 rounded-lg p-4 space-y-4">
              <h4 className="text-sm font-medium text-gray-900">Recipient Information</h4>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label htmlFor="recipient_name" className={labelClassName}>Name</label>
                  <input
                    type="text"
                    name="recipient_name"
                    id="recipient_name"
                    required
                    className={inputClassName}
                  />
                </div>
                <div>
                  <label htmlFor="recipient_phone" className={labelClassName}>Phone Number</label>
                  <input
                    type="tel"
                    name="recipient_phone"
                    id="recipient_phone"
                    required
                    className={inputClassName}
                  />
                </div>
              </div>
              <div>
                <label htmlFor="recipient_address" className={labelClassName}>Address</label>
                <textarea
                  name="recipient_address"
                  id="recipient_address"
                  rows={3}
                  required
                  className={`${inputClassName} h-24`}
                />
              </div>
            </div>

            {/* Shipping Date */}
            <div>
              <label htmlFor="shipping_date" className={labelClassName}>Shipping Date</label>
              <input
                type="date"
                name="shipping_date"
                id="shipping_date"
                required
                className={inputClassName}
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
                        className={inputClassName}
                      >
                        {products.map(product => (
                          <option key={product.id} value={product.id}>
                            {product.name}
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
                        className={inputClassName}
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

            {error && (
              <div className="text-red-700 text-sm font-medium">
                {error}
              </div>
            )}

            <div className="flex justify-end space-x-3 pt-6 border-t border-gray-200">
              <button
                type="button"
                onClick={onClose}
                className="px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 rounded-md border border-gray-300 h-10"
              >
                Cancel
              </button>
              <button
                type="submit"
                disabled={loading || selectedProducts.length === 0}
                className="px-4 py-2 text-sm font-medium text-white bg-purple-600 hover:bg-purple-700 rounded-md disabled:opacity-50 h-10"
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