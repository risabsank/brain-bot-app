// hi-widgets.jsx — Hi-fi primitives + bottom-sheet engine.

// ─────────────────────────────────────────────────────────────────────────
// Phone shell — iPhone frame styled for warm cream backdrop.
// ─────────────────────────────────────────────────────────────────────────
function HiPhone({ children, bg, dark = false, time = '9:41' }) {
  return (
    <div style={{
      width: 393, height: 852, borderRadius: 50, overflow: 'hidden', position: 'relative',
      background: dark ? '#0B1A14' : (bg || HiT.bg),
      boxShadow: '0 1px 0 rgba(255,255,255,0.6) inset, 0 0 0 1px rgba(15,28,21,0.18), 0 38px 80px rgba(15,28,21,0.25), 0 16px 32px rgba(15,28,21,0.16)',
      fontFamily: HiT.ui, WebkitFontSmoothing: 'antialiased', color: HiT.ink,
    }}>
      {/* dynamic island */}
      <div style={{
        position: 'absolute', top: 11, left: '50%', transform: 'translateX(-50%)',
        width: 122, height: 36, borderRadius: 22, background: '#000', zIndex: 90,
      }} />
      <div style={{ position: 'absolute', top: 0, left: 0, right: 0, zIndex: 80 }}>
        <IOSStatusBar dark={dark} time={time} />
      </div>
      <div style={{ height: '100%', display: 'flex', flexDirection: 'column', position: 'relative' }}>
        {children}
      </div>
      <div style={{
        position: 'absolute', bottom: 0, left: 0, right: 0, zIndex: 95,
        height: 34, display: 'flex', justifyContent: 'center', alignItems: 'flex-end',
        paddingBottom: 8, pointerEvents: 'none',
      }}>
        <div style={{
          width: 139, height: 5, borderRadius: 100,
          background: dark ? 'rgba(255,255,255,0.7)' : 'rgba(0,0,0,0.30)',
        }} />
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────────────
// Hi-fi Primary / Secondary buttons
// ─────────────────────────────────────────────────────────────────────────
function HiButton({ children, onClick, disabled, full = true, kind = 'primary', size = 'lg', style = {} }) {
  const tall = size === 'lg' ? 54 : (size === 'md' ? 44 : 36);
  const base = {
    height: tall, borderRadius: 18, border: 'none', cursor: disabled ? 'not-allowed' : 'pointer',
    fontFamily: HiT.ui, fontSize: size === 'lg' ? 16 : 14, fontWeight: 700,
    letterSpacing: -0.1, width: full ? '100%' : 'auto', padding: '0 22px',
    display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
    transition: 'transform 0.12s ease, box-shadow 0.18s ease, background 0.18s',
    boxSizing: 'border-box',
  };
  const variants = {
    primary: {
      background: disabled ? '#C9D2CC' : HiT.moss, color: '#fff',
      boxShadow: disabled ? 'none' : '0 1px 0 rgba(255,255,255,0.18) inset, 0 -2px 0 rgba(0,0,0,0.15) inset, 0 4px 12px rgba(20,59,45,0.30)',
    },
    secondary: {
      background: '#fff', color: HiT.moss, border: `1.5px solid ${HiT.moss}`,
      boxShadow: '0 1px 2px rgba(15,28,21,0.05)',
    },
    soft: {
      background: HiT.mossSoft, color: HiT.mossDark,
    },
    ghost: {
      background: 'transparent', color: HiT.ink2,
    },
    amber: {
      background: '#F4B65E', color: HiT.amberDeep,
      boxShadow: '0 1px 0 rgba(255,255,255,0.5) inset, 0 -2px 0 rgba(0,0,0,0.10) inset, 0 4px 12px rgba(232,154,60,0.35)',
    },
  };
  return (
    <button
      onClick={onClick} disabled={disabled}
      onMouseDown={(e) => !disabled && (e.currentTarget.style.transform = 'translateY(1px) scale(0.99)')}
      onMouseUp={(e) => (e.currentTarget.style.transform = '')}
      onMouseLeave={(e) => (e.currentTarget.style.transform = '')}
      style={{ ...base, ...variants[kind], ...style }}>
      {children}
    </button>
  );
}

// ─────────────────────────────────────────────────────────────────────────
// Chip (pill, optional icon)
// ─────────────────────────────────────────────────────────────────────────
function HiChip({ active, children, onClick, icon }) {
  return (
    <button onClick={onClick} style={{
      flexShrink: 0, height: 34, padding: '0 14px', borderRadius: 999,
      background: active ? HiT.moss : '#fff',
      color: active ? '#fff' : HiT.ink,
      border: active ? 'none' : `1.2px solid rgba(15,28,21,0.10)`,
      fontFamily: HiT.ui, fontSize: 13, fontWeight: 700,
      cursor: 'pointer', display: 'inline-flex', alignItems: 'center', gap: 6,
      letterSpacing: -0.1,
      boxShadow: active ? '0 2px 8px rgba(20,59,45,0.20)' : 'none',
      transition: 'all 0.15s',
    }}>{icon}{children}</button>
  );
}

// ─────────────────────────────────────────────────────────────────────────
// Level / XP bar — gamification core
// ─────────────────────────────────────────────────────────────────────────
function LevelBar({ level = 3, xp = 64, xpMax = 100, compact = false }) {
  const pct = Math.min(100, (xp / xpMax) * 100);
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 10,
      padding: compact ? '4px 8px 4px 4px' : '6px 14px 6px 6px',
      background: '#fff',
      borderRadius: 999,
      border: '1px solid rgba(15,28,21,0.08)',
      boxShadow: '0 2px 6px rgba(15,28,21,0.05)',
    }}>
      <div style={{
        width: 32, height: 32, borderRadius: 999,
        background: `conic-gradient(${HiT.sprout} ${pct * 3.6}deg, ${HiT.mossSoft} 0)`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        flexShrink: 0,
      }}>
        <div style={{
          width: 24, height: 24, borderRadius: 999, background: HiT.moss,
          color: '#fff', fontFamily: HiT.display, fontWeight: 700, fontSize: 13,
          display: 'flex', alignItems: 'center', justifyContent: 'center', letterSpacing: -0.5,
        }}>{level}</div>
      </div>
      {!compact && (
        <div style={{ display: 'flex', flexDirection: 'column' }}>
          <div style={{
            fontFamily: HiT.ui, fontSize: 11, fontWeight: 700,
            color: HiT.ink3, letterSpacing: 0.5, textTransform: 'uppercase', lineHeight: 1,
          }}>Gardener</div>
          <div style={{ fontFamily: HiT.ui, fontSize: 12.5, color: HiT.ink, fontWeight: 600, marginTop: 2 }}>
            {xp} <span style={{ color: HiT.ink3, fontWeight: 500 }}>/ {xpMax} XP</span>
          </div>
        </div>
      )}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────────────
// Streak pill
// ─────────────────────────────────────────────────────────────────────────
function StreakPill({ days = 7 }) {
  return (
    <div style={{
      display: 'inline-flex', alignItems: 'center', gap: 5,
      padding: '6px 12px', borderRadius: 999,
      background: 'linear-gradient(135deg, #FFC678 0%, #E89A3C 100%)',
      color: '#fff',
      fontFamily: HiT.ui, fontSize: 13, fontWeight: 800, letterSpacing: -0.1,
      boxShadow: '0 1px 0 rgba(255,255,255,0.4) inset, 0 2px 8px rgba(232,154,60,0.45)',
    }}>
      {Ico.flame('#fff', 16)}
      <span>{days}</span>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────────────
// Bottom sheet — slides up from below with backdrop. Drag handle on top.
// ─────────────────────────────────────────────────────────────────────────
function BottomSheet({ open, onClose, children, height = 660, lockClose = false }) {
  const [mounted, setMounted] = React.useState(open);
  const [showing, setShowing] = React.useState(false);
  React.useEffect(() => {
    if (open) {
      setMounted(true);
      requestAnimationFrame(() => requestAnimationFrame(() => setShowing(true)));
    } else if (mounted) {
      setShowing(false);
      const t = setTimeout(() => setMounted(false), 260);
      return () => clearTimeout(t);
    }
  }, [open]);

  if (!mounted) return null;

  return (
    <div style={{
      position: 'absolute', inset: 0, zIndex: 200,
      pointerEvents: 'auto',
    }}>
      {/* backdrop */}
      <div onClick={lockClose ? undefined : onClose} style={{
        position: 'absolute', inset: 0,
        background: 'rgba(20,40,30,0.45)',
        backdropFilter: 'blur(4px)', WebkitBackdropFilter: 'blur(4px)',
        opacity: showing ? 1 : 0,
        transition: 'opacity 0.22s',
      }} />
      {/* sheet */}
      <div style={{
        position: 'absolute', bottom: 0, left: 0, right: 0,
        height, background: HiT.surface2, borderRadius: '28px 28px 0 0',
        transform: showing ? 'translateY(0)' : 'translateY(100%)',
        transition: 'transform 0.30s cubic-bezier(0.16, 0.84, 0.36, 1)',
        boxShadow: '0 -8px 28px rgba(15,28,21,0.15)',
        display: 'flex', flexDirection: 'column', overflow: 'hidden',
      }}>
        {/* drag handle */}
        <div style={{ display: 'flex', justifyContent: 'center', padding: '10px 0 4px' }}>
          <div style={{ width: 44, height: 5, borderRadius: 999, background: 'rgba(15,28,21,0.18)' }} />
        </div>
        {children}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────────────
// XP floater — animated +N XP that drifts up & fades.
// ─────────────────────────────────────────────────────────────────────────
function XpFloater({ events = [] }) {
  return (
    <div style={{
      position: 'absolute', top: 100, left: 0, right: 0,
      zIndex: 250, pointerEvents: 'none',
      display: 'flex', justifyContent: 'center',
    }}>
      <div style={{ position: 'relative', width: 200, height: 80 }}>
        {events.map((e) => (
          <div key={e.id} style={{
            position: 'absolute', left: '50%', top: 30,
            transform: 'translateX(-50%)',
            animation: 'hi-floatup 1.4s ease forwards',
            background: 'linear-gradient(135deg, #FFC678 0%, #E89A3C 100%)',
            color: '#fff', fontFamily: HiT.display, fontSize: 22, fontWeight: 700,
            padding: '6px 16px', borderRadius: 999, letterSpacing: -0.3,
            boxShadow: '0 4px 14px rgba(232,154,60,0.5)',
            display: 'inline-flex', alignItems: 'center', gap: 6,
            whiteSpace: 'nowrap',
          }}>
            {Ico.spark('#fff', 18)} +{e.amount} XP
          </div>
        ))}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────────────
// Section header (small caps)
// ─────────────────────────────────────────────────────────────────────────
function HiLabel({ children, accent, style = {} }) {
  return (
    <div style={{
      fontFamily: HiT.ui, fontSize: 11, fontWeight: 800,
      color: accent || HiT.ink3, letterSpacing: 1, textTransform: 'uppercase',
      ...style,
    }}>{children}</div>
  );
}

// ─────────────────────────────────────────────────────────────────────────
// SEED CARD (compact, hi-fi). Tap → opens detail sheet.
// ─────────────────────────────────────────────────────────────────────────
function HiSeedCard({ idea, onClick, height }) {
  const H = HUE[idea.hue];
  const C = CAT[idea.cat];
  const dark = idea.hue === 'night';
  const fg2 = dark ? 'rgba(230,240,229,0.7)' : 'rgba(15,28,21,0.62)';
  const growth = idea.growth || 1; // 0–3 sprout pips
  return (
    <button
      onClick={onClick}
      style={{
        background: H.bg, color: H.ink, borderRadius: HiT.rLg,
        padding: '14px 14px 12px', border: 'none', cursor: 'pointer',
        textAlign: 'left', fontFamily: HiT.ui,
        display: 'flex', flexDirection: 'column', gap: 7,
        minHeight: height || 168,
        boxShadow: dark
          ? '0 1px 0 rgba(255,255,255,0.04) inset, 0 6px 14px rgba(15,28,21,0.22)'
          : '0 1px 0 rgba(255,255,255,0.7) inset, 0 4px 12px rgba(15,28,21,0.06)',
        position: 'relative', overflow: 'hidden',
        transition: 'transform 0.12s, box-shadow 0.18s',
      }}
      onMouseDown={(e) => (e.currentTarget.style.transform = 'scale(0.98)')}
      onMouseUp={(e) => (e.currentTarget.style.transform = '')}
      onMouseLeave={(e) => (e.currentTarget.style.transform = '')}
    >
      {/* category emoji floats top-right, watermark style */}
      <div style={{
        position: 'absolute', top: 6, right: 8, fontSize: 30, opacity: 0.18,
      }}>{C.emoji}</div>

      <div style={{
        display: 'inline-flex', alignItems: 'center', gap: 4,
        fontSize: 10.5, fontWeight: 800, letterSpacing: 0.5,
        textTransform: 'uppercase', color: dark ? H.ink : HiT.moss,
      }}>
        {C.icon(dark ? H.ink : HiT.moss, 12)}
        <span>{C.label}</span>
      </div>

      <div style={{
        fontFamily: HiT.display, fontSize: 17, fontWeight: 600,
        lineHeight: 1.2, letterSpacing: -0.3, color: H.ink, marginTop: 2,
      }}>{idea.title}</div>

      <div style={{
        fontSize: 12, color: fg2, lineHeight: 1.4, flex: 1,
        display: '-webkit-box', WebkitLineClamp: 3, WebkitBoxOrient: 'vertical', overflow: 'hidden',
      }}>{idea.body}</div>

      {/* growth meter */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: 2 }}>
        <div style={{ display: 'flex', gap: 3 }}>
          {[0, 1, 2].map((i) => (
            <div key={i} style={{
              width: 14, height: 14, borderRadius: 999,
              background: i < growth ? (dark ? '#9DD3B0' : HiT.sprout) : (dark ? 'rgba(255,255,255,0.12)' : 'rgba(15,28,21,0.08)'),
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              {i < growth && Ico.sprout(dark ? '#143B2D' : '#0E3D24', 10)}
            </div>
          ))}
        </div>
        {idea.audio && (
          <div style={{
            display: 'inline-flex', alignItems: 'center', gap: 4,
            fontSize: 10.5, fontWeight: 700, color: dark ? '#9DD3B0' : HiT.moss,
          }}>
            {Ico.wave(dark ? '#9DD3B0' : HiT.moss, 11)}
          </div>
        )}
      </div>
    </button>
  );
}

// ─────────────────────────────────────────────────────────────────────────
// Hue picker — 4 large tiles
// ─────────────────────────────────────────────────────────────────────────
function HuePicker({ value, onChange }) {
  return (
    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 8 }}>
      {Object.entries(HUE).map(([k, H]) => {
        const sel = value === k;
        return (
          <button key={k} onClick={() => onChange(k)} style={{
            height: 88, borderRadius: 16, border: 'none', cursor: 'pointer',
            padding: 10, position: 'relative',
            background: H.bg,
            boxShadow: sel
              ? `0 0 0 3px ${HiT.moss}, 0 0 0 6px rgba(31,92,70,0.20), 0 6px 16px rgba(15,28,21,0.12)`
              : '0 1px 0 rgba(255,255,255,0.5) inset, 0 2px 6px rgba(15,28,21,0.06)',
            display: 'flex', flexDirection: 'column', justifyContent: 'space-between', alignItems: 'flex-start',
            transition: 'box-shadow 0.18s, transform 0.12s',
            color: H.ink,
          }}>
            <div style={{
              width: 22, height: 22, borderRadius: 999,
              background: H.ring, border: `2px solid ${H.bg}`,
              boxShadow: `0 0 0 1.5px ${H.ring}`,
            }} />
            <div style={{ fontFamily: HiT.display, fontSize: 14, fontWeight: 600, letterSpacing: -0.1 }}>{H.label}</div>
            {sel && (
              <div style={{
                position: 'absolute', top: 8, right: 8,
                width: 22, height: 22, borderRadius: 999, background: HiT.moss,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>{Ico.check('#fff', 13)}</div>
            )}
          </button>
        );
      })}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────────────
// Category picker (2×2 grid)
// ─────────────────────────────────────────────────────────────────────────
function CategoryPicker({ value, onChange }) {
  return (
    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
      {Object.entries(CAT).map(([k, C]) => {
        const sel = value === k;
        return (
          <button key={k} onClick={() => onChange(k)} style={{
            display: 'flex', alignItems: 'center', gap: 10, padding: '13px 14px',
            borderRadius: 16, cursor: 'pointer', textAlign: 'left',
            border: 'none',
            background: sel ? HiT.moss : '#fff',
            color: sel ? '#fff' : HiT.ink,
            boxShadow: sel
              ? '0 1px 0 rgba(255,255,255,0.15) inset, 0 -2px 0 rgba(0,0,0,0.15) inset, 0 4px 10px rgba(20,59,45,0.25)'
              : '0 1px 0 rgba(255,255,255,0.5) inset, 0 1px 3px rgba(15,28,21,0.06)',
            fontFamily: HiT.ui, fontSize: 13, fontWeight: 700,
            transition: 'all 0.15s',
          }}>
            <span style={{ fontSize: 20 }}>{C.emoji}</span>
            <span>{C.label}</span>
          </button>
        );
      })}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────────────
// Progress dot row (multi-step)
// ─────────────────────────────────────────────────────────────────────────
function StepDots({ step = 1, total = 3 }) {
  return (
    <div style={{ display: 'flex', gap: 5, alignItems: 'center' }}>
      {Array.from({ length: total }).map((_, i) => {
        const done = i + 1 < step;
        const cur  = i + 1 === step;
        return (
          <div key={i} style={{
            height: 7, borderRadius: 999,
            width: cur ? 26 : 7,
            background: done ? HiT.moss : (cur ? HiT.moss : 'rgba(15,28,21,0.13)'),
            transition: 'all 0.3s',
          }} />
        );
      })}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────────────
// Floating round icon button
// ─────────────────────────────────────────────────────────────────────────
function IconBtn({ icon, onClick, kind = 'soft', size = 40, style = {} }) {
  const variants = {
    soft:  { background: 'rgba(255,255,255,0.92)', color: HiT.ink,  shadow: '0 2px 6px rgba(15,28,21,0.08)' },
    solid: { background: HiT.moss, color: '#fff',  shadow: '0 4px 12px rgba(20,59,45,0.30)' },
    ghost: { background: 'transparent', color: HiT.ink2, shadow: 'none' },
  };
  const v = variants[kind];
  return (
    <button onClick={onClick} style={{
      width: size, height: size, borderRadius: 999, border: 'none',
      background: v.background, color: v.color,
      boxShadow: v.shadow,
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
      cursor: 'pointer',
      ...style,
    }}>{icon}</button>
  );
}

Object.assign(window, {
  HiPhone, HiButton, HiChip, LevelBar, StreakPill,
  BottomSheet, XpFloater, HiLabel, HiSeedCard,
  HuePicker, CategoryPicker, StepDots, IconBtn,
});
