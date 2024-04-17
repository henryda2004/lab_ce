class LabModel {
  final int? labId;
  final String labName;
  final int capacity;
  final int computers;
  final String otherAssets;
  final String facilities;

  LabModel({
    this.labId,
    required this.labName,
    required this.capacity,
    required this.computers,
    required this.otherAssets,
    required this.facilities,
  });

  Map<String, dynamic> toMap() {
    return {
      'labId': labId,
      'labName': labName,
      'capacity': capacity,
      'computers': computers,
      'otherAssets': otherAssets,
      'facilities': facilities,
    };
  }

  factory LabModel.fromMap(Map<String, dynamic> map) {
    return LabModel(
      labId: map['labId'],
      labName: map['labName'],
      capacity: map['capacity'],
      computers: map['computers'],
      otherAssets: map['otherAssets'],
      facilities: map['facilities'],
    );
  }
}
