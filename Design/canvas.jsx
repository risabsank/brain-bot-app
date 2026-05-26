// canvas.jsx — Lays out all screens + annotations into a DesignCanvas.

const { useState, useCallback } = React;

// Side annotation panel next to a phone. Width 300, matches phone height (852).
function AnnoPanel({ title, frame, children, footer }) {
  return (
    <div style={{
      width: 300, height: 852,
      background: '#FAF8F3',
      borderRadius: 10,
      border: '1px solid rgba(26,31,28,0.10)',
      padding: 18,
      display: 'flex', flexDirection: 'column',
      fontFamily: T.font,
      boxSizing: 'border-box',
    }}>
      <div style={{
        fontFamily: T.fontMono, fontSize: 10.5, color: T.ink3,
        letterSpacing: 0.3, marginBottom: 4,
      }}>{frame}</div>
      <div style={{
        fontSize: 16, fontWeight: 700, color: T.ink, letterSpacing: -0.2,
        marginBottom: 12, lineHeight: 1.25,
      }}>{title}</div>
      <div style={{ flex: 1, overflowY: 'auto', paddingRight: 4 }}>
        {children}
      </div>
      {footer && (
        <div style={{
          marginTop: 10, paddingTop: 10,
          borderTop: '1px solid rgba(26,31,28,0.10)',
          fontFamily: T.fontMono, fontSize: 10.5, color: T.ink3,
        }}>{footer}</div>
      )}
    </div>
  );
}

// Compose phone + side annotation panel inside one artboard.
function PhoneWithAnno({ phone, anno }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'flex-start', gap: 28,
      padding: 24,
      width: 745, height: 900,
      background: '#F4F1EC',
      boxSizing: 'border-box',
    }}>
      <div style={{ flexShrink: 0 }}>{phone}</div>
      <div style={{ flexShrink: 0 }}>{anno}</div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// Interactive prototype — single phone wired with state. Lives in its own
