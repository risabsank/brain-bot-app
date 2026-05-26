// widgets.jsx — Reusable UI primitives for Idea Garden wireframes.

// ──────────────────────────────────────────────────────────────────────────
// Phone wrapper — sets background, leaves room for status bar + home bar.
// ──────────────────────────────────────────────────────────────────────────
function Phone({ children, dark = false, bg, statusBarDark, time = '9:41' }) {
  const sd = statusBarDark ?? dark;
  return (
    <div style={{
      width: 393, height: 852, borderRadius: 47, overflow: 'hidden',
      position: 'relative', background: dark ? '#0F1311' : (bg || T.bg),
      boxShadow: '0 30px 60px rgba(20,18,14,0.15), 0 0 0 1px rgba(0,0,0,0.10)',
      fontFamily: T.font, WebkitFontSmoothing: 'antialiased',
    }}>
      {/* dynamic island */}
      <div style={{
        position: 'absolute', top: 11, left: '50%', transform: 'translateX(-50%)',
        width: 122, height: 36, borderRadius: 22, background: '#000', zIndex: 50,
      }} />
      {/* status bar */}
      <div style={{ position: 'absolute', top: 0, left: 0, right: 0, zIndex: 10 }}>
        <IOSStatusBar dark={sd} time={time} />
      </div>
      <div style={{ height: '100%', display: 'flex', flexDirection: 'column', position: 'relative' }}>
        {children}
      </div>
      {/* home indicator */}
      <div style={{
        position: 'absolute', bottom: 0, left: 0, right: 0, zIndex: 60,
        height: 34, display: 'flex', justifyContent: 'center', alignItems: 'flex-end',
        paddingBottom: 8, pointerEvents: 'none',
      }}>
        <div style={{
          width: 139, height: 5, borderRadius: 100,
          background: dark ? 'rgba(255,255,255,0.7)' : 'rgba(0,0,0,0.35)',
        }} />
      </div>
    </div>
  );
}

// ──────────────────────────────────────────────────────────────────────────
// Tab bar (3 tabs)
// ──────────────────────────────────────────────────────────────────────────
function TabBar({ active = 'ideas', onSelect }) {
  const tabs = [
    { id: 'ideas', label: 'Ideas',       icon: Icon.leaf },
    { id: 'plant', label: 'Plant Seed',  icon: Icon.plusCircle },
    { id: 'sprint',label: 'Daily Sprint',icon: Icon.target },
  ];
  return (
    <div style={{
      flexShrink: 0,
      borderTop: `1px solid ${T.line}`,
      background: 'rgba(255,255,255,0.92)',
      backdropFilter: 'blur(20px)',
      padding: '8px 0 30px',
      display: 'flex',
    }}>
      {tabs.map((t) => {
        const isOn = t.id === active;
        const c = isOn ? T.brand : T.ink3;
        return (
          <button
            key={t.id}
            onClick={() => onSelect && onSelect(t.id)}
            style={{
              flex: 1, background: 'transparent', border: 'none', cursor: 'pointer',
              display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2,
              padding: 4, color: c, fontFamily: T.font,
            }}>
            {t.icon(c, 24)}
            <span style={{ fontSize: 10, fontWeight: 600, letterSpacing: 0.1 }}>{t.label}</span>
          </button>
        );
      })}
    </div>
  );
}

// ──────────────────────────────────────────────────────────────────────────
// Section label (small caps)
// ──────────────────────────────────────────────────────────────────────────
function SectionLabel({ children, style = {} }) {
  return (
    <div style={{
      fontFamily: T.font, fontSize: 11, fontWeight: 700,
      color: T.ink2, letterSpacing: 0.8, textTransform: 'uppercase',
      marginBottom: 8, ...style,
    }}>{children}</div>
  );
}

// ──────────────────────────────────────────────────────────────────────────
// Buttons
// ──────────────────────────────────────────────────────────────────────────
function PrimaryButton({ children, onClick, disabled, full = true, style = {} }) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      style={{
        height: 52, borderRadius: 14, border: 'none',
        background: disabled ? 'rgba(31,77,63,0.20)' : T.brand,
        color: '#fff',
        fontFamily: T.font, fontSize: 16, fontWeight: 600,
        cursor: disabled ? 'not-allowed' : 'pointer',
        width: full ? '100%' : 'auto',
        padding: '0 20px',
        display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
        ...style,
      }}>{children}</button>
  );
}

