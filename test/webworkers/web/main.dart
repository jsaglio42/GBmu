
// import 'package:angular2/platform/browser.dart';

// import 'package:pirate_badge/app_component.dart';

import 'dart:html';

main() {
  print('salut');
  var st = StackTrace.current;
  print(st);
  var element = querySelector('#hellol');
  element.text = "truc";
  print(element);
  print('salut');
  // bootstrap(AppComponent);
}