// artboard so reviewers can click through Flows A/B/C without leaving the
// canvas.
// ═══════════════════════════════════════════════════════════════════════════
function InteractivePrototype() {
  const [scene, setScene] = useState('entry'); // entry | ideas | plant | detail | sprint
  const [step, setStep]   = useState(1);
  const [draft, setDraft] = useState({ cat: 'quick', hue: 'mist', title: '', body: '' });
  const [selectedIdea, setSelectedIdea] = useState(null);
  const [sprintState, setSprintState]   = useState('progress');

  const goTab = useCallback((id) => {
    if (id === 'ideas') setScene('ideas');
    if (id === 'plant') { setScene('plant'); setStep(1); }
    if (id === 'sprint') setScene('sprint');
  }, []);

  const handleSave = () => {
    setScene('ideas');
    setDraft({ cat: 'quick', hue: 'mist', title: '', body: '' });
  };

  let phone = null;
  if (scene === 'entry') {
    phone = <EntryGateScreen onContinue={() => setScene('ideas')} />;
  } else if (scene === 'ideas') {
    phone = (
      <IdeasScreen
        state="default"
        onTab={goTab}
        onSelect={(i) => { setSelectedIdea(i); setScene('detail'); }}
        onPlant={() => { setScene('plant'); setStep(1); }}
      />
    );
  } else if (scene === 'plant') {
    phone = (
      <PlantSeedScreen
        step={step}
        variant="default"
        onStep={setStep}
        onTab={goTab}
        draft={draft}
        setDraft={setDraft}
        onSave={handleSave}
      />
    );
  } else if (scene === 'detail') {
    phone = (
      <SeedDetailScreen
        idea={selectedIdea}
        onBack={() => setScene('ideas')}
        onTab={goTab}
      />
    );
  } else if (scene === 'sprint') {
    phone = <DailySprintScreen state={sprintState} onTab={goTab} onComplete={() => setSprintState('complete')} />;
  }

  return (
    <div style={{
      width: 745, height: 900,
      background: 'linear-gradient(160deg, #EFE7DA 0%, #DDE6DE 100%)',
      padding: 24, boxSizing: 'border-box',
      display: 'flex', flexDirection: 'column', gap: 16,
    }}>
      <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between' }}>
        <div>
          <div style={{ fontFamily: T.fontMono, fontSize: 11, color: T.ink3, letterSpacing: 0.4 }}>00_LIVE_PROTOTYPE</div>
          <div style={{ fontFamily: T.font, fontSize: 18, fontWeight: 700, color: T.ink, marginTop: 2 }}>Tap through the flows</div>
          <div style={{ fontFamily: T.font, fontSize: 12.5, color: T.ink2, marginTop: 2, maxWidth: 420, lineHeight: 1.45 }}>
            Live state — search, filters, multi-step capture, sprint progress all wired. Try Flow A: <i>Entry → Plant Seed → Save</i>.
          </div>
        </div>

        {/* Quick scene jump */}
        <div style={{
          display: 'flex', flexDirection: 'column', gap: 4,
          background: 'rgba(255,255,255,0.55)', borderRadius: 12, padding: 8,
          border: '1px solid rgba(26,31,28,0.08)',
        }}>
          {[
            ['entry',  '1. Entry Gate'],
            ['ideas',  '2. Ideas'],
            ['plant',  '3. Plant Seed'],
            ['detail', '4. Seed Detail'],
            ['sprint', '5. Daily Sprint'],
          ].map(([id, label]) => {
            const on = scene === id;
            return (
              <button key={id} onClick={() => { setScene(id); if (id === 'plant') setStep(1); }} style={{
                padding: '5px 12px', borderRadius: 7, border: 'none', cursor: 'pointer',
                background: on ? T.brand : 'transparent',
                color: on ? '#fff' : T.ink,
                fontFamily: T.font, fontSize: 12, fontWeight: 600,
                textAlign: 'left', minWidth: 130,
              }}>{label}</button>
            );
          })}
          {scene === 'sprint' && (
            <div style={{
              marginTop: 4, paddingTop: 6,
              borderTop: '1px solid rgba(26,31,28,0.08)',
              display: 'flex', gap: 4,
            }}>
              {['empty', 'progress', 'complete'].map((s) => (
                <button key={s} onClick={() => setSprintState(s)} style={{
                  flex: 1, padding: '3px 6px', borderRadius: 5, border: 'none', cursor: 'pointer',
                  background: sprintState === s ? T.ink : 'rgba(26,31,28,0.06)',
                  color: sprintState === s ? '#fff' : T.ink2,
                  fontFamily: T.font, fontSize: 10, fontWeight: 600,
                }}>{s}</button>
              ))}
            </div>
          )}
        </div>
      </div>

      <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        {phone}
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// Annotation panels — content for each screen
// ═══════════════════════════════════════════════════════════════════════════
const Annos = {
  entry: (
    <AnnoPanel frame="01_EntryGate/Default" title="Entry Gate" footer="Spacing: 24pt H · 32pt subtitle↔CTA">
      <Anno s="imp" label="Wordmark">Brand rename Brain Bot → Idea Garden. Sprout glyph + serif/rounded title.</Anno>
      <Anno s="imp" label="Value subtitle">Replace &ldquo;Capture ideas fast&rdquo; with the gardening metaphor.</Anno>
      <Anno s="imp" label="Continue CTA">Reuses existing <code>isSignedIn</code> toggle. 52pt tall, rounded-14, full-width.</Anno>
      <Anno s="ph"  label="Auth note">Real email/password auth out of MVP scope. Demo sign-in only.</Anno>
    </AnnoPanel>
  ),

  ideasDefault: (
    <AnnoPanel frame="02_Ideas/Default" title="Ideas — Garden Feed" footer="Sticky header + scrollable grid (Session 4)">
      <Anno s="ph"  label="App title + sprout">Wordmark in header. Pin streak badge to top-right.</Anno>
      <Anno s="fut" label="Streak badge (3🔥)">Surfaces removed Activity tab data. Full Activity view = MVP Future.</Anno>
      <Anno s="imp" label="Search bar">Persistent, custom field — drop <code>.searchable</code> so it can pin.</Anno>
      <Anno s="imp" label="Filter chips">Active = filled brand-green; inactive = outlined. &ldquo;For You&rdquo; pre-selected.</Anno>
      <Anno s="imp" label="Seed Card grid">2-col <code>LazyVGrid</code>. Header lives ABOVE the ScrollView so only cards scroll.</Anno>
      <Anno s="imp" label="Card anatomy">14pt padding · r:18 · category tag · name · 3-line body · optional audio row.</Anno>
      <Anno s="imp" label="Hue backgrounds">Mist · Sage · Paper · Night → maps to <code>IdeaVisualStyle</code>.</Anno>
    </AnnoPanel>
  ),

  ideasEmpty: (
    <AnnoPanel frame="02_Ideas/EmptyState" title="Ideas — Empty Garden" footer="Component: Global_EmptyState_Garden">
      <Anno s="imp" label="Illustration">Sprout glyph in a brand-soft chip. No custom artwork needed.</Anno>
      <Anno s="imp" label="Empty copy">&ldquo;Your garden is empty. Plant your first seed.&rdquo;</Anno>
      <Anno s="imp" label="CTA → Plant Seed tab">Switches active tab to Plant Seed (does not nav-push).</Anno>
    </AnnoPanel>
  ),

  ideasSearch: (
    <AnnoPanel frame="02_Ideas/SearchActive" title="Ideas — Search Active" footer="Live: type to filter">
      <Anno s="imp" label="Focused search ring">Soft brand halo on focus.</Anno>
      <Anno s="imp" label="Live filter">Matches across title + body. Chips stay above the result count.</Anno>
      <Anno s="imp" label="No-results state">Component: Global_EmptyState_Search. Shows the query string in quotes.</Anno>
    </AnnoPanel>
  ),

  plantStep1: (
    <AnnoPanel frame="03_PlantSeed/Step1_Metadata" title="Plant Seed · Step 1" footer="Total height fits iPhone 14 Pro w/o scroll">
      <Anno s="imp" label="Back + title + dots">3-dot progress indicator (Placeholder for behavior only).</Anno>
      <Anno s="imp" label="Soil Type">Maps to <code>IdeaCategory</code> — Quick Win · Long Term · Creator Mode · Experiment.</Anno>
      <Anno s="imp" label="Botanical Hues">Maps to <code>IdeaVisualStyle</code>. Renamed label only — Mist · Sage · Paper · Night.</Anno>
      <Anno s="imp" label="Seed Name field">Maps to <code>title</code>. Required.</Anno>
      <Anno s="ph"  label="Next CTA gate">Disabled until Seed Name has ≥1 non-whitespace char.</Anno>
      <Anno s="ph"  label="Live preview card">Reflects type + hue choice in real time. Not in spec — proposed.</Anno>
    </AnnoPanel>
  ),

  plantStep2: (
    <AnnoPanel frame="03_PlantSeed/Step2_Notes" title="Plant Seed · Step 2" footer="Voice expands to inline recorder">
      <Anno s="imp" label="Seed Notes editor">Maps to <code>body</code>. Min height 160pt. Optional — Next stays enabled.</Anno>
      <Anno s="imp" label="Voice Input — collapsed">Single tappable row, reduces visual noise vs. always-on recorder.</Anno>
      <Anno s="imp" label="Voice — recording state">Pulsing dot · waveform · Stop/Finish · &ldquo;Transcribing…&rdquo; spinner.</Anno>
      <Anno s="imp" label="Autosave on Next">Draft persisted at every step transition.</Anno>
    </AnnoPanel>
  ),

  plantStep3: (
    <AnnoPanel frame="03_PlantSeed/Step3_Pathways" title="Plant Seed · Step 3" footer="NEW — not yet in codebase">
      <Anno s="s5" label="AI Pathways header">New step. Sparkle icon + subtitle quoting the seed name.</Anno>
      <Anno s="s5" label="Pathway cards (3–5)">Each: source badge · quoted suggestion · &ldquo;Plant this&rdquo; secondary CTA.</Anno>
      <Anno s="s5" label="&ldquo;Plant this&rdquo;">Appends pathway text into the draft <code>body</code> string.</Anno>
      <Anno s="imp" label="AI source badge">Reuse existing Local/Cloud labeling on each card.</Anno>
      <Anno s="ph"  label="Save Seed CTA">Fires <code>store.autosaveIdea()</code> → navigates to Ideas tab.</Anno>
      <Anno s="ph"  label="Skip link">Saves without pathways and exits the flow.</Anno>
    </AnnoPanel>
  ),

  plantStep3Loading: (
    <AnnoPanel frame="03_PlantSeed/Step3_Loading" title="Pathways · Loading" footer="3–8s on local LLM (qwen3-0.6b)">
      <Anno s="s5" label="Loading card">Dashed border placeholder · spinner · &ldquo;Growing pathways…&rdquo; copy.</Anno>
      <Anno s="ph" label="Timing copy">Sets expectations: this is a local model, not an API.</Anno>
      <Anno s="ph" label="Skip remains live">User can opt out at any moment.</Anno>
    </AnnoPanel>
  ),

  plantStep3Fallback: (
    <AnnoPanel frame="03_PlantSeed/Step3_Fallback" title="Pathways · Fallback" footer="Component: PlantSeed_PathwayCard_Fallback">
      <Anno s="imp" label="Fallback card">Amber warn tone. Tells user the local model isn&rsquo;t ready.</Anno>
      <Anno s="imp" label="Save Seed still primary">Don&rsquo;t block save on AI failure. The seed still saves.</Anno>
      <Anno s="s5"  label="Retry from Detail">Detail screen lets the user ask the Garden when model is back.</Anno>
    </AnnoPanel>
  ),

  detail: (
    <AnnoPanel frame="04_SeedDetail/Default" title="Seed Detail / Edit" footer="Autosave: 700ms debounce">
      <Anno s="imp" label="Editable Seed Name">Maps to <code>title</code>. Falls back to &ldquo;Untitled idea&rdquo; on empty save.</Anno>
      <Anno s="imp" label="Editable Details">Maps to <code>body</code>. Multi-line TextEditor, min 140pt.</Anno>
      <Anno s="imp" label="Soil Type segmented">Tap to switch category. All four options always visible.</Anno>
      <Anno s="imp" label="Botanical Hue picker">Menu picker — shows current hue swatch + label.</Anno>
      <Anno s="imp" label="Help-level selector">Minimal · Standard · More help. Drives <code>IdeaAssistantService</code>.</Anno>
      <Anno s="imp" label="Ask the Garden">Renamed CTA (was &ldquo;Brain Button&rdquo;). Calls <code>generateSuggestions(for:)</code>.</Anno>
      <Anno s="imp" label="Previous results">AssistanceResultsView — Question · Pathway · Assumption + source badge.</Anno>
      <Anno s="imp" label="Autosave note">Footer: &ldquo;Changes autosave while you type.&rdquo;</Anno>
    </AnnoPanel>
  ),

  sprintPre: (
    <AnnoPanel frame="05_DailySprint/PreCompletion" title="Daily Sprint · In Progress" footer="Sprouts locked until ≥10 entries">
      <Anno s="imp" label="Object + prompt">Driven by <code>AlternateUsesChallenge.today()</code>.</Anno>
      <Anno s="imp" label="Progress bar + label">Brand green fill. &ldquo;5 of 10 ideas&rdquo;.</Anno>
      <Anno s="imp" label="Input + Add">Pressing Return or Add submits. Adds to <code>store.dailyEntries</code>.</Anno>
      <Anno s="s5"  label="Sprouts locked">Conditional render via <code>isComplete</code> computed var.</Anno>
      <Anno s="s5"  label="Locked copy">&ldquo;Complete your sprint to reveal sprouts.&rdquo; with lock icon.</Anno>
    </AnnoPanel>
  ),

  sprintEmpty: (
    <AnnoPanel frame="05_DailySprint/EmptyStart" title="Daily Sprint · Empty Start" footer="No entries yet">
      <Anno s="imp" label="Progress at 0">Bar is empty; copy reads &ldquo;0 of 10 ideas&rdquo;.</Anno>
      <Anno s="s5"  label="Sprouts placeholder">Show locked card with no-lock variant: &ldquo;Add your first idea above.&rdquo;</Anno>
      <Anno s="imp" label="Add button — disabled empty">Active when input has ≥1 non-whitespace char.</Anno>
    </AnnoPanel>
  ),

  sprintPost: (
    <AnnoPanel frame="05_DailySprint/PostCompletion" title="Daily Sprint · Complete" footer="Reveal animation: fade-in 400ms">
      <Anno s="imp" label="Sprint card → green fill">Visual reward when progress hits 1.0.</Anno>
      <Anno s="s5"  label="Sprouts reveal">Section animates in. Numbered list with count badge.</Anno>
      <Anno s="ph"  label="Input becomes optional">Disabled by default; tap to add more (does NOT change completion).</Anno>
      <Anno s="fut" label="Streak ++">Increments the Ideas-tab streak badge on next visit.</Anno>
    </AnnoPanel>
  ),
};

// ═══════════════════════════════════════════════════════════════════════════
// Annotation legend artboard
// ═══════════════════════════════════════════════════════════════════════════
function LegendArtboard() {
  return (
    <div style={{
      width: 1020, height: 520,
      background: '#FAF8F3', borderRadius: 4,
      padding: 32, boxSizing: 'border-box',
      fontFamily: T.font, color: T.ink,
      display: 'flex', flexDirection: 'column', gap: 16,
    }}>
      <div>
        <div style={{ fontFamily: T.fontMono, fontSize: 11, color: T.ink3, letterSpacing: 0.5 }}>READ_ME · IDEA GARDEN WIREFRAME</div>
        <div style={{ fontSize: 26, fontWeight: 700, marginTop: 4, letterSpacing: -0.4 }}>Idea Garden — Session 5 wireframe</div>
        <div style={{ fontSize: 14, color: T.ink2, lineHeight: 1.5, marginTop: 6, maxWidth: 720 }}>
          App rename: <b>Brain Bot → Idea Garden</b>. iPhone-only, iOS 17+, portrait. Low-to-mid fidelity:
          grayscale layouts with the four Botanical Hue card backgrounds applied. Tap a frame title to open it
          fullscreen (Esc to exit). The live prototype artboard on the right is fully wired.
        </div>
      </div>

      <div style={{
        display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 16,
        background: '#fff', borderRadius: 10, padding: 18,
        border: '1px solid rgba(26,31,28,0.08)',
      }}>
        {Object.entries(STATUS).map(([k, v]) => (
          <div key={k} style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
            <Tag s={k}>{v.label}</Tag>
            <div style={{ fontSize: 12, color: T.ink2, lineHeight: 1.45 }}>
              {k === 'imp' && 'Already exists in the app. Just needs renaming or restyling.'}
              {k === 'ph'  && 'Wired up but not fully working yet.'}
              {k === 'fut' && 'Planned but not built. Not in MVP.'}
              {k === 's5'  && 'New idea not yet in the codebase (especially AI Pathways).'}
            </div>
          </div>
        ))}
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 16, flex: 1 }}>
        <FlowCard title="Flow A · Plant a seed" steps={[
          'Entry Gate → Continue',
          'Plant Seed tab',
          'Step 1: type · hue · name',
          'Step 2: write notes',
          'Step 3: AI pathways (optional)',
          'Save → new card in Ideas',
        ]} />
        <FlowCard title="Flow B · Find & edit" steps={[
          'Ideas tab',
          'Tap search → type query',
          'Tap a seed card',
          'Seed Detail opens',
          'Edit · autosave 700ms',
          'Back → updated card',
        ]} />
        <FlowCard title="Flow C · Daily Sprint" steps={[
          'Daily Sprint tab',
          'See today\u2019s object',
          'Submit ideas one by one',
          'Progress fills (10 entries)',
          'Sprint completes',
          'Sprouts list reveals',
        ]} />
      </div>
    </div>
  );
}

