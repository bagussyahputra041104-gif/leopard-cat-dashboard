import 'package:flutter/services.dart' show rootBundle;

import '../models/camera_trap_event.dart';

/// Data event yang digunakan oleh seluruh dashboard.
List<CameraTrapEvent> eventData = [];

/// Status pemuatan data.
bool eventDataLoaded = false;

/// Memuat seluruh event dari dashboard_events.csv.
Future<void> loadEventData() async {
  if (eventDataLoaded) {
    return;
  }

  final csv = await rootBundle.loadString(
    'assets/data/dashboard_events.csv',
  );

  final lines = csv
      .split(RegExp(r'\r?\n'))
      .where((line) => line.trim().isNotEmpty)
      .toList();

  final events = <CameraTrapEvent>[];

  if (lines.length > 1) {
    for (var i = 1; i < lines.length; i++) {
      final columns = _parseCsvLine(lines[i]);

      // CSV final memiliki 11 kolom:
      //
      // 0  event_id
      // 1  label
      // 2  timestamp
      // 3  foto_1
      // 4  arah_1
      // 5  foto_2
      // 6  arah_2
      // 7  foto_3
      // 8  arah_3
      // 9  candidate_individual
      // 10 reid_status
      if (columns.length < 11) {
        continue;
      }

      final eventId = columns[0].trim();
      final label = columns[1].trim();
      final timestamp = columns[2].trim();

      final orientation1 = columns[4].trim();
      final orientation2 = columns[6].trim();
      final orientation3 = columns[8].trim();

      if (eventId.isEmpty || label.isEmpty || timestamp.isEmpty) {
        continue;
      }

      events.add(
        CameraTrapEvent(
          eventId: eventId,
          label: label,
          timestamp: timestamp,
          photoPaths: [
            'assets/events/${eventId}_1.jpg',
            'assets/events/${eventId}_2.jpg',
            'assets/events/${eventId}_3.jpg',
          ],
          orientations: [
            orientation1,
            orientation2,
            orientation3,
          ],
        ),
      );
    }
  }

  eventData = events;
  eventDataLoaded = true;
}

/// Parser CSV sederhana yang tetap aman apabila ada field
/// yang mengandung koma di dalam tanda kutip.
List<String> _parseCsvLine(String line) {
  final columns = <String>[];
  final buffer = StringBuffer();

  var insideQuotes = false;

  for (var i = 0; i < line.length; i++) {
    final char = line[i];

    if (char == '"') {
      if (insideQuotes && i + 1 < line.length && line[i + 1] == '"') {
        buffer.write('"');
        i++;
      } else {
        insideQuotes = !insideQuotes;
      }
    } else if (char == ',' && !insideQuotes) {
      columns.add(buffer.toString());
      buffer.clear();
    } else {
      buffer.write(char);
    }
  }

  columns.add(buffer.toString());

  return columns;
}
