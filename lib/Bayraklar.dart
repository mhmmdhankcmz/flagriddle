class Bayraklar {
  final int bayrakId;
  final String bayrakAd;
  final String bayrakResim;

  const Bayraklar({
    required this.bayrakId,
    required this.bayrakAd,
    required this.bayrakResim,
  });

  factory Bayraklar.fromMap(Map<String, dynamic> map) {
    return Bayraklar(
      bayrakId: map['bayrak_id'] as int,
      bayrakAd: map['bayrak_ad'] as String,
      bayrakResim: map['bayrak_resim'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bayrak_id': bayrakId,
      'bayrak_ad': bayrakAd,
      'bayrak_resim': bayrakResim,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bayraklar && other.bayrakId == bayrakId;
  }

  @override
  int get hashCode => bayrakId.hashCode;

  @override
  String toString() {
    return 'Bayraklar(id: $bayrakId, ad: $bayrakAd, resim: $bayrakResim)';
  }

  Bayraklar copyWith({
    int? bayrakId,
    String? bayrakAd,
    String? bayrakResim,
  }) {
    return Bayraklar(
      bayrakId: bayrakId ?? this.bayrakId,
      bayrakAd: bayrakAd ?? this.bayrakAd,
      bayrakResim: bayrakResim ?? this.bayrakResim,
    );
  }
}
