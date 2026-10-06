class CameraTrapEvent {
  final String eventId;
  final String label;
  final String timestamp;
  final List<String> photoPaths;

  /// Arah hadap leopard cat untuk masing-masing foto.
  ///
  /// Urutannya harus sama dengan [photoPaths]:
  /// fotoPaths[0] -> orientation[0]
  /// fotoPaths[1] -> orientation[1]
  /// fotoPaths[2] -> orientation[2]
  final List<String> orientations;

  const CameraTrapEvent({
    required this.eventId,
    required this.label,
    required this.timestamp,
    required this.photoPaths,
    this.orientations = const [],
  });

  bool get isLeopardCat => label == 'leopard_cat';

  bool get isNullEvent => label == 'null';

  /// Mengambil arah hadap berdasarkan nomor foto.
  ///
  /// Jika data orientasi belum tersedia, mengembalikan '-'.
  String orientationAt(int index) {
    if (index < 0 || index >= orientations.length) {
      return '-';
    }

    final orientation = orientations[index].trim();

    if (orientation.isEmpty) {
      return '-';
    }

    return orientation;
  }
}
