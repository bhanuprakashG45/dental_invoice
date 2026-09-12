import 'package:flutter/foundation.dart';
import 'package:invoice/data/models/home/invoice/create_invoice_model.dart';
import 'package:invoice/data/models/home/invoice/invoice_history_response_model.dart';
import 'package:invoice/data/models/home/invoice/invoice_local_storage_model.dart';
import 'package:invoice/data/repo/home/invoice/invoice_repository.dart';

class InvoiceProvider extends ChangeNotifier {
  final InvoiceRepository invoiceRepository;
  final InvoiceLocalStorage localStorage;

  InvoiceProvider({
    required this.invoiceRepository,
    required this.localStorage,
  });

  // ===========================================================================
  // CREATE / LOCAL INVOICE
  // ===========================================================================

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isSyncing = false;

  String? _errorMessage;

  InvoiceModel? _currentInvoice;
  List<InvoiceModel> _invoices = [];

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isSyncing => _isSyncing;

  String? get errorMessage => _errorMessage;

  InvoiceModel? get currentInvoice => _currentInvoice;

  List<InvoiceModel> get invoices => List.unmodifiable(_invoices);

  // ===========================================================================
  // INVOICE HISTORY
  // ===========================================================================

  bool _isHistoryLoading = false;

  String? _historyErrorMessage;

  List<InvoiceHistoryModel> _invoiceHistory = [];

  InvoiceHistoryDataModel _invoiceHistoryData = const InvoiceHistoryDataModel();

  bool get isHistoryLoading => _isHistoryLoading;

  String? get historyErrorMessage => _historyErrorMessage;

  List<InvoiceHistoryModel> get invoiceHistory =>
      List.unmodifiable(_invoiceHistory);

  InvoiceHistoryDataModel get invoiceHistoryData => _invoiceHistoryData;

  int get historyCurrentPage {
    if (_invoiceHistoryData.totalPages == 0) {
      return 1;
    }

    return _invoiceHistoryData.hasPreviousPage ? 2 : 1;
  }

  int get historyTotalPages => _invoiceHistoryData.totalPages;

  int get historyTotalRecords => _invoiceHistoryData.totalRecords;

  bool get hasNextHistoryPage => _invoiceHistoryData.hasNextPage;

  bool get hasPreviousHistoryPage => _invoiceHistoryData.hasPreviousPage;

  // ===========================================================================
  // SAVE INVOICE LOCALLY
  // ===========================================================================

