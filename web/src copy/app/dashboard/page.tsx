'use client';

import { useState, useEffect } from 'react';
import { Shipment } from '@/types';
import Link from 'next/link';
import { getRecentShipments } from '@/lib/api';
import ShipmentDetail from '@/components/ShipmentDetail';

export default function Dashboard() {
  const [recentShipments, setRecentShipments] = useState<Shipment[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [selectedShipment, setSelectedShipment] = useState<Shipment | null>(null);

  useEffect(() => {
    fetchRecentShipments();
  }, []);

  const fetchRecentShipments = async () => {
    try {
      const data = await getRecentShipments();
      setRecentShipments(data);
    } catch (err) {
      setError('Failed to load recent shipments');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <div className="p-4">Loading...</div>;
  if (error) return <div className="p-4 text-red-500">{error}</div>;

  // Calculate metrics
  const totalShipments = recentShipments.length;
  const activeShipments = recentShipments.filter(s => s.status !== 'Delivered').length;
  const constraintViolations = recentShipments.filter(s => s.constraints_violated).length;

  return (
    <div className="py-6">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <h1 className="text-2xl font-semibold text-gray-900">Dashboard</h1>

        {/* Metrics */}
        <div className="mt-6 grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
          <div className="bg-white overflow-hidden shadow rounded-lg">
            <div className="p-5">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <svg className="h-6 w-6 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" />
                  </svg>
                </div>
                <div className="ml-5 w-0 flex-1">
                  <dl>
                    <dt className="text-sm font-medium text-gray-500 truncate">Total Recent Shipments</dt>
                    <dd className="text-lg font-medium text-gray-900">{totalShipments}</dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>

          <div className="bg-white overflow-hidden shadow rounded-lg">
            <div className="p-5">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <svg className="h-6 w-6 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                  </svg>
                </div>
                <div className="ml-5 w-0 flex-1">
                  <dl>
                    <dt className="text-sm font-medium text-gray-500 truncate">Active Shipments</dt>
                    <dd className="text-lg font-medium text-gray-900">{activeShipments}</dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>

          <div className="bg-white overflow-hidden shadow rounded-lg">
            <div className="p-5">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <svg className="h-6 w-6 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                  </svg>
                </div>
                <div className="ml-5 w-0 flex-1">
                  <dl>
                    <dt className="text-sm font-medium text-gray-500 truncate">Constraint Violations</dt>
                    <dd className="text-lg font-medium text-gray-900">{constraintViolations}</dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Recent Shipments */}
        <div className="mt-8">
          <div className="flex items-center justify-between">
            <h2 className="text-lg font-medium text-gray-900">Recent Shipments</h2>
            <Link
              href="/dashboard/shipments"
              className="text-sm font-medium text-blue-600 hover:text-blue-500"
            >
              View all
            </Link>
          </div>

          <div className="mt-4 bg-white shadow overflow-hidden sm:rounded-md">
            <ul role="list" className="divide-y divide-gray-200">
              {recentShipments.map((shipment) => (
                <li
                  key={shipment.shipment_code}
                  onClick={() => setSelectedShipment(shipment)}
                  className="hover:bg-gray-50 cursor-pointer"
                >
                  <div className="px-4 py-4 sm:px-6">
                    <div className="flex items-center justify-between">
                      <div className="sm:flex">
                        <p className="text-sm font-medium text-blue-600 truncate">
                          {shipment.shipment_code}
                        </p>
                        <p className="mt-1 sm:mt-0 sm:ml-6 text-sm text-gray-500">
                          to {shipment.recipient_name}
                        </p>
                      </div>
                      <div className="ml-2 flex-shrink-0 flex">
                        <span className={`
                          px-2 inline-flex text-xs leading-5 font-semibold rounded-full
                          ${shipment.constraints_violated
                            ? 'bg-red-100 text-red-800'
                            : shipment.status === 'Delivered'
                              ? 'bg-green-100 text-green-800'
                              : 'bg-yellow-100 text-yellow-800'
                          }
                        `}>
                          {shipment.status}
                        </span>
                      </div>
                    </div>
                    <div className="mt-2 sm:flex sm:justify-between">
                      <div className="sm:flex">
                        <p className="flex items-center text-sm text-gray-500">
                          Shipped on {new Date(shipment.shipping_date).toLocaleDateString()}
                        </p>
                      </div>
                      {shipment.constraints_violated && (
                        <div className="mt-2 sm:mt-0">
                          <span className="text-xs text-red-600">
                            ⚠️ Constraint violation detected
                          </span>
                        </div>
                      )}
                    </div>
                  </div>
                </li>
              ))}
            </ul>
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
    </div>
  );
}