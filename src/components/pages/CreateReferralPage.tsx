import React from 'react';
import { ArrowLeft } from 'lucide-react';
import ReferralForm from '../referrals/ReferralForm';
import Button from '../ui/Button';
import { Referral } from '../../types';

interface CreateReferralPageProps {
  onCreateReferral: (data: { description: string; location: string; tags: string[] }) => void;
  onNavigate: (path: string) => void;
}

const CreateReferralPage: React.FC<CreateReferralPageProps> = ({ 
  onCreateReferral,
  onNavigate
}) => {
  const handleSubmit = (data: { description: string; location: string; tags: string[] }) => {
    onCreateReferral(data);
    onNavigate('/');
  };

  return (
    <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <Button 
        variant="ghost" 
        onClick={() => onNavigate('/')}
        className="mb-6 -ml-2"
      >
        <ArrowLeft size={18} className="mr-1" />
        Back
      </Button>
      
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Create a Referral</h1>
        <p className="text-gray-600 mt-1">Share an opportunity and help someone advance their career</p>
      </div>
      
      <ReferralForm onSubmit={handleSubmit} />
    </div>
  );
};

export default CreateReferralPage;