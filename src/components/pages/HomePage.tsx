import React, { useState } from 'react';
import { UserPlus, Users } from 'lucide-react';
import Button from '../ui/Button';
import ReferralList from '../referrals/ReferralList';
import { Referral, WORK_TYPES } from '../../types';

interface HomePageProps {
  referrals: Referral[];
  onNavigate: (path: string) => void;
  onRequestReferral: (referralId: string, data: {
    email: string;
    linkedinUrl: string;
    cvUrl: string;
  }) => void;
  requestedReferrals: Set<string>;
}

const HomePage: React.FC<HomePageProps> = ({
  referrals,
  onNavigate,
  onRequestReferral,
  requestedReferrals,
}) => {
  const [activeTab, setActiveTab] = useState<'need' | 'can'>('need');
  const [selectedTags, setSelectedTags] = useState<string[]>([]);
  const [selectedWorkType, setSelectedWorkType] = useState<string>('all');
  
  const allTags = Array.from(
    new Set(referrals.flatMap(referral => referral.tags))
  );
  
  const filteredReferrals = referrals.filter(referral => {
    const matchesTags = selectedTags.length === 0 || 
      referral.tags.some(tag => selectedTags.includes(tag));
    
    const matchesWorkType = selectedWorkType === 'all' || 
      referral.workType === selectedWorkType;
    
    return matchesTags && matchesWorkType;
  });

  const toggleTag = (tag: string) => {
    setSelectedTags(prev => 
      prev.includes(tag)
        ? prev.filter(t => t !== tag)
        : [...prev, tag]
    );
  };

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div className="flex flex-col md:flex-row md:items-center md:justify-between mb-8 gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Find Your Next Opportunity</h1>
          <p className="text-gray-600 mt-1">Connect with professionals offering referrals</p>
        </div>
        
        <div className="flex space-x-4">
          <Button 
            variant={activeTab === 'need' ? 'primary' : 'outline'}
            onClick={() => setActiveTab('need')}
            className="flex-1 md:flex-none transition-all"
          >
            <Users size={18} className="mr-2" />
            I Need Referral
          </Button>
          
          <Button 
            variant={activeTab === 'can' ? 'primary' : 'outline'}
            onClick={() => onNavigate('/create')}
            className="flex-1 md:flex-none transition-all"
          >
            <UserPlus size={18} className="mr-2" />
            I Can Refer
          </Button>
        </div>
      </div>
      
      <div className="mb-6 space-y-4">
        {/* Work type filter */}
        <div>
          <h2 className="text-sm font-medium text-gray-700 mb-2">Filter by work type:</h2>
          <div className="flex flex-wrap gap-2">
            <button
              onClick={() => setSelectedWorkType('all')}
              className={`px-3 py-1 rounded-full text-sm font-medium transition-colors ${
                selectedWorkType === 'all'
                  ? 'bg-gray-900 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              All
            </button>
            {WORK_TYPES.map(type => (
              <button
                key={type.value}
                onClick={() => setSelectedWorkType(type.value)}
                className={`px-3 py-1 rounded-full text-sm font-medium transition-colors ${
                  selectedWorkType === type.value
                    ? 'bg-gray-900 text-white'
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
              >
                {type.label}
              </button>
            ))}
          </div>
        </div>

        {/* Tags filter */}
        {allTags.length > 0 && (
          <div>
            <h2 className="text-sm font-medium text-gray-700 mb-2">Filter by tags:</h2>
            <div className="flex flex-wrap gap-2">
              {allTags.map(tag => (
                <button
                  key={tag}
                  onClick={() => toggleTag(tag)}
                  className={`px-3 py-1 rounded-full text-sm font-medium transition-colors ${
                    selectedTags.includes(tag)
                      ? 'bg-gray-900 text-white'
                      : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                  }`}
                >
                  {tag}
                </button>
              ))}
            </div>
          </div>
        )}
      </div>
      
      <ReferralList 
        referrals={filteredReferrals}
        onRequestReferral={onRequestReferral}
        requestedReferrals={requestedReferrals}
        emptyMessage="No referrals available yet. Be the first to create one!"
      />
    </div>
  );
};

export default HomePage;