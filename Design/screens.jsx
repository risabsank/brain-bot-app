// screens.jsx — All 5 screens of the Idea Garden wireframe + state variants.

// Seed dataset for feed previews
const SEED_IDEAS = [
  { id: 's1', cat: 'quick',   hue: 'mist',  title: 'Podcast hook ideas',     body: 'Open each episode with a 20-second true story before the lesson.', audio: false },
  { id: 's2', cat: 'exper',   hue: 'sage',  title: 'Weekend pop-up cart',    body: 'Test a one-day iced tea cart at the farmer\u2019s market this Saturday.', audio: false },
  { id: 's3', cat: 'long',    hue: 'paper', title: 'Fitness challenge mini-app', body: '7-day bodyweight series with a streak ring and one daily prompt.', audio: false },
  { id: 's4', cat: 'quick',   hue: 'sage',  title: 'Newsletter growth',      body: 'Offer one practical PDF in exchange for a referral. Track conversion.', audio: true },
  { id: 's5', cat: 'creator', hue: 'night', title: 'Studio visit series',    body: 'Short documentary visits to local artists\u2019 workshops, one per month.', audio: false },
  { id: 's6', cat: 'exper',   hue: 'mist',  title: 'Slow recipe video',      body: 'Single static shot, ASMR audio, no narration. 90 seconds end-to-end.', audio: false },
];

