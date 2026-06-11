import 'package:riverpod/riverpod.dart';

class ColorProvider extends Notifier<int> {
  @override
  int build() => 0;

  void changeValue(int value) {
    state = value;
  }
}

final colorChange = NotifierProvider<ColorProvider, int>(() {
  return ColorProvider();
});
