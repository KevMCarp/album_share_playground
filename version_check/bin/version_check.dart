import 'dart:io';

import 'package:args/args.dart';

const kNext = 'next';
const kPrev = 'prev';

void main(List<String> arguments) {
  exitCode = 0;

  final parser = ArgParser()
    ..addOption(kPrev, abbr: 'p')
    ..addOption(kNext, abbr: 'n');

  final results = parser.parse(arguments);

  var prev = results[kPrev];
  if (prev.startsWith('v')) {
    prev = prev.substring(1);
  }

  var next = results[kNext];
  if (next.startsWith('v')) {
    next = next.substring(1);
  }

  if (prev is! String || next is! String) {
    print('Expected string version numbers');
    exit(2);
  }

  final prevValues = prev.split('.');
  final prevMajor = int.tryParse(prevValues[0]);
  final prevMinor = int.tryParse(prevValues[1]);
  final prevPatch = int.tryParse(prevValues[2].split('+').first);

  final nextValues = next.split('.');
  final nextMajor = int.tryParse(nextValues[0]);
  final nextMinor = int.tryParse(nextValues[1]);
  final nextPatch = int.tryParse(nextValues[2].split('+').first);

  if (prevMajor == null ||
      prevMinor == null ||
      prevPatch == null ||
      nextMajor == null ||
      nextMinor == null ||
      nextPatch == null) {
    print('Unable to parse version numbers');
    print('prevMajor: $prevMajor');
    print('prevMinor: $prevMinor');
    print('prevPatch: $prevPatch');
    print('nextMajor: $nextMajor');
    print('nextMinor: $nextMinor');
    print('nextPatch: $nextPatch');
    exit(2);
  }

  if (nextMajor <= prevMajor) {
    if (nextMinor <= prevMinor) {
      if (nextPatch <= prevPatch) {
        print('Version older or unchanged');
        exitCode = 2;
      }
    }
  }

  // stdout.write(true);
}
