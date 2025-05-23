'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/contexts/AuthContext';

export default function Home() {
  const router = useRouter();
  const { isAuthenticated } = useAuth();
  const [activeTab, setActiveTab] = useState('shipments');

  useEffect(() => {
    if (!isAuthenticated) {
      router.push('/auth/login');
    }
  }, [isAuthenticated, router]);

  if (!isAuthenticated) {
    return null;
  }

  return (
    <main className="container mx-auto p-4">
      <h1 className="text-2xl font-bold mb-4">Medicine Tracking System</h1>
      
      <div className="flex gap-4 mb-4">
        <button 
          className={`px-4 py-2 rounded ${activeTab === 'shipments' ? 'bg-blue-500 text-white' : 'bg-gray-200'}`}
          onClick={() => setActiveTab('shipments')}
        >
          Shipments
        </button>
        <button 
          className={`px-4 py-2 rounded ${activeTab === 'products' ? 'bg-blue-500 text-white' : 'bg-gray-200'}`}
          onClick={() => setActiveTab('products')}
        >
          Products
        </button>
      </div>

      {/* Content will be added here in next iterations */}
      <div className="p-4 border rounded">
        <p className="text-gray-500">
          {activeTab === 'shipments' ? 'Shipments content will be added here' : 'Products content will be added here'}
        </p>
      </div>
    </main>
  );
}