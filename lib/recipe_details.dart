import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:recipe_app/models/recipe_details_model.dart';

class RecipeDetailsPage extends StatefulWidget {
  final String mealId;

  const RecipeDetailsPage({required this.mealId, super.key});

  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  RecipeDetailsModel? meal;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMeal();
  }

  Future<void> fetchMeal() async {
    final url =
        "https://www.themealdb.com/api/json/v1/1/lookup.php?i=${widget.mealId}";

    final response = await get(Uri.parse(url));
    final data = jsonDecode(response.body);
    final mealData = data["meals"][0];

    setState(() {
      meal = RecipeDetailsModel.fromMap(mealData);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTitleSection(),
            _buildIngredients(),
            _buildInstructions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: Image.network(
            meal!.image,
            height: 300,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),

        // Back button
        Positioned(
          top: 40,
          left: 16,
          child: CircleAvatar(
            backgroundColor: Colors.black54,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            meal!.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              meal!.area,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredients() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ingredients",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          ...List.generate(meal!.ingredients.length, (index) {
            return ListTile(
              leading: const Icon(Icons.check, color: Colors.orange),

              title: Text(
                meal!.ingredients[index],
                style: const TextStyle(color: Colors.white),
              ),

              trailing: Text(
                meal!.measures[index],
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    final steps = meal!.instructions.split(
      RegExp(r'step \d+', caseSensitive: false),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Instructions",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          ...steps.asMap().entries.map((entry) {
            if (entry.value.trim().isEmpty) return const SizedBox();

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Step ${entry.key}: ${entry.value.trim()}",
                style: const TextStyle(color: Colors.white),
              ),
            );
          }),
        ],
      ),
    );
  }
}
