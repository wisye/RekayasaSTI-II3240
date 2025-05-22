export interface Product {
  id: number;
  name: string;
  description: string;
  max_temperature: number;
  min_temperature: number;
  max_humidity: number;
  min_humidity: number;
  product_code: string;
  manufacturer_id: number;
  created_at: string;
}

export interface Shipment {
  id: string;
  orderCode: string;
  shippingDate: string;
  recipientName: string;
  recipientAddress: string;
  phoneNumber: string;
  additionalInfo?: string;
  products: {
    id: string;
    name: string;
    quantity: number;
    hasConstraintViolation: boolean;
  }[];
  isDelivered: boolean;
}

export const dummyProducts: Product[] = [
  {
    id: 1,
    name: "Paracetamol",
    description: "Pain reliever and fever reducer",
    max_temperature: 25,
    min_temperature: 15,
    max_humidity: 60,
    min_humidity: 30,
    product_code: "PARA001",
    manufacturer_id: 1,
    created_at: "2025-05-22T10:00:00Z"
  },
  {
    id: 2,
    name: "Amoxicillin",
    description: "Antibiotic medication",
    max_temperature: 22,
    min_temperature: 18,
    max_humidity: 55,
    min_humidity: 35,
    product_code: "AMOX001",
    manufacturer_id: 1,
    created_at: "2025-05-22T11:00:00Z"
  }
];

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
  },
  {
    id: "SHP002",
    orderCode: "ORD124",
    shippingDate: "2025-05-21",
    recipientName: "Community Clinic",
    recipientAddress: "456 Health Avenue, Wellness District",
    phoneNumber: "098-765-4321",
    products: [
      {
        id: "MED001",
        name: "Paracetamol",
        quantity: 200,
        hasConstraintViolation: false
      }
    ],
    isDelivered: true
  }
];