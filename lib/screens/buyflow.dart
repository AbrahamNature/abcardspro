import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/palette.dart';

// ---------------------------------------------------------------------------
// BUY FLOW: CardsScreen -> CardDetailScreen -> CheckoutScreen -> PinScreen
//           -> ResultScreen (success / pending / failed)
// Sample data below is for testing. Replace with real data from your backend.
// ---------------------------------------------------------------------------

String _money(double v) => '\$${v.toStringAsFixed(2)}';

class GiftCardBrand {
  final String name;
  final String category;
  final Color color;
  final double discount; // percent off when a customer buys
  const GiftCardBrand(this.name, this.category, this.color, this.discount);
}

// SAMPLE DATA: replace with your real catalogue.
const _brands = <GiftCardBrand>[
  GiftCardBrand('Amazon', 'Shopping', Palette.marigold, 2),
  GiftCardBrand('Walmart', 'Shopping', Palette.teal, 1.5),
  GiftCardBrand('Apple', 'Shopping', Palette.paper, 1),
  GiftCardBrand('Google Play', 'Gaming', Palette.teal, 2),
  GiftCardBrand('Steam', 'Gaming', Palette.rose, 2.5),
  GiftCardBrand('Xbox', 'Gaming', Palette.marigold, 2),
  GiftCardBrand('Netflix', 'Streaming', Palette.rose, 1.5),
  GiftCardBrand('Spotify', 'Streaming', Palette.teal, 1),
  GiftCardBrand('Name', 'Category', Palette.teal, 2),
];

class Order {
  final GiftCardBrand brand;
  final double amount; 
  final int qty;
  final double total; 
  const Order(this.brand, this.amount, this.qty, this.total);
  double get face => amount * qty;
}
class _Page extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? bottom;
  const _Page({required this.title, required this.child, this.bottom});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.night,
      appBar: AppBar(
        backgroundColor: Palette.night,
        foregroundColor: Palette.paper,
        elevation: 0,
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480), child: child),
        ),
      ),
      bottomNavigationBar: bottom == null
          ? null
          : SafeArea(
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: bottom,
                  ),
                ),
              ),
            ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  const _PrimaryButton(this.label, this.onPressed, {this.outlined = false});

  @override
  Widget build(BuildContext context) {
    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
    const text = TextStyle(fontSize: 17, fontWeight: FontWeight.w600);
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: outlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: Palette.paper,
                side: const BorderSide(color: Palette.line, width: 1.5),
                shape: shape,
                textStyle: text,
              ),
              child: Text(label),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.marigold,
                foregroundColor: Palette.night,
                disabledBackgroundColor: Palette.line,
                disabledForegroundColor: Palette.muted,
                shape: shape,
                textStyle: text,
              ),
              child: Text(label),
            ),
    );
  }
}

