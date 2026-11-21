import 'package:flutter/material.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/core/widgets/generic_error.dart';
import 'package:users_api/core/widgets/message_view.dart';
import 'package:users_api/core/widgets/offline.dart';
import 'package:users_api/core/widgets/server_error.dart';

class UsersErrorView extends StatelessWidget {
  const UsersErrorView({super.key, required this.error, required this.onRetry});

  final ApiException error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (error) {
      NoConnectionException() => Offline(onRetry: onRetry),
      NotFoundException() || UnauthorizedException() => const MessageView(
        icon: Icons.block,
        text: 'Not available',
      ),
      ServerException(:final status) => ServerError(status, onRetry: onRetry),
      BadResponseException() => const GenericError(),
    };
  }
}
