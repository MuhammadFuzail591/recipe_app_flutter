# Recipe App — Presentation Content

> 📝 **For the person preparing the slides:** This document has two parts.
>
> 1. **Slide-by-slide content** — every slide has a title, the bullets to
>    put on the slide, and "**Speaker notes**" (what to say out loud).
>    Keep slide text **short**; put detail in the speaker notes.
> 2. **Screenshot playbook** at the end — exact, beginner-friendly steps
>    for capturing every screenshot the slides need. Follow the order;
>    each step tells you what to tap and what should be on screen before
>    you press the capture button.
>
> Screenshot markers in the slides look like this: **`[📷 SS-01]`**.
> The number matches a step in the playbook at the bottom.

**Total slides: 14.** Estimated talk time: **8–10 minutes** at a normal
speaking pace.

---

## Slide 1 — Title

### Recipe App
**An AI-Powered Cooking Companion**

Subtitle: *Discover recipes. Cook them step by step.*

Built with Flutter • Powered by Claude AI • Recipes from TheMealDB

> Team name • Course name • Date

**Speaker notes:**
> Good morning/afternoon. We built a mobile cooking app called Recipe App.
> What makes it interesting is that it doesn't just show you recipes — it
> uses AI to **walk you through cooking them**, step by step, with
> timers. Let me show you what we mean.

---

## Slide 2 — The Problem

### The problem we're solving

- 📖 Recipe websites are a **wall of text**
- 👨‍🍳 Beginners don't know how to follow vague instructions
- ⏱️ "Simmer for 10 minutes" → did you set a timer? Did you forget?
- 🔁 You constantly re-read while your hands are dirty

**Speaker notes:**
> Anyone who has tried a new recipe knows this problem. You read a
> paragraph, do one thing, lose your place, re-read it, your hands are
> covered in flour, you forget if you already added the salt. Cookbooks
> assume you already know how to cook. Beginners don't.

---

## Slide 3 — Our Solution

### Our solution: Cook with me

A **playable** cooking experience that:

- ✅ Breaks any recipe into clear, sequential steps
- ⏲️ Adds a countdown timer to steps that take time
- 🎯 Shows one action at a time — no walls of text
- 🤖 Uses AI to do the parsing — works on **any** recipe

**Speaker notes:**
> Our solution is to treat a recipe like a guided playlist. One step on
> screen at a time. If the step takes time, a countdown timer runs. You
> tap Next when you're ready. The clever part is that we don't pre-write
> these steps for each recipe — we use AI to generate them on demand,
> so the same feature works on any recipe in the database.

---

## Slide 4 — Technology Stack

### Tech stack

| Component | Technology |
|---|---|
| 📱 Framework | **Flutter** (Dart) |
| 🍽️ Recipe data | **TheMealDB** REST API |
| 🤖 AI | **Claude Haiku 4.5** (Anthropic) |
| 🌐 HTTP | `http` package |
| 📦 Platforms | Android & iOS (single codebase) |

**Speaker notes:**
> Flutter for the app — one codebase, runs on Android and iOS. TheMealDB
> is a free recipe API. For AI we picked Claude Haiku — Anthropic's fast,
> low-cost model that's really good at converting unstructured text into
> structured data, which is exactly what we need.

---

## Slide 5 — App Flow

### How the app flows

```
   Home  ──tap category──▶  Filtered meals
    │
    ├──tap meal──▶  Recipe Details  ──tap "Cook with me"──▶  Cook Mode
    │                                                         (AI generates
    └──search──▶  Search Results                                steps live)
```

Three main screens + one AI-powered screen.

**Speaker notes:**
> The app has four screens. Home shows featured meals and categories.
> Tapping a category filters meals. Tapping any meal opens the recipe
> details. From the details page you can either read the recipe normally
> OR hit the big orange Cook button, which opens our AI-powered playable
> mode.

---

## Slide 6 — Home Screen

### Home Screen

**`[📷 SS-01]`** *(Place screenshot of home screen on the right side of the slide)*

Key elements:
- 🔍 Search bar with circular blue search button
- 📋 Horizontally scrollable **category** strip
- ⭐ **"Featured"** section showing Indian meals by default
- 🍛 Live data from TheMealDB

