# Idea Garden — Figma Wireframe Spec
**App rename:** Brain Bot → Idea Garden  
**Target:** iPhone-only (iOS 17+), portrait  
**Fidelity:** Low-to-mid (grayscale layout + brand labels, no color fills)  
**Status key:** `[Implemented]` · `[Placeholder]` · `[MVP Future]` · `[Session 5 Concept]`

---

## 1. IA Map

```
App Launch
  └─ Entry Gate (AppEntryView)
       └─ Continue CTA
            └─ Root Tab Bar (3 tabs)
                 ├─ [Tab 1] Ideas (Garden Feed)
                 │    ├─ Sticky Header Zone
                 │    │    ├─ "Idea Garden" wordmark + sprout icon
                 │    │    ├─ Search bar (persistent)
                 │    │    └─ Filter chips: For You · Quick Wins · Experiments · Creator
                 │    ├─ Scroll Zone — 2-col card grid
                 │    │    └─ Idea Card → Seed Detail/Edit
                 │    └─ [Empty State] No ideas yet
                 │
                 ├─ [Tab 2] Plant Seed (multi-step capture)
                 │    ├─ Step 1 — Metadata
                 │    │    ├─ Soil Type (category picker)
                 │    │    ├─ Botanical Hues (visual style picker)
                 │    │    └─ Seed Name (title field)
                 │    ├─ Step 2 — Seed Notes
                 │    │    └─ Body text area
                 │    ├─ Step 3 — AI Pathways  [Session 5 Concept]
                 │    │    ├─ 3–5 pathway cards
                 │    │    ├─ "Plant this" per card
                 │    │    └─ Save Seed CTA
                 │    └─ [Validation] Missing required fields
                 │
                 └─ [Tab 3] Daily Sprint
                      ├─ Sprint Header (challenge + progress)
                      ├─ Input zone (object + text field + Add)
                      ├─ [Hidden pre-completion] Today's Sprouts section
                      └─ [Post-completion] Numbered sprouts list revealed
```

**Removed tab:** Activity tracker collapsed out of nav. Its data surfaces as a small streak indicator on the Ideas header. `[MVP Future]` for dedicated screen.

---

## 2. Screen Specs

### 2.1 Screen: Entry Gate
**Figma frame name:** `01_EntryGate/Default`

**Layout** (full-screen, centered column, safe-area aware):

```
┌─────────────────────────────────┐
│  [Status Bar]                   │
│                                 │
│                                 │
│   🌱  Idea Garden               │  ← wordmark, large/bold rounded font
│                                 │
│   "Your garden for growing      │  ← subtitle, secondary text
│    ideas into action."          │
│                                 │
│                                 │
│  ┌───────────────────────────┐  │
│  │        Continue           │  │  ← primary CTA, full-width, rounded-14
│  └───────────────────────────┘  │
│                                 │
│  "MVP uses a demo sign-in.      │  ← footnote, centered, secondary
│   Real auth attaches later."    │
│                                 │
│  [Home Indicator]               │
└─────────────────────────────────┘
```

**Annotations:**
- Title: `[Implemented]` — brand rename from "Brain Bot" to "Idea Garden"
- Subtitle: `[Implemented]` — update copy from "Capture ideas fast" to gardening metaphor
- CTA: `[Implemented]` — no behavior change, same `isSignedIn` toggle
- Auth note: `[Placeholder]` — real email/password auth is out of MVP scope

**Spacing:**
- Horizontal padding: 24pt
- Title↔subtitle gap: 12pt
- Subtitle↔CTA gap: 32pt
- CTA height: 52pt (headline font, white text)

---

### 2.2 Screen: Ideas (Garden Feed)
**Figma frame name:** `02_Ideas/Default`

**Architecture:** Sticky header zone + independent scroll zone below.

