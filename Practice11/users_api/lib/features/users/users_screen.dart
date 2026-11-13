import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/widgets/generic_error.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/message_view.dart';
import '../../core/widgets/offline.dart';
import '../../core/widgets/server_error.dart';
import 'new_user_screen.dart';
import 'user_list.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  Widget _body(UsersModel m) {
    if (m.loading) return const LoadingView();
    return switch (m.error) {
      null => RefreshIndicator(onRefresh: m.load, child: UserList(m.items)),
      NoConnectionException() => Offline(onRetry: m.load),
      NotFoundException() || UnauthorizedException() => const MessageView(
        icon: Icons.block,
        text: 'Not available',
      ),
      ServerException(:final status) => ServerError(status, onRetry: m.load),
      BadResponseException() => const GenericError(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const NewUserScreen())),
            icon: const Icon(Icons.person_add),
          ),
        ],
      ),
      body: _body(m),
    );
  }
}
