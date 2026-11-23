import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/palette.dart';


class WalletTx {
  final String title;
  final double amount; 
  final DateTime time;
  const WalletTx(this.title, this.amount, this.time);
}

final ValueNotifier<double> walletBalance = ValueNotifier<double>(0);
final ValueNotifier<List<WalletTx>> walletTxs = ValueNotifier<List<WalletTx>>([]);

void addWalletTx(String title, double amount) {
  walletBalance.value += amount;
  walletTxs.value = [WalletTx(title, amount, DateTime.now()), ...walletTxs.value];
}

String _money(double v) => '\$${v.toStringAsFixed(2)}';
String _date(DateTime t) => '${t.day}/${t.month}/${t.year}';

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Future<bool> _askPin(BuildContext context) async {
  final c = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Confirm with PIN'),
      content: TextField(
        controller: c,
        autofocus: true,
        obscureText: true,
        maxLength: 4,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: '4-digit PIN'),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel')),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, c.text.length == 4),
            child: const Text('Confirm')),
      ],
    ),
  );
  return ok ?? false;
}

Widget _wideButton(String label, VoidCallback onPressed, {Color? color}) {
  return SizedBox(
    width: double.infinity,
    child: FilledButton(
      style: color == null ? null : FilledButton.styleFrom(backgroundColor: color),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(label),
      ),
    ),
  );
}

Widget _tile(BuildContext context,
    {required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? color}) {
  final cs = Theme.of(context).colorScheme;
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.onSurface.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: (color ?? Palette.teal).withOpacity(0.2),
              child: Icon(icon, color: color ?? Palette.teal),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16)),
                  if (subtitle != null)
                    Text(subtitle,
                        style: TextStyle(color: cs.onSurface.withOpacity(0.6))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    ),
  );
}

const List<String> _cardBrands = [
  'Amazon',
  'iTunes / Apple',
  'Google Play',
  'Steam',
  'Xbox',
  'PlayStation',
  'Walmart',
  'Visa Gift Card',
  'Sephora',
  'Nike',
  'Netflix',
  'Spotify',
];

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Palette.teal,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Wallet balance',
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 6),
                  ValueListenableBuilder<double>(
                    valueListenable: walletBalance,
                    builder: (_, v, __) => Text(_money(v),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black),
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AddMoneyScreen())),
                          child: const Text('Add money'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white70)),
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const WithdrawScreen())),
                          child: const Text('Withdraw'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Transactions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            ValueListenableBuilder<List<WalletTx>>(
              valueListenable: walletTxs,
              builder: (_, list, __) {
                if (list.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Text(
                      'No transactions yet. Add money or sell a card to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final t in list)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: (t.amount >= 0 ? Palette.teal : Palette.rose)
                              .withOpacity(0.2),
                          child: Icon(
                              t.amount >= 0
                                  ? Icons.south_west_rounded
                                  : Icons.north_east_rounded,
                              color: t.amount >= 0 ? Palette.teal : Palette.rose),
                        ),
                        title: Text(t.title),
                        subtitle: Text(_date(t.time)),
                        trailing: Text(
                          '${t.amount >= 0 ? '+' : '-'}${_money(t.amount.abs())}',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: t.amount >= 0 ? Palette.teal : Palette.rose),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final _amount = TextEditingController();
  String _method = 'Bank transfer';
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final v = double.tryParse(_amount.text.trim()) ?? 0;
    if (v <= 0) {
      setState(() => _error = 'Enter the amount you want to add.');
      return;
    }
    final ok = await _askPin(context);
    if (!ok || !mounted) return;

    addWalletTx('Added money ($_method)', v);
    Navigator.pop(context);
    _snack(context, '${_money(v)} added to your wallet.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add money')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Wrap(
              spacing: 8,
              children: [
                for (final m in ['Bank transfer', 'Card', 'Crypto deposit'])
                  ChoiceChip(
                    label: Text(m),
                    selected: _method == m,
                    onSelected: (_) => setState(() => _method = m),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _amount,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount (USD)',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Palette.rose)),
            ],
            const SizedBox(height: 20),
            _wideButton('Add money', _add),
          ],
        ),
      ),
    );
  }
}

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _bank = TextEditingController();
  final _number = TextEditingController();
  final _name = TextEditingController();
  final _amount = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _bank.dispose();
    _number.dispose();
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _withdraw() async {
    final v = double.tryParse(_amount.text.trim()) ?? 0;
    if (_bank.text.trim().isEmpty ||
        _number.text.trim().length < 6 ||
        _name.text.trim().isEmpty) {
      setState(() => _error = 'Fill in your bank name, account number and account name.');
      return;
    }
    if (v <= 0) {
      setState(() => _error = 'Enter the amount to withdraw.');
      return;
    }
    if (v > walletBalance.value) {
      setState(() => _error =
          'Your balance is ${_money(walletBalance.value)}. Enter a smaller amount.');
      return;
    }
    final ok = await _askPin(context);
    if (!ok || !mounted) return;
    addWalletTx('Withdrawal to ${_bank.text.trim()}', -v);
    Navigator.pop(context);
    _snack(context, 'Withdrawal of ${_money(v)} submitted.');
  }

  @override
  Widget build(BuildContext context) {
    Widget field(TextEditingController c, String label,
            {TextInputType? type}) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: TextField(
            controller: c,
            keyboardType: type,
            decoration: InputDecoration(
                labelText: label, border: const OutlineInputBorder()),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Withdraw')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ValueListenableBuilder<double>(
              valueListenable: walletBalance,
              builder: (_, v, __) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text('Available: ${_money(v)}',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
            ),
            field(_bank, 'Bank name'),
            field(_number, 'Account number', type: TextInputType.number),
            field(_name, 'Account name'),
            field(_amount, 'Amount (USD)',
                type: const TextInputType.numberWithOptions(decimal: true)),
            if (_error != null) ...[
              Text(_error!, style: TextStyle(color: Palette.rose)),
              const SizedBox(height: 14),
            ],
            _wideButton('Withdraw', _withdraw),
          ],
        ),
      ),
    );
  }
}

