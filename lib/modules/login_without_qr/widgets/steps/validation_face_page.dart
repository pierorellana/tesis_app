import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:math';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/modules/login_without_qr/services/face_validation_service.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/cards/hikvision_camera_widget.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/cards/face_circle_scanner.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/rejected_alerts/rejected_validation_face.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/succes_alerts/success_validation_face.dart';
import 'package:tesis_app/shared/helpers/responsive.dart';

enum _FaceUiState { scanning, validating, success, rejected }

class ValidationFacePage extends StatefulWidget {
  const ValidationFacePage({
    super.key,
    required this.onBack,
    required this.onSuccessNext,
    required this.fotoCedulaBase64,
  });

  final VoidCallback onBack;
  final VoidCallback onSuccessNext;
  final String fotoCedulaBase64;

  @override
  State<ValidationFacePage> createState() => _ValidationFacePageState();
}

class _ValidationFacePageState extends State<ValidationFacePage> {
  final FaceValidationService _faceService = FaceValidationService();
  late final FaceDetector _faceDetector;
  late final HikvisionCameraConfig _cameraConfig;

  Player? _player;
  VideoController? _videoController;
  StreamSubscription<dynamic>? _playerErrorSub;
  StreamSubscription<VideoParams>? _rtspParamsSub;
  Timer? _rtspTimeout;
  List<String> _rtspCandidates = const [];
  int _rtspCandidateIndex = 0;
  bool _rtspConnected = false;

  Timer? _scanTimer;
  bool _processingFrame = false;
  bool _isValidating = false;
  DateTime _lastProcess = DateTime.fromMillisecondsSinceEpoch(0);
  int _stableHits = 0;
  String? _errorMessage;

  Directory? _tempDir;
  Uint8List? _snapshotCache;
  DateTime _snapshotCacheAt = DateTime.fromMillisecondsSinceEpoch(0);
  Uint8List? _lastFaceFrame;
  Uint8List? _cedulaPreviewBytes;
  DateTime _lastPreviewUpdate = DateTime.fromMillisecondsSinceEpoch(0);

  Map<String, String>? _digestChallenge;
  int _digestNc = 0;
  bool _loggedDigestChallenge = false;
  final Random _rng = Random();

  _FaceUiState _uiState = _FaceUiState.scanning;

