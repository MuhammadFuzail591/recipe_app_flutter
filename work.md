# Work Log

## Task
Make the category cards on the **Home** screen interactive. When the user
taps a category (e.g. *Seafood*, *Beef*, *Chicken* …) the meals for that
category should be fetched from TheMealDB API and rendered below in place of
the existing recipe list.

---

## API Endpoints Used

| Purpose | Endpoint |
|---|---|
| Search meals by name (already used in app) | `https://www.themealdb.com/api/json/v1/1/search.php?s=<query>` |
| **New** — filter meals by category | `https://www.themealdb.com/api/json/v1/1/filter.php?c=<category>` |

### Important difference between the two endpoints
The two endpoints **do not return the same JSON shape**:

| Field | `search.php` | `filter.php` |
|---|---|---|
| `idMeal` | ✅ | ✅ |
| `strMeal` | ✅ | ✅ |
| `strMealThumb` | ✅ | ✅ |
| `strArea` | ✅ | ❌ (missing) |
| (lots of other fields like ingredients, instructions, etc.) | ✅ | ❌ |

`filter.php` only gives us **id + name + thumbnail**. That fact drives one of
the changes below.

---

## Files Changed

### 1. `lib/models/recipe_model.dart`
**Why:** `RecipeModel.fromMap` was reading `recipe["strArea"]` directly. When
the meal comes from `filter.php` that key is `null`, which would crash the app
because `mealArea` is a non-nullable `String`.

**What changed:** Added null-coalescing fallbacks (`??`) for every field so the
model is safe to build from either endpoint. `strArea` falls back to `"--"`
(the dash badge will simply appear in the corner instead of crashing).

```dart
factory RecipeModel.fromMap(Map recipe) {
  return RecipeModel(
    mealId: recipe["idMeal"] ?? "000",
    mealLabel: recipe["strMeal"] ?? "LABEL",
    mealImageUrl: recipe["strMealThumb"] ?? "IMAGE",
    mealArea: recipe["strArea"] ?? "--",
  );
}
```

> 💡 **Lesson:** When the same model is built from multiple API endpoints,
> always check which fields each endpoint actually returns and code
> defensively for the missing ones.

---

### 2. `lib/home.dart`

#### a) New state field — `selectedCategory`
Used purely for UI feedback so the tapped category card gets an orange border
and the user can see what they picked.

```dart
String selectedCategory = "Chicken";
```

#### b) New method — `getRecipeByCategory(String category)`
Mirrors `getRecipe(...)` but uses the `filter.php` endpoint. Steps:

1. **Reset the UI:** clear `recipeList`, turn `isLoading` back on, and update
   `selectedCategory` so the highlight moves immediately.
2. **Hit the API:** `GET filter.php?c=<category>`.
3. **Null guard:** If the API returns `{"meals": null}` (which it does for
   typos or empty categories), simply stop the loader and bail out — no crash.
4. **Parse & rebuild:** Loop the meals, push each into `recipeList` via
   `RecipeModel.fromMap`, then `setState` once at the end with `isLoading = false`.

```dart
void getRecipeByCategory(String category) async {
  setState(() {
    isLoading = true;
    recipeList = <RecipeModel>[];
    selectedCategory = category;
  });

  String url =
      "https://www.themealdb.com/api/json/v1/1/filter.php?c=$category";
  Response response = await get(Uri.parse(url));
  Map data = await jsonDecode(response.body);

  if (data["meals"] == null) {
    setState(() { isLoading = false; });
    return;
  }

  data["meals"].forEach((meal) {
    RecipeModel recipeModel = RecipeModel.fromMap(meal);
    recipeList.add(recipeModel);
  });
  setState(() { isLoading = false; });
}
```

> 💡 **Lesson — small but important:** In the original `getRecipe(...)`,
> `setState` was being called **inside** the `forEach` loop, meaning the
> widget tree rebuilds once per meal. Here we call `setState` **once after
> the loop**. That's the cheaper and idiomatic way.

