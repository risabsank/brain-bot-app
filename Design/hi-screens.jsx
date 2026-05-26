// hi-screens.jsx — All hi-fi screens, gamified, sheet-based.

const HI_SEEDS = [
  { id: 's1', cat: 'creator', hue: 'sage',  growth: 2, audio: false, title: 'Podcast hook ideas',     body: 'Open each episode with a 20-second true story, then hard-cut to the host’s key question.' },
  { id: 's2', cat: 'exper',   hue: 'mist',  growth: 1, audio: true,  title: 'Weekend pop-up cart',    body: 'Test a one-day iced tea cart at the farmer’s market this Saturday. Measure conversion.' },
  { id: 's3', cat: 'long',    hue: 'paper', growth: 3, audio: false, title: 'Fitness mini-app',       body: '7-day bodyweight series with a streak ring and one daily prompt.' },
  { id: 's4', cat: 'quick',   hue: 'sage',  growth: 1, audio: false, title: 'Newsletter referral',    body: 'Offer a practical PDF in exchange for a referral. Track conversion weekly.' },
  { id: 's5', cat: 'creator', hue: 'night', growth: 2, audio: true,  title: 'Studio visit series',    body: 'Short documentary visits to local artists’ workshops, one per month.' },
  { id: 's6', cat: 'exper',   hue: 'mist',  growth: 1, audio: false, title: 'Slow recipe video',      body: 'Single static shot, ASMR audio, no narration. 90 seconds end-to-end.' },
];

// ═══════════════════════════════════════════════════════════════════════════
// ENTRY GATE — fully hi-fi brand moment with floating glyphs.
// ═══════════════════════════════════════════════════════════════════════════
function HiEntry({ onContinue }) {
  return (
    <HiPhone bg="#E2EFE3">
      {/* organic backdrop */}
      <div style={{ position: 'absolute', inset: 0, overflow: 'hidden', pointerEvents: 'none' }}>
        <div style={{
          position: 'absolute', top: -120, left: -80,
          width: 380, height: 380, borderRadius: '50%',
          background: 'radial-gradient(circle at 30% 30%, #B7DAB8 0%, transparent 70%)',
          filter: 'blur(8px)',
        }} />
        <div style={{
          position: 'absolute', bottom: -150, right: -100,
          width: 360, height: 360, borderRadius: '50%',
          background: 'radial-gradient(circle at 70% 70%, #F4B65E 0%, transparent 70%)',
          opacity: 0.6, filter: 'blur(12px)',
        }} />
        {/* floating sprouts */}
        {[
          { x: 60,  y: 130, r: -18, s: 28, c: HiT.moss, d: 0    },
          { x: 320, y: 180, r: 14,  s: 22, c: HiT.sprout, d: 1.6 },
          { x: 50,  y: 350, r: -8,  s: 18, c: HiT.amber, d: 3.0 },
          { x: 330, y: 430, r: 20,  s: 26, c: HiT.moss, d: 1    },
          { x: 80,  y: 560, r: -25, s: 22, c: HiT.sprout, d: 2.4 },
        ].map((p, i) => (
          <div key={i} style={{
            position: 'absolute', left: p.x, top: p.y,
            transform: `rotate(${p.r}deg)`,
            animation: `hi-bob 6s ease-in-out ${p.d}s infinite`,
            opacity: 0.65,
          }}>
            {Ico.sprout(p.c, p.s)}
          </div>
        ))}
      </div>

      <div style={{ flex: 1, padding: '90px 28px 36px', position: 'relative', zIndex: 1, display: 'flex', flexDirection: 'column' }}>
        {/* logo lockup */}
        <div style={{
          width: 76, height: 76, borderRadius: 26,
          background: HiT.moss,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          boxShadow: '0 1px 0 rgba(255,255,255,0.18) inset, 0 -3px 0 rgba(0,0,0,0.15) inset, 0 12px 28px rgba(20,59,45,0.32)',
          marginBottom: 28,
        }}>{Ico.sprout('#E2EFE3', 42)}</div>

        <div style={{
          fontFamily: HiT.display, fontSize: 52, fontWeight: 600,
          color: HiT.mossDark, letterSpacing: -1.5, lineHeight: 1,
        }}>Idea<br/>Garden.</div>

        <div style={{
          marginTop: 14,
          fontFamily: HiT.ui, fontSize: 17, fontWeight: 500,
          color: 'rgba(20,59,45,0.7)', lineHeight: 1.4, maxWidth: 280,
        }}>Capture sparks. Tend them daily. Watch ideas grow into action.</div>

        <div style={{ flex: 1 }} />

        {/* stats teaser */}
        <div style={{
          background: 'rgba(255,255,255,0.6)', backdropFilter: 'blur(10px)',
          border: '1px solid rgba(255,255,255,0.7)',
          borderRadius: 20, padding: 14,
          marginBottom: 16,
          display: 'flex', alignItems: 'center', gap: 12,
        }}>
          <div style={{
            width: 44, height: 44, borderRadius: 14,
            background: HiT.amber, display: 'flex', alignItems: 'center', justifyContent: 'center',
            color: '#fff', boxShadow: '0 4px 10px rgba(232,154,60,0.4)',
          }}>{Ico.trophy('#fff', 22)}</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontFamily: HiT.ui, fontSize: 12, fontWeight: 700, color: HiT.amberDeep, letterSpacing: 0.4, textTransform: 'uppercase' }}>Today</div>
            <div style={{ fontFamily: HiT.display, fontSize: 16, color: HiT.ink, marginTop: 1 }}>Paperclip · Daily Sprint awaits</div>
          </div>
        </div>

        <HiButton onClick={onContinue}>
          <span>Step into the garden</span>
          {Ico.arrowRight('#fff', 18)}
        </HiButton>
        <div style={{ textAlign: 'center', marginTop: 14, fontFamily: HiT.ui, fontSize: 11.5, color: 'rgba(20,59,45,0.55)' }}>
          Demo sign-in · real auth attaches later
        </div>
      </div>
    </HiPhone>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// HOME (Ideas) — header with gamification + compact feed
