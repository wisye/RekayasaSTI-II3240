'use client';

import { Shipment, ShipmentItem } from '@/types';
import { useEffect } from 'react';
import { XMarkIcon, ExclamationTriangleIcon, CheckCircleIcon } from '@heroicons/react/24/outline';
import { useTemperatureCheck } from '@/hooks/useTemperatureCheck';

interface ShipmentDetailProps {
  shipment: Shipment;
  onClose: () => void;
}

function isShipped(shippingDate: string): boolean {
  const shipmentDate = new Date(shippingDate);
  const currentDate = new Date();
  // Reset time portion for date comparison
  shipmentDate.setHours(0, 0, 0, 0);
  currentDate.setHours(0, 0, 0, 0);
  return shipmentDate < currentDate;
}

export default function ShipmentDetail({ shipment, onClose }: ShipmentDetailProps) {
  const { data: tempData, error: tempError } = useTemperatureCheck(shipment.shipment_code);
  const displayStatus = isShipped(shipment.shipping_date) ? 'Shipped' : shipment.status;

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'Delivered':
        return 'bg-green-100 text-green-800';
      case 'Shipped':
        return 'bg-blue-100 text-blue-800';
      default:
        return 'bg-yellow-100 text-yellow-800';
    }
  };

  useEffect(() => {
    document.body.style.overflow = 'hidden';
    return () => {
      document.body.style.overflow = 'unset';
    };
  }, []);

  return (
    <div className="fixed inset-0 z-50">
      <div className="absolute inset-0 backdrop-blur-sm bg-white/30" onClick={onClose} />

      <div className="relative flex items-center justify-center min-h-screen p-4">
        <div className="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto shadow-xl">
          <div className="px-6 py-4 border-b border-gray-200 flex justify-between items-center sticky top-0 bg-white z-10">
            <div>
              <h3 className="text-lg font-medium text-gray-900">
                Shipment Details
              </h3>
              <p className="text-sm text-gray-500">{shipment.shipment_code}</p>
            </div>
            <button onClick={onClose} className="p-2 rounded-full hover:bg-gray-100">
              <XMarkIcon className="h-5 w-5 text-gray-400" />
            </button>
          </div>

          <div className="p-6 space-y-6">
            {/* Status Badges */}
            <div className="flex justify-between items-center">
              <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(displayStatus)}`}>
                {displayStatus}
              </span>
              {shipment.constraints_violated && (
                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                  <ExclamationTriangleIcon className="h-4 w-4 mr-1" />
                  Constraints Violated
                </span>
              )}
            </div>

            {/* Items with Environmental Monitoring */}
            <div>
              <h4 className="text-sm font-medium text-gray-500 mb-3">Items</h4>
              <div className="bg-gray-50 rounded-lg divide-y divide-gray-200">
                {shipment.items.map((item: ShipmentItem) => (
                  <div key={item.product_id} className="p-4">
                    <div className="space-y-4">
                      {/* Item Details */}
                      <div className="flex items-start justify-between">
                        <div className="space-y-1">
                          <p className="text-sm font-medium text-gray-900">
                            {item.product_name}
                          </p>
                          <p className="text-sm text-gray-700">
                            Quantity: {item.quantity}
                          </p>
                          <p className="text-sm text-gray-500">
                            Product ID: {item.product_id}
                          </p>
                        </div>
                        {shipment.constraints_violated && (
                          <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                            <ExclamationTriangleIcon className="h-4 w-4 mr-1" />
                            Constraints Violated
                          </span>
                        )}
                      </div>

                      {/* Environmental Monitoring per Item */}
                      <div className="bg-white rounded-lg p-3 border border-gray-200">
                        <h5 className="text-xs font-medium text-gray-500 mb-2">Environmental Data</h5>
                        {tempError ? (
                          <p className="text-red-600 text-sm">{tempError}</p>
                        ) : !tempData ? (
                          <p className="text-gray-500 text-sm">Loading data...</p>
                        ) : (
                          <div className="grid grid-cols-2 gap-4">
                            <div>
                              <p className="text-xs text-gray-500">Temperature</p>
                              <span className="text-sm text-gray-600">
                                {tempData.temperature}°C
                              </span>
                            </div>
                            <div>
                              <p className="text-xs text-gray-500">Humidity</p>
                              <span className="text-sm text-gray-600">
                                {tempData.humidity}%
                              </span>
                            </div>
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}