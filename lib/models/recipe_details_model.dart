class RecipeDetailsModel {
  final String id;
  final String title;
  final String image;
  final String area;
  final String instructions;
  final List<String> ingredients;
  final List<String> measures;

  RecipeDetailsModel({
    required this.id,
    required this.title,
    required this.image,
    required this.area,
    required this.instructions,
    required this.ingredients,
    required this.measures,
  });

  factory RecipeDetailsModel.fromMap(Map<String, dynamic> json) {
    List<String> ingredients = [];
    List<String> measures = [];

    for (int i = 1; i <= 20; i++) {
      final ingredient = json["strIngredient$i"];
      final measure = json["strMeasure$i"];

      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add(ingredient);
        measures.add(measure ?? "");
      }
    }

    return RecipeDetailsModel(
      id: json["idMeal"],
      title: json["strMeal"],
      image: json["strMealThumb"],
      area: json["strArea"],
      instructions: json["strInstructions"],
      ingredients: ingredients,
      measures: measures,
    );
  }
}
