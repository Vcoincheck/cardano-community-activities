import React, { Suspense, lazy } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Spinner from './components/common/Spinner';
import './styles/globals.css';

// Lazy load pages for code splitting
const LandingPage = lazy(() => import('./pages/LandingPage'));
const EndUserDashboard = lazy(() => import('./pages/EndUserDashboard'));
const AdminDashboard = lazy(() => import('./pages/AdminDashboard'));
const NotFound = lazy(() => import('./pages/NotFound'));

// Loading fallback
const LoadingFallback = () => (
  <div style={{ 
    display: 'flex', 
    justifyContent: 'center', 
    alignItems: 'center', 
    minHeight: '100vh',
    background: 'linear-gradient(135deg, #0a0e27 0%, #1a1f3a 100%)'
  }}>
    <Spinner size="lg" />
  </div>
);

export default function App() {
  return (
    <Router>
      <Suspense fallback={<LoadingFallback />}>
        <Routes>
          {/* Landing / Home */}
          <Route path="/" element={<LandingPage />} />
          
          {/* End-User Routes */}
          <Route path="/user" element={<EndUserDashboard />} />
          <Route path="/user/keygen" element={<EndUserDashboard initialTool="keygen" />} />
          <Route path="/user/signer" element={<EndUserDashboard initialTool="signer" />} />
          <Route path="/user/verifier" element={<EndUserDashboard initialTool="verifier" />} />
          <Route path="/user/exporter" element={<EndUserDashboard initialTool="exporter" />} />
          
          {/* Admin Routes */}
          <Route path="/admin" element={<AdminDashboard />} />
          <Route path="/admin/events" element={<AdminDashboard initialTool="events" />} />
          <Route path="/admin/verify" element={<AdminDashboard initialTool="verify" />} />
          <Route path="/admin/registry" element={<AdminDashboard initialTool="registry" />} />
          <Route path="/admin/reports" element={<AdminDashboard initialTool="reports" />} />
          
          {/* 404 Page */}
          <Route path="/404" element={<NotFound />} />
          <Route path="*" element={<Navigate to="/404" replace />} />
        </Routes>
      </Suspense>
    </Router>
  );
}
