import React, { useState } from 'react';
import { MapPin, Mail, Linkedin, FileText } from 'lucide-react';
import Card, { CardContent, CardFooter } from '../ui/Card';
import Modal from '../ui/Modal';
import ReferralRequestForm from './ReferralRequestForm';
import { Referral } from '../../types';

interface ReferralCardProps {
  referral: Referral;
  onRequestReferral: (referralId: string, data: {
    email: string;
    linkedinUrl: string;
    cvUrl: string;
  }) => void;
  hasRequested: boolean;
}

const ReferralCard: React.FC<ReferralCardProps> = ({ 
  referral,
  onRequestReferral,
  hasRequested
}) => {
  const [isModalOpen, setIsModalOpen] = useState(false);

  const formattedDate = new Date(referral.createdAt).toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  });

  const workTypeDisplay = referral.workType 
    ? referral.workType.charAt(0).toUpperCase() + referral.workType.slice(1)
    : 'Not specified';

  const handleRequestSubmit = (data: {
    email: string;
    linkedinUrl: string;
    cvUrl: string;
  }) => {
    onRequestReferral(referral.id, data);
    setIsModalOpen(false);
  };

  return (
    <>
      <Card className="h-full">
        <CardContent>
          <div className="mb-3">
            <h3 className="font-semibold text-gray-900 line-clamp-2 mb-2">
              {referral.description.split(' ').slice(0, 8).join(' ')}
              {referral.description.split(' ').length > 8 ? '...' : ''}
            </h3>
            <div className="inline-flex items-center px-2 py-1 rounded-md bg-gray-100 text-gray-700 text-sm">
              {workTypeDisplay}
            </div>
          </div>
          
          <p className="text-gray-700 mb-4 line-clamp-3">{referral.description}</p>
          
          <div className="flex items-center text-gray-500 mb-4">
            <MapPin size={16} className="flex-shrink-0" />
            <span className="ml-1 text-sm">{referral.location}</span>
          </div>
          
          <div className="flex flex-wrap gap-2">
            {referral.tags.map((tag, index) => (
              <span 
                key={index} 
                className="inline-block bg-gray-100 text-gray-800 text-xs px-2 py-1 rounded-md"
              >
                {tag}
              </span>
            ))}
          </div>
        </CardContent>
        
        <CardFooter className="flex justify-between items-center">
          <span className="text-xs text-gray-500">{formattedDate}</span>
          <button
            onClick={() => setIsModalOpen(true)}
            disabled={hasRequested}
            className={`text-sm font-medium transition-colors ${
              hasRequested
                ? 'text-gray-400 cursor-not-allowed'
                : 'text-primary hover:text-primary-hover'
            }`}
          >
            {hasRequested ? 'Request Sent' : 'Request Referral'}
          </button>
        </CardFooter>
      </Card>

      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title="Request Referral"
      >
        <ReferralRequestForm onSubmit={handleRequestSubmit} />
      </Modal>
    </>
  );
};

export default ReferralCard;