**Speaker notes:**
> This is the home screen. The search bar at the top, the categories
> below the headline, and a Featured section that loads Indian meals
> when the app opens. All of this is live data — we hit TheMealDB API
> on launch.

---

## Slide 7 — Categories filter the list

### Tapping a category filters meals

**`[📷 SS-03]`** *(screenshot showing Seafood category selected, with orange highlight border around it)*

- Tap any category → meals reload instantly
- The selected card gets an **orange border** highlight
- The section title swaps from "Featured" to the category name

**Speaker notes:**
> Categories aren't just decoration — tapping any of them filters the
> meal list below. The selected category gets an orange outline so you
> always know what's active. The "Featured" title also flips to the
> category name — small detail but it tells the user "you're now looking
> at Seafood, not Featured."

---

## Slide 8 — Search

### Search — with a friendly empty-state

**`[📷 SS-04]`** *(screenshot of search results for "chicken")* — **left side**
**`[📷 SS-05]`** *(screenshot of empty-state for "asdfgh")* — **right side**

- 🔍 Full-text search across TheMealDB
- ⬅️ Back button to return home
- 💬 No results? → friendly message that **quotes the user's query**

**Speaker notes:**
> Search runs against the full TheMealDB catalogue. On the left you see
> a normal "chicken" search. On the right is what happens when nothing
> matches — instead of a blank screen, we show a friendly empty-state
> that quotes back exactly what they typed. That makes it personal and
> obvious that the search ran. Small UX touches like this matter.

---

## Slide 9 — Recipe Details

### Recipe Details Page

**`[📷 SS-06]`** *(top half — image, title, Cook button)*

- 🖼️ Hero image + title + cuisine badge
- 🟧 Big orange **"Cook with me"** button — the main action
- 🧾 Ingredients with measures
- 📝 Original instructions

**Speaker notes:**
> When you tap any meal, you land here. Hero image, title, the cuisine
> badge in orange, ingredients with their measures, and the original
> instructions text. But the most important thing on this screen is
> that big orange Cook with me button. That's where the magic happens.

---

## Slide 10 — The Flagship Feature

### Cook with me — the playable mode

**`[📷 SS-09]`** *(cook-mode player view, screenshot in the centre)*

What you get:
- 📊 Progress bar — "Step 3 of 7"
- 🏷️ Orange **verb chip** (e.g. *FRY*, *SIMMER*)
- 📝 One short instruction at a time
- ⏱️ **Countdown timer** when the step takes time
- ⏮️ ⏸️ ⏭️ Prev / Pause / Skip / Next controls

**Speaker notes:**
> This is the flagship feature. One step at a time. A timer for steps
> that take time, like "simmer for 10 minutes". The orange chip at the
> top tells you the action verb — fry, simmer, mix, whatever. You can
> pause if you need to grab something. The progress bar at the top
> shows how far through the recipe you are.

---

## Slide 11 — How the AI works

### How "Cook with me" actually works

```
   Recipe text ──▶  Claude Haiku 4.5  ──▶  Structured JSON ──▶  Player UI
   (one blob)        (with a strict           (guaranteed
                      JSON schema)             shape, no parsing)
```

- We send the recipe to **Claude Haiku 4.5**
- Claude is **forced** to reply via a "tool" with a fixed JSON schema
- Response is **guaranteed** to match the shape — no regex, no parsing
- Cost: **~$0.001 per recipe** | Latency: **1–3 seconds**

**Speaker notes:**
> Here's the technical interesting bit. The recipe text from TheMealDB is
> one big unstructured paragraph. We need a list of steps with timers.
> So we send the recipe to Claude with a special instruction called Tool
> Use — we define a tool with a strict JSON schema describing what we
> want, and we force Claude to respond by calling that tool. The
> response is guaranteed to match the schema. No flaky string parsing.
> No "hope the JSON is valid" — it's validated before we even see it.
> The cost is about a tenth of a cent per recipe and it takes 1 to 3
> seconds.

---

## Slide 12 — Finishing the recipe

### When you finish

**`[📷 SS-11]`** *(last step with Finish button)* — **left**
**`[📷 SS-12]`** *(Enjoy your meal dialog)* — **right**

