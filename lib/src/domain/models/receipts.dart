class BaseReceipt {
  final String servinId;
  final String servinName;
  final String servinNickname;
  final String ownerName;
  final int amount;
  final DateTime periodStartDate;
  final DateTime periodEndDate;
  final DateTime paymentDate;
  final String paymentMethod;
  final String? notes;

  BaseReceipt({
    required this.servinId,
    required this.servinName,
    required this.servinNickname,
    required this.ownerName,
    required this.amount,
    required this.periodStartDate,
    required this.periodEndDate,
    required this.paymentDate,
    this.paymentMethod = 'transfer',
    this.notes,
  });

  factory BaseReceipt.fromJson(Map<String, dynamic> json) => BaseReceipt(
    servinId: json['servinId'],
    servinName: json['servinName'],
    servinNickname: json['servinNickname'],
    ownerName: json['ownerName'],
    amount: json['amount'],
    periodStartDate: DateTime.fromMillisecondsSinceEpoch(json['periodStartDate']),
    periodEndDate: DateTime.fromMillisecondsSinceEpoch(json['periodEndDate']),
    paymentDate: DateTime.fromMillisecondsSinceEpoch(json['paymentDate']),
    paymentMethod: json['paymentMethod'] ?? 'transfer',
    notes: json['notes'],
  );

  Map<String, dynamic> toJson() => {
    'servinId': servinId,
    'servinName': servinName,
    'servinNickname': servinNickname,
    'ownerName': ownerName,
    'amount': amount,
    'periodStartDate': periodStartDate.millisecondsSinceEpoch,
    'periodEndDate': periodEndDate.millisecondsSinceEpoch,
    'paymentDate': paymentDate.millisecondsSinceEpoch,
    'paymentMethod': paymentMethod,
    'notes': notes,
  };
}

class CreateReceipt extends BaseReceipt {
  CreateReceipt({
    required super.servinId,
    required super.servinName,
    required super.servinNickname,
    required super.ownerName,
    required super.amount,
    required super.periodStartDate,
    required super.periodEndDate,
    required super.paymentDate,
    super.paymentMethod = 'transfer',
    super.notes,
  });

  factory CreateReceipt.fromJson(Map<String, dynamic> json) => CreateReceipt(
    servinId: json['servinId'],
    servinName: json['servinName'],
    servinNickname: json['servinNickname'],
    ownerName: json['ownerName'],
    amount: json['amount'],
    periodStartDate: DateTime.fromMillisecondsSinceEpoch(json['periodStartDate']),
    periodEndDate: DateTime.fromMillisecondsSinceEpoch(json['periodEndDate']),
    paymentDate: DateTime.fromMillisecondsSinceEpoch(json['paymentDate']),
    paymentMethod: json['paymentMethod'] ?? 'transfer',
    notes: json['notes'],
  );
}

class UpdateReceipt {
  String? servinId;
  String? servinName;
  String? servinNickname;
  String? ownerName;
  int? amount;
  DateTime? periodStartDate;
  DateTime? periodEndDate;
  DateTime? paymentDate;
  String? paymentMethod;
  String? notes;

  UpdateReceipt({
    this.servinId,
    this.servinName,
    this.servinNickname,
    this.ownerName,
    this.amount,
    this.periodStartDate,
    this.periodEndDate,
    this.paymentDate,
    this.paymentMethod,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'servinId': servinId,
      'servinName': servinName,
      'servinNickname': servinNickname,
      'ownerName': ownerName,
      'amount': amount,
      'periodStartDate': periodStartDate?.millisecondsSinceEpoch,
      'periodEndDate': periodEndDate?.millisecondsSinceEpoch,
      'paymentDate': paymentDate?.millisecondsSinceEpoch,
      'paymentMethod': paymentMethod,
      'notes': notes,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

class ReceiptInDb extends BaseReceipt {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ReceiptInDb({
    required this.id,
    required super.servinId,
    required super.servinName,
    required super.servinNickname,
    required super.ownerName,
    required super.amount,
    required super.periodStartDate,
    required super.periodEndDate,
    required super.paymentDate,
    super.paymentMethod = 'transfer',
    super.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory ReceiptInDb.fromJson(Map<String, dynamic> json) => ReceiptInDb(
    id: json['id'],
    servinId: json['servinId'],
    servinName: json['servinName'],
    servinNickname: json['servinNickname'],
    ownerName: json['ownerName'],
    amount: json['amount'],
    periodStartDate: DateTime.fromMillisecondsSinceEpoch(json['periodStartDate']),
    periodEndDate: DateTime.fromMillisecondsSinceEpoch(json['periodEndDate']),
    paymentDate: DateTime.fromMillisecondsSinceEpoch(json['paymentDate']),
    paymentMethod: json['paymentMethod'] ?? 'transfer',
    notes: json['notes'],
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
    updatedAt: json['updatedAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
        : null,
  );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'id': id,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    });
    return data;
  }
}
