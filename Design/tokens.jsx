// tokens.jsx — Design tokens, status tags, helpers shared across screens.

const T = {
  // surface
  bg:        '#F4F1EC',            // warm paper canvas
  surface:   '#FFFFFF',
  ink:       '#1A1F1C',
  ink2:      '#5A615D',
  ink3:      '#9CA29F',
  line:      'rgba(26,31,28,0.10)',
  line2:     'rgba(26,31,28,0.22)',
  // brand
  brand:     '#1F4D3F',            // midnight green
  brandInk:  '#103027',
  brandSoft: '#E2EBE6',
  // botanical hues
  hueMist:   '#EBF5F2',
  hueSage:   '#D7E8E3',
  huePaper:  '#FBFBF8',
  hueNight:  '#2E4F45',            // tinted dark
  // typography
  font:      '-apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, sans-serif',
  fontMono:  'ui-monospace, "SF Mono", Menlo, monospace',
};

// Annotation status (per spec)
const STATUS = {
  imp:  { bg: '#DDEBE0', fg: '#2A5C36', label: 'Implemented'      },
  ph:   { bg: '#F6E4C5', fg: '#7A4F12', label: 'Placeholder'      },
  fut:  { bg: '#D9E4F2', fg: '#214F86', label: 'MVP Future'       },
  s5:   { bg: '#E5DAF1', fg: '#5C2E94', label: 'Session 5 Concept'},
};

// Tag pill — shows next to elements in annotation panels.
function Tag({ s, children }) {
  const v = STATUS[s] || STATUS.imp;
  return (
    <span style={{
      display: 'inline-block',
      background: v.bg, color: v.fg,
      fontFamily: T.font, fontSize: 9.5, fontWeight: 700,
      padding: '2px 6px', borderRadius: 4,
      letterSpacing: 0.3, textTransform: 'uppercase',
      whiteSpace: 'nowrap', verticalAlign: 'middle',
    }}>{children || v.label}</span>
  );
}

// In-screen tiny corner badge — single-letter version for cramped phone layouts.
function MicroTag({ s }) {
  const map = { imp: 'I', ph: 'P', fut: 'F', s5: 'S5' };
  const v = STATUS[s];
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
      minWidth: 14, height: 14, padding: '0 4px',
      borderRadius: 3,
      background: v.bg, color: v.fg,
      fontFamily: T.font, fontSize: 9, fontWeight: 800,
      letterSpacing: 0.2,
    }}>{map[s]}</span>
  );
}

// Annotation row used in side panels.
function Anno({ s, label, children }) {
  return (
    <div style={{
      display: 'flex', gap: 8, padding: '8px 0',
      borderBottom: '1px dashed rgba(26,31,28,0.10)',
      fontFamily: T.font, fontSize: 11.5, lineHeight: 1.45, color: T.ink2,
    }}>
      <div style={{ flexShrink: 0, marginTop: 1 }}><Tag s={s} /></div>
      <div style={{ flex: 1 }}>
        {label && <div style={{ color: T.ink, fontWeight: 600, fontSize: 11.5, marginBottom: 1 }}>{label}</div>}
        <div>{children}</div>
      </div>
    </div>
  );
}

