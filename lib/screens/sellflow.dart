import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/palette.dart';
class _Brand {
  final String name;
  final double rate; // share of the card value paid out
  final IconData icon;
  const _Brand(this.name, this.rate, this.icon);
}

const List<_Brand> _brands = [
  _Brand('Amazon', 0.82, Icons.shopping_cart_outlined),
  _Brand('iTunes / Apple', 0.78, Icons.apple),
  _Brand('Google Play', 0.76, Icons.play_arrow_rounded),
  _Brand('Steam', 0.74, Icons.sports_esports_outlined),
  _Brand('Xbox', 0.72, Icons.gamepad_outlined),
  _Brand('PlayStation', 0.72, Icons.videogame_asset_outlined),
  _Brand('Walmart', 0.70, Icons.storefront_outlined),
  _Brand('Visa Gift Card', 0.68, Icons.credit_card_outlined),
  _Brand('Sephora', 0.66, Icons.brush_outlined),
  _Brand('Nike', 0.64, Icons.directions_run_rounded),
  _Brand('Netflix', 0.62, Icons.movie_outlined),
  _Brand('Spotify', 0.60, Icons.music_note_outlined),
];

class SellOrder {
  final String id;
  final String brand;
  final double amount;
  final double payout;
  final String payoutTo;
  final String status; 
  final String? reason; 
  final DateTime time;
  const SellOrder({
    required this.id,
    required this.brand,
    required this.amount,
    required this.payout,
    required this.payoutTo,
    required this.status,
    this.reason,
    required this.time,
  });
}

final ValueNotifier<List<SellOrder>> sellOrders =
    ValueNotifier<List<SellOrder>>([]);

