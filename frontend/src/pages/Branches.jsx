import React, { useState } from 'react';
import { Card } from '../components/ui/card';
import { Button } from '../components/ui/button';
import { Badge } from '../components/ui/badge';
import { 
  MapPin, 
  Phone, 
  Clock, 
  Search,
  Navigation,
  Star,
  CheckCircle,
  Users,
  CreditCard,
  Globe
} from 'lucide-react';
import { branches } from '../data/mock';

const Branches = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedProvince, setSelectedProvince] = useState('all');

  const provinces = [
    { value: 'all', label: 'All Provinces' },
    { value: 'western-cape', label: 'Western Cape' },
    { value: 'gauteng', label: 'Gauteng' },
    { value: 'kwazulu-natal', label: 'KwaZulu-Natal' },
    { value: 'eastern-cape', label: 'Eastern Cape' },
    { value: 'free-state', label: 'Free State' },
    { value: 'limpopo', label: 'Limpopo' },
    { value: 'mpumalanga', label: 'Mpumalanga' },
    { value: 'north-west', label: 'North West' },
    { value: 'northern-cape', label: 'Northern Cape' }
  ];

  const serviceIcons = {
    'Full Banking': CreditCard,
    'Foreign Exchange': Globe,
    'Safe Deposit': CheckCircle,
    'Business Banking': Users,
    'Investment Services': Star,
    'Loans': CheckCircle
  };

  const filteredBranches = branches.filter(branch => {
    const matchesSearch = branch.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         branch.address.toLowerCase().includes(searchTerm.toLowerCase());
    // In a real app, you'd filter by actual province data
    return matchesSearch;
  });

  const stats = [
    { label: 'Branches Nationwide', value: '200+' },
    { label: 'ATMs Available', value: '500+' },
    { label: 'Cities Served', value: '50+' },
    { label: 'Customer Satisfaction', value: '98%' }
  ];

  return (
    <div className="min-h-screen bg-slate-50">
      {/* Hero Section */}
      <section className="bg-gradient-to-br from-slate-900 via-slate-800 to-emerald-900 text-white py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-4xl mx-auto mb-12">
            <h1 className="text-4xl lg:text-5xl font-bold mb-6">
              Find Your <span className="text-emerald-400">Nearest Branch</span>
            </h1>
            <p className="text-xl text-slate-300 leading-relaxed mb-8">
              With over 200 branches across South Africa, we're never far from where you need us. 
              Visit us for personalized service and expert financial advice.
            </p>
          </div>

          {/* Stats */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
            {stats.map((stat, index) => (
              <div key={index} className="text-center">
                <div className="text-3xl font-bold text-emerald-400 mb-2">{stat.value}</div>
                <div className="text-slate-300">{stat.label}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Search & Filters */}
      <section className="py-8 bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex flex-col md:flex-row gap-4">
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-slate-400" />
              <input
                type="text"
                placeholder="Search by branch name or city..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 pr-4 py-3 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              />
            </div>
            <div className="md:w-64">
              <select
                value={selectedProvince}
                onChange={(e) => setSelectedProvince(e.target.value)}
                className="w-full px-4 py-3 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              >
                {provinces.map((province) => (
                  <option key={province.value} value={province.value}>
                    {province.label}
                  </option>
                ))}
              </select>
            </div>
            <Button className="bg-emerald-500 hover:bg-emerald-600 px-8">
              <Navigation className="h-5 w-5 mr-2" />
              Use My Location
            </Button>
          </div>
        </div>
      </section>

      {/* Branches List */}
      <section className="py-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="mb-8">
            <h2 className="text-2xl font-bold text-slate-900 mb-2">
              {filteredBranches.length} Branches Found
            </h2>
            <p className="text-slate-600">
              All branches offer full banking services with extended hours
            </p>
          </div>

          <div className="grid lg:grid-cols-2 gap-6">
            {filteredBranches.map((branch) => (
              <Card key={branch.id} className="p-6 hover:shadow-lg transition-all duration-300 border-0 shadow-md">
                <div className="flex justify-between items-start mb-4">
                  <div>
                    <h3 className="text-xl font-semibold text-slate-900 mb-1">
                      {branch.name}
                    </h3>
                    <div className="flex items-center space-x-2 text-slate-600">
                      <MapPin className="h-4 w-4" />
                      <span className="text-sm">{branch.address}</span>
                    </div>
                  </div>
                  <Badge className="bg-emerald-100 text-emerald-700 border-0">
                    <Star className="h-3 w-3 mr-1 fill-current" />
                    4.8
                  </Badge>
                </div>

                {/* Contact Info */}
                <div className="space-y-3 mb-6">
                  <div className="flex items-center space-x-3">
                    <Phone className="h-5 w-5 text-emerald-500" />
                    <span className="text-slate-700">{branch.phone}</span>
                  </div>
                  <div className="flex items-center space-x-3">
                    <Clock className="h-5 w-5 text-emerald-500" />
                    <span className="text-slate-700">{branch.hours}</span>
                  </div>
                </div>

                {/* Services */}
                <div className="mb-6">
                  <h4 className="font-medium text-slate-900 mb-3">Available Services</h4>
                  <div className="flex flex-wrap gap-2">
                    {branch.services.map((service, idx) => {
                      const IconComponent = serviceIcons[service] || CheckCircle;
                      return (
                        <Badge key={idx} variant="outline" className="border-emerald-200 text-emerald-700">
                          <IconComponent className="h-3 w-3 mr-1" />
                          {service}
                        </Badge>
                      );
                    })}
                  </div>
                </div>

                {/* Actions */}
                <div className="flex flex-col sm:flex-row gap-3">
                  <Button className="bg-emerald-600 hover:bg-emerald-700 text-white flex-1">
                    <Navigation className="h-4 w-4 mr-2" />
                    Get Directions
                  </Button>
                  <Button variant="outline" className="border-slate-300 text-slate-700 hover:bg-slate-50 flex-1">
                    <Phone className="h-4 w-4 mr-2" />
                    Call Branch
                  </Button>
                </div>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* Map Placeholder & Additional Info */}
      <section className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid lg:grid-cols-2 gap-12 items-center">
            <div>
              <h2 className="text-3xl font-bold text-slate-900 mb-6">
                Banking Made Accessible
              </h2>
              <p className="text-lg text-slate-600 mb-8 leading-relaxed">
                Our extensive network ensures you're never far from personalized banking services. 
                Whether you need to open an account, apply for a loan, or get financial advice, 
                our friendly staff is ready to help.
              </p>
              
              <div className="space-y-4">
                {[
                  'Free parking available at all branches',
                  'Wheelchair accessible facilities',
                  'Multilingual staff support',
                  'Extended Saturday hours',
                  'Private consultation rooms',
                  'Kids play area in select branches'
                ].map((feature, index) => (
                  <div key={index} className="flex items-center space-x-3">
                    <CheckCircle className="h-5 w-5 text-emerald-500" />
                    <span className="text-slate-700">{feature}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Map Placeholder */}
            <div className="bg-slate-100 rounded-lg h-96 flex items-center justify-center">
              <div className="text-center">
                <MapPin className="h-12 w-12 text-slate-400 mx-auto mb-4" />
                <h3 className="text-lg font-medium text-slate-600 mb-2">Interactive Map</h3>
                <p className="text-slate-500">
                  Full interactive map with all branch locations coming soon
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
};

export default Branches;