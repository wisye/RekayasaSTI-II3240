'use client';

import { useState, useEffect } from 'react';
import { UserCircleIcon } from '@heroicons/react/24/outline';
import { useAuth } from '@/contexts/AuthContext';
import ShipmentDetail from '@/components/ShipmentDetail';
import { Shipment } from '@/types';
import { getShipments } from '@/lib/api';

function isShipped(shippingDate: string): boolean {
  const shipmentDate = new Date(shippingDate);
  const currentDate = new Date();
  // Reset time portion for date comparison
  shipmentDate.setHours(0, 0, 0, 0);
  currentDate.setHours(0, 0, 0, 0);
  return shipmentDate < currentDate; // Changed from <= to <
}

export default function Reports() {
  const [shipments, setShipments] = useState<Shipment[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [selectedShipment, setSelectedShipment] = useState<Shipment | null>(null);
  const { username } = useAuth();

  useEffect(() => {
    fetchShipments();
  }, []);

  const fetchShipments = async () => {
    try {
      const data = await getShipments();
      // Filter shipments based on shipping date
      const shippedShipments = data.filter((shipment: Shipment) => 
        isShipped(shipment.shipping_date)
      ).map((shipment: Shipment) => ({
        ...shipment,
        // Override status based on date
        status: 'Shipped'
      }));
      setShipments(shippedShipments);
    } catch (err) {
      setError('Failed to load shipment reports');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-8">
      {/* Header */}
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-xl font-medium text-purple-600">
            Shipment Reports
          </h1>
          <p className="text-sm text-gray-500">
            View detailed reports of shipped items
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
            Shipped Items Report
          </h2>
        </div>

        {loading ? (
          <p>Loading...</p>
        ) : error ? (
          <p className="text-red-500">{error}</p>
        ) : shipments.length === 0 ? (
          <p className="text-center text-gray-500 py-8">
            No shipped items to report.
          </p>
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
                      Shipped Date: {new Date(shipment.shipping_date).toLocaleDateString()}
                    </p>
                  </div>
                  <div className="flex flex-col items-end space-y-2">
                    <span className={`
                      inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium
                      ${shipment.status === 'Delivered' ? 'bg-green-100 text-green-800' : 'bg-blue-100 text-blue-800'}
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

      {/* Shipment Detail Modal */}
      {selectedShipment && (
        <ShipmentDetail
          shipment={selectedShipment}
          onClose={() => setSelectedShipment(null)}
        />
      )}
    </div>
  );
}