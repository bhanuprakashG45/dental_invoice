import 'package:invoice/core/api/api_client.dart';
import 'package:invoice/data/models/home/invoice/invoice_local_storage_model.dart';
import 'package:invoice/data/repo/auth/auth_repository.dart';
import 'package:invoice/data/repo/home/invoice/invoice_repository.dart';
import 'package:invoice/data/repo/home/products/products_repository.dart';
import 'package:invoice/provider/auth/auth_provider.dart';
import 'package:invoice/provider/home/invoice/invoice_provider.dart';
import 'package:invoice/provider/home/products/products_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

final List<SingleChildWidget> allProviders = [
  /*-----------------------------------------------------------------
                        API CLIENT
   ------------------------------------------------------------------*/
  Provider<ApiClient>.value(value: ApiClient.instance),

  /*-----------------------------------------------------------------
                        REPOSITORIES
   ------------------------------------------------------------------*/
  Provider<AuthRepository>(
    create: (context) => AuthRepository(context.read<ApiClient>()),
  ),

  Provider<InvoiceRepository>(
    create: (context) => InvoiceRepository(context.read<ApiClient>()),
  ),

  Provider<ProductsRepository>(
    create: (context) => ProductsRepository(context.read<ApiClient>()),
  ),

  /*-----------------------------------------------------------------
                    LOCAL STORAGE
   ------------------------------------------------------------------*/
  Provider<InvoiceLocalStorage>(create: (_) => InvoiceLocalStorage()),

  /*-----------------------------------------------------------------
                        PROVIDERS
   ------------------------------------------------------------------*/
  ChangeNotifierProvider<AuthProvider>(
    create: (context) => AuthProvider(context.read<AuthRepository>()),
  ),

  ChangeNotifierProvider<InvoiceProvider>(
    create: (context) => InvoiceProvider(
      invoiceRepository: context.read<InvoiceRepository>(),
      localStorage: context.read<InvoiceLocalStorage>(),
    ),
  ),

  ChangeNotifierProvider<ProductsProvider>(
    create: (context) => ProductsProvider(context.read<ProductsRepository>()),
  ),
];
