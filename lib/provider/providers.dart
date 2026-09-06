import 'package:invoice/data/repo/auth/auth_repository.dart';
import 'package:invoice/provider/auth/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:invoice/core/api/api_client.dart';

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

  /*-----------------------------------------------------------------
                        PROVIDERS
   ------------------------------------------------------------------*/
  ChangeNotifierProvider<AuthProvider>(
    create: (context) => AuthProvider(context.read<AuthRepository>()),
  ),
];
