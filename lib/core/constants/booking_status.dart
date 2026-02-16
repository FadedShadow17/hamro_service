class BookingStatus {
  static const String pending = 'PENDING';
  static const String confirmed = 'CONFIRMED';
  static const String completed = 'COMPLETED';
  static const String declined = 'DECLINED';
  static const String cancelled = 'CANCELLED';

  static String toDisplayLabel(String status) {
    switch (status.toUpperCase()) {
      case pending:
        return 'Pending';
      case confirmed:
        return 'Confirmed';
      case completed:
        return 'Completed';
      case declined:
        return 'Declined';
      case cancelled:
        return 'Cancelled';
      default:
        return status;
    }
  }

  static bool canAccept(String status) {
    return status.toUpperCase() == pending;
  }

  static bool canDecline(String status) {
    return status.toUpperCase() == pending;
  }

  static bool canComplete(String status) {
    return status.toUpperCase() == confirmed;
  }

  static bool canCancel(String status) {
    final upperStatus = status.toUpperCase();
    return upperStatus == pending || upperStatus == confirmed;
  }
}
