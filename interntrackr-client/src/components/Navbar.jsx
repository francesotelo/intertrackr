import { useAuth } from '../context/AuthContext';
import { LogOut } from 'lucide-react';

export default function Navbar({ activeTab, setActiveTab }) {
  const { user, logout } = useAuth();

  return (
    <nav style={styles.nav}>
      <div style={styles.left}>
        <span style={styles.logo}>🎓 InternTrack</span>
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