```
┌─────────────────────────────────┐  ← STICKY TOP ZONE (does not scroll)
│  [Status Bar]                   │
│  ─────────────────────────────  │
│  Idea Garden          🌱 3🔥    │  ← title left, streak badge right [MVP Future]
│  ─────────────────────────────  │
│  [ 🔍 Search seeds...         ] │  ← persistent search bar [Implemented]
│  ─────────────────────────────  │
│  [For You ✓] [Quick Wins]       │  ← horizontal chip scroll [Implemented]
│  [Experiments] [Creator]        │
│  ─────────────────────────────  │
├─────────────────────────────────┤  ← SCROLL ZONE (grid scrolls, header fixed)
│  ┌──────────┐  ┌──────────┐    │
│  │ ⚡Quick  │  │ 🧪Exper. │    │  ← category tag + icon [Implemented]
│  │ Win      │  │ iment    │    │
│  │          │  │          │    │
│  │ Podcast  │  │ Weekend  │    │  ← seed name / title [Implemented]
│  │ hook     │  │ pop-up   │    │
│  │ ideas    │  │ cart     │    │
│  │          │  │          │    │
│  │ Open     │  │ Test a   │    │  ← body preview, 3 lines [Implemented]
│  │ each     │  │ one-day  │    │
│  │ episode  │  │ iced tea │    │
│  │ with...  │  │ cart...  │    │
│  │          │  │     Mist │    │  ← visual style dot indicator
│  └──────────┘  └──────────┘    │
│  ┌──────────┐  ┌──────────┐    │
│  │ 🕐Long  │  │ ⚡Quick  │    │
│  │  Term    │  │  Win     │    │
│  │ Fitness  │  │ Newslet- │    │
│  │ challenge│  │ ter      │    │
│  │ mini-app │  │ growth   │    │
│  │          │  │          │    │
│  │ 7-day    │  │ Offer    │    │
│  │ bodywei- │  │ one      │    │
│  │ ght...   │  │ practi.. │    │
│  └──────────┘  └──────────┘    │
│                                 │
│  [Tab Bar]                      │
└─────────────────────────────────┘
```

**Idea Card anatomy:**
- Corner radius: 18pt
- Background: IdeaVisualStyle color (`[Implemented]`: Mist/Sage/Paper/Night)
- 14pt internal padding
- Row 1: category icon (SF Symbol) + category label — caption semibold, brand green
- Row 2: Seed Name — headline weight
- Row 3: Body preview — subheadline, 3-line limit, secondary color
- Row 4 (conditional): waveform icon + "Recording saved" — caption, brand green `[Implemented]`
- Thin 1pt stroke overlay, opacity 6%

**Sticky header implementation note (Session 4):**
Only the grid scrolls. The header (title bar + search + chips) is pinned using a `VStack` with `ScrollView` nested below, not `safeAreaInset`. Dev should use `LazyVGrid` inside `ScrollView` with the header pulled out above it.

**Filter chips:**
- Active chip: filled brand-green background, white text
- Inactive chip: white background, brand-green text, 1pt stroke
- "For You" pre-selected on load

---

### 2.3 Screen: Plant Seed — Step 1 (Metadata)
**Figma frame name:** `03_PlantSeed/Step1_Metadata`

**Session 5 change:** Tab renamed "Capture" → "Plant Seed". Form order inverted: metadata comes before body text. No long single-screen form.

```
┌─────────────────────────────────┐
│  [Status Bar]                   │
│  ← Back    Plant a Seed    [●○○]│  ← back button + progress indicator (3 dots)
│  ─────────────────────────────  │
│                                 │
│  SOIL TYPE                      │  ← section label, caption, secondary
│  ┌───────────────────────────┐  │
│  │ ⚡ Quick Win            ▾ │  │  ← picker, tappable [Implemented model]
│  └───────────────────────────┘  │
│                                 │
│  BOTANICAL HUES                 │  ← section label (was "Visual Style")
│  ┌────────┐┌────────┐┌────────┐┌────────┐
│  │  Mist  ││  Sage  ││ Paper  ││ Night  │  ← 4 rounded chip options
│  │   ●    ││        ││        ││        │  ← selected state = filled
│  └────────┘└────────┘└────────┘└────────┘
│                                 │
│  SEED NAME                      │  ← section label (was "Title")
│  ┌───────────────────────────┐  │
│  │ What are you planting?    │  │  ← text field, placeholder [Implemented]
│  └───────────────────────────┘  │
│                                 │
│                                 │
│  ┌───────────────────────────┐  │
│  │           Next →          │  │  ← primary CTA, disabled if Seed Name empty
│  └───────────────────────────┘  │
│                                 │
│  [Tab Bar]                      │
└─────────────────────────────────┘
```

