class VerificationService {
  static bool canPerformAction(String verificationStatus) {
    return verificationStatus == 'verified';
  }

  static String? getErrorMessage(String verificationStatus, {String? rejectionReason}) {
    switch (verificationStatus) {
      case 'not_submitted':
        return null;
      case 'pending':
        return 'Your verification is being processed by admin.';
      case 'verified':
        return null;
      default:
        return 'Please submit your verification documents first';
    }
  }

  static bool isVerified(String verificationStatus) {
    return verificationStatus == 'verified';
  }
}
