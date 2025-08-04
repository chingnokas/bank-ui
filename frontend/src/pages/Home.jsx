import React from 'react';
import { Link } from 'react-router-dom';
import { Button } from '../components/ui/button';
import { Card } from '../components/ui/card';
import { Badge } from '../components/ui/badge';
import { 
  CreditCard, 
  PiggyBank, 
  Home as HomeIcon, 
  Banknote,
  Shield,
  Clock,
  Users,
  CheckCircle,
  ArrowRight,
  Smartphone,
  Globe,
  Award
} from 'lucide-react';
import { bankingServices } from '../data/mock';

const Home = () => {
  const iconMap = {
    CreditCard,
    PiggyBank, 
    Home: HomeIcon,
    Banknote
  };

  const features = [
    {
      icon: Shield,
      title: "Bank-Grade Security",
      description: "Your money and data are protected with industry-leading security measures"
    },
    {
      icon: Clock,
      title: "24/7 Banking",
      description: "Access your accounts anytime, anywhere with our digital banking platforms"
    },
    {
      icon: Users,
      title: "Personal Service",
      description: "Dedicated relationship managers and personalized banking solutions"
    },
    {
      icon: Smartphone,
      title: "Mobile First",
      description: "Award-winning mobile app with all banking features at your fingertips"
    }
  ];

  const stats = [
    { label: "Customers Served", value: "500K+" },
    { label: "Branches Nationwide", value: "200+" },
    { label: "Years of Excellence", value: "25+" },
    { label: "Customer Satisfaction", value: "98%" }
  ];

  return (
    <div className="min-h-screen bg-slate-50">
      {/* Hero Section */}
      <section className="relative bg-gradient-to-br from-slate-900 via-slate-800 to-emerald-900 text-white overflow-hidden">
        <div className="absolute inset-0 bg-[url('data:image/svg+xml,%3Csvg width="60" height="60" viewBox="0 0 60 60" xmlns="http://www.w3.org/2000/svg"%3E%3Cg fill="none" fill-rule="evenodd"%3E%3Cg fill="%23ffffff" fill-opacity="0.05"%3E%3Ccircle cx="30" cy="30" r="2"/%3E%3C/g%3E%3C/g%3E%3C/svg%3E')] opacity-20"></div>
        
        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 lg:py-28">
          <div className="grid lg:grid-cols-2 gap-12 items-center">
            <div className="space-y-8">
              <div className="space-y-4">
                <Badge className="bg-emerald-500/20 text-emerald-300 border-emerald-500/30">
                  <Award className="h-4 w-4 mr-1" />
                  Trusted by 500K+ South Africans
                </Badge>
                <h1 className="text-4xl lg:text-6xl font-bold leading-tight">
                  The bank that does{' '}
                  <span className="text-emerald-400">it all</span>
                </h1>
                <p className="text-xl text-slate-300 leading-relaxed">
                  Banking built for South Africans, by South Africans. Experience personalized service, competitive rates, and innovative digital solutions that grow with your dreams.
                </p>
              </div>

              <div className="flex flex-col sm:flex-row gap-4">
                <Link to="/register">
                  <Button className="bg-emerald-500 hover:bg-emerald-600 text-white text-lg px-8 py-4 rounded-lg transition-all duration-300 hover:scale-105 shadow-lg hover:shadow-emerald-500/25">
                    Open Account
                    <ArrowRight className="ml-2 h-5 w-5" />
                  </Button>
                </Link>
                <Link to="/login">
                  <Button variant="outline" className="border-slate-600 text-white hover:bg-slate-800 text-lg px-8 py-4 rounded-lg transition-all duration-300">
                    Login to Banking
                  </Button>
                </Link>
              </div>

              {/* Quick Features */}
              <div className="grid grid-cols-2 gap-6 pt-8">
                {[
                  { icon: Shield, text: "No monthly fees" },
                  { icon: Clock, text: "Instant transfers" },
                  { icon: Globe, text: "Global ATM access" },
                  { icon: Smartphone, text: "Award-winning app" }
                ].map((feature, index) => (
                  <div key={index} className="flex items-center space-x-3">
                    <div className="bg-emerald-500/20 p-2 rounded-lg">
                      <feature.icon className="h-5 w-5 text-emerald-400" />
                    </div>
                    <span className="text-slate-300">{feature.text}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Stats Card */}
            <div className="lg:flex lg:justify-end">
              <Card className="bg-white/10 backdrop-blur-lg border-white/20 p-8 space-y-6">
                <div className="text-center">
                  <h3 className="text-2xl font-bold text-white mb-2">Why Choose Peoples Bank?</h3>
                  <p className="text-slate-300">Trusted by South Africans nationwide</p>
                </div>
                
                <div className="grid grid-cols-2 gap-6">
                  {stats.map((stat, index) => (
                    <div key={index} className="text-center">
                      <div className="text-3xl font-bold text-emerald-400">{stat.value}</div>
                      <div className="text-sm text-slate-300">{stat.label}</div>
                    </div>
                  ))}
                </div>
              </Card>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl lg:text-4xl font-bold text-slate-900 mb-4">
              Modern Banking Made Simple
            </h2>
            <p className="text-xl text-slate-600 max-w-3xl mx-auto">
              Experience the future of banking with our comprehensive suite of services designed for your lifestyle
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            {features.map((feature, index) => (
              <Card key={index} className="p-6 text-center hover:shadow-lg transition-all duration-300 hover:scale-105 border-0 shadow-md">
                <div className="bg-emerald-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                  <feature.icon className="h-8 w-8 text-emerald-600" />
                </div>
                <h3 className="text-xl font-semibold text-slate-900 mb-2">{feature.title}</h3>
                <p className="text-slate-600">{feature.description}</p>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* Services Section */}
      <section className="py-20 bg-slate-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl lg:text-4xl font-bold text-slate-900 mb-4">
              Banking Services for Every Need
            </h2>
            <p className="text-xl text-slate-600">
              From everyday banking to major life milestones, we've got you covered
            </p>
          </div>

          <div className="grid md:grid-cols-2 gap-8">
            {bankingServices.map((service) => {
              const IconComponent = iconMap[service.icon];
              return (
                <Card key={service.id} className="p-8 hover:shadow-xl transition-all duration-300 group border-0 shadow-md">
                  <div className="flex items-start space-x-6">
                    <div className="bg-emerald-100 p-4 rounded-xl group-hover:bg-emerald-200 transition-colors">
                      <IconComponent className="h-8 w-8 text-emerald-600" />
                    </div>
                    <div className="flex-1">
                      <h3 className="text-2xl font-semibold text-slate-900 mb-3">{service.title}</h3>
                      <p className="text-slate-600 mb-4">{service.description}</p>
                      <ul className="space-y-2">
                        {service.features.map((feature, idx) => (
                          <li key={idx} className="flex items-center space-x-3">
                            <CheckCircle className="h-5 w-5 text-emerald-500" />
                            <span className="text-slate-700">{feature}</span>
                          </li>
                        ))}
                      </ul>
                      <Link to="/services" className="inline-flex items-center mt-6 text-emerald-600 hover:text-emerald-700 font-medium">
                        Learn More <ArrowRight className="ml-2 h-4 w-4" />
                      </Link>
                    </div>
                  </div>
                </Card>
              );
            })}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-emerald-600 text-white">
        <div className="max-w-4xl mx-auto text-center px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl lg:text-4xl font-bold mb-4">
            Ready to Experience Better Banking?
          </h2>
          <p className="text-xl text-emerald-100 mb-8 leading-relaxed">
            Join over 500,000 South Africans who trust Peoples Bank for their financial journey. 
            Open your account today and discover what personalized banking feels like.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link to="/register">
              <Button className="bg-white text-emerald-600 hover:bg-slate-100 text-lg px-8 py-4 rounded-lg transition-all duration-300 hover:scale-105 shadow-lg">
                Open Account Today
                <ArrowRight className="ml-2 h-5 w-5" />
              </Button>
            </Link>
            <Link to="/contact">
              <Button variant="outline" className="border-white text-white hover:bg-white hover:text-emerald-600 text-lg px-8 py-4 rounded-lg transition-all duration-300">
                Speak to an Advisor
              </Button>
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
};

export default Home;