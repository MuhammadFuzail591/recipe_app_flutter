import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:recipe_app/models/recipe_model.dart';
import 'package:recipe_app/data/categories.dart';
import 'package:recipe_app/recipe_details.dart';
import 'package:recipe_app/search.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = true;
  List<RecipeModel> recipeList = <RecipeModel>[];
  TextEditingController searchController = TextEditingController();
  String selectedCategory = "";
  String sectionTitle = "Featured";

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
      setState(() {
        isLoading = false;
      });
      return;
    }

    data["meals"].forEach((meal) {
      RecipeModel recipeModel = RecipeModel.fromMap(meal);
      recipeList.add(recipeModel);
    });
    setState(() {
      isLoading = false;
    });
  }

  void getRecipeByCategory(String category) async {
    setState(() {
      isLoading = true;
      recipeList = <RecipeModel>[];
      selectedCategory = category;
      sectionTitle = category;
    });

    String url =
        "https://www.themealdb.com/api/json/v1/1/filter.php?c=$category";
    Response response = await get(Uri.parse(url));
    Map data = await jsonDecode(response.body);

    if (data["meals"] == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    data["meals"].forEach((meal) {
      RecipeModel recipeModel = RecipeModel.fromMap(meal);
      recipeList.add(recipeModel);
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getFeaturedMeals();
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
                SafeArea(
                  child: Container(
                    padding: EdgeInsets.only(left: 20, right: 6),
                    margin: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (value) {
                              if (value.replaceAll(" ", "") == "") {
                                debugPrint("Blank search");
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Search(query: value),
                                  ),
                                );
                              }
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Let's Cook Something!",
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.blueAccent,
                          shape: CircleBorder(),
                          child: InkWell(
                            customBorder: CircleBorder(),
                            onTap: () {
                              if ((searchController.text).replaceAll(" ", "") ==
                                  "") {
                                debugPrint("Blank search");
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        Search(query: searchController.text),
                                  ),
                                );
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 22,
                              ),
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

                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    itemCount: mealCategoryList.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final bool isSelected =
                          mealCategoryList[index].title == selectedCategory;
                      return Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: isSelected
                              ? Border.all(color: Colors.orangeAccent, width: 3)
                              : null,
                        ),
                        child: InkWell(
                          onTap: () {
                            getRecipeByCategory(mealCategoryList[index].title);
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0.0,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(18.0),
                                  child: Image.network(
                                    mealCategoryList[index].imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(18),
                                        bottomRight: Radius.circular(18),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          mealCategoryList[index].title,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

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

                Container(
                  child: isLoading
                      ? CircularProgressIndicator()
                      : ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: recipeList.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RecipeDetailsPage(
                                      mealId: recipeList[index].mealId,
                                    ),
                                  ),
                                );
                              },
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
                                      right: 5,
                                      top: 5,
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          color: Colors.black54,
                                        ),
                                        child: Text(
                                          recipeList[index].mealArea,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
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
