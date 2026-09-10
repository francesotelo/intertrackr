import React from 'react';
import ApplicationCard from './ApplicationCard';

const COLUMNS = [
  { id: 'Wishlist', label: '⭐ Wishlist', color: '#4a9eff' },
  { id: 'Applied', label: '📨 Applied', color: '#a78bfa' },
  { id: 'OA/Interview', label: '🧠 OA / Interview', color: '#f59e0b' },
  { id: 'Offer', label: '🎉 Offer', color: '#10b981' },
  { id: 'Rejected', label: '❌ Rejected', color: '#ef4444' },
];

export default function Pipeline({ apps, onUpdate, onDelete, search }) {
  const filtered = apps.filter(a =>
    a.company.toLowerCase().includes(search.toLowerCase()) ||
    a.role.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div style={styles.board}>
      {COLUMNS.map(col => {
        const colApps = filtered.filter(a => a.status === col.id);
        return (
          <div key={col.id} style={styles.column}>
            <div style={styles.colHeader}>
              <span style={{ ...styles.dot, background: col.color }} />
              <span style={styles.colTitle}>{col.label}</span>
              <span style={styles.count}>{colApps.length}</span>
            </div>
            <div style={styles.cards}>
              {colApps.length === 0
                ? <div style={styles.empty}>No applications</div>
                : colApps.map(app => (
                    /* Fixed: changed app._id to app.id for Firebase */
                    <ApplicationCard key={app.id} app={app} onUpdate={onUpdate} onDelete={onDelete} />
                  ))
              }
            </div>
          </div>
        );
      })}
    </div>
  );
}

const styles = {
  board: { display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)', gap: '1rem', overflowX: 'auto', minWidth: '900px' },
  column: { background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: '12px', padding: '1rem', display: 'flex', flexDirection: 'column', gap: '0.75rem', minHeight: '300px' },
  colHeader: { display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.5rem' },
  dot: { width: '8px', height: '8px', borderRadius: '50%', flexShrink: 0 },
  colTitle: { fontFamily: 'Syne, sans-serif', fontWeight: 600, fontSize: '0.85rem', flex: 1 },
  count: { background: 'var(--surface2)', borderRadius: '10px', padding: '2px 8px', fontSize: '0.75rem', color: 'var(--muted)' },
  cards: { display: 'flex', flexDirection: 'column', gap: '0.75rem', flex: 1 },
  empty: { color: 'var(--muted)', fontSize: '0.8rem', textAlign: 'center', padding: '2rem 0', opacity: 0.6 }
};