class TradeScreen extends StatefulWidget {
  const TradeScreen({super.key});

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> {
  static const double _rate = 0.92;
  String _from = _cardBrands[0];
  String _to = _cardBrands[1];
  final _amount = TextEditingController();
  final _code = TextEditingController();
  String? _error;

  double get _value => double.tryParse(_amount.text.trim()) ?? 0;

  @override
  void dispose() {
    _amount.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_from == _to) {
      setState(() => _error = 'Choose two different cards.');
      return;
    }
    if (_value <= 0 || _code.text.trim().length < 6) {
      setState(() => _error = 'Enter the card amount and the full card code.');
      return;
    }
    final ok = await _askPin(context);
    if (!ok || !mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Trade submitted'),
        content: Text(
            'Your $_from card is under review. After approval you will get a $_to card worth ${_money(_value * _rate)}.'),
        actions: [
          FilledButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Done'))
        ],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget picker(String label, String value, ValueChanged<String> onChanged) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
                labelText: label, border: const OutlineInputBorder()),
            items: [
              for (final b in _cardBrands)
                DropdownMenuItem(value: b, child: Text(b))
            ],
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Trade a card')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            picker('You give', _from, (v) => setState(() => _from = v)),
            picker('You get', _to, (v) => setState(() => _to = v)),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TextField(
                controller: _amount,
                onChanged: (_) => setState(() {}),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Card amount (USD)',
                    prefixText: '\$ ',
                    border: OutlineInputBorder()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TextField(
                controller: _code,
                decoration: const InputDecoration(
                    labelText: 'Card code', border: OutlineInputBorder()),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Palette.rose.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('You will get',
                      style: TextStyle(color: cs.onSurface.withOpacity(0.7))),
                  Text(_money(_value * _rate),
                      style: TextStyle(
                          color: Palette.rose,
                          fontWeight: FontWeight.w800,
                          fontSize: 22)),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Palette.rose)),
            ],
            const SizedBox(height: 18),
            _wideButton('Submit trade', _submit),
          ],
        ),
      ),
    );
  }
}

class _Coin {
  final String name;
  final String symbol;
  final double price; // placeholder USD price, replace with a live feed
  final String address; // placeholder deposit address
  const _Coin(this.name, this.symbol, this.price, this.address);
}

