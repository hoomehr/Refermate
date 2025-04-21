import React, { useState } from 'react';
import Navbar from './components/layout/Navbar';
import HomePage from './components/pages/HomePage';
import CreateReferralPage from './components/pages/CreateReferralPage';
import ProfilePage from './components/pages/ProfilePage';
import { mockReferrals, mockUser, mockUserReferrals } from './data/mockData';
import { Referral } from './types';

function App() {
  const [referrals, setReferrals] = useState<Referral[]>(mockReferrals);
  const [userReferrals, setUserReferrals] = useState<Referral[]>(mockUserReferrals);
  const [currentPath, setCurrentPath] = useState('/');
  const [requestedReferrals, setRequestedReferrals] = useState<Set<string>>(new Set());

  const handleCreateReferral = (data: {
    description: string;
    location: string;
    tags: string[];
    workType: 'remote' | 'onsite' | 'hybrid';
    contactInfo: {
      email: string;
      linkedinUrl?: string;
      cvUrl?: string;
    };
  }) => {
    const newReferral: Referral = {
      id: Date.now().toString(),
      description: data.description,
      location: data.location,
      tags: data.tags,
      workType: data.workType,
      createdAt: new Date(),
      userId: mockUser.id,
      contactInfo: data.contactInfo,
    };
    
    setReferrals([newReferral, ...referrals]);
    setUserReferrals([newReferral, ...userReferrals]);
  };

  const handleRequestReferral = (referralId: string, data: {
    email: string;
    linkedinUrl: string;
    cvUrl: string;
  }) => {
    setRequestedReferrals(prev => new Set([...prev, referralId]));
    // Here you would typically send this data to your backend
    console.log('Referral requested:', { referralId, ...data });
  };

  const renderPage = () => {
    switch (currentPath) {
      case '/create':
        return (
          <CreateReferralPage
            onCreateReferral={handleCreateReferral}
            onNavigate={setCurrentPath}
          />
        );
      case '/profile':
        return (
          <ProfilePage
            user={mockUser}
            userReferrals={userReferrals}
            onNavigate={setCurrentPath}
          />
        );
      default:
        return (
          <HomePage
            referrals={referrals}
            onNavigate={setCurrentPath}
            onRequestReferral={handleRequestReferral}
            requestedReferrals={requestedReferrals}
          />
        );
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col">
      <Navbar onNavigate={setCurrentPath} currentPath={currentPath} />
      <main className="flex-1">
        {renderPage()}
      </main>
    </div>
  );
}

export default App;