#### c) Wiring the category card `onTap`
Previously: `onTap: () {}` (did nothing).
Now: calls `getRecipeByCategory` with the tapped category's title.

```dart
onTap: () {
  getRecipeByCategory(mealCategoryList[index].title);
},
```

#### d) Visual highlight for the selected category
Inside `itemBuilder` we compute `isSelected` and, if true, wrap the card with
an orange border so the user can see which one is active.

```dart
final bool isSelected =
    mealCategoryList[index].title == selectedCategory;
// ...
decoration: BoxDecoration(
  borderRadius: BorderRadius.circular(18),
  border: isSelected
      ? Border.all(color: Colors.orangeAccent, width: 3)
      : null,
),
```

---

## Flow Summary (what happens when you tap "Seafood")

1. `onTap` fires → `getRecipeByCategory("Seafood")` runs.
2. `setState` clears the recipe list, sets `isLoading = true`, marks
   `selectedCategory = "Seafood"`. The list area now shows the spinner and
   the *Seafood* card grows an orange border.
3. HTTP GET to `filter.php?c=Seafood` resolves.
4. JSON is decoded; each meal is turned into a `RecipeModel`.
5. Final `setState` flips `isLoading = false` and the meal grid populates.
6. Tapping any meal card still works → opens `RecipeDetailsPage` because
   each card already gets its `mealId` from the model.

---

## Verification
- `flutter analyze` → **No issues found.**
- The category endpoint returns only `idMeal/strMeal/strMealThumb`, so the
  `mealArea` badge on each card will show `"--"` for category-filtered
  results. That's expected — `filter.php` does not provide area data.

---

## Things you could try next (suggestions)
- Replace `"--"` with hiding the area badge entirely when the data isn't
  there (small UI polish).
- Show a friendly "No meals found" message instead of a blank list when
  `data["meals"] == null`.
- Add a `try/catch` around the HTTP call to handle no-internet gracefully.
- Cache the last-tapped category so the home opens on that category next
  time.

---

# Update 2 — Search bar redesign + back button

## Task
1. The search icon was on the **left** of the search bar and looked flat —
   users didn't realise it was clickable. Move it to the **right** and make
   it look like an actual button.
2. On the search results page there was no way to get back to the home page.
   Add a back button.

---

## Files Changed

### 1. `lib/home.dart` — search bar redesign
**Before:** A flat search icon on the left, then the text field. The icon
was wrapped in a `GestureDetector` but had no background, no padding, no
shape — so it looked like decoration, not a button.

**After:** A pill-shaped search bar with:
- Text field on the **left** (room to type).
- A round blue **button** with a white search icon on the **right** — it
  clearly looks tappable.
- A soft `boxShadow` so the whole pill lifts off the dark background.
- The keyboard's "search" action key now triggers the same search via
  `onSubmitted` + `textInputAction: TextInputAction.search`. So the user can
  tap the icon **or** hit enter — either works.

Key snippets:

```dart
// Right-side circular search button
Material(
  color: Colors.blueAccent,
  shape: CircleBorder(),
  child: InkWell(
    customBorder: CircleBorder(),
    onTap: () { /* navigate to Search */ },
    child: Padding(
      padding: EdgeInsets.all(10),
      child: Icon(Icons.search, color: Colors.white, size: 22),
    ),
  ),
),
```

```dart
// Keyboard "search" key support on the text field
TextField(
  controller: searchController,
  textInputAction: TextInputAction.search,
  onSubmitted: (value) { /* navigate to Search */ },
  // ...
)
```

> 💡 **Lesson — why `Material` + `InkWell` instead of `GestureDetector`:**
> `InkWell` gives you a real Material **ripple** on tap, which is the visual
> feedback users expect on Android. `GestureDetector` is invisible — no
> ripple, no hint that anything happened. Wrapping it in `Material` so the
> ripple has a surface to paint on is the canonical pattern.

> 💡 **Lesson — `customBorder: CircleBorder()`:** Without this, the ripple
> would be a rectangle even though the button looks round. `customBorder`
> clips the ripple to the same shape as the button.