// ═══════════════════════════════════════════════════════════════════════════
function HiHome({ onOpenSeed, onPlant, onSprint, onSearch, query = '', xp, level, streak, sproutsToday }) {
  const [chip, setChip] = React.useState('all');

  let list = HI_SEEDS;
  if (query) {
    const q = query.toLowerCase();
    list = list.filter((i) => (i.title + ' ' + i.body).toLowerCase().includes(q));
  }
  if (chip !== 'all') list = list.filter((i) => i.cat === chip);

  return (
    <>
      {/* HEADER — sticky non-scrolling band */}
      <div style={{
        flexShrink: 0, padding: '56px 18px 12px',
        background: HiT.bg,
        position: 'relative', zIndex: 4,
      }}>
        {/* row 1 — greet + streak */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 }}>
          <div>
            <div style={{ fontFamily: HiT.ui, fontSize: 12, fontWeight: 600, color: HiT.ink3, letterSpacing: 0.5, textTransform: 'uppercase' }}>Good morning, Alex</div>
            <div style={{ fontFamily: HiT.display, fontSize: 30, fontWeight: 600, color: HiT.ink, letterSpacing: -0.8, marginTop: 2 }}>
              Your garden
            </div>
          </div>
          <StreakPill days={streak} />
        </div>

        {/* row 2 — XP/Level + Sprint card */}
        <div style={{ display: 'flex', gap: 10, marginBottom: 14 }}>
          <button onClick={onSprint} style={{
            flex: 1, padding: 14, borderRadius: HiT.rLg, border: 'none',
            cursor: 'pointer', textAlign: 'left', position: 'relative', overflow: 'hidden',
            background: 'linear-gradient(135deg, #1F5C46 0%, #143B2D 100%)',
            color: '#fff',
            boxShadow: '0 1px 0 rgba(255,255,255,0.12) inset, 0 6px 16px rgba(20,59,45,0.30)',
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 4 }}>
              {Ico.target('#A6E5C9', 14)}
              <span style={{ fontFamily: HiT.ui, fontSize: 10.5, fontWeight: 800, letterSpacing: 0.6, textTransform: 'uppercase', color: '#A6E5C9' }}>Daily Sprint</span>
            </div>
            <div style={{ fontFamily: HiT.display, fontSize: 19, fontWeight: 600, letterSpacing: -0.3, lineHeight: 1.1 }}>Paperclip</div>
            <div style={{ fontFamily: HiT.ui, fontSize: 11.5, color: 'rgba(255,255,255,0.7)', marginTop: 3 }}>
              Tap to play · 10 min
            </div>
            <div style={{
              position: 'absolute', right: -10, bottom: -16,
              fontSize: 80, opacity: 0.18, transform: 'rotate(-12deg)',
              color: '#A6E5C9',
            }}>{Ico.paperclip('#A6E5C9', 90)}</div>
          </button>

          <div style={{
            width: 130, padding: 14, borderRadius: HiT.rLg,
            background: '#fff',
            border: '1px solid rgba(15,28,21,0.06)',
            boxShadow: '0 4px 10px rgba(15,28,21,0.05)',
            display: 'flex', flexDirection: 'column', justifyContent: 'space-between',
          }}>
            <div style={{ fontFamily: HiT.ui, fontSize: 10.5, fontWeight: 800, letterSpacing: 0.6, textTransform: 'uppercase', color: HiT.ink3 }}>Today</div>
            <div>
              <div style={{ display: 'flex', alignItems: 'baseline', gap: 5 }}>
                <div style={{ fontFamily: HiT.display, fontSize: 30, fontWeight: 600, color: HiT.moss, letterSpacing: -1, lineHeight: 1 }}>+{sproutsToday}</div>
                <div style={{ color: HiT.sprout }}>{Ico.sprout(HiT.sprout, 14)}</div>
              </div>
              <div style={{ fontFamily: HiT.ui, fontSize: 11, color: HiT.ink2, marginTop: 2 }}>sprouts planted</div>
            </div>
            <LevelBar level={level} xp={xp} xpMax={100} compact />
          </div>
        </div>

        {/* row 3 — search + filter */}
        <div style={{ display: 'flex', gap: 8, marginBottom: 10 }}>
          <button onClick={onSearch} style={{
            flex: 1, height: 42, borderRadius: 14, border: 'none',
            background: '#fff', color: query ? HiT.ink : HiT.ink3,
            padding: '0 14px',
            display: 'flex', alignItems: 'center', gap: 8,
            fontFamily: HiT.ui, fontSize: 14, fontWeight: 500, cursor: 'pointer',
            boxShadow: '0 1px 3px rgba(15,28,21,0.04)',
            border: '1px solid rgba(15,28,21,0.06)',
          }}>
            {Ico.search(HiT.ink3, 16)}
            <span style={{ flex: 1, textAlign: 'left' }}>{query || 'Search seeds…'}</span>
          </button>
          <IconBtn icon={Ico.refresh(HiT.ink, 16)} kind="soft" size={42} />
        </div>

        <div style={{ display: 'flex', gap: 6, overflowX: 'auto', paddingBottom: 2 }}>
          <HiChip active={chip === 'all'}     onClick={() => setChip('all')}>All</HiChip>
          <HiChip active={chip === 'quick'}   onClick={() => setChip('quick')}>⚡ Quick</HiChip>
          <HiChip active={chip === 'exper'}   onClick={() => setChip('exper')}>🧪 Experiment</HiChip>
          <HiChip active={chip === 'creator'} onClick={() => setChip('creator')}>🎨 Creator</HiChip>
          <HiChip active={chip === 'long'}    onClick={() => setChip('long')}>🌳 Long term</HiChip>
        </div>
      </div>

      {/* GRID — scrolling area */}
      <div style={{ flex: 1, overflowY: 'auto', padding: '8px 18px 110px' }}>
        {list.length === 0 ? (
          <HomeEmpty onPlant={onPlant} hasQuery={!!query} query={query} />
        ) : (
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            {list.map((i) => <HiSeedCard key={i.id} idea={i} onClick={() => onOpenSeed(i)} />)}
          </div>
        )}
      </div>

      {/* TAB BAR — pill-shaped, floating */}
      <HiTabBar onPlant={onPlant} onSprint={onSprint} active="ideas" />
    </>
  );
}

