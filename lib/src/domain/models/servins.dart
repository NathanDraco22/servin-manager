class BaseServin {
  final String name;
  final String nickname;
  final String ownerName;
  final String url;
  final bool isMultiBranch;
  final bool isActive;
  final int price;

  BaseServin({
    required this.name,
    required this.nickname,
    required this.ownerName,
    required this.url,
    this.isMultiBranch = false,
    required this.isActive,
    required this.price,
  });

  factory BaseServin.fromJson(Map<String, dynamic> json) => BaseServin(
    name: json['name'],
    nickname: json['nickname'],
    ownerName: json['ownerName'],
    url: json['url'],
    isMultiBranch: json['isMultiBranch'] ?? false,
    isActive: json['isActive'],
    price: json['price'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'nickname': nickname,
    'ownerName': ownerName,
    'url': url,
    'isMultiBranch': isMultiBranch,
    'isActive': isActive,
    'price': price,
  };
}

class CreateServin extends BaseServin {
  CreateServin({
    required super.name,
    required super.nickname,
    required super.ownerName,
    required super.url,
    super.isMultiBranch,
    required super.isActive,
    required super.price,
  });

  factory CreateServin.fromJson(Map<String, dynamic> json) => CreateServin(
    name: json['name'],
    nickname: json['nickname'],
    ownerName: json['ownerName'],
    url: json['url'],
    isMultiBranch: json['isMultiBranch'] ?? false,
    isActive: json['isActive'],
    price: json['price'],
  );
}

class UpdateServin {
  String? name;
  String? nickname;
  String? ownerName;
  String? url;
  bool? isMultiBranch;
  bool? isActive;
  int? price;

  UpdateServin({
    this.name,
    this.nickname,
    this.ownerName,
    this.url,
    this.isMultiBranch,
    this.isActive,
    this.price,
  });

  factory UpdateServin.fromJson(Map<String, dynamic> json) => UpdateServin(
    name: json['name'],
    nickname: json['nickname'],
    ownerName: json['ownerName'],
    url: json['url'],
    isMultiBranch: json['isMultiBranch'] ?? false,
    isActive: json['isActive'] ?? true,
    price: json['price'],
  );

  Map<String, dynamic> toJson() {
    final data = {
      'name': name,
      'nickname': nickname,
      'ownerName': ownerName,
      'url': url,
      'isMultiBranch': isMultiBranch,
      'isActive': isActive,
      'price': price,
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
    required super.url,
    super.isMultiBranch,
    required super.isActive,
    required super.price,
    required this.createdAt,
    this.updatedAt,
  });

  factory ServinInDb.fromJson(Map<String, dynamic> json) => ServinInDb(
    id: json['id'],
    apiKey: json['apiKey'],
    name: json['name'],
    nickname: json['nickname'],
    ownerName: json['ownerName'],
    url: json['url'],
    isMultiBranch: json['isMultiBranch'] ?? false,
    isActive: json['isActive'],
    price: json['price'],
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
