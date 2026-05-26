// hi-tokens.jsx — Hi-fi design tokens for Idea Garden v2 (gamified).

const HiT = {
  // Palette — deep moss + warm paper + amber pop
  bg:        '#F4ECDB',                    // cream paper
  bgDeep:    '#E9DFC8',
  surface:   '#FFFFFF',
  surface2:  '#FAF3E2',                    // raised paper

  ink:       '#1B2A22',                    // near-black green
  ink2:      '#4A5851',
  ink3:      '#8A938E',
  ink4:      'rgba(27,42,34,0.10)',

  // brand
  moss:      '#1F5C46',                    // primary deep moss
  mossDark:  '#143B2D',
  mossSoft:  '#D7E6DC',
  sprout:    '#67B27E',                    // bright spring green (level/XP)
  sproutInk: '#0E5E2B',

  // accents
  amber:     '#E89A3C',                    // streak / XP / pop
  amberDeep: '#B86F18',
  blush:     '#E66B5C',                    // celebration / urgent
  sky:       '#82B5D6',                    // links / informational

  // Botanical Hues — punchier than wireframe
  hueMist:   '#D5ECE3',
  hueMistI:  '#0B3A2A',
  hueSage:   '#B8DAB7',
  hueSageI:  '#173B17',
  huePaper:  '#FBF1D9',
  huePaperI: '#5A3E0A',
  hueNight:  '#2A4438',
  hueNightI: '#E6F0E5',

  // typography
  display:   '"Bricolage Grotesque", -apple-system, system-ui, sans-serif',
  ui:        '"Plus Jakarta Sans", -apple-system, system-ui, sans-serif',
  mono:      'ui-monospace, "JetBrains Mono", Menlo, monospace',

  // radii / shadows
  rXs: 8, rSm: 12, rMd: 16, rLg: 22, rXl: 28,
  shadowSm: '0 1px 2px rgba(20,18,14,0.06), 0 2px 8px rgba(20,18,14,0.05)',
  shadowMd: '0 4px 14px rgba(20,18,14,0.08), 0 10px 32px rgba(20,18,14,0.08)',
  shadowLg: '0 14px 30px rgba(20,18,14,0.10), 0 30px 60px rgba(20,18,14,0.12)',
};