  Future<bool> saveInvoiceLocally(InvoiceModel invoice) async {
    if (_isSaving) {
      return false;
    }

    try {
      _isSaving = true;
      _errorMessage = null;
      notifyListeners();

      final localInvoice = invoice.copyWith(isSynced: false);

      await localStorage.saveInvoice(localInvoice);

      _currentInvoice = localInvoice;

      _updateInvoiceInMemory(localInvoice);

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);

      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // CREATE INVOICE
  // ===========================================================================

  Future<InvoiceModel?> createInvoice(InvoiceModel invoice) async {
    if (_isLoading) {
      return null;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Always save locally first.
      final localInvoice = invoice.copyWith(isSynced: false);

      await localStorage.saveInvoice(localInvoice);

      _currentInvoice = localInvoice;

      _updateInvoiceInMemory(localInvoice);

      // Try API sync.
      try {
        final response = await invoiceRepository.createInvoice(
          invoice: localInvoice,
        );

        if (response.success) {
          final syncedInvoice =
              response.data?.copyWith(isSynced: true) ??
              localInvoice.copyWith(isSynced: true);

          await localStorage.updateInvoice(syncedInvoice);

          _currentInvoice = syncedInvoice;

          _updateInvoiceInMemory(syncedInvoice);

          return syncedInvoice;
        }

        // API failed but local save succeeded.
        final unsyncedInvoice = localInvoice.copyWith(isSynced: false);

        await localStorage.updateInvoice(unsyncedInvoice);

        _currentInvoice = unsyncedInvoice;

        _updateInvoiceInMemory(unsyncedInvoice);

        _errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Invoice saved locally, but server sync failed.';

        return unsyncedInvoice;
      } catch (e) {
        // API exception.
        // Local invoice is still available.
        final unsyncedInvoice = localInvoice.copyWith(isSynced: false);

        await localStorage.updateInvoice(unsyncedInvoice);

        _currentInvoice = unsyncedInvoice;

        _updateInvoiceInMemory(unsyncedInvoice);

        _errorMessage =
            'Invoice saved locally, but server sync failed: '
            '${_cleanError(e)}';

        return unsyncedInvoice;
      }
    } catch (e) {
      // Local storage failed.
      _errorMessage = 'Unable to save invoice locally: ${_cleanError(e)}';

      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // LOAD LOCAL INVOICES
  // ===========================================================================

  Future<void> loadInvoices() async {
    if (_isLoading) {
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final storedInvoices = await localStorage.getInvoices();

      _invoices = storedInvoices;
    } catch (e) {
      _errorMessage = _cleanError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // GET LOCAL INVOICE
  // ===========================================================================

  Future<InvoiceModel?> getInvoice(String invoiceNo) async {
    try {
      final invoice = await localStorage.getInvoice(invoiceNo);

      if (invoice != null) {
        _currentInvoice = invoice;
      }

      return invoice;
    } catch (e) {
      _errorMessage = _cleanError(e);

      notifyListeners();

      return null;
    }
  }

  // ===========================================================================
  // DELETE LOCAL INVOICE
  // ===========================================================================

  Future<bool> deleteInvoice(String invoiceNo) async {
    try {
      await localStorage.deleteInvoice(invoiceNo);

      _invoices.removeWhere((invoice) => invoice.invoiceNo == invoiceNo);

      if (_currentInvoice?.invoiceNo == invoiceNo) {
        _currentInvoice = null;
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);

      notifyListeners();

      return false;
    }
  }

  // ===========================================================================
  // SYNC PENDING INVOICES
  // ===========================================================================

  Future<void> syncPendingInvoices() async {
    if (_isSyncing) {
      return;
    }

    try {
      _isSyncing = true;
      _errorMessage = null;
      notifyListeners();

      final storedInvoices = await localStorage.getInvoices();

      final pendingInvoices = storedInvoices
          .where((invoice) => !invoice.isSynced)
          .toList();

      for (final invoice in pendingInvoices) {
        try {
          final response = await invoiceRepository.createInvoice(
            invoice: invoice,
          );

          if (!response.success) {
            continue;
          }

          final syncedInvoice =
              response.data?.copyWith(isSynced: true) ??
              invoice.copyWith(isSynced: true);

          await localStorage.updateInvoice(syncedInvoice);

          _updateInvoiceInMemory(syncedInvoice);

          if (_currentInvoice?.invoiceNo == invoice.invoiceNo) {
            _currentInvoice = syncedInvoice;
          }
        } catch (_) {
          continue;
        }
      }

      _invoices = await localStorage.getInvoices();
    } catch (e) {
      _errorMessage = _cleanError(e);
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // SYNC SINGLE INVOICE
  // ===========================================================================

  Future<InvoiceModel?> syncInvoice(InvoiceModel invoice) async {
    if (invoice.isSynced) {
      return invoice;
    }

    try {
      final response = await invoiceRepository.createInvoice(invoice: invoice);

      if (!response.success) {
        _errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to sync invoice.';

        notifyListeners();

        return invoice;
      }

      final syncedInvoice =
          response.data?.copyWith(isSynced: true) ??
          invoice.copyWith(isSynced: true);

      await localStorage.updateInvoice(syncedInvoice);

      _currentInvoice = syncedInvoice;

      _updateInvoiceInMemory(syncedInvoice);

      notifyListeners();

      return syncedInvoice;
    } catch (e) {
      _errorMessage = 'Unable to sync invoice: ${_cleanError(e)}';

      notifyListeners();

      return invoice;
    }
  }

  // ===========================================================================
  // GET INVOICE HISTORY FROM API
  // ===========================================================================

  Future<bool> getInvoiceHistory({int page = 1, int limit = 10}) async {
    if (_isHistoryLoading) {
      return false;
    }

    try {
      _isHistoryLoading = true;
      _historyErrorMessage = null;

      notifyListeners();

      final response = await invoiceRepository.getInvoices(
        page: page,
        limit: limit,
      );

      if (!response.success) {
        _historyErrorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to fetch invoice history.';

        return false;
      }

      _invoiceHistoryData = response.data;

      _invoiceHistory = response.data.invoices;

      return true;
    } catch (e) {
      _historyErrorMessage = _cleanError(e);

      return false;
    } finally {
      _isHistoryLoading = false;

      notifyListeners();
    }
  }

  // ===========================================================================
  // LOAD NEXT HISTORY PAGE
  // ===========================================================================

  Future<bool> loadNextInvoiceHistoryPage() async {
    if (_isHistoryLoading || !_invoiceHistoryData.hasNextPage) {
      return false;
    }

    final currentPage = _invoiceHistoryData.hasPreviousPage ? 2 : 1;

    return getInvoiceHistory(
      page: currentPage + 1,
      limit: _invoiceHistoryData.limit,
    );
  }

  // ===========================================================================
  // LOAD PREVIOUS HISTORY PAGE
  // ===========================================================================

  Future<bool> loadPreviousInvoiceHistoryPage() async {
    if (_isHistoryLoading || !_invoiceHistoryData.hasPreviousPage) {
      return false;
    }

    final currentPage = _invoiceHistoryData.hasPreviousPage ? 2 : 1;

    if (currentPage <= 1) {
      return false;
    }

    return getInvoiceHistory(
      page: currentPage - 1,
      limit: _invoiceHistoryData.limit,
    );
  }

  // ===========================================================================
  // CLEAR INVOICE HISTORY
  // ===========================================================================

  void clearInvoiceHistory() {
    _invoiceHistory = [];

    _invoiceHistoryData = const InvoiceHistoryDataModel();

    _historyErrorMessage = null;

    notifyListeners();
  }

  // ===========================================================================
  // CLEAR ERRORS
  // ===========================================================================

  void clearError() {
    _errorMessage = null;

    notifyListeners();
  }

  void clearHistoryError() {
    _historyErrorMessage = null;

    notifyListeners();
  }

  // ===========================================================================
  // UPDATE LOCAL INVOICE LIST
  // ===========================================================================

  void _updateInvoiceInMemory(InvoiceModel invoice) {
    final index = _invoices.indexWhere(
      (item) => item.invoiceNo == invoice.invoiceNo,
    );

    if (index == -1) {
      _invoices.add(invoice);
    } else {
      _invoices[index] = invoice;
    }
  }

  // ===========================================================================
  // ERROR HANDLER
  // ===========================================================================

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message;
  }
}
