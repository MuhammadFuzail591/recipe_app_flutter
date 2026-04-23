import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:recipe_app/model.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<RecipeModel> recipeList = <RecipeModel>[];
  TextEditingController searchController = TextEditingController();

  void getRecipe(String query) async {
    String url = "https://www.themealdb.com/api/json/v1/1/search.php?s=$query";
    Response response = await get(Uri.parse(url));
    Map data = jsonDecode(response.body);
    // debugPrint(jsonEncode(data), wrapWidth: 1024);

    data["meals"].forEach((meal) {
      RecipeModel recipeModel = RecipeModel();
      recipeModel = RecipeModel.fromMap(meal);
      recipeList.add(recipeModel);
      debugPrint(recipeList.toString());
    });

    recipeList.forEach((recipe) {
      debugPrint(recipe.mealLabel);
      debugPrint(recipe.mealId);
    });
  }

  @override
  void initState() {
    super.initState();
    getRecipe("chicken");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff213A50), Color(0xff071938)],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                // Search Bar
                SafeArea(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    margin: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if ((searchController.text).replaceAll(" ", "") ==
                                "") {
                              debugPrint("Blank search");
                            } else {
                              getRecipe(searchController.text);
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.fromLTRB(3, 0, 7, 0),
                            child: Icon(Icons.search, color: Colors.blueAccent),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Let's Cook Something!",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "WHAT DO YOU WANT TO COOK TODAY?",
                        style: TextStyle(fontSize: 33, color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Let's Cook Something New!",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: recipeList.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {},
                        child: Card(
                          margin: EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0.0,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.network(
                                  recipeList[index].mealImageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 200,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                left: 0,
                                bottom: 0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                  ),
                                  child: Text(
                                    recipeList[index].mealLabel,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                child: Text(recipeList[index].mealArea),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
