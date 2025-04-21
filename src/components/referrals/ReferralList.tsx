import React from 'react';
import ReferralCard from './ReferralCard';
import { Referral } from '../../types';

interface ReferralListProps {
  referrals: Referral[];
  emptyMessage?: string;
  onRequestReferral?: (referralId: string, data: {
    email: string;
    linkedinUrl: string;
    cvUrl: string;
  }) => void;
  requestedReferrals?: Set<string>;
}

const ReferralList: React.FC<ReferralListProps> = ({ 
  referrals, 
  emptyMessage = "No referrals found. Try adjusting your filters.",
  onRequestReferral,
  requestedReferrals = new Set(),
}) => {
  if (referrals.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-12 px-4 text-center">
        <svg
          className="w-16 h-16 text-gray-300 mb-4"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth="2"
            d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"
          />
        </svg>
        <p className="text-gray-500">{emptyMessage}</p>
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
      {referrals.map((referral) => (
        <ReferralCard
          key={referral.id}
          referral={referral}
          onRequestReferral={onRequestReferral || (() => {})}
          hasRequested={requestedReferrals.has(referral.id)}
        />
      ))}
    </div>
  );
};

export default ReferralList;