///
/// https://stackoverflow.com/questions/54545102/dart-make-a-calculation-from-a-user-input-string-including-math-operators
/// Q: https://stackoverflow.com/users/11020422/aembe
/// A: https://stackoverflow.com/users/11324471/pranav
///

import 'package:petitparser/petitparser.dart';
import 'dart:math';

Parser buildParser() {
  final builder = ExpressionBuilder();
  builder.group()
    ..primitive((pattern('+-').optional() &
    digit().plus() &
    (char('.') & digit().plus()).optional() &
    (pattern('eE') & pattern('+-').optional() & digit().plus())
        .optional())
        .flatten('number expected')
        .trim()
        .map(num.tryParse))
    ..wrapper(
        char('(').trim(), char(')').trim(), (left, value, right) => value);
  builder.group()..prefix(char('-').trim(), (op, a) => -a);
  builder.group()..right(char('^').trim(), (a, op, b) => pow(a, b));
  builder.group()
    ..left(char('*').trim(), (a, op, b) => a * b)
    ..left(char('/').trim(), (a, op, b) => a / b);
  builder.group()
    ..left(char('+').trim(), (a, op, b) => a + b)
    ..left(char('-').trim(), (a, op, b) => a - b);
  return builder.build().end();
}

double calcString(String text) {
  final parser = buildParser();
  final input = text;
  try {
    final result = parser.parse(input);
    if (result.isSuccess) {
      return result.value.toDouble();
    }else{
      return double.parse(text);
    }
  } on FormatException {
    return double.nan;
  }
}