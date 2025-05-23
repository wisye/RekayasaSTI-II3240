import { Shipment } from '@/types';

interface ShipmentDetailProps {
  shipment: Shipment;
  onClose: () => void;
}

export default function ShipmentDetail({ shipment, onClose }: ShipmentDetailProps) {
  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  };

  return (
    <div className="fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center p-4 z-50">
      <div className="bg-white rounded-lg max-w-3xl w-full max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="px-6 py-4 border-b border-gray-200 flex justify-between items-center bg-gray-50">
          <div>
            <h3 className="text-xl font-semibold text-gray-900">
              Shipment Details
            </h3>
            <p className="mt-1 text-sm text-gray-500">
              {shipment.shipment_code}
            </p>
          </div>
          <button
            onClick={onClose}
            className="rounded-md bg-white p-2 hover:bg-gray-100"
          >
            <span className="sr-only">Close</span>
            <svg className="h-6 w-6 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        {/* Content */}
        <div className="p-6 space-y-8">
          {/* Status and Dates */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <h4 className="text-sm font-medium text-gray-500">Status</h4>
              <div className="mt-2 flex items-center space-x-2">
                <span className={`
                  inline-flex rounded-full px-3 py-1 text-sm font-medium
                  ${shipment.status === 'Delivered' 
                    ? 'bg-green-100 text-green-800' 
                    : 'bg-yellow-100 text-yellow-800'
                  }
                `}>
                  {shipment.status}
                </span>
                {shipment.constraints_violated && (
                  <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-red-100 text-red-800">
                    Constraints Violated
                  </span>
                )}
              </div>
            </div>
            <div>
              <h4 className="text-sm font-medium text-gray-500">Shipping Date</h4>
              <p className="mt-2 text-sm text-gray-900">
                {formatDate(shipment.shipping_date)}
              </p>
            </div>
            {shipment.delivery_date && (
              <div>
                <h4 className="text-sm font-medium text-gray-500">Delivery Date</h4>
                <p className="mt-2 text-sm text-gray-900">
                  {formatDate(shipment.delivery_date)}
                </p>
              </div>
            )}
          </div>

          {/* Recipient Information */}
          <div className="bg-gray-50 rounded-lg p-4">
            <h4 className="text-sm font-medium text-gray-500 mb-3">Recipient Information</h4>
            <dl className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <dt className="text-sm font-medium text-gray-900">Name</dt>
                <dd className="mt-1 text-sm text-gray-500">{shipment.recipient_name}</dd>
              </div>
              <div>
                <dt className="text-sm font-medium text-gray-900">Phone</dt>
                <dd className="mt-1 text-sm text-gray-500">{shipment.recipient_phone}</dd>
              </div>
              <div className="md:col-span-2">
                <dt className="text-sm font-medium text-gray-900">Address</dt>
                <dd className="mt-1 text-sm text-gray-500">{shipment.recipient_address}</dd>
              </div>
            </dl>
          </div>

          {/* Items */}
          <div>
            <h4 className="text-sm font-medium text-gray-500 mb-3">Items</h4>
            <div className="bg-white border border-gray-200 rounded-lg overflow-hidden">
              <ul className="divide-y divide-gray-200">
                {shipment.items.map((item) => (
                  <li key={item.product_id} className="p-4">
                    <div className="flex items-center justify-between">
                      <div className="flex-1">
                        <h5 className="text-sm font-medium text-gray-900">{item.product_name}</h5>
                        <p className="mt-1 text-sm text-gray-500">Quantity: {item.quantity}</p>
                      </div>
                      <div className="ml-4">
                        {item.constraints_violated ? (
                          <div className="flex flex-col items-end">
                            <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                              Constraints Violated
                            </span>
                            <span className="text-xs text-red-600 mt-1">
                              Storage conditions exceeded
                            </span>
                          </div>
                        ) : (
                          <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                            Normal
                          </span>
                        )}
                      </div>
                    </div>
                  </li>
                ))}
              </ul>
            </div>
          </div>

          {/* Additional Information */}
          {shipment.additional_info && (
            <div>
              <h4 className="text-sm font-medium text-gray-500 mb-2">Additional Information</h4>
              <p className="text-sm text-gray-900 bg-gray-50 rounded-lg p-4">
                {shipment.additional_info}
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}