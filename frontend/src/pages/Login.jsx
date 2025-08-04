import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Button } from '../components/ui/button';
import { Card } from '../components/ui/card';
import { Eye, EyeOff, Smartphone, Shield, AlertCircle } from 'lucide-react';

const Login = () => {
  const [showPassword, setShowPassword] = useState(false);
  const [formData, setFormData] = useState({
    accountNumber: '',
    password: ''
  });
  const [isLoading, setIsLoading] = useState(false);
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    
    // Simulate login process
    setTimeout(() => {
      setIsLoading(false);
      // Mock login - in real app, validate credentials
      if (formData.accountNumber && formData.password) {
        // Store mock auth state (in real app, use proper auth)
        localStorage.setItem('isAuthenticated', 'true');
        navigate('/dashboard');
      }
    }, 1000);
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-emerald-900 flex items-center justify-center px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        {/* Header */}
        <div className="text-center">
          <Link to="/" className="inline-flex items-center space-x-2 mb-8">
            <div className="bg-emerald-500 rounded-lg p-2">
              <div className="w-8 h-8 bg-white rounded text-emerald-500 flex items-center justify-center font-bold text-xl">
                P
              </div>
            </div>
            <div className="text-2xl font-bold text-white">
              Peoples <span className="text-emerald-400">Bank</span>
            </div>
          </Link>
          <h2 className="text-3xl font-bold text-white mb-2">Welcome Back</h2>
          <p className="text-slate-300">Sign in to your account to continue</p>
        </div>

        {/* Login Form */}
        <Card className="bg-white/10 backdrop-blur-lg border-white/20 p-8">
          <form onSubmit={handleSubmit} className="space-y-6">
            <div>
              <label htmlFor="accountNumber" className="block text-sm font-medium text-white mb-2">
                Account Number
              </label>
              <input
                id="accountNumber"
                name="accountNumber"
                type="text"
                required
                className="w-full px-4 py-3 bg-white/20 border border-white/30 rounded-lg text-white placeholder-slate-300 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent transition-all duration-200"
                placeholder="Enter your account number"
                value={formData.accountNumber}
                onChange={handleInputChange}
              />
            </div>

            <div>
              <label htmlFor="password" className="block text-sm font-medium text-white mb-2">
                Password
              </label>
              <div className="relative">
                <input
                  id="password"
                  name="password"
                  type={showPassword ? 'text' : 'password'}
                  required
                  className="w-full px-4 py-3 bg-white/20 border border-white/30 rounded-lg text-white placeholder-slate-300 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent transition-all duration-200 pr-12"
                  placeholder="Enter your password"
                  value={formData.password}
                  onChange={handleInputChange}
                />
                <button
                  type="button"
                  className="absolute inset-y-0 right-0 flex items-center pr-4"
                  onClick={() => setShowPassword(!showPassword)}
                >
                  {showPassword ? (
                    <EyeOff className="h-5 w-5 text-slate-300" />
                  ) : (
                    <Eye className="h-5 w-5 text-slate-300" />
                  )}
                </button>
              </div>
            </div>

            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <input
                  id="remember-me"
                  name="remember-me"
                  type="checkbox"
                  className="h-4 w-4 text-emerald-500 focus:ring-emerald-500 border-white/30 rounded bg-white/20"
                />
                <label htmlFor="remember-me" className="ml-2 block text-sm text-white">
                  Remember me
                </label>
              </div>
              <Link to="/forgot-password" className="text-sm text-emerald-400 hover:text-emerald-300">
                Forgot password?
              </Link>
            </div>

            <Button
              type="submit"
              disabled={isLoading}
              className="w-full bg-emerald-500 hover:bg-emerald-600 text-white font-medium py-3 px-4 rounded-lg transition-all duration-300 hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:scale-100"
            >
              {isLoading ? 'Signing In...' : 'Sign In'}
            </Button>
          </form>

          {/* Demo Account Info */}
          <div className="mt-6 p-4 bg-blue-500/20 border border-blue-400/30 rounded-lg">
            <div className="flex items-start space-x-3">
              <AlertCircle className="h-5 w-5 text-blue-400 mt-0.5" />
              <div>
                <h4 className="text-sm font-medium text-blue-300">Demo Account</h4>
                <p className="text-xs text-blue-200 mt-1">
                  Use any account number and password to access the demo
                </p>
              </div>
            </div>
          </div>
        </Card>

        {/* Additional Options */}
        <div className="text-center space-y-4">
          <div className="flex items-center justify-center space-x-2 text-slate-300">
            <Shield className="h-4 w-4" />
            <span className="text-sm">Your data is protected with bank-grade security</span>
          </div>
          
          <div className="text-center">
            <p className="text-slate-300">
              Don't have an account?{' '}
              <Link to="/register" className="text-emerald-400 hover:text-emerald-300 font-medium">
                Open Account
              </Link>
            </p>
          </div>

          <div className="pt-4 border-t border-white/20">
            <Button variant="outline" className="w-full border-white/30 text-white hover:bg-white/10">
              <Smartphone className="h-5 w-5 mr-2" />
              Download Mobile App
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Login;