const List<_Coin> _coins = [
  _Coin('Bitcoin', 'BTC', 65000, 'REPLACE-WITH-YOUR-BTC-ADDRESS'),
  _Coin('Ethereum', 'ETH', 3200, 'REPLACE-WITH-YOUR-ETH-ADDRESS'),
  _Coin('Tether (TRC20)', 'USDT', 1, 'REPLACE-WITH-YOUR-USDT-ADDRESS'),
];

class CryptoScreen extends StatelessWidget {
  const CryptoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crypto'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Buy crypto'),
            Tab(text: 'Sell crypto'),
          ]),
        ),
        body: const SafeArea(
          child: TabBarView(children: [_BuyCrypto(), _SellCrypto()]),
        ),
      ),
    );
  }
}

class _BuyCrypto extends StatefulWidget {
  const _BuyCrypto();

  @override
  State<_BuyCrypto> createState() => _BuyCryptoState();
}

class _BuyCryptoState extends State<_BuyCrypto> {
  _Coin _coin = _coins[0];
  final _usd = TextEditingController();
  final _wallet = TextEditingController();
  String? _error;

  double get _value => double.tryParse(_usd.text.trim()) ?? 0;

  @override
  void dispose() {
    _usd.dispose();
    _wallet.dispose();
    super.dispose();
  }

  Future<void> _buy() async {
    if (_value <= 0 || _wallet.text.trim().length < 10) {
      setState(() => _error = 'Enter an amount and your ${_coin.symbol} wallet address.');
      return;
    }
    if (_value > walletBalance.value) {
      setState(() => _error =
          'Your balance is ${_money(walletBalance.value)}. Add money first.');
      return;
    }
    final ok = await _askPin(context);
    if (!ok || !mounted) return;
    addWalletTx('Bought ${_coin.symbol}', -_value);
    setState(() {
      _error = null;
      _usd.clear();
    });
    _snack(context, 'Order placed. Your ${_coin.symbol} will be sent after review.');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        DropdownButtonFormField<_Coin>(
          value: _coin,
          decoration: const InputDecoration(
              labelText: 'Coin', border: OutlineInputBorder()),
          items: [
            for (final c in _coins)
              DropdownMenuItem(value: c, child: Text('${c.name} (${c.symbol})'))
          ],
          onChanged: (c) => setState(() => _coin = c ?? _coin),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _usd,
          onChanged: (_) => setState(() {}),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
              labelText: 'Amount to spend (USD)',
              prefixText: '\$ ',
              border: OutlineInputBorder()),
        ),
        const SizedBox(height: 8),
        Text(
          'You get about ${(_value / _coin.price).toStringAsFixed(6)} ${_coin.symbol}',
          style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _wallet,
          decoration: InputDecoration(
              labelText: 'Your ${_coin.symbol} wallet address',
              border: const OutlineInputBorder()),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: Palette.rose)),
        ],
        const SizedBox(height: 18),
        _wideButton('Buy ${_coin.symbol}', _buy),
      ],
    );
  }
}

class _SellCrypto extends StatefulWidget {
  const _SellCrypto();

  @override
  State<_SellCrypto> createState() => _SellCryptoState();
}

class _SellCryptoState extends State<_SellCrypto> {
  _Coin _coin = _coins[0];
  final _hash = TextEditingController();
  final _usd = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _hash.dispose();
    _usd.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final v = double.tryParse(_usd.text.trim()) ?? 0;
    if (v <= 0 || _hash.text.trim().length < 10) {
      setState(() => _error = 'Enter the value you sent and the transaction hash.');
      return;
    }
    final ok = await _askPin(context);
    if (!ok || !mounted) return;
    setState(() {
      _error = null;
      _hash.clear();
      _usd.clear();
    });
    _snack(context, 'Submitted. An admin will confirm your deposit, then credit your wallet.');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        DropdownButtonFormField<_Coin>(
          value: _coin,
          decoration: const InputDecoration(
              labelText: 'Coin you are selling', border: OutlineInputBorder()),
          items: [
            for (final c in _coins)
              DropdownMenuItem(value: c, child: Text('${c.name} (${c.symbol})'))
          ],
          onChanged: (c) => setState(() => _coin = c ?? _coin),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.onSurface.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Send ${_coin.symbol} to this address',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SelectableText(_coin.address),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _coin.address));
                  _snack(context, 'Address copied.');
                },
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copy address'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _usd,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
              labelText: 'Value you sent (USD)',
              prefixText: '\$ ',
              border: OutlineInputBorder()),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _hash,
          decoration: const InputDecoration(
              labelText: 'Transaction hash', border: OutlineInputBorder()),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: Palette.rose)),
        ],
        const SizedBox(height: 18),
        _wideButton('Submit for review', _submit),
      ],
    );
  }
}


