'use client';

import { useState } from 'react';
import { dummyShipments } from '@/lib/dummyData';
import ShipmentForm from '@/components/ShipmentForm';

export default function Shipments() {
  const [activeTab, setActiveTab] = useState<'all' | 'active' | 'delivered'>('all');
  const [showForm, setShowForm] = useState(false);
  const [shipments, setShipments] = useState(dummyShipments);

  // ...existing filtering code...

  const handleNewShipment = (data: any) => {
    const newShipment = {
      id: `SHP${shipments.length + 1}`.padStart(6, '0'),
      ...data,
      isDelivered: false,
      products: data.products.map((p: any) => ({
        ...p,
        id: `PROD${Math.random().toString(36).substr(2, 9)}`,
        hasConstraintViolation: false
      }))
    };

    setShipments([newShipment, ...shipments]);
    setShowForm(false);
  };

  return (
    <div className="py-6">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="sm:flex sm:items-center">
          <div className="sm:flex-auto">
            <h1 className="text-2xl font-semibold text-gray-900">Shipments</h1>
            <p className="mt-2 text-sm text-gray-700">
              A list of all shipments including their status, recipient details, and products.
            </p>
          </div>
          <div className="mt-4 sm:mt-0 sm:ml-16 sm:flex-none">
            <button
              type="button"
              onClick={() => setShowForm(true)}
              className="inline-flex items-center justify-center rounded-md border border-transparent bg-blue-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-blue-700"
            >
              Add Shipment
            </button>
          </div>
        </div>

        {/* ...existing tabs and list code... */}

        {showForm && (
          <ShipmentForm
            onClose={() => setShowForm(false)}
            onSubmit={handleNewShipment}
          />
        )}
      </div>
    </div>
  );
}