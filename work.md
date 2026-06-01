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
