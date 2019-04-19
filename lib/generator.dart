import 'dart:math';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

Future<String> generatePassphrase({wordsCount = 4, separator = " ", dictionaryPath = "../assets/small.txt" }) async {

  var rand = Random.secure();
  var dictText = await rootBundle.loadString(dictionaryPath);
  var dict = dictText.split("\n").toList();

  var len = dict.length;

  List<String> result = List(wordsCount).map((_) => dict[rand.nextInt(len)].toLowerCase()).toList();

  return result.join(separator);
}
