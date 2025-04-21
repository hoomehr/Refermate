export interface Referral {
  id: string;
  description: string;
  location: string;
  tags: string[];
  createdAt: Date;
  userId: string;
  workType: 'remote' | 'onsite' | 'hybrid';
  contactInfo: {
    email: string;
    linkedinUrl?: string;
    cvUrl?: string;
  };
}

export interface User {
  id: string;
  name: string;
  email: string;
  avatar?: string;
}

export const SUGGESTED_TAGS = [
  'Software Engineering',
  'Frontend',
  'Backend',
  'Full Stack',
  'DevOps',
  'Product Management',
  'UI/UX Design',
  'Data Science',
  'Machine Learning',
  'Marketing',
  'Sales',
  'Customer Success',
  'HR',
  'Finance',
  'Operations',
  'Project Management'
];

export const WORK_TYPES = [
  { value: 'remote', label: 'Remote' },
  { value: 'onsite', label: 'On-site' },
  { value: 'hybrid', label: 'Hybrid' }
] as const;