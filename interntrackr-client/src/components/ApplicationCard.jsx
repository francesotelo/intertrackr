import { useState } from 'react';
import { ExternalLink, Trash2, ChevronDown } from 'lucide-react';

const STATUSES = ['Wishlist', 'Applied', 'OA/Interview', 'Offer', 'Rejected'];
const STATUS_COLORS = { Wishlist: '#4a9eff', Applied: '#a78bfa', 'OA/Interview': '#f59e0b', Offer: '#10b981', Rejected: '#ef4444' };

export default function ApplicationCard({ app, onUpdate, onDelete }) {
  const [showStatus, setShowStatus] = useState(false);

  return (
    <div style={styles.card}>
      <div style={styles.top}>
        <div>
          <div style={styles.company}>{app.company}</div>
          <div style={styles.role}>{app.role}</div>
          {app.location && <div style={styles.location}>📍 {app.location}</div>}
        </div>
        <div style={styles.actions}>
          {app.link && <a href={app.link} target="_blank" rel="noopener noreferrer" style={styles.iconBtn}><ExternalLink size={14} /></a>}
          {/* Fixed: changed app._id to app.id */}
          <button onClick={() => onDelete(app.id)} style={{ ...styles.iconBtn, color: '#ef4444' }}><Trash2 size={14} /></button>
        </div>
      </div>
      <div style={styles.bottom}>
        <div style={{ position: 'relative' }}>
          <button onClick={() => setShowStatus(!showStatus)}
            style={{ ...styles.statusBadge, background: STATUS_COLORS[app.status] + '20', color: STATUS_COLORS[app.status], borderColor: STATUS_COLORS[app.status] + '40' }}>
            {app.status} <ChevronDown size={12} />
          </button>
          {showStatus && (
            <div style={styles.dropdown}>
              {STATUSES.map(s => (
                /* Fixed: changed app._id to app.id */
                <button key={s} onClick={() => { onUpdate(app.id, { status: s }); setShowStatus(false); }}
                  style={{ ...styles.dropItem, color: STATUS_COLORS[s] }}>{s}</button>
              ))}
            </div>
          )}
        </div>
        {app.deadline && <span style={styles.deadline}>⏰ {new Date(app.deadline).toLocaleDateString()}</span>}
      </div>
      {app.notes && <div style={styles.notes}>{app.notes}</div>}
    </div>
  );
}

const styles = {
  card: { background: 'var(--surface2)', border: '1px solid var(--border)', borderRadius: '12px', padding: '1rem', display: 'flex', flexDirection: 'column', gap: '0.75rem', transition: 'border-color 0.2s' },
  top: { display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' },
  company: { fontFamily: 'Syne, sans-serif', fontWeight: 700, fontSize: '1rem', color: 'var(--text)' },
  role: { fontSize: '0.85rem', color: 'var(--muted)', marginTop: '2px' },
  location: { fontSize: '0.78rem', color: 'var(--muted)', marginTop: '4px' },
  actions: { display: 'flex', gap: '0.5rem' },
  iconBtn: { background: 'none', border: 'none', color: 'var(--muted)', cursor: 'pointer', padding: '4px', display: 'flex', alignItems: 'center', textDecoration: 'none' },
  bottom: { display: 'flex', alignItems: 'center', justifyContent: 'space-between' },
  statusBadge: { display: 'flex', alignItems: 'center', gap: '4px', border: '1px solid', borderRadius: '6px', padding: '3px 10px', fontSize: '0.78rem', fontWeight: 600, cursor: 'pointer', background: 'none', fontFamily: 'DM Sans, sans-serif' },
  dropdown: { position: 'absolute', top: '100%', left: 0, background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: '8px', zIndex: 50, minWidth: '140px', overflow: 'hidden', marginTop: '4px' },
  dropItem: { display: 'block', width: '100%', padding: '0.6rem 1rem', background: 'none', border: 'none', cursor: 'pointer', textAlign: 'left', fontSize: '0.85rem', fontFamily: 'DM Sans, sans-serif' },
  deadline: { fontSize: '0.78rem', color: 'var(--muted)' },
  notes: { fontSize: '0.8rem', color: 'var(--muted)', background: 'var(--bg)', borderRadius: '6px', padding: '0.5rem 0.75rem', lineHeight: 1.5 }
};