// SF-symbol-ish icon set, monoline. 24×24 viewbox.
const Icon = {
  leaf: (c='currentColor', s=18) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round">
      <path d="M20 4C12 4 4 8 4 16c0 2 1 4 4 4 8 0 12-8 12-16z"/>
      <path d="M4 20C8 16 12 12 18 8"/>
    </svg>
  ),
  plusCircle: (c='currentColor', s=18) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6" strokeLinecap="round">
      <circle cx="12" cy="12" r="9"/><path d="M12 8v8M8 12h8"/>
    </svg>
  ),
  target: (c='currentColor', s=18) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6">
      <circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="5.5"/><circle cx="12" cy="12" r="2" fill={c}/>
    </svg>
  ),
  search: (c='currentColor', s=16) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.8" strokeLinecap="round">
      <circle cx="11" cy="11" r="6"/><path d="M20 20l-4.5-4.5"/>
    </svg>
  ),
  back: (c='currentColor', s=16) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round">
      <path d="M14.5 5L7 12l7.5 7"/>
    </svg>
  ),
  chevR: (c='currentColor', s=12) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round">
      <path d="M9 5l7 7-7 7"/>
    </svg>
  ),
  chevD: (c='currentColor', s=12) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round">
      <path d="M5 9l7 7 7-7"/>
    </svg>
  ),
  mic: (c='currentColor', s=16) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.7" strokeLinecap="round">
      <rect x="9" y="3" width="6" height="11" rx="3"/><path d="M5 12a7 7 0 0014 0M12 19v3"/>
    </svg>
  ),
  spark: (c='currentColor', s=16) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6" strokeLinejoin="round" strokeLinecap="round">
      <path d="M12 3v5M12 16v5M3 12h5M16 12h5M5.5 5.5l3 3M15.5 15.5l3 3M5.5 18.5l3-3M15.5 8.5l3-3"/>
    </svg>
  ),
  bolt: (c='currentColor', s=14) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.7" strokeLinejoin="round">
      <path d="M13 2L4 14h7l-1 8 9-12h-7l1-8z"/>
    </svg>
  ),
  clock: (c='currentColor', s=14) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.7" strokeLinecap="round">
      <circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>
    </svg>
  ),
  flask: (c='currentColor', s=14) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
      <path d="M9 3h6M10 3v6L4 20a1 1 0 001 1h14a1 1 0 001-1L14 9V3"/>
    </svg>
  ),
  palette: (c='currentColor', s=14) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 3a9 9 0 100 18c1.5 0 2-1 2-2s-1-2-1-3 1-2 3-2h2a3 3 0 003-3 8 8 0 00-9-8z"/>
      <circle cx="7.5" cy="11" r="1" fill={c} stroke="none"/>
      <circle cx="10" cy="7" r="1" fill={c} stroke="none"/>
      <circle cx="15" cy="7.5" r="1" fill={c} stroke="none"/>
    </svg>
  ),
  brain: (c='currentColor', s=18) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.55" strokeLinecap="round" strokeLinejoin="round">
      <path d="M9 4a3 3 0 00-3 3 3 3 0 00-2 5 3 3 0 002 5 3 3 0 003 3h1V4H9z"/>
      <path d="M15 4a3 3 0 013 3 3 3 0 012 5 3 3 0 01-2 5 3 3 0 01-3 3h-1V4h1z"/>
    </svg>
  ),
  wave: (c='currentColor', s=14) => (
    <svg width={s*1.6} height={s} viewBox="0 0 32 14" fill="none" stroke={c} strokeWidth="1.6" strokeLinecap="round">
      <path d="M2 7h2M6 4v6M9 2v10M12 5v4M15 1v12M18 4v6M21 6v2M24 3v8M27 5v4M30 7h.5"/>
    </svg>
  ),
  lock: (c='currentColor', s=18) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6" strokeLinecap="round">
      <rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V8a4 4 0 018 0v3"/>
    </svg>
  ),
  check: (c='currentColor', s=14) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M4 12l5 5L20 6"/>
    </svg>
  ),
  warn: (c='currentColor', s=14) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 3l10 18H2L12 3z"/><path d="M12 10v5M12 18v.5"/>
    </svg>
  ),
  refresh: (c='currentColor', s=14) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
      <path d="M3 12a9 9 0 0115-7l3 3M21 5v4h-4M21 12a9 9 0 01-15 7l-3-3M3 19v-4h4"/>
    </svg>
  ),
  flame: (c='currentColor', s=14) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.7" strokeLinejoin="round">
      <path d="M12 3c0 4-5 5-5 10a5 5 0 0010 0c0-2-1-3-1-5 0 1-1 2-2 2 0-3 0-5-2-7z"/>
    </svg>
  ),
  sprout: (c='currentColor', s=16) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 21V11"/>
      <path d="M12 11C8 11 5 8 5 4c4 0 7 3 7 7z"/>
      <path d="M12 13c4 0 7-2 7-6-4 0-7 2-7 6z"/>
    </svg>
  ),
};

Object.assign(window, { T, STATUS, Tag, MicroTag, Anno, Icon });
