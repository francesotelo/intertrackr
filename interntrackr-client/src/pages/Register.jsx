import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import axios from 'axios';
import { useAuth } from '../context/AuthContext';

export default function Register() {
  const [form, setForm] = useState({ name: '', email: '', password: '' });
  const [error, setError] = useState('');
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const res = await axios.post('http://localhost:5000/api/auth/register', form);
      login(res.data.token, res.data.user);
      navigate('/');
    } catch (err) {
      setError(err.response?.data?.msg || 'Registration failed');
    }
  };

  return (
    <div style={styles.page}>
      <div style={styles.card}>
        <div style={styles.logo}>🎓</div>
        <h1 style={styles.title}>Join InternTrack</h1>
        <p style={styles.sub}>Start tracking your internship hunt today.</p>
        {error && <div style={styles.error}>{error}</div>}
        <form onSubmit={handleSubmit} style={styles.form}>
          <input style={styles.input} placeholder="Full Name" value={form.name}
            onChange={e => setForm({ ...form, name: e.target.value })} required />
          <input style={styles.input} type="email" placeholder="Email" value={form.email}
            onChange={e => setForm({ ...form, email: e.target.value })} required />
          <input style={styles.input} type="password" placeholder="Password" value={form.password}
            onChange={e => setForm({ ...form, password: e.target.value })} required />
          <button style={styles.btn} type="submit">Create Account</button>
        </form>
        <p style={styles.link}>Have an account? <Link to="/login" style={{ color: 'var(--accent)' }}>Sign in</Link></p>
      </div>
    </div>
  );
}

const styles = {
  page: { minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'var(--bg)' },
  card: { background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: '16px', padding: '2.5rem', width: '100%', maxWidth: '400px', textAlign: 'center' },
  logo: { fontSize: '3rem', marginBottom: '0.5rem' },
  title: { fontSize: '2rem', fontWeight: 800, color: 'var(--text)', marginBottom: '0.25rem' },
  sub: { color: 'var(--muted)', marginBottom: '2rem', fontSize: '0.9rem' },
  error: { background: '#ef444420', border: '1px solid #ef4444', color: '#ef4444', borderRadius: '8px', padding: '0.75rem', marginBottom: '1rem', fontSize: '0.85rem' },
  form: { display: 'flex', flexDirection: 'column', gap: '1rem' },
  input: { background: 'var(--surface2)', border: '1px solid var(--border)', borderRadius: '8px', padding: '0.85rem 1rem', color: 'var(--text)', fontSize: '0.95rem', outline: 'none' },
  btn: { background: 'var(--accent)', color: '#fff', border: 'none', borderRadius: '8px', padding: '0.9rem', fontSize: '1rem', fontWeight: 600, cursor: 'pointer', fontFamily: 'Syne, sans-serif' },
  link: { marginTop: '1.5rem', color: 'var(--muted)', fontSize: '0.9rem' }
};