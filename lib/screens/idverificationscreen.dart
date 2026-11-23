import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/palette.dart';
import 'homescreen.dart';

enum IdType { passport, national, license, face }

class IdVerificationScreen extends StatefulWidget {
  const IdVerificationScreen({super.key});

  @override
  State<IdVerificationScreen> createState() => _IdVerificationScreenState();
}

class _IdVerificationScreenState extends State<IdVerificationScreen> {
  static const _bg = Palette.night;
  static const _surface = Palette.surface;
  static const _line = Palette.line;
  static const _text = Palette.paper;
  static const _muted = Palette.muted;
  static const _accent = Palette.marigold;
  static const _ok = Palette.teal;
  static const _err = Palette.rose;
  static final _selectedBg =
      Color.alphaBlend(Palette.marigold.withAlpha(31), Palette.surface);

  static const _maxBytes = 10 * 1024 * 1024;

  final _picker = ImagePicker();
  int _step = 0; 
  IdType? _type;
  Uint8List? _front;
  Uint8List? _back;
  Uint8List? _selfie;
  String? _error;

  bool get _face => _type == IdType.face;

  void _go(int delta) {
    var n = _step + delta;
    if (_face && (n == 1 || n == 2)) {
      n = delta > 0 ? 3 : 0;
    } else if (n == 2 && _type == IdType.passport) {
      n += delta;
    }
    setState(() {
      _step = n < 0 ? 0 : n;
      _error = null;
    });
  }