**Annotations:**
- Soil Type picker: `[Implemented]` — maps to `IdeaCategory` (Quick Win/Long Term/Creator Mode/Experiment)
- Botanical Hues: `[Implemented]` — maps to `IdeaVisualStyle` (Mist/Sage/Paper/Night); rename label only
- Seed Name: `[Implemented]` — maps to `title` field
- Progress dots: `[Placeholder]` — 3 filled/empty dots representing step position
- Next CTA: `[Placeholder]` — gating logic: disabled until Seed Name has ≥1 non-whitespace char

**Compact layout rationale (Session 4):** No `Form` sections with spacious insets. Use a custom `VStack` layout with labeled sections and 12pt gaps. Total scrollable height should fit Step 1 on-screen without scrolling on iPhone 14 Pro.

---

### 2.4 Screen: Plant Seed — Step 2 (Seed Notes)
**Figma frame name:** `03_PlantSeed/Step2_Notes`

```
┌─────────────────────────────────┐
│  [Status Bar]                   │
│  ← Back    Plant a Seed    [●●○]│
│  ─────────────────────────────  │
│                                 │
│  SEED NOTES                     │  ← section label
│  ┌───────────────────────────┐  │
│  │                           │  │
│  │  What's the idea? Add     │  │  ← multi-line TextEditor
│  │  as much or little as     │  │  ← min height 160pt
│  │  you need.                │  │
│  │                           │  │
│  │                           │  │
│  └───────────────────────────┘  │
│                                 │
│  VOICE INPUT (optional)         │  ← collapsed by default
│  ┌───────────────────────────┐  │
│  │ 🎙 Start voice session    │  │  ← tappable row, expands [Implemented]
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │           Next →          │  │  ← enabled even with empty body
│  └───────────────────────────┘  │
│                                 │
│  [Tab Bar]                      │
└─────────────────────────────────┘
```

**Voice Input expanded state:**
```
│  VOICE INPUT                    │
│  ┌───────────────────────────┐  │
│  │ ● Recording — tap to stop │  │  ← waveform icon animates
│  │ [Stop]  [Finish Session]  │  │
│  │ "Transcribing..."         │  │  ← shows ProgressView during STT
│  └───────────────────────────┘  │
```

**Annotations:**
- Seed Notes: `[Implemented]` — maps to `body` field; display before AI pathways step
- Voice input: `[Implemented]` — IdeaAudioRecorder; keep in Step 2, collapsed to reduce visual noise
- Next CTA: `[Implemented]` — body is optional; Next always enabled at Step 2

---

### 2.5 Screen: Plant Seed — Step 3 (AI Pathways)
**Figma frame name:** `03_PlantSeed/Step3_Pathways`

**Session 5 Concept** — This step is new. Generates 3–5 contextual pathways from Seed Name + Notes using the existing `IdeaAssistantService`. Each pathway can be "planted" into the seed body.

```
┌─────────────────────────────────┐
│  [Status Bar]                   │
│  ← Back    Plant a Seed    [●●●]│
│  ─────────────────────────────  │
│                                 │
│  AI PATHWAYS  ✦                 │  ← label + sparkle icon
│  "Here are some directions      │  ← descriptive subtitle
│   for your seed to grow:"       │
│                                 │
│  ┌───────────────────────────┐  │
│  │ 🌿 Pathway 1              │  ← pathway card, rounded-12
│  │ "Turn each episode into   │  │
│  │  a 60-sec audio clip for  │  │
│  │  Reels or Shorts."        │  │
│  │                           │  │
│  │         [ Plant this ]    │  │  ← secondary CTA, right-aligned
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │ 🌿 Pathway 2              │  │
│  │ "Pitch to 3 indie         │  │
│  │  podcast networks first   │  │
│  │  before launching solo."  │  │
│  │         [ Plant this ]    │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │ 🌿 Pathway 3              │  │
│  │ "Create a Substack post   │  │
│  │  to test the hook format  │  │
│  │  cheaply."                │  │
│  │         [ Plant this ]    │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │         Save Seed 🌱       │  │  ← primary CTA, brand green
│  └───────────────────────────┘  │
│  Skip →                         │  ← tertiary link, right-aligned
│                                 │
│  [Tab Bar]                      │
└─────────────────────────────────┘
```

