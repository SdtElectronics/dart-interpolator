# Interpolator

[Interpolator](https://pub.dev/packages/interpolator) is yet another Dart package to handle dynamic String interpolation with better performance and error check.

## Usage

Create an interpolator instance form a format String:

```dart
const format = "{Name} is a chemical element with the symbol {Symbol} and atomic number {No.}.";
final element = Interpolator(format);
```

Get result string by call the instance as a method with substitution Map:

```dart
const map = {
    "Name":     "Chromium",
    "Symbol":   "Cr",
    "No.":      24
};
print(element(map));

//Chromium is a chemical element with the symbol Cr and atomic number 24.
```

Use {pre} and {suf} to escape braces in the format string:

```dart
const format = "Need format string includes '{pre}' and '{suf}'? No problem!";
final escaped = Interpolator(format);
print(escaped(const {}));

//Need format string includes '{' and '}'? No problem!
```

Note: this only works out of braces contain the keys. Names of keys containing braces are not allowed.

## Features 
Default values can be set when initializing an Interpolator. When format string contains keys not provided by the map during interpolation, corresponding default values will be filled. Set the value of key null as a placeholder to fill all unspecified values.
```dart
const format = "Default value: {default}, placeholder: {unspecified}";
const defaultVal = {"default": 0, null: '_'};
final fillDefault = Interpolator(format, defaultVal);
print(fillDefault(const {}));

//Default value: 0, placeholder: _
```

Interpolator can detect and locate syntax errors in format strings, i.e. unclosed brace or a key not provided by the substitution map while no placeholder is specified. This feature makes it preferable when handling format strings you have less control on them, such as user inputs or a configuration file.

```dart
Interpolator("Unmatched '{pre}' at 2:2\n { ");

//FormatException: Expected '}' to match '{' at 2:2
```

```dart
final nullMatch = Interpolator("{nullMatch}");
nullMatch(const{});

///FormatException: No match with key "nullMatch" at 1:2 and no placeholder specified
```

Providing richer functionality, interpolator also has a better performance than the simple function implemented with the [splitMapJoin](https://api.dart.dev/stable/2.8.4/dart-core/String/splitMapJoin.html) method provided by the core library when running as a pre-compiled binary(Tested with dart SDK 2.8.4, WSL 4.4.0-18362 and [GNU time](https://www.gnu.org/software/time/)). 

```dart
String inter(String format, Map<String, dynamic> sub ,{String placeholder = ""}){
	return format.splitMapJoin(RegExp(r'{.*?}'),
    onMatch:    (m) => sub[m.group(0).substring(1, m.group(0).length - 1)].toString() ?? placeholder,
    onNonMatch: (n) => n);
}
```

Since the parsed format string is cached during initialization, this performance improvement will become more significant when performing interpolation on the same format string several times.