- Last step → button changes to a green **Finish** button
- Tap Finish → 🎉 "Enjoy your meal!" dialog
- Back to recipe details

**Speaker notes:**
> When you reach the last step, the Next button becomes a Finish button.
> Tap it and you get a little celebration dialog. Small touch, but it
> closes the loop — the user knows they're done. Then back to the
> recipe details page.

---

## Slide 13 — Things we're proud of

### Polish details

- 🎨 Consistent dark gradient theme across all screens
- ✨ Material **ripple feedback** on every tap
- 🎯 **Selected category highlight** (orange border)
- 🌊 Animated step transitions in cook mode (300 ms fade)
- 💬 Empty states that **quote the user's query**
- ⚠️ Friendly error state with **Retry** when AI calls fail
- 🔒 API key **git-ignored** — never committed

**Speaker notes:**
> A few small details we're proud of. Material ripples on every tap, so
> the user always sees feedback. Animated transitions between steps so
> the UI doesn't feel jumpy. The empty-state quoting back your search
> query. The error state with a retry button. And on the engineering
> side — the API key is git-ignored, so it can't accidentally end up in
> the repo.

---

## Slide 14 — Conclusion & Future Work

### What's next

What we built:
- ✅ Browse, search, filter recipes
- ✅ Full details view
- ✅ AI-powered playable cook mode with timers

Future ideas:
- 💾 **Cache** AI responses per recipe — instant on second visit
- 🔊 **Text-to-speech** so the user doesn't have to look at the phone
- 🔐 Backend proxy to hide the API key for production
- 💡 **Wake-lock** to keep screen on while cooking

**Thank you! Questions?**

**Speaker notes:**
> So that's Recipe App. To recap: a Flutter app that browses recipes,
> searches them, and uses Claude AI to turn any recipe into a step-by-
> step playable cooking guide with timers. Future ideas include caching
> AI responses so the same recipe loads instantly the second time, adding
> text-to-speech so you don't have to touch the phone with dirty hands,
> and moving the API key behind a backend for a real production release.
> Thanks for watching — happy to take questions.

---

---

# 📸 Screenshot Playbook — for the person taking the screenshots

> ⚠️ **Read this first.** You don't need to know anything about the app.
> Just follow the steps in order. Each one tells you what to tap and
> what should appear on screen before you press the capture button.

## Before you start

1. Have the app installed and running on a phone (or an emulator).
2. Make sure you have **internet access** — the app fetches recipes
   online and the Cook mode talks to an AI.
3. Use **portrait mode** for all screenshots.
4. Silence the phone or turn on **Do Not Disturb** so no notifications
   appear at the top of the screen.
5. Have a notes app open so you can **rename each screenshot
   immediately** as `SS-01`, `SS-02`, etc.
6. How to take a screenshot:
   - **Android:** Press **Power + Volume Down** together for ~1 second.
   - **iPhone:** Press **Side button + Volume Up** together.
   - **Android emulator:** Click the camera icon in the side toolbar.

You'll need **8 screenshots** total — `SS-01`, `SS-03`, `SS-04`, `SS-05`,
`SS-06`, `SS-09`, `SS-11`, `SS-12`. (We skip `SS-02`, `SS-07`, `SS-08`,
`SS-10`, `SS-13` — those were for a longer report, not this presentation.)

---

## Step-by-step capture instructions

### `SS-01` — Home screen on first launch
1. **Open the app.** Wait ~2 seconds for it to load.
2. You should see:
   - A white pill-shaped search bar at the top with a **blue circular
     search button**
   - The big white headline **"WHAT DO YOU WANT TO COOK TODAY?"**
   - A row of round-corner **category cards** below the headline
   - The word **"Featured"** below the categories
   - A list of Indian meal cards starting underneath
3. **Do not scroll.** Take the screenshot now.
4. Save as `SS-01`.

### `SS-03` — Category selected (Seafood)
1. Still on the home screen.
2. Find the **Seafood** card in the categories row. You may need to
   swipe the categories row left to find it.
3. **Tap the Seafood card.**
4. Wait ~2 seconds for meals to load.
5. You should see:
   - The Seafood card now has an **orange border** around it
   - The section title changed from "Featured" to **"Seafood"**
   - The meal list now shows seafood dishes
