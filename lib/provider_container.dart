import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_manager_front/src/data/data.dart';
import 'package:service_manager_front/src/domain/repository/repository.dart';

class ProviderContainer extends StatelessWidget {
  const ProviderContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final servinDatasource = ServinsDataSource();
    final userDatasource = UsersDataSource();
    final authDatasource = AuthsDataSource();
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => ServinsRepository(servinDatasource),
        ),
        RepositoryProvider(
          create: (context) => UsersRepository(userDatasource),
        ),
        RepositoryProvider(
          create: (context) => AuthsRepository(authDatasource),
        ),
      ],
      child: child,
    );
  }
}
