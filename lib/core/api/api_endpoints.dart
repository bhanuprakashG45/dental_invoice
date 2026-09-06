class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = "https://dentalinvoice-backend-1.onrender.com";
  //Auth
  static const login = "/api/auth/v1/login";
  //Products
  static const products = "/api/products/v1";
  // Inventory
  static const inventory = "inventory";
  //Invoices
  static const createInvoice = "/api/invoice/v1";
}
