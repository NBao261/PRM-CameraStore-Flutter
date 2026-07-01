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
import 'features/order/data/datasources/order_remote_datasource.dart';
import 'features/order/data/repositories/order_repository_impl.dart';
import 'features/order/presentation/bloc/order_bloc.dart';
import 'features/main/presentation/screens/main_screen.dart';
import 'features/notification/data/repositories/notification_repository_impl.dart';
import 'features/notification/presentation/bloc/notification_bloc.dart';
import 'features/notification/presentation/bloc/notification_event.dart';
import 'features/chat/data/datasources/chat_remote_datasource.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/admin/data/datasources/admin_remote_datasource.dart';
import 'features/admin/data/repositories/admin_repository.dart';
import 'features/admin/presentation/bloc/admin_order_bloc.dart';
import 'features/admin/presentation/bloc/admin_chat_bloc.dart';
import 'features/admin/presentation/screens/admin_main_screen.dart';

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

    final orderRemoteDataSource = OrderRemoteDataSource(apiClient);
    final orderRepository = OrderRepositoryImpl(orderRemoteDataSource);

    final notificationRepository = NotificationRepositoryImpl(apiClient);

    final chatRemoteDataSource = ChatRemoteDataSource(apiClient);
    final chatRepository = ChatRepositoryImpl(chatRemoteDataSource);

    final adminDataSource = AdminRemoteDataSource(apiClient);
    final adminRepository = AdminRepository(adminDataSource);

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
        BlocProvider(
          create: (_) => OrderBloc(orderRepository: orderRepository),
        ),
        BlocProvider(
          create: (_) => NotificationBloc(notificationRepository),
        ),
        BlocProvider(
          create: (_) => ChatBloc(chatRepository),
        ),
        BlocProvider(
          create: (_) => AdminOrderBloc(adminRepository),
        ),
        BlocProvider(
          create: (_) => AdminChatBloc(adminRepository),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) {
            if (state.status == AuthStatus.authenticated) {
              context.read<CartBloc>().add(const CartLoadRequested());
              context.read<NotificationBloc>().add(NotificationLoadRequested());
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state.status == AuthStatus.initial) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state.user != null) {
                // Role-based routing
                if (state.user!.role == 'admin') {
                  return const AdminMainScreen();
                }
                return const MainScreen();
              }

              return const LoginScreen();
            },
          ),
        ),
      ),
    );
  }
}
