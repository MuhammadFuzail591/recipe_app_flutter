import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:recipe_app/config/api_keys.dart';
import 'package:recipe_app/models/cook_step_model.dart';
import 'package:recipe_app/models/recipe_details_model.dart';

class CookModeService {
  static const String _model = "claude-haiku-4-5";
  static const String _endpoint = "https://api.anthropic.com/v1/messages";

  static const Map<String, dynamic> _toolSchema = {
    "type": "object",
    "properties": {
      "steps": {
        "type": "array",
        "description":
            "Ordered list of cook-along steps. Each step is one short, "
            "actionable instruction the user performs before moving on.",
        "items": {
          "type": "object",
          "properties": {
            "order": {
              "type": "integer",
              "description": "1-based step number.",
            },
            "instruction": {
              "type": "string",
              "description":
                  "One short imperative sentence telling the user what to do. "
                  "Keep it under 25 words.",
            },
            "durationSeconds": {
              "type": ["integer", "null"],
              "description":
                  "How long this step takes in seconds. Use null if the "
                  "recipe does not imply a duration (e.g. 'season to taste').",
            },
            "verb": {
              "type": ["string", "null"],
              "description":
                  "Short single-word action verb (e.g. 'chop', 'simmer', "
                  "'fry', 'preheat', 'mix'). Null if unclear.",
            },
          },
          "required": ["order", "instruction", "durationSeconds", "verb"],
        },
      },
    },
    "required": ["steps"],
  };

  static Future<List<CookStep>> generateSteps(RecipeDetailsModel recipe) async {
    if (ApiKeys.anthropic == "YOUR_API_KEY" || ApiKeys.anthropic.isEmpty) {
      throw Exception(
        "Anthropic API key not set. Open lib/config/api_keys.dart and "
        "replace YOUR_API_KEY with your real key.",
      );
    }

    final prompt = _buildPrompt(recipe);

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        "Content-Type": "application/json",
        "x-api-key": ApiKeys.anthropic,
        "anthropic-version": "2023-06-01",
      },
      body: jsonEncode({
        "model": _model,
        "max_tokens": 2048,
        "tools": [
          {
            "name": "submit_cook_steps",
            "description":
                "Submit the parsed cook-along steps for the recipe. "
                "Call this exactly once with the full list of steps.",
            "input_schema": _toolSchema,
          },
        ],
        "tool_choice": {"type": "tool", "name": "submit_cook_steps"},
        "messages": [
          {"role": "user", "content": prompt},
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Claude API error ${response.statusCode}: ${response.body}",
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    final contentBlocks = body["content"] as List;
    final toolUse = contentBlocks.firstWhere(
      (block) => block["type"] == "tool_use",
      orElse: () =>
          throw Exception("Claude did not return a tool_use block: $body"),
    );

    final input = toolUse["input"] as Map<String, dynamic>;
    final stepsJson = input["steps"] as List;

    return stepsJson
        .map((s) => CookStep.fromMap(s as Map<String, dynamic>))
        .toList();
  }

  static String _buildPrompt(RecipeDetailsModel recipe) {
    final ingredientsList = List.generate(
      recipe.ingredients.length,
      (i) => "  - ${recipe.measures[i]} ${recipe.ingredients[i]}",
    ).join("\n");

    return """
You are helping a beginner cook follow a recipe step-by-step in a mobile app.

Recipe: ${recipe.title}
Cuisine: ${recipe.area}

Ingredients:
$ingredientsList

Raw instructions:
${recipe.instructions}

Your job: break the raw instructions into a clean, ordered list of cook-along
steps for the app. Follow these rules strictly:

1. Each step should be ONE short imperative sentence (under 25 words).
2. Split combined sentences into separate steps when each part is a distinct
   action (e.g. "chop onions and fry them" → two steps).
3. For each step, estimate durationSeconds ONLY if the recipe explicitly or
   strongly implies a time (e.g. "simmer 10 minutes" → 600). Use null for
   open-ended steps like "season to taste" or "mix until smooth".
4. For preheat steps, use 600 seconds (10 minutes) as a sensible default.
5. Add a single-word `verb` describing the action (chop, fry, simmer, mix,
   preheat, bake, etc.). Use null if no clear verb fits.
6. Do not invent steps that aren't in the original instructions.
7. Order should start at 1 and increment by 1.

Call the submit_cook_steps tool with the result.
""";
  }
}
