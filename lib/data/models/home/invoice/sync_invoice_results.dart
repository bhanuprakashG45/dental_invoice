class SyncInvoicesResult {
  final bool success;
  final int syncedCount;
  final int failedCount;
  final String message;

  const SyncInvoicesResult({
    required this.success,
    required this.syncedCount,
    required this.failedCount,
    required this.message,
  });
}
