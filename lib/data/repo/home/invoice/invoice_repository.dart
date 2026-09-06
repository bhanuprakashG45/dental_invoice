import 'package:invoice/core/api/api_client.dart';
import 'package:invoice/core/api/api_endpoints.dart';
import 'package:invoice/data/models/home/invoice/create_invoice_model.dart';

class InvoiceRepository {
  final ApiClient apiClient;

  InvoiceRepository(this.apiClient);

  Future<InvoiceResponseModel> createInvoice({required InvoiceModel invoice}) {
    return apiClient.post(
      ApiEndpoints.createInvoice,
      data: invoice.toApiJson(),
      parser: InvoiceResponseModel.fromJson,
    );
  }
}
