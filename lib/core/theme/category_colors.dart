import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../data/models/subscription_model.dart';

class CategoryStyle {
  final Color bgDark;
  final Color bgLight;
  final Color accent;

  const CategoryStyle({
    required this.bgDark,
    required this.bgLight,
    required this.accent,
  });
}

class CategoryColors {
  static const Map<SubscriptionCategory, CategoryStyle> styles = {
    SubscriptionCategory.streaming: CategoryStyle(
      bgDark: AppColors.streamingDark,
      bgLight: AppColors.streamingLight,
      accent: AppColors.streamingAccent,
    ),
    SubscriptionCategory.software: CategoryStyle(
      bgDark: AppColors.softwareDark,
      bgLight: AppColors.softwareLight,
      accent: AppColors.softwareAccent,
    ),
    SubscriptionCategory.gaming: CategoryStyle(
      bgDark: AppColors.gamingDark,
      bgLight: AppColors.gamingLight,
      accent: AppColors.gamingAccent,
    ),
    SubscriptionCategory.news: CategoryStyle(
      bgDark: AppColors.newsDark,
      bgLight: AppColors.newsLight,
      accent: AppColors.newsAccent,
    ),
    SubscriptionCategory.fitness: CategoryStyle(
      bgDark: AppColors.fitnessDark,
      bgLight: AppColors.fitnessLight,
      accent: AppColors.fitnessAccent,
    ),
    SubscriptionCategory.education: CategoryStyle(
      bgDark: AppColors.educationDark,
      bgLight: AppColors.educationLight,
      accent: AppColors.educationAccent,
    ),
    SubscriptionCategory.cloud: CategoryStyle(
      bgDark: AppColors.cloudDark,
      bgLight: AppColors.cloudLight,
      accent: AppColors.cloudAccent,
    ),
    SubscriptionCategory.other: CategoryStyle(
      bgDark: AppColors.otherDark,
      bgLight: AppColors.otherLight,
      accent: AppColors.otherAccent,
    ),
  };

  static CategoryStyle of(SubscriptionCategory category) {
    return styles[category] ??
        const CategoryStyle(
          bgDark: AppColors.otherDark,
          bgLight: AppColors.otherLight,
          accent: AppColors.otherAccent,
        );
  }
}