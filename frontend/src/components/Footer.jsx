import React from 'react';
import { Link } from 'react-router-dom';
import { Phone, Mail, MapPin, Facebook, Twitter, Instagram, Linkedin } from 'lucide-react';

const Footer = () => {
  return (
    <footer className="bg-slate-900 text-white">
      {/* Main Footer */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          {/* Brand & About */}
          <div className="space-y-4">
            <div className="flex items-center space-x-3">
              <img 
                src="https://customer-assets.emergentagent.com/job_krotoa-banking/artifacts/1jgqb0uw_logob.jpeg" 
                alt="Peoples Bank Logo"
                className="w-12 h-12 rounded-full bg-white p-1 shadow-md"
              />
              <div className="text-xl font-bold">
                Peoples <span className="text-emerald-400">Bank</span>
              </div>
            </div>
            <p className="text-slate-300 text-sm leading-relaxed">
              South Africa's trusted banking partner, serving communities across the nation with integrity, innovation, and commitment to financial empowerment.
            </p>
            <div className="flex space-x-4">
              <a href="#" className="text-slate-400 hover:text-emerald-400 transition-colors">
                <Facebook className="h-5 w-5" />
              </a>
              <a href="#" className="text-slate-400 hover:text-emerald-400 transition-colors">
                <Twitter className="h-5 w-5" />
              </a>
              <a href="#" className="text-slate-400 hover:text-emerald-400 transition-colors">
                <Instagram className="h-5 w-5" />
              </a>
              <a href="#" className="text-slate-400 hover:text-emerald-400 transition-colors">
                <Linkedin className="h-5 w-5" />
              </a>
            </div>
          </div>

          {/* Quick Links */}
          <div>
            <h3 className="font-semibold text-lg mb-4">Quick Links</h3>
            <ul className="space-y-2">
              {[
                { name: 'Personal Banking', href: '/services' },
                { name: 'Business Banking', href: '/business' },
                { name: 'Online Banking', href: '/login' },
                { name: 'Mobile App', href: '/mobile' },
                { name: 'Interest Rates', href: '/rates' },
                { name: 'Fees & Charges', href: '/fees' }
              ].map((link) => (
                <li key={link.name}>
                  <Link 
                    to={link.href} 
                    className="text-slate-300 hover:text-emerald-400 transition-colors text-sm"
                  >
                    {link.name}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Support */}
          <div>
            <h3 className="font-semibold text-lg mb-4">Support</h3>
            <ul className="space-y-2">
              {[
                { name: 'Help Center', href: '/help' },
                { name: 'Contact Us', href: '/contact' },
                { name: 'Find a Branch', href: '/branches' },
                { name: 'ATM Locator', href: '/atms' },
                { name: 'Security Center', href: '/security' },
                { name: 'Report Fraud', href: '/fraud' }
              ].map((link) => (
                <li key={link.name}>
                  <Link 
                    to={link.href} 
                    className="text-slate-300 hover:text-emerald-400 transition-colors text-sm"
                  >
                    {link.name}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Contact Info */}
          <div>
            <h3 className="font-semibold text-lg mb-4">Get in Touch</h3>
            <div className="space-y-3">
              <div className="flex items-center space-x-3">
                <Phone className="h-5 w-5 text-emerald-400" />
                <div>
                  <div className="text-sm font-medium">24/7 Support</div>
                  <div className="text-sm text-slate-300">0860 PEOPLES</div>
                </div>
              </div>
              <div className="flex items-center space-x-3">
                <Mail className="h-5 w-5 text-emerald-400" />
                <div>
                  <div className="text-sm font-medium">Email Us</div>
                  <div className="text-sm text-slate-300">info@peoplesbank.co.za</div>
                </div>
              </div>
              <div className="flex items-center space-x-3">
                <MapPin className="h-5 w-5 text-emerald-400" />
                <div>
                  <div className="text-sm font-medium">Head Office</div>
                  <div className="text-sm text-slate-300">Cape Town, South Africa</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Bottom Bar */}
      <div className="border-t border-slate-700">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex flex-col md:flex-row justify-between items-center space-y-4 md:space-y-0">
            <div className="text-sm text-slate-400">
              © 2025 Peoples Bank. All rights reserved. Licensed by the South African Reserve Bank.
            </div>
            <div className="flex space-x-6 text-sm">
              <Link to="/privacy" className="text-slate-400 hover:text-emerald-400 transition-colors">
                Privacy Policy
              </Link>
              <Link to="/terms" className="text-slate-400 hover:text-emerald-400 transition-colors">
                Terms of Service
              </Link>
              <Link to="/accessibility" className="text-slate-400 hover:text-emerald-400 transition-colors">
                Accessibility
              </Link>
            </div>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;