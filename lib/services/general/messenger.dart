import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final messengerProvider = Provider<Messenger>((ref) {
  return Messenger();
});

class Message {
  final String text;
  final MessageType type;
  final Duration duration;
  final VoidCallback? action;
  final String? actionLabel;

  Message({
    required this.text,
    required this.type,
    this.duration = const Duration(seconds: 3),
    this.action,
    this.actionLabel,
  });
}

enum MessageType {
  info,
  success,
  warning,
  error,
}

class Messenger {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  void showInfo(String message,
      {Duration? duration, VoidCallback? action, String? actionLabel}) {
    _showMessage(Message(
      text: message,
      type: MessageType.info,
      duration: duration ?? const Duration(seconds: 3),
      action: action,
      actionLabel: actionLabel,
    ));
  }

  void showSuccess(String message,
      {Duration? duration, VoidCallback? action, String? actionLabel}) {
    _showMessage(Message(
      text: message,
      type: MessageType.success,
      duration: duration ?? const Duration(seconds: 3),
      action: action,
      actionLabel: actionLabel,
    ));
  }

  void showWarning(String message,
      {Duration? duration, VoidCallback? action, String? actionLabel}) {
    _showMessage(Message(
      text: message,
      type: MessageType.warning,
      duration: duration ?? const Duration(seconds: 3),
      action: action,
      actionLabel: actionLabel,
    ));
  }

  void showError(String message,
      {Duration? duration, VoidCallback? action, String? actionLabel}) {
    _showMessage(Message(
      text: message,
      type: MessageType.error,
      duration: duration ?? const Duration(seconds: 5),
      action: action,
      actionLabel: actionLabel,
    ));
  }

  void _showMessage(Message message) {
    final scaffoldMessenger = scaffoldMessengerKey.currentState;
    if (scaffoldMessenger == null) return;

    scaffoldMessenger.clearSnackBars();

    final snackBar = SnackBar(
      content: Text(message.text),
      duration: message.duration,
      backgroundColor: _getBackgroundColor(message.type),
      action: message.action != null && message.actionLabel != null
          ? SnackBarAction(
              label: message.actionLabel!,
              textColor: Colors.white,
              onPressed: message.action!,
            )
          : null,
    );

    scaffoldMessenger.showSnackBar(snackBar);
  }

  Color _getBackgroundColor(MessageType type) {
    switch (type) {
      case MessageType.info:
        return Colors.blue.shade700;
      case MessageType.success:
        return Colors.green.shade700;
      case MessageType.warning:
        return Colors.amber.shade700;
      case MessageType.error:
        return Colors.red.shade700;
    }
  }
}
