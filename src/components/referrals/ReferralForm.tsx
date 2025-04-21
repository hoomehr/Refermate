import React, { useState } from 'react';
import { Save } from 'lucide-react';
import Input from '../ui/Input';
import Textarea from '../ui/Textarea';
import TagInput from '../ui/TagInput';
import Button from '../ui/Button';
import { SUGGESTED_TAGS, WORK_TYPES } from '../../types';

interface ReferralFormProps {
  onSubmit: (data: {
    description: string;
    location: string;
    tags: string[];
    workType: 'remote' | 'onsite' | 'hybrid';
    contactInfo: {
      email: string;
      linkedinUrl?: string;
      cvUrl?: string;
    };
  }) => void;
}

const ReferralForm: React.FC<ReferralFormProps> = ({ onSubmit }) => {
  const [description, setDescription] = useState('');
  const [location, setLocation] = useState('');
  const [tags, setTags] = useState<string[]>([]);
  const [workType, setWorkType] = useState<'remote' | 'onsite' | 'hybrid'>('onsite');
  const [email, setEmail] = useState('');
  const [linkedinUrl, setLinkedinUrl] = useState('');
  const [cvUrl, setCvUrl] = useState('');
  const [errors, setErrors] = useState({
    description: '',
    location: '',
    tags: '',
    email: '',
  });

  const validateForm = () => {
    let isValid = true;
    const newErrors = {
      description: '',
      location: '',
      tags: '',
      email: '',
    };

    if (!description.trim()) {
      newErrors.description = 'Description is required';
      isValid = false;
    }

    if (!location.trim()) {
      newErrors.location = 'Location is required';
      isValid = false;
    }

    if (tags.length === 0) {
      newErrors.tags = 'At least one tag is required';
      isValid = false;
    }

    if (!email.trim()) {
      newErrors.email = 'Email is required';
      isValid = false;
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      newErrors.email = 'Invalid email format';
      isValid = false;
    }

    setErrors(newErrors);
    return isValid;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (validateForm()) {
      onSubmit({
        description,
        location,
        tags,
        workType,
        contactInfo: {
          email,
          linkedinUrl: linkedinUrl || undefined,
          cvUrl: cvUrl || undefined,
        },
      });
      
      // Reset form
      setDescription('');
      setLocation('');
      setTags([]);
      setEmail('');
      setLinkedinUrl('');
      setCvUrl('');
    }
  };

  return (
    <form onSubmit={handleSubmit} className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
      <div className="space-y-6">
        <Textarea
          label="Description"
          placeholder="Describe the referral opportunity in detail..."
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          error={errors.description}
        />
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <Input
            label="Location"
            placeholder="City, State, Country"
            value={location}
            onChange={(e) => setLocation(e.target.value)}
            error={errors.location}
          />
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Work Type
            </label>
            <select
              value={workType}
              onChange={(e) => setWorkType(e.target.value as 'remote' | 'onsite' | 'hybrid')}
              className="w-full px-3 py-2 bg-white border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary transition-colors"
            >
              {WORK_TYPES.map(type => (
                <option key={type.value} value={type.value}>
                  {type.label}
                </option>
              ))}
            </select>
          </div>
        </div>

        <TagInput
          label="Tags"
          placeholder="Select or type to add tags..."
          value={tags}
          onChange={setTags}
          error={errors.tags}
          suggestedTags={SUGGESTED_TAGS}
        />

        <div className="space-y-4">
          <h3 className="text-lg font-semibold text-gray-900">Contact Information</h3>
          
          <Input
            label="Email Address"
            type="email"
            placeholder="your@email.com"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            error={errors.email}
          />
          
          <Input
            label="LinkedIn Profile URL (Optional)"
            type="url"
            placeholder="https://linkedin.com/in/..."
            value={linkedinUrl}
            onChange={(e) => setLinkedinUrl(e.target.value)}
          />
          
          <Input
            label="CV/Resume URL (Optional)"
            type="url"
            placeholder="https://..."
            value={cvUrl}
            onChange={(e) => setCvUrl(e.target.value)}
          />
        </div>
        
        <Button type="submit" className="w-full sm:w-auto">
          <Save size={18} className="mr-2" />
          Save Referral
        </Button>
      </div>
    </form>
  );
};

export default ReferralForm