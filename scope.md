
# Brain Bot iPhone MVP Scope

## 1. Overview
Brain Bot is an iPhone-only application for quick idea capture and light idea development. MVP focuses on capturing ideas in the moment, providing constrained AI support that preserves user thinking, and offering one short daily creativity exercise. The product is local-first with authenticated user accounts.

## 2. Product goals
- Ship a stable iPhone MVP with a narrow, testable feature set.
- Enable fast idea capture via typed input and voice transcription.
- Provide non-dominant AI assistance to clarify and expand ideas.
- Drive daily engagement with one 10-minute creativity game.
- Maintain privacy and responsiveness through local-first operation.

## 3. MVP user stories
- As an authenticated user, I can sign in and access only my idea data.
- As a user, I can create and save an idea quickly with text or voice.
- As a user, I can view my saved ideas on a homepage and search by title/content.
- As a user, I can open an idea and request lightweight AI help (questions + 2–3 directions).
- As a user, I can control AI assistance level (minimal, standard, more help).
- As a user, I receive a morning notification and can complete one daily creativity game.

## 4. In-scope features
### 4.1 Platform and access
- Native iPhone deployment only.
- Required authentication (email/password or equivalent managed auth).
- Per-user data isolation.

### 4.2 Idea store
- Create, edit, and delete ideas.
- Idea fields: title, body text, created/updated timestamps.
- Capture inputs:
  - typed text,
  - voice-to-text transcription.
- Optional visual styling per idea card:
  - choose a solid background color, or
  - assign one user-selected image.

### 4.3 Homepage
- Scrollable idea list (single-column cards for MVP).
- Search across title and body text.
- Tap card to open idea detail view.

### 4.4 AI-assisted idea development
- Available from idea detail screen.
- AI actions for MVP:
  - ask clarifying follow-up questions,
  - propose exactly 2–3 next directions,
  - identify potential weak assumptions briefly.
- User-set assistance level:
  - Minimal: mostly questions,
  - Standard: questions + 2 directions,
  - More help: questions + up to 3 directions + weak-spot prompt.

### 4.5 Daily creativity game
- One game in scope: **Alternate Uses Challenge**.
- Daily morning push notification opens game flow.
- Single 10-minute session format:
  - show one everyday object,
  - user writes as many alternate uses as possible,
  - optional end-of-session AI reflection with 2 prompts.

### 4.6 Collaboration (limited MVP inclusion)
- Minimal async sharing only:
  - user can generate a read-only share link to an idea snapshot.
- No co-editing, no comments, no rooms in MVP.

## 5. Out-of-scope features
- iPad, Android, web, desktop clients.
- Real-time collaboration, live cursors, idea rooms, mentions, threaded comments.
- Multi-game catalog, custom game builder, competitive or social game mechanics.
- AI-generated full idea drafts or autonomous ideation workflows.
- Advanced media capture (video notes, whiteboard OCR, image-to-idea extraction).
- Offline multi-device sync conflict resolution beyond basic last-write-wins.
- Team admin controls, org billing, enterprise policy controls.

## 6. Functional requirements
- FR1: User must authenticate before accessing app content.
- FR2: System must bind all ideas to authenticated user ID.
- FR3: User must be able to create, edit, delete, and search ideas.
- FR4: System must support typed capture and voice transcription to text.
- FR5: Homepage must render saved ideas with title and selected visual style.
- FR6: AI assistance must be user-invoked (not auto-expanding ideas by default).
- FR7: AI response must follow selected assistance level constraints.
- FR8: System must schedule one daily morning local notification for the creativity game.
- FR9: Game session must be completable in ~10 minutes.
- FR10: Shared idea link (if created) must be read-only and revoke-capable.

## 7. Non-functional requirements
- iPhone-first UX with target support for current iOS major version and previous major version.
- Local-first data access for core idea operations when network is unavailable.
- App launch to interactive homepage target: <=2.5 seconds on reference device.
- Core capture interaction target: save text idea in <=2 taps after entry.
- Privacy baseline: local data encrypted at rest using platform mechanisms.
- Reliability target: no data loss for saved ideas during normal app termination/update.

## 8. AI behavior and routing rules
- Primary model: on-device/local LLM for default requests.
- Escalate to OpenAI API only when at least one condition is true:
  1. User explicitly requests stronger/cloud reasoning.
  2. Local model confidence/quality threshold is not met.
  3. Prompt is classified as complex reasoning (configured heuristic).
- Routing transparency:
  - UI labels whether response used Local or Cloud.
  - User can disable cloud escalation globally in settings.
- Assistant behavior guardrails:
  - prioritize questions over answers,
  - offer bounded options (2–3 paths),
  - avoid definitive “best idea” claims,
  - avoid producing complete end-to-end solution drafts unless explicitly requested.

## 9. Data/storage expectations
- Local-first canonical store on device for ideas and game session logs.
- Cloud backend responsibilities (MVP):
  - authentication,
  - backup/sync of user ideas,
  - share-link hosting for read-only snapshots.
- Sync model: async background sync with last-write-wins conflict handling.
- Data model minimum entities:
  - User,
  - Idea,
  - IdeaStyle,
  - GameSession,
  - ShareLink.
- AI metadata stored per AI interaction:
  - timestamp,
  - routing source (local/cloud),
  - assistance level used.

## 10. Assumptions and open questions
### Assumptions
- Voice transcription uses platform speech APIs acceptable for MVP accuracy.
- Push notifications are local-scheduled for daily game reminder.
- Read-only share link can be implemented without full collaborator accounts.
- Last-write-wins is acceptable for MVP conflict behavior.