function FlowCard({ title, steps }) {
  return (
    <div style={{
      background: '#fff', borderRadius: 10, padding: 14,
      border: '1px solid rgba(26,31,28,0.08)',
      fontFamily: T.font,
    }}>
      <div style={{ fontSize: 13, fontWeight: 700, color: T.ink, marginBottom: 8 }}>{title}</div>
      <ol style={{ margin: 0, padding: 0, listStyle: 'none' }}>
        {steps.map((s, i) => (
          <li key={i} style={{ display: 'flex', gap: 8, padding: '3px 0', fontSize: 12, color: T.ink2, lineHeight: 1.4 }}>
            <span style={{ color: T.brand, fontWeight: 700, minWidth: 16 }}>{i + 1}.</span>
            <span>{s}</span>
          </li>
        ))}
      </ol>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// Stateful artboards (small wrappers so each shows the right initial state)
// ═══════════════════════════════════════════════════════════════════════════
function StaticIdeasScreen({ state, query }) {
  return <IdeasScreen state={state} query={query} />;
}
function StaticPlant({ step, variant, draft }) {
  return <PlantSeedScreen step={step} variant={variant} draft={draft || { cat: 'creator', hue: 'sage', title: 'Podcast hook ideas', body: 'Open each episode with a 20-second true story before the lesson.' }} setDraft={() => {}} />;
}
function StaticSprint({ state }) { return <DailySprintScreen state={state} />; }
function StaticDetail() { return <SeedDetailScreen idea={SEED_IDEAS[0]} />; }

// ═══════════════════════════════════════════════════════════════════════════
// Root
// ═══════════════════════════════════════════════════════════════════════════
function App() {
  return (
    <DesignCanvas>
      <DCSection id="overview" title="Overview" subtitle="Wireframe map · annotation legend · interactive prototype">
        <DCArtboard id="legend" label="Read me · status legend · flows" width={1020} height={520}>
          <LegendArtboard />
        </DCArtboard>
        <DCArtboard id="proto" label="00 · Interactive prototype" width={745} height={900}>
          <InteractivePrototype />
        </DCArtboard>
      </DCSection>

      <DCSection id="entry" title="01 — Entry Gate" subtitle="First impression · brand moment">
        <DCArtboard id="entry-default" label="01_EntryGate/Default" width={745} height={900}>
          <PhoneWithAnno
            phone={<EntryGateScreen />}
            anno={Annos.entry}
          />
        </DCArtboard>
      </DCSection>

      <DCSection id="ideas" title="02 — Ideas (Garden Feed)" subtitle="Sticky header · scrolling 2-col grid · empty + search states">
        <DCArtboard id="ideas-default" label="02_Ideas/Default" width={745} height={900}>
          <PhoneWithAnno phone={<StaticIdeasScreen state="default" />} anno={Annos.ideasDefault} />
        </DCArtboard>
        <DCArtboard id="ideas-search" label="02_Ideas/SearchActive" width={745} height={900}>
          <PhoneWithAnno phone={<StaticIdeasScreen state="search" query="podcast" />} anno={Annos.ideasSearch} />
        </DCArtboard>
        <DCArtboard id="ideas-empty" label="02_Ideas/EmptyState" width={745} height={900}>
          <PhoneWithAnno phone={<StaticIdeasScreen state="empty" />} anno={Annos.ideasEmpty} />
        </DCArtboard>
      </DCSection>

      <DCSection id="plant" title="03 — Plant Seed" subtitle="Guided 3-step capture · replaces single-form CaptureIdeaView">
        <DCArtboard id="plant-1" label="03_PlantSeed/Step1_Metadata" width={745} height={900}>
          <PhoneWithAnno
            phone={<StaticPlant step={1} variant="default" draft={{ cat: 'creator', hue: 'sage', title: '', body: '' }} />}
            anno={Annos.plantStep1}
          />
        </DCArtboard>
        <DCArtboard id="plant-2" label="03_PlantSeed/Step2_Notes" width={745} height={900}>
          <PhoneWithAnno
            phone={<StaticPlant step={2} variant="default" draft={{ cat: 'creator', hue: 'sage', title: 'Podcast hook ideas', body: 'Open each episode with a 20-second true story before the lesson.\n\nHard-cut to the host\u2019s key question.' }} />}
            anno={Annos.plantStep2}
          />
        </DCArtboard>
        <DCArtboard id="plant-2-voice" label="03_PlantSeed/Step2_VoiceActive" width={745} height={900}>
          <PhoneWithAnno
            phone={<StaticPlant step={2} variant="voice" draft={{ cat: 'creator', hue: 'sage', title: 'Podcast hook ideas', body: 'Open each episode with a 20-second…' }} />}
            anno={Annos.plantStep2}
          />
        </DCArtboard>
        <DCArtboard id="plant-3" label="03_PlantSeed/Step3_Pathways" width={745} height={900}>
          <PhoneWithAnno
            phone={<StaticPlant step={3} variant="default" draft={{ cat: 'creator', hue: 'sage', title: 'Podcast hook ideas', body: '' }} />}
            anno={Annos.plantStep3}
          />
        </DCArtboard>
        <DCArtboard id="plant-3-loading" label="03_PlantSeed/Step3_Loading" width={745} height={900}>
          <PhoneWithAnno
            phone={<StaticPlant step={3} variant="loading" draft={{ cat: 'creator', hue: 'sage', title: 'Podcast hook ideas' }} />}
            anno={Annos.plantStep3Loading}
          />
        </DCArtboard>
        <DCArtboard id="plant-3-fallback" label="03_PlantSeed/Step3_Fallback" width={745} height={900}>
          <PhoneWithAnno
            phone={<StaticPlant step={3} variant="fallback" draft={{ cat: 'creator', hue: 'sage', title: 'Podcast hook ideas' }} />}
            anno={Annos.plantStep3Fallback}
          />
        </DCArtboard>
      </DCSection>

      <DCSection id="detail" title="04 — Seed Detail / Edit" subtitle="Opens on card tap · all fields editable · autosave">
        <DCArtboard id="detail-default" label="04_SeedDetail/Default" width={745} height={900}>
          <PhoneWithAnno phone={<StaticDetail />} anno={Annos.detail} />
        </DCArtboard>
      </DCSection>

      <DCSection id="sprint" title="05 — Daily Sprint" subtitle="Alternate Uses Challenge · Sprouts locked until completion">
        <DCArtboard id="sprint-empty" label="05_DailySprint/EmptyStart" width={745} height={900}>
          <PhoneWithAnno phone={<StaticSprint state="empty" />} anno={Annos.sprintEmpty} />
        </DCArtboard>
        <DCArtboard id="sprint-progress" label="05_DailySprint/PreCompletion" width={745} height={900}>
          <PhoneWithAnno phone={<StaticSprint state="progress" />} anno={Annos.sprintPre} />
        </DCArtboard>
        <DCArtboard id="sprint-complete" label="05_DailySprint/PostCompletion" width={745} height={900}>
          <PhoneWithAnno phone={<StaticSprint state="complete" />} anno={Annos.sprintPost} />
        </DCArtboard>
      </DCSection>
    </DesignCanvas>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