---

### 2. `lib/search.dart` — same search bar **+ back button**

The original search bar on this page had the same problem AND there was no
way back. Now the top row is:

```
[ ←  Back ]   [ ───── search field ─────  🔍 ]
```

- **Back button** on the far left: a circular semi-transparent button with a
  back arrow. `Navigator.pop(context)` returns to Home.
- **Search bar** to its right with exactly the same design as the Home page,
  so the UI feels consistent.

Back-button snippet:

```dart
Material(
  color: Colors.white24,
  shape: CircleBorder(),
  child: InkWell(
    customBorder: CircleBorder(),
    onTap: () { Navigator.pop(context); },
    child: Padding(
      padding: EdgeInsets.all(10),
      child: Icon(Icons.arrow_back, color: Colors.white, size: 22),
    ),
  ),
),
```

> 💡 **`pop` vs `pushReplacement`:** `Navigator.pop` returns to the previous
> screen on the stack — perfect for a back button. `pushReplacement` swaps
> the current screen with a new one (we use that when the user runs a *new*
> search from the search page, so we don't pile up Search → Search → Search
> in the stack).

---

## Verification
- `flutter analyze` → **No issues found.**
- Behaviour:
  - Home: tap the blue circle **or** press enter on the keyboard → opens
    Search.
  - Search: tap the back arrow → returns to Home. Type a new query + tap
    the blue circle → replaces current search results (does not stack).

---

## Things you could try next (suggestions)
- Preload the search bar on the Search page with `widget.query` so the user
  can see/edit what they searched for.
- Disable the search button (greyed out) while the text field is empty,
  instead of just debug-printing "Blank search".
- Animate the transition from Home → Search with a `Hero` widget on the
  search bar so it morphs in place.

---

# Update 3 — Featured (Indian) meals on startup + dynamic section title

## Task
1. Replace the awkward "show chicken meals on startup" behaviour with a
   **Featured** section that loads Indian meals on launch.
2. Add a section title above the meal list that says **"Featured"** when
   the app opens, and **switches to the category name** when the user taps
   a category card.

---

## API Endpoint Used

```
https://www.themealdb.com/api/json/v1/1/filter.php?a=India
```

Returns 14 Indian meals with: `idMeal`, `strMeal`, `strMealThumb`,
`strArea`, `strCountry`. Existing `RecipeModel.fromMap` already handles
this shape — no model changes needed.

> 💡 **Gotcha worth remembering — TheMealDB's area filter is inconsistent.**
> The `list.php?a=list` endpoint says the area for Indian food is
> `"Indian"` (the demonym). But the `filter.php?a=Indian` endpoint returns
> `{"meals": null}` — i.e. **no results**. The value that actually works
> is `"India"` (the country name). Other areas are the opposite — e.g.
> `Italian` works but `Italy` doesn't.
>
> Lesson: when an API filter unexpectedly returns null, try the alternate
> spelling / capitalisation / synonym (demonym vs. country name) before
> assuming the data is missing. There is **no documented rule** for which
> areas use which form on TheMealDB — you just have to test.

---

## Files Changed

### `lib/home.dart`

#### a) Removed the old `getRecipe(String query)` method
It existed only to fire `getRecipe("chicken")` on startup. The home screen
no longer searches by name — categories drive everything now — so the
method is gone. The search bar still works because it navigates to the
`Search` page, which has its own copy of `getRecipe`.

#### b) New state field — `sectionTitle`
Drives the text shown above the meal list.

```dart
String selectedCategory = "";   // empty = nothing tapped yet (Featured mode)
String sectionTitle = "Featured";
```

`selectedCategory` is also reset to `""` so the orange "selected" border
isn't drawn on any category card while we're in Featured mode.

#### c) New method — `getFeaturedMeals()`
Same shape as `getRecipeByCategory`, but hits the area-filter endpoint
with `a=India` and sets the section title back to `"Featured"`. Called
from `initState`.

