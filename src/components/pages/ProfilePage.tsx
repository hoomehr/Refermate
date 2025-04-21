import React from 'react';
import { ArrowLeft, Plus } from 'lucide-react';
import Button from '../ui/Button';
import ReferralList from '../referrals/ReferralList';
import { Referral, User } from '../../types';

interface ProfilePageProps {
  user: User;
  userReferrals: Referral[];
  onNavigate: (path: string) => void;
}

const ProfilePage: React.FC<ProfilePageProps> = ({ 
  user, 
  userReferrals,
  onNavigate
}) => {
  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <Button 
        variant="ghost" 
        onClick={() => onNavigate('/')}
        className="mb-6 -ml-2"
      >
        <ArrowLeft size={18} className="mr-1" />
        Back
      </Button>
      
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6 mb-8">
        <div className="flex flex-col sm:flex-row items-start sm:items-center gap-4">
          <div className="bg-blue-100 text-blue-800 rounded-full h-16 w-16 flex items-center justify-center text-xl font-bold">
            {user.name.charAt(0)}
          </div>
          
          <div className="flex-1">
            <h1 className="text-2xl font-bold text-gray-900">{user.name}</h1>
            <p className="text-gray-600">{user.email}</p>
          </div>
          
          <Button
            onClick={() => onNavigate('/create')}
            className="sm:self-start"
          >
            <Plus size={18} className="mr-2" />
            Create Referral
          </Button>
        </div>
      </div>
      
      <div className="mb-6">
        <h2 className="text-xl font-semibold text-gray-900 mb-4">Your Referrals</h2>
        <ReferralList 
          referrals={userReferrals} 
          emptyMessage="You haven't created any referrals yet. Click 'Create Referral' to get started."
        />
      </div>
    </div>
  );
};

export default ProfilePage;