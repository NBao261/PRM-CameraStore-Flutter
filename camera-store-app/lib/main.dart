import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_strings.dart';
import 'core/network/api_client.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/product/data/datasources/product_remote_datasource.dart';
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/cart/data/datasources/cart_remote_datasource.dart';
import 'features/cart/data/repositories/cart_repository_impl.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/cart/presentation/bloc/cart_event.dart';
import 'features/product/presentation/screens/product_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CameraStoreApp());
}

class CameraStoreApp extends StatelessWidget {
  const CameraStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();
    final authRemoteDataSource = AuthRemoteDataSource(apiClient);
    final authRepository = AuthRepositoryImpl(authRemoteDataSource, apiClient);

    final productRemoteDataSource = ProductRemoteDataSource(apiClient);
    final productRepository = ProductRepositoryImpl(productRemoteDataSource);

    final cartRemoteDataSource = CartRemoteDataSourceImpl(apiClient);
    final cartRepository = CartRepositoryImpl(cartRemoteDataSource);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(authRepository)..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (_) => ProductBloc(productRepository),
        ),
        BlocProvider(
          create: (_) => CartBloc(cartRepository: cartRepository),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state.status == AuthStatus.initial) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (state.status == AuthStatus.authenticated) {
              // Load cart when user is authenticated
              context.read<CartBloc>().add(const CartLoadRequested());
              return const ProductListScreen();
            }

            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
