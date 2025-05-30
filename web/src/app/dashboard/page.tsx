'use client';

import { useState, useEffect } from 'react';
import { UserCircleIcon } from '@heroicons/react/24/outline';
import { useAuth } from '@/contexts/AuthContext';
import Calendar from '@/components/Calendar';
import ShipmentDetail from '@/components/ShipmentDetail';
import { Shipment } from '@/types';
import { getRecentShipments } from '@/lib/api';

const getShipmentStatus = (shipment: Shipment) => {
  if (shipment.status === 'Delivered') {
    return {
      status: 'Delivered',
      className: 'bg-green-100 text-green-800'
    };
  }

  const shipmentDate = new Date(shipment.shipping_date);
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  if (shipmentDate <= today) {
    return {
      status: 'Shipped',
      className: 'bg-blue-100 text-blue-800'
    };
  }

  return {
    status: 'Prepared',
    className: 'bg-yellow-100 text-yellow-800'
  };
};

export default function Dashboard() {
  const [recentShipments, setRecentShipments] = useState<Shipment[]>([]);
  const [selectedDateShipments, setSelectedDateShipments] = useState<Shipment[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [selectedDate, setSelectedDate] = useState<Date | null>(null);
  const [selectedShipment, setSelectedShipment] = useState<Shipment | null>(null);
  const { username } = useAuth();

  useEffect(() => {
    fetchRecentShipments();
  }, []);

  const fetchRecentShipments = async () => {
    try {
      const data = await getRecentShipments();
      setRecentShipments(data);
    } catch (err) {
      setError('Failed to load recent shipments');
    } finally {
      setLoading(false);
    }
  };

  const handleDateSelect = (date: Date) => {
    setSelectedDate(date);
    const shipmentsOnDate = recentShipments.filter(shipment =>
      new Date(shipment.shipping_date).toDateString() === date.toDateString()
    );
    setSelectedDateShipments(shipmentsOnDate);
  };

  return (
    <div className="p-8">
      {/* Header */}
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-xl font-medium text-purple-600">
            Hello, {username}! 👋
          </h1>
          <p className="text-sm text-gray-500">
            Good morning! Here are your recent shipments.
          </p>
        </div>
        <div>
          <UserCircleIcon className="h-8 w-8 text-gray-400" />
        </div>
      </div>

      {/* Main Content */}
      <div className="grid grid-cols-2 gap-8">
        {/* Recent Shipments */}
        <div>
          <div className="bg-gradient-to-r from-purple-100 to-pink-100 rounded-lg p-4 mb-4">
            <h2 className="text-lg font-medium text-gray-900">
              Recent Shipments
            </h2>
          </div>

          {loading ? (
            <p>Loading...</p>
          ) : error ? (
            <p className="text-red-500">{error}</p>
          ) : recentShipments.length === 0 ? (
            <p className="text-center text-gray-500 py-8">
              Add new shipments to see them here.
            </p>
          ) : (
            <div className="space-y-4">
              {recentShipments.map((shipment) => (
                <div
                  key={shipment.shipment_code}
                  onClick={() => setSelectedShipment(shipment)}
                  className="bg-white rounded-lg shadow p-4 cursor-pointer hover:bg-gray-50 transition-colors"
                >
                  <div className="flex justify-between items-start">
                    <div>
                      <p className="font-medium text-gray-900">
                        No Pesanan: <span className="text-gray-900">{shipment.shipment_code}</span>
                      </p>
                      <p className="text-sm text-gray-700">
                        {new Date(shipment.shipping_date).toLocaleDateString()}
                      </p>
                    </div>
                    <div className="flex flex-col items-end space-y-2">
                      <span className={`
                        inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium
                        ${getShipmentStatus(shipment).className}
                      `}>
                        {getShipmentStatus(shipment).status}
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

        {/* Calendar */}
        <div className="bg-white rounded-lg shadow p-6">
          <Calendar
            onSelectDate={handleDateSelect}
            shipments={recentShipments}
          />

          {selectedDate && selectedDateShipments.length > 0 && (
            <div className="mt-6">
              <h3 className="text-lg font-medium text-gray-900 mb-4">
                Shipments on {selectedDate.toLocaleDateString()}
              </h3>
              <div className="space-y-4">
                {selectedDateShipments.map((shipment) => (
                  <div
                    key={shipment.shipment_code}
                    onClick={() => setSelectedShipment(shipment)}
                    className="bg-white border border-gray-200 rounded-lg p-4 cursor-pointer hover:bg-gray-50 transition-colors"
                  >
                    <div className="flex justify-between items-start">
                      <div>
                        <p className="font-medium text-gray-900">
                          No Pesanan: <span>{shipment.shipment_code}</span>
                        </p>
                        <p className="text-sm text-gray-700 mt-1">
                          to: {shipment.recipient_name}
                        </p>
                      </div>
                      <div className="flex flex-col items-end space-y-2">
                        <span className={`
                  inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium
                  ${getShipmentStatus(shipment).className}
                `}>
                          {getShipmentStatus(shipment).status}
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
            </div>
          )}
        </div>
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