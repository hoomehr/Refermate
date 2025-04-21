import React, { useState } from 'react';
import { X, Plus } from 'lucide-react';

interface TagInputProps {
  label?: string;
  value: string[];
  onChange: (tags: string[]) => void;
  placeholder?: string;
  className?: string;
  error?: string;
  suggestedTags?: string[];
}

const TagInput: React.FC<TagInputProps> = ({
  label,
  value,
  onChange,
  placeholder = 'Add a tag...',
  className = '',
  error,
  suggestedTags = [],
}) => {
  const [inputValue, setInputValue] = useState('');
  const [showSuggestions, setShowSuggestions] = useState(false);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setInputValue(e.target.value);
    setShowSuggestions(true);
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter' && inputValue.trim() !== '') {
      e.preventDefault();
      addTag(inputValue.trim());
    }
  };

  const addTag = (tag: string) => {
    if (!value.includes(tag)) {
      onChange([...value, tag]);
    }
    setInputValue('');
    setShowSuggestions(false);
  };

  const removeTag = (tagToRemove: string) => {
    onChange(value.filter(tag => tag !== tagToRemove));
  };

  const filteredSuggestions = suggestedTags
    .filter(tag => 
      !value.includes(tag) && 
      tag.toLowerCase().includes(inputValue.toLowerCase())
    );

  return (
    <div className={`mb-4 ${className}`}>
      {label && (
        <label className="block text-sm font-medium text-gray-700 mb-1">
          {label}
        </label>
      )}
      <div
        className={`flex flex-wrap gap-2 p-2 border rounded-lg bg-white min-h-[42px] focus-within:ring-2 focus-within:ring-primary focus-within:border-primary relative ${
          error ? 'border-red-500' : 'border-gray-300'
        }`}
      >
        {value.map((tag, index) => (
          <div
            key={index}
            className="flex items-center bg-gray-100 text-gray-800 rounded-md px-2 py-1 text-sm"
          >
            {tag}
            <button
              type="button"
              className="ml-1 text-gray-600 hover:text-gray-800"
              onClick={() => removeTag(tag)}
            >
              <X size={14} />
            </button>
          </div>
        ))}
        <div className="relative flex-1">
          <input
            type="text"
            value={inputValue}
            onChange={handleInputChange}
            onKeyDown={handleKeyDown}
            onFocus={() => setShowSuggestions(true)}
            placeholder={value.length === 0 ? placeholder : ''}
            className="outline-none bg-transparent text-sm min-w-[120px] py-1 w-full"
          />
          {showSuggestions && filteredSuggestions.length > 0 && (
            <div className="absolute top-full left-0 right-0 mt-1 bg-white border border-gray-200 rounded-lg shadow-lg z-10 max-h-48 overflow-y-auto">
              {filteredSuggestions.map((tag, index) => (
                <button
                  key={index}
                  type="button"
                  className="w-full text-left px-3 py-2 text-sm hover:bg-gray-50 flex items-center"
                  onClick={() => addTag(tag)}
                >
                  <Plus size={14} className="mr-2" />
                  {tag}
                </button>
              ))}
            </div>
          )}
        </div>
      </div>
      {error && <p className="mt-1 text-sm text-red-500">{error}</p>}
      <p className="mt-1 text-xs text-gray-500">Press Enter to add a tag</p>
    </div>
  );
};

export default TagInput