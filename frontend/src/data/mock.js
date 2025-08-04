// Mock data for Peoples Bank South Africa

export const mockUser = {
  id: "user_001",
  name: "Thandiwe Mthembu",
  email: "thandiwe.mthembu@email.co.za",
  phone: "+27 82 123 4567",
  accountNumber: "62134567890",
  profileImage: "https://images.unsplash.com/photo-1494790108755-2616b612b47c?w=150&h=150&fit=crop&crop=face"
};

export const mockAccounts = [
  {
    id: "acc_001",
    name: "Savings Account",
    type: "savings",
    balance: 15750.50,
    currency: "ZAR",
    accountNumber: "62134567890",
    isActive: true
  },
  {
    id: "acc_002", 
    name: "Current Account",
    type: "current",
    balance: 3420.75,
    currency: "ZAR",
    accountNumber: "62134567891",
    isActive: true
  },
  {
    id: "acc_003",
    name: "Credit Card",
    type: "credit",
    balance: -2150.00,
    creditLimit: 15000,
    currency: "ZAR",
    accountNumber: "4532 1234 5678 9012",
    isActive: true
  }
];

export const mockTransactions = [
  {
    id: "txn_001",
    date: "2025-01-15",
    description: "Woolworths Cape Town",
    amount: -450.50,
    type: "debit",
    category: "Groceries",
    accountId: "acc_002"
  },
  {
    id: "txn_002", 
    date: "2025-01-14",
    description: "Salary Deposit - ABC Corp",
    amount: 12500.00,
    type: "credit",
    category: "Income",
    accountId: "acc_001"
  },
  {
    id: "txn_003",
    date: "2025-01-13",
    description: "Uber South Africa",
    amount: -85.00,
    type: "debit",
    category: "Transport",
    accountId: "acc_002"
  },
  {
    id: "txn_004",
    date: "2025-01-12",
    description: "Netflix",
    amount: -159.00,
    type: "debit", 
    category: "Entertainment",
    accountId: "acc_002"
  },
  {
    id: "txn_005",
    date: "2025-01-11",
    description: "Transfer from Savings",
    amount: 2000.00,
    type: "credit",
    category: "Transfer",
    accountId: "acc_002"
  }
];

export const krotoachatbotResponses = {
  greeting: [
    "Gâi tsēs! I'm Krotoa, your friendly banking assistant. How can I help you today?",
    "Gâi tsēs! I'm Krotoa, here to assist with your banking needs. What would you like to know?",
    "Sanibonani! I'm Krotoa, ready to help you with your Peoples Bank account. How can I assist you?",
    "Hello and gâi tsēs! Welcome to Peoples Bank. I'm Krotoa, your personal banking assistant."
  ],
  balance: [
    `Your current account balance is R${mockAccounts[1].balance.toFixed(2)} and your savings balance is R${mockAccounts[0].balance.toFixed(2)}. Looking good!`,
    "I can see your accounts are doing well! Your current balance across all accounts looks healthy. Anything specific you'd like to know?"
  ],
  transactions: [
    "Your recent transactions include purchases at Woolworths, Uber rides, and your salary deposit. Would you like me to show you more details?",
    "I can see your latest transactions. You've been quite active with everyday purchases and your salary came through recently. Need any details?"
  ],
  help: [
    "Gâi tsēs! I can help you with: checking balances, reviewing transactions, finding branches, customer support, and general banking questions. What interests you?",
    "I'm here to assist with your banking needs! I can check balances, explain transactions, locate branches, or connect you with customer support. How can I help?"
  ],
  branches: [
    "Peoples Bank has branches across South Africa! Our main branches are in Cape Town, Johannesburg, Durban, and Pretoria. Would you like specific branch details or directions?",
    "We have over 200 branches nationwide, plus ATMs at major shopping centers. Where are you located so I can find the nearest one for you?"
  ],
  support: [
    "For additional support, you can call us at 0860 PEOPLES (0860 736 7537) or visit any branch. Our call center is available 24/7 with friendly staff ready to help!",
    "Our customer support team is available 24/7 at 0860 PEOPLES. You can also visit our branches or continue chatting with me for quick questions. I'm here to help!"
  ],
  default: [
    "Gâi tsēs! I'm not sure about that specific question, but I'd love to help! Try asking about your balance, recent transactions, or finding a branch.",
    "That's a great question! I specialize in banking queries like balances, transactions, and branch locations. What banking topic can I help you with?",
    "I'm still learning, but I can definitely help with banking basics! Ask me about your accounts, transactions, or how to contact our support team."
  ]
};

export const bankingServices = [
  {
    id: "service_001",
    title: "Current Accounts",
    description: "Manage your everyday banking with our flexible current accounts",
    icon: "CreditCard",
    features: ["No monthly fees", "Free ATM withdrawals", "Online banking", "Mobile app"]
  },
  {
    id: "service_002", 
    title: "Savings Accounts",
    description: "Grow your money with competitive interest rates",
    icon: "PiggyBank",
    features: ["High interest rates", "No minimum balance", "Goal tracking", "Auto-save options"]
  },
  {
    id: "service_003",
    title: "Home Loans",
    description: "Make your dream home a reality with affordable home loans",
    icon: "Home",
    features: ["Competitive rates", "Quick approval", "Flexible terms", "First-time buyer support"]
  },
  {
    id: "service_004",
    title: "Personal Loans",
    description: "Personal loans for all your needs",
    icon: "Banknote",
    features: ["Quick approval", "Flexible repayment", "No hidden fees", "Online application"]
  }
];

export const branches = [
  {
    id: "branch_001",
    name: "Cape Town CBD",
    address: "123 Long Street, Cape Town, 8001",
    phone: "+27 21 123 4567",
    hours: "Mon-Fri: 8:00-16:30, Sat: 8:00-12:00",
    services: ["Full Banking", "Foreign Exchange", "Safe Deposit"]
  },
  {
    id: "branch_002",
    name: "Johannesburg Sandton",
    address: "456 Rivonia Road, Sandton, 2196", 
    phone: "+27 11 234 5678",
    hours: "Mon-Fri: 8:00-16:30, Sat: 8:00-12:00",
    services: ["Full Banking", "Business Banking", "Investment Services"]
  },
  {
    id: "branch_003",
    name: "Durban CBD",
    address: "789 Smith Street, Durban, 4001",
    phone: "+27 31 345 6789", 
    hours: "Mon-Fri: 8:00-16:30, Sat: 8:00-12:00",
    services: ["Full Banking", "Foreign Exchange", "Loans"]
  }
];