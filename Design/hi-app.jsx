// hi-app.jsx — root app, state, tweaks panel wiring.

const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "accent":         "moss",
  "vibe":           "warm",
  "showStreak":     true,
  "celebrateOnComplete": true,
  "startScene":     "entry"
}/*EDITMODE-END*/;

function HiApp() {
  const [t, setTweak] = useTweaks(TWEAK_DEFAULTS);

  // App state
  const [scene, setScene]   = React.useState(t.startScene || 'entry');     // entry | home | sprint
  const [plantOpen, setPlantOpen]     = React.useState(false);
  const [detailOpen, setDetailOpen]   = React.useState(false);
  const [searchOpen, setSearchOpen]   = React.useState(false);
  const [activeSeed, setActiveSeed]   = React.useState(null);
  const [query, setQuery]             = React.useState('');

  // Gamification state
  const [xp, setXp]               = React.useState(64);
  const [level, setLevel]         = React.useState(3);
  const [streak, setStreak]       = React.useState(t.showStreak ? 7 : 0);
  const [sproutsToday, setToday]  = React.useState(2);
  const [xpEvents, setXpEvents]   = React.useState([]); // floaters

  // Sprint state — outside Sprint component so it survives leaving
  const [sprintEntries, setSprintEntries] = React.useState([
    { id: 1, text: 'Use as a bookmark' },
    { id: 2, text: 'Mini cable organizer' },
    { id: 3, text: 'Earring back' },
    { id: 4, text: 'Plant label stake' },
    { id: 5, text: 'Reset button for sunglasses screws' },
  ]);

  // sync start scene from tweaks
  React.useEffect(() => { if (t.startScene) setScene(t.startScene); }, [t.startScene]);

  const grantXp = (amount, kind) => {
    const id = Date.now() + Math.random();
    setXpEvents((arr) => [...arr, { id, amount, kind }]);
    setTimeout(() => setXpEvents((arr) => arr.filter((e) => e.id !== id)), 1400);
    setXp((v) => {
      const nv = v + amount;
      if (nv >= 100) { setLevel((L) => L + 1); return nv - 100; }
      return nv;
    });
  };

  const handleSave = (draft) => {
    setPlantOpen(false);
    grantXp(15, 'plant');
    setToday((n) => n + 1);
  };

  const handleSprintComplete = () => {
    if (!t.celebrateOnComplete) return;
    grantXp(30, 'sprint');
    setStreak((s) => s + 0); // already counted today
  };

  return (
    <HiPhone>
      {scene === 'entry' && <HiEntry onContinue={() => setScene('home')} />}

      {scene === 'home' && (
        <HiHome
          onOpenSeed={(s) => { setActiveSeed(s); setDetailOpen(true); }}
          onPlant={() => setPlantOpen(true)}
          onSprint={() => setScene('sprint')}
          onSearch={() => setSearchOpen(true)}
          query={query}
          xp={xp} level={level}
          streak={t.showStreak ? streak : 0}
          sproutsToday={sproutsToday}
        />
      )}

      {scene === 'sprint' && (
        <HiSprint
          entries={sprintEntries}
          setEntries={setSprintEntries}
          onClose={() => setScene('home')}
          onBack={() => setScene('home')}
          onComplete={handleSprintComplete}
        />
      )}

      <HiPlantSheet open={plantOpen} onClose={() => setPlantOpen(false)} onSave={handleSave} />
      <HiDetailSheet open={detailOpen} idea={activeSeed} onClose={() => { setDetailOpen(false); grantXp(5, 'tend'); }} onAskGarden={() => grantXp(2, 'ask')} />
      <HiSearchSheet open={searchOpen} onClose={() => setSearchOpen(false)} initial={query}
        onApply={(q) => { setQuery(q); setSearchOpen(false); }} />

      <XpFloater events={xpEvents} />
    </HiPhone>
  );
}

// ─────────────────────────────────────────────────────────────────────────
// Page shell — centers the phone on a warm canvas, adds Tweaks.
// ─────────────────────────────────────────────────────────────────────────
function PageShell() {
  const [t, setTweak] = useTweaks(TWEAK_DEFAULTS);

  // Apply vibe → body background
  React.useEffect(() => {
    const bgs = {
      warm:    'radial-gradient(120% 80% at 50% 0%, #F2E6CB 0%, #E8D9B6 60%, #DDC9A0 100%)',
      cool:    'radial-gradient(120% 80% at 50% 0%, #E0EEE9 0%, #C7DCD2 60%, #B5CFC2 100%)',
      blossom: 'radial-gradient(120% 80% at 50% 0%, #F5E0DB 0%, #ECC6BC 60%, #DDA89A 100%)',
      dusk:    'radial-gradient(120% 80% at 50% 0%, #2C3A33 0%, #1B2A22 60%, #11201A 100%)',
    };
    document.body.style.background = bgs[t.vibe] || bgs.warm;
  }, [t.vibe]);

  return (
    <>
      <div style={{
        minHeight: '100vh', width: '100%',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        padding: '40px 20px', boxSizing: 'border-box',
        position: 'relative',
      }}>
        {/* subtle scene label */}
        <div style={{
          position: 'absolute', top: 24, left: 24,
          fontFamily: HiT.ui, fontSize: 11.5, fontWeight: 700,
          color: t.vibe === 'dusk' ? 'rgba(255,255,255,0.6)' : 'rgba(20,40,30,0.5)',
          letterSpacing: 0.6, textTransform: 'uppercase',
        }}>Idea Garden · Hi-Fi prototype</div>

        <HiApp />
      </div>

      <TweaksPanel title="Tweaks">
        <TweakSection label="Theme">
          <TweakRadio label="Vibe" value={t.vibe}
            options={[
              { label: 'Warm',    value: 'warm'    },
              { label: 'Cool',    value: 'cool'    },
              { label: 'Blossom', value: 'blossom' },
              { label: 'Dusk',    value: 'dusk'    },
            ]}
            onChange={(v) => setTweak('vibe', v)} />
        </TweakSection>

        <TweakSection label="Gamification">
          <TweakToggle label="Show streak pill"          value={t.showStreak}          onChange={(v) => setTweak('showStreak', v)} />
          <TweakToggle label="Celebrate on sprint done"  value={t.celebrateOnComplete} onChange={(v) => setTweak('celebrateOnComplete', v)} />
        </TweakSection>

        <TweakSection label="Quick jump">
          <TweakRadio label="Start at" value={t.startScene}
            options={[
              { label: 'Entry',  value: 'entry'  },
              { label: 'Home',   value: 'home'   },
              { label: 'Sprint', value: 'sprint' },
            ]}
            onChange={(v) => setTweak('startScene', v)} />
        </TweakSection>
      </TweaksPanel>
    </>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<PageShell />);
