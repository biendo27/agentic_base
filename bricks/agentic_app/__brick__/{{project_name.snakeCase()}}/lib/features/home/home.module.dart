// Home feature DI module
{{#uses_get_it}}
// Registration handled via @injectable and @LazySingleton annotations.
// No manual registration needed — injectable scans these automatically.

{{/uses_get_it}}
{{^uses_get_it}}
// Riverpod starter features build their dependency graph in provider files.
// No generated DI scan is required for this starter module.

{{/uses_get_it}}