String _money(double v) => '\$${v.toStringAsFixed(2)}';
String _date(DateTime t) => '${t.day}/${t.month}/${t.year}';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  int _step = 0;
  _Brand? _brand;
  bool _physical = false;
  String _payoutTo = 'Wallet';
  bool _agreed = false;
  final _amount = TextEditingController();
  final _code = TextEditingController();
  final _pin = TextEditingController();
  XFile? _photo;
  String? _error;

  double get _value => double.tryParse(_amount.text.trim()) ?? 0;
  double get _payout => _value * (_brand?.rate ?? 0);

  @override
  void dispose() {
    _amount.dispose();
    _code.dispose();
    _pin.dispose();
    super.dispose();
  }

  void _fail(String message) => setState(() => _error = message);

  void _back() {
    if (_step == 0) {
      Navigator.pop(context);
    } else {
      setState(() {
        _error = null;
        _step -= 1;
      });
    }
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _photo = picked;
        _error = null;
      });
    }
  }

  void _continueDetails() {
    if (_value <= 0) {
      _fail('Enter the amount on the card.');
      return;
    }
    if (!_physical && _code.text.trim().length < 6) {
      _fail('Enter the full card code.');
      return;
    }
    if (_photo == null) {
      _fail('Upload a clear photo of the card.');
      return;
    }
    setState(() {
      _error = null;
      _step = 2;
    });
  }

  void _submit() {
    if (!_agreed) {
      _fail('Accept the selling terms to continue.');
      return;
    }
    if (_pin.text.length != 4) {
      _fail('Enter your 4-digit PIN.');
      return;
    }
    final order = SellOrder(
      id: 'SL${DateTime.now().millisecondsSinceEpoch % 1000000}',
      brand: _brand!.name,
      amount: _value,
      payout: _payout,
      payoutTo: _payoutTo,
      status: 'Under review',
      time: DateTime.now(),
    );
    sellOrders.value = [order, ...sellOrders.value];
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SellOrderStatusScreen(order: order)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const titles = ['Sell a gift card', 'Card details', 'Review and confirm'];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _back,
        ),
        title: Text(titles[_step]),
        actions: [
          IconButton(
            tooltip: 'My sell orders',
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SellOrdersScreen())),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            LinearProgressIndicator(
              value: (_step + 1) / 3,
              color: Palette.marigold,
              minHeight: 4,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 20),
            if (_step == 0) _pickBrand(context),
            if (_step == 1) _details(context),
            if (_step == 2) _review(context),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(_error!, style: TextStyle(color: Palette.rose)),
            ],
          ],
        ),
      ),
    );
  }

  // Step 1: choose the brand ------------------------------------------------
  Widget _pickBrand(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Which card are you selling?',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text('The percentage is what you receive of the card value.',
            style: TextStyle(color: cs.onSurface.withOpacity(0.6))),
        const SizedBox(height: 16),
        for (final b in _brands)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() {
                _brand = b;
                _step = 1;
              }),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.onSurface.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Palette.marigold.withOpacity(0.2),
                      child: Icon(b.icon, color: Palette.marigold),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(b.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                    ),
                    Text('${(b.rate * 100).round()}%',
                        style: TextStyle(
                            color: Palette.teal,
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Step 2: card details ----------------------------------------------------
  Widget _details(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${_brand!.name} card',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('E-code')),
            ButtonSegment(value: true, label: Text('Physical card')),
          ],
          selected: {_physical},
          onSelectionChanged: (s) => setState(() => _physical = s.first),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: 'Card amount (USD)',
            prefixText: '\$ ',
            border: OutlineInputBorder(),
          ),
        ),
        if (!_physical) ...[
          const SizedBox(height: 14),
          TextField(
            controller: _code,
            decoration: const InputDecoration(
              labelText: 'Card code',
              border: OutlineInputBorder(),
            ),
          ),
        ],
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: _pickPhoto,
          icon: const Icon(Icons.add_a_photo_outlined),
          label: Text(_photo == null
              ? (_physical
                  ? 'Upload photo of card front and back'
                  : 'Upload receipt or card screenshot')
              : 'Photo added: ${_photo!.name}'),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Palette.teal.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('You will receive',
                  style: TextStyle(color: cs.onSurface.withOpacity(0.7))),
              Text(_money(_payout),
                  style: TextStyle(
                      color: Palette.teal,
                      fontWeight: FontWeight.w800,
                      fontSize: 22)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _continueDetails,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Continue'),
            ),
          ),
        ),
      ],
    );
  }

  // Step 3: review, payout choice, terms, PIN -------------------------------
  Widget _review(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget row(String k, String v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(k, style: TextStyle(color: cs.onSurface.withOpacity(0.6))),
              Flexible(
                child: Text(v,
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row('Card', _brand!.name),
        row('Type', _physical ? 'Physical card' : 'E-code'),
        row('Card value', _money(_value)),
        row('Rate', '${(_brand!.rate * 100).round()}%'),
        row('Photo', _photo?.name ?? ''),
        const Divider(height: 28),
        row('You receive', _money(_payout)),
        const SizedBox(height: 14),
        Text('Pay me in', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final p in ['Wallet', 'Crypto (USDT)'])
              ChoiceChip(
                label: Text(p),
                selected: _payoutTo == p,
                onSelected: (_) => setState(() => _payoutTo = p),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Your card is reviewed by an admin before payment. Once approved, the money goes to the option you chose.',
          style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _agreed,
          onChanged: (v) => setState(() => _agreed = v ?? false),
          title: const Text(
              'I confirm this card is mine, has not been used, and I accept the selling terms.'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _pin,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: const InputDecoration(
            labelText: 'Enter your 4-digit PIN',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _submit,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Submit for review'),
            ),
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// Sell order status (under review, approved or rejected)
// ===========================================================================
class SellOrderStatusScreen extends StatelessWidget {
  final SellOrder order;
  const SellOrderStatusScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final rejected = order.status == 'Rejected';
    final approved = order.status == 'Approved';
    final current = approved ? 4 : 1; // 4 means every step is done

    final List<List<String>> stages = rejected
        ? [
            ['Order submitted', 'We received your card.'],
            [
              'Rejected',
              order.reason ?? 'We could not verify this card. Contact support for details.'
            ],
          ]
        : [
            ['Order submitted', 'We received your card.'],
            ['Under review', 'An admin is checking your card.'],
            ['Approved', 'Your card is verified.'],
            ['Paid', 'The payout was sent to your ${order.payoutTo}.'],
          ];

    return Scaffold(
      appBar: AppBar(title: const Text('Order status')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: (rejected ? Palette.rose : Palette.marigold)
                    .withOpacity(0.16),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${order.brand} card, ${_money(order.amount)}',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text('Payout: ${_money(order.payout)} to ${order.payoutTo}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 20)),
                  const SizedBox(height: 6),
                  Text('Order ${order.id}, ${_date(order.time)}',
                      style: TextStyle(color: cs.onSurface.withOpacity(0.6))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            for (var i = 0; i < stages.length; i++)
              _stage(
                context,
                stages[i][0],
                stages[i][1],
                done: i < current && !(rejected && i == 1),
                active: i == current && !rejected,
                bad: rejected && i == 1,
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Back to home'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stage(BuildContext context, String title, String sub,
      {required bool done, required bool active, required bool bad}) {
    final cs = Theme.of(context).colorScheme;
    final color = bad
        ? Palette.rose
        : (done || active ? Palette.teal : cs.onSurface.withOpacity(0.3));
    final icon = bad
        ? Icons.cancel_rounded
        : (done
            ? Icons.check_circle_rounded
            : (active
                ? Icons.timelapse_rounded
                : Icons.radio_button_unchecked));
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: done || active || bad
                            ? null
                            : cs.onSurface.withOpacity(0.5))),
                Text(sub,
                    style: TextStyle(color: cs.onSurface.withOpacity(0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// My sell orders (with empty state)
// ===========================================================================
class SellOrdersScreen extends StatelessWidget {
  const SellOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('My sell orders')),
      body: SafeArea(
        child: ValueListenableBuilder<List<SellOrder>>(
          valueListenable: sellOrders,
          builder: (_, list, __) {
            if (list.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Text(
                    'No sell orders yet. Tap Sell on the home screen to turn a gift card into cash.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
                  ),
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                for (final o in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  SellOrderStatusScreen(order: o))),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cs.onSurface.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${o.brand}, ${_money(o.amount)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16)),
                                  Text('${o.status}, ${_date(o.time)}',
                                      style: TextStyle(
                                          color:
                                              cs.onSurface.withOpacity(0.6))),
                                ],
                              ),
                            ),
                            Text(_money(o.payout),
                                style: TextStyle(
                                    color: o.status == 'Rejected'
                                        ? Palette.rose
                                        : Palette.teal,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}