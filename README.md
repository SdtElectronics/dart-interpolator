# Interpolator

Interpolator is yet another Dart package to handle dynamic String interpolation with lighter implementation and error check.

## Usage

Create an interpolator instance form format String:

```dart

```

Get result string by call the instance as a method with substitution Map:

```dart

```



Use {pre} and {suf} to escape brackets in the format string:

```dart

```

## Features 
Interpolator can detect and locate syntax errors in format strings, i.e. unclosed bracket and a key not provided by the substitution map while no placeholder is specified. This feature makes it preferable when handling format strings you have less control on them, such as user inputs or a configuration file.
```dart

```

Providing richer functionality, interpolator also has a slightly better performance than the simple function implemented with the splitMapJoin method provided by the core library with less memory consumption when running as a pre-compiled native program(Tested with dart SDK 2.8.4, WSL 4.4.0-18362 and GNU time). 

```dart
String inter(String format, Map<String, dynamic> sub ,{String placeholder = ""}){
	return format.splitMapJoin(RegExp(r'{.*?}'),
    onMatch:    (m) => sub[m.group(0).substring(1, m.group(0).length - 1)].toString() ?? placeholder,
    onNonMatch: (n) => n);
}
```

Since the parsed format string is cached during initialization, this performance improvement will become more significant when performing interpolation on the same format string several times.