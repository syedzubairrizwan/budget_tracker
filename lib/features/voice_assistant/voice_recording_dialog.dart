import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:budget_tracker/services/ai_parser_service.dart';
import 'package:budget_tracker/models/transaction.dart';

class VoiceRecordingDialog extends StatefulWidget {
  const VoiceRecordingDialog({super.key});

  @override
  VoiceRecordingDialogState createState() => VoiceRecordingDialogState();
}

class VoiceRecordingDialogState extends State<VoiceRecordingDialog>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isParsing = false;
  String _text = 'Press the microphone and start speaking...';

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _initSpeech();
  }

  void _initSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (val) {
          /* handle status */
        },
        onError: (val) {
          // handle error
          setState(() {
            _isListening = false;
            _text = "Error: Couldn't understand. Please try again.";
          });
        },
      );
      if (available) {
        _startListening();
      } else {
        setState(() {
          _text = "Speech recognition denied or not available.";
        });
      }
    } catch (e) {
      setState(() {
        _text = "Microphone permission error: $e";
      });
    }
  }

  void _startListening() {
    setState(() {
      _isListening = true;
      _text = "Listening...";
    });
    _speech.listen(
      onResult: (val) {
        setState(() {
          _text = val.recognizedWords;
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      listenOptions: stt.SpeechListenOptions(
        cancelOnError: true,
        partialResults: true,
      ),
    );
  }

  String? _errorMessage;

  void _stopListeningAndParse() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    }

    if (_text.isEmpty ||
        _text == "Listening..." ||
        _text.startsWith("Press the")) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    setState(() {
      _isParsing = true;
      _errorMessage = null;
      _text = _text; // Keep the captured text
    });

    try {
      final parser = AIParserService();
      final result = await parser.parseTransaction(_text);

      if (mounted) {
        if (result != null) {
          Navigator.of(context).pop(result);
        } else {
          setState(() {
            _isParsing = false;
            _errorMessage =
                "AI couldn't parse this. You can try again or enter details manually.";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isParsing = false;
          _errorMessage =
              "Connection error. Please check your internet and try again.";
        });
      }
    }
  }

  void _proceedManually() {
    // Return a partial result with just the title as the transcript
    Navigator.of(context).pop(
      ParsedTransactionResult(
        title: _text,
        amount: 0.0,
        type: TransactionType.expense,
        isSplit: false,
        categoryHint: 'Other',
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isParsing
                  ? 'Processing'
                  : (_isListening ? 'Listening' : 'Ready'),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (_isParsing) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text(
                'AI is analyzing your request...',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ] else ...[
              GestureDetector(
                onTap: () {
                  if (_isListening) {
                    _stopListeningAndParse();
                  } else if (!_isParsing) {
                    _startListening();
                  }
                },
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Container(
                      padding: EdgeInsets.all(
                        _isListening
                            ? 16.0 + (_animationController.value * 10)
                            : 16.0,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.1),
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: _isListening
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              )
            else
              Text(
                _text,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isParsing)
                  TextButton(
                    onPressed: () {
                      if (_isListening) {
                        _stopListeningAndParse();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(_isListening ? 'Done' : 'Cancel'),
                  ),
                if (_errorMessage != null) ...[
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _proceedManually,
                    child: const Text('Enter Manually'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