6. **Take the screenshot** — make sure the highlighted Seafood card,
   the "Seafood" title, and at least one seafood meal are all visible.
7. Save as `SS-03`.

### `SS-04` — Search results (with results)
1. Scroll back up if needed so the search bar at the top is visible.
2. **Tap inside the search bar.**
3. Type the word **`chicken`** (all lowercase is fine).
4. Tap the **blue circular search button** on the right of the search
   bar — or press the **Enter/Search** key on your keyboard.
5. You should land on a new page showing a list of chicken meals. The
   back arrow is in the top-left.
6. Wait until **2–3 meal cards** are visible.
7. **Take the screenshot.**
8. Save as `SS-04`.

### `SS-05` — Empty-state (no results)
1. **Still on the Search page.** Tap the search bar again.
2. **Clear the text** completely.
3. Type **`asdfgh`** (any nonsense string).
4. Tap the **blue search button** again.
5. Wait ~2 seconds. The page should now show:
   - A 🍽️ "no meals" icon
   - The headline **"No meals found"**
   - A subtitle quoting back your query: *"We couldn't find anything
     for "asdfgh". Try searching for something else!"*
6. **Take the screenshot.**
7. Save as `SS-05`.

### `SS-06` — Recipe Details (top half)
1. Tap the **back arrow** (top-left) to return to home.
2. From the home screen, **tap any meal card** from the Featured list.
   Pick one with a nice-looking image.
3. Wait ~2 seconds for the details to load.
4. You should see:
   - A **big food image** at the top
   - The recipe title below it
   - A small **orange cuisine badge**
   - A **big orange "Cook with me" button** with a knife & fork icon
5. **Do not scroll.** Make sure the orange Cook button is fully visible.
6. **Take the screenshot.**
7. Save as `SS-06`.

### `SS-09` — Cook Mode player (mid-recipe with running timer)
1. **Still on the same details page.** Tap the orange **"Cook with me"**
   button.
2. You'll see a brief loading screen, then the first cook step appears.
3. **You need a step that shows a running countdown timer** — a big
   number like "**05:00**" or "**02:30**" in the centre of the screen.
4. If the very first step has a timer → great, use it.
5. If the first step says **"Tap Next when you're done"** instead of
   showing a number → tap the **Next** button (the right-most circle at
   the bottom of the screen) until you reach a step with a real timer.
6. While the timer is **mid-countdown** (e.g. shows "04:32"), take the
   screenshot. Make sure these elements are all visible:
   - The progress bar at the top
   - The **"Step X of Y"** text
   - The orange **verb chip** at the top (e.g. *FRY*)
   - The instruction text in the centre
   - The countdown timer
   - The Prev / Pause / Next buttons at the bottom
7. Save as `SS-09`.

### `SS-11` — Last step with Finish button
1. **Stay in cook mode.**
2. Tap the **Next** button repeatedly until you reach the **final step**.
   You'll know it's the last step because:
   - The progress bar at the top is **completely full**
   - The "Step X of Y" shows the same number twice (e.g. "Step 7 of 7")
   - The right-most button now shows a **✓ check icon** labelled
     **"Finish"** in bright orange
3. **Take the screenshot.**
4. Save as `SS-11`.

### `SS-12` — Finish dialog
1. **From the last step**, tap the orange **Finish** button.
2. A dialog appears with:
   - The headline **"Enjoy your meal! 🎉"**
   - A line saying *"You're done cooking [recipe name]."*
   - A **"Back to recipe"** button in orange
3. **Take the screenshot** while the dialog is fully visible.
4. Save as `SS-12`.
5. After the screenshot, tap "Back to recipe" to dismiss the dialog.

---

## Quick checklist before you send the screenshots back

- [ ] All 8 screenshots taken: `SS-01`, `SS-03`, `SS-04`, `SS-05`,
      `SS-06`, `SS-09`, `SS-11`, `SS-12`
- [ ] All screenshots are **portrait** orientation
- [ ] All screenshots are clearly named so the person making slides
      can match them to the markers in the slides
- [ ] No personal notifications visible at the top of the screen
- [ ] No system overlays / pop-ups blocking the content

If anything in the app looks different from what's described here, ask
Fuzail before retaking — the app design might have moved on slightly.

Good luck! 📸
