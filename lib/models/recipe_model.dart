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
    return RecipeModel(
      mealId: recipe["idMeal"] ?? "000",
      mealLabel: recipe["strMeal"] ?? "LABEL",
      mealImageUrl: recipe["strMealThumb"] ?? "IMAGE",
      mealArea: recipe["strArea"] ?? "--",
    );
  }
}
