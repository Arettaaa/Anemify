class FoodModel {
  final String id;
  final String name;
  final String subtitle;
  final String category;
  final String ironContent;
  final String proteinContent;
  final String? extraNutrient;
  final String fdcId;
  final String description;
  final String tips;
  final String imagePath; // Path gambar di assets/images/

  const FoodModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.category,
    required this.ironContent,
    required this.proteinContent,
    this.extraNutrient,
    required this.fdcId,
    required this.description,
    required this.tips,
    required this.imagePath,
  });
}
