import 'package:flutter/material.dart';

import '../../../core/dialogs/logs_dialog.dart';
import '../../../core/utils/app_localisations.dart';

class LogsWidget extends StatefulWidget {
  const LogsWidget({super.key});

  @override
  State<LogsWidget> createState() => _LogsWidgetState();
}

class _LogsWidgetState extends State<LogsWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(AppLocalizations.of(context)!.logs),
      trailing: IconButton(
        onPressed: () => showLogsDialog(context),
        icon: const Icon(Icons.chevron_right),
      ),
      onTap: () => showLogsDialog(context),
    );
  }
}