**Loading state (pathway generation in progress):**
```
│  AI PATHWAYS  ✦                 │
│  ┌───────────────────────────┐  │
│  │   ⟳  Growing pathways...  │  │  ← loading card placeholder
│  │   (3–8 sec for local LLM) │  │
│  └───────────────────────────┘  │
```

**Annotations:**
- AI Pathways: `[Session 5 Concept]` — new step; not yet implemented in code
- Pathway card "Plant this": `[Session 5 Concept]` — inserts pathway `.text` into seed body (appended or replaced)
- Pathway generation: maps to existing `IdeaAssistantService.generateSuggestions()` filtering for `.pathway` kind `[Implemented]` logic; UI wrapper is `[Placeholder]`
- "Save Seed": `[Placeholder]` — calls `store.autosaveIdea()` then navigates to Ideas tab
- "Skip →": `[Placeholder]` — saves without AI pathways, navigates to Ideas tab
- AI source badge (Local/Cloud): `[Implemented]` — surface on each pathway card

**Fallback state (AI unavailable):**
```
│  ┌───────────────────────────┐  │
│  │  ⚠ Pathways unavailable   │  │
│  │  Local model not ready.   │  │
│  │  Save your seed anyway.   │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │         Save Seed 🌱       │  │
│  └───────────────────────────┘  │
```

---

### 2.6 Screen: Seed Detail / Edit
**Figma frame name:** `04_SeedDetail/Default`

```
┌─────────────────────────────────┐
│  [Status Bar]                   │
│  ← Ideas          Edit Seed     │
│  ─────────────────────────────  │
│                                 │
│  SEED NAME                      │
│  ┌───────────────────────────┐  │
│  │ Podcast hook ideas        │  │  ← editable text field [Implemented]
│  └───────────────────────────┘  │
│                                 │
│  DETAILS                        │
│  ┌───────────────────────────┐  │
│  │ Open each episode with a  │  │
│  │ 20-second true story      │  │  ← TextEditor, min 140pt [Implemented]
│  │ before the lesson.        │  │
│  └───────────────────────────┘  │
│                                 │
│  SOIL TYPE                      │
│  [⚡Quick Win][🕐Long][🎨Creator][🧪Exp.]  ← segmented chips [Implemented]
│                                 │
│  BOTANICAL HUES                 │
│  [Mist ▾]                       │  ← menu picker [Implemented]
│                                 │
│  BRAINSTORM                     │  ← [Implemented] AI assistance
│  Help level: [Standard      ▾]  │
│  ┌───────────────────────────┐  │
│  │ 🧠 Brain Button           │  │  ← AI generate CTA
│  └───────────────────────────┘  │
│                                 │
│  ── Previous results ──         │
│  [Local] qwen3-0.6b  2:34pm     │
│  Question: "What metric..."     │
│  Pathway:  "Launch a..."        │
│  Assumption: "Users will..."    │
│                                 │
│  ┌───────────────────────────┐  │
│  │         Save Changes      │  │  ← primary CTA [Implemented]
│  └───────────────────────────┘  │
│  "Changes autosave while        │
│   you type."                    │  ← footer note [Implemented]
│                                 │
│  [Tab Bar]                      │
└─────────────────────────────────┘
```

