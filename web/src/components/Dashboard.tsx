import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { 
  Squares2X2Icon, 
  DocumentTextIcon,
  ArrowRightOnRectangleIcon
} from '@heroicons/react/24/outline';
import Image from 'next/image';
import { useAuth } from '@/contexts/AuthContext';

const navigation = [
  { name: 'DASHBOARD', href: '/dashboard', icon: Squares2X2Icon },
  { name: 'LAPORAN', href: '/dashboard/reports', icon: DocumentTextIcon },
];

export default function Sidebar() {
  const pathname = usePathname();
  const { logout } = useAuth();

  return (
    <div className="fixed top-0 left-0 h-full w-64 bg-purple-100">
      <div className="flex flex-col h-full">
        {/* Logo */}
        <div className="flex items-center p-8">
          <div className="flex items-center space-x-2">
            <div className="text-purple-500 text-2xl font-semibold">
              MediQ
            </div>
          </div>
        </div>

        {/* Navigation */}
        <nav className="flex-1 px-4 space-y-2">
          {navigation.map((item) => {
            const isActive = pathname === item.href;
            return (
              <Link
                key={item.name}
                href={item.href}
                className={`
                  flex items-center px-4 py-3 text-sm font-medium rounded-lg
                  ${isActive 
                    ? 'bg-purple-200 text-purple-700' 
                    : 'text-purple-700 hover:bg-purple-200'
                  }
                `}
              >
                <item.icon className={`
                  mr-3 h-5 w-5
                  ${isActive ? 'text-purple-700' : 'text-purple-600'}
                `} />
                {item.name}
              </Link>
            );
          })}
        </nav>

        {/* Logout Button */}
        <div className="p-4">
          <button
            onClick={logout}
            className="flex items-center w-full px-4 py-3 text-sm font-medium text-purple-700 hover:bg-purple-200 rounded-lg"
          >
            <ArrowRightOnRectangleIcon className="mr-3 h-5 w-5" />
            LOGOUT
          </button>
        </div>
      </div>
    </div>
  );
}