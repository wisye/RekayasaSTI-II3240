'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { register } from '@/lib/api';

export default function Register() {
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    const formData = new FormData(e.currentTarget);
    
    try {
      await register({
        username: formData.get('username') as string,
        password: formData.get('password') as string,
      });
      router.push('/auth/login');
    } catch (err) {
      setError('Failed to register');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex">
      {/* Left Side - Register Form */}
      <div className="w-full md:w-1/2 p-8 flex flex-col justify-center items-center bg-gray-900">
        <div className="w-full max-w-md space-y-8">
          <h2 className="text-3xl font-bold text-center text-white mb-10">
            Register
          </h2>

          {error && (
            <div className="bg-red-900 border border-red-600 rounded p-3">
              <p className="text-red-200 text-center">{error}</p>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-6">
            <div>
              <div className="relative">
                <span className="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                  <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                    <path fillRule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clipRule="evenodd" />
                  </svg>
                </span>
                <input
                  type="text"
                  name="username"
                  required
                  className="w-full pl-10 pr-3 py-2 bg-gray-800 border border-gray-600 rounded-full text-white placeholder-gray-400 focus:outline-none focus:border-purple-500"
                  placeholder="Username"
                />
              </div>
            </div>

            <div>
              <div className="relative">
                <span className="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                  <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                    <path fillRule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clipRule="evenodd" />
                  </svg>
                </span>
                <input
                  type="password"
                  name="password"
                  required
                  className="w-full pl-10 pr-3 py-2 bg-gray-800 border border-gray-600 rounded-full text-white placeholder-gray-400 focus:outline-none focus:border-purple-500"
                  placeholder="Password"
                />
              </div>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full py-2 px-4 bg-gradient-to-r from-purple-500 to-pink-500 text-white rounded-full hover:opacity-90 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500 disabled:opacity-50"
            >
              {loading ? 'Registering...' : 'Register'}
            </button>
          </form>
        </div>
      </div>

      {/* Right Side - Purple Background */}
      <div className="hidden md:flex md:w-1/2 bg-purple-500 text-white p-12 flex-col justify-center items-center rounded-l-[80px]">
        <h1 className="text-4xl font-bold mb-4">Welcome Back!</h1>
        <p className="text-lg mb-8">Already have an account?</p>
        <Link 
          href="/auth/login"
          className="px-8 py-3 border-2 border-white rounded-full text-white hover:bg-white hover:text-purple-500 transition-colors"
        >
          Login
        </Link>
      </div>
    </div>
  );
}