import 'package:invoice/core/api/api_client.dart';
import 'package:invoice/core/api/api_endpoints.dart';
import 'package:invoice/data/models/home/products/products_response_model.dart';

class ProductsRepository {
  final ApiClient apiClient;

  ProductsRepository(this.apiClient);

  Future<ProductsResponseModel> getProducts({
    String? search,
    int page = 1,
    int limit = 10,
  }) {
    return apiClient.get(
      ApiEndpoints.products,
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
        'limit': limit,
      },
      parser: ProductsResponseModel.fromJson,
    );
  }
}
