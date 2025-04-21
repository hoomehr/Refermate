import React, { useState } from 'react';
import Input from '../ui/Input';
import Button from '../ui/Button';

interface ReferralRequestFormProps {
  onSubmit: (data: {
    email: string;
    linkedinUrl: string;
    cvUrl: string;
  }) => void;
}

const ReferralRequestForm: React.FC<ReferralRequestFormProps> = ({ onSubmit }) => {
  const [email, setEmail] = useState('');
  const [linkedinUrl, setLinkedinUrl] = useState('');
  const [cvUrl, setCvUrl] = useState('');
  const [errors, setErrors] = useState({
    email: '',
    linkedinUrl: '',
    cvUrl: '',
  });

  const validateForm = () => {
    const newErrors = {
      email: '',
      linkedinUrl: '',
      cvUrl: '',
    };
    let isValid = true;

    if (!email) {
      newErrors.email = 'Email is required';
      isValid = false;
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      newErrors.email = 'Invalid email format';
      isValid = false;
    }

    if (!linkedinUrl) {
      newErrors.linkedinUrl = 'LinkedIn URL is required';
      isValid = false;
    }

    if (!cvUrl) {
      newErrors.cvUrl = 'CV/Resume URL is required';
      isValid = false;
    }

    setErrors(newErrors);
    return isValid;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (validateForm()) {
      onSubmit({ email, linkedinUrl, cvUrl });
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <Input
        label="Email Address"
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        error={errors.email}
        placeholder="your@email.com"
      />

      <Input
        label="LinkedIn Profile URL"
        type="url"
        value={linkedinUrl}
        onChange={(e) => setLinkedinUrl(e.target.value)}
        error={errors.linkedinUrl}
        placeholder="https://linkedin.com/in/..."
      />

      <Input
        label="CV/Resume URL"
        type="url"
        value={cvUrl}
        onChange={(e) => setCvUrl(e.target.value)}
        error={errors.cvUrl}
        placeholder="https://..."
      />

      <Button type="submit" className="w-full">
        Submit Request
      </Button>
    </form>
  );
};

export default ReferralRequestForm;