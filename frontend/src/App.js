import React from "react";
import "./App.css";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import Header from "./components/Header";
import Footer from "./components/Footer";
import ChatBot from "./components/ChatBot";
import Home from "./pages/Home";
import Dashboard from "./pages/Dashboard";
import Login from "./pages/Login";
import Services from "./pages/Services";
import Branches from "./pages/Branches";

function App() {
  return (
    <div className="App">
      <BrowserRouter>
        <Header />
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/login" element={<Login />} />
          <Route path="/services" element={<Services />} />
          <Route path="/branches" element={<Branches />} />
          <Route path="/register" element={<Login />} />
          <Route path="/accounts" element={<Dashboard />} />
          <Route path="/contact" element={<Branches />} />
        </Routes>
        <Footer />
        <ChatBot />
      </BrowserRouter>
    </div>
  );
}

export default App;