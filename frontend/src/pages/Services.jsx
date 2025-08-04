import React from 'react';
import { Card } from '../components/ui/card';
import { Button } from '../components/ui/button';
import { Badge } from '../components/ui/badge';
import { 
  CreditCard, 
  PiggyBank, 
  Home as HomeIcon, 
  Banknote,
  CheckCircle,
  ArrowRight,
  Calculator,
  Shield,
  Clock,
  Users,
  Briefcase,
  GraduationCap,
  Car
} from 'lucide-react';
import { bankingServices } from '../data/mock';

const Services = () => {
  const iconMap = {
    CreditCard,
    PiggyBank, 
    Home: HomeIcon,
    Banknote
  };

  const additionalServices = [
    {
      id: "service_005",
      title: "Business Banking",
      description: "Comprehensive banking solutions for businesses of all sizes",
      icon: Briefcase,
      features: ["Business accounts", "Merchant services", "Payroll solutions", "Business loans"],
      highlight: "New"
    },
    {
      id: "service_006",
      title: "Student Accounts",
      description: "Special banking packages designed for students",
      icon: GraduationCap,
      features: ["No monthly fees", "Free transactions", "Study loans", "Digital banking"],
      highlight: "Popular"
    },
    {
      id: "service_007",
      title: "Vehicle Finance",
      description: "Drive your dream car with our competitive vehicle finance",
      icon: Car,
      features: ["New & used cars", "Competitive rates", "Quick approval", "Flexible terms"],
      highlight: null
    },
    {
      id: "service_008",
      title: "Investment Services",
      description: "Grow your wealth with our investment and savings products",
      icon: Calculator,
      features: ["Unit trusts", "Fixed deposits", "Tax-free savings", "Financial planning"],
      highlight: null
    }
  ];

  const allServices = [...bankingServices, ...additionalServices];

  const benefits = [
    {
      icon: Shield,
      title: "Bank-Grade Security",
      description: "All your transactions and data are protected with the highest security standards"
    },
    {
      icon: Clock,
      title: "24/7 Support",
      description: "Round-the-clock customer support whenever you need assistance"
    },
    {
      icon: Users,
      title: "Personal Service",
      description: "Dedicated relationship managers for personalized banking experience"
    }
  ];

  return (
    <div className="min-h-screen bg-slate-50">
      {/* Hero Section */}
      <section className="bg-gradient-to-br from-slate-900 via-slate-800 to-emerald-900 text-white py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-4xl mx-auto">
            <h1 className="text-4xl lg:text-5xl font-bold mb-6">
              Banking Services for <span className="text-emerald-400">Every Need</span>
            </h1>
            <p className="text-xl text-slate-300 leading-relaxed mb-8">
              From personal banking to business solutions, we offer comprehensive financial services 
              designed to help you achieve your goals and secure your financial future.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Button className="bg-emerald-500 hover:bg-emerald-600 text-white text-lg px-8 py-4">
                Explore Services
                <ArrowRight className="ml-2 h-5 w-5" />
              </Button>
              <Button variant="outline" className="border-white text-white hover:bg-white hover:text-slate-900 text-lg px-8 py-4">
                Speak to an Advisor
              </Button>
            </div>
          </div>
        </div>
      </section>

      {/* Services Grid */}
      <section className="py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl lg:text-4xl font-bold text-slate-900 mb-4">
              Our Complete Service Portfolio
            </h2>
            <p className="text-xl text-slate-600 max-w-3xl mx-auto">
              Whether you're just starting your financial journey or planning for retirement, 
              we have the right services to support you every step of the way.
            </p>
          </div>

          <div className="grid md:grid-cols-2 gap-8 mb-16">
            {allServices.map((service) => {
              const IconComponent = iconMap[service.icon] || service.icon;
              return (
                <Card key={service.id} className="p-8 hover:shadow-xl transition-all duration-300 group border-0 shadow-lg relative overflow-hidden">
                  {service.highlight && (
                    <Badge 
                      className={`absolute top-4 right-4 ${
                        service.highlight === 'New' 
                          ? 'bg-emerald-500 text-white' 
                          : 'bg-blue-500 text-white'
                      }`}
                    >
                      {service.highlight}
                    </Badge>
                  )}
                  
                  <div className="flex items-start space-x-6">
                    <div className="bg-emerald-100 p-4 rounded-xl group-hover:bg-emerald-200 transition-colors shrink-0">
                      <IconComponent className="h-8 w-8 text-emerald-600" />
                    </div>
                    <div className="flex-1">
                      <h3 className="text-2xl font-semibold text-slate-900 mb-3">{service.title}</h3>
                      <p className="text-slate-600 mb-6 leading-relaxed">{service.description}</p>
                      
                      <div className="space-y-3 mb-6">
                        {service.features.map((feature, idx) => (
                          <div key={idx} className="flex items-center space-x-3">
                            <CheckCircle className="h-5 w-5 text-emerald-500 shrink-0" />
                            <span className="text-slate-700">{feature}</span>
                          </div>
                        ))}
                      </div>
                      
                      <div className="flex flex-col sm:flex-row gap-3">
                        <Button className="bg-emerald-600 hover:bg-emerald-700 text-white">
                          Apply Now
                        </Button>
                        <Button variant="outline" className="border-slate-300 text-slate-700 hover:bg-slate-50">
                          Learn More
                        </Button>
                      </div>
                    </div>
                  </div>
                </Card>
              );
            })}
          </div>
        </div>
      </section>

      {/* Benefits Section */}
      <section className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl lg:text-4xl font-bold text-slate-900 mb-4">
              Why Choose Peoples Bank?
            </h2>
            <p className="text-xl text-slate-600">
              Experience the difference of personalized banking with trusted expertise
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            {benefits.map((benefit, index) => (
              <Card key={index} className="p-8 text-center hover:shadow-lg transition-all duration-300 border-0 shadow-md">
                <div className="bg-emerald-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-6">
                  <benefit.icon className="h-8 w-8 text-emerald-600" />
                </div>
                <h3 className="text-xl font-semibold text-slate-900 mb-4">{benefit.title}</h3>
                <p className="text-slate-600 leading-relaxed">{benefit.description}</p>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-emerald-600 text-white">
        <div className="max-w-4xl mx-auto text-center px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl lg:text-4xl font-bold mb-6">
            Ready to Get Started?
          </h2>
          <p className="text-xl text-emerald-100 mb-8 leading-relaxed">
            Let our banking experts help you choose the right services for your needs. 
            Schedule a consultation today or apply online in minutes.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Button className="bg-white text-emerald-600 hover:bg-slate-100 text-lg px-8 py-4">
              Schedule Consultation
              <ArrowRight className="ml-2 h-5 w-5" />
            </Button>
            <Button variant="outline" className="border-white text-white hover:bg-white hover:text-emerald-600 text-lg px-8 py-4">
              Apply Online
            </Button>
          </div>
        </div>
      </section>
    </div>
  );
};

export default Services;