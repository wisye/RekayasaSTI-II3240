'use client';

import { Shipment, ShipmentItem } from '@/types';
import { useEffect } from 'react';
import { XMarkIcon, ExclamationTriangleIcon, CheckCircleIcon } from '@heroicons/react/24/outline';

interface ShipmentDetailProps {
  shipment: Shipment;
  onClose: () => void;
}

export default function ShipmentDetail({ shipment, onClose }: ShipmentDetailProps) {
  useEffect(() => {
    document.body.style.overflow = 'hidden';
    return () => {
      document.body.style.overflow = 'unset';
    };
  }, []);

  return (
    <div className="fixed inset-0 z-50">
      <div 
        className="absolute inset-0 backdrop-blur-sm bg-white/30"
        onClick={onClose}
      />

      <div className="relative flex items-center justify-center min-h-screen p-4">
        <div className="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto shadow-xl">
          <div className="px-6 py-4 border-b border-gray-200 flex justify-between items-center sticky top-0 bg-white z-10">
            <div>
              <h3 className="text-lg font-medium text-gray-900">
                Shipment Details
              </h3>
              <p className="text-sm text-gray-500">{shipment.shipment_code}</p>
            </div>
            <button
              onClick={onClose}
              className="p-2 rounded-full hover:bg-gray-100 transition-colors"
            >
              <XMarkIcon className="h-5 w-5 text-gray-400" />
            </button>
          </div>

          <div className="p-6 space-y-6">
            {/* Status */}
            <div className="flex items-center space-x-4">
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

            {/* Items */}
            <div>
              <h4 className="text-sm font-medium text-gray-500 mb-3">Items</h4>
              <div className="bg-gray-50 rounded-lg divide-y divide-gray-200">
                {shipment.items.map((item: ShipmentItem) => (
                  <div key={item.product_id} className="p-4">
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
                      <div className="flex items-center">
                        {item.constraints_violated ? (
                          <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                            <ExclamationTriangleIcon className="h-4 w-4 mr-1" />
                            Constraints Violated
                          </span>
                        ) : (
                          <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                            <CheckCircleIcon className="h-4 w-4 mr-1" />
                            Normal
                          </span>
                        )}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Additional Info */}
            {shipment.additional_info && (
              <div className="bg-gray-50 rounded-lg p-4">
                <h4 className="text-sm font-medium text-gray-500 mb-2">
                  Additional Information
                </h4>
                <p className="text-sm text-gray-700">
                  {shipment.additional_info}
                </p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}