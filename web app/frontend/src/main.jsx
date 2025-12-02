import React, { useState, useEffect } from 'react';
import axios from 'axios';

const API_BASE_URL = 'http://localhost:3000/api';

export default function App() {
  const [role, setRole] = useState(null);
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(false);

  const fetchStats = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`${API_BASE_URL}/reports/dashboard/stats`);
      setStats(response.data);
    } catch (error) {
      console.error('Error fetching stats:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (role === 'admin') {
      fetchStats();
    }
  }, [role]);

  if (!role) {
    return (
      <div style={styles.container}>
        <div style={styles.header}>
          <h1>🔗 Cardano Community Suite</h1>
          <p>Choose your role to continue</p>
        </div>

        <div style={styles.roleSelector}>
          <div style={styles.roleCard} onClick={() => setRole('user')}>
            <div style={{ fontSize: '48px' }}>👤</div>
            <h2>End-User</h2>
            <p>Manage wallets & sign messages</p>
            <button style={styles.button}>Enter</button>
          </div>

          <div style={styles.roleCard} onClick={() => setRole('admin')}>
            <div style={{ fontSize: '48px' }}>👨‍💼</div>
            <h2>Admin</h2>
            <p>Manage community & verify users</p>
            <button style={styles.button}>Enter</button>
          </div>
        </div>
      </div>
    );
  }

  if (role === 'user') {
    return (
      <div style={styles.container}>
        <div style={styles.header}>
          <button onClick={() => setRole(null)} style={{ ...styles.button, marginBottom: '10px' }}>← Back</button>
          <h1>👤 End-User Tools</h1>
        </div>
        <div style={styles.content}>
          <div style={styles.tool}>
            <h2>🔑 Generate Keypair</h2>
            <p>Create a new Ed25519 keypair for signing messages</p>
            <button style={styles.button}>Generate Keys</button>
          </div>
          
          <div style={styles.tool}>
            <h2>✍️ Sign Message</h2>
            <p>Sign a message with your private key</p>
            <button style={styles.button}>Sign Now</button>
          </div>
          
          <div style={styles.tool}>
            <h2>✓ Verify Signature</h2>
            <p>Verify a signature locally before submitting</p>
            <button style={styles.button}>Verify</button>
          </div>
          
          <div style={styles.tool}>
            <h2>💾 Export Wallet</h2>
            <p>Backup your wallet data</p>
            <button style={styles.button}>Export</button>
          </div>
        </div>
      </div>
    );
  }

  if (role === 'admin') {
    return (
      <div style={styles.container}>
        <div style={styles.header}>
          <button onClick={() => setRole(null)} style={{ ...styles.button, marginBottom: '10px' }}>← Back</button>
          <h1>👨‍💼 Admin Dashboard</h1>
        </div>
        
        {loading ? (
          <p>Loading...</p>
        ) : stats ? (
          <div style={styles.content}>
            <div style={styles.statGrid}>
              <div style={styles.stat}>
                <h3>{stats.total_users}</h3>
                <p>Total Users</p>
              </div>
              <div style={styles.stat}>
                <h3>{stats.total_verified}</h3>
                <p>Verified</p>
              </div>
              <div style={styles.stat}>
                <h3>{stats.total_communities}</h3>
                <p>Communities</p>
              </div>
            </div>

            <div style={styles.tool}>
              <h2>➕ Generate Event</h2>
              <p>Create a new verification event</p>
              <button style={styles.button}>Generate</button>
            </div>
            
            <div style={styles.tool}>
              <h2>✅ Verify Signature</h2>
              <p>Verify user signatures</p>
              <button style={styles.button}>Verify</button>
            </div>
            
            <div style={styles.tool}>
              <h2>📊 View Registry</h2>
              <p>Manage community members</p>
              <button style={styles.button}>View</button>
            </div>
            
            <div style={styles.tool}>
              <h2>📈 Export Report</h2>
              <p>Generate community reports</p>
              <button style={styles.button}>Export</button>
            </div>
          </div>
        ) : null}
      </div>
    );
  }
}

const styles = {
  container: {
    maxWidth: '1200px',
    margin: '0 auto',
    padding: '20px',
    fontFamily: "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif",
    background: 'linear-gradient(135deg, #0a0e27 0%, #1a1f3a 100%)',
    color: '#e0e0e0',
    minHeight: '100vh'
  },
  header: {
    background: 'rgba(20, 28, 50, 0.8)',
    borderBottom: '2px solid #00d4ff',
    padding: '20px',
    marginBottom: '40px',
    borderRadius: '8px'
  },
  roleSelector: {
    display: 'grid',
    gridTemplateColumns: '1fr 1fr',
    gap: '20px',
    margin: '40px 0'
  },
  roleCard: {
    background: 'rgba(30, 40, 70, 0.9)',
    border: '2px solid #00d4ff',
    borderRadius: '12px',
    padding: '30px',
    cursor: 'pointer',
    transition: 'all 0.3s ease',
    textAlign: 'center'
  },
  content: {
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))',
    gap: '20px'
  },
  tool: {
    background: 'rgba(30, 40, 70, 0.9)',
    border: '1px solid #00d4ff',
    borderRadius: '8px',
    padding: '20px'
  },
  statGrid: {
    display: 'grid',
    gridTemplateColumns: 'repeat(3, 1fr)',
    gap: '20px',
    marginBottom: '30px'
  },
  stat: {
    background: 'rgba(0, 212, 255, 0.1)',
    border: '2px solid #00d4ff',
    borderRadius: '8px',
    padding: '20px',
    textAlign: 'center'
  },
  button: {
    background: '#00d4ff',
    color: '#0a0e27',
    border: 'none',
    padding: '10px 25px',
    borderRadius: '6px',
    fontWeight: 'bold',
    cursor: 'pointer',
    transition: 'all 0.3s ease'
  }
};
