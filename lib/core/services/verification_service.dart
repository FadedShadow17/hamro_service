class VerificationService {
  static bool canPerformAction(String verificationStatus) {
    return verificationStatus == 'APPROVED';
  }

  static String? getErrorMessage(String verificationStatus, {String? rejectionReason}) {
    switch (verificationStatus) {
      case 'NOT_SUBMITTED':
        return 'Please submit your verification documents first';
      case 'PENDING_REVIEW':
        return 'Your verification is pending review. Please wait for approval.';
      case 'REJECTED':
        if (rejectionReason != null && rejectionReason.isNotEmpty) {
          return 'Verification rejected: $rejectionReason. Please resubmit with corrected documents.';
        }
        return 'Your verification was rejected. Please resubmit with corrected documents.';
      case 'APPROVED':
        return null;
      default:
        return 'Provider verification required';
    }
  }

  static bool isVerified(String verificationStatus) {
    return verificationStatus == 'APPROVED';
  }
}
