import React, { useState } from 'react';
import { Card } from '../components/ui/card';
import { Button } from '../components/ui/button';
import { Badge } from '../components/ui/badge';
import { 
  Eye, 
  EyeOff, 
  ArrowUpRight, 
  ArrowDownLeft, 
  Plus,
  Send,
  Download,
  CreditCard,
  PiggyBank,
  TrendingUp,
  Calendar,
  Filter
} from 'lucide-react';
import { mockUser, mockAccounts, mockTransactions } from '../data/mock';

const Dashboard = () => {
  const [balanceVisible, setBalanceVisible] = useState(true);
  const [selectedAccount, setSelectedAccount] = useState('all');

  const totalBalance = mockAccounts.reduce((sum, account) => {
    return account.type === 'credit' ? sum : sum + account.balance;
  }, 0);

  const filteredTransactions = selectedAccount === 'all' 
    ? mockTransactions 
    : mockTransactions.filter(t => t.accountId === selectedAccount);

  const formatCurrency = (amount) => {
    return new Intl.NumberFormat('en-ZA', {
      style: 'currency',
      currency: 'ZAR'
    }).format(Math.abs(amount));
  };

  const getAccountIcon = (type) => {
    switch (type) {
      case 'savings': return PiggyBank;
      case 'current': return CreditCard;
      case 'credit': return CreditCard;
      default: return CreditCard;
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 py-8">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="mb-8">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h1 className="text-3xl font-bold text-slate-900">
                Welcome back, {mockUser.name.split(' ')[0]}!
              </h1>
              <p className="text-slate-600 mt-1">Here's an overview of your accounts</p>
            </div>
            <div className="flex items-center space-x-3">
              <img
                src={mockUser.profileImage}
                alt="Profile"
                className="w-12 h-12 rounded-full"
              />
              <div className="hidden md:block">
                <div className="text-sm font-medium text-slate-900">{mockUser.name}</div>
                <div className="text-xs text-slate-600">{mockUser.email}</div>
              </div>
            </div>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
          {[
            { icon: Send, label: 'Transfer', color: 'bg-blue-500' },
            { icon: Plus, label: 'Deposit', color: 'bg-emerald-500' },
            { icon: Download, label: 'Withdraw', color: 'bg-orange-500' },
            { icon: CreditCard, label: 'Pay Bill', color: 'bg-purple-500' }
          ].map((action, index) => (
            <Button
              key={index}
              variant="outline"
              className="h-20 flex flex-col space-y-2 hover:shadow-md transition-all duration-300"
            >
              <div className={`p-2 rounded-lg ${action.color}`}>
                <action.icon className="h-5 w-5 text-white" />
              </div>
              <span className="text-sm font-medium">{action.label}</span>
            </Button>
          ))}
        </div>

        <div className="grid lg:grid-cols-3 gap-8">
          {/* Left Column */}
          <div className="lg:col-span-2 space-y-6">
            {/* Total Balance Card */}
            <Card className="p-6 bg-gradient-to-br from-slate-900 to-slate-800 text-white">
              <div className="flex items-center justify-between mb-4">
                <div>
                  <h3 className="text-sm font-medium text-slate-300">Total Balance</h3>
                  <div className="flex items-center space-x-3 mt-2">
                    {balanceVisible ? (
                      <h2 className="text-3xl font-bold">{formatCurrency(totalBalance)}</h2>
                    ) : (
                      <h2 className="text-3xl font-bold">••••••••</h2>
                    )}
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => setBalanceVisible(!balanceVisible)}
                      className="text-slate-300 hover:text-white hover:bg-slate-700"
                    >
                      {balanceVisible ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                    </Button>
                  </div>
                </div>
                <div className="bg-emerald-500 p-3 rounded-full">
                  <TrendingUp className="h-6 w-6" />
                </div>
              </div>
              <div className="flex items-center text-sm text-emerald-300">
                <ArrowUpRight className="h-4 w-4 mr-1" />
                <span>+2.5% from last month</span>
              </div>
            </Card>

            {/* Account Cards */}
            <div className="space-y-4">
              <h3 className="text-xl font-semibold text-slate-900">Your Accounts</h3>
              {mockAccounts.map((account) => {
                const IconComponent = getAccountIcon(account.type);
                return (
                  <Card key={account.id} className="p-6 hover:shadow-md transition-all duration-300">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center space-x-4">
                        <div className="bg-emerald-100 p-3 rounded-full">
                          <IconComponent className="h-6 w-6 text-emerald-600" />
                        </div>
                        <div>
                          <h4 className="font-semibold text-slate-900">{account.name}</h4>
                          <p className="text-sm text-slate-600">{account.accountNumber}</p>
                        </div>
                      </div>
                      <div className="text-right">
                        <div className={`text-xl font-bold ${account.type === 'credit' ? 'text-red-600' : 'text-slate-900'}`}>
                          {account.type === 'credit' && account.balance < 0 ? '-' : ''}
                          {formatCurrency(account.balance)}
                        </div>
                        {account.type === 'credit' && (
                          <div className="text-sm text-slate-600">
                            Limit: {formatCurrency(account.creditLimit)}
                          </div>
                        )}
                        <Badge variant={account.isActive ? 'default' : 'secondary'} className="mt-1">
                          {account.isActive ? 'Active' : 'Inactive'}
                        </Badge>
                      </div>
                    </div>
                  </Card>
                );
              })}
            </div>
          </div>

          {/* Right Column - Recent Transactions */}
          <div className="space-y-6">
            <Card className="p-6">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-semibold text-slate-900">Recent Transactions</h3>
                <div className="flex items-center space-x-2">
                  <Button variant="outline" size="sm">
                    <Filter className="h-4 w-4" />
                  </Button>
                  <Button variant="outline" size="sm">
                    <Calendar className="h-4 w-4" />
                  </Button>
                </div>
              </div>

              {/* Account Filter */}
              <div className="mb-4">
                <select
                  value={selectedAccount}
                  onChange={(e) => setSelectedAccount(e.target.value)}
                  className="w-full p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent text-sm"
                >
                  <option value="all">All Accounts</option>
                  {mockAccounts.map((account) => (
                    <option key={account.id} value={account.id}>
                      {account.name}
                    </option>
                  ))}
                </select>
              </div>

              <div className="space-y-4">
                {filteredTransactions.slice(0, 8).map((transaction) => (
                  <div key={transaction.id} className="flex items-center justify-between py-3 border-b border-gray-100 last:border-b-0">
                    <div className="flex items-center space-x-3">
                      <div className={`p-2 rounded-full ${
                        transaction.type === 'credit' ? 'bg-emerald-100' : 'bg-red-100'
                      }`}>
                        {transaction.type === 'credit' 
                          ? <ArrowDownLeft className="h-4 w-4 text-emerald-600" />
                          : <ArrowUpRight className="h-4 w-4 text-red-600" />
                        }
                      </div>
                      <div>
                        <div className="font-medium text-slate-900 text-sm">
                          {transaction.description}
                        </div>
                        <div className="text-xs text-slate-500">
                          {new Date(transaction.date).toLocaleDateString('en-ZA')}
                        </div>
                      </div>
                    </div>
                    <div className="text-right">
                      <div className={`font-semibold text-sm ${
                        transaction.type === 'credit' ? 'text-emerald-600' : 'text-red-600'
                      }`}>
                        {transaction.type === 'credit' ? '+' : '-'}
                        {formatCurrency(transaction.amount)}
                      </div>
                      <Badge variant="outline" className="text-xs">
                        {transaction.category}
                      </Badge>
                    </div>
                  </div>
                ))}
              </div>

              <Button variant="outline" className="w-full mt-4">
                View All Transactions
              </Button>
            </Card>

            {/* Quick Stats */}
            <Card className="p-6">
              <h3 className="text-lg font-semibold text-slate-900 mb-4">This Month</h3>
              <div className="space-y-4">
                <div className="flex justify-between items-center">
                  <span className="text-slate-600">Income</span>
                  <span className="font-semibold text-emerald-600">+{formatCurrency(12500)}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-slate-600">Expenses</span>
                  <span className="font-semibold text-red-600">-{formatCurrency(694.50)}</span>
                </div>
                <div className="border-t pt-4">
                  <div className="flex justify-between items-center">
                    <span className="font-semibold text-slate-900">Net Income</span>
                    <span className="font-bold text-emerald-600">+{formatCurrency(11805.50)}</span>
                  </div>
                </div>
              </div>
            </Card>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;