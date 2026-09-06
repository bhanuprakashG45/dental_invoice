import 'package:hive/hive.dart';
import 'package:invoice/data/models/home/invoice/create_invoice_model.dart';

class InvoiceLocalStorage {
  static const String boxName = 'invoice_box';

  Future<Box> _box() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }

    return Hive.openBox(boxName);
  }

  /// Save invoice locally.
  Future<void> saveInvoice(InvoiceModel invoice) async {
    final box = await _box();

    await box.put(invoice.invoiceNo, invoice.toLocalJson());
  }

  /// Update an existing invoice locally.
  Future<void> updateInvoice(InvoiceModel invoice) async {
    final box = await _box();

    await box.put(invoice.invoiceNo, invoice.toLocalJson());
  }

  /// Get all locally saved invoices.
  Future<List<InvoiceModel>> getInvoices() async {
    final box = await _box();

    return box.values
        .whereType<Map>()
        .map(
          (value) =>
              InvoiceModel.fromLocalJson(Map<String, dynamic>.from(value)),
        )
        .toList();
  }

  /// Get a single invoice by invoice number.
  Future<InvoiceModel?> getInvoice(String invoiceNo) async {
    final box = await _box();

    final value = box.get(invoiceNo);

    if (value == null || value is! Map) {
      return null;
    }

    return InvoiceModel.fromLocalJson(Map<String, dynamic>.from(value));
  }

  /// Delete an invoice by invoice number.
  Future<void> deleteInvoice(String invoiceNo) async {
    final box = await _box();

    await box.delete(invoiceNo);
  }
}