function HomeEmpty({ onPlant, hasQuery, query }) {
  if (hasQuery) {
    return (
      <div style={{ textAlign: 'center', padding: '70px 24px' }}>
        <div style={{ fontSize: 44 }}>🌫️</div>
        <div style={{ fontFamily: HiT.display, fontSize: 18, fontWeight: 600, marginTop: 8 }}>No seeds match &ldquo;{query}&rdquo;</div>
        <div style={{ fontFamily: HiT.ui, fontSize: 13, color: HiT.ink2, marginTop: 6 }}>Try different words, or plant a new seed.</div>
      </div>
    );
  }
  return (
    <div style={{ textAlign: 'center', padding: '60px 24px' }}>
      <div style={{
        width: 96, height: 96, margin: '0 auto 16px',
        borderRadius: 28, background: HiT.mossSoft,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        boxShadow: '0 12px 28px rgba(20,59,45,0.15)',
      }}>{Ico.sprout(HiT.moss, 44)}</div>
      <div style={{ fontFamily: HiT.display, fontSize: 22, fontWeight: 600, color: HiT.ink }}>Your garden is empty</div>
      <div style={{ fontFamily: HiT.ui, fontSize: 14, color: HiT.ink2, lineHeight: 1.45, maxWidth: 240, margin: '8px auto 22px' }}>
        Plant your first seed — even a half-formed thought counts.
      </div>
      <div style={{ display: 'inline-block' }}>
        <HiButton full={false} onClick={onPlant}>
          {Ico.plus('#fff', 18)}<span>Plant your first seed</span>
        </HiButton>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// TAB BAR — floating pill with center "Plant" FAB
// ═══════════════════════════════════════════════════════════════════════════
function HiTabBar({ active = 'ideas', onIdeas, onPlant, onSprint }) {
  const TabItem = ({ id, icon, label, onClick }) => {
    const on = active === id;
    return (
      <button onClick={onClick} style={{
        flex: 1, background: 'transparent', border: 'none', cursor: 'pointer',
        display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2,
        color: on ? HiT.moss : HiT.ink3, padding: '4px 0',
      }}>
        {icon(on ? HiT.moss : HiT.ink3, 20)}
        <span style={{ fontFamily: HiT.ui, fontSize: 10.5, fontWeight: 700, letterSpacing: 0.1 }}>{label}</span>
      </button>
    );
  };
  return (
    <div style={{
      position: 'absolute', bottom: 14, left: 14, right: 14,
      height: 68, borderRadius: 28,
      background: 'rgba(255,255,255,0.85)',
      backdropFilter: 'blur(16px)', WebkitBackdropFilter: 'blur(16px)',
      border: '1px solid rgba(15,28,21,0.06)',
      boxShadow: '0 12px 28px rgba(15,28,21,0.14), 0 2px 6px rgba(15,28,21,0.06)',
      display: 'flex', alignItems: 'center', padding: '0 6px',
      zIndex: 70,
    }}>
      <TabItem id="ideas"  icon={Ico.leaf}    label="Ideas"  onClick={onIdeas} />
      <button onClick={onPlant} style={{
        flex: '0 0 auto', margin: '0 6px',
        width: 56, height: 56, borderRadius: 999, border: 'none',
        background: HiT.moss, color: '#fff', cursor: 'pointer',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        boxShadow: '0 1px 0 rgba(255,255,255,0.20) inset, 0 -2px 0 rgba(0,0,0,0.18) inset, 0 8px 18px rgba(20,59,45,0.35)',
        transform: 'translateY(-10px)',
      }}>{Ico.plus('#fff', 26)}</button>
      <TabItem id="sprint" icon={Ico.target}  label="Sprint" onClick={onSprint} />
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// PLANT SEED — multi-step bottom sheet (carousel of 3 panels)
// ═══════════════════════════════════════════════════════════════════════════
function HiPlantSheet({ open, onClose, onSave }) {
  const [step, setStep] = React.useState(1);
  const [draft, setDraft] = React.useState({ cat: 'creator', hue: 'sage', title: '', body: '' });
  const [variant, setVariant] = React.useState('default'); // default | loading | fallback
  const [voice, setVoice] = React.useState(false);

  React.useEffect(() => {
    if (open) { setStep(1); setDraft({ cat: 'creator', hue: 'sage', title: '', body: '' }); setVariant('default'); setVoice(false); }
  }, [open]);

  const next = () => {
    if (step === 2) {
      setVariant('loading');
      setStep(3);
      setTimeout(() => setVariant('default'), 1800);
    } else {
      setStep(step + 1);
    }
  };
  const back = () => setStep(Math.max(1, step - 1));

  return (
    <BottomSheet open={open} onClose={onClose} height={760}>
      {/* sheet head */}
      <div style={{ padding: '8px 20px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12 }}>
        {step > 1
          ? <IconBtn icon={Ico.back(HiT.ink, 18)} onClick={back} size={36} />
          : <IconBtn icon={Ico.close(HiT.ink, 18)} onClick={onClose} size={36} />}
        <div style={{ flex: 1, display: 'flex', justifyContent: 'center' }}><StepDots step={step} total={3} /></div>
        <div style={{
          padding: '4px 10px', borderRadius: 999, background: HiT.mossSoft,
          fontFamily: HiT.ui, fontSize: 11, fontWeight: 700, color: HiT.mossDark, letterSpacing: 0.3,
        }}>{step} / 3</div>
      </div>

      {/* carousel */}
      <div style={{ flex: 1, overflow: 'hidden', position: 'relative' }}>
        <div style={{
          display: 'flex', width: '300%', height: '100%',
          transform: `translateX(${-(step - 1) * 33.333}%)`,
          transition: 'transform 0.32s cubic-bezier(0.16, 0.84, 0.36, 1)',
        }}>
          <Step1 draft={draft} setDraft={setDraft} />
          <Step2 draft={draft} setDraft={setDraft} voice={voice} setVoice={setVoice} />
          <Step3 draft={draft} variant={variant} setDraft={setDraft} />
        </div>
      </div>

      {/* footer */}
      <div style={{ padding: '12px 20px 18px', background: HiT.surface2 }}>
        {step < 3 ? (
          <HiButton onClick={next} disabled={step === 1 && !draft.title.trim()}>
            <span>{step === 1 ? 'Name it & continue' : 'Generate pathways'}</span>
            {Ico.arrowRight('#fff', 18)}
          </HiButton>
        ) : (
          <div style={{ display: 'flex', gap: 10, alignItems: 'center' }}>
            <button onClick={() => onSave(draft)} style={{
              background: 'transparent', border: 'none', cursor: 'pointer',
              color: HiT.ink2, fontFamily: HiT.ui, fontSize: 13.5, fontWeight: 600,
              padding: '0 4px',
            }}>Skip</button>
            <div style={{ flex: 1 }}>
              <HiButton onClick={() => onSave(draft)} kind="primary">
                <span>Save seed</span>
                {Ico.sprout('#fff', 18)}
              </HiButton>
            </div>
          </div>
        )}
      </div>
    </BottomSheet>
  );
}

function Step1({ draft, setDraft }) {
  return (
    <div style={{ width: '33.333%', flexShrink: 0, padding: '8px 20px 16px', overflow: 'hidden', display: 'flex', flexDirection: 'column', gap: 18 }}>
      <div>
        <div style={{ fontFamily: HiT.display, fontSize: 26, fontWeight: 600, letterSpacing: -0.7, color: HiT.ink }}>Plant a seed</div>
        <div style={{ fontFamily: HiT.ui, fontSize: 14, color: HiT.ink2, marginTop: 2 }}>Pick its shape, then give it a name.</div>
      </div>

      <div>
        <HiLabel style={{ marginBottom: 8 }}>Soil type</HiLabel>
        <CategoryPicker value={draft.cat} onChange={(c) => setDraft({ ...draft, cat: c })} />
      </div>

      <div>
        <HiLabel style={{ marginBottom: 8 }}>Botanical hue</HiLabel>
        <HuePicker value={draft.hue} onChange={(h) => setDraft({ ...draft, hue: h })} />
      </div>

      <div>
        <HiLabel style={{ marginBottom: 8 }}>Seed name</HiLabel>
        <input
          value={draft.title}
          onChange={(e) => setDraft({ ...draft, title: e.target.value })}
          autoFocus
          placeholder="e.g. Podcast hook ideas"
          style={{
            width: '100%', boxSizing: 'border-box',
            background: '#fff', borderRadius: 14, border: '1px solid rgba(15,28,21,0.10)',
            padding: '0 16px', height: 50,
            fontFamily: HiT.ui, fontSize: 15, color: HiT.ink, outline: 'none',
            boxShadow: '0 1px 3px rgba(15,28,21,0.04)',
          }} />
      </div>
    </div>
  );
}

function Step2({ draft, setDraft, voice, setVoice }) {
  return (
    <div style={{ width: '33.333%', flexShrink: 0, padding: '8px 20px 16px', overflow: 'hidden', display: 'flex', flexDirection: 'column', gap: 16 }}>
      <div>
        <div style={{ fontFamily: HiT.display, fontSize: 26, fontWeight: 600, letterSpacing: -0.7, color: HiT.ink }}>Tell its story</div>
        <div style={{ fontFamily: HiT.ui, fontSize: 14, color: HiT.ink2, marginTop: 2 }}>Type or speak — as much or little as you need.</div>
      </div>

      <textarea
        value={draft.body}
        onChange={(e) => setDraft({ ...draft, body: e.target.value })}
        placeholder="What's the idea?"
        style={{
          width: '100%', boxSizing: 'border-box',
          background: '#fff', borderRadius: 18, border: '1px solid rgba(15,28,21,0.10)',
          padding: 16, minHeight: 200,
          fontFamily: HiT.ui, fontSize: 15, color: HiT.ink, outline: 'none',
          resize: 'none', lineHeight: 1.55,
          boxShadow: '0 1px 3px rgba(15,28,21,0.04)',
        }} />

      {voice ? (
        <div style={{
          background: '#fff', borderRadius: 18, padding: 16,
          border: `1.5px solid ${HiT.amber}`,
          boxShadow: '0 6px 16px rgba(232,154,60,0.15)',
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 10 }}>
            <div style={{
              width: 36, height: 36, borderRadius: 999, background: HiT.amber,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              color: '#fff', animation: 'hi-pulse 1.4s ease-in-out infinite',
            }}>{Ico.mic('#fff', 18)}</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontFamily: HiT.ui, fontSize: 14, fontWeight: 700, color: HiT.ink }}>Listening…</div>
              <div style={{ fontFamily: HiT.ui, fontSize: 12, color: HiT.ink3, marginTop: 1 }}>Transcribing on-device</div>
            </div>
            <div style={{ color: HiT.amber }}>{Ico.wave(HiT.amber, 18)}</div>
          </div>
          <div style={{ display: 'flex', gap: 8 }}>
            <HiButton kind="soft" size="md" onClick={() => setVoice(false)}>Stop</HiButton>
            <HiButton kind="primary" size="md" onClick={() => setVoice(false)}>Finish & insert</HiButton>
          </div>
        </div>
      ) : (
        <button onClick={() => setVoice(true)} style={{
          background: '#fff', borderRadius: 18, padding: 14,
          border: '1px solid rgba(15,28,21,0.10)',
          display: 'flex', alignItems: 'center', gap: 12, cursor: 'pointer',
          textAlign: 'left', boxShadow: '0 1px 3px rgba(15,28,21,0.04)',
        }}>
          <div style={{
            width: 40, height: 40, borderRadius: 999,
            background: HiT.mossSoft, color: HiT.moss,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>{Ico.mic(HiT.moss, 18)}</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontFamily: HiT.ui, fontSize: 14, fontWeight: 700, color: HiT.ink }}>Use your voice</div>
            <div style={{ fontFamily: HiT.ui, fontSize: 12, color: HiT.ink2, marginTop: 1 }}>Tap and speak — we&rsquo;ll transcribe</div>
          </div>
          <div style={{ color: HiT.ink3 }}>{Ico.arrowRight(HiT.ink3, 16)}</div>
        </button>
      )}
    </div>
  );
}

function Step3({ draft, variant, setDraft }) {
  const pathways = [
    { id: 1, text: 'Turn each episode into a 60-second audio clip for Reels or Shorts.' },
    { id: 2, text: 'Pitch to 3 indie podcast networks first before launching solo.' },
    { id: 3, text: 'Create a Substack post to test the hook format cheaply.' },
  ];
  const [planted, setPlanted] = React.useState([]);
  const [flash, setFlash]     = React.useState(false);   // briefly highlight notes preview
  const notesRef = React.useRef(null);

  const plant = (p) => {
    if (planted.includes(p.id)) return;
    setPlanted((arr) => [...arr, p.id]);
    // Functional setDraft so concurrent taps don't drop appends.
    setDraft((d) => ({
      ...d,
      body: ((d.body || '').replace(/\s+$/, '') + (d.body ? '\n\n• ' : '• ') + p.text),
    }));
    setFlash(true);
    setTimeout(() => setFlash(false), 700);
    // Scroll preview to bottom on next paint so the new line is visible.
    requestAnimationFrame(() => {
      if (notesRef.current) notesRef.current.scrollTop = notesRef.current.scrollHeight;
    });
  };

  const wordCount = (draft.body || '').trim().split(/\s+/).filter(Boolean).length;

  return (
    <div style={{
      width: '33.333%', flexShrink: 0, padding: '8px 20px 0',
      overflow: 'hidden', display: 'flex', flexDirection: 'column', gap: 12,
      minWidth: 0, height: '100%', boxSizing: 'border-box',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, flexShrink: 0 }}>
        <div style={{ color: HiT.amber }}>{Ico.spark(HiT.amber, 22)}</div>
        <div>
          <div style={{ fontFamily: HiT.display, fontSize: 22, fontWeight: 600, letterSpacing: -0.5, color: HiT.ink }}>Pathways</div>
          <div style={{ fontFamily: HiT.ui, fontSize: 12.5, color: HiT.ink2 }}>Tap &ldquo;Plant this&rdquo; to weave one into your notes.</div>
        </div>
      </div>

      {/* SCROLLABLE pathway list */}
      <div style={{
        flex: 1, minHeight: 0, overflowY: 'auto',
        display: 'flex', flexDirection: 'column', gap: 8, paddingRight: 2,
      }}>
        {variant === 'loading' && <PathwaySkeletons />}

        {variant === 'fallback' && (
          <div style={{
            background: '#FCF5E8', borderRadius: 18, padding: 16,
            border: '1px solid #ECDDB6',
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 6 }}>
              <span style={{ fontSize: 18 }}>⚠️</span>
              <div style={{ fontFamily: HiT.ui, fontSize: 14, fontWeight: 700, color: '#7A4F12' }}>Pathways unavailable</div>
            </div>
            <div style={{ fontFamily: HiT.ui, fontSize: 13, color: '#7A4F12', lineHeight: 1.45 }}>
              Local model isn&rsquo;t ready. Save your seed anyway — you can ask the Garden later.
            </div>
          </div>
        )}

        {variant === 'default' && pathways.map((p, i) => {
          const on = planted.includes(p.id);
          return (
            <div key={p.id} style={{
              background: on ? HiT.hueSage : '#fff',
              borderRadius: 14, padding: '10px 12px',
              border: on ? '1.5px solid #7BB47A' : '1px solid rgba(15,28,21,0.08)',
              transition: 'all 0.25s',
              boxShadow: '0 1px 3px rgba(15,28,21,0.05)',
              display: 'flex', alignItems: 'flex-start', gap: 10,
            }}>
              <div style={{
                width: 24, height: 24, borderRadius: 7,
                background: on ? '#1F5C46' : HiT.mossSoft,
                color: on ? '#fff' : HiT.moss,
                display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
                fontFamily: HiT.display, fontSize: 12, fontWeight: 700, marginTop: 1,
              }}>{i + 1}</div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontFamily: HiT.ui, fontSize: 13.5, color: HiT.ink, lineHeight: 1.4, fontWeight: 500 }}>
                  {p.text}
                </div>
                <div style={{ marginTop: 6, display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 8 }}>
                  <span style={{
                    fontFamily: HiT.mono, fontSize: 9, fontWeight: 700,
                    padding: '2px 5px', borderRadius: 4,
                    background: HiT.mossSoft, color: HiT.mossDark, letterSpacing: 0.3,
                  }}>LOCAL</span>
                  <button onClick={() => plant(p)} disabled={on} style={{
                    height: 26, padding: '0 10px', borderRadius: 999, border: 'none',
                    background: on ? '#fff' : HiT.moss,
                    color: on ? HiT.mossDark : '#fff',
                    fontFamily: HiT.ui, fontSize: 11.5, fontWeight: 700,
                    cursor: on ? 'default' : 'pointer',
                    display: 'inline-flex', alignItems: 'center', gap: 4,
                    boxShadow: on ? 'none' : '0 2px 6px rgba(20,59,45,0.20)',
                    flexShrink: 0,
                  }}>
                    {on ? <>{Ico.check(HiT.mossDark, 12)}<span>Planted</span></> : <>{Ico.sprout('#fff', 12)}<span>Plant this</span></>}
                  </button>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* LIVE NOTES PREVIEW — editable, shows pathways being appended */}
      <div style={{
        flexShrink: 0, marginTop: 2, marginBottom: 14,
        background: '#fff', borderRadius: 16,
        border: flash ? `1.5px solid ${HiT.sprout}` : '1px solid rgba(15,28,21,0.10)',
        boxShadow: flash
          ? '0 0 0 4px rgba(103,178,126,0.18), 0 6px 14px rgba(15,28,21,0.06)'
          : '0 1px 3px rgba(15,28,21,0.05)',
        transition: 'border 0.25s, box-shadow 0.35s',
        overflow: 'hidden',
      }}>
        <div style={{
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          padding: '8px 12px 4px',
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            {Ico.edit(HiT.ink2, 13)}
            <span style={{ fontFamily: HiT.ui, fontSize: 10.5, fontWeight: 800, color: HiT.ink2, letterSpacing: 0.6, textTransform: 'uppercase' }}>Your seed notes</span>
          </div>
          <span style={{ fontFamily: HiT.ui, fontSize: 10.5, fontWeight: 600, color: HiT.ink3 }}>
            {wordCount} word{wordCount === 1 ? '' : 's'}
            {planted.length > 0 && <> · {planted.length} planted</>}
          </span>
        </div>
        <textarea
          ref={notesRef}
          value={draft.body || ''}
          onChange={(e) => setDraft({ ...draft, body: e.target.value })}
          placeholder="Your notes from Step 2 appear here. Tap a pathway above and watch it weave in."
          style={{
            width: '100%', boxSizing: 'border-box', display: 'block',
            background: 'transparent', border: 'none', outline: 'none', resize: 'none',
            padding: '2px 12px 12px',
            fontFamily: HiT.ui, fontSize: 13.5, color: HiT.ink, lineHeight: 1.5,
            height: 100, maxHeight: 100, overflowY: 'auto',
          }} />
      </div>
    </div>
  );
}

function PathwaySkeletons() {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
      {[0, 1, 2].map((i) => (
        <div key={i} style={{
          background: '#fff', borderRadius: 18, padding: 14,
          border: '1px solid rgba(15,28,21,0.06)',
          height: 84,
          background: 'linear-gradient(90deg, #fff 0%, #F1EBDC 50%, #fff 100%)',
          backgroundSize: '200% 100%',
          animation: 'hi-shimmer 1.6s ease-in-out infinite',
        }} />
      ))}
      <div style={{ textAlign: 'center', fontFamily: HiT.ui, fontSize: 12.5, color: HiT.ink2, marginTop: 4 }}>
        Growing pathways… 3–8s for the local model
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// SEED DETAIL — bottom sheet with sectioned tabs (no scroll if short)
// ═══════════════════════════════════════════════════════════════════════════
function HiDetailSheet({ open, idea, onClose, onAskGarden }) {
  const [tab, setTab] = React.useState('seed');
  const [title, setTitle] = React.useState('');
  const [body, setBody] = React.useState('');
  const [cat, setCat] = React.useState('quick');
  const [hue, setHue] = React.useState('mist');

  React.useEffect(() => {
    if (idea) { setTitle(idea.title); setBody(idea.body); setCat(idea.cat); setHue(idea.hue); setTab('seed'); }
  }, [idea]);

  if (!idea) return null;
  const H = HUE[hue];

  return (
    <BottomSheet open={open} onClose={onClose} height={760}>
      {/* head — hue strip */}
      <div style={{
        margin: '0 16px 8px', height: 96, borderRadius: HiT.rLg,
        background: H.bg, padding: 14, position: 'relative', overflow: 'hidden',
      }}>
        <div style={{ position: 'absolute', top: 6, right: 10, fontSize: 50, opacity: 0.25 }}>{CAT[cat].emoji}</div>
        <div style={{ display: 'inline-flex', alignItems: 'center', gap: 5,
          padding: '4px 10px', borderRadius: 999,
          background: 'rgba(255,255,255,0.7)', color: H.ink,
          fontFamily: HiT.ui, fontSize: 10.5, fontWeight: 800, letterSpacing: 0.5, textTransform: 'uppercase',
        }}>{CAT[cat].emoji} {CAT[cat].label}</div>
        <div style={{ fontFamily: HiT.display, fontSize: 19, fontWeight: 600, color: H.ink, marginTop: 8, letterSpacing: -0.3 }}>{title || 'Untitled'}</div>
      </div>

      {/* tab pills */}
      <div style={{ padding: '0 16px', display: 'flex', gap: 6, marginBottom: 6 }}>
        {[['seed','Seed'],['ai','Ask the Garden'],['style','Style']].map(([id, label]) => (
          <button key={id} onClick={() => setTab(id)} style={{
            flex: 1, height: 36, borderRadius: 11, border: 'none', cursor: 'pointer',
            background: tab === id ? HiT.moss : 'transparent',
            color: tab === id ? '#fff' : HiT.ink2,
            fontFamily: HiT.ui, fontSize: 12.5, fontWeight: 700, letterSpacing: -0.1,
            transition: 'all 0.15s',
          }}>{label}</button>
        ))}
      </div>

      {/* tab body */}
      <div style={{ flex: 1, overflowY: 'auto', padding: '8px 16px 14px' }}>
        {tab === 'seed' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            <input value={title} onChange={(e) => setTitle(e.target.value)} style={{
              width: '100%', boxSizing: 'border-box',
              background: '#fff', borderRadius: 14, border: '1px solid rgba(15,28,21,0.10)',
              padding: '0 16px', height: 48,
              fontFamily: HiT.display, fontSize: 17, fontWeight: 600, color: HiT.ink, outline: 'none',
              letterSpacing: -0.2,
            }} />
            <textarea value={body} onChange={(e) => setBody(e.target.value)} style={{
              width: '100%', boxSizing: 'border-box',
              background: '#fff', borderRadius: 16, border: '1px solid rgba(15,28,21,0.10)',
              padding: 14, minHeight: 220,
              fontFamily: HiT.ui, fontSize: 14.5, color: HiT.ink, outline: 'none',
              resize: 'none', lineHeight: 1.55,
            }} />
            <div style={{
              padding: 10, borderRadius: 10,
              background: HiT.mossSoft,
              fontFamily: HiT.ui, fontSize: 11.5, color: HiT.mossDark,
              display: 'flex', alignItems: 'center', gap: 6,
            }}>
              <span style={{ width: 6, height: 6, borderRadius: 999, background: HiT.sprout, animation: 'hi-pulse 1.4s ease-in-out infinite' }} />
              <span>Autosaving while you type</span>
            </div>
          </div>
        )}

        {tab === 'ai' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            <div style={{ display: 'flex', gap: 6 }}>
              {['Minimal', 'Standard', 'More help'].map((lv, i) => (
                <button key={lv} onClick={() => {}} style={{
                  flex: 1, height: 36, borderRadius: 10, border: 'none', cursor: 'pointer',
                  background: i === 1 ? '#fff' : 'rgba(255,255,255,0.5)',
                  color: HiT.ink, fontFamily: HiT.ui, fontSize: 12.5, fontWeight: 700,
                  boxShadow: i === 1 ? '0 2px 6px rgba(15,28,21,0.10)' : 'none',
                  border: i === 1 ? `1.5px solid ${HiT.moss}` : '1px solid rgba(15,28,21,0.08)',
                }}>{lv}</button>
              ))}
            </div>
            <HiButton onClick={onAskGarden}>
              {Ico.brain('#fff', 18)}<span>Ask the Garden</span>{Ico.spark('#fff', 16)}
            </HiButton>
            <div style={{
              background: '#fff', borderRadius: 16, padding: 14,
              border: '1px solid rgba(15,28,21,0.08)',
            }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 10 }}>
                <span style={{ fontFamily: HiT.mono, fontSize: 9.5, fontWeight: 700, padding: '2px 6px', borderRadius: 4, background: HiT.mossSoft, color: HiT.mossDark, letterSpacing: 0.3 }}>LOCAL</span>
                <span style={{ fontFamily: HiT.ui, fontSize: 11, color: HiT.ink3 }}>qwen3-0.6b · 2:34pm</span>
              </div>
              <Suggestion kind="Question"  text="What single metric tells you the hook worked?" />
              <Suggestion kind="Pathway"   text="Launch a 5-episode mini-season around one theme." />
              <Suggestion kind="Assumption" text="Users will tolerate a longer cold-open." />
            </div>
          </div>
        )}

        {tab === 'style' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 18 }}>
            <div>
              <HiLabel style={{ marginBottom: 8 }}>Soil type</HiLabel>
              <CategoryPicker value={cat} onChange={setCat} />
            </div>
            <div>
              <HiLabel style={{ marginBottom: 8 }}>Botanical hue</HiLabel>
              <HuePicker value={hue} onChange={setHue} />
            </div>
          </div>
        )}
      </div>

      {/* footer */}
      <div style={{ padding: '10px 16px 16px', background: HiT.surface2, borderTop: '1px solid rgba(15,28,21,0.06)' }}>
        <HiButton onClick={onClose}>
          <span>Save & close</span>
          {Ico.check('#fff', 18)}
        </HiButton>
      </div>
    </BottomSheet>
  );
}

function Suggestion({ kind, text }) {
  const colors = {
    Question:   { bg: '#E7F0F6', fg: '#214F86' },
    Pathway:    { bg: HiT.mossSoft, fg: HiT.mossDark },
    Assumption: { bg: '#F6E4C5', fg: '#7A4F12' },
  };
  const c = colors[kind];
  return (
    <div style={{ padding: '8px 0', borderTop: '1px dashed rgba(15,28,21,0.10)' }}>
      <div style={{
        display: 'inline-block',
        background: c.bg, color: c.fg,
        fontFamily: HiT.ui, fontSize: 10, fontWeight: 800, padding: '2px 6px', borderRadius: 4,
        textTransform: 'uppercase', letterSpacing: 0.4, marginBottom: 4,
      }}>{kind}</div>
      <div style={{ fontFamily: HiT.ui, fontSize: 13.5, color: HiT.ink, lineHeight: 1.45 }}>{text}</div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// SEARCH SHEET — small overlay with query input + chips
// ═══════════════════════════════════════════════════════════════════════════
function HiSearchSheet({ open, onClose, onApply, initial = '' }) {
  const [q, setQ] = React.useState(initial);
  React.useEffect(() => { if (open) setQ(initial); }, [open, initial]);

  return (
    <BottomSheet open={open} onClose={onClose} height={420}>
      <div style={{ padding: '4px 20px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{ fontFamily: HiT.display, fontSize: 22, fontWeight: 600, letterSpacing: -0.4 }}>Search seeds</div>
        <IconBtn icon={Ico.close(HiT.ink, 18)} onClick={onClose} size={36} />
      </div>
      <div style={{ padding: '16px 20px', display: 'flex', flexDirection: 'column', gap: 12 }}>
        <div style={{
          display: 'flex', alignItems: 'center', gap: 10,
          background: '#fff', borderRadius: 14, padding: '0 16px', height: 50,
          border: `1.5px solid ${HiT.moss}`, boxShadow: '0 6px 16px rgba(20,59,45,0.10)',
        }}>
          {Ico.search(HiT.moss, 18)}
          <input value={q} onChange={(e) => setQ(e.target.value)} autoFocus
            placeholder="title or body…"
            style={{ flex: 1, border: 'none', outline: 'none', fontFamily: HiT.ui, fontSize: 15, color: HiT.ink, background: 'transparent' }}
            onKeyDown={(e) => { if (e.key === 'Enter') onApply(q); }} />
          {q && <button onClick={() => setQ('')} style={{ background: 'transparent', border: 'none', cursor: 'pointer', color: HiT.ink3 }}>{Ico.close(HiT.ink3, 16)}</button>}
        </div>

        <HiLabel>Recent</HiLabel>
        <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
          {['podcast', 'pop-up', 'newsletter', 'fitness'].map((r) => (
            <button key={r} onClick={() => { setQ(r); }} style={{
              padding: '8px 12px', borderRadius: 999, border: '1px solid rgba(15,28,21,0.10)',
              background: '#fff', color: HiT.ink,
              fontFamily: HiT.ui, fontSize: 12.5, fontWeight: 600, cursor: 'pointer',
            }}>{r}</button>
          ))}
        </div>

        <HiButton onClick={() => onApply(q)}>Search</HiButton>
      </div>
    </BottomSheet>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// DAILY SPRINT — full screen, no scrolling.  Tap to play, type to add,
// sprouts pop in tiny pills, celebration on complete.
// ═══════════════════════════════════════════════════════════════════════════
function HiSprint({ entries, setEntries, onClose, onBack, onComplete }) {
  const goal = 10;
  const [input, setInput] = React.useState('');
  const [pops, setPops] = React.useState([]); // {id, text}
  const [celebrate, setCelebrate] = React.useState(false);
  const isComplete = entries.length >= goal;
  const pct = Math.min(100, (entries.length / goal) * 100);

  const add = () => {
    if (!input.trim() || isComplete) return;
    const e = { id: Date.now() + Math.random(), text: input.trim() };
    setEntries((arr) => {
      const next = [...arr, e];
      if (next.length >= goal) {
        setTimeout(() => { setCelebrate(true); onComplete && onComplete(); }, 240);
      }
      return next;
    });
    setPops((arr) => [...arr, { id: e.id, text: e.text }]);
    setTimeout(() => setPops((arr) => arr.filter((p) => p.id !== e.id)), 900);
    setInput('');
  };

  return (
    <div style={{
      flex: 1, display: 'flex', flexDirection: 'column', position: 'relative',
      background: 'linear-gradient(180deg, #143B2D 0%, #0E2A20 100%)',
      color: '#fff', overflow: 'hidden',
    }}>
      {/* decorative paperclip */}
      <div style={{
        position: 'absolute', right: -30, top: 70, opacity: 0.08, transform: 'rotate(15deg)',
        color: '#A6E5C9',
      }}>{Ico.paperclip('#A6E5C9', 240)}</div>

      {/* nav */}
      <div style={{
        padding: '56px 18px 8px', display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        zIndex: 2,
      }}>
        <IconBtn icon={Ico.back('#fff', 18)} onClick={onBack || onClose} size={40} style={{ background: 'rgba(255,255,255,0.12)', color: '#fff' }} />
        <div style={{
          padding: '6px 12px', borderRadius: 999,
          background: 'rgba(166,229,201,0.18)',
          fontFamily: HiT.ui, fontSize: 12, fontWeight: 700, color: '#A6E5C9', letterSpacing: 0.3,
        }}>Day {7} · Daily Sprint</div>
        <div style={{ width: 40 }} />
      </div>

      {/* hero: object */}
      <div style={{ padding: '10px 24px 18px', textAlign: 'center', zIndex: 2 }}>
        <div style={{ fontFamily: HiT.ui, fontSize: 12, fontWeight: 700, color: '#A6E5C9', letterSpacing: 1, textTransform: 'uppercase' }}>Today&rsquo;s object</div>
        <div style={{ fontFamily: HiT.display, fontSize: 64, fontWeight: 600, letterSpacing: -2, lineHeight: 1, marginTop: 6 }}>Paperclip</div>
        <div style={{ fontFamily: HiT.ui, fontSize: 14, color: 'rgba(255,255,255,0.6)', marginTop: 6, lineHeight: 1.4 }}>
          List as many alternate uses as you can. <br/>10 minutes · 10 ideas to complete.
        </div>
      </div>

      {/* progress ring of sprout pips */}
      <div style={{ padding: '0 24px 14px', zIndex: 2 }}>
        <div style={{
          display: 'flex', gap: 6, justifyContent: 'space-between',
          background: 'rgba(0,0,0,0.18)', padding: 12, borderRadius: 16,
          border: '1px solid rgba(166,229,201,0.15)',
        }}>
          {Array.from({ length: goal }).map((_, i) => {
            const on = i < entries.length;
            return (
              <div key={i} style={{
                width: 26, height: 26, borderRadius: 999,
                background: on ? '#A6E5C9' : 'rgba(255,255,255,0.08)',
                color: on ? '#143B2D' : 'rgba(255,255,255,0.35)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontFamily: HiT.display, fontSize: 12, fontWeight: 700,
                transition: 'all 0.3s',
                transform: on ? 'scale(1)' : 'scale(0.85)',
                boxShadow: on ? '0 4px 10px rgba(166,229,201,0.4)' : 'none',
              }}>{on ? Ico.sprout('#143B2D', 13) : i + 1}</div>
            );
          })}
        </div>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 10 }}>
          <div style={{ fontFamily: HiT.ui, fontSize: 12, color: 'rgba(255,255,255,0.55)' }}>
            <b style={{ color: '#A6E5C9', fontFamily: HiT.display, fontSize: 16 }}>{entries.length}</b>
            <span> / {goal} sprouts</span>
          </div>
          <div style={{ fontFamily: HiT.ui, fontSize: 12, color: 'rgba(255,255,255,0.55)' }}>{Math.round(pct)}%</div>
        </div>
      </div>

      {/* spacer pushes input to bottom */}
      <div style={{ flex: 1, position: 'relative', zIndex: 2 }}>
        {/* floating sprout pops */}
        <div style={{ position: 'absolute', inset: 0, pointerEvents: 'none', overflow: 'hidden' }}>
          {pops.map((p) => (
            <div key={p.id} style={{
              position: 'absolute', bottom: 30, left: '50%',
              transform: 'translateX(-50%)',
              animation: 'hi-sproutpop 0.9s ease forwards',
              background: '#A6E5C9', color: '#143B2D',
              padding: '6px 14px', borderRadius: 999,
              fontFamily: HiT.ui, fontSize: 13, fontWeight: 700, whiteSpace: 'nowrap',
              maxWidth: 280, overflow: 'hidden', textOverflow: 'ellipsis',
              boxShadow: '0 6px 14px rgba(166,229,201,0.4)',
              display: 'inline-flex', alignItems: 'center', gap: 5,
            }}>{Ico.sprout('#143B2D', 14)}<span>{p.text}</span></div>
          ))}
        </div>

        {/* latest 3 entries peek */}
        <div style={{
          position: 'absolute', left: 24, right: 24, bottom: 0,
          display: 'flex', flexDirection: 'column', gap: 6,
        }}>
          {entries.slice(-3).reverse().map((e, idx) => (
            <div key={e.id} style={{
              padding: '8px 12px', borderRadius: 12,
              background: 'rgba(255,255,255,0.06)',
              color: 'rgba(255,255,255,0.75)',
              fontFamily: HiT.ui, fontSize: 13,
              opacity: 1 - idx * 0.25,
              display: 'flex', alignItems: 'center', gap: 8,
            }}>
              <span style={{ color: '#A6E5C9', fontFamily: HiT.display, fontWeight: 700, fontSize: 12 }}>
                {entries.length - idx}.
              </span>
              <span style={{ flex: 1, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{e.text}</span>
            </div>
          ))}
        </div>
      </div>

      {/* INPUT BAR */}
      <div style={{
        padding: '12px 18px 30px', zIndex: 3,
        background: 'linear-gradient(180deg, rgba(14,42,32,0) 0%, #0E2A20 40%)',
      }}>
        <div style={{
          display: 'flex', gap: 8, alignItems: 'center',
          background: 'rgba(255,255,255,0.95)', borderRadius: 18, padding: 6,
          boxShadow: '0 14px 28px rgba(0,0,0,0.20)',
        }}>
          <input value={input} onChange={(e) => setInput(e.target.value)}
            disabled={isComplete}
            onKeyDown={(e) => { if (e.key === 'Enter') add(); }}
            placeholder={isComplete ? 'Sprint complete! Tap to see sprouts.' : 'Use it as a…'}
            style={{
              flex: 1, border: 'none', outline: 'none',
              fontFamily: HiT.ui, fontSize: 15, color: HiT.ink,
              padding: '0 12px', height: 44, background: 'transparent',
            }} />
          <button onClick={add} disabled={!input.trim() || isComplete} style={{
            height: 44, width: 44, borderRadius: 14, border: 'none',
            background: !input.trim() || isComplete ? '#C9D2CC' : HiT.moss,
            color: '#fff', cursor: !input.trim() || isComplete ? 'not-allowed' : 'pointer',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: !input.trim() || isComplete ? 'none' : '0 4px 12px rgba(20,59,45,0.30)',
          }}>{Ico.plus('#fff', 22)}</button>
        </div>
      </div>

      {/* CELEBRATION SHEET */}
      {celebrate && <CelebrateModal entries={entries} onClose={() => setCelebrate(false)} onDone={onClose} />}
    </div>
  );
}

function CelebrateModal({ entries, onClose, onDone }) {
  // confetti dots
  const dots = React.useMemo(() => Array.from({ length: 30 }).map((_, i) => ({
    id: i, x: Math.random() * 100, d: Math.random() * 0.6, c: [HiT.amber, HiT.sprout, HiT.blush, '#A6E5C9'][i % 4],
    s: 6 + Math.random() * 6, r: Math.random() * 360,
  })), []);

  return (
    <div style={{ position: 'absolute', inset: 0, zIndex: 300 }}>
      {/* confetti */}
      <div style={{ position: 'absolute', inset: 0, overflow: 'hidden', pointerEvents: 'none' }}>
        {dots.map((d) => (
          <div key={d.id} style={{
            position: 'absolute', left: `${d.x}%`, top: -20,
            width: d.s, height: d.s, borderRadius: d.id % 2 ? 999 : 2,
            background: d.c, transform: `rotate(${d.r}deg)`,
            animation: `hi-confetti 2.2s ease-in ${d.d}s forwards`,
          }} />
        ))}
      </div>

      <div onClick={onClose} style={{
        position: 'absolute', inset: 0,
        background: 'rgba(11,30,22,0.78)', backdropFilter: 'blur(10px)',
      }} />

      <div style={{
        position: 'absolute', left: 16, right: 16, bottom: 36,
        background: HiT.surface2, borderRadius: 28, padding: 24,
        animation: 'hi-popin 0.45s cubic-bezier(0.34, 1.56, 0.64, 1) both',
        boxShadow: '0 24px 48px rgba(0,0,0,0.4)',
      }}>
        <div style={{
          width: 72, height: 72, margin: '0 auto 14px',
          borderRadius: 24,
          background: 'linear-gradient(135deg, #FFC678 0%, #E89A3C 100%)',
          color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
          boxShadow: '0 12px 28px rgba(232,154,60,0.45)',
        }}>{Ico.trophy('#fff', 38)}</div>

        <div style={{ textAlign: 'center', fontFamily: HiT.display, fontSize: 30, fontWeight: 600, letterSpacing: -0.8, color: HiT.ink }}>
          Sprint complete!
        </div>
        <div style={{ textAlign: 'center', fontFamily: HiT.ui, fontSize: 14, color: HiT.ink2, marginTop: 4 }}>
          You planted {entries.length} sprouts today.
        </div>

        <div style={{
          margin: '16px 0', padding: '12px 14px',
          background: '#fff', borderRadius: 16,
          border: '1px solid rgba(15,28,21,0.06)',
          display: 'flex', alignItems: 'center', gap: 14,
        }}>
          <div style={{
            width: 44, height: 44, borderRadius: 12, background: HiT.mossSoft,
            color: HiT.moss, display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>{Ico.spark(HiT.amber, 22)}</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontFamily: HiT.ui, fontSize: 12, fontWeight: 700, color: HiT.ink3, letterSpacing: 0.4, textTransform: 'uppercase' }}>Earned</div>
            <div style={{ fontFamily: HiT.display, fontSize: 18, fontWeight: 600, color: HiT.ink, marginTop: 1 }}>+30 XP · 🔥 streak +1</div>
          </div>
        </div>

        {/* sprouts collected */}
        <div style={{ maxHeight: 130, overflowY: 'auto', marginBottom: 14, paddingRight: 4 }}>
          <ol style={{ margin: 0, padding: 0, listStyle: 'none' }}>
            {entries.map((e, i) => (
              <li key={e.id} style={{
                display: 'flex', gap: 8, padding: '5px 0',
                borderBottom: i < entries.length - 1 ? '1px solid rgba(15,28,21,0.06)' : 'none',
                fontFamily: HiT.ui, fontSize: 13, color: HiT.ink,
              }}>
                <span style={{ color: HiT.moss, fontWeight: 700, minWidth: 18 }}>{i + 1}.</span>
                <span>{e.text}</span>
              </li>
            ))}
          </ol>
        </div>

        <HiButton kind="primary" onClick={onDone}>
          <span>Back to garden</span>
          {Ico.arrowRight('#fff', 18)}
        </HiButton>
      </div>
    </div>
  );
}

Object.assign(window, {
  HI_SEEDS, HiEntry, HiHome, HiTabBar,
  HiPlantSheet, HiDetailSheet, HiSearchSheet, HiSprint,
});