**Annotations:**
- All edit fields: `[Implemented]`
- Voice Session section (if idea has audio): `[Implemented]` — shown conditionally; play/stop + transcript editor
- "Brain Button": `[Implemented]` — label rename from "Brain Button" acceptable; or "Ask the Garden"
- Brainstorm results: `[Implemented]` — AssistanceResultsView renders question/pathway/assumption

---

### 2.7 Screen: Daily Sprint
**Figma frame name:** `05_DailySprint/PreCompletion`

**Session 4 change:** "Today's Sprouts" section hidden until sprint is complete.

```
┌─────────────────────────────────┐
│  [Status Bar]                   │
│  ─────────────────────────────  │
│  Daily Sprint                   │  ← navigation title [Implemented]
│  ─────────────────────────────  │
│  ┌───────────────────────────┐  │
│  │ Daily Creativity Sprint   │  │  ← section header card [Implemented]
│  │                           │  │
│  │ ████████████░░░░░░░░░░░░  │  │  ← ProgressView, brand green [Implemented]
│  │ 5 of 10 ideas             │  │  ← progress label [Placeholder]
│  │                           │  │
│  │ Object: Paperclip         │  │  ← AlternateUsesChallenge.today() [Implemented]
│  │ List as many alternate    │  │
│  │ uses as you can in        │  │
│  │ 10 minutes.               │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │  ← input card [Implemented]
│  │ Add alternate use         │  │
│  │ ┌─────────────────────┐   │  │
│  │ │ Use it as a desk... │   │  │  ← text field
│  │ └─────────────────────┘   │  │
│  │ ┌──────────────────────┐  │  │
│  │ │         Add          │  │  │  ← Add button [Implemented]
│  │ └──────────────────────┘  │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │  🌱 Today's Sprouts       │  │  ← HIDDEN until completion condition met
│  │  [locked, greyed out]     │  │  ← show placeholder lock icon + "Complete
│  │  Complete your sprint     │  │     your sprint to reveal"
│  │  to reveal sprouts.       │  │
│  └───────────────────────────┘  │
│                                 │
│  [Tab Bar]                      │
└─────────────────────────────────┘
```

**Post-completion state:** `05_DailySprint/PostCompletion`

```
┌─────────────────────────────────┐
│  [Status Bar]                   │
│  Daily Sprint                   │
│  ─────────────────────────────  │
│  ┌───────────────────────────┐  │
│  │ ████████████████████████  │  ← full progress bar
│  │ ✅ Sprint complete!       │  │
│  │ Object: Paperclip         │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │  ← input disabled or hidden post-completion
│  │ Add more (optional)       │  │
│  │ [ text field disabled ]   │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │  🌱 Today's Sprouts  (10) │  │  ← revealed, count badge [Session 4]
│  │                           │  │
│  │  1. Use as a bookmark     │  │
│  │  2. Mini cable organizer  │  │
│  │  3. Earring back          │  │
│  │  4. Plant label stake     │  │
│  │  ...                      │  │
│  └───────────────────────────┘  │
│                                 │
│  [Tab Bar]                      │
└─────────────────────────────────┘
```

**Completion condition:** `[Placeholder]` — progress reaches ≥ 1.0 (10+ entries). Current code increments by 0.07 per entry (≈15 entries = 100%). Dev should wire `isComplete: Bool` computed from `dailyEntries.count >= 10` or `progress >= 1.0`.

**Annotations:**
- Challenge card: `[Implemented]`
- Input + Add: `[Implemented]`
- Progress bar + label: `[Implemented]` progress view; label is `[Placeholder]`
- Sprouts hidden until completion: `[Session 4 Concept]` — conditional rendering by `isComplete`
- "Today's Sprouts" label rename: `[Session 4 Concept]` — was "Today's ideas"

---

## 3. Components

### Naming Convention
Pattern: `[Screen/Global]_[ComponentName]_[Variant]`

