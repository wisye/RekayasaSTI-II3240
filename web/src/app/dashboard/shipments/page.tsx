'use client';

import { useState, useEffect } from 'react';
import { createShipment, getShipments } from '@/lib/api';
import { CreateShipmentData, Shipment } from '@/types';
import ShipmentForm from '@/components/ShipmentForm';
import ShipmentDetail from '@/components/ShipmentDetail';

export default function Shipments() {
  const [shipments, setShipments] = useState<Shipment[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [showForm, setShowForm] = useState(false);
  const [selectedShipment, setSelectedShipment] = useState<Shipment | null>(null);

  useEffect(() => {
    fetchShipments();
  }, []);

  const fetchShipments = async () => {
    try {
      const data = await getShipments();
      setShipments(data);
    } catch (err) {
      setError('Failed to load shipments');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleCreateShipment = async (data: CreateShipmentData) => {
    try {
      await createShipment(data);
      await fetchShipments();
      setShowForm(false);
    } catch (err) {
      console.error('Failed to create shipment:', err);
      throw err;
    }
  };

  if (loading) return <div className="p-4">Loading...</div>;
  if (error) return <div className="p-4 text-red-500">{error}</div>;

  return (
    <div className="py-6">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="sm:flex sm:items-center">
          <div className="sm:flex-auto">
            <h1 className="text-2xl font-semibold text-gray-900">Shipments</h1>
            <p className="mt-2 text-sm text-gray-700">
              A list of all shipments and their current status.
            </p>
          </div>
          <div className="mt-4 sm:mt-0 sm:ml-16 sm:flex-none">
            <button
              onClick={() => setShowForm(true)}
              className="inline-flex items-center justify-center rounded-md border border-transparent bg-blue-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-blue-700"
            >
              Create Shipment
            </button>
          </div>
        </div>

        <div className="mt-8 overflow-hidden bg-white shadow sm:rounded-md">
          <ul role="list" className="divide-y divide-gray-200">
            {shipments.map((shipment) => (
              <li 
                key={shipment.shipment_code}
                onClick={() => setSelectedShipment(shipment)}
                className="hover:bg-gray-50 cursor-pointer"
              >
                <div className="px-4 py-4 sm:px-6">
                  <div className="flex items-center justify-between">
                    <div className="truncate">
                      <div className="flex text-sm">
                        <p className="font-medium text-blue-600 truncate">
                          {shipment.shipment_code}
                        </p>
                        <p className="ml-1 font-normal text-gray-500">
                          to {shipment.recipient_name}
                        </p>
                      </div>
                      <div className="mt-2 flex">
                        <div className="flex items-center text-sm text-gray-500">
                          <p>Shipping Date: {new Date(shipment.shipping_date).toLocaleDateString()}</p>
                        </div>
                      </div>
                    </div>
                    <div className="ml-2 flex flex-shrink-0">
                      <span className={`
                        inline-flex rounded-full px-2 text-xs font-semibold leading-5
                        ${shipment.constraints_violated 
                          ? 'bg-red-100 text-red-800' 
                          : 'bg-green-100 text-green-800'
                        }
                      `}>
                        {shipment.status}
                      </span>
                    </div>
                  </div>
                  <div className="mt-4 sm:flex sm:justify-between">
                    <div className="sm:flex">
                      <div className="mr-6 flex items-center text-sm text-gray-500">
                        <span className="font-medium">Items:</span>
                        <ul className="ml-2">
                          {shipment.items.map((item) => (
                            <li key={item.product_id} className="flex items-center">
                              {item.product_name} (x{item.quantity})
                              {item.constraints_violated && (
                                <span className="ml-2 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                                  Constraint Violation
                                </span>
                              )}
                            </li>
                          ))}
                        </ul>
                      </div>
                    </div>
                  </div>
                </div>
              </li>
            ))}
          </ul>
        </div>

        {showForm && (
          <ShipmentForm
            onClose={() => setShowForm(false)}
            onSubmit={handleCreateShipment}
          />
        )}

        {selectedShipment && (
          <ShipmentDetail
            shipment={selectedShipment}
            onClose={() => setSelectedShipment(null)}
          />
        )}
      </div>
    </div>
  );
}