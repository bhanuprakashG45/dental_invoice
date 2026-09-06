import 'package:hive/hive.dart';
import 'package:invoice/data/models/home/invoice/create_invoice_model.dart';

class InvoiceLocalStorage {
  static const String boxName = 'invoice_box';

  Future<Box> get _box async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }

    return Hive.openBox(boxName);
  }

  Future<void> saveInvoice(InvoiceModel invoice) async {
    final box = await _box;

    await box.put(invoice.invoiceNo, invoice.toLocalJson());
  }

  Future<void> updateInvoice(InvoiceModel invoice) async {
    final box = await _box;

    await box.put(invoice.invoiceNo, invoice.toLocalJson());
  }

  Future<InvoiceModel?> getInvoice(String invoiceNo) async {
    final box = await _box;

    final data = box.get(invoiceNo);

    if (data is! Map) {
      return null;
    }

    return InvoiceModel.fromLocalJson(Map<String, dynamic>.from(data));
  }

  Future<List<InvoiceModel>> getInvoices() async {
    final box = await _box;

    return box.values
        .whereType<Map>()
        .map(
          (item) => InvoiceModel.fromLocalJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<void> deleteInvoice(String invoiceNo) async {
    final box = await _box;

    await box.delete(invoiceNo);
  }
}
