'use client';

import { useState } from 'react';
import { ChevronLeftIcon, ChevronRightIcon } from '@heroicons/react/24/outline';
import { Shipment } from '@/types';

interface CalendarProps {
  onSelectDate: (date: Date) => void;
  shipments: Shipment[];
}

export default function Calendar({ onSelectDate, shipments }: CalendarProps) {
  const [currentDate, setCurrentDate] = useState(new Date());

  const getDaysInMonth = (date: Date) => {
    const year = date.getFullYear();
    const month = date.getMonth();
    return new Date(year, month + 1, 0).getDate();
  };

  const getFirstDayOfMonth = (date: Date) => {
    return new Date(date.getFullYear(), date.getMonth(), 1).getDay();
  };

  const handlePrevMonth = () => {
    setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() - 1));
  };

  const handleNextMonth = () => {
    setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() + 1));
  };

  const hasShipmentsOnDate = (date: Date) => {
    return shipments.some(shipment => 
      new Date(shipment.shipping_date).toDateString() === date.toDateString()
    );
  };

  const days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
  const daysInMonth = getDaysInMonth(currentDate);
  const firstDay = getFirstDayOfMonth(currentDate);

  return (
    <div>
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-lg font-medium text-gray-900">
          {currentDate.toLocaleString('default', { month: 'long', year: 'numeric' })}
        </h2>
        <div className="flex space-x-2">
          <button onClick={handlePrevMonth} className="p-1 hover:bg-gray-100 rounded">
            <ChevronLeftIcon className="h-5 w-5" />
          </button>
          <button onClick={handleNextMonth} className="p-1 hover:bg-gray-100 rounded">
            <ChevronRightIcon className="h-5 w-5" />
          </button>
        </div>
      </div>

      <div className="grid grid-cols-7 gap-1">
        {days.map(day => (
          <div key={day} className="text-center text-sm font-medium text-gray-500 py-2">
            {day}
          </div>
        ))}
        
        {Array.from({ length: firstDay }).map((_, index) => (
          <div key={`empty-${index}`} className="text-center py-2" />
        ))}
        
        {Array.from({ length: daysInMonth }).map((_, index) => {
          const date = new Date(currentDate.getFullYear(), currentDate.getMonth(), index + 1);
          const isToday = date.toDateString() === new Date().toDateString();
          const hasShipments = hasShipmentsOnDate(date);
          
          return (
            <button
              key={index}
              onClick={() => onSelectDate(date)}
              className={`
                text-center py-2 rounded-full hover:bg-purple-50
                ${isToday ? 'bg-purple-100 text-purple-600' : ''}
                ${hasShipments ? 'font-bold' : ''}
              `}
            >
              {index + 1}
              {hasShipments && (
                <span className="block h-1 w-1 mx-auto mt-1 rounded-full bg-purple-500" />
              )}
            </button>
          );
        })}
      </div>
    </div>
  );
}