import React, { useState, useRef } from 'react';
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
  const [isDetailsModalOpen, setIsDetailsModalOpen] = useState(false);
  const cardRef = useRef<HTMLDivElement>(null);

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
      <Card 
        className="h-full relative cursor-pointer transition-all duration-200 hover:shadow-md"
        ref={cardRef}
        onMouseEnter={() => setIsDetailsModalOpen(true)}
        onMouseLeave={() => setIsDetailsModalOpen(false)}
      >
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
            {referral.tags.map((tag, index) => {
              // Generate a pastel color based on the tag name
              const tagHash = tag.split('').reduce((acc, char) => acc + char.charCodeAt(0), 0);
              const hue = tagHash % 360;
              
              return (
                <span 
                  key={index} 
                  className="inline-block text-xs px-2 py-1 rounded-md"
                  style={{ 
                    backgroundColor: `hsla(${hue}, 70%, 90%, 0.8)`,
                    color: `hsla(${hue}, 70%, 30%, 1)`
                  }}
                >
                  {tag}
                </span>
              );
            })}
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

      <Modal
        isOpen={isDetailsModalOpen}
        onClose={() => setIsDetailsModalOpen(false)}
        title="Referral Details"
      >
        <div className="space-y-4">
          <h3 className="font-semibold text-lg">{referral.description}</h3>
          
          <div className="flex items-center text-gray-700">
            <MapPin size={18} className="flex-shrink-0 mr-2" />
            <span>{referral.location}</span>
          </div>
          
          <div className="flex flex-wrap gap-2 mt-3">
            {referral.tags.map((tag, index) => {
              const tagHash = tag.split('').reduce((acc, char) => acc + char.charCodeAt(0), 0);
              const hue = tagHash % 360;
              
              return (
                <span 
                  key={index} 
                  className="inline-block text-xs px-2 py-1 rounded-md"
                  style={{ 
                    backgroundColor: `hsla(${hue}, 70%, 90%, 0.8)`,
                    color: `hsla(${hue}, 70%, 30%, 1)`
                  }}
                >
                  {tag}
                </span>
              );
            })}
          </div>
          
          <div className="mt-4">
            <p className="text-sm text-gray-500">Posted on {formattedDate}</p>
          </div>
          
          <div className="mt-6">
            <button
              onClick={() => {
                setIsDetailsModalOpen(false);
                setIsModalOpen(true);
              }}
              disabled={hasRequested}
              className={`px-4 py-2 rounded-md text-white bg-primary hover:bg-primary-hover transition-colors ${
                hasRequested ? 'opacity-50 cursor-not-allowed' : ''
              }`}
            >
              {hasRequested ? 'Request Sent' : 'Request Referral'}
            </button>
          </div>
        </div>
      </Modal>
    </>
  );
};

export default ReferralCard;