class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Replace with real notifications from your backend.
    const items = <(IconData, String, String)>[
      (Icons.verified_user_outlined, 'Verify your identity',
          'Finish ID or face verification to unlock selling and withdrawals.'),
      (Icons.local_offer_outlined, 'New cards added',
          'Browse 24 gift card brands in the Buy section.'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: SafeArea(
        child: items.isEmpty
            ? Center(
                child: Text('You are all caught up.',
                    style: TextStyle(color: cs.onSurface.withOpacity(0.6))))
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  for (final n in items)
                    _tile(context,
                        icon: n.$1,
                        title: n.$2,
                        subtitle: n.$3,
                        onTap: () {}),
                ],
              ),
      ),
    );
  }
}

// ===========================================================================
// Support (customer side: send a complaint, track tickets)
// ===========================================================================
class SupportTicket {
  final String id;
  final String category;
  final String message;
  final String status; // Open, In progress, Resolved
  const SupportTicket(this.id, this.category, this.message, this.status);
}

final ValueNotifier<List<SupportTicket>> supportTickets =
    ValueNotifier<List<SupportTicket>>([]);

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const NewTicketScreen())),
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('New complaint'),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<List<SupportTicket>>(
          valueListenable: supportTickets,
          builder: (_, list, __) {
            if (list.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Text(
                    'No complaints yet. Tell us what went wrong and we will reply here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
                  ),
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                for (final t in list)
                  _tile(context,
                      icon: Icons.support_agent_rounded,
                      title: '${t.category} (${t.id})',
                      subtitle: '${t.status}: ${t.message}',
                      color: Palette.marigold,
                      onTap: () {}),
              ],
            );
          },
        ),
      ),
    );
  }
}

class NewTicketScreen extends StatefulWidget {
  const NewTicketScreen({super.key});

  @override
  State<NewTicketScreen> createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends State<NewTicketScreen> {
  String _category = 'Payment issue';
  final _message = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  void _send() {
    if (_message.text.trim().length < 10) {
      setState(() => _error = 'Describe the problem in a few words.');
      return;
    }
    final id = 'T${DateTime.now().millisecondsSinceEpoch % 100000}';
    supportTickets.value = [
      SupportTicket(id, _category, _message.text.trim(), 'Open'),
      ...supportTickets.value,
    ];
    Navigator.pop(context);
    _snack(context, 'Complaint sent. Ticket $id is open.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New complaint')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Wrap(
              spacing: 8,
              children: [
                for (final c in [
                  'Payment issue',
                  'Sell order',
                  'Buy order',
                  'Account',
                  'Other'
                ])
                  ChoiceChip(
                    label: Text(c),
                    selected: _category == c,
                    onSelected: (_) => setState(() => _category = c),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _message,
              maxLines: 6,
              decoration: const InputDecoration(
                  labelText: 'What happened?', border: OutlineInputBorder()),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Palette.rose)),
            ],
            const SizedBox(height: 18),
            _wideButton('Send complaint', _send),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Profile
// ===========================================================================
class ProfileScreen extends StatelessWidget {
  final String name;
  const ProfileScreen({super.key, this.name = 'My account'});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Palette.teal,
                  child: Text(name.isEmpty ? '?' : name[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(name,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _tile(context,
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationsScreen()))),
            _tile(context,
                icon: Icons.account_balance_wallet_outlined,
                title: 'Wallet',
                subtitle: 'Balance, add money, withdraw',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const WalletScreen()))),
            _tile(context,
                icon: Icons.support_agent_rounded,
                title: 'Support and complaints',
                color: Palette.marigold,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SupportScreen()))),
            _tile(context,
                icon: Icons.lock_outline_rounded,
                title: 'Change PIN',
                onTap: () => _snack(context, 'Change PIN is coming with the backend.')),
            const SizedBox(height: 10),
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Palette.rose),
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log out'),
            ),
            const SizedBox(height: 6),
            Text('ABCardsPro',
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurface.withOpacity(0.4))),
          ],
        ),
      ),
    );
  }
}