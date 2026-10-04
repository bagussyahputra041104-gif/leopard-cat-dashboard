class CameraTrapEvent {
  final String eventId;
  final String label;
  final String timestamp;
  final List<String> photoPaths;

  const CameraTrapEvent({
    required this.eventId,
    required this.label,
    required this.timestamp,
    required this.photoPaths,
  });

  bool get isLeopardCat => label == 'leopard_cat';

  bool get isNullEvent => label == 'null';
}