  @override
  void initState() {
    super.initState();
    _cameraConfig = _buildConfigFromEnv();
    _cedulaPreviewBytes = _decodeBase64Image(widget.fotoCedulaBase64);
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: false,
        enableContours: false,
        enableTracking: true,
        performanceMode: FaceDetectorMode.accurate,
        minFaceSize: 0.08,
      ),
    );
    _startRtspPreview();
    _startFaceLoop();
  }

  @override
  void dispose() {
    _stopFaceLoop();
    _rtspTimeout?.cancel();
    _playerErrorSub?.cancel();
    _rtspParamsSub?.cancel();
    _videoController = null;
    _player?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ValidationFacePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fotoCedulaBase64 != widget.fotoCedulaBase64) {
      _cedulaPreviewBytes = _decodeBase64Image(widget.fotoCedulaBase64);
    }
  }

  HikvisionCameraConfig _buildConfigFromEnv() {
    final rtsp = dotenv.env['HIKVISION_FACE_RTSP_URL'] ?? '';
    final snapshot = dotenv.env['HIKVISION_FACE_SNAPSHOT_URL'];
    final user = dotenv.env['HIKVISION_FACE_USER'];
    final pass = dotenv.env['HIKVISION_FACE_PASS'];

    return HikvisionCameraConfig(
      rtspUrl: rtsp,
      snapshotUrl: snapshot,
      username: user,
      password: pass,
    );
  }

  void _startFaceLoop() {
    _scanTimer?.cancel();
    _scanTimer = Timer.periodic(
      const Duration(milliseconds: 450),
      (_) => _processFaceFrame(),
    );
  }

  void _stopFaceLoop() {
    _scanTimer?.cancel();
    _scanTimer = null;
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
    final raw = _cameraConfig.resolvedRtspUrl.trim();
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

  Future<void> _processFaceFrame() async {
    if (!mounted) return;
    if (_uiState != _FaceUiState.scanning) return;
    if (_processingFrame || _isValidating) return;

    final now = DateTime.now();
    if (now.difference(_lastProcess).inMilliseconds < 320) return;
    _lastProcess = now;

    _processingFrame = true;
    try {
      final bytes = await _getSnapshotBytes();
      if (bytes == null || bytes.isEmpty) {
        _stableHits = 0;
        return;
      }

      _updateFacePreview(bytes);

      final imageSize = await _decodeImageSize(bytes);
      if (imageSize == null) {
        _stableHits = 0;
        return;
      }

      final input = await _inputImageFromBytes(
        bytes,
        filename: 'face_frame.jpg',
      );
      if (input == null) return;

      final faces = await _faceDetector.processImage(input);
      if (faces.isEmpty) {
        _stableHits = 0;
        return;
      }

      final face = _pickLargestFace(faces);
      final ok = _isFaceGood(face, imageSize);

      _stableHits = ok ? _stableHits + 1 : 0;

      if (ok && _stableHits >= 2) {
        await _validateFace(bytes);
      }
    } catch (_) {
      // ignore frame errors
    } finally {
      _processingFrame = false;
    }
  }

  Face _pickLargestFace(List<Face> faces) {
    faces.sort(
      (a, b) => (b.boundingBox.width * b.boundingBox.height).compareTo(
        a.boundingBox.width * a.boundingBox.height,
      ),
    );
    return faces.first;
  }

  bool _isFaceGood(Face face, ui.Size imageSize) {
    final box = face.boundingBox;
    final areaRatio =
        (box.width * box.height) / (imageSize.width * imageSize.height);

    if (areaRatio < 0.06 || areaRatio > 0.9) return false;

    final center = box.center;
    final dx = (center.dx - imageSize.width / 2).abs() / imageSize.width;
    final dy = (center.dy - imageSize.height / 2).abs() / imageSize.height;

    if (dx > 0.28 || dy > 0.28) return false;

    final yaw = (face.headEulerAngleY ?? 0).abs();
    final roll = (face.headEulerAngleZ ?? 0).abs();
    final pitch = (face.headEulerAngleX ?? 0).abs();

    if (yaw > 25 || roll > 20 || pitch > 25) return false;

    final leftEye = face.leftEyeOpenProbability;
    final rightEye = face.rightEyeOpenProbability;
    if (leftEye != null && rightEye != null) {
      if (leftEye < 0.2 || rightEye < 0.2) return false;
    }

    return true;
  }

  void _updateFacePreview(Uint8List bytes) {
    final now = DateTime.now();
    if (now.difference(_lastPreviewUpdate).inMilliseconds < 500) {
      return;
    }
    _lastPreviewUpdate = now;
    if (!mounted) return;
    setState(() => _lastFaceFrame = bytes);
  }

  Future<void> _validateFace(Uint8List bytes) async {
    if (_isValidating || _uiState != _FaceUiState.scanning) return;

    if (widget.fotoCedulaBase64.trim().isEmpty) {
      setState(() => _uiState = _FaceUiState.rejected);
      return;
    }

    _isValidating = true;
    _stopFaceLoop();

    if (mounted) {
      setState(() => _uiState = _FaceUiState.validating);
    }

    final payload = {
      'foto_cedula_base64': widget.fotoCedulaBase64,
      'foto_rostro_vivo_base64': base64Encode(bytes),
    };

    final response = await _faceService.getFace(context, payload: payload);

    if (!mounted) return;

    if (!response.error && response.data?.match == true) {
      setState(() => _uiState = _FaceUiState.success);
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) widget.onSuccessNext();
      });
    } else {
      setState(() => _uiState = _FaceUiState.rejected);
    }

    _isValidating = false;
  }

  void _retry() {
    _stableHits = 0;
    _isValidating = false;
    setState(() => _uiState = _FaceUiState.scanning);
    _startFaceLoop();
  }

  Future<Uint8List?> _getSnapshotBytes() async {
    final snapUrl = _cameraConfig.snapshotUrl;
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
      final baseHeaders = _cameraConfig.snapshotHeaders;

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
          return null;
        }
        return null;
      }
      return null;
    } on TimeoutException catch (_) {
      return null;
    } catch (_) {
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

  Future<ui.Size?> _decodeImageSize(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final size = ui.Size(image.width.toDouble(), image.height.toDouble());
      image.dispose();
      return size;
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

  @override
  Widget build(BuildContext context) {
    if (_uiState == _FaceUiState.success) {
      return const SuccessValidationFace();
    }

    if (_uiState == _FaceUiState.rejected) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final previewWidth =
              (constraints.maxWidth * 0.26).clamp(220.0, 360.0);
          final previewHeight = previewWidth * 0.62;

          return RejectedValidationFace(
            onRetry: _retry,
            onBackToStart: widget.onBack,
            preview: _buildPreviewPanel(
              width: previewWidth,
              height: previewHeight,
            ),
          );
        },
      );
    }

    if (_uiState == _FaceUiState.validating) {
      return _buildValidating();
    }

    return _buildScanner(context);
  }

  Widget _buildValidating() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 18),
        const SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(strokeWidth: 4),
        ),
        const SizedBox(height: 22),
        const Text(
          'Validando rostro...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppTheme.dark,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Mantenga su rostro dentro del círculo',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.hinText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildScanner(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final r = context.responsive;
        final isShort = constraints.maxHeight < 650;
        final isTablet = r.isTablet;
        final paddingH = (constraints.maxWidth * 0.05).clamp(16.0, 64.0);

        final titleScale = isTablet ? 1.08 : 1.0;
        final hintScale = isTablet ? 1.05 : 1.0;
        final titleSize = (r.dp(2.6) * titleScale).clamp(28.0, 58.0);
        final hintSize = (r.dp(1.0) * hintScale).clamp(12.0, 18.0);

        final availableWidth = constraints.maxWidth - (paddingH * 2);
        final widthFactor = isTablet ? 0.72 : 0.65;
        final heightFactor = isTablet ? 0.66 : (isShort ? 0.48 : 0.58);
        final maxCardSize = math.min(
          availableWidth * widthFactor,
          constraints.maxHeight * heightFactor,
        );
        final cardSize = maxCardSize.clamp(260.0, 620.0);

        final padScale = isTablet ? 1.05 : 1.0;
        final cardPadding = (r.dp(1.2) * padScale).clamp(16.0, 26.0);
        final circleSize = (cardSize - (cardPadding * 1)).clamp(220.0, 540.0);

        final gapScale = isTablet ? 1.08 : 1.0;
        final gapTitle = (constraints.maxHeight * 0.02 * gapScale).clamp(
          8.0,
          18.0,
        );
        final gapBlock = (constraints.maxHeight * 0.03 * gapScale).clamp(
          12.0,
          28.0,
        );
        final gapAfter = (constraints.maxHeight * 0.03 * gapScale).clamp(
          12.0,
          28.0,
        );
        final buttonGap = (constraints.maxHeight * (isTablet ? 0.035 : 0.05))
            .clamp(14.0, 30.0);
        final buttonWidth = (constraints.maxWidth * (isTablet ? 0.2 : 0.22))
            .clamp(120.0, 180.0);
        final buttonHeight = (constraints.maxHeight * (isTablet ? 0.07 : 0.08))
            .clamp(46.0, 60.0);

        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: gapTitle),
              Text(
                'Valide su rostro',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.dark,
                  height: 1.05,
                ),
              ),
              SizedBox(height: gapBlock),
              Center(
                child: FaceCircleScanner(
                  size: circleSize,
                  controller: _videoController,
                  errorMessage: _errorMessage,
                ),
              ),
              SizedBox(height: gapAfter),
              Text(
                'Mire a la cámara',
                style: TextStyle(
                  fontSize: hintSize,
                  color: AppTheme.hinText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Mantenga el rostro dentro del círculo',
                style: TextStyle(
                  fontSize: hintSize,
                  color: AppTheme.hinText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: buttonGap),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text(
                      'Volver',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.dark,
                      side: const BorderSide(color: Color(0xFFD7DEE8)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreviewPanel({required double width, required double height}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD7DEE8)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPreviewItem(
            label: 'Cédula (OCR)',
            width: width,
            height: height,
            bytes: _cedulaPreviewBytes,
          ),
          const SizedBox(height: 12),
          _buildPreviewItem(
            label: 'Rostro vivo',
            width: width,
            height: height,
            bytes: _lastFaceFrame,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewItem({
    required String label,
    required double width,
    required double height,
    required Uint8List? bytes,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.hinText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F5FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: bytes != null
                ? Image.memory(
                    bytes,
                    fit: BoxFit.contain,
                  )
                : Center(
                    child: Text(
                      'Sin imagen',
                      style: TextStyle(
                        color: AppTheme.hinText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Uint8List? _decodeBase64Image(String input) {
    if (input.trim().isEmpty) return null;
    try {
      final trimmed = input.trim();
      final comma = trimmed.indexOf(',');
      final raw = comma >= 0 ? trimmed.substring(comma + 1) : trimmed;
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
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
    final user = _cameraConfig.username;
    final pass = _cameraConfig.password;
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
