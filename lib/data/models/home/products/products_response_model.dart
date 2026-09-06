import 'package:invoice/data/models/home/products/products_model.dart';

class ProductsResponseModel {
  final bool success;
  final List<ProductModel> data;
  final PaginationModel pagination;

  const ProductsResponseModel({
    required this.success,
    required this.data,
    required this.pagination,
  });

  factory ProductsResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductsResponseModel(
      success: json['success'] == true,
      data: json['data'] is List
          ? (json['data'] as List)
                .whereType<Map>()
                .map(
                  (item) =>
                      ProductModel.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : [],
      pagination: json['pagination'] is Map
          ? PaginationModel.fromJson(
              Map<String, dynamic>.from(json['pagination']),
            )
          : const PaginationModel(),
    );
  }
}

class PaginationModel {
  final int currentPage;
  final int limit;
  final int totalRecords;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginationModel({
    this.currentPage = 1,
    this.limit = 10,
    this.totalRecords = 0,
    this.totalPages = 0,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: _toInt(json['currentPage'], 1),
      limit: _toInt(json['limit'], 10),
      totalRecords: _toInt(json['totalRecords']),
      totalPages: _toInt(json['totalPages']),
      hasNextPage: json['hasNextPage'] == true,
      hasPreviousPage: json['hasPreviousPage'] == true,
    );
  }

  static int _toInt(dynamic value, [int defaultValue = 0]) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? defaultValue;
  }
}