| Component | Figma Name | Notes |
|-----------|------------|-------|
| Idea card | `Ideas_SeedCard_Default` | 2-col grid cell |
| Idea card with audio | `Ideas_SeedCard_WithRecording` | adds waveform row |
| Filter chip (active) | `Global_Chip_Active` | filled, white text |
| Filter chip (inactive) | `Global_Chip_Inactive` | outlined |
| Category tag | `Global_CategoryTag_[QuickWin|LongTerm|Creator|Experiment]` | icon + label |
| Visual style swatch | `PlantSeed_HueSwatch_[Mist|Sage|Paper|Night]` | color circle |
| Progress dot | `PlantSeed_ProgressDot_[Filled|Empty]` | step indicator |
| Primary button | `Global_Button_Primary` | full-width, rounded-14, 52pt tall |
| Secondary button | `Global_Button_Secondary` | outlined or tinted |
| Tertiary link | `Global_Button_Tertiary` | text-only |
| Pathway card | `PlantSeed_PathwayCard_Default` | AI pathway result |
| Pathway card loading | `PlantSeed_PathwayCard_Loading` | shimmer placeholder |
| Pathway card fallback | `PlantSeed_PathwayCard_Fallback` | error state |
| Sprouts list item | `DailySprint_SproutItem` | numbered row |
| Sprouts locked | `DailySprint_SproutsLocked` | pre-completion placeholder |
| AI source badge | `Global_AIBadge_[Local|Cloud|LocalDraft]` | small pill |
| Assistance result | `SeedDetail_AssistanceResult` | question/pathway/assumption rows |
| Empty state | `Global_EmptyState_[Garden|Search|Sprouts]` | centered illus + copy |
| Search bar | `Ideas_SearchBar` | `.searchable` equivalent |
| Tab bar item | `Global_TabItem_[Ideas|PlantSeed|DailySprint]` | icon + label |

### Tab Bar Items (Session 5 rename)
| Tab | Icon (SF Symbol) | Label |
|-----|-----------------|-------|
| 1 | `leaf.fill` | Ideas |
| 2 | `plus.circle.fill` | Plant Seed |
| 3 | `target` | Daily Sprint |

### Color Tokens (wireframe annotations only — not final palette)
| Token | Usage | Hex note |
|-------|-------|----------|
| `brand-green` | CTAs, active chips, icons | maps to `Color.midnightGreen` |
| `bg-cloud` | Screen backgrounds | maps to `Color.cloud` |
| `hue-mist` | Card bg, Mist style | `#EBF5F2` |
| `hue-sage` | Card bg, Sage style | `#D7E8E3` |
| `hue-paper` | Card bg, Paper style | `#FFFFFF` |
| `hue-night` | Card bg, Night style | `midnightGreen @ 14%` |

---

## 4. User Flows

### Flow A: Sign In → Plant Seed → Save → Appears in Ideas

```
01_EntryGate/Default
  │  Tap "Continue"
  ▼
02_Ideas/Default  (Ideas tab selected)
  │  Tap "Plant Seed" tab
  ▼
03_PlantSeed/Step1_Metadata
  │  Select Soil Type: Creator Mode
  │  Select Hue: Sage
  │  Type Seed Name: "Podcast hook ideas"
  │  Tap "Next →"
  ▼
03_PlantSeed/Step2_Notes
  │  Type body: "Open each episode with a 20-second true story"
  │  Tap "Next →"
  ▼
03_PlantSeed/Step3_Pathways  [Session 5 Concept]
  │  System generates 3–5 pathways (local LLM, 3–8s)
  │  Option A: Tap "Plant this" on Pathway 2
  │    → pathway text appended to seed body
  │  Tap "Save Seed 🌱"
  ▼
02_Ideas/Default
  │  New card appears at top of grid (Sage bg, Creator icon)
  │  [Autosave confirmation: card visible immediately]
```

**Autosave note:** `store.autosaveIdea()` is called on each step navigation. If user abandons at Step 2, a draft already exists in the feed.

---

### Flow B: Search Ideas → Open/Edit Seed → Save

