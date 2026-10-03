.PHONY: pigeon check

pigeon:
	dart run pigeon --input pigeon_config.dart
	dart format lib/quick_look_messages.g.dart

check:
	dart format --output=none --set-exit-if-changed lib test example/lib pigeon_config.dart
	flutter analyze
	flutter test