  Future<void> _pick(ImageSource source, void Function(Uint8List) save,
      {bool selfie = false}) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
        preferredCameraDevice: selfie ? CameraDevice.front : CameraDevice.rear,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.length > _maxBytes) {
        setState(() => _error =
            'That photo is over 10 MB. Retake it or choose a smaller one.');
        return;
      }
      setState(() {
        save(bytes);
        _error = null;
      });
    } catch (_) {
      setState(() => _error =
          'We couldn’t open the camera or gallery. Check app permissions and try again.');
    }
  }

  void _openHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final level = _step == 0 ? 0 : (_step <= 2 ? 1 : (_step == 3 ? 2 : 3));
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                children: [
                  Row(children: [
                    if (_step != 4)
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () =>
                            _step == 0 ? Navigator.maybePop(context) : _go(-1),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _line),
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: _text, size: 20),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(children: [
                        for (var i = 0; i < 3; i++)
                          Expanded(
                            child: Container(
                              height: 5,
                              margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                              decoration: BoxDecoration(
                                color: i < level ? _accent : _line,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  Expanded(child: _body()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    switch (_step) {
      case 0:
        return _page(
          title: 'Verify your identity',
          lead:
              'Verify with an ID for full access, or with your face only for limited access.',
          children: [
            _option(IdType.passport, 'Passport', 'Photo page only'),
            _option(IdType.national, 'National ID card', 'Front and back'),
            _option(IdType.license, 'Driver’s license', 'Front and back'),
            _option(IdType.face, 'Face only, no ID',
                'Limited buying. Add an ID later to sell and withdraw.'),
          ],
          cta: 'Continue',
          onCta: _type == null ? null : () => _go(1),
        );
      case 1:
        return _page(
          title: _type == IdType.passport ? 'Photo your passport' : 'Front of your ID',
          lead: _type == IdType.passport
              ? 'Open it to the photo page and lay it flat in good light.'
              : 'Lay it flat in good light so every corner is visible.',
          children: [
            _slot(_front, 'Front of your ID will show here'),
            _pickRow((b) => _front = b),
            _errorText(),
            const SizedBox(height: 12),
            _tip('Text is sharp and readable'),
            _tip('No glare or covered details'),
            _tip('The whole ID is inside the frame'),
          ],
          cta: 'Continue',
          onCta: _front == null ? null : () => _go(1),
        );
      case 2:
        return _page(
          title: 'Now the back',
          lead: 'Same again: flat, bright, all four corners in view.',
          children: [
            _slot(_back, 'Back of your ID will show here'),
            _pickRow((b) => _back = b),
            _errorText(),
          ],
          cta: 'Continue',
          onCta: _back == null ? null : () => _go(1),
        );
      case 3:
        return _page(
          title: _face ? 'Verify your face' : 'Take a selfie',
          lead: _face
              ? 'Look straight at the camera in good light, no hat or sunglasses. Keep your whole face in view.'
              : 'We match your face to your ID. Look straight at the camera, no hat or sunglasses.',
          children: [
            Center(
              child: SizedBox(
                width: 240,
                child: _slot(_selfie, 'Your selfie will show here',
                    circle: true),
              ),
            ),
            _pickRow((b) => _selfie = b, selfie: true),
            _errorText(),
          ],
          cta: 'Submit for review',
          onCta: _selfie == null ? null : () => _go(1),
        );
      default:
        return _done();
    }
  }

  Widget _page({
    required String title,
    required String lead,
    required List<Widget> children,
    required String cta,
    required VoidCallback? onCta,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: _text,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.15)),
                const SizedBox(height: 8),
                Text(lead,
                    style: const TextStyle(color: _muted, fontSize: 16, height: 1.5)),
                const SizedBox(height: 24),
                ...children,
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: onCta,
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: Palette.night,
              disabledBackgroundColor: _line,
              disabledForegroundColor: _muted,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            child: Text(cta),
          ),
        ),
      ],
    );
  }

  Widget _option(IdType type, String title, String sub) {
    final selected = _type == type;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _type = type),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? _selectedBg : _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? _accent : _line, width: 1.5),
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title,
                    style: const TextStyle(
                        color: _text, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(color: _muted, fontSize: 14)),
              ]),
            ),
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? _accent : _line),
          ]),
        ),
      ),
    );
  }

  Widget _slot(Uint8List? bytes, String hint, {bool circle = false}) {
    final ready = bytes != null;
    final box = Container(
      decoration: BoxDecoration(
        color: _surface,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(20),
        border: Border.all(color: ready ? _ok : _line, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: ready
          ? Image.memory(bytes, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(hint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _muted, fontSize: 14)),
              ),
            ),
    );
    return AspectRatio(aspectRatio: circle ? 1 : 1.586, child: box);
  }

  Widget _pickRow(void Function(Uint8List) save, {bool selfie = false}) {
    Widget btn(String label, ImageSource src) => Expanded(
          child: OutlinedButton(
            onPressed: () => _pick(src, save, selfie: selfie),
            style: OutlinedButton.styleFrom(
              backgroundColor: _surface,
              foregroundColor: _text,
              side: const BorderSide(color: _line, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            child: Text(label),
          ),
        );
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(children: [
        btn(selfie ? 'Take selfie' : 'Take photo', ImageSource.camera),
        const SizedBox(width: 10),
        btn('Upload', ImageSource.gallery),
      ]),
    );
  }

  Widget _errorText() => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(_error ?? '', style: const TextStyle(color: _err, fontSize: 14)),
      );

  Widget _tip(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          const Icon(Icons.check, color: _ok, size: 16),
          const SizedBox(width: 8),
          Text(t, style: const TextStyle(color: _muted, fontSize: 14)),
        ]),
      );

  Widget _done() {
    Widget row(IconData icon, Color c, String title, String sub) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: c, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title,
                    style: const TextStyle(
                        color: _text, fontSize: 16, fontWeight: FontWeight.w600)),
                Text(sub, style: const TextStyle(color: _muted, fontSize: 14)),
              ]),
            ),
          ]),
        );
    return _page(
      title: 'Verification submitted',
      lead:
          'We’re checking your details. You can browse cards now, and we’ll notify you when you can buy and sell.',
      children: [
        row(Icons.check_circle, _ok, 'Documents received',
            _face ? 'Selfie only' : 'ID and selfie'),
        row(Icons.timelapse, _accent, 'Review in progress',
            'We’ll message you with the result'),
        row(Icons.lock_outline, _muted,
            _face ? 'Limited buying unlocked' : 'Buy and sell unlocked',
            _face ? 'Add an ID anytime to sell and withdraw' : 'Starts once you’re verified'),
      ],
      cta: 'Browse gift cards',
      onCta: _openHome,
    );
  }
}