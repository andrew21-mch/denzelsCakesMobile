class Country {
  final String code;
  final String name;
  final String flag;
  final String dialCode;

  const Country({
    required this.code,
    required this.name,
    required this.flag,
    required this.dialCode,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      flag: json['flag'] ?? '',
      dialCode: json['dialCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'flag': flag,
      'dialCode': dialCode,
    };
  }

  @override
  String toString() => '$flag $name';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Country && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}
