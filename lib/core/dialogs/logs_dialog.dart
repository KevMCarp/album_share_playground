import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/logger/app_logger.dart';
import '../components/app_snackbar.dart';
import '../utils/app_localisations.dart';
import 'dialog_buttons.dart';

Future<void> showLogsDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (_) => const _LogsDialog(),
  );
}

class _LogsDialog extends StatelessWidget {
  const _LogsDialog();

  void _shareLogs(BuildContext context, String logs) {
    Clipboard.setData(
      ClipboardData(text: logs),
    ).then((_) {
      if (context.mounted) {
        return AppSnackbar.success(
          context: context,
          message: AppLocalizations.of(context)!.clipboardSave,
        );
      }
    }).onError((e, __) {
      if (context.mounted) {
        return AppSnackbar.warning(
          context: context,
          message: '$e',
        );
      }
    });
  }

  void _clearLogs(BuildContext context) {
    AppLogger.instance.clear();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final logs = AppLogger.instance.formatted();
    final locale = AppLocalizations.of(context)!;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  locale.logs,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (logs.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _shareLogs(context, logs),
                        icon: const Icon(Icons.copy),
                      ),
                      IconButton(
                        onPressed: () => _clearLogs(context),
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  )
              ],
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  logs,
                  style: GoogleFonts.jetBrainsMono(),
                ),
              ),
            ),
            DialogButtons(
              confirmText: locale.close,
              onConfirm: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
