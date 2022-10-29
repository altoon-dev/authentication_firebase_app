import 'package:flutter/foundation.dart';

extension IfDebugging on String{
  String? get IfDebugging => kDebugMode ? this: null;
}