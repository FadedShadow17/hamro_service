class PricingHelper {
  static double getDefaultPriceForCategory(String categoryTag) {
    final category = categoryTag.toLowerCase();
    
    if (category.contains('cleaning') || category.contains('clean')) {
      return 1000.0;
    } else if (category.contains('plumbing') || category.contains('plumber')) {
      return 1500.0;
    } else if (category.contains('electrical') || category.contains('electric')) {
      return 1200.0;
    } else if (category.contains('carpentry') || category.contains('carpenter')) {
      return 2000.0;
    } else if (category.contains('painting') || category.contains('paint')) {
      return 2500.0;
    } else if (category.contains('gardening') || category.contains('garden')) {
      return 800.0;
    } else if (category.contains('appliance') || category.contains('repair')) {
      return 1500.0;
    }
    
    return 1000.0;
  }
  
  static double getPriceWithFallback(dynamic price, String categoryTag) {
    final priceValue = (price ?? 0.0).toDouble();
    if (priceValue <= 0) {
      return getDefaultPriceForCategory(categoryTag);
    }
    return priceValue;
  }
}
