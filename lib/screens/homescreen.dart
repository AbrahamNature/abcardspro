import 'package:flutter/material.dart';
import '../theme/palette.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _tabs = <Widget>[
    _HomeTab(),
    _TabPlaceholder('Cards'),
    _TabPlaceholder('Wallet'),
    _TabPlaceholder('Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _tabs[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Palette.surface,
        indicatorColor: Palette.marigold,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: Palette.night),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style_rounded, color: Palette.night),
            label: 'Cards',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon:
                Icon(Icons.account_balance_wallet_rounded, color: Palette.night),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: Palette.night),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder(this.name);
  final String name;

  @override
  Widget build(BuildContext context) =>
      Center(child: Text('$name screen goes here'));
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back',
                      style: text.bodyMedium?.copyWith(color: Palette.muted)),
                  const SizedBox(height: 2),
                  Text('ABCardsPro',
                      style: text.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Palette.marigold,
                      )),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                // TODO: open notifications
              },
              icon: const Icon(Icons.notifications_none_rounded),
              tooltip: 'Notifications',
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _WalletCard(),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _QuickAction(icon: Icons.shopping_bag_outlined, label: 'Buy', color: Palette.teal),
            _QuickAction(icon: Icons.sell_outlined, label: 'Sell', color: Palette.marigold),
            _QuickAction(icon: Icons.swap_horiz_rounded, label: 'Trade', color: Palette.rose),
            _QuickAction(icon: Icons.currency_bitcoin_rounded, label: 'Crypto', color: Palette.paper),
          ],
        ),
        const SizedBox(height: 28),
        Text('Recent activity',
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        // Sample data. Replace with real orders from your backend.
        const _ActivityTile(
          title: 'Sell order',
          subtitle: 'Shopping card, under review',
          amount: '+\$100.00',
          color: Palette.marigold,
        ),
        const _ActivityTile(
          title: 'Bought card',
          subtitle: 'Gaming card, delivered',
          amount: '-\$25.00',
          color: Palette.teal,
        ),
        const _ActivityTile(
          title: 'Wallet top-up',
          subtitle: 'Bank transfer, completed',
          amount: '+\$200.00',
          color: Palette.rose,
        ),
      ],
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Palette.marigold,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Wallet balance',
              style: TextStyle(
                color: Palette.night,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              )),
          const SizedBox(height: 6),
          const Text('\$1,250.00',
              style: TextStyle(
                color: Palette.night,
                fontWeight: FontWeight.w900,
                fontSize: 38,
              )),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Palette.night,
                    foregroundColor: Palette.paper,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // TODO: open add money
                  },
                  child: const Text('Add money'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Palette.night,
                    side: const BorderSide(color: Palette.night),
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // TODO: open withdraw
                  },
                  child: const Text('Withdraw'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // TODO: open $label flow
      },
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Palette.night, size: 28),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.line),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    )),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                      color: Palette.muted,
                      fontSize: 13,
                    )),
              ],
            ),
          ),
          Text(amount,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
              )),
        ],
      ),
    );
  }
}