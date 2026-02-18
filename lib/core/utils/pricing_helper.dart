class PricingHelper {
  static const double defaultBookingPrice = 5000.0;
  
  static double getDefaultPriceForCategory(String categoryTag) {
    return defaultBookingPrice;
  }
  
  static double getPriceWithFallback(dynamic price, String categoryTag) {
    final priceValue = (price ?? 0.0).toDouble();
    if (priceValue <= 0) {
      return getDefaultPriceForCategory(categoryTag);
    }
    return priceValue;
  }
}
