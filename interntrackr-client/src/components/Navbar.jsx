import { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import { LogOut, Sun, Moon } from 'lucide-react';

export default function Navbar({ activeTab, setActiveTab }) {
  const { user, logout } = useAuth();

  const [isNightMode, setIsNightMode] = useState(() => {
    return localStorage.getItem('theme') === 'dark';
  });

  useEffect(() => {
    if (isNightMode) {
      document.documentElement.classList.add('dark');
      localStorage.setItem('theme', 'dark');
    } else {
      document.documentElement.classList.remove('dark');
      localStorage.setItem('theme', 'light');
    }
  }, [isNightMode]);

  return (
    <nav style={styles.nav} className="dark:bg-gray-800 transition-colors">
      <div style={styles.left}>
        {/* Fixed the spelling here! */}
        <span style={styles.logo}>🎓 InternTrackr</span>
        <div style={styles.tabs}>
          {['Pipeline', 'Analytics', 'Profile'].map(tab => (
            <button key={tab} onClick={() => setActiveTab(tab)}
              style={{ ...styles.tab, ...(activeTab === tab ? styles.activeTab : {}) }}>
              {tab}
            </button>
          ))}
        </div>
      </div>
      <div style={styles.right}>
        <button 
          onClick={() => setIsNightMode(!isNightMode)} 
          className="p-2 rounded-full bg-gray-100 hover:bg-gray-200 dark:bg-gray-700 dark:hover:bg-gray-600 transition-colors"
        >
          {isNightMode ? (
            <Sun className="text-yellow-400 w-5 h-5" />
          ) : (
            <Moon className="text-indigo-600 w-5 h-5" />
          )}
        </button>
        <span style={styles.userName}>Hey, {user?.name?.split(' ')[0]} 👋</span>
        <button onClick={logout} style={styles.logoutBtn}>
          <LogOut size={16} /> Logout
        </button>
      </div>
    </nav>
  );
}

const styles = {
  nav: { background: 'var(--surface)', borderBottom: '1px solid var(--border)', padding: '0 2rem', display: 'flex', alignItems: 'center', justifyContent: 'space-between', height: '64px', position: 'sticky', top: 0, zIndex: 100 },
  left: { display: 'flex', alignItems: 'center', gap: '2rem' },
  logo: { fontFamily: 'Syne, sans-serif', fontWeight: 800, fontSize: '1.2rem', color: 'var(--text)' },
  tabs: { display: 'flex', gap: '0.25rem' },
  tab: { background: 'none', border: 'none', color: 'var(--muted)', padding: '0.5rem 1rem', borderRadius: '8px', cursor: 'pointer', fontFamily: 'DM Sans, sans-serif', fontSize: '0.9rem', transition: 'all 0.2s' },
  activeTab: { background: 'var(--surface2)', color: 'var(--text)', fontWeight: 500 },
  right: { display: 'flex', alignItems: 'center', gap: '1rem' },
  userName: { color: 'var(--muted)', fontSize: '0.9rem' },
  logoutBtn: { display: 'flex', alignItems: 'center', gap: '0.4rem', background: 'none', border: '1px solid var(--border)', color: 'var(--muted)', padding: '0.4rem 0.8rem', borderRadius: '8px', cursor: 'pointer', fontSize: '0.85rem' }
};