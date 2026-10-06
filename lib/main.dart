import 'package:flutter/material.dart';

import 'app.dart';
import 'data/event_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await loadEventData();

  runApp(const LeopardCatApp());
}
