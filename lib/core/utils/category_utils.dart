import 'package:denzels_cakes/l10n/app_localizations.dart';

class CategoryUtils {
  // Map of category keys (as stored in backend) to localization keys
  static const Map<String, String> categoryKeyMap = {
    'Birthday': 'categoryBirthday',
    'Wedding': 'categoryWedding',
    'Anniversary': 'categoryAnniversary',
    'Baby Shower': 'categoryBabyShower',
    'Faith Celebrations': 'categoryFaithCelebrations',
    'Engagement': 'categoryEngagement',
    'Bridal Shower': 'categoryBridalShower',
    'Gender Reveal': 'categoryGenderReveal',
    'Baptism': 'categoryBaptism',
    'Child Dedication': 'categoryChildDedication',
    'First Communion': 'categoryFirstCommunion',
    'Confirmation': 'categoryConfirmation',
    'Bar Mitzvah': 'categoryBarMitzvah',
    'Bat Mitzvah': 'categoryBatMitzvah',
    'Religious Celebration': 'categoryReligiousCelebration',
    'Christmas': 'categoryChristmas',
    'Easter': 'categoryEaster',
    'New Year': 'categoryNewYear',
    'Thanksgiving': 'categoryThanksgiving',
    'Halloween': 'categoryHalloween',
    'Valentine\'s Day': 'categoryValentinesDay',
    'Mother\'s Day': 'categoryMothersDay',
    'Father\'s Day': 'categoryFathersDay',
    'Independence Day': 'categoryIndependenceDay',
    'St. Patrick\'s Day': 'categoryStPatricksDay',
    'Graduation': 'categoryGraduation',
    'Retirement': 'categoryRetirement',
    'Promotion': 'categoryPromotion',
    'Congratulations': 'categoryCongratulations',
    'Achievement': 'categoryAchievement',
    'Corporate Event': 'categoryCorporateEvent',
    'Office Party': 'categoryOfficeParty',
    'Housewarming': 'categoryHousewarming',
    'Welcome Party': 'categoryWelcomeParty',
    'Farewell Party': 'categoryFarewellParty',
    'Sympathy': 'categorySympathy',
    'Memorial': 'categoryMemorial',
    'Custom Design': 'categoryCustomDesign',
    'General Celebration': 'categoryGeneralCelebration',
  };

  /// Get localized category name
  static String getLocalizedCategory(String categoryKey, AppLocalizations l10n) {
    final localizationKey = categoryKeyMap[categoryKey];
    if (localizationKey == null) {
      return categoryKey; // Fallback to original if not found
    }

    // Use reflection to get the localized string
    switch (localizationKey) {
      case 'categoryBirthday':
        return l10n.categoryBirthday;
      case 'categoryWedding':
        return l10n.categoryWedding;
      case 'categoryAnniversary':
        return l10n.categoryAnniversary;
      case 'categoryBabyShower':
        return l10n.categoryBabyShower;
      case 'categoryFaithCelebrations':
        return l10n.categoryFaithCelebrations;
      case 'categoryEngagement':
        return l10n.categoryEngagement;
      case 'categoryBridalShower':
        return l10n.categoryBridalShower;
      case 'categoryGenderReveal':
        return l10n.categoryGenderReveal;
      case 'categoryBaptism':
        return l10n.categoryBaptism;
      case 'categoryChildDedication':
        return l10n.categoryChildDedication;
      case 'categoryFirstCommunion':
        return l10n.categoryFirstCommunion;
      case 'categoryConfirmation':
        return l10n.categoryConfirmation;
      case 'categoryBarMitzvah':
        return l10n.categoryBarMitzvah;
      case 'categoryBatMitzvah':
        return l10n.categoryBatMitzvah;
      case 'categoryReligiousCelebration':
        return l10n.categoryReligiousCelebration;
      case 'categoryChristmas':
        return l10n.categoryChristmas;
      case 'categoryEaster':
        return l10n.categoryEaster;
      case 'categoryNewYear':
        return l10n.categoryNewYear;
      case 'categoryThanksgiving':
        return l10n.categoryThanksgiving;
      case 'categoryHalloween':
        return l10n.categoryHalloween;
      case 'categoryValentinesDay':
        return l10n.categoryValentinesDay;
      case 'categoryMothersDay':
        return l10n.categoryMothersDay;
      case 'categoryFathersDay':
        return l10n.categoryFathersDay;
      case 'categoryIndependenceDay':
        return l10n.categoryIndependenceDay;
      case 'categoryStPatricksDay':
        return l10n.categoryStPatricksDay;
      case 'categoryGraduation':
        return l10n.categoryGraduation;
      case 'categoryRetirement':
        return l10n.categoryRetirement;
      case 'categoryPromotion':
        return l10n.categoryPromotion;
      case 'categoryCongratulations':
        return l10n.categoryCongratulations;
      case 'categoryAchievement':
        return l10n.categoryAchievement;
      case 'categoryCorporateEvent':
        return l10n.categoryCorporateEvent;
      case 'categoryOfficeParty':
        return l10n.categoryOfficeParty;
      case 'categoryHousewarming':
        return l10n.categoryHousewarming;
      case 'categoryWelcomeParty':
        return l10n.categoryWelcomeParty;
      case 'categoryFarewellParty':
        return l10n.categoryFarewellParty;
      case 'categorySympathy':
        return l10n.categorySympathy;
      case 'categoryMemorial':
        return l10n.categoryMemorial;
      case 'categoryCustomDesign':
        return l10n.categoryCustomDesign;
      case 'categoryGeneralCelebration':
        return l10n.categoryGeneralCelebration;
      default:
        return categoryKey;
    }
  }

  /// Get all category keys (for dropdowns, etc.)
  static List<String> getAllCategoryKeys() {
    return categoryKeyMap.keys.toList()..sort();
  }

  /// Get home page categories (the 5 main ones)
  static List<String> getHomePageCategories() {
    return [
      'Birthday',
      'Wedding',
      'Anniversary',
      'Baby Shower',
      'Faith Celebrations',
    ];
  }

  /// Get all categories for home page with core 5 first, then all others
  static List<String> getAllCategoriesForHomePage() {
    final coreCategories = getHomePageCategories();
    final allCategories = getAllCategoryKeys();
    
    // Get categories that are not in the core list
    final otherCategories = allCategories
        .where((cat) => !coreCategories.contains(cat))
        .toList()
      ..sort();
    
    // Return core categories first, then all others
    return [...coreCategories, ...otherCategories];
  }
}