```
02_Ideas/Default
  │  Tap search bar
  │  Type "podcast"
  ▼
02_Ideas/SearchActive
  │  Grid filters to matching cards
  │  Tap "Podcast hook ideas" card
  ▼
04_SeedDetail/Default
  │  Edit body text: add new line
  │  Optionally: tap "Ask the Garden" → AI generates suggestions
  │  Autosave fires 700ms after typing stops
  │  Tap "Save Changes" (or use back navigation)
  ▼
02_Ideas/Default
  │  Card shows updated body preview
  │  Search state cleared on tab re-selection
```

---

### Flow C: Daily Sprint Completion → Sprouts Reveal

```
05_DailySprint/PreCompletion
  │  Sprint header shows object: "Paperclip"
  │  User types: "Use as a bookmark" → Tap Add
  │    → entry #1 added, progress += 0.07
  │  [repeat until progress ≥ 1.0 / 10 entries]
  ▼
05_DailySprint/CompletionMoment
  │  Progress bar fills to 100%
  │  "✅ Sprint complete!" replaces prompt text
  │  "Today's Sprouts" section animates in (fade/slide)
  ▼
05_DailySprint/PostCompletion
  │  Numbered list of all entries visible
  │  Input field disabled or shows "Add more (optional)"
  │  Streak badge on Ideas tab header increments [MVP Future]
```

---

## 5. States & Validation

### 5.1 Empty States

| Screen | Trigger | Component | Copy |
|--------|---------|-----------|------|
| Ideas — no ideas | Fresh install | `Global_EmptyState_Garden` | "Your garden is empty. Plant your first seed." + "Plant Seed" CTA |
| Ideas — no search results | Search returns 0 | `Global_EmptyState_Search` | "No seeds match '[query]'. Try different words." |
| Daily Sprint — no entries | Sprint not started | `DailySprint_SproutsLocked` | Hidden section shows lock placeholder |
| AI Pathways — no results | Model returns 0 | `PlantSeed_PathwayCard_Fallback` | "Couldn't grow pathways right now. Save your seed anyway." |

### 5.2 Field Validation

| Screen | Field | Rule | Error behavior |
|--------|-------|------|----------------|
| Step 1 | Seed Name | Required, ≥1 non-whitespace char | "Next →" CTA disabled; no inline error shown |
| Step 1 | Soil Type | Required | Pre-selected to "Quick Win" on load; always valid |
| Step 1 | Botanical Hues | Required | Pre-selected to "Mist" on load; always valid |
| Step 2 | Seed Notes | Optional | No validation; Next always enabled |
| Step 3 | — | Skip available | User can bypass AI step entirely |
| Seed Detail | Seed Name | Non-empty to save | Autosave uses "Untitled idea" if empty `[Implemented]` |

### 5.3 AI Generation States

| State | Visual treatment | Annotation |
|-------|-----------------|------------|
| Not started | "Next →" enabled, no pathways shown | — |
| Generating | Loading card with spinner + "Growing pathways..." | `[Session 5 Concept]` |
| Success | 3–5 pathway cards with "Plant this" | `[Session 5 Concept]` |
| Partial (< 3 results) | Show what was returned, no error | `[Session 5 Concept]` |
| Failure / model not ready | Fallback card + "Save Seed" still available | `[Implemented]` alert equivalent |
| Cloud escalated | "Cloud" badge on pathway card | `[Implemented]` source labeling |

### 5.4 Voice Recording States (Step 2)

| State | Label | Buttons |
|-------|-------|---------|
| Idle | "Start a voice session." | [Start] [Finish Session - disabled] |
| Recording | "Recording. Tap Stop to pause." | [Stop] [Finish Session] |
| Paused | "Paused. Tap Resume." | [Resume] [Finish Session] |
| Transcribing | "Transcribing..." | ProgressView; both disabled |
| Done | "Recording saved with transcript." | Transcript text shown below |

### 5.5 Daily Sprint States

| State | Progress condition | Sprouts section |
|-------|--------------------|-----------------|
| Not started | progress = 0 | Hidden, no lock UI |
| In progress | 0 < progress < 1.0 | Locked placeholder visible |
| Complete | progress ≥ 1.0 | Animated reveal, full list |

---

## 6. Dev Handoff Notes

