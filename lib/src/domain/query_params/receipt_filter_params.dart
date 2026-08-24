class ReceiptFilterParams {
  final String? servinId;

  ReceiptFilterParams({this.servinId});

  Map<String, String> toMap() {
    final map = <String, String>{};
    if (servinId != null && servinId!.trim().isNotEmpty) {
      map['servinId'] = servinId!.trim();
    }
    return map;
  }
}