function SecondaryButton({ children, onClick, style = {} }) {
  return (
    <button
      onClick={onClick}
      style={{
        height: 36, borderRadius: 10, padding: '0 14px',
        background: 'transparent', border: `1.2px solid ${T.brand}`,
        color: T.brand, fontFamily: T.font, fontSize: 13, fontWeight: 600,
        cursor: 'pointer', display: 'inline-flex', alignItems: 'center', gap: 6,
        ...style,
      }}>{children}</button>
  );
}

// ──────────────────────────────────────────────────────────────────────────
// Filter chip
// ──────────────────────────────────────────────────────────────────────────
function Chip({ active, children, onClick }) {
  return (
    <button onClick={onClick} style={{
      flexShrink: 0,
      height: 30, padding: '0 12px', borderRadius: 999,
      background: active ? T.brand : '#fff',
      color: active ? '#fff' : T.brand,
      border: active ? 'none' : `1px solid ${T.brand}`,
      fontFamily: T.font, fontSize: 12.5, fontWeight: 600,
      cursor: 'pointer',
      display: 'inline-flex', alignItems: 'center', gap: 4,
    }}>{children}</button>
  );
}

// ──────────────────────────────────────────────────────────────────────────
// Category tag (icon + label) — used inside seed cards
// ──────────────────────────────────────────────────────────────────────────
const CATEGORIES = {
  quick:   { label: 'Quick Win',    icon: Icon.bolt,    hue: T.hueMist  },
  long:    { label: 'Long Term',    icon: Icon.clock,   hue: T.hueSage  },
  creator: { label: 'Creator Mode', icon: Icon.palette, hue: T.huePaper },
  exper:   { label: 'Experiment',   icon: Icon.flask,   hue: T.hueNight },
};

function CategoryTag({ cat = 'quick', dark = false }) {
  const C = CATEGORIES[cat];
  const c = dark ? '#D8E6E0' : T.brand;
  return (
    <div style={{
      display: 'inline-flex', alignItems: 'center', gap: 5,
      color: c, fontFamily: T.font, fontSize: 11, fontWeight: 700,
      letterSpacing: 0.2, textTransform: 'uppercase',
    }}>
      {C.icon(c, 13)}
      <span>{C.label}</span>
    </div>
  );
}

// ──────────────────────────────────────────────────────────────────────────
// Botanical Hue swatch
// ──────────────────────────────────────────────────────────────────────────
const HUES = {
  mist:  { label: 'Mist',  bg: T.hueMist,  text: T.ink   },
  sage:  { label: 'Sage',  bg: T.hueSage,  text: T.ink   },
  paper: { label: 'Paper', bg: T.huePaper, text: T.ink   },
  night: { label: 'Night', bg: T.hueNight, text: '#EDF2EF' },
};

