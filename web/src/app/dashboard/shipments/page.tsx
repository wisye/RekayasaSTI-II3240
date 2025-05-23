'use client';

import { useState, useEffect } from 'react';
import { UserCircleIcon, PlusCircleIcon, PlusIcon } from '@heroicons/react/24/outline';
import { useAuth } from '@/contexts/AuthContext';
import ShipmentDetail from '@/components/ShipmentDetail';
import ShipmentForm from '@/components/ShipmentForm';
import { Shipment } from '@/types';
import { getShipments } from '@/lib/api';

export default function Shipments() {
  const [shipments, setShipments] = useState<Shipment[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [selectedShipment, setSelectedShipment] = useState<Shipment | null>(null);
  const [showForm, setShowForm] = useState(false);
  const { username } = useAuth();

  useEffect(() => {
    fetchShipments();
  }, []);

  const fetchShipments = async () => {
    try {
      const data = await getShipments();
      setShipments(data);
    } catch (err) {
      setError('Failed to load shipments');
    } finally {
      setLoading(false);
    }
  };

  const handleCreateShipment = async (shipment: any) => {
    // Implement create shipment logic
    await fetchShipments();
    setShowForm(false);
  };

  return (
        <div className="p-8 relative">
      {/* Header */}
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-xl font-medium text-purple-600">
            Shipments
          </h1>
          <p className="text-sm text-gray-500">
            Manage your shipments and track their status
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
            All Shipments
          </h2>
        </div>

        {loading ? (
          <p>Loading...</p>
        ) : error ? (
          <p className="text-red-500">{error}</p>
        ) : shipments.length === 0 ? (
          <div className="text-center py-12">
            <p className="text-gray-500 mb-4">No shipments found</p>
            <button
              onClick={() => setShowForm(true)}
              className="inline-flex items-center px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700"
            >
              <PlusCircleIcon className="h-5 w-5 mr-2" />
              Create New Shipment
            </button>
          </div>
        ) : (
          <div className="grid gap-4">
            {shipments.map((shipment) => (
              <div
                key={shipment.shipment_code}
                onClick={() => setSelectedShipment(shipment)}
                className="bg-white rounded-lg shadow p-4 cursor-pointer hover:bg-gray-50 transition-colors"
              >
                <div className="flex justify-between items-start">
                  <div>
                    <p className="font-medium text-gray-900">
                      No Pesanan: <span>{shipment.shipment_code}</span>
                    </p>
                    <p className="text-sm text-gray-700 mt-1">
                      To: {shipment.recipient_name}
                    </p>
                    <p className="text-sm text-gray-700">
                      {new Date(shipment.shipping_date).toLocaleDateString()}
                    </p>
                  </div>
                  <div className="flex flex-col items-end space-y-2">
                    <span className={`
                      inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium
                      ${shipment.status === 'Delivered' 
                        ? 'bg-green-100 text-green-800' 
                        : 'bg-yellow-100 text-yellow-800'
                      }
                    `}>
                      {shipment.status}
                    </span>
                    {shipment.constraints_violated && (
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                        Constraint Violated
                      </span>
                    )}
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
        <span className="sr-only">New Shipment</span>
      </button>

      {/* Shipment Detail Modal */}
      {selectedShipment && (
        <ShipmentDetail
          shipment={selectedShipment}
          onClose={() => setSelectedShipment(null)}
        />
      )}

      {/* Create Shipment Modal */}
      {selectedShipment && (
        <ShipmentDetail
          shipment={selectedShipment}
          onClose={() => setSelectedShipment(null)}
        />
      )}

      {showForm && (
        <ShipmentForm
          onClose={() => setShowForm(false)}
          onSubmit={handleCreateShipment}
        />
      )}
    </div>
  );
}