// ═══════════════════════════════════════════════════════════════════════════
// 1. ENTRY GATE
// ═══════════════════════════════════════════════════════════════════════════
function EntryGateScreen({ onContinue }) {
  return (
    <Phone bg="#F0EBE2">
      {/* subtle organic background motif */}
      <div style={{ position: 'absolute', inset: 0, overflow: 'hidden', pointerEvents: 'none' }}>
        <svg width="100%" height="100%" viewBox="0 0 393 852" style={{ position: 'absolute', inset: 0 }}>
          <defs>
            <radialGradient id="vig" cx="50%" cy="20%" r="70%">
              <stop offset="0%"  stopColor="#E2EBE4" stopOpacity="0.7"/>
              <stop offset="100%" stopColor="#E2EBE4" stopOpacity="0"/>
            </radialGradient>
          </defs>
          <rect width="393" height="852" fill="url(#vig)"/>
        </svg>
      </div>

      <div style={{ flex: 1, padding: '120px 32px 0', position: 'relative', zIndex: 1, display: 'flex', flexDirection: 'column' }}>
        {/* wordmark */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 22 }}>
          <div style={{
            width: 44, height: 44, borderRadius: 14, background: T.brand,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>{Icon.sprout('#F0EBE2', 24)}</div>
          <div style={{
            fontFamily: T.font, fontSize: 30, fontWeight: 700,
            color: T.brand, letterSpacing: -0.6,
          }}>Idea Garden</div>
        </div>

        <div style={{
          fontFamily: T.font, fontSize: 19, fontWeight: 400,
          color: T.ink2, lineHeight: 1.4, letterSpacing: -0.2,
          marginTop: 4, maxWidth: 280,
        }}>Your garden for growing ideas into action.</div>

        <div style={{ flex: 1 }} />

        <div style={{ marginBottom: 14 }}>
          <PrimaryButton onClick={onContinue}>Continue</PrimaryButton>
        </div>

        <div style={{
          textAlign: 'center', padding: '0 20px 28px',
          fontFamily: T.font, fontSize: 11.5, color: T.ink3, lineHeight: 1.5,
        }}>MVP uses a demo sign-in. Real auth attaches later.</div>
      </div>
    </Phone>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 2. IDEAS TAB — Garden Feed
// ═══════════════════════════════════════════════════════════════════════════
function IdeasScreen({ state = 'default', onSelect, onTab, onPlant, query: initialQuery = '' }) {
  const [chip, setChip] = React.useState('for-you');
  const [query, setQuery] = React.useState(initialQuery);

  const allIdeas = SEED_IDEAS;
  const ideas = (() => {
    if (state === 'empty') return [];
    let list = allIdeas;
    if (state === 'search' || query) {
      const q = (state === 'search' ? 'podcast' : query).toLowerCase();
      list = list.filter((i) => (i.title + i.body).toLowerCase().includes(q));
    }
    if (chip === 'quick')    list = list.filter((i) => i.cat === 'quick');
    if (chip === 'exper')    list = list.filter((i) => i.cat === 'exper');
    if (chip === 'creator')  list = list.filter((i) => i.cat === 'creator');
    if (chip === 'long')     list = list.filter((i) => i.cat === 'long');
    return list;
  })();

  const showSearch = state === 'search' || query.length > 0;

  return (
    <Phone>
      {/* STICKY HEADER ZONE — does NOT scroll */}
      <div style={{ flexShrink: 0, background: T.bg, paddingBottom: 12, borderBottom: `1px solid ${T.line}` }}>
        {/* title + streak */}
        <div style={{
          paddingTop: 56, paddingLeft: 20, paddingRight: 20, paddingBottom: 10,
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <div style={{ color: T.brand }}>{Icon.sprout(T.brand, 22)}</div>
            <div style={{
              fontFamily: T.font, fontSize: 26, fontWeight: 700,
              color: T.ink, letterSpacing: -0.5,
            }}>Idea Garden</div>
          </div>
          <div style={{
            display: 'inline-flex', alignItems: 'center', gap: 4,
            padding: '4px 10px', borderRadius: 999,
            background: '#fff', border: `1px solid ${T.line}`,
            fontFamily: T.font, fontSize: 12, fontWeight: 600, color: T.ink,
          }}>{Icon.flame('#D87C2A', 12)}<span>3</span></div>
        </div>

        {/* search bar */}
        <div style={{ padding: '0 16px 10px' }}>
          <div style={{
            display: 'flex', alignItems: 'center', gap: 8,
            background: '#fff', borderRadius: 11, padding: '8px 12px',
            border: `1px solid ${T.line}`,
            boxShadow: showSearch ? `0 0 0 2px ${T.brandSoft}` : 'none',
          }}>
            {Icon.search(T.ink3, 16)}
            <input
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Search seeds..."
              style={{
                flex: 1, border: 'none', outline: 'none', background: 'transparent',
                fontFamily: T.font, fontSize: 15, color: T.ink, padding: 0,
              }} />
            {showSearch && (
              <button onClick={() => setQuery('')} style={{
                border: 'none', background: 'transparent', cursor: 'pointer',
                color: T.ink3, padding: 0, fontSize: 14,
              }}>×</button>
            )}
          </div>
        </div>

        {/* filter chips */}
        <div style={{ padding: '0 16px', display: 'flex', gap: 8, overflowX: 'auto' }}>
          <Chip active={chip === 'for-you'} onClick={() => setChip('for-you')}>For You</Chip>
          <Chip active={chip === 'quick'}   onClick={() => setChip('quick')}>Quick Wins</Chip>
          <Chip active={chip === 'exper'}   onClick={() => setChip('exper')}>Experiments</Chip>
          <Chip active={chip === 'creator'} onClick={() => setChip('creator')}>Creator</Chip>
        </div>
      </div>

      {/* SCROLL ZONE — grid only */}
      <div style={{ flex: 1, overflowY: 'auto', padding: 16 }}>
        {ideas.length === 0 ? (
          <EmptyState
            kind={showSearch ? 'search' : 'garden'}
            query={query || (state === 'search' ? 'podcast' : '')}
            onAction={onPlant}
          />
        ) : (
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            {ideas.map((i) => <SeedCard key={i.id} idea={i} onClick={() => onSelect && onSelect(i)} />)}
          </div>
        )}
      </div>

      <TabBar active="ideas" onSelect={onTab} />
    </Phone>
  );
}

function EmptyState({ kind = 'garden', query = '', onAction }) {
  if (kind === 'garden') {
    return (
      <div style={{ textAlign: 'center', padding: '60px 24px 0' }}>
        <div style={{
          width: 88, height: 88, margin: '0 auto 18px',
          borderRadius: 24, background: T.brandSoft,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>{Icon.sprout(T.brand, 38)}</div>
        <div style={{
          fontFamily: T.font, fontSize: 19, fontWeight: 700, color: T.ink,
          marginBottom: 6,
        }}>Your garden is empty</div>
        <div style={{
          fontFamily: T.font, fontSize: 14, color: T.ink2, lineHeight: 1.45,
          maxWidth: 260, margin: '0 auto 22px',
        }}>Plant your first seed — write down an idea, no matter how small.</div>
        <div style={{ display: 'inline-block' }}>
          <PrimaryButton full={false} onClick={onAction}>
            {Icon.plusCircle('#fff', 18)} Plant Seed
          </PrimaryButton>
        </div>
      </div>
    );
  }
  return (
    <div style={{ textAlign: 'center', padding: '60px 24px 0' }}>
      <div style={{
        width: 72, height: 72, margin: '0 auto 14px',
        borderRadius: 999, background: '#fff', border: `1px solid ${T.line}`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>{Icon.search(T.ink3, 28)}</div>
      <div style={{
        fontFamily: T.font, fontSize: 17, fontWeight: 700, color: T.ink,
        marginBottom: 6,
      }}>No seeds match &ldquo;{query}&rdquo;</div>
      <div style={{
        fontFamily: T.font, fontSize: 13.5, color: T.ink2,
        maxWidth: 240, margin: '0 auto',
      }}>Try different words, or plant a new seed.</div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 3. PLANT SEED — multi-step
// ═══════════════════════════════════════════════════════════════════════════
function PlantSeedScreen({ step = 1, variant = 'default', onStep, onTab, draft, setDraft, onSave }) {
  const d = draft || { cat: 'quick', hue: 'mist', title: '', body: '' };
  const setD = setDraft || (() => {});

  return (
    <Phone>
      <PhoneTopBar
        left={step > 1 ? <BackButton onClick={() => onStep && onStep(step - 1)} /> : <span />}
        center="Plant a Seed"
        right={<ProgressDots step={step} total={3} />}
      />

      <div style={{ flex: 1, overflowY: 'auto', padding: '8px 20px 20px' }}>
        {step === 1 && <PlantStep1 d={d} setD={setD} />}
        {step === 2 && <PlantStep2 d={d} setD={setD} variant={variant} />}
        {step === 3 && <PlantStep3 d={d} setD={setD} variant={variant} />}
      </div>

      {/* Footer CTA bar */}
      <div style={{
        padding: '12px 20px 16px', background: T.bg,
        borderTop: `1px solid ${T.line}`,
        display: 'flex', flexDirection: 'column', gap: 8,
      }}>
        {step < 3 ? (
          <PrimaryButton
            onClick={() => onStep && onStep(step + 1)}
            disabled={step === 1 && !d.title.trim()}>
            Next →
          </PrimaryButton>
        ) : (
          <>
            <PrimaryButton onClick={onSave}>
              Save Seed {Icon.sprout('#fff', 16)}
            </PrimaryButton>
            <button onClick={onSave} style={{
              background: 'transparent', border: 'none', cursor: 'pointer',
              color: T.ink2, fontFamily: T.font, fontSize: 13, fontWeight: 500,
              alignSelf: 'flex-end', padding: 0,
            }}>Skip →</button>
          </>
        )}
      </div>

      <TabBar active="plant" onSelect={onTab} />
    </Phone>
  );
}

function PlantStep1({ d, setD }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 22, paddingTop: 8 }}>
      {/* Soil Type */}
      <div>
        <SectionLabel>Soil Type</SectionLabel>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
          {Object.entries(CATEGORIES).map(([k, C]) => {
            const sel = d.cat === k;
            return (
              <button key={k} onClick={() => setD({ ...d, cat: k })} style={{
                display: 'flex', alignItems: 'center', gap: 8,
                padding: '12px 12px',
                borderRadius: 12, cursor: 'pointer',
                background: sel ? T.brand : '#fff',
                color: sel ? '#fff' : T.ink,
                border: sel ? 'none' : `1px solid ${T.line}`,
                fontFamily: T.font, fontSize: 13, fontWeight: 600,
              }}>
                {C.icon(sel ? '#fff' : T.brand, 16)}
                <span>{C.label}</span>
              </button>
            );
          })}
        </div>
      </div>

      {/* Botanical Hues */}
      <div>
        <SectionLabel>Botanical Hues</SectionLabel>
        <div style={{ display: 'flex', gap: 8 }}>
          {Object.keys(HUES).map((h) => (
            <HueSwatch key={h} hue={h} selected={d.hue === h} onClick={() => setD({ ...d, hue: h })} />
          ))}
        </div>
      </div>

      {/* Seed Name */}
      <div>
        <SectionLabel>Seed Name</SectionLabel>
        <input
          value={d.title}
          onChange={(e) => setD({ ...d, title: e.target.value })}
          placeholder="What are you planting?"
          style={{
            width: '100%', boxSizing: 'border-box',
            background: '#fff', borderRadius: 12,
            border: `1px solid ${T.line}`,
            padding: '0 14px', height: 50,
            fontFamily: T.font, fontSize: 15, color: T.ink, outline: 'none',
          }} />
        {!d.title.trim() && (
          <div style={{
            marginTop: 8, fontFamily: T.font, fontSize: 11.5, color: T.ink3,
            display: 'flex', alignItems: 'center', gap: 6,
          }}>
            {Icon.warn(T.ink3, 12)}
            <span>Add a name to continue.</span>
          </div>
        )}
      </div>

      {/* Live preview */}
      <div>
        <SectionLabel>Preview</SectionLabel>
        <div style={{ width: '60%' }}>
          <SeedCard idea={{
            cat: d.cat, hue: d.hue,
            title: d.title || 'Untitled seed',
            body: 'Your notes will appear here once you write them in the next step.',
          }} />
        </div>
      </div>
    </div>
  );
}

function PlantStep2({ d, setD, variant }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 22, paddingTop: 8 }}>
      <div>
        <SectionLabel>Seed Notes</SectionLabel>
        <textarea
          value={d.body}
          onChange={(e) => setD({ ...d, body: e.target.value })}
          placeholder="What's the idea? Add as much or little as you need."
          style={{
            width: '100%', boxSizing: 'border-box',
            background: '#fff', borderRadius: 12,
            border: `1px solid ${T.line}`,
            padding: 14, minHeight: 180,
            fontFamily: T.font, fontSize: 14, color: T.ink, outline: 'none',
            resize: 'none', lineHeight: 1.5,
          }} />
      </div>

      {/* Voice input section */}
      <div>
        <SectionLabel>Voice Input <span style={{ color: T.ink3, textTransform: 'none', letterSpacing: 0, fontWeight: 500 }}>(optional)</span></SectionLabel>

        {variant === 'voice' ? (
          <div style={{
            background: '#fff', borderRadius: 12, padding: 14,
            border: `1px solid ${T.line}`,
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 10 }}>
              <div style={{
                width: 10, height: 10, borderRadius: 999, background: '#D6533B',
                boxShadow: '0 0 0 3px rgba(214,83,59,0.18)',
              }} />
              <div style={{ flex: 1, fontFamily: T.font, fontSize: 13.5, color: T.ink, fontWeight: 600 }}>Recording — tap Stop to pause</div>
              <div style={{ color: T.brand }}>{Icon.wave(T.brand, 18)}</div>
            </div>
            <div style={{ display: 'flex', gap: 8, marginBottom: 8 }}>
              <SecondaryButton>Stop</SecondaryButton>
              <SecondaryButton>Finish Session</SecondaryButton>
            </div>
            <div style={{ fontFamily: T.font, fontSize: 12, color: T.ink3, display: 'flex', alignItems: 'center', gap: 6 }}>
              <div style={{
                width: 12, height: 12, borderRadius: 999, border: `1.5px solid ${T.ink3}`, borderTopColor: 'transparent',
                animation: 'ig-spin 0.8s linear infinite',
              }} />
              <span>Transcribing…</span>
            </div>
          </div>
        ) : (
          <button style={{
            width: '100%', background: '#fff', borderRadius: 12,
            border: `1px solid ${T.line}`,
            padding: '14px 14px',
            display: 'flex', alignItems: 'center', gap: 10,
            cursor: 'pointer', textAlign: 'left',
          }}>
            <div style={{
              width: 32, height: 32, borderRadius: 999, background: T.brandSoft,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              color: T.brand, flexShrink: 0,
            }}>{Icon.mic(T.brand, 16)}</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontFamily: T.font, fontSize: 14, fontWeight: 600, color: T.ink }}>Start voice session</div>
              <div style={{ fontFamily: T.font, fontSize: 12, color: T.ink3, marginTop: 1 }}>Speak the idea — we&rsquo;ll transcribe.</div>
            </div>
            {Icon.chevR(T.ink3, 14)}
          </button>
        )}
      </div>
    </div>
  );
}

function PlantStep3({ d, variant }) {
  const pathways = [
    { id: 1, text: 'Turn each episode into a 60-second audio clip for Reels or Shorts.', source: 'Local' },
    { id: 2, text: 'Pitch to 3 indie podcast networks first before launching solo.',     source: 'Local' },
    { id: 3, text: 'Create a Substack post to test the hook format cheaply.',           source: 'Local' },
  ];

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 16, paddingTop: 8 }}>
      <div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 4 }}>
          <div style={{ color: T.brand }}>{Icon.spark(T.brand, 16)}</div>
          <div style={{ fontFamily: T.font, fontSize: 13, fontWeight: 700, color: T.brand, letterSpacing: 0.8, textTransform: 'uppercase' }}>AI Pathways</div>
        </div>
        <div style={{ fontFamily: T.font, fontSize: 14, color: T.ink2, lineHeight: 1.45 }}>Here are some directions for &ldquo;{d.title || 'your seed'}&rdquo; to grow:</div>
      </div>

      {variant === 'loading' && (
        <div style={{
          background: '#fff', borderRadius: 14, padding: 22,
          border: `1px dashed ${T.line2}`,
          display: 'flex', alignItems: 'center', gap: 12,
        }}>
          <div style={{
            width: 22, height: 22, borderRadius: 999,
            border: `2.4px solid ${T.line2}`, borderTopColor: T.brand,
            animation: 'ig-spin 0.9s linear infinite',
          }} />
          <div>
            <div style={{ fontFamily: T.font, fontSize: 14, fontWeight: 600, color: T.ink }}>Growing pathways…</div>
            <div style={{ fontFamily: T.font, fontSize: 12, color: T.ink3, marginTop: 2 }}>3–8 sec for the local model.</div>
          </div>
        </div>
      )}

      {variant === 'fallback' && (
        <div style={{
          background: '#FCF5E8', borderRadius: 14, padding: 16,
          border: '1px solid #ECDDB6',
          display: 'flex', gap: 12,
        }}>
          <div style={{ color: '#A8721C', flexShrink: 0, marginTop: 1 }}>{Icon.warn('#A8721C', 18)}</div>
          <div>
            <div style={{ fontFamily: T.font, fontSize: 14, fontWeight: 700, color: '#7A4F12' }}>Pathways unavailable</div>
            <div style={{ fontFamily: T.font, fontSize: 13, color: '#7A4F12', marginTop: 3, lineHeight: 1.45 }}>Local model not ready. Save your seed anyway — you can ask the Garden later from the seed&rsquo;s detail screen.</div>
          </div>
        </div>
      )}

      {variant === 'default' && pathways.map((p, i) => (
        <div key={p.id} style={{
          background: '#fff', borderRadius: 14, padding: 14,
          border: `1px solid ${T.line}`,
          display: 'flex', flexDirection: 'column', gap: 10,
        }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
              <div style={{ color: T.brand }}>{Icon.sprout(T.brand, 14)}</div>
              <div style={{ fontFamily: T.font, fontSize: 12.5, fontWeight: 700, color: T.brand }}>Pathway {i + 1}</div>
            </div>
            <span style={{
              fontFamily: T.font, fontSize: 9.5, fontWeight: 700,
              padding: '2px 6px', borderRadius: 4,
              background: T.brandSoft, color: T.brand,
              letterSpacing: 0.3, textTransform: 'uppercase',
            }}>{p.source}</span>
          </div>
          <div style={{ fontFamily: T.font, fontSize: 14, color: T.ink, lineHeight: 1.5 }}>&ldquo;{p.text}&rdquo;</div>
          <div style={{ display: 'flex', justifyContent: 'flex-end' }}>
            <SecondaryButton>
              {Icon.sprout(T.brand, 13)}
              <span>Plant this</span>
            </SecondaryButton>
          </div>
        </div>
      ))}
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 4. SEED DETAIL / EDIT
// ═══════════════════════════════════════════════════════════════════════════
function SeedDetailScreen({ idea, onBack, onTab }) {
  const I = idea || SEED_IDEAS[0];
  const [title, setTitle] = React.useState(I.title);
  const [body, setBody] = React.useState(I.body + '\n\nFollow with a hard-cut to the host\u2019s key question.');
  const [cat, setCat] = React.useState(I.cat);
  const [hue, setHue] = React.useState(I.hue);
  const [helpLevel, setHelpLevel] = React.useState('Standard');

  return (
    <Phone>
      <PhoneTopBar
        left={<BackButton label="Ideas" onClick={onBack} />}
        center="Edit Seed"
        right={<span style={{ fontFamily: T.font, fontSize: 13, color: T.ink3 }}>Autosaved</span>}
      />

      <div style={{ flex: 1, overflowY: 'auto', padding: '8px 20px 20px', display: 'flex', flexDirection: 'column', gap: 18 }}>
        {/* Seed Name */}
        <div>
          <SectionLabel>Seed Name</SectionLabel>
          <input value={title} onChange={(e) => setTitle(e.target.value)} style={{
            width: '100%', boxSizing: 'border-box',
            background: '#fff', borderRadius: 12,
            border: `1px solid ${T.line}`,
            padding: '0 14px', height: 48,
            fontFamily: T.font, fontSize: 15, fontWeight: 600, color: T.ink, outline: 'none',
          }} />
        </div>

        {/* Details */}
        <div>
          <SectionLabel>Details</SectionLabel>
          <textarea value={body} onChange={(e) => setBody(e.target.value)} style={{
            width: '100%', boxSizing: 'border-box',
            background: '#fff', borderRadius: 12,
            border: `1px solid ${T.line}`,
            padding: 14, minHeight: 130,
            fontFamily: T.font, fontSize: 14, color: T.ink, outline: 'none',
            resize: 'none', lineHeight: 1.5,
          }} />
        </div>

        {/* Soil Type — segmented chips */}
        <div>
          <SectionLabel>Soil Type</SectionLabel>
          <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
            {Object.entries(CATEGORIES).map(([k, C]) => {
              const sel = cat === k;
              return (
                <button key={k} onClick={() => setCat(k)} style={{
                  display: 'inline-flex', alignItems: 'center', gap: 5,
                  padding: '8px 11px', borderRadius: 999,
                  background: sel ? T.brand : '#fff',
                  color: sel ? '#fff' : T.ink,
                  border: sel ? 'none' : `1px solid ${T.line}`,
                  fontFamily: T.font, fontSize: 12, fontWeight: 600,
                  cursor: 'pointer',
                }}>
                  {C.icon(sel ? '#fff' : T.brand, 13)}
                  <span>{C.label}</span>
                </button>
              );
            })}
          </div>
        </div>

        {/* Botanical Hues — small swatches */}
        <div>
          <SectionLabel>Botanical Hues</SectionLabel>
          <div style={{
            display: 'inline-flex', alignItems: 'center', gap: 6,
            background: '#fff', borderRadius: 10, padding: '6px 10px',
            border: `1px solid ${T.line}`,
          }}>
            <div style={{
              width: 16, height: 16, borderRadius: 999,
              background: HUES[hue].bg, border: `1px solid ${T.line2}`,
            }} />
            <div style={{ fontFamily: T.font, fontSize: 13, color: T.ink, fontWeight: 600 }}>{HUES[hue].label}</div>
            {Icon.chevD(T.ink3, 12)}
          </div>
        </div>

        {/* Brainstorm — AI */}
        <div>
          <SectionLabel>Brainstorm</SectionLabel>
          <div style={{
            background: '#fff', borderRadius: 14, padding: 14,
            border: `1px solid ${T.line}`,
            display: 'flex', flexDirection: 'column', gap: 12,
          }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <div style={{ fontFamily: T.font, fontSize: 12, color: T.ink2 }}>Help level</div>
              <div style={{
                display: 'inline-flex', alignItems: 'center', gap: 4,
                background: T.bg, borderRadius: 8, padding: '5px 10px',
                fontFamily: T.font, fontSize: 12.5, fontWeight: 600, color: T.ink,
              }}>
                <span>{helpLevel}</span>
                {Icon.chevD(T.ink3, 11)}
              </div>
            </div>
            <PrimaryButton style={{ height: 44 }}>
              {Icon.brain('#fff', 16)}
              <span>Ask the Garden</span>
            </PrimaryButton>

            {/* prior results */}
            <div style={{
              borderTop: `1px dashed ${T.line2}`, paddingTop: 10,
              fontFamily: T.font, fontSize: 12, color: T.ink2,
              display: 'flex', flexDirection: 'column', gap: 7,
            }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                <span style={{
                  fontFamily: T.fontMono, fontSize: 9.5, fontWeight: 700,
                  padding: '2px 5px', borderRadius: 4,
                  background: T.brandSoft, color: T.brand,
                }}>LOCAL</span>
                <span style={{ color: T.ink3, fontSize: 11 }}>qwen3-0.6b · 2:34pm</span>
              </div>
              <div><b style={{ color: T.ink }}>Question</b> — What single metric tells you the hook worked?</div>
              <div><b style={{ color: T.ink }}>Pathway</b> — Launch a 5-ep mini-season around one theme.</div>
              <div><b style={{ color: T.ink }}>Assumption</b> — Users will tolerate a longer cold-open.</div>
            </div>
          </div>
        </div>

        <PrimaryButton>Save Changes</PrimaryButton>
        <div style={{
          textAlign: 'center', fontFamily: T.font, fontSize: 11.5, color: T.ink3,
          marginTop: -8,
        }}>Changes autosave while you type.</div>
      </div>

      <TabBar active="ideas" onSelect={onTab} />
    </Phone>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 5. DAILY SPRINT
// ═══════════════════════════════════════════════════════════════════════════
function DailySprintScreen({ state = 'progress', onTab, onComplete }) {
  // state: 'empty' | 'progress' | 'complete'
  const sprouts = [
    'Use as a bookmark',
    'Mini cable organizer',
    'Earring back',
    'Plant label stake',
    'Reset button for sunglasses screws',
    'Hold a beanie shape while drying',
    'Zip pull replacement',
    'Lock a wandering luggage zipper',
    'Tiny stylus tip for art',
    'Make a chain bracelet',
  ];

  const [entries, setEntries] = React.useState(() => {
    if (state === 'empty') return [];
    if (state === 'progress') return sprouts.slice(0, 5);
    return sprouts;
  });
  const [input, setInput] = React.useState('');

  React.useEffect(() => {
    if (state === 'empty') setEntries([]);
    else if (state === 'progress') setEntries(sprouts.slice(0, 5));
    else setEntries(sprouts);
  }, [state]);

  const progress = Math.min(entries.length / 10, 1);
  const isComplete = progress >= 1.0;

  const handleAdd = () => {
    if (!input.trim()) return;
    const next = [...entries, input.trim()];
    setEntries(next);
    setInput('');
    if (next.length >= 10 && onComplete) onComplete();
  };

  return (
    <Phone>
      <div style={{
        paddingTop: 56, paddingLeft: 20, paddingRight: 20, paddingBottom: 10,
      }}>
        <div style={{ fontFamily: T.font, fontSize: 26, fontWeight: 700, color: T.ink, letterSpacing: -0.5 }}>Daily Sprint</div>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '4px 16px 20px', display: 'flex', flexDirection: 'column', gap: 14 }}>
        {/* Challenge card */}
        <div style={{
          background: isComplete ? T.brand : '#fff',
          color: isComplete ? '#fff' : T.ink,
          borderRadius: 18, padding: 18,
          border: isComplete ? 'none' : `1px solid ${T.line}`,
          display: 'flex', flexDirection: 'column', gap: 12,
        }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div style={{
              fontFamily: T.font, fontSize: 11.5, fontWeight: 700,
              letterSpacing: 0.8, textTransform: 'uppercase',
              color: isComplete ? 'rgba(255,255,255,0.7)' : T.ink2,
            }}>Daily Creativity Sprint</div>
            <div style={{
              fontFamily: T.font, fontSize: 11, fontWeight: 600,
              color: isComplete ? 'rgba(255,255,255,0.85)' : T.ink2,
            }}>{entries.length} / 10</div>
          </div>

          {/* progress bar */}
          <div style={{
            height: 8, borderRadius: 999,
            background: isComplete ? 'rgba(255,255,255,0.2)' : 'rgba(26,31,28,0.08)',
            overflow: 'hidden',
          }}>
            <div style={{
              width: `${progress * 100}%`, height: '100%', borderRadius: 999,
              background: isComplete ? '#A6E5C9' : T.brand,
              transition: 'width 0.3s',
            }} />
          </div>

          <div style={{
            fontFamily: T.font, fontSize: 13, fontWeight: 600,
            color: isComplete ? 'rgba(255,255,255,0.78)' : T.ink2,
            display: 'flex', alignItems: 'center', gap: 6,
          }}>
            {isComplete && Icon.check('#A6E5C9', 14)}
            <span>{isComplete ? 'Sprint complete!' : `${entries.length} of 10 ideas`}</span>
          </div>

          <div style={{ borderTop: `1px ${isComplete ? 'solid rgba(255,255,255,0.18)' : 'dashed ' + T.line2}`, paddingTop: 12 }}>
            <div style={{
              fontFamily: T.font, fontSize: 12, fontWeight: 700,
              color: isComplete ? 'rgba(255,255,255,0.7)' : T.ink2,
              letterSpacing: 0.6, textTransform: 'uppercase',
            }}>Object</div>
            <div style={{
              fontFamily: T.font, fontSize: 22, fontWeight: 700,
              color: isComplete ? '#fff' : T.ink, marginTop: 3, letterSpacing: -0.3,
            }}>Paperclip</div>
            <div style={{
              fontFamily: T.font, fontSize: 13.5, lineHeight: 1.45,
              color: isComplete ? 'rgba(255,255,255,0.78)' : T.ink2, marginTop: 4,
            }}>List as many alternate uses as you can in 10 minutes.</div>
          </div>
        </div>

        {/* Input */}
        <div style={{
          background: '#fff', borderRadius: 16, padding: 14,
          border: `1px solid ${T.line}`,
          display: 'flex', flexDirection: 'column', gap: 10,
          opacity: isComplete ? 0.65 : 1,
        }}>
          <SectionLabel style={{ marginBottom: 0 }}>
            {isComplete ? 'Add more (optional)' : 'Add alternate use'}
          </SectionLabel>
          <div style={{ display: 'flex', gap: 8 }}>
            <input
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={(e) => { if (e.key === 'Enter') handleAdd(); }}
              disabled={isComplete}
              placeholder={isComplete ? 'Sprint complete — see Sprouts below.' : 'Use it as a desk…'}
              style={{
                flex: 1, background: T.bg, borderRadius: 10,
                border: `1px solid ${T.line}`,
                padding: '0 12px', height: 42,
                fontFamily: T.font, fontSize: 14, color: T.ink, outline: 'none',
              }} />
            <button onClick={handleAdd} disabled={isComplete || !input.trim()} style={{
              height: 42, padding: '0 18px', borderRadius: 10, border: 'none',
              background: !input.trim() || isComplete ? 'rgba(31,77,63,0.20)' : T.brand,
              color: '#fff', fontFamily: T.font, fontSize: 14, fontWeight: 600,
              cursor: !input.trim() || isComplete ? 'not-allowed' : 'pointer',
            }}>Add</button>
          </div>
        </div>

        {/* Sprouts — locked vs revealed */}
        {!isComplete ? (
          <div style={{
            background: 'rgba(255,255,255,0.55)',
            borderRadius: 16, padding: 22,
            border: `1px dashed ${T.line2}`,
            textAlign: 'center',
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8,
          }}>
            <div style={{ color: T.ink3 }}>{Icon.lock(T.ink3, 22)}</div>
            <div style={{ fontFamily: T.font, fontSize: 14, fontWeight: 700, color: T.ink2 }}>🌱  Today&rsquo;s Sprouts</div>
            <div style={{ fontFamily: T.font, fontSize: 12.5, color: T.ink3, maxWidth: 220, lineHeight: 1.4 }}>
              {entries.length === 0
                ? 'Add your first idea above to start the sprint.'
                : 'Complete your sprint to reveal your sprouts.'}
            </div>
          </div>
        ) : (
          <div style={{
            background: '#fff', borderRadius: 16, padding: 16,
            border: `1px solid ${T.line}`,
            animation: 'ig-fadein 0.4s ease',
          }}>
            <div style={{
              display: 'flex', alignItems: 'center', justifyContent: 'space-between',
              marginBottom: 10,
            }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                <div style={{ color: T.brand }}>{Icon.sprout(T.brand, 16)}</div>
                <div style={{ fontFamily: T.font, fontSize: 15, fontWeight: 700, color: T.ink }}>Today&rsquo;s Sprouts</div>
              </div>
              <div style={{
                padding: '2px 8px', borderRadius: 999, background: T.brandSoft,
                color: T.brand, fontFamily: T.font, fontSize: 11, fontWeight: 700,
              }}>{entries.length}</div>
            </div>
            <ol style={{
              margin: 0, padding: 0, listStyle: 'none',
              display: 'flex', flexDirection: 'column', gap: 6,
            }}>
              {entries.map((e, i) => (
                <li key={i} style={{
                  display: 'flex', gap: 10,
                  padding: '7px 2px',
                  borderBottom: i < entries.length - 1 ? `1px solid ${T.line}` : 'none',
                  fontFamily: T.font, fontSize: 13.5, color: T.ink, lineHeight: 1.4,
                }}>
                  <span style={{ color: T.brand, fontWeight: 700, minWidth: 18 }}>{i + 1}.</span>
                  <span>{e}</span>
                </li>
              ))}
            </ol>
          </div>
        )}
      </div>

      <TabBar active="sprint" onSelect={onTab} />
    </Phone>
  );
}

Object.assign(window, {
  EntryGateScreen, IdeasScreen, EmptyState,
  PlantSeedScreen, SeedDetailScreen, DailySprintScreen,
  SEED_IDEAS,
});