// Inline SVG icon set — rounded, friendly.
const Ico = {
  sprout: (c = 'currentColor', s = 22) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 22V12" />
      <path d="M12 12c-4 0-7-3-7-7 4 0 7 3 7 7z" fill={c} fillOpacity="0.15" />
      <path d="M12 14c4 0 7-2 7-6-4 0-7 2-7 6z" fill={c} fillOpacity="0.15" />
    </svg>
  ),
  leaf:   (c='currentColor', s=22) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.7" strokeLinejoin="round">
      <path d="M20 4c-9 0-15 4-15 12 0 3 2 5 5 5 9 0 12-8 12-17z" fill={c} fillOpacity="0.15"/>
      <path d="M5 21c4-6 9-10 14-14"/>
    </svg>
  ),
  plus:   (c='currentColor', s=22) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2.2" strokeLinecap="round">
      <path d="M12 5v14M5 12h14"/>
    </svg>
  ),
  target: (c='currentColor', s=22) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.6">
      <circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="5.5"/><circle cx="12" cy="12" r="2" fill={c}/>
    </svg>
  ),
  flame:  (c='currentColor', s=18) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill={c} stroke="none">
      <path d="M12 2c0 5-6 5-6 11a6 6 0 0012 0c0-3-1-4-1-7 0 2-1 3-3 3 0-3 0-5-2-7z"/>
    </svg>
  ),
  spark:  (c='currentColor', s=18) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill={c} stroke="none">
      <path d="M12 2l1.8 5.2L19 9l-5.2 1.8L12 16l-1.8-5.2L5 9l5.2-1.8L12 2z"/>
      <circle cx="19" cy="18" r="1.5"/><circle cx="5" cy="19" r="1"/>
    </svg>
  ),
  bolt:   (c='currentColor', s=18) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill={c} stroke="none">
      <path d="M13 2L4 14h6l-1 8 11-13h-7l1-7z"/>
    </svg>
  ),
  clock:  (c='currentColor', s=16) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.8" strokeLinecap="round">
      <circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>
    </svg>
  ),
  flask:  (c='currentColor', s=16) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
      <path d="M9 3h6M10 3v6L4 19a2 2 0 002 2h12a2 2 0 002-2L14 9V3"/>
      <circle cx="9" cy="15" r="1" fill={c}/><circle cx="14" cy="17" r="0.7" fill={c}/>
    </svg>
  ),
  palette:(c='currentColor', s=16) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.7" strokeLinejoin="round">
      <path d="M12 3a9 9 0 100 18c1.5 0 2-1 2-2s-1-2-1-3 1-2 3-2h2a3 3 0 003-3 8 8 0 00-9-8z"/>
      <circle cx="7.5" cy="11" r="1" fill={c} stroke="none"/>
      <circle cx="10" cy="7" r="1" fill={c} stroke="none"/>
      <circle cx="15" cy="7.5" r="1" fill={c} stroke="none"/>
    </svg>
  ),
  search: (c='currentColor', s=18) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round">
      <circle cx="11" cy="11" r="6"/><path d="M20 20l-4.5-4.5"/>
    </svg>
  ),
  close:  (c='currentColor', s=18) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round">
      <path d="M6 6l12 12M18 6L6 18"/>
    </svg>
  ),
  back:   (c='currentColor', s=20) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M14 5l-7 7 7 7"/>
    </svg>
  ),
  mic:    (c='currentColor', s=18) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.8" strokeLinecap="round">
      <rect x="9" y="3" width="6" height="11" rx="3" fill={c} fillOpacity="0.15"/>
      <path d="M5 12a7 7 0 0014 0M12 19v3"/>
    </svg>
  ),
  check:  (c='currentColor', s=18) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round">
      <path d="M4 12l5 5L20 6"/>
    </svg>
  ),
  refresh:(c='currentColor', s=16) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <path d="M3 12a9 9 0 0115-7l3 3M21 5v4h-4"/>
    </svg>
  ),
  paperclip: (c='currentColor', s=24) => (
    <svg width={s} height={s} viewBox="0 0 60 60" fill="none" stroke={c} strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
      <path d="M44 20v22a12 12 0 01-24 0V14a8 8 0 0116 0v26a4 4 0 01-8 0V20"/>
    </svg>
  ),
  trophy:  (c='currentColor', s=18) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill={c} stroke="none">
      <path d="M7 4h10v3a5 5 0 01-10 0V4z"/>
      <path d="M5 5H3a1 1 0 00-1 1v2a4 4 0 004 4h-1V5zM19 5h2a1 1 0 011 1v2a4 4 0 01-4 4h1V5z"/>
      <path d="M9 13h6v3H9z"/>
      <path d="M6 19h12v2H6z"/>
    </svg>
  ),
  arrowRight: (c='currentColor', s=18) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M5 12h14M13 6l6 6-6 6"/>
    </svg>
  ),
  wave:   (c='currentColor', s=16) => (
    <svg width={s*1.6} height={s} viewBox="0 0 32 14" fill="none" stroke={c} strokeWidth="1.8" strokeLinecap="round">
      <path d="M2 7h2M6 4v6M9 2v10M12 5v4M15 1v12M18 4v6M21 6v2M24 3v8M27 5v4M30 7h.5"/>
    </svg>
  ),
  brain:  (c='currentColor', s=18) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill={c} fillOpacity="0.15" stroke={c} strokeWidth="1.55" strokeLinecap="round" strokeLinejoin="round">
      <path d="M9 4a3 3 0 00-3 3 3 3 0 00-2 5 3 3 0 002 5 3 3 0 003 3h1V4H9z"/>
      <path d="M15 4a3 3 0 013 3 3 3 0 012 5 3 3 0 01-2 5 3 3 0 01-3 3h-1V4h1z"/>
    </svg>
  ),
  edit:   (c='currentColor', s=16) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <path d="M4 20l4-1 11-11-3-3L5 16l-1 4z"/><path d="M14 6l4 4"/>
    </svg>
  ),
};

const HUE = {
  mist:  { bg: HiT.hueMist,  ink: HiT.hueMistI,  ring: '#A4D3C0', label: 'Mist'  },
  sage:  { bg: HiT.hueSage,  ink: HiT.hueSageI,  ring: '#7BB47A', label: 'Sage'  },
  paper: { bg: HiT.huePaper, ink: HiT.huePaperI, ring: '#E0CE9C', label: 'Paper' },
  night: { bg: HiT.hueNight, ink: HiT.hueNightI, ring: '#4F7C68', label: 'Night' },
};

const CAT = {
  quick:   { label: 'Quick Win',    icon: Ico.bolt,    emoji: '⚡' },
  long:    { label: 'Long Term',    icon: Ico.clock,   emoji: '🌳' },
  creator: { label: 'Creator Mode', icon: Ico.palette, emoji: '🎨' },
  exper:   { label: 'Experiment',   icon: Ico.flask,   emoji: '🧪' },
};

Object.assign(window, { HiT, Ico, HUE, CAT });
