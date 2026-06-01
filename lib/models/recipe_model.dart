class RecipeModel {
  String mealId;
  String mealLabel;
  String mealImageUrl;
  String mealArea;

  RecipeModel({
    this.mealId = "000",
    this.mealLabel = "LABEL",
    this.mealImageUrl = "IMAGE",
    this.mealArea = "AREA",
  });

  factory RecipeModel.fromMap(Map recipe) {
    // Note: the filter.php endpoint does NOT return strArea, so we fall back
    // to a default ("--") to avoid a null crash on the area badge.
    return RecipeModel(
      mealId: recipe["idMeal"] ?? "000",
      mealLabel: recipe["strMeal"] ?? "LABEL",
      mealImageUrl: recipe["strMealThumb"] ?? "IMAGE",
      mealArea: recipe["strArea"] ?? "--",
    );
  }
}
