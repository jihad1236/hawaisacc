class EquipmentScanResult {
  const EquipmentScanResult({
    required this.success,
    required this.scanId,
    required this.status,
    required this.equipment,
    required this.confidence,
    required this.recommendedExercises,
    required this.equipmentImage,
    required this.equipmentDetected,
    required this.primaryEquipment,
    required this.primaryEquipmentId,
    required this.recommendedWorkoutIds,
    required this.errorMessage,
  });

  final bool success;
  final int? scanId;
  final String status;
  final Map<String, dynamic>? equipment;
  final double confidence;
  final List<Map<String, dynamic>> recommendedExercises;
  final String equipmentImage;
  final List<String> equipmentDetected;
  final String primaryEquipment;
  final int? primaryEquipmentId;
  final List<int> recommendedWorkoutIds;
  final String errorMessage;

  bool get hasMatch =>
      success &&
      (primaryEquipmentId != null || primaryEquipment.trim().isNotEmpty);

  factory EquipmentScanResult.fromJson(Map<String, dynamic> json) {
    final matchJson = json['match'];
    final match = matchJson is Map<String, dynamic> ? matchJson : null;
    final equipmentJson = match?['equipment'];
    final equipment = equipmentJson is Map<String, dynamic>
        ? Map<String, dynamic>.from(equipmentJson)
        : null;
    final detectedJson = json['equipment_detected'];
    final recommendedJson =
        json['recommended_exercises'] ?? json['recommended_workouts'];
    final primaryEquipmentName =
        equipment?['name']?.toString().trim().isNotEmpty == true
        ? equipment!['name'].toString().trim()
        : equipment?['title']?.toString().trim() ??
              json['primary_equipment']?.toString().trim() ??
              '';
    final primaryEquipmentId =
        int.tryParse(equipment?['id']?.toString() ?? '') ??
        int.tryParse(json['primary_equipment_id']?.toString() ?? '');
    final status = json['status']?.toString().trim() ?? '';

    return EquipmentScanResult(
      success:
          json['success'] == true ||
          (status.toLowerCase() == 'completed' &&
              (equipment != null || match != null)),
      scanId: int.tryParse(json['scan_id']?.toString() ?? ''),
      status: status,
      equipment: equipment,
      confidence:
          double.tryParse(match?['confidence']?.toString() ?? '') ??
          double.tryParse(json['confidence']?.toString() ?? '') ??
          0,
      recommendedExercises: recommendedJson is List
          ? recommendedJson
                .whereType<Map>()
                .map(
                  (item) =>
                      item.map((key, value) => MapEntry(key.toString(), value)),
                )
                .toList(growable: false)
          : const [],
      equipmentImage: json['equipment_image']?.toString().trim() ?? '',
      equipmentDetected: detectedJson is List
          ? detectedJson
                .map((item) => item?.toString().trim() ?? '')
                .where((item) => item.isNotEmpty)
                .toList(growable: false)
          : const [],
      primaryEquipment: primaryEquipmentName,
      primaryEquipmentId: primaryEquipmentId,
      recommendedWorkoutIds: recommendedJson is List
          ? recommendedJson
                .map((item) {
                  if (item is Map<String, dynamic>) {
                    return int.tryParse(item['id']?.toString() ?? '');
                  }
                  return int.tryParse(item?.toString() ?? '');
                })
                .whereType<int>()
                .toList(growable: false)
          : const [],
      errorMessage: json['error_message']?.toString().trim().isNotEmpty == true
          ? json['error_message'].toString().trim()
          : json['message']?.toString().trim() ?? '',
    );
  }
}

class EquipmentVerificationResult {
  const EquipmentVerificationResult({
    required this.success,
    required this.isMatch,
    required this.message,
    required this.confidence,
  });

  final bool success;
  final bool isMatch;
  final String message;
  final double confidence;

  factory EquipmentVerificationResult.fromJson(Map<String, dynamic> json) {
    return EquipmentVerificationResult(
      success: json['success'] == true,
      isMatch: json['is_match'] == true,
      message: json['message']?.toString().trim() ?? '',
      confidence: double.tryParse(json['confidence']?.toString() ?? '') ?? 0,
    );
  }
}
