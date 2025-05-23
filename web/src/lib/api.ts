import { CreateProductData, CreateShipmentData } from "@/types";

interface RegisterData {
  username: string;
  password: string;
}

interface RegisterRequestData {
  username: string;
  email: string;
  password: string;
  role: 'manufacturer' | 'recipient';
}

interface LoginData {
  username: string;
  password: string;
}

const API_BASE_URL = 'http://127.0.0.1:8000/api';

export async function register(data: RegisterData) {
  const registerData: RegisterRequestData = {
    username: data.username,
    email: `${data.username}@example.com`,
    password: data.password,
    role: 'manufacturer'
  };

  try {
    const response = await fetch(`${API_BASE_URL}/register`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(registerData),
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.detail || 'Registration failed');
    }

    return {
      success: true,
      data,
      message: 'Registration successful! You can now login.'
    };
  } catch (error) {
    console.error('Registration error:', error);
    throw error;
  }
}

export async function login(data: LoginData) {
  const formData = new FormData();
  formData.append('username', data.username);
  formData.append('password', data.password);

  const response = await fetch(`${API_BASE_URL}/login`, {
    method: 'POST',
    body: formData,
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.detail || 'Failed to login');
  }

  return response.json();
}

export async function getProducts() {
  const response = await fetch(`${API_BASE_URL}/products`, {
    headers: {
      'Authorization': `Bearer ${localStorage.getItem('auth_token')}`
    }
  });

  if (!response.ok) {
    throw new Error('Failed to fetch products');
  }

  return response.json();
}

export async function createProduct(data: CreateProductData) {
  const response = await fetch(`${API_BASE_URL}/products`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${localStorage.getItem('auth_token')}`
    },
    body: JSON.stringify(data)
  });

  if (!response.ok) {
    throw new Error('Failed to create product');
  }

  return response.json();
}

export async function getShipments() {
  const response = await fetch(`${API_BASE_URL}/shipments`, {
    headers: {
      'Authorization': `Bearer ${localStorage.getItem('auth_token')}`
    }
  });

  if (!response.ok) {
    throw new Error('Failed to fetch shipments');
  }

  return response.json();
}

export async function createShipment(data: CreateShipmentData) {
  const response = await fetch(`${API_BASE_URL}/shipments`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${localStorage.getItem('auth_token')}`
    },
    body: JSON.stringify(data)
  });

  if (!response.ok) {
    throw new Error('Failed to create shipment');
  }

  return response.json();
}

export async function getRecentShipments() {
  const response = await fetch(`${API_BASE_URL}/shipments/recent`, {
    headers: {
      'Authorization': `Bearer ${localStorage.getItem('auth_token')}`
    }
  });

  if (!response.ok) {
    throw new Error('Failed to fetch recent shipments');
  }

  return response.json();
}