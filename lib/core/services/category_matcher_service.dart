class CategoryMatcherService {
  static String normalize(String value) {
    return value.toLowerCase().trim();
  }

  static String? getCategoryFromRole(String role) {
    final normalizedRole = normalize(role);
    final roleToCategoryMap = {
      'electrician': 'electrical',
      'plumber': 'plumbing',
      'cleaner': 'cleaning',
      'carpenter': 'carpentry',
      'painter': 'painting',
      'hvac technician': 'hvac',
      'appliance repair technician': 'appliance repair',
      'gardener/landscaper': 'gardening',
      'pest control specialist': 'pest control',
      'water tank cleaner': 'water tank cleaning',
    };
    return roleToCategoryMap[normalizedRole];
  }

  static String getCategoryFromService(String serviceName) {
    final normalizedService = normalize(serviceName);
    final serviceToCategoryMap = {
      'electrical': 'electrical',
      'plumbing': 'plumbing',
      'cleaning': 'cleaning',
      'carpentry': 'carpentry',
      'painting': 'painting',
      'hvac': 'hvac',
      'appliance repair': 'appliance repair',
      'gardening': 'gardening',
      'pest control': 'pest control',
      'water tank cleaning': 'water tank cleaning',
    };
    return serviceToCategoryMap[normalizedService] ?? normalizedService;
  }

  static bool isCategoryMatch(String providerRole, String serviceCategory) {
    if (providerRole.isEmpty || serviceCategory.isEmpty) {
      return false;
    }

    final roleCategory = getCategoryFromRole(providerRole);
    if (roleCategory == null) {
      return false;
    }

    final serviceCategoryNormalized = getCategoryFromService(serviceCategory);
    return roleCategory == serviceCategoryNormalized;
  }
}
