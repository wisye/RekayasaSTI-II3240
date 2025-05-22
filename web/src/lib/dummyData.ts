import { Shipment, Product } from '@/types';

export const dummyShipments: Shipment[] = [
  {
    id: "SHP001",
    orderCode: "ORD123",
    shippingDate: "2025-05-22",
    recipientName: "City Hospital",
    recipientAddress: "123 Medical Street, Healthcare City",
    phoneNumber: "123-456-7890",
    additionalInfo: "Handle with care, temperature sensitive",
    products: [
      {
        id: "MED001",
        name: "Paracetamol",
        quantity: 100,
        hasConstraintViolation: false
      },
      {
        id: "MED002",
        name: "Amoxicillin",
        quantity: 50,
        hasConstraintViolation: true
      }
    ],
    isDelivered: false
  }
];

export const dummyProducts: Product[] = [
  {
    id: "MED001",
    name: "Paracetamol",
    batchNumber: "BATCH001",
    expiryDate: "2026-12-31",
    temperature: {
      current: 23,
      limit: 25
    },
    humidity: {
      current: 45,
      limit: 60
    }
  }
];