```dart
void getFeaturedMeals() async {
  setState(() {
    isLoading = true;
    recipeList = <RecipeModel>[];
    selectedCategory = "";
    sectionTitle = "Featured";
  });

  String url = "https://www.themealdb.com/api/json/v1/1/filter.php?a=India";
  Response response = await get(Uri.parse(url));
  Map data = await jsonDecode(response.body);

  if (data["meals"] == null) {
    setState(() { isLoading = false; });
    return;
  }

  data["meals"].forEach((meal) {
    recipeList.add(RecipeModel.fromMap(meal));
  });
  setState(() { isLoading = false; });
}
```

#### d) `getRecipeByCategory` now also sets the section title
One extra line in its initial `setState`:

```dart
setState(() {
  isLoading = true;
  recipeList = <RecipeModel>[];
  selectedCategory = category;
  sectionTitle = category;          // ← new
});
```

#### e) New section-title widget in `build`
Inserted **between** the categories scroller and the meals list:

```dart
Container(
  width: double.infinity,
  padding: EdgeInsets.fromLTRB(24, 16, 24, 4),
  child: Text(
    sectionTitle,
    style: TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),
  ),
),
```

`width: double.infinity` is there so the text is left-aligned to the screen
edge rather than collapsing to the width of the text itself — without it,
Containers shrink-wrap to their child.

#### f) `initState` now calls `getFeaturedMeals()` instead of `getRecipe("chicken")`

---

## Flow Summary

1. **App opens** → `getFeaturedMeals()` runs → header reads **"Featured"**
   → 14 Indian meals load.
2. **User taps a category** (say *Seafood*) → `getRecipeByCategory("Seafood")`
   runs → header flips to **"Seafood"** → meal list rebuilds with seafood
   meals. The Seafood card gets the orange border.
3. **User taps the meal card** → still works exactly as before:
   `Navigator.push` to `RecipeDetailsPage(mealId: ...)`.
4. **User taps another category** → header changes again to that category's
   name and the meal list reloads.

---

## Verification
- `flutter analyze` → **No issues found.**
- `curl` confirmed `filter.php?a=India` returns 14 meals with all the
  fields `RecipeModel.fromMap` expects.

---

