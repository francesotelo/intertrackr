import { useState } from 'react';
import { X } from 'lucide-react';

const STATUSES = ['Wishlist', 'Applied', 'OA/Interview', 'Offer', 'Rejected'];

export default function AddApplicationModal({ onClose, onAdd }) {
  const [form, setForm] = useState({ company: '', role: '', location: '', link: '', status: 'Wishlist', notes: '', appliedDate: '', deadline: '' });

  const handleSubmit = (e) => {
    e.preventDefault();
    onAdd(form);
  };

  return (
    <div style={styles.overlay}>
      <div style={styles.modal}>
        <div style={styles.header}>
          <h2 style={styles.title}>Add Application</h2>
          <button onClick={onClose} style={styles.closeBtn}><X size={20} /></button>
        </div>
        <form onSubmit={handleSubmit} style={styles.form}>
          <div style={styles.row}>
            <div style={styles.field}>
              <label style={styles.label}>Company *</label>
              <input style={styles.input} placeholder="e.g. Google" value={form.company}
                onChange={e => setForm({ ...form, company: e.target.value })} required />
            </div>
            <div style={styles.field}>
              <label style={styles.label}>Role *</label>
              <input style={styles.input} placeholder="e.g. SWE Intern" value={form.role}
                onChange={e => setForm({ ...form, role: e.target.value })} required />
            </div>
          </div>
          <div style={styles.row}>
            <div style={styles.field}>
              <label style={styles.label}>Location</label>
              <input style={styles.input} placeholder="e.g. Remote, NYC" value={form.location}
                onChange={e => setForm({ ...form, location: e.target.value })} />
            </div>
            <div style={styles.field}>
              <label style={styles.label}>Status</label>
              <select style={styles.input} value={form.status} onChange={e => setForm({ ...form, status: e.target.value })}>
                {STATUSES.map(s => <option key={s}>{s}</option>)}
              </select>
            </div>
          </div>
          <div style={styles.field}>
            <label style={styles.label}>Job Link</label>
            <input style={styles.input} placeholder="https://..." value={form.link}
              onChange={e => setForm({ ...form, link: e.target.value })} />
          </div>
          <div style={styles.row}>
            <div style={styles.field}>
              <label style={styles.label}>Date Applied</label>
              <input style={styles.input} type="date" value={form.appliedDate}
                onChange={e => setForm({ ...form, appliedDate: e.target.value })} />
            </div>
            <div style={styles.field}>
              <label style={styles.label}>Deadline</label>
              <input style={styles.input} type="date" value={form.deadline}
                onChange={e => setForm({ ...form, deadline: e.target.value })} />
            </div>
          </div>
          <div style={styles.field}>
            <label style={styles.label}>Notes</label>
            <textarea style={{ ...styles.input, height: '80px', resize: 'vertical' }} placeholder="Referral, interview tips, etc."
              value={form.notes} onChange={e => setForm({ ...form, notes: e.target.value })} />
          </div>
          <button type="submit" style={styles.submitBtn}>Add Application</button>
        </form>
      </div>
    </div>
  );
}

const styles = {
  overlay: { position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.7)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 200, padding: '1rem' },
  modal: { background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: '16px', width: '100%', maxWidth: '600px', padding: '2rem', maxHeight: '90vh', overflowY: 'auto' },
  header: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' },
  title: { fontSize: '1.4rem', fontWeight: 700 },
  closeBtn: { background: 'none', border: 'none', color: 'var(--muted)', cursor: 'pointer', padding: '4px' },
  form: { display: 'flex', flexDirection: 'column', gap: '1rem' },
  row: { display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' },
  field: { display: 'flex', flexDirection: 'column', gap: '0.4rem' },
  label: { fontSize: '0.8rem', color: 'var(--muted)', fontWeight: 500, textTransform: 'uppercase', letterSpacing: '0.05em' },
  input: { background: 'var(--surface2)', border: '1px solid var(--border)', borderRadius: '8px', padding: '0.75rem 1rem', color: 'var(--text)', fontSize: '0.95rem', outline: 'none', width: '100%' },
  submitBtn: { background: 'var(--accent)', color: '#fff', border: 'none', borderRadius: '8px', padding: '0.9rem', fontSize: '1rem', fontWeight: 600, cursor: 'pointer', fontFamily: 'Syne, sans-serif', marginTop: '0.5rem' }
};