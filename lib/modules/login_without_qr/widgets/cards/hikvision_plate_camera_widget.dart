import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/cards/hikvision_camera_widget.dart';

class HikvisionPlateCameraWidget extends StatefulWidget {
  const HikvisionPlateCameraWidget({
    super.key,
    required this.controller,
    required this.config,
    required this.onCaptured,
    this.autoCapture = false,
    this.width,
    this.height,
    this.padding,
    this.framePadding,
  });

  final HikvisionCameraController controller;
  final HikvisionCameraConfig config;
  final ValueChanged<XFile> onCaptured;
  final bool autoCapture;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? framePadding;

  @override
  State<HikvisionPlateCameraWidget> createState() =>
      _HikvisionPlateCameraWidgetState();
}

class _HikvisionPlateCameraWidgetState
    extends State<HikvisionPlateCameraWidget> {
  Player? _player;
  VideoController? _videoController;
  StreamSubscription<dynamic>? _playerErrorSub;
  StreamSubscription<VideoParams>? _rtspParamsSub;
  Timer? _rtspTimeout;
  List<String> _rtspCandidates = const [];
  int _rtspCandidateIndex = 0;
  bool _rtspConnected = false;
  late final TextRecognizer _textRecognizer;

  bool _isTaking = false;
  String? _errorMessage;

  Timer? _autoTimer;
  bool _processingFrame = false;
  bool _autoCaptured = false;
  DateTime _lastProcess = DateTime.fromMillisecondsSinceEpoch(0);
  int _stableHits = 0;
  Directory? _tempDir;

  Uint8List? _snapshotCache;
  DateTime _snapshotCacheAt = DateTime.fromMillisecondsSinceEpoch(0);
  Map<String, String>? _digestChallenge;
  int _digestNc = 0;
  final Random _rng = Random();
  bool _loggedDigestChallenge = false;

  @override
  void initState() {
    super.initState();
    widget.controller.bind(takePhoto: takePhoto);
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    _startRtspPreview();

    if (widget.autoCapture) {
      _startAutoCapture();
    }
  }

  @override
  void didUpdateWidget(covariant HikvisionPlateCameraWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      widget.controller.bind(takePhoto: takePhoto);
    }
    if (oldWidget.autoCapture != widget.autoCapture) {
      if (widget.autoCapture) {
        _startAutoCapture();
      } else {
        _stopAutoCapture();
      }
    }
  }

  void _startAutoCapture() {
    if (_autoTimer != null) return;
    _autoTimer = Timer.periodic(
      const Duration(milliseconds: 450),
      (_) => _processAutoFrame(),
    );
  }

  void _stopAutoCapture() {
    _autoTimer?.cancel();
    _autoTimer = null;
  }

  void _startRtspPreview() {
    _rtspCandidates = _buildRtspCandidates();
    _rtspCandidateIndex = 0;
    _rtspConnected = false;

    if (_rtspCandidates.isEmpty) {
      _errorMessage = 'RTSP URL vacía';
      return;
    }

    _player = Player(
      configuration: const PlayerConfiguration(
        muted: true,
        bufferSize: 2 * 1024 * 1024,
        protocolWhitelist: [
          'udp',
          'rtp',
          'rtsp',
          'tcp',
          'tls',
          'data',
          'file',
          'http',
          'https',
          'crypto',
        ],
      ),
    );
    _videoController = VideoController(_player!);

    _playerErrorSub = _player!.stream.error.listen(_handleRtspError);
    _rtspParamsSub = _player!.stream.videoParams.listen(_handleRtspParams);

    _openNextRtspCandidate();
  }

  void _handleRtspError(dynamic error) {
    debugPrint('Hikvision RTSP error: $error');
    if (!mounted) return;
    setState(() => _errorMessage = error?.toString());
    if (_rtspConnected) return;
    _rtspTimeout?.cancel();
    _rtspTimeout = Timer(const Duration(seconds: 2), _openNextRtspCandidate);
  }

  void _handleRtspParams(VideoParams params) {
    final width = params.w ?? params.dw ?? 0;
    final height = params.h ?? params.dh ?? 0;
    if (width <= 0 || height <= 0) return;
    _rtspConnected = true;
    _rtspTimeout?.cancel();
    if (!mounted) return;
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  void _openNextRtspCandidate() {
    if (_player == null) return;
    if (_rtspCandidateIndex >= _rtspCandidates.length) {
      if (mounted && _errorMessage == null) {
        setState(() => _errorMessage = 'Sin conexión RTSP');
      }
      return;
    }

    final url = _rtspCandidates[_rtspCandidateIndex++];
    _rtspConnected = false;
    if (mounted && _errorMessage != null) {
      setState(() => _errorMessage = null);
    }
    debugPrint('Hikvision RTSP intentando: $url');

    _player!.open(Media(url), play: true);
    _rtspTimeout?.cancel();
    _rtspTimeout = Timer(const Duration(seconds: 6), () {
      if (!_rtspConnected) {
        _openNextRtspCandidate();
      }
    });
  }

  List<String> _buildRtspCandidates() {
    final raw = widget.config.resolvedRtspUrl.trim();
    if (raw.isEmpty) return const [];
    final uri = Uri.tryParse(raw);
    if (uri == null) return [raw];

    final candidates = <Uri>[];
    void add(Uri u) {
      if (!candidates.any((c) => c.toString() == u.toString())) {
        candidates.add(u);
      }
    }

    add(uri);

    final hasPort = uri.hasPort && uri.port > 0;
    if (!hasPort || uri.port == 80) {
      add(uri.replace(port: 554));
    }

    if (uri.path.contains('/101')) {
      final altPath = uri.path.replaceFirst('/101', '/102');
      if (altPath != uri.path) {
        add(uri.replace(path: altPath));
        if (!hasPort || uri.port == 80) {
          add(uri.replace(path: altPath, port: 554));
        }
      }
    }

    final ordered = <String>[];
    final seen = <String>{};
    for (final u in candidates) {
      final base = u.toString();
      if (seen.add(base)) ordered.add(base);

      if (!u.queryParameters.containsKey('rtsp_transport')) {
        final params = Map<String, String>.from(u.queryParameters);
        params['rtsp_transport'] = 'tcp';
        final tcpUrl = u.replace(queryParameters: params).toString();
        if (seen.add(tcpUrl)) ordered.add(tcpUrl);
      }
    }

    return ordered;
  }

  Future<void> _processAutoFrame() async {
    if (!mounted || _autoCaptured || _processingFrame) return;
    final now = DateTime.now();
    if (now.difference(_lastProcess).inMilliseconds < 350) return;
    _lastProcess = now;

    _processingFrame = true;
    try {
      final bytes = await _fetchFrameBytes();
      if (bytes == null || bytes.isEmpty) return;

      final input = await _inputImageFromBytes(
        bytes,
        filename: 'plate_frame.jpg',
      );
      if (input == null) return;

      final recognized = await _textRecognizer.processImage(input);
      final ok = _looksLikePlate(recognized.text);

      if (ok) {
        _stableHits++;
      } else {
        _stableHits = 0;
      }

      if (_stableHits >= 4) {
        _autoCaptured = true;
        _stopAutoCapture();
        await takePhoto();
      }
    } catch (_) {
      // ignorar frame malo
    } finally {
      _processingFrame = false;
    }
  }

  bool _looksLikePlate(String text) {
    final upper = text.toUpperCase();
    final normalized = upper.replaceAll(RegExp(r'[^A-Z0-9]'), '');

    final ecuadorLike = RegExp(r'[A-Z]{3}\d{3,4}').hasMatch(normalized);
    if (ecuadorLike) return true;

    final shortFormat = RegExp(r'[A-Z]{2}\d{4}').hasMatch(normalized);
    if (shortFormat) return true;

    return RegExp(r'\b[A-Z]{2,3}\s*-?\s*\d{3,4}\b').hasMatch(upper);
  }

  Future<Uint8List?> _fetchFrameBytes() async {
    final snapUrl = widget.config.snapshotUrl;
    if (snapUrl != null && snapUrl.trim().isNotEmpty) {
      final bytes = await _getSnapshotBytes();
      if (bytes != null && bytes.isNotEmpty) return bytes;
    }
    return null;
  }

  Future<Uint8List?> _getSnapshotBytes() async {
    final snapUrl = widget.config.snapshotUrl;
    if (snapUrl == null || snapUrl.trim().isEmpty) return null;
    final now = DateTime.now();
    if (now.difference(_snapshotCacheAt).inMilliseconds < 300) {
      return _snapshotCache;
    }
    final bytes = await _fetchSnapshotHttp(snapUrl);
    if (bytes != null && bytes.isNotEmpty) {
      _snapshotCache = bytes;
      _snapshotCacheAt = now;
      return bytes;
    }
    return null;
  }

  Future<Uint8List?> _fetchSnapshotHttp(String url) async {
    try {
      final uri = Uri.parse(url);
      final baseHeaders = widget.config.snapshotHeaders;

      final digestAuth = _buildDigestAuthHeader(uri, 'GET');
      if (digestAuth != null) {
        final resp = await http
            .get(uri, headers: {'Authorization': digestAuth})
            .timeout(const Duration(seconds: 4));
        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          return resp.bodyBytes;
        }
        if (resp.statusCode == 401) {
          final rawChallenge = resp.headers['www-authenticate'];
          _updateDigestChallenge(rawChallenge);
          final retryAuth = _buildDigestAuthHeader(uri, 'GET');
          if (retryAuth != null) {
            final resp2 = await http
                .get(uri, headers: {'Authorization': retryAuth})
                .timeout(const Duration(seconds: 4));
            if (resp2.statusCode >= 200 && resp2.statusCode < 300) {
              return resp2.bodyBytes;
            }
          }
        }
      }

      final resp = await http
          .get(uri, headers: baseHeaders.isNotEmpty ? baseHeaders : null)
          .timeout(const Duration(seconds: 4));
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return resp.bodyBytes;
      }
      if (resp.statusCode == 401) {
        _updateDigestChallenge(resp.headers['www-authenticate']);
        final auth = _buildDigestAuthHeader(uri, 'GET');
        if (auth != null) {
          final resp2 = await http
              .get(uri, headers: {'Authorization': auth})
              .timeout(const Duration(seconds: 4));
          if (resp2.statusCode >= 200 && resp2.statusCode < 300) {
            return resp2.bodyBytes;
          }
          debugPrint('Hikvision snapshot 401');
          return null;
        }
        debugPrint('Hikvision snapshot 401 (digest build)');
        return null;
      }
      debugPrint('Hikvision snapshot ${resp.statusCode}');
      return null;
    } on TimeoutException catch (_) {
      debugPrint('Hikvision snapshot timeout');
      return null;
    } catch (e, st) {
      debugPrint('Hikvision snapshot error: $e');
      debugPrintStack(stackTrace: st);
      return null;
    }
  }

  Future<InputImage?> _inputImageFromBytes(
    Uint8List bytes, {
    required String filename,
  }) async {
    try {
      final dir = await _ensureTempDir();
      final path = '${dir.path}${Platform.pathSeparator}$filename';
      final file = File(path);
      await file.writeAsBytes(bytes, flush: true);
      return InputImage.fromFilePath(file.path);
    } catch (_) {
      return null;
    }
  }

  Future<File?> _writeCaptureFile(Uint8List bytes) async {
    try {
      final dir = await _ensureTempDir();
      final name =
          'hik_plate_capture_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '${dir.path}${Platform.pathSeparator}$name';
      final file = File(path);
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } catch (_) {
      return null;
    }
  }

  Future<Directory> _ensureTempDir() async {
    final cached = _tempDir;
    if (cached != null) return cached;
    final dir = await getTemporaryDirectory();
    _tempDir = dir;
    return dir;
  }

  Future<void> takePhoto() async {
    if (_isTaking) return;

    setState(() => _isTaking = true);
    try {
      _autoCaptured = true;
      _stopAutoCapture();

      final bytes = await _fetchFrameBytes();
      if (bytes == null || bytes.isEmpty) return;

      final file = await _writeCaptureFile(bytes);
      if (file == null) return;

      widget.onCaptured(XFile(file.path));
    } catch (e) {
      debugPrint('Error takeSnapshot: $e');
    } finally {
      if (mounted) setState(() => _isTaking = false);
    }
  }

  @override
  void dispose() {
    _stopAutoCapture();
    _textRecognizer.close();
    _rtspTimeout?.cancel();
    _rtspTimeout = null;
    _playerErrorSub?.cancel();
    _playerErrorSub = null;
    _rtspParamsSub?.cancel();
    _rtspParamsSub = null;
    _videoController = null;
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double cardWidth =
        widget.width ?? (size.width * 0.36).clamp(520.0, 720.0);
    final double cardHeight =
        widget.height ?? (size.height * 0.52).clamp(330.0, 460.0);
    final outerPadding = widget.padding ?? const EdgeInsets.all(18);
    final innerPadding = widget.framePadding ?? const EdgeInsets.all(22);

    return Container(
      width: cardWidth,
      height: cardHeight,
      padding: outerPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD7DEE8), width: 1),
        boxShadow: [
          BoxShadow(
            blurRadius: 26,
            offset: const Offset(0, 14),
            color: Colors.black.withOpacity(0.10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: innerPadding,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final controller = _videoController;
                      if (controller == null) return _buildPlaceholder();
                      return Video(controller: controller, fit: BoxFit.cover);
                    },
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: innerPadding,
                child: CustomPaint(
                  painter: _FramePainter(color: AppTheme.primaryColor),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            if (_errorMessage != null)
              Positioned.fill(
                child: Center(
                  child: Text(
                    kDebugMode && _errorMessage != null
                        ? 'No se pudo conectar a la camara\n$_errorMessage'
                        : 'No se pudo conectar a la camara',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            if (_isTaking)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.12),
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 34,
                    height: 34,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5FA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        Icons.photo_camera_outlined,
        size: 46,
        color: AppTheme.hinText.withOpacity(0.6),
      ),
    );
  }

  Map<String, String> _parseDigestChallenge(String header) {
    final trimmed = header.trim();
    final idx = trimmed.toLowerCase().indexOf('digest');
    final params = idx >= 0 ? trimmed.substring(idx + 6).trim() : trimmed;
    final parts = _splitDigestParams(params);
    final map = <String, String>{};
    for (final part in parts) {
      final eq = part.indexOf('=');
      if (eq <= 0) continue;
      final key = part.substring(0, eq).trim();
      var value = part.substring(eq + 1).trim();
      if (value.startsWith('"') && value.endsWith('"') && value.length > 1) {
        value = value.substring(1, value.length - 1);
      }
      if (key.isNotEmpty) map[key] = value;
    }
    return map;
  }

  void _updateDigestChallenge(String? rawChallenge) {
    final digestChallenge = _extractDigestChallenge(rawChallenge);
    if (digestChallenge == null) return;
    if (!_loggedDigestChallenge) {
      _loggedDigestChallenge = true;
      debugPrint('Hikvision www-authenticate: $rawChallenge');
    }
    _digestChallenge = _parseDigestChallenge(digestChallenge);
  }

  String? _extractDigestChallenge(String? header) {
    if (header == null || header.isEmpty) return null;
    final lower = header.toLowerCase();
    final idx = lower.indexOf('digest');
    if (idx < 0) return null;
    return header.substring(idx).trim();
  }

  String? _buildDigestAuthHeader(Uri uri, String method) {
    final challenge = _digestChallenge;
    final user = widget.config.username;
    final pass = widget.config.password;
    if (challenge == null || user == null || pass == null) return null;

    final realm = challenge['realm'] ?? '';
    final nonce = challenge['nonce'] ?? '';
    final qop = challenge['qop'];
    final opaque = challenge['opaque'];
    final rawAlgorithm = (challenge['algorithm'] ?? 'MD5').toUpperCase();
    final algorithmToken = rawAlgorithm.replaceAll('"', '');
    var algorithm = 'MD5';
    var includeAlgorithm = false;
    if (algorithmToken == 'MD5' || algorithmToken == 'MD5-SESS') {
      algorithm = algorithmToken;
      includeAlgorithm = true;
    } else if (algorithmToken.isNotEmpty) {
      debugPrint('Hikvision digest algorithm unsupported: $rawAlgorithm');
    }
    final charset = challenge['charset'];
    if (realm.isEmpty || nonce.isEmpty) return null;

    final uriPath = uri.path + (uri.hasQuery ? '?${uri.query}' : '');
    final ha1Raw = _md5('$user:$realm:$pass');
    final ha2 = _md5('$method:$uriPath');

    String response;
    String? cnonce;
    String? nc;
    String? qopValue;

    if (qop != null && qop.isNotEmpty) {
      final qops = qop.split(',').map((e) => e.trim().toLowerCase()).toList();
      qopValue = qops.contains('auth') ? 'auth' : qops.first;
      _digestNc += 1;
      nc = _digestNc.toString().padLeft(8, '0');
      cnonce = _randomHex(16);
    } else if (algorithm == 'MD5-SESS') {
      cnonce = _randomHex(16);
    }

    final ha1 = algorithm == 'MD5-SESS'
        ? _md5('$ha1Raw:$nonce:${cnonce ?? _randomHex(16)}')
        : ha1Raw;

    if (qopValue != null && nc != null && cnonce != null) {
      response = _md5('$ha1:$nonce:$nc:$cnonce:$qopValue:$ha2');
    } else {
      response = _md5('$ha1:$nonce:$ha2');
    }

    final buffer = StringBuffer();
    buffer.write('Digest ');
    buffer.write('username="$user", ');
    buffer.write('realm="$realm", ');
    buffer.write('nonce="$nonce", ');
    buffer.write('uri="$uriPath", ');
    buffer.write('response="$response"');
    if (opaque != null && opaque.isNotEmpty) {
      buffer.write(', opaque="$opaque"');
    }
    if (includeAlgorithm) {
      buffer.write(', algorithm=$algorithm');
    }
    if (charset != null && charset.isNotEmpty) {
      buffer.write(', charset=$charset');
    }
    if (qopValue != null && nc != null && cnonce != null) {
      buffer.write(', qop=$qopValue, nc=$nc, cnonce="$cnonce"');
    } else if (algorithm == 'MD5-SESS' && cnonce != null) {
      buffer.write(', cnonce="$cnonce"');
    }

    return buffer.toString();
  }

  List<String> _splitDigestParams(String input) {
    final parts = <String>[];
    final buf = StringBuffer();
    var inQuotes = false;
    for (var i = 0; i < input.length; i++) {
      final ch = input[i];
      if (ch == '"') {
        inQuotes = !inQuotes;
        buf.write(ch);
        continue;
      }
      if (ch == ',' && !inQuotes) {
        final part = buf.toString().trim();
        if (part.isNotEmpty) parts.add(part);
        buf.clear();
        continue;
      }
      buf.write(ch);
    }
    final tail = buf.toString().trim();
    if (tail.isNotEmpty) parts.add(tail);
    return parts;
  }

  String _md5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  String _randomHex(int length) {
    const chars = '0123456789abcdef';
    final buf = StringBuffer();
    for (var i = 0; i < length; i++) {
      buf.write(chars[_rng.nextInt(chars.length)]);
    }
    return buf.toString();
  }
}

class _FramePainter extends CustomPainter {
  final Color color;
  const _FramePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const double stroke = 4;
    const double cornerLength = 48;

    final paint = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final softPaint = Paint()
      ..color = color.withOpacity(0.25)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(18),
    );
    canvas.drawRRect(r, softPaint);

    canvas.drawArc(
      Rect.fromLTWH(0, 0, cornerLength, cornerLength),
      3.14,
      1.57,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromLTWH(size.width - cornerLength, 0, cornerLength, cornerLength),
      -1.57,
      1.57,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromLTWH(0, size.height - cornerLength, cornerLength, cornerLength),
      1.57,
      1.57,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        size.width - cornerLength,
        size.height - cornerLength,
        cornerLength,
        cornerLength,
      ),
      0,
      1.57,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _FramePainter oldDelegate) =>
      oldDelegate.color != color;
}