function HueSwatch({ hue, selected, onClick, size = 64 }) {
  const H = HUES[hue];
  return (
    <button onClick={onClick} style={{
      flex: 1, height: size, borderRadius: 12,
      background: H.bg,
      border: selected ? `2px solid ${T.brand}` : `1px solid ${T.line}`,
      cursor: 'pointer', padding: '8px 10px',
      display: 'flex', flexDirection: 'column', alignItems: 'flex-start', justifyContent: 'space-between',
      position: 'relative',
    }}>
      {selected && (
        <div style={{
          position: 'absolute', top: 6, right: 6,
          width: 16, height: 16, borderRadius: 999, background: T.brand,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>{Icon.check('#fff', 10)}</div>
      )}
      <div style={{
        width: 18, height: 18, borderRadius: 999,
        background: hue === 'paper' ? '#F0EDE5' : H.bg,
        border: `1px solid ${hue === 'paper' ? T.line2 : 'rgba(0,0,0,0.06)'}`,
      }} />
      <span style={{ fontSize: 12, fontWeight: 600, color: H.text, fontFamily: T.font }}>{H.label}</span>
    </button>
  );
}

// ──────────────────────────────────────────────────────────────────────────
// Progress dots (3-step indicator)
// ──────────────────────────────────────────────────────────────────────────
function ProgressDots({ step = 1, total = 3 }) {
  return (
    <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
      {Array.from({ length: total }).map((_, i) => {
        const filled = i < step;
        return (
          <div key={i} style={{
            width: filled ? 22 : 6, height: 6, borderRadius: 999,
            background: filled ? T.brand : 'rgba(26,31,28,0.18)',
            transition: 'all 0.25s',
          }} />
        );
      })}
    </div>
  );
}

// ──────────────────────────────────────────────────────────────────────────
// Phone-internal nav bar (for non-tab screens, like Step pages / Detail)
// ──────────────────────────────────────────────────────────────────────────
function PhoneTopBar({ left, center, right, style = {} }) {
  return (
    <div style={{
      paddingTop: 52, paddingBottom: 10,
      paddingLeft: 16, paddingRight: 16,
      display: 'flex', alignItems: 'center', gap: 12,
      ...style,
    }}>
      <div style={{ minWidth: 60, display: 'flex', alignItems: 'center' }}>{left}</div>
      <div style={{ flex: 1, textAlign: 'center', fontFamily: T.font, fontSize: 15, fontWeight: 600, color: T.ink }}>{center}</div>
      <div style={{ minWidth: 60, display: 'flex', justifyContent: 'flex-end', alignItems: 'center' }}>{right}</div>
    </div>
  );
}

function BackButton({ label = 'Back', onClick }) {
  return (
    <button onClick={onClick} style={{
      background: 'transparent', border: 'none', cursor: 'pointer',
      display: 'inline-flex', alignItems: 'center', gap: 2,
      color: T.brand, fontFamily: T.font, fontSize: 14, fontWeight: 500,
      padding: 0,
    }}>{Icon.back(T.brand, 18)}<span>{label}</span></button>
  );
}

// ──────────────────────────────────────────────────────────────────────────
// Inline text input (faux)
// ──────────────────────────────────────────────────────────────────────────
function FauxInput({ value, placeholder, multiline, minHeight, icon }) {
  const hasV = !!value;
  return (
    <div style={{
      background: '#fff', borderRadius: 12,
      border: `1px solid ${T.line}`,
      padding: multiline ? '12px 14px' : '0 14px',
      minHeight: minHeight || (multiline ? 120 : 44),
      display: 'flex', alignItems: multiline ? 'flex-start' : 'center', gap: 8,
      fontFamily: T.font, fontSize: 14,
      color: hasV ? T.ink : T.ink3,
      lineHeight: 1.45,
    }}>
      {icon && <div style={{ flexShrink: 0, marginTop: multiline ? 2 : 0 }}>{icon}</div>}
      <div style={{ flex: 1 }}>{hasV ? value : placeholder}</div>
    </div>
  );
}

// ──────────────────────────────────────────────────────────────────────────
// Seed Card (used in feed)
// ──────────────────────────────────────────────────────────────────────────
function SeedCard({ idea, onClick }) {
  const isDark = idea.hue === 'night';
  const fg = isDark ? '#EDF2EF' : T.ink;
  const fg2 = isDark ? 'rgba(237,242,239,0.7)' : T.ink2;
  return (
    <div onClick={onClick} style={{
      background: HUES[idea.hue].bg,
      borderRadius: 18, padding: 14,
      border: isDark ? '1px solid rgba(255,255,255,0.06)' : '1px solid rgba(26,31,28,0.06)',
      boxShadow: isDark ? 'none' : '0 1px 0 rgba(255,255,255,0.7) inset',
      display: 'flex', flexDirection: 'column', gap: 8,
      minHeight: 180,
      cursor: onClick ? 'pointer' : 'default',
    }}>
      <CategoryTag cat={idea.cat} dark={isDark} />
      <div style={{
        fontFamily: T.font, fontSize: 15, fontWeight: 700, color: fg,
        lineHeight: 1.25, letterSpacing: -0.1,
      }}>{idea.title}</div>
      <div style={{
        fontFamily: T.font, fontSize: 12, color: fg2,
        lineHeight: 1.4, flex: 1,
        display: '-webkit-box', WebkitLineClamp: 3, WebkitBoxOrient: 'vertical', overflow: 'hidden',
      }}>{idea.body}</div>
      {idea.audio && (
        <div style={{
          display: 'flex', alignItems: 'center', gap: 6,
          color: isDark ? '#9DD3BE' : T.brand,
          fontFamily: T.font, fontSize: 10.5, fontWeight: 600,
        }}>
          {Icon.wave(isDark ? '#9DD3BE' : T.brand, 11)}
          <span>Recording saved</span>
        </div>
      )}
    </div>
  );
}

Object.assign(window, {
  Phone, TabBar, SectionLabel, PrimaryButton, SecondaryButton,
  Chip, CategoryTag, HueSwatch, ProgressDots, PhoneTopBar, BackButton,
  FauxInput, SeedCard, CATEGORIES, HUES,
});
