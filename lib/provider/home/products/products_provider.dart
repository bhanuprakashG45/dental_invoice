import 'package:flutter/material.dart';
import 'package:invoice/data/models/home/products/products_model.dart';
import 'package:invoice/data/models/home/products/products_response_model.dart';
import 'package:invoice/data/repo/home/products/products_repository.dart';

class ProductsProvider extends ChangeNotifier {
  final ProductsRepository productsRepository;

  ProductsProvider(this.productsRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  set errorMessage(String value) {
    _errorMessage = value;
    notifyListeners();
  }

  List<ProductModel> _products = [];

  PaginationModel _pagination = const PaginationModel();

  List<ProductModel> get products => List.unmodifiable(_products);

  PaginationModel get pagination => _pagination;

  Future<bool> getProducts({
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    if (_isLoading) {
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await productsRepository.getProducts(
        search: search,
        page: page,
        limit: limit,
      );

      if (!response.success) {
        _errorMessage = 'Failed to fetch products.';
        return false;
      }

      _products = response.data;
      _pagination = response.pagination;

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> searchProducts(String search) async {
    return getProducts(search: search, page: 1, limit: 10);
  }

  void clearProducts() {
    _products = [];
    _pagination = const PaginationModel();
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }

    return message;
  }
}
