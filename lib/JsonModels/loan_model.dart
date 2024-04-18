class LoanModel {
  final String asset;
  final String name;
  final String lastName1;
  final String lastName2;
  final String email;
  final DateTime dateTime;
  final int approved;

  LoanModel({
    required this.asset,
    required this.name,
    required this.lastName1,
    required this.lastName2,
    required this.email,
    required this.dateTime,
    required this.approved,
  });

  factory LoanModel.fromMap(Map<String, dynamic> json) {
    return LoanModel(
      asset: json['asset'],
      name: json['name'],
      lastName1: json['lastName1'],
      lastName2: json['lastName2'],
      email: json['email'],
      dateTime: DateTime.parse(json['dateTime']),
      approved: json['approved'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'asset': asset,
      'name': name,
      'lastName1': lastName1,
      'lastName2': lastName2,
      'email': email,
      'dateTime': dateTime.toIso8601String(),
      'approved': approved,
    };
  }
}
