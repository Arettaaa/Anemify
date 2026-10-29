import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/models/article_model.dart';
import '../widgets/article_detail_sheet.dart';

void showArticleDetailModal(BuildContext context, ArticleModel article) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: ArticleDetailSheet(article: article),
      );
    },
  );
}
