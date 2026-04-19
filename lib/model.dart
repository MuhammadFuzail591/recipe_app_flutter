class RecipeModel {
  String mealId;
  String mealLabel;
  String mealImageUrl;
  String mealCategory;

  RecipeModel({
    this.mealId = "000",
    this.mealLabel = "LABEL",
    this.mealImageUrl = "IMAGE",
    this.mealCategory = "CATEGORY",
  });

  factory RecipeModel.fromMap(Map recipe) {
    return RecipeModel(
      mealId: recipe["idMeal"],
      mealLabel: recipe["strMeal"],
      mealImageUrl: recipe["strMealThumb"],
      mealCategory: recipe["strCategory"],
    );
  }
}