class _BrandTile extends StatelessWidget {
  final GiftCardBrand brand;
  final double size = 52;
  const _BrandTile(this.brand);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: brand.color,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Text(
        brand.name.substring(0, 1),
        style: TextStyle(
          color: Palette.night,
          fontSize: size * 0.45,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _Row(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: bold ? Palette.paper : Palette.muted,
      fontSize: bold ? 17 : 15,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
}
class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  static const _categories = ['All', 'Shopping', 'Gaming', 'Streaming'];
  String _category = 'All';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final list = _brands.where((b) {
      final okCat = _category == 'All' || b.category == _category;
      final okQuery =
          b.name.toLowerCase().contains(_query.trim().toLowerCase());
      return okCat && okQuery;
    }).toList();

    return _Page(
      title: 'Buy a gift card',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          TextField(
            onChanged: (v) => setState(() => _query = v),
            style: const TextStyle(color: Palette.paper),
            cursorColor: Palette.marigold,
            decoration: InputDecoration(
              hintText: 'Search gift cards',
              hintStyle: const TextStyle(color: Palette.muted),
              prefixIcon: const Icon(Icons.search, color: Palette.muted),
              filled: true,
              fillColor: Palette.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Palette.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Palette.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Palette.marigold, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: [
              for (final c in _categories)
                ChoiceChip(
                  label: Text(c),
                  selected: _category == c,
                  onSelected: (_) => setState(() => _category = c),
                  backgroundColor: Palette.surface,
                  selectedColor: Palette.marigold,
                  side: const BorderSide(color: Palette.line),
                  labelStyle: TextStyle(
                    color: _category == c ? Palette.night : Palette.paper,
                    fontWeight: FontWeight.w600,
                  ),
                  showCheckmark: false,
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Text(
                'No gift cards match “$_query”. Try another name or category.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Palette.muted, fontSize: 15),
              ),
            ),
          for (final b in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => CardDetailScreen(b))),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Palette.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Palette.line),
                  ),
                  child: Row(children: [
                    _BrandTile(b),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.name,
                              style: const TextStyle(
                                  color: Palette.paper,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          Text('${b.category} · ${b.discount}% off',
                              style: const TextStyle(
                                  color: Palette.muted, fontSize: 14)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Palette.muted),
                  ]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
class CardDetailScreen extends StatefulWidget {
  final GiftCardBrand brand;
  const CardDetailScreen(this.brand, {super.key});

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  static const _values = [10.0, 25.0, 50.0, 100.0, 200.0];
  double _amount = 25;
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final b = widget.brand;
    final face = _amount * _qty;
    final saving = face * b.discount / 100;
    final total = face - saving;

    return _Page(
      title: b.name,
      bottom: _PrimaryButton(
        'Continue to checkout',
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CheckoutScreen(Order(b, _amount, _qty, total)),
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            height: 150,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: b.color,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(b.name,
                    style: const TextStyle(
                        color: Palette.night,
                        fontSize: 26,
                        fontWeight: FontWeight.w800)),
                Text('${b.category} gift card · ${b.discount}% off',
                    style: const TextStyle(
                        color: Palette.night,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Choose a value',
              style: TextStyle(
                  color: Palette.paper,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final v in _values)
                ChoiceChip(
                  label: Text(_money(v)),
                  selected: _amount == v,
                  onSelected: (_) => setState(() => _amount = v),
                  backgroundColor: Palette.surface,
                  selectedColor: Palette.marigold,
                  side: const BorderSide(color: Palette.line),
                  showCheckmark: false,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  labelStyle: TextStyle(
                    color: _amount == v ? Palette.night : Palette.paper,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Quantity',
                  style: TextStyle(
                      color: Palette.paper,
                      fontSize: 17,
                      fontWeight: FontWeight.w700)),
              Row(children: [
                IconButton(
                  onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Palette.paper,
                  disabledColor: Palette.line,
                ),
                Text('$_qty',
                    style: const TextStyle(
                        color: Palette.paper,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                IconButton(
                  onPressed: _qty < 10 ? () => setState(() => _qty++) : null,
                  icon: const Icon(Icons.add_circle_outline),
                  color: Palette.paper,
                  disabledColor: Palette.line,
                ),
              ]),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Palette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Palette.line),
            ),
            child: Column(children: [
              _Row('Card value', _money(face)),
              _Row('You save (${b.discount}%)', '-${_money(saving)}'),
              const Divider(color: Palette.line, height: 20),
              _Row('You pay', _money(total), bold: true),
            ]),
          ),
          const SizedBox(height: 12),
          const Text(
            'You’ll get the card code in the app as soon as payment is confirmed.',
            style: TextStyle(color: Palette.muted, fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }
}
enum PayMethod { wallet, crypto }
const _demoRates = {'USDT': 1.0, 'BTC': 0.00001, 'ETH': 0.0003};
const _demoAddress = 'REPLACE-WITH-YOUR-DEPOSIT-ADDRESS';

class CheckoutScreen extends StatefulWidget {
  final Order order;
  final double walletBalance;
  const CheckoutScreen(this.order, {super.key, this.walletBalance = 1250});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  PayMethod _method = PayMethod.wallet;
  String _coin = 'USDT';

  bool get _enough => widget.walletBalance >= widget.order.total;

  Future<void> _pay() async {
    final o = widget.order;
    if (_method == PayMethod.wallet) {
      if (!_enough) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ResultScreen(ResultKind.failed, o,
                  message:
                      'Your wallet balance is ${_money(widget.walletBalance)} but this order is ${_money(o.total)}. Add money or pay with crypto.')),
        );
        return;
      }
      final ok = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const PinScreen()),
      );
      if (ok != true || !mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(ResultKind.success, o)),
      );
    } else {
      // Crypto: the customer sends coins, then we wait for network confirmation.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(ResultKind.pending, o)),
      );
    }
  }

  Widget _methodTile(PayMethod m, String title, String sub, IconData icon) {
    final selected = _method == m;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _method = m),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Palette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: selected ? Palette.marigold : Palette.line, width: 1.5),
          ),
          child: Row(children: [
            Icon(icon, color: selected ? Palette.marigold : Palette.muted),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Palette.paper,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  Text(sub,
                      style: const TextStyle(
                          color: Palette.muted, fontSize: 14)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? Palette.marigold : Palette.line,
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final cryptoAmount = o.total * (_demoRates[_coin] ?? 1);

    return _Page(
      title: 'Checkout',
      bottom: _PrimaryButton(
        _method == PayMethod.wallet
            ? 'Pay ${_money(o.total)}'
            : 'I’ve sent the payment',
        _pay,
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Palette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Palette.line),
            ),
            child: Row(children: [
              _BrandTile(o.brand),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${o.brand.name} gift card',
                        style: const TextStyle(
                            color: Palette.paper,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    Text('${o.qty} × ${_money(o.amount)}',
                        style: const TextStyle(
                            color: Palette.muted, fontSize: 14)),
                  ],
                ),
              ),
              Text(_money(o.total),
                  style: const TextStyle(
                      color: Palette.paper,
                      fontSize: 17,
                      fontWeight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(height: 24),
          const Text('Pay with',
              style: TextStyle(
                  color: Palette.paper,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _methodTile(PayMethod.wallet, 'Wallet balance',
              'Available: ${_money(widget.walletBalance)}',
              Icons.account_balance_wallet_outlined),
          _methodTile(PayMethod.crypto, 'Crypto',
              'USDT, BTC or ETH', Icons.currency_bitcoin),
          if (_method == PayMethod.wallet && !_enough)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Your balance is too low for this order. Add money or pay with crypto.',
                style: TextStyle(color: Palette.rose, fontSize: 14),
              ),
            ),
          if (_method == PayMethod.crypto) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                for (final c in _demoRates.keys)
                  ChoiceChip(
                    label: Text(c),
                    selected: _coin == c,
                    onSelected: (_) => setState(() => _coin = c),
                    backgroundColor: Palette.surface,
                    selectedColor: Palette.marigold,
                    side: const BorderSide(color: Palette.line),
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color: _coin == c ? Palette.night : Palette.paper,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Palette.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Palette.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Send exactly',
                      style: TextStyle(color: Palette.muted, fontSize: 14)),
                  Text('${cryptoAmount.toStringAsFixed(6)} $_coin',
                      style: const TextStyle(
                          color: Palette.paper,
                          fontSize: 22,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  const Text('To this address',
                      style: TextStyle(color: Palette.muted, fontSize: 14)),
                  Row(children: [
                    const Expanded(
                      child: Text(_demoAddress,
                          style: TextStyle(
                              color: Palette.paper, fontSize: 14)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Palette.marigold),
                      tooltip: 'Copy address',
                      onPressed: () {
                        Clipboard.setData(
                            const ClipboardData(text: _demoAddress));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Address copied')),
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: 8),
                  const Text(
                    'Only send the coin you picked, on the network shown. Coins sent to the wrong network can’t be recovered. Rates shown are for testing.',
                    style: TextStyle(
                        color: Palette.muted, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _pin = '';

  void _tap(String d) {
    if (_pin.length >= 4) return;
    setState(() => _pin += d);
    if (_pin.length == 4) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) Navigator.pop(context, true);
      });
    }
  }

  void _delete() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    Widget key(String label, {VoidCallback? onTap, IconData? icon}) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: SizedBox(
            height: 64,
            child: onTap == null
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: onTap,
                    style: TextButton.styleFrom(
                      backgroundColor: Palette.surface,
                      foregroundColor: Palette.paper,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: icon != null
                        ? Icon(icon)
                        : Text(label,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w600)),
                  ),
          ),
        ),
      );
    }

    Widget line(List<Widget> keys) => Row(children: keys);

    return _Page(
      title: 'Confirm payment',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          children: [
            const Text('Enter your 4-digit PIN',
                style: TextStyle(
                    color: Palette.paper,
                    fontSize: 22,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('This confirms the payment from your wallet.',
                style: TextStyle(color: Palette.muted, fontSize: 15)),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 4; i++)
                  Container(
                    width: 18,
                    height: 18,
                    margin: const EdgeInsets.symmetric(horizontal: 9),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _pin.length ? Palette.marigold : Colors.transparent,
                      border: Border.all(
                          color: i < _pin.length ? Palette.marigold : Palette.line,
                          width: 2),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            line([for (final d in ['1', '2', '3']) key(d, onTap: () => _tap(d))]),
            line([for (final d in ['4', '5', '6']) key(d, onTap: () => _tap(d))]),
            line([for (final d in ['7', '8', '9']) key(d, onTap: () => _tap(d))]),
            line([
              key(''),
              key('0', onTap: () => _tap('0')),
              key('', onTap: _delete, icon: Icons.backspace_outlined),
            ]),
          ],
        ),
      ),
    );
  }
}

enum ResultKind { success, pending, failed }

class ResultScreen extends StatelessWidget {
  final ResultKind kind;
  final Order order;
  final String? message;
  const ResultScreen(this.kind, this.order, {super.key, this.message});

  @override
  Widget build(BuildContext context) {
    late final IconData icon;
    late final Color color;
    late final String title;
    late final String body;

    switch (kind) {
      case ResultKind.success:
        icon = Icons.check_circle;
        color = Palette.teal;
        title = 'Payment successful';
        body = 'Your ${order.brand.name} gift card is ready. Keep the code private.';
        break;
      case ResultKind.pending:
        icon = Icons.timelapse;
        color = Palette.marigold;
        title = 'Waiting for your payment';
        body =
            'We’ll confirm once the network receives your crypto. Your card code appears here as soon as that’s done.';
        break;
      case ResultKind.failed:
        icon = Icons.error_outline;
        color = Palette.rose;
        title = 'Payment failed';
        body = message ?? 'Something went wrong. Nothing was charged. Try again.';
        break;
    }

    return Scaffold(
      backgroundColor: Palette.night,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Icon(icon, color: color, size: 72),
                  const SizedBox(height: 20),
                  Text(title,
                      style: const TextStyle(
                          color: Palette.paper,
                          fontSize: 28,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(body,
                      style: const TextStyle(
                          color: Palette.muted, fontSize: 16, height: 1.5)),
                  if (kind == ResultKind.success) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Palette.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Palette.teal),
                      ),
                      child: Row(children: [
                        const Expanded(
                          // SAMPLE: show the real code from your backend.
                          child: Text('XXXX-XXXX-XXXX-XXXX',
                              style: TextStyle(
                                  color: Palette.paper,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Palette.teal),
                          tooltip: 'Copy code',
                          onPressed: () {
                            Clipboard.setData(const ClipboardData(
                                text: 'XXXX-XXXX-XXXX-XXXX'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Code copied')),
                            );
                          },
                        ),
                      ]),
                    ),
                  ],
                  const Spacer(),
                  if (kind == ResultKind.failed) ...[
                    _PrimaryButton('Try again', () => Navigator.pop(context)),
                    const SizedBox(height: 10),
                  ],
                  _PrimaryButton(
                    'Back to home',
                    () => Navigator.popUntil(context, (r) => r.isFirst),
                    outlined: kind == ResultKind.failed,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}