### 6.1 Frame Naming Convention
```
[ScreenNumber]_[ScreenName]/[State]
Examples:
  01_EntryGate/Default
  02_Ideas/Default
  02_Ideas/SearchActive
  02_Ideas/EmptyState
  03_PlantSeed/Step1_Metadata
  03_PlantSeed/Step2_Notes
  03_PlantSeed/Step3_Pathways
  03_PlantSeed/Step3_Pathways_Loading
  03_PlantSeed/Step3_Pathways_Fallback
  04_SeedDetail/Default
  04_SeedDetail/WithAudioRecording
  05_DailySprint/PreCompletion
  05_DailySprint/PostCompletion
  05_DailySprint/EmptyStart
```

### 6.2 Implementation Priority Map

**Build immediately (all Implemented):**
- Entry Gate copy update (Brain Bot → Idea Garden)
- Tab bar: rename "Capture" → "Plant Seed", tab icon `plus.circle.fill` → `leaf.fill` (or keep)
- Ideas tab: extract header out of `ScrollView` to achieve sticky behavior (Session 4)
- Daily Sprint: add `isComplete` computed var, conditionally show/hide Sprouts section (Session 4)
- Rename "Today's ideas" → "Today's Sprouts" in `DailyChallengeView`

**Build next (Placeholder → working):**
- Step-by-step PlantSeed flow replacing single-form `CaptureIdeaView`
- Step progress indicator (3 dots)
- "Next →" / Back navigation between steps
- "Save Seed" final action wiring

**Design only for now (Session 5 Concept):**
- AI Pathways step (Step 3) — annotate in Figma, don't implement yet
- "Plant this" insertion behavior

### 6.3 Sticky Header Implementation (Session 4)

Current `IdeaFeedView` uses `.searchable` which floats the search bar inside `NavigationStack`. To achieve a true sticky header with chips:

```swift
// Pattern: header pinned above ScrollView
VStack(spacing: 0) {
    // Header zone (does not scroll)
    VStack { titleBar; searchBar; chipRow }
    
    // Scroll zone
    ScrollView {
        LazyVGrid(columns: columns) { ... }
    }
}
// Remove .searchable modifier; implement custom search field
```

### 6.4 Sprint Completion Gate (Session 4)

Add to `DailyChallengeView`:
```swift
private var isSprintComplete: Bool {
    store.dailyEntries.count >= 10  // or: progress >= 1.0
}
// Use isSprintComplete to conditionally show "Today's Sprouts" section
```

### 6.5 Data Model Changes Needed for Session 5

Current `Idea` model requires no changes. Session 5 introduces UI flow changes only.

For AI Pathways step, reuse existing:
- `IdeaAssistantService.generateSuggestions(for:)` — already returns `.pathway` kind suggestions
- Filter `result.suggestions.filter { $0.kind == .pathway }` to populate pathway cards
- "Plant this" action: append chosen pathway text to the draft `body` string

### 6.6 Autosave Draft Behavior

The existing autosave (`store.autosaveIdea()`) fires 700ms after any field change. In the multi-step flow:
- Fire autosave when user taps "Next →" at Step 1 (Seed Name + metadata written to store)
- Fire again at Step 2 (body appended)
- Final "Save Seed" at Step 3 confirms and navigates to Ideas tab
- If user abandons mid-flow, draft already exists in the feed

### 6.7 Activity Tab

Removed from tab bar in Idea Garden. Contribution streak data should surface as a small "3🔥" badge on the Ideas screen title area. Full Activity view is `[MVP Future]` — keep `ActivityTrackerView` code in place but don't tab-slot it.

### 6.8 Spacing & Layout System (reference from existing `Style.swift`)

Match existing card style (`.cardStyle()` modifier pattern). Implement new wireframe screens with:
- Screen horizontal padding: 16pt (grid) or 24pt (form)
- Card corner radius: 18pt (idea cards), 12pt (pathway cards)
- Section label: `.caption.weight(.semibold)`, secondary foreground
- CTA button: `.headline`, 52pt tall, rounded-14
- Inter-section gap: 16pt in scroll views, 12pt inside cards
