# Cook Mode — Live AI-powered playable recipes

> ⚠️ **Before you run the app:** you must paste your Anthropic API key into
> `lib/config/api_keys.dart`. See the **Setup** section below. Without it
> you'll see a friendly error on the Cook screen telling you the same thing.

This doc explains the "Cook with me" feature end-to-end, so you can read it
top-to-bottom and understand exactly what's happening and why.

---

## What this feature does

On any recipe details page there is now a big orange **"Cook with me"**
button. Tapping it opens a full-screen **playable cook mode**:

```
┌──────────────────────────────────────┐
│  ✕                  Step 3 of 7      │
│  ▓▓▓▓▓▓▓▓░░░░░░░░░░  (progress bar)  │
│                                      │
│             [ FRY ]                  │  ← verb chip
│                                      │
│   Fry the onions until golden        │  ← instruction (animated swap)
│                                      │
│             04:32                    │  ← countdown
│                                      │
│   ⏮  Prev    ⏸ Pause    ⏭ Next       │  ← controls
└──────────────────────────────────────┘
```

- The recipe gets broken into clean numbered steps **on demand**, by Claude.
- Each step shows its instruction and a **countdown timer** if the recipe
  implies a duration.
- Steps with no implied duration (e.g. "season to taste") show *"Tap Next
  when you're done"* instead of a timer.
- Prev / Pause / Skip / Next controls let the user move through the recipe
  at their own pace.
- Last step is replaced with a **Finish** button that shows a "Enjoy your
  meal!" dialog.

---

## How the structured AI call works (the interesting part)

