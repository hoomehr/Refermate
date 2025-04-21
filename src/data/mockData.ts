import { Referral, User } from '../types';

// Mock user
export const mockUser: User = {
  id: '1',
  name: 'Alex Johnson',
  email: 'alex@example.com',
};

// Generate a set of mock referrals
export const mockReferrals: Referral[] = [
  {
    id: '1',
    description: 'Software Engineer at a fintech startup. Looking for someone with 2+ years of React experience. Great culture and competitive salary.',
    location: 'San Francisco, CA',
    tags: ['Engineering', 'React', 'Fintech'],
    createdAt: new Date('2023-05-15'),
    userId: '2',
  },
  {
    id: '2',
    description: 'Product Designer position at a health tech company. Need someone with experience in designing mobile applications and a strong portfolio.',
    location: 'Remote',
    tags: ['Design', 'Product', 'UI/UX'],
    createdAt: new Date('2023-06-02'),
    userId: '3',
  },
  {
    id: '3',
    description: 'Data Scientist role focusing on machine learning models. PhD preferred but not required if you have equivalent industry experience.',
    location: 'Boston, MA',
    tags: ['Data Science', 'Machine Learning', 'AI'],
    createdAt: new Date('2023-06-10'),
    userId: '4',
  },
  {
    id: '4',
    description: 'Marketing Manager for a consumer products company. Need experience with digital marketing campaigns and analytics.',
    location: 'Chicago, IL',
    tags: ['Marketing', 'Digital', 'Analytics'],
    createdAt: new Date('2023-06-18'),
    userId: '5',
  },
  {
    id: '5',
    description: 'Senior Frontend Developer at a growing e-commerce platform. 4+ years of experience with modern JavaScript frameworks (React, Vue, Angular).',
    location: 'Austin, TX',
    tags: ['Engineering', 'Frontend', 'JavaScript'],
    createdAt: new Date('2023-06-25'),
    userId: '1',
  },
  {
    id: '6',
    description: 'Project Manager with agile experience needed for a media company. PMP certification is a plus but not required.',
    location: 'New York, NY',
    tags: ['Project Management', 'Agile', 'Media'],
    createdAt: new Date('2023-07-05'),
    userId: '1',
  }
];

// Mock user referrals (referrals created by the current user)
export const mockUserReferrals = mockReferrals.filter(referral => referral.userId === mockUser.id);