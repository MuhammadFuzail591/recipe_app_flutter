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
      mealId: recipe["idMeal"],
      mealLabel: recipe["strMeal"],
      mealImageUrl: recipe["strMealThumb"],
      mealArea: recipe["strArea"],
    );
  }
}
