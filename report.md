# Recipe App — Project Report

> 📝 **For the person writing the report:** This document has two parts.
>
> 1. **The report content** — paste the headings and paragraphs straight into
>    your report document (Word / Google Docs). Edit anything that doesn't
>    match your professor's required format.
> 2. **Screenshot instructions** — at the end. A step-by-step playbook for
>    capturing every screenshot the report mentions. Follow the order; each
>    step tells you exactly what to tap and what you should see before you
>    press the capture button.
>
> Screenshot markers in the content look like this: **`[📷 SS-01]`**. The
> number matches the step in the screenshot playbook at the bottom.

---

## 1. Introduction

Recipe App is a mobile cooking companion built with **Flutter** that helps
beginners discover meals and cook them step-by-step. The app sources its
recipes from [TheMealDB](https://www.themealdb.com/) — a free, open recipe
database — and adds a unique AI-powered **"Cook with me"** mode that turns
any recipe's plain-text instructions into a guided, playable cook-along
experience with timers and clear single-action steps.

The motivation behind the app is simple: cookbooks and recipe websites give
you a wall of text and expect you to figure out the rest. A real beginner
needs the recipe broken into small, sequential actions, with a timer for
each step that takes time. Recipe App provides exactly that.

---

## 2. Objectives

1. Build a clean, mobile-first interface for browsing meals by category.
2. Allow free-text search across the entire TheMealDB catalogue with a
   friendly empty-state when nothing matches.
3. Display full recipe details — image, cuisine, ingredients with measures,
   and the original instructions.
4. **Integrate AI-driven structured output** so that on-demand any recipe
   can be converted into a step-by-step playable cooking guide with
   countdown timers.
5. Keep the app responsive and forgiving — show loaders, handle empty API
   responses, and provide retry paths on failure.

---

## 3. Technology Stack

| Layer | Choice |
|---|---|
| Framework | Flutter (Dart) |
| Recipe data source | TheMealDB REST API |
| AI provider | Anthropic Claude (model: `claude-haiku-4-5`) |
| HTTP | `http` package |
| Fonts | Poppins |
| Platforms supported | Android, iOS (single Flutter codebase) |

### Why Claude Haiku?
Claude Haiku 4.5 is Anthropic's fast, low-cost tier and is excellent at
**structured extraction tasks**. It returns a typical recipe-to-steps
breakdown in 1–3 seconds and costs roughly one tenth of a cent per call.
For a feature like "Cook with me" where the model is converting one blob
of text into a known JSON shape, it is the right choice over the larger
and slower Sonnet/Opus models.

---

## 4. App Architecture

The project follows a simple, screen-based layout typical of small Flutter
apps. There is no state-management library — `StatefulWidget` + `setState`
keeps the code easy to read for a learning project.

### Folder layout

```
lib/
├── main.dart                              ← app entry, theme, root widget
├── home.dart                              ← Home screen
├── search.dart                            ← Search results screen
├── recipe_details.dart                    ← Recipe details + "Cook" button
├── cook_mode.dart                         ← Playable cook-along screen
├── config/
│   ├── api_keys.dart                      ← API key (git-ignored)
│   └── api_keys.example.dart              ← Template for collaborators
├── data/
│   └── categories.dart                    ← Hard-coded category list
├── models/
│   ├── recipe_model.dart                  ← List-item recipe shape
│   ├── recipe_details_model.dart          ← Full recipe shape
│   ├── recipe_category_model.dart         ← Category card shape
│   └── cook_step_model.dart               ← One playable step
└── services/
    └── cook_mode_service.dart             ← Calls Claude, returns steps
```

### Navigation flow

```
              ┌────────────┐
              │    Home    │
              │ (Featured  │
              │  Indian    │
              │  meals)    │
              └─────┬──────┘
       ┌────────────┼──────────────┐
       │            │              │
       ▼            ▼              ▼
   Tap a       Tap a meal     Type in search
  category      card            bar + Enter
       │            │              │
       │            │              ▼
       │            │         ┌──────────┐
       │            │         │  Search  │
       │            │         │ results  │
       │            │         └─────┬────┘
       │            │               │
       │            ▼               ▼
       │     ┌──────────────────────────┐
       └────▶│   Recipe Details Page    │
             │   (image, ingredients,   │
             │   instructions, "Cook    │
             │   with me" button)       │
             └────────────┬─────────────┘
                          │
                  Tap "Cook with me"
                          │
                          ▼
                 ┌──────────────────┐
                 │   Cook Mode      │
                 │   (Loading →     │
                 │    AI steps →    │
                 │    Player)       │
                 └──────────────────┘
```

---

## 5. Features (with screenshots)

### 5.1 Home Screen — Featured meals & categories
The home screen opens directly into **Featured** — a curated list of Indian
meals fetched live from TheMealDB. Above the meal list, a horizontally
scrollable strip of category cards (Beef, Chicken, Dessert, Lamb, Pasta,
Seafood, Vegetarian, Breakfast, Goat) lets the user filter by cuisine.

A search bar sits at the top of the screen with a circular blue search
button on the right — tapping it (or hitting Enter on the keyboard) sends
the user to the dedicated search results page.

**`[📷 SS-01]` — Home screen on first launch (Featured)**
**`[📷 SS-02]` — Category list scrolled horizontally**

When a category card is tapped, the section title above the meal list
swaps from "Featured" to the category name (e.g. "Seafood"), and the
meal list reloads with that category's meals. The selected card grows
an orange highlight border so the user always knows which filter is
active.

**`[📷 SS-03]` — After tapping a category (e.g. Seafood)**

### 5.2 Search — with friendly empty-state
Tapping the search button (or pressing Enter) navigates to the Search
results page. The same search bar is at the top — but with a back button
on the left so the user can return to Home. The screen shows the full
list of meals matching the query in a clean card layout.

**`[📷 SS-04]` — Search results page for a real query (e.g. "chicken")**

If the query has no matches, instead of a blank screen the app shows a
friendly empty-state widget with a 🍽️ icon, "No meals found" headline,
and a subtitle that **quotes the user's actual query** back to them, e.g.:

> *We couldn't find anything for "asdf".
> Try searching for something else!*

This is intentionally personal — it makes it obvious that the search ran,
the result was empty, and the user should try something different.

**`[📷 SS-05]` — Empty-state for a no-match query (e.g. "asdf")**

### 5.3 Recipe Details
Tapping any meal card opens the Recipe Details page. The page shows:

- A large hero image with a back button on top
- The recipe title and a cuisine badge
- A bold orange **"Cook with me"** call-to-action button — the main
  action of the screen
- Full list of ingredients with their measures
- The original instructions text from TheMealDB

**`[📷 SS-06]` — Recipe Details page (top half: image + title + Cook button)**
**`[📷 SS-07]` — Recipe Details page (scrolled down to ingredients + instructions)**

### 5.4 Cook with me — AI-powered playable mode

This is the flagship feature of the app. When the user taps **Cook with
me**, the following happens behind the scenes:

1. The app sends the recipe (name, ingredients, instructions) to Claude
   Haiku 4.5 via the Anthropic Messages API.
2. The request includes a **JSON schema** that locks the response shape —
   it specifies that Claude must return an ordered list of steps, each
   with an instruction sentence, an optional duration in seconds, and an
   optional action verb.
3. Claude responds within 1–3 seconds with the validated, structured
   step list. No string parsing or fragile regex is needed on the app
   side — the response is guaranteed to match the schema.
4. The app renders the steps in a dedicated player UI.

**`[📷 SS-08]` — Cook mode while loading ("Preparing your recipe…")**

The Cook Mode player UI includes:

- A progress bar across the top showing how many steps remain
- A "Step X of Y" counter
- A small orange verb chip (e.g. **FRY**, **CHOP**, **SIMMER**) that
  describes the step's action at a glance
- The instruction text in large, centred typography
- A **countdown timer** for steps that have an implied duration (e.g.
  "Simmer for 10 minutes" → a 10:00 countdown), or "Tap Next when you're
  done" for open-ended steps (e.g. "Season to taste")
- Four control buttons: **Prev**, **Pause/Resume**, **Next**, and on the
  final step a **Finish** button

When the timer hits zero the **Next** button changes colour to orange,
signalling "you can move on now." The app deliberately does **not**
auto-advance — that would be rude if the user is still chopping.

**`[📷 SS-09]` — Cook mode player view (mid-recipe, with a running timer)**
**`[📷 SS-10]` — Cook mode player view when timer hits 00:00 (Next is highlighted orange)**
**`[📷 SS-11]` — Cook mode on the last step (Finish button visible)**
**`[📷 SS-12]` — The "Enjoy your meal! 🎉" finish dialog**

### 5.5 Error handling
If the AI call fails (no internet, API issue, etc.) the user sees a
friendly error state with the exact reason and a **Retry** button. The
same screen is used for any failure path — recipe with no instructions,
malformed response, or transient API outage.

**`[📷 SS-13]` — Cook mode error state (optional — see screenshot playbook
for how to trigger this safely)**

---

## 6. AI Integration — How it works (technical detail)

This section is for the technical chapter of the report. It explains why
the AI integration is reliable and not "the model hallucinated something."

### Structured output via Tool Use
The Anthropic Messages API supports a feature called **tool use** where
the developer can declare one or more "tools" that the model is allowed
to call. Each tool has an `input_schema` (JSON Schema) describing the
shape of its arguments.

The app declares a single tool called `submit_cook_steps` with a schema
that requires:

```json
{
  "steps": [
    {
      "order": <integer, 1-based>,
      "instruction": "<short imperative sentence>",
      "durationSeconds": <integer or null>,
      "verb": "<short verb or null>"
    },
    ...
  ]
}
```

Then the request is sent with the parameter:

```json
"tool_choice": { "type": "tool", "name": "submit_cook_steps" }
```

This forces Claude to reply by **calling that tool**. Claude is not
allowed to respond with free-form text. The response arrives as a
`tool_use` block whose `input` field is JSON validated against the
schema. The app parses this directly into a `List<CookStep>`.

This is the **official Anthropic-recommended pattern for structured
output** and is what makes the feature reliable — there is no regex, no
"hope the model returned valid JSON" parsing, no try/catch around a
fragile `jsonDecode`.

### The prompt
The prompt sent to Claude includes the recipe name, the full ingredient
list with measures, the raw `strInstructions` blob, and seven explicit
rules:

1. Each step is **one short imperative sentence** (under 25 words).
2. Combined sentences with multiple actions get **split** ("chop onions
   and fry them" → two steps).
3. `durationSeconds` is set **only** when the recipe implies a time
   (e.g. "simmer 10 minutes" → 600); otherwise `null`.
4. Preheat steps default to 600 seconds (10 minutes).
5. The `verb` is a single-word action (chop, fry, simmer, mix, preheat,
   bake…) or `null`.
6. The model must not **invent** steps that aren't in the original
   instructions.
7. Step `order` starts at 1 and increments by 1.

### Cost & latency
- **Latency:** typically 1–3 seconds per recipe.
- **Cost:** roughly **$0.001 per recipe** (one tenth of a cent). The free
  trial credit Anthropic gives new accounts covers thousands of
  conversions, more than enough for development and demos.

### Security note
The Anthropic API key is stored in `lib/config/api_keys.dart`, which is
**git-ignored**. A template (`api_keys.example.dart`) is committed so
collaborators know what to fill in. For a production release the key
would be moved behind a backend proxy, but for this learning project the
client-side key is appropriate.

---

## 7. UX touches worth mentioning

A handful of small polish details that improve the feel of the app:

- **Soft drop shadow** under the search bar pill to lift it off the dark
  gradient background.
- **Material InkWell ripples** on all tappable buttons — never bare
  `GestureDetector` — so every tap gives the user real visual feedback.
- **Animated step transitions** in Cook mode use a 300 ms `AnimatedSwitcher`
  so the instruction text fades between steps instead of popping in.
- **Selected-category highlight** — an orange border draws around the
  currently active category card.
- The cook-mode **progress bar** and **verb chip** make it obvious at a
  glance where in the recipe the user is and what action they're doing.
- **`white70` for secondary text** on dark backgrounds throughout —
  consistent Material convention.

---

## 8. Future enhancements

Things explored or considered but left for later:

- **Caching** of AI responses per `mealId` (e.g. in `shared_preferences`)
  so the second time a user cooks the same recipe, it's instant and
  costs nothing.
- **Text-to-speech** of the current step so the user doesn't have to
  look at the phone with messy hands.
- A **backend proxy** that holds the Claude API key, removing it from
  the client.
- **Wake-lock** to keep the screen on during Cook mode.
- **Hero animations** between the Cook button and the cook-mode screen
  for a more cinematic transition.

---

## 9. Conclusion

The app demonstrates how a small, well-scoped Flutter project can
integrate a modern LLM API for a feature that genuinely improves user
experience — converting messy human-written recipe instructions into
guided, timed steps. The architecture is simple by design: ordinary
StatefulWidgets, ordinary HTTP calls, and a single thin service layer
that wraps the AI call. The complexity that would normally come with
"parse the model's output" is **eliminated** by using the API's
structured-output mechanism.

This results in a small, readable codebase that nonetheless ships a
genuinely useful AI-powered feature.

---

---

# 📸 Screenshot Playbook — for the person taking the screenshots

> ⚠️ **Read this carefully — it walks you through the app step by step.**
> You don't need to know anything about the app beforehand. Just follow
> the steps in order. Take each screenshot when it tells you to.

## Before you start
1. Have the app installed and running on a phone (or in an emulator).
2. Have an **active internet connection** — the app fetches recipes
   online, and the Cook mode talks to an AI.
3. Make sure your phone is in **portrait mode**. All screenshots should
   be portrait.
4. Have a **notepad / Notes app open** so you can label each screenshot
   immediately after taking it. Use the names below (`SS-01`, `SS-02`,
   etc.).
5. How to take a screenshot on Android: press **Power + Volume Down**
   together for ~1 second. (On iPhone: **Side button + Volume Up**.)
   On an emulator: use the camera icon in the emulator toolbar.

---

## Step-by-step capture instructions

### `SS-01` — Home screen on first launch (Featured)
1. **Open the app.** Wait ~2 seconds for it to load.
2. You should see:
   - A white search bar at the top with a blue circular search button
   - A big white headline "WHAT DO YOU WANT TO COOK TODAY?"
   - A horizontal row of round-corner category cards
   - The word **"Featured"** below the categories
   - A list of meal cards starting with **"Featured"** Indian dishes
3. **Do not scroll yet.** While the meal list is still at the very top,
   **take the screenshot.**
4. Save it as `SS-01`.

### `SS-02` — Category list scrolled horizontally
1. Stay on the home screen.
2. Find the row of category cards (Beef, Chicken, Dessert, etc.).
3. **Swipe left across that row only** with your finger — slide the
   row about halfway through, so cards like Seafood, Vegetarian,
   Breakfast become visible.
4. **Take the screenshot** while showing categories that weren't visible
   in `SS-01` (so the reader can see that there are more categories).
5. Save as `SS-02`.

### `SS-03` — Category selected (Seafood)
1. Tap the **Seafood** card in the categories row.
2. Wait ~2 seconds for meals to load.
3. You should see:
   - The Seafood card now has an **orange border** around it
   - The section title above the meal list changed from "Featured" to
     **"Seafood"**
   - The meal list now shows seafood dishes
4. **Take the screenshot** with both the highlighted Seafood card AND
   the "Seafood" title AND at least one seafood meal visible.
5. Save as `SS-03`.

### `SS-04` — Search results page (with results)
1. Scroll back to the top of the home screen if needed.
2. Tap inside the **white search bar at the top**.
3. Type the word **`chicken`** (lowercase is fine).
4. Tap the **blue circular search button** on the right of the search
   bar (or press the Enter/Search key on your keyboard).
5. You should land on a new page that shows a list of chicken meals.
   The back arrow is in the top-left.
6. Wait until at least 2–3 meal cards are visible.
7. **Take the screenshot.**
8. Save as `SS-04`.

### `SS-05` — Empty-state (no results)
1. **Still on the Search page,** tap the search bar (it now contains
   "chicken" or is empty).
2. **Clear the text**, then type **`asdfgh`** (any nonsense string).
3. Tap the **blue search button** again.
4. Wait ~2 seconds. The page should now show:
   - A 🍽️ icon
   - The headline **"No meals found"**
   - A subtitle that quotes back "asdfgh": *"We couldn't find anything
     for "asdfgh". Try searching for something else!"*
5. **Take the screenshot.**
6. Save as `SS-05`.

### `SS-06` — Recipe Details (top half)
1. Tap the **back arrow** (top-left) to return to home.
2. From the home screen, tap any meal card from the "Featured" list — a
   good visually appealing one would be the **first Indian dish**.
3. Wait ~2 seconds for the details to load.
4. You should see a big food image at the top, the recipe title below
   it, a small orange cuisine badge, and a **big orange "Cook with me"
   button** with a knife & fork icon.
5. **Do not scroll.** Make sure the orange Cook button is fully visible.
6. **Take the screenshot.**
7. Save as `SS-06`.

### `SS-07` — Recipe Details (scrolled to ingredients + instructions)
1. **Stay on the same details page.**
2. **Scroll down** slowly until you can see:
   - The end of the **Ingredients** list (orange tick marks beside each
     ingredient)
   - The start of the **Instructions** section
3. **Take the screenshot** when both sections are visible together.
4. Save as `SS-07`.

### `SS-08` — Cook Mode loading
1. **Scroll back up** on the details page until the orange "Cook with
   me" button is visible.
2. **Tap "Cook with me".**
3. You should land on a dark gradient screen showing:
   - An orange spinning circle
   - The text **"Preparing your recipe…"**
   - The smaller text **"Breaking it into easy steps for you"**
4. ⏱️ **You only have 1–3 seconds before the loading state disappears**
   and the steps appear. Have your finger ready on the screenshot
   buttons BEFORE tapping Cook.
5. **Take the screenshot quickly.**
6. Save as `SS-08`.
7. If you missed it, tap the **✕** in the top-left, go back to the
   details page, and tap "Cook with me" again. Try once more.

### `SS-09` — Cook Mode player (mid-recipe with running timer)
1. After the loading screen disappears, you'll see the first cook step.
2. If the first step has **a timer** (big "00:30" style number on screen,
   not "Tap Next when you're done"), use this step.
3. If the first step has no timer, tap the **Next** button (the right-
   most circular button at the bottom) until you reach a step with a
   running timer.
4. **Take the screenshot** while the timer is mid-countdown (e.g.
   shows "04:32" or similar). The screenshot should include:
   - The progress bar at the top
   - The "Step X of Y" text
   - The orange verb chip (e.g. **FRY**)
   - The instruction text
   - The countdown timer
   - The Prev / Pause / Next buttons
5. Save as `SS-09`.

### `SS-10` — Timer finished, Next highlighted
1. **Stay in cook mode.** Wait for the timer to count all the way down
   to **00:00**. (Tip: if the timer is very long, tap **Pause** to stop
   it, then take the screenshot in SS-09 first, then move on — you can
   come back for this one. Or pick a recipe with shorter timers.)
2. Once the timer shows **00:00 in green**, you should see:
   - The text **"Time's up! Tap next when ready."**
   - The **Next** button glowing **bright orange** (it was white before)
3. **Take the screenshot.**
4. Save as `SS-10`.

### `SS-11` — Last step with Finish button
1. **Stay in cook mode.** Tap **Next** repeatedly until you reach the
   final step. You'll know it's the last step because:
   - The progress bar at the top is completely full
   - The "Step X of Y" shows the same numbers (e.g. "Step 7 of 7")
   - The right-most button now shows a **✓ check icon** and is labelled
     **"Finish"** in bright orange
2. **Take the screenshot.**
3. Save as `SS-11`.

### `SS-12` — Finish dialog
1. **From the last step**, tap the orange **Finish** button.
2. A dialog appears with:
   - The headline **"Enjoy your meal! 🎉"**
   - A line saying *"You're done cooking [recipe name]."*
   - A **"Back to recipe"** button in orange
3. **Take the screenshot** while the dialog is fully visible.
4. Save as `SS-12`.
5. Tap "Back to recipe" to dismiss.

### `SS-13` — Error state (OPTIONAL — only if requested)
This screenshot shows what happens when the AI call fails. It's optional
— include it only if your professor asks to see error handling.

**Safe way to trigger it:**
1. **Turn off your phone's Wi-Fi AND mobile data** (Airplane mode is
   easiest — just enable Airplane mode).
2. Go to any recipe details page (you may have to do this BEFORE turning
   off internet, then navigate back).
3. Tap **"Cook with me"**.
4. After the spinner runs for ~10 seconds it will fail and show:
   - A 🟧 warning icon
   - **"Couldn't prepare your recipe"** headline
   - A small grey error message below it
   - A **Back** button and an orange **Retry** button
5. **Take the screenshot.**
6. Save as `SS-13`.
7. **Turn the internet back on** when done.

---

## Quick checklist before you send the screenshots back

- [ ] All 12 (or 13) screenshots taken
- [ ] All screenshots are **portrait** orientation
- [ ] All screenshots are clearly labelled `SS-01` through `SS-12` (and
      `SS-13` if you took the optional one)
- [ ] No personal notifications visible at the top of the screen
      (silence the phone first, or use Do Not Disturb)
- [ ] No system overlays or pop-ups blocking the app content

If anything in the app looks different from what's described here, ask
Fuzail before retaking — the app design might have moved on slightly.

Good luck! 📸
