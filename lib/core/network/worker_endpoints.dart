const String _defaultWorkerUrl =
    'https://nutriz-food-ai.alexandretmoraes110.workers.dev';

String resolveWorkerBaseUrl() {
  const configured = String.fromEnvironment(
    'NUTRIZ_WORKER_URL',
    defaultValue: _defaultWorkerUrl,
  );

  final trimmed = configured.trim();
  if (trimmed.isEmpty) return _defaultWorkerUrl;
  return trimmed;
}

