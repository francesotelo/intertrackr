import { useState, useEffect, useRef } from 'react';
import axios from 'axios';
import { useAuth } from '../context/AuthContext';
import { Save, Upload, Trash2, Globe, Plus, X } from 'lucide-react';

export default function Profile() {
  const { user, login, token } = useAuth();
  const [profile, setProfile] = useState(null);
  const [editing, setEditing] = useState(false);
  const [form, setForm] = useState({});
  const [skillInput, setSkillInput] = useState('');
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);
  const fileRef = useRef();

  useEffect(() => { fetchProfile(); }, []);

  const fetchProfile = async () => {
    try {
      const res = await axios.get('http://localhost:5000/api/profile');
      setProfile(res.data);
      setForm(res.data);
    } catch (err) { console.error(err); }
  };

  const handleSave = async () => {
    setSaving(true);
    try {
      const res = await axios.put('http://localhost:5000/api/profile', form);
      setProfile(res.data);
      setEditing(false);
      setSaved(true);
      login(token, { ...user, name: res.data.name });
      setTimeout(() => setSaved(false), 2000);
    } catch (err) { console.error(err); }
    setSaving(false);
  };

  const handleResumeUpload = (e) => {
    const file = e.target.files[0];
    if (!file) return;
    setForm(prev => ({
      ...prev,
      resumeFileName: file.name,
      resumeUploadDate: new Date().toLocaleDateString()
    }));
  };

  const addSkill = () => {
    const s = skillInput.trim();
    if (!s || form.skills?.includes(s)) return;
    setForm(prev => ({ ...prev, skills: [...(prev.skills || []), s] }));
    setSkillInput('');
  };

  const removeSkill = (skill) => {
    setForm(prev => ({ ...prev, skills: prev.skills.filter(s => s !== skill) }));
  };

  if (!profile) return <div style={styles.loading}>Loading profile...</div>;

  const YEAR_LEVELS = ['1st Year', '2nd Year', '3rd Year', '4th Year', '5th Year', 'Graduate'];

  const linkFields = [
    {
      key: 'linkedIn',
      icon: <span style={styles.textIcon}>in</span>,
      label: 'LinkedIn',
      placeholder: 'https://linkedin.com/in/...'
    },
    {
      key: 'github',
      icon: <span style={styles.textIcon}>gh</span>,
      label: 'GitHub',
      placeholder: 'https://github.com/...'
    },
    {
      key: 'portfolio',
      icon: <Globe size={16} />,
      label: 'Portfolio',
      placeholder: 'https://yoursite.com'
    },
  ];

  return (
    <div style={styles.container}>
      {/* Header Card */}
      <div style={styles.headerCard}>
        <div style={styles.avatar}>
          {profile.name?.charAt(0).toUpperCase()}
        </div>
        <div style={styles.headerInfo}>
          <h1 style={styles.name}>{profile.name}</h1>
          <p style={styles.email}>{profile.email}</p>
          <div style={styles.badges}>
            {profile.course && <span style={styles.badge}>📚 {profile.course}</span>}
            {profile.university && <span style={styles.badge}>🏫 {profile.university}</span>}
            {profile.yearLevel && <span style={styles.badge}>🎓 {profile.yearLevel}</span>}
          </div>
        </div>
        <div style={styles.headerActions}>
          {!editing ? (
            <button onClick={() => setEditing(true)} style={styles.editBtn}>Edit Profile</button>
          ) : (
            <div style={{ display: 'flex', gap: '0.5rem' }}>
              <button onClick={() => { setEditing(false); setForm(profile); }} style={styles.cancelBtn}>Cancel</button>
              <button onClick={handleSave} style={styles.saveBtn} disabled={saving}>
                <Save size={15} /> {saving ? 'Saving...' : saved ? 'Saved! ✓' : 'Save'}
              </button>
            </div>
          )}
        </div>
      </div>

      <div style={styles.grid}>
        {/* Left Column */}
        <div style={styles.leftCol}>

          {/* About */}
          <div style={styles.card}>
            <h3 style={styles.cardTitle}>About</h3>
            {editing ? (
              <textarea style={styles.textarea} placeholder="Write a short bio about yourself..."
                value={form.bio || ''} onChange={e => setForm({ ...form, bio: e.target.value })} />
            ) : (
              <p style={styles.bioText}>
                {profile.bio || <span style={styles.empty}>No bio added yet.</span>}
              </p>
            )}
          </div>

          {/* Academic Info */}
          <div style={styles.card}>
            <h3 style={styles.cardTitle}>Academic Info</h3>
            <div style={styles.fieldGrid}>
              <div style={styles.field}>
                <label style={styles.label}>Full Name</label>
                {editing
                  ? <input style={styles.input} value={form.name || ''}
                      onChange={e => setForm({ ...form, name: e.target.value })} />
                  : <span style={styles.value}>{profile.name}</span>}
              </div>
              <div style={styles.field}>
                <label style={styles.label}>Course / Degree</label>
                {editing
                  ? <input style={styles.input} placeholder="e.g. BS Computer Science"
                      value={form.course || ''}
                      onChange={e => setForm({ ...form, course: e.target.value })} />
                  : <span style={styles.value}>{profile.course || '—'}</span>}
              </div>
              <div style={styles.field}>
                <label style={styles.label}>University</label>
                {editing
                  ? <input style={styles.input} placeholder="e.g. UP Diliman"
                      value={form.university || ''}
                      onChange={e => setForm({ ...form, university: e.target.value })} />
                  : <span style={styles.value}>{profile.university || '—'}</span>}
              </div>
              <div style={styles.field}>
                <label style={styles.label}>Year Level</label>
                {editing
                  ? <select style={styles.input} value={form.yearLevel || ''}
                      onChange={e => setForm({ ...form, yearLevel: e.target.value })}>
                      <option value="">Select year</option>
                      {YEAR_LEVELS.map(y => <option key={y}>{y}</option>)}
                    </select>
                  : <span style={styles.value}>{profile.yearLevel || '—'}</span>}
              </div>
            </div>
          </div>

          {/* Links */}
          <div style={styles.card}>
            <h3 style={styles.cardTitle}>Links</h3>
            <div style={styles.linksGrid}>
              {linkFields.map(({ key, icon, placeholder }) => (
                <div key={key} style={styles.linkRow}>
                  <span style={styles.linkIcon}>{icon}</span>
                  {editing
                    ? <input style={styles.linkInput} placeholder={placeholder}
                        value={form[key] || ''}
                        onChange={e => setForm({ ...form, [key]: e.target.value })} />
                    : profile[key]
                      ? <a href={profile[key]} target="_blank" rel="noopener noreferrer"
                          style={styles.linkValue}>{profile[key]}</a>
                      : <span style={styles.empty}>Not added</span>}
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Right Column */}
        <div style={styles.rightCol}>

          {/* Resume */}
          <div style={styles.card}>
            <h3 style={styles.cardTitle}>Resume</h3>
            {form.resumeFileName ? (
              <div style={styles.resumeBox}>
                <div style={styles.resumeIcon}>📄</div>
                <div style={styles.resumeInfo}>
                  <div style={styles.resumeName}>{form.resumeFileName}</div>
                  <div style={styles.resumeDate}>Uploaded {form.resumeUploadDate}</div>
                </div>
                {editing && (
                  <button
                    onClick={() => setForm(prev => ({ ...prev, resumeFileName: '', resumeUploadDate: '' }))}
                    style={styles.removeBtn}>
                    <Trash2 size={14} />
                  </button>
                )}
              </div>
            ) : (
              <div style={styles.resumeEmpty}>
                <p style={styles.empty}>No resume uploaded yet.</p>
              </div>
            )}
            {editing && (
              <>
                <input type="file" ref={fileRef} onChange={handleResumeUpload}
                  accept=".pdf,.doc,.docx" style={{ display: 'none' }} />
                <button onClick={() => fileRef.current.click()} style={styles.uploadBtn}>
                  <Upload size={15} /> Upload Resume
                </button>
              </>
            )}
          </div>

          {/* Skills */}
          <div style={styles.card}>
            <h3 style={styles.cardTitle}>Skills</h3>
            <div style={styles.skillsWrap}>
              {(editing ? form.skills : profile.skills)?.map(skill => (
                <span key={skill} style={styles.skillTag}>
                  {skill}
                  {editing && (
                    <button onClick={() => removeSkill(skill)} style={styles.skillRemove}>
                      <X size={10} />
                    </button>
                  )}
                </span>
              ))}
              {(editing ? form.skills : profile.skills)?.length === 0 &&
                <span style={styles.empty}>No skills added yet.</span>}
            </div>
            {editing && (
              <div style={styles.skillInputRow}>
                <input style={styles.skillInput} placeholder="Add a skill (press Enter)..."
                  value={skillInput}
                  onChange={e => setSkillInput(e.target.value)}
                  onKeyDown={e => e.key === 'Enter' && addSkill()} />
                <button onClick={addSkill} style={styles.addSkillBtn}><Plus size={16} /></button>
              </div>
            )}
          </div>

          {/* Account Info */}
          <div style={styles.card}>
            <h3 style={styles.cardTitle}>Account Info</h3>
            <div style={styles.statsGrid}>
              <div style={styles.statItem}>
                <span style={styles.statLabel}>Member Since</span>
                <span style={styles.statValue}>
                  {new Date(profile.createdAt).toLocaleDateString('en-US', { month: 'long', year: 'numeric' })}
                </span>
              </div>
              <div style={styles.statItem}>
                <span style={styles.statLabel}>Email</span>
                <span style={styles.statValue}>{profile.email}</span>
              </div>
            </div>
          </div>

        </div>
      </div>
    </div>
  );
}

const styles = {
  container: { padding: '2rem', maxWidth: '1100px', margin: '0 auto' },
  loading: { color: 'var(--muted)', padding: '3rem', textAlign: 'center' },
  headerCard: { background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: '16px', padding: '2rem', display: 'flex', alignItems: 'center', gap: '1.5rem', marginBottom: '1.5rem', flexWrap: 'wrap' },
  avatar: { width: '80px', height: '80px', borderRadius: '50%', background: 'linear-gradient(135deg, var(--accent), #f7c06a)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '2rem', fontFamily: 'Syne, sans-serif', fontWeight: 800, color: '#fff', flexShrink: 0 },
  headerInfo: { flex: 1 },
  name: { fontSize: '1.8rem', fontWeight: 800, marginBottom: '0.25rem' },
  email: { color: 'var(--muted)', fontSize: '0.9rem', marginBottom: '0.75rem' },
  badges: { display: 'flex', gap: '0.5rem', flexWrap: 'wrap' },
  badge: { background: 'var(--surface2)', border: '1px solid var(--border)', borderRadius: '20px', padding: '3px 12px', fontSize: '0.78rem', color: 'var(--muted)' },
  headerActions: { display: 'flex', alignItems: 'center' },
  editBtn: { background: 'var(--surface2)', border: '1px solid var(--border)', color: 'var(--text)', borderRadius: '8px', padding: '0.6rem 1.2rem', cursor: 'pointer', fontFamily: 'Syne, sans-serif', fontWeight: 600, fontSize: '0.9rem' },
  cancelBtn: { background: 'none', border: '1px solid var(--border)', color: 'var(--muted)', borderRadius: '8px', padding: '0.6rem 1rem', cursor: 'pointer', fontSize: '0.9rem' },
  saveBtn: { display: 'flex', alignItems: 'center', gap: '0.4rem', background: 'var(--accent)', color: '#fff', border: 'none', borderRadius: '8px', padding: '0.6rem 1.2rem', cursor: 'pointer', fontFamily: 'Syne, sans-serif', fontWeight: 600, fontSize: '0.9rem' },
  grid: { display: 'grid', gridTemplateColumns: '1fr 380px', gap: '1.5rem' },
  leftCol: { display: 'flex', flexDirection: 'column', gap: '1.5rem' },
  rightCol: { display: 'flex', flexDirection: 'column', gap: '1.5rem' },
  card: { background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: '12px', padding: '1.5rem' },
  cardTitle: { fontSize: '0.8rem', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.08em', color: 'var(--muted)', marginBottom: '1rem' },
  fieldGrid: { display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' },
  field: { display: 'flex', flexDirection: 'column', gap: '0.4rem' },
  label: { fontSize: '0.75rem', color: 'var(--muted)', fontWeight: 500 },
  value: { fontSize: '0.95rem', color: 'var(--text)', fontWeight: 500 },
  input: { background: 'var(--surface2)', border: '1px solid var(--border)', borderRadius: '8px', padding: '0.6rem 0.8rem', color: 'var(--text)', fontSize: '0.9rem', outline: 'none', width: '100%' },
  textarea: { background: 'var(--surface2)', border: '1px solid var(--border)', borderRadius: '8px', padding: '0.75rem', color: 'var(--text)', fontSize: '0.9rem', outline: 'none', width: '100%', minHeight: '90px', resize: 'vertical', fontFamily: 'DM Sans, sans-serif' },
  bioText: { color: 'var(--text)', fontSize: '0.95rem', lineHeight: 1.6 },
  empty: { color: 'var(--muted)', fontSize: '0.85rem', fontStyle: 'italic' },
  linksGrid: { display: 'flex', flexDirection: 'column', gap: '0.75rem' },
  linkRow: { display: 'flex', alignItems: 'center', gap: '0.75rem' },
  linkIcon: { color: 'var(--muted)', flexShrink: 0, display: 'flex', alignItems: 'center' },
  textIcon: { fontWeight: 800, fontSize: '11px', color: 'var(--muted)', background: 'var(--surface2)', border: '1px solid var(--border)', borderRadius: '4px', padding: '2px 5px', letterSpacing: '0.02em' },
  linkInput: { background: 'var(--surface2)', border: '1px solid var(--border)', borderRadius: '8px', padding: '0.55rem 0.8rem', color: 'var(--text)', fontSize: '0.85rem', outline: 'none', flex: 1 },
  linkValue: { color: 'var(--accent)', fontSize: '0.85rem', textDecoration: 'none', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', maxWidth: '300px' },
  resumeBox: { display: 'flex', alignItems: 'center', gap: '1rem', background: 'var(--surface2)', borderRadius: '10px', padding: '1rem', marginBottom: '1rem' },
  resumeIcon: { fontSize: '2rem' },
  resumeInfo: { flex: 1 },
  resumeName: { fontWeight: 600, fontSize: '0.9rem', color: 'var(--text)' },
  resumeDate: { fontSize: '0.78rem', color: 'var(--muted)', marginTop: '2px' },
  resumeEmpty: { marginBottom: '1rem' },
  removeBtn: { background: 'none', border: 'none', color: '#ef4444', cursor: 'pointer', padding: '4px' },
  uploadBtn: { display: 'flex', alignItems: 'center', gap: '0.5rem', background: 'var(--surface2)', border: '1px solid var(--border)', color: 'var(--text)', borderRadius: '8px', padding: '0.6rem 1rem', cursor: 'pointer', fontSize: '0.85rem', width: '100%', justifyContent: 'center' },
  skillsWrap: { display: 'flex', flexWrap: 'wrap', gap: '0.5rem', marginBottom: '1rem', minHeight: '30px' },
  skillTag: { display: 'flex', alignItems: 'center', gap: '4px', background: 'var(--accent)20', border: '1px solid var(--accent)40', color: 'var(--accent)', borderRadius: '20px', padding: '4px 12px', fontSize: '0.8rem', fontWeight: 500 },
  skillRemove: { background: 'none', border: 'none', color: 'var(--accent)', cursor: 'pointer', padding: 0, display: 'flex', alignItems: 'center' },
  skillInputRow: { display: 'flex', gap: '0.5rem' },
  skillInput: { flex: 1, background: 'var(--surface2)', border: '1px solid var(--border)', borderRadius: '8px', padding: '0.55rem 0.8rem', color: 'var(--text)', fontSize: '0.85rem', outline: 'none' },
  addSkillBtn: { background: 'var(--accent)', color: '#fff', border: 'none', borderRadius: '8px', padding: '0.55rem 0.75rem', cursor: 'pointer', display: 'flex', alignItems: 'center' },
  statsGrid: { display: 'flex', flexDirection: 'column', gap: '0.75rem' },
  statItem: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '0.5rem 0', borderBottom: '1px solid var(--border)' },
  statLabel: { fontSize: '0.82rem', color: 'var(--muted)' },
  statValue: { fontSize: '0.85rem', color: 'var(--text)', fontWeight: 500 },
};