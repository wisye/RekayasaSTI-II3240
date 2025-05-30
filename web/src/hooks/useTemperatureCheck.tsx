import { useState, useEffect } from 'react';
import { getAuthHeader } from '@/lib/api';
import { API_BASE_URL } from '@/lib/api';

interface TemperatureData {
  temperature: number;
  humidity: number;
  constraints_violated: boolean;
  shipment_code: string;
}

export function useTemperatureCheck(shipmentCode: string | undefined, interval = 5000) {
  const [data, setData] = useState<TemperatureData | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!shipmentCode) {
      setError('No shipment code provided');
      return;
    }

    const checkTemperature = async () => {
      try {
        const headers = await getAuthHeader();
        const response = await fetch(`${API_BASE_URL}/temperature/${shipmentCode}`, {
          headers
        });
        
        if (!response.ok) {
          throw new Error('Failed to fetch temperature data');
        }

        const data = await response.json();
        setData(data);
        setError(null);
      } catch (err) {
        setError('Error fetching temperature data');
        console.error('Temperature check error:', err);
      }
    };

    checkTemperature();
    const timer = setInterval(checkTemperature, interval);
    return () => clearInterval(timer);
  }, [shipmentCode, interval]);

  return { data, error };
}