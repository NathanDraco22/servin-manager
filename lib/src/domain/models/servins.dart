enum ServinType { neptuno, mercury, serum }

class BaseServin {
  final String name;
  final String nickname;
  final String ownerName;
  final ServinType type;
  final String url;
  final bool isMultiBranch;
  final bool isUsingExpirationDate;
  final bool isActive;
  final int price;
  final int? paymentDate;

  BaseServin({
    required this.name,
    required this.nickname,
    required this.ownerName,
    required this.type,
    required this.url,
    this.isMultiBranch = false,
    this.isUsingExpirationDate = true,
    required this.isActive,
    required this.price,
    this.paymentDate,
  });

  factory BaseServin.fromJson(Map<String, dynamic> json) => BaseServin(
    name: json['name'],
    nickname: json['nickname'],
    ownerName: json['ownerName'],
    type: ServinType.values.firstWhere((element) => element.name == json['type']),
    url: json['url'],
    isMultiBranch: json['isMultiBranch'] ?? false,
    isUsingExpirationDate: json['isUsingExpirationDate'] ?? true,
    isActive: json['isActive'],
    price: json['price'],
    paymentDate: json['paymentDate'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'nickname': nickname,
    'ownerName': ownerName,
    'type': type.name,
    'url': url,
    'isMultiBranch': isMultiBranch,
    'isUsingExpirationDate': isUsingExpirationDate,
    'isActive': isActive,
    'price': price,
    'paymentDate': paymentDate,
  };
}

class CreateServin extends BaseServin {
  CreateServin({
    required super.name,
    required super.nickname,
    required super.ownerName,
    required super.type,
    required super.url,
    super.isMultiBranch,
    super.isUsingExpirationDate,
    required super.isActive,
    required super.price,
    super.paymentDate,
  });

  factory CreateServin.fromJson(Map<String, dynamic> json) => CreateServin(
    name: json['name'],
    nickname: json['nickname'],
    ownerName: json['ownerName'],
    type: ServinType.values.firstWhere((element) => element.name == json['type']),
    url: json['url'],
    isMultiBranch: json['isMultiBranch'] ?? false,
    isUsingExpirationDate: json['isUsingExpirationDate'] ?? true,
    isActive: json['isActive'],
    price: json['price'],
    paymentDate: json['paymentDate'],
  );
}

class UpdateServin {
  String? name;
  String? nickname;
  String? ownerName;
  ServinType? type;
  String? url;
  bool? isMultiBranch;
  bool? isUsingExpirationDate;
  bool? isActive;
  int? price;
  int? paymentDate;

  UpdateServin({
    this.name,
    this.nickname,
    this.ownerName,
    this.type,
    this.url,
    this.isMultiBranch,
    this.isUsingExpirationDate,
    this.isActive,
    this.price,
    this.paymentDate,
  });

  factory UpdateServin.fromJson(Map<String, dynamic> json) => UpdateServin(
    name: json['name'],
    nickname: json['nickname'],
    ownerName: json['ownerName'],
    type: ServinType.values.firstWhere((element) => element.name == json['type']),
    url: json['url'],
    isMultiBranch: json['isMultiBranch'] ?? false,
    isUsingExpirationDate: json['isUsingExpirationDate'] ?? true,
    isActive: json['isActive'] ?? true,
    price: json['price'],
    paymentDate: json['paymentDate'],
  );

  Map<String, dynamic> toJson() {
    final data = {
      'name': name,
      'nickname': nickname,
      'ownerName': ownerName,
      'type': type?.name,
      'url': url,
      'isMultiBranch': isMultiBranch,
      'isUsingExpirationDate': isUsingExpirationDate,
      'isActive': isActive,
      'price': price,
      'paymentDate': paymentDate,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

class ServinInDb extends BaseServin {
  final String id;
  final String apiKey;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ServinInDb({
    required this.id,
    required this.apiKey,
    required super.name,
    required super.nickname,
    required super.ownerName,
    required super.type,
    required super.url,
    super.isMultiBranch,
    super.isUsingExpirationDate,
    required super.isActive,
    required super.price,
    super.paymentDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory ServinInDb.fromJson(Map<String, dynamic> json) => ServinInDb(
    id: json['id'],
    apiKey: json['apiKey'],
    name: json['name'],
    nickname: json['nickname'],
    ownerName: json['ownerName'],
    type: ServinType.values.firstWhere((element) => element.name == json['type']),
    url: json['url'],
    isMultiBranch: json['isMultiBranch'] ?? false,
    isUsingExpirationDate: json['isUsingExpirationDate'] ?? true,
    isActive: json['isActive'],
    price: json['price'],
    paymentDate: json['paymentDate'],
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
    updatedAt: json['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt']) : null,
  );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'id': id,
      'apiKey': apiKey,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    });
    return data;
  }
}