The hard problem: TheMealDB returns `strInstructions` as **one long blob of
text** that's totally unstructured. We need a list of `{instruction,
durationSeconds, verb}` objects. So we ask Claude to do the conversion —
but we need the response shape to be **guaranteed**, not just hoped for.

We use Anthropic's **tool use** mechanism to enforce this. The pattern is:

1. We define a single "tool" called `submit_cook_steps`. Its `input_schema`
   is the exact JSON shape we want — array of `{order, instruction,
   durationSeconds, verb}` objects.
2. We send a request with `tool_choice: {type: "tool", name: "submit_cook_steps"}`.
   This **forces** Claude to respond by calling that tool. It is not
   allowed to reply with plain text.
3. Claude's response arrives as a `tool_use` block. The block's `input`
   field is the validated, schema-conforming JSON we wanted.
4. We parse it directly into a `List<CookStep>`. No string parsing, no
   regex, no try/catch around `jsonDecode` of the model's free-form text.

This is the official Anthropic-recommended way to get structured output.
See: <https://docs.anthropic.com/en/docs/build-with-claude/tool-use>

### What the prompt looks like

We send Claude:
- The meal name (e.g. *Teriyaki Chicken Casserole*).
- The full ingredients list with measures.
- The raw `strInstructions` text.

Plus 7 explicit rules (written in `lib/services/cook_mode_service.dart`):

> 1. Each step should be ONE short imperative sentence (under 25 words).
> 2. Split combined sentences into separate steps when each part is a
>    distinct action.
> 3. Estimate `durationSeconds` ONLY if the recipe implies a time.
>    Otherwise use null.
> 4. For preheat steps, default to 600 seconds.
> 5. Add a single-word `verb` (chop, fry, simmer, mix, preheat, bake…)
>    or null.
> 6. Don't invent steps that aren't in the original instructions.
> 7. Order starts at 1 and increments by 1.

The full schema and prompt are at the top of
`lib/services/cook_mode_service.dart`.

### Which model

`claude-haiku-4-5` — Anthropic's small/fast tier. It's:
- ⚡ Fast (~1–3 seconds for a typical recipe).
- 💸 Very cheap (~$0.001 per recipe — fractions of a cent).
- 🎯 Genuinely good at structured extraction tasks like this.

If we ever wanted higher quality, we could swap in `claude-sonnet-4-6` by
changing one constant — but Haiku is the right call here.

---

## Setup — required before first run 🔑

You'll see the Cook button on every recipe page, but tapping it will show
an error until you do this:

1. Get an API key from <https://console.anthropic.com/>. New accounts get
   free trial credit that's plenty for development.
2. Open `lib/config/api_keys.dart` (this file is **git-ignored**, so your
   key never gets committed).
3. Replace the `YOUR_API_KEY` placeholder with your real key:

   ```dart
   class ApiKeys {
     static const String anthropic = "sk-ant-api03-...your-real-key...";
   }
   ```

4. Hot-restart the app (`R` in `flutter run`, or stop & re-run from your IDE).
   Cook with me should now work.

A `lib/config/api_keys.example.dart` is checked into git so other people
cloning the project know what file to make.

### Why is the key in the app and not on a server?

For a school/learning project, having it in the app is **fine**. The risks
are:
- Anyone who decompiles the APK can extract the key.
- They can use your free credits.

Mitigations for a real release would be a tiny backend proxy (e.g. a free
Cloudflare Worker) that holds the key and the app calls that instead. We
intentionally aren't doing that yet — see `work.md` for the discussion.

---

## File map for this feature

| File | What's in it |
|---|---|
| `lib/config/api_keys.dart` | Your Anthropic key. **Git-ignored.** |
| `lib/config/api_keys.example.dart` | Template so others know what file to make. Committed. |
| `lib/models/cook_step_model.dart` | The `CookStep` Dart class (order, instruction, durationSeconds, verb). |
| `lib/services/cook_mode_service.dart` | Builds the prompt, calls Claude, enforces structured output via tool use, parses the response into `List<CookStep>`. |
| `lib/cook_mode.dart` | The full-screen `CookModePage` widget — loading / error / player states, timer, controls, finish dialog. |
| `lib/recipe_details.dart` | New `_buildCookButton()` method + a single line wiring it into the page. |
| `.gitignore` | One line added to ignore `lib/config/api_keys.dart`. |
| `pubspec.yaml` | Unchanged — we already had `http`. |

---

## State machine inside CookModePage

```
        ┌──────────────┐
        │   Loading    │ ──[ network error ]──▶ ┌──────────┐
        │ (spinner +   │                        │  Error   │ ─[retry]─┐
        │  "Preparing  │ ◀──[retry]─────────────│ + button │           │
        │  your        │                        └──────────┘           │
        │  recipe…")   │                                                │
        └──────┬───────┘                                                │
               │                                                        │
               │ [Claude responds OK]                                   │
               ▼                                                        │
        ┌──────────────┐                                                │
        │   Player     │                                                │
        │ (current step│                                                │
        │  + timer +   │                                                │
        │  controls)   │                                                │
        └──────────────┘                                                │
               ▲                                                        │
               └────────────────────────────────────────────────────────┘
```

The retry button does the **exact same call** again — same recipe, same
prompt, fresh request.

---

## UX details that matter

- **Timer hits zero**: it does **not** auto-advance. The Next button just
  changes colour (highlight orange) to signal "you can move on now." This
  is deliberate — auto-advancing while the user is still chopping would be
  rude.
- **Pause/Resume**: needed because you'll inevitably get distracted (phone
  call, kid, fridge run).
- **Instruction transitions**: a 300ms `AnimatedSwitcher` fades between
  steps. Tiny, but it makes the screen feel alive instead of jumpy.
- **Verb chip**: small orange pill above the instruction (`FRY`, `CHOP`,
  `SIMMER`). Hidden if the model returned `null` for that step's verb.
- **Progress bar**: thin orange bar across the top showing
  `(currentIndex + 1) / steps.length`.

---

## What could go wrong (and what happens)

| Situation | What the user sees |
|---|---|
| No API key set | Error state: *"Anthropic API key not set. Open lib/config/api_keys.dart..."* |
| No internet | Error state: *"SocketException: Failed host lookup..."* + Retry. |
| Claude API down / 5xx | Error state with the status code + Retry. |
| Recipe instructions are very short ("Bake at 180°C for 30 min.") | Player works fine — Claude usually returns 1-2 steps. |
| Recipe instructions are absurdly long | Capped at 2048 output tokens, which covers ~40+ steps. Should be plenty. |
| User taps Cook → Cook → Cook back-to-back | Each tap fires a fresh request. We don't cache between sessions yet (see next steps). |

---

## Costs

For development, this is essentially free. Each recipe → Claude call costs
about **$0.001** (one tenth of a cent). The free trial credit Anthropic
gives new accounts covers **thousands** of recipe loads.

---

## Things to try next (suggestions)

- **Cache the response per recipe** in `shared_preferences`. Same recipe
  tapped a second time → instant load, zero API cost.
- **Hero animation** on the orange Cook button → into the orange action
  colours on the Cook page.
- **Text-to-speech**: read the step aloud so the user doesn't have to look
  at the phone while their hands are dirty.
- **Wake-lock**: keep the screen on while in cook mode.
- **Better error messages** by type (no-internet vs. bad-key vs. server)
  instead of dumping the raw exception text.

---

## Verification

- `flutter analyze` → **No issues found.**
- All new files compile and integrate. The button on `RecipeDetailsPage`
  navigates to `CookModePage` which fires the service call on init.
- Until you paste a real key, the error state appears with a clear
  message — proving the error path works.
