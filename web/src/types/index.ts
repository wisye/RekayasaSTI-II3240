export interface Shipment {
  id: string;
  orderCode: string;
  shippingDate: string;
  recipientName: string;
  recipientAddress: string;
  phoneNumber: string;
  additionalInfo?: string;
  products: ShipmentProduct[];
  isDelivered: boolean;
}

export interface ShipmentProduct {
  id: string;
  name: string;
  quantity: number;
  hasConstraintViolation: boolean;
}

export interface Product {
  id: string;
  name: string;
  batchNumber: string;
  expiryDate: string;
  temperature: {
    current: number;
    limit: number;
  };
  humidity: {
    current: number;
    limit: number;
  };
}