class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = "https://dentalinvoice-backend-1.onrender.com";

  // Auth
  static const login = "/api/v1/auth/login";

  // Dashboard
  static const dashboard = "dashboard";

  // Products
  static const products = "products";

  // Inventory
  static const inventory = "inventory";

  // Invoice
  static const invoices = "invoices";
}