## Things you could try next (suggestions)
- Add a small "← back to Featured" link / button when a category is
  selected, so the user can return to the Featured list without picking
  another category. (Right now you'd refresh the app to see Featured again.)
- Animate the section-title change (e.g. `AnimatedSwitcher`) so the text
  fades when it flips between "Featured" and the category name.
- Cache the featured response so a second app launch doesn't hit the
  network — same problem we discussed during the design chat.
- Style "Featured" a little differently from the category names (e.g. add
  a tiny ⭐ icon next to it) so it feels special.

---

# Update 4 — Friendly empty-state on Search

## Task
When the user searches for something that has no matching meals (e.g.
"asdf"), show a friendly "No meals found" message instead of a blank
screen or a crash.

---

## The Bug This Also Fixes

The previous `getRecipe` in `search.dart` called `data["meals"].forEach(...)`
directly. The `search.php` endpoint returns `{"meals": null}` when nothing
matches the query — and calling `.forEach` on `null` throws a runtime error.
So before this change, searching for a non-existent meal would actually
**crash the page** (the spinner would just spin forever and you'd see a
`NoSuchMethodError` in the debug console).

> 💡 **Lesson:** Whenever an API can return `null` for a list field, always
> null-guard before iterating. This is the exact same bug we already fixed
> in `home.dart`'s `getRecipeByCategory` and `getFeaturedMeals` — the
> Search page just hadn't gotten the same treatment yet.

---

## Files Changed

### `lib/search.dart`

#### a) Null-guarded `getRecipe`
Bail out early if `data["meals"]` is null. We still flip `isLoading` off so
the spinner stops and the build method can decide what to render.

```dart
if (data["meals"] == null) {
  setState(() { isLoading = false; });
  return;
}
```

Also cleaned up a small issue while I was in there: the old code called
`setState` **inside** the `.forEach` loop (once per meal). Moved it to a
single `setState` after the loop — same fix we made on Home earlier.

#### b) Three-state UI in `build`
The bottom of the page now picks between:

| State | Trigger | Renders |
|---|---|---|
| Loading | `isLoading == true` | `CircularProgressIndicator` |
| Empty | `recipeList.isEmpty` | Friendly empty-state widget |
| Has results | otherwise | The list of meal cards |

The conditional reads top-to-bottom — loading wins first, then empty, then
the list. Written using nested ternaries in the same style the rest of the
file uses:

```dart
child: isLoading
    ? CircularProgressIndicator()
    : recipeList.isEmpty
        ? /* empty-state widget */
        : ListView.builder(/* ... */),
```

#### c) The empty-state widget
- A muted `Icons.no_meals` icon (Flutter ships one — perfect fit).
- Bold "No meals found" headline.
- A subtitle that quotes back **the actual query** so the user knows what
  failed, plus a nudge to try something else:
  *We couldn't find anything for "asdf". Try searching for something else!*

```dart
Padding(
  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 60),
  child: Column(
    children: [
      Icon(Icons.no_meals, color: Colors.white70, size: 80),
      SizedBox(height: 20),
      Text("No meals found", /* big white bold */),
      SizedBox(height: 8),
      Text(
        "We couldn't find anything for \"${widget.query}\".\n"
        "Try searching for something else!",
        textAlign: TextAlign.center,
        /* softer white70 */,
      ),
    ],
  ),
)
```

> 💡 **Small touch:** `widget.query` is interpolated into the subtitle.
> This is why we made `query` a `final` field on the `Search` widget
> earlier — it gives us a stable, page-scoped value we can echo back to
> the user. Showing the exact query the user typed makes the message feel
> personal rather than generic.

> 💡 **Why `Icons.no_meals` and `Colors.white70`:** The icon literally
> means "no meals available" — perfect semantic fit. White70 (white at
> ~70% opacity) is a common Material convention for secondary text/icons
> on dark backgrounds — it reads as "this is here, but it's not the main
> thing."

---

## Verification
- `flutter analyze` → **No issues found.**
- Behaviour test cases:
  - Search **"chicken"** → results show as before.
  - Search **"xyzabc"** (no match) → friendly empty-state appears, with the
    query echoed in the subtitle. Previously this crashed.
  - Back button still returns to Home from the empty-state page.

---

## Things you could try next (suggestions)
- Apply the same null-guard pattern to `home.dart`'s old `getRecipe` — wait,
  we already removed it 🙂 So Home is already safe.
- Add a "Try a popular search" row of suggestion chips (*Chicken*, *Pasta*,
  *Beef*) under the empty-state, each one a tappable shortcut to a new
  search.
- Animate the empty-state in with a fade — feels more polished than it
  just popping into existence.

---

# Update 5 — Playable Cook Mode (live AI)

A big one. The "Cook with me" feature is in.

**Full write-up:** see [`cook_mode.md`](./cook_mode.md) in the project root.
That doc explains everything — the structured AI call, the file map, the UX
choices, the setup steps, costs, and what could go wrong.

**Quick summary of what was added:**

- `lib/config/api_keys.dart` (git-ignored) + `api_keys.example.dart`
  (template). Holds the Anthropic API key.
- `lib/models/cook_step_model.dart` — the `CookStep` class.
- `lib/services/cook_mode_service.dart` — calls Claude (claude-haiku-4-5)
  via the Messages API with **tool use** to force the response into a
  guaranteed JSON shape (no fragile string parsing).
- `lib/cook_mode.dart` — new full-screen `CookModePage` with three states
  (loading / error / player) and prev/pause/skip/next controls.
- `lib/recipe_details.dart` — big orange "Cook with me" button between
  the title and ingredients sections.
- `.gitignore` — one line so the real key never gets committed.

**🔑 BEFORE YOU RUN:** paste your real Anthropic key into
`lib/config/api_keys.dart` (replace `YOUR_API_KEY`). Full instructions
in `cook_mode.md`.

`flutter analyze` → **No issues found.**
