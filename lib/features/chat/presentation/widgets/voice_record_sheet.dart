import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../../../core/locale/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

/// Bottom sheet d'enregistrement vocal. Retourne le chemin local ou null.
class VoiceRecordSheet extends StatefulWidget {
  const VoiceRecordSheet({super.key, required this.strings});

  final AppStrings strings;

  @override
  State<VoiceRecordSheet> createState() => _VoiceRecordSheetState();
}

class _VoiceRecordSheetState extends State<VoiceRecordSheet> {
  AudioRecorder? _recorder;
  Timer? _timer;
  var _seconds = 0;
  var _recording = false;
  var _busy = false;
  String? _error;

  AppStrings get _s => widget.strings;

  AudioRecorder _requireRecorder() {
    return _recorder ??= AudioRecorder();
  }

  @override
  void dispose() {
    _timer?.cancel();
    final recorder = _recorder;
    if (recorder != null) {
      unawaited(recorder.dispose());
    }
    super.dispose();
  }

  String get _clock {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _toggleRecord() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final recorder = _requireRecorder();
      if (_recording) {
        _timer?.cancel();
        final path = await recorder.stop();
        if (!mounted) return;
        setState(() => _recording = false);
        if (path == null || _seconds < 1) {
          setState(() => _error = _s.voiceTooShort);
          return;
        }
        Navigator.pop(context, path);
        return;
      }

      final mic = await Permission.microphone.request();
      if (!mic.isGranted) {
        setState(() => _error = _s.micPermissionRequired);
        return;
      }

      if (!await recorder.hasPermission()) {
        setState(() => _error = _s.micUnavailable);
        return;
      }

      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );

      _seconds = 0;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _seconds += 1);
      });
      setState(() => _recording = true);
    } on MissingPluginException {
      setState(() => _error = _s.micPluginMissing);
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    _timer?.cancel();
    final recorder = _recorder;
    if (recorder != null && await recorder.isRecording()) {
      final path = await recorder.stop();
      if (path != null) {
        try {
          await File(path).delete();
        } catch (_) {}
      }
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _s.voiceMessage,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _recording ? _s.voiceTapToSend : _s.voiceTapToRecord,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _clock,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade700, fontSize: 13),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: _busy ? null : _cancel,
                  child: Text(_s.cancel),
                ),
                Material(
                  color: _recording ? Colors.redAccent : AppColors.brand,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _busy ? null : _toggleRecord,
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: Icon(
                        _recording ? Icons.stop_rounded : Icons.mic,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 72),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
