import { useState, useEffect } from 'react';
import axios from 'axios';
import Navbar from '../components/Navbar';
import Pipeline from '../components/Pipeline';
import Analytics from '../components/Analytics';
import AddApplicationModal from '../components/AddApplicationModal';
import Profile from './Profile';  // ADD THIS
import { Plus, Search } from 'lucide-react';

export default function Dashboard() {
  const [apps, setApps] = useState([]);
  const [activeTab, setActiveTab] = useState('Pipeline');
  const [showModal, setShowModal] = useState(false);
  const [search, setSearch] = useState('');

  useEffect(() => { fetchApps(); }, []);

  const fetchApps = async () => {
    try {
      const res = await axios.get('http://localhost:5000/api/applications');
      setApps(res.data);
    } catch (err) { console.error(err); }
  };

  const handleAdd = async (form) => {
    try {
      const res = await axios.post('http://localhost:5000/api/applications', form);
      setApps(prev => [res.data, ...prev]);
      setShowModal(false);
    } catch (err) { console.error(err); }
  };

  const handleUpdate = async (id, updates) => {
    try {
      const res = await axios.put(`http://localhost:5000/api/applications/${id}`, updates);
      setApps(prev => prev.map(a => a._id === id ? res.data : a));
    } catch (err) { console.error(err); }
  };

  const handleDelete = async (id) => {
    if (!confirm('Delete this application?')) return;
    try {
      await axios.delete(`http://localhost:5000/api/applications/${id}`);
      setApps(prev => prev.filter(a => a._id !== id));
    } catch (err) { console.error(err); }
  };

  return (
    <div style={{ minHeight: '100vh', background: 'var(--bg)' }}>
      <Navbar activeTab={activeTab} setActiveTab={setActiveTab} />

      {activeTab === 'Pipeline' && (
        <div style={styles.main}>
          <div style={styles.toolbar}>
            <div style={styles.searchWrap}>
              <Search size={16} style={styles.searchIcon} />
              <input style={styles.searchInput} placeholder="Search by company or role..."
                value={search} onChange={e => setSearch(e.target.value)} />
            </div>
            <button onClick={() => setShowModal(true)} style={styles.addBtn}>
              <Plus size={18} /> Add Application
            </button>
          </div>
          <div style={{ overflowX: 'auto' }}>
            <Pipeline apps={apps} onUpdate={handleUpdate} onDelete={handleDelete} search={search} />
          </div>
        </div>
      )}

      {activeTab === 'Analytics' && <Analytics apps={apps} />}

      {activeTab === 'Profile' && <Profile />}  {/* ADD THIS */}

      {showModal && <AddApplicationModal onClose={() => setShowModal(false)} onAdd={handleAdd} />}
    </div>
  );
}

const styles = {
  main: { padding: '2rem' },
  toolbar: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem', gap: '1rem' },
  searchWrap: { position: 'relative', flex: 1, maxWidth: '400px' },
  searchIcon: { position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)', color: 'var(--muted)' },
  searchInput: { width: '100%', background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: '8px', padding: '0.7rem 1rem 0.7rem 2.5rem', color: 'var(--text)', fontSize: '0.9rem', outline: 'none' },
  addBtn: { display: 'flex', alignItems: 'center', gap: '0.5rem', background: 'var(--accent)', color: '#fff', border: 'none', borderRadius: '8px', padding: '0.75rem 1.25rem', fontFamily: 'Syne, sans-serif', fontWeight: 600, fontSize: '0.95rem', cursor: 'pointer', whiteSpace: 'nowrap' }
};