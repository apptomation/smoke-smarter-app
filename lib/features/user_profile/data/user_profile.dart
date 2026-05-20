class UserProfile {
  const UserProfile({
    required this.uid,
    required this.interests,
    this.cigarettesPerDay,
    this.cigarettesPerPack,
    this.pricePerPack,
    this.quitStartDate,
  });

  final String uid;
  final List<String> interests;

  /// Baseline cigarettes smoked per day before quitting
  final int? cigarettesPerDay;

  /// Number of cigarettes in one pack
  final int? cigarettesPerPack;

  /// Price of one pack in the user's local currency
  final double? pricePerPack;

  /// The date the user started their quit/reduction journey
  final DateTime? quitStartDate;

  bool get hasInterests => interests.isNotEmpty;

  bool get hasSmokingProfile =>
      cigarettesPerDay != null &&
      cigarettesPerPack != null &&
      pricePerPack != null &&
      quitStartDate != null;

  /// Price per single cigarette
  double? get pricePerCigarette {
    if (pricePerPack == null || cigarettesPerPack == null || cigarettesPerPack! <= 0) return null;
    return pricePerPack! / cigarettesPerPack!;
  }

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      interests: List<String>.from(data['interests'] as List? ?? []),
      cigarettesPerDay: data['cigarettesPerDay'] as int?,
      cigarettesPerPack: data['cigarettesPerPack'] as int?,
      pricePerPack: (data['pricePerPack'] as num?)?.toDouble(),
      quitStartDate: data['quitStartDate'] != null
          ? DateTime.parse(data['quitStartDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {'interests': interests};
}
