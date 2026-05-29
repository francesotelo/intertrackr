import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, PieChart, Pie, Cell, Legend } from 'recharts';

const STATUS_COLORS = { Wishlist: '#4a9eff', Applied: '#a78bfa', 'OA/Interview': '#f59e0b', Offer: '#10b981', Rejected: '#ef4444' };
const STATUSES = ['Wishlist', 'Applied', 'OA/Interview', 'Offer', 'Rejected'];

export default function Analytics({ apps }) {
  const barData = STATUSES.map(s => ({ name: s, count: apps.filter(a => a.status === s).length }));
  const pieData = barData.filter(d => d.count > 0);
  const total = apps.length;
  const offerRate = total > 0 ? ((apps.filter(a => a.status === 'Offer').length / total) * 100).toFixed(1) : 0;
  const interviewRate = total > 0 ? (((apps.filter(a => a.status === 'OA/Interview').length + apps.filter(a => a.status === 'Offer').length) / total) * 100).toFixed(1) : 0;

  const stats = [
    { label: 'Total Applications', value: total, icon: '📋' },
    { label: 'Offer Rate', value: `${offerRate}%`, icon: '🎉' },
    { label: 'Interview Rate', value: `${interviewRate}%`, icon: '🧠' },
    { label: 'Active (Not Rejected)', value: apps.filter(a => a.status !== 'Rejected').length, icon: '🔥' },
  ];

  return (
    <div style={styles.container}>
      <h2 style={styles.heading}>Your Stats</h2>
      <div style={styles.statsGrid}>
        {stats.map(s => (
          <div key={s.label} style={styles.statCard}>
            <div style={styles.statIcon}>{s.icon}</div>
            <div style={styles.statValue}>{s.value}</div>
            <div style={styles.statLabel}>{s.label}</div>
          </div>
        ))}
      </div>
      <div style={styles.charts}>
        <div style={styles.chartCard}>
          <h3 style={styles.chartTitle}>Applications by Stage</h3>
          <ResponsiveContainer width="100%" height={250}>
            <BarChart data={barData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
              <XAxis dataKey="name" tick={{ fill: '#6b6b80', fontSize: 11 }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fill: '#6b6b80', fontSize: 11 }} axisLine={false} tickLine={false} />
              <Tooltip contentStyle={{ background: '#111118', border: '1px solid #2a2a3a', borderRadius: '8px', color: '#e8e8f0' }} />
              <Bar dataKey="count" radius={[6, 6, 0, 0]}>
                {barData.map((entry, i) => <Cell key={i} fill={STATUS_COLORS[entry.name]} />)}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        </div>
        <div style={styles.chartCard}>
          <h3 style={styles.chartTitle}>Pipeline Breakdown</h3>
          <ResponsiveContainer width="100%" height={250}>
            <PieChart>
              <Pie data={pieData} dataKey="count" nameKey="name" cx="50%" cy="50%" outerRadius={90} innerRadius={50}>
                {pieData.map((entry, i) => <Cell key={i} fill={STATUS_COLORS[entry.name]} />)}
              </Pie>
              <Tooltip contentStyle={{ background: '#111118', border: '1px solid #2a2a3a', borderRadius: '8px', color: '#e8e8f0' }} />
              <Legend iconType="circle" wrapperStyle={{ fontSize: '12px', color: '#6b6b80' }} />
            </PieChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  );
}

const styles = {
  container: { padding: '2rem' },
  heading: { fontSize: '1.8rem', fontWeight: 800, marginBottom: '1.5rem' },
  statsGrid: { display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '1rem', marginBottom: '2rem' },
  statCard: { background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: '12px', padding: '1.5rem', textAlign: 'center' },
  statIcon: { fontSize: '1.8rem', marginBottom: '0.5rem' },
  statValue: { fontFamily: 'Syne, sans-serif', fontSize: '2rem', fontWeight: 800, color: 'var(--accent)' },
  statLabel: { color: 'var(--muted)', fontSize: '0.8rem', marginTop: '0.25rem' },
  charts: { display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' },
  chartCard: { background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: '12px', padding: '1.5rem' },
  chartTitle: { fontSize: '1rem', fontWeight: 600, marginBottom: '1rem', color: 'var(--text)' }
};