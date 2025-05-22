export interface ShipmentItem {
  product_id: number;
  product_name: string;
  quantity: number;
  constraints_violated: boolean;
}

export interface Shipment {
  shipment_code: string;
  shipping_date: string;
  delivery_date: string | null;
  recipient_name: string;
  recipient_address: string;
  recipient_phone: string;
  status: string;
  constraints_violated: boolean;
  items: ShipmentItem[];
  additional_info?: string;
}

export interface CreateShipmentItem {
  product_code: string;
  quantity: number;
}

export interface CreateShipmentData {
  shipping_date: string;
  recipient_name: string;
  recipient_address: string;
  recipient_phone: string;
  items: CreateShipmentItem[];
  additional_info?: string;
}

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

export interface CreateProductData {
  name: string;
  description: string;
  max_temperature: number;
  min_temperature: number;
  max_humidity: number;
  min_humidity: number;
}