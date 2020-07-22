# Interpolator

Interpolator is yet another Dart package to handle dynamic String interpolation with lighter implementation and error check.

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
Interpolator can detect and locate syntax errors in format strings, i.e. unclosed brace or a key not provided by the substitution map while no placeholder is specified. This feature makes it preferable when handling format strings you have less control on them, such as user inputs or a configuration file.

```dart
Interpolator("Unmatched '{pre}' at 2:2\n { ");

//FormatException: Expected '}' to match '{' at 2:2
```

```dart
final nullMatch = Interpolator("{nullMatch}");
interpolator(const{});

///FormatException: No match with key "nullMatch" at 1:2 and no placeholder specified
```

Providing richer functionality, interpolator also has a slightly better performance than the simple function implemented with the splitMapJoin method provided by the core library with less memory consumption when running as a pre-compiled native program(Tested with dart SDK 2.8.4, WSL 4.4.0-18362 ,valgrind and GNU time). 

```dart
String inter(String format, Map<String, dynamic> sub ,{String placeholder = ""}){
	return format.splitMapJoin(RegExp(r'{.*?}'),
    onMatch:    (m) => sub[m.group(0).substring(1, m.group(0).length - 1)].toString() ?? placeholder,
    onNonMatch: (n) => n);
}
```

Since the parsed format string is cached during initialization, this performance improvement will become more significant when performing interpolation on the same format string several times.