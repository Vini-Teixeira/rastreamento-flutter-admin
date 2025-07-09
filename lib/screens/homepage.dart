import 'package:flutter/material.dart';
import 'package:rastreamento_app_admin/screens/create_delivery_page.dart';
import 'package:rastreamento_app_admin/screens/drivers_page.dart';
import 'package:rastreamento_app_admin/services/auth_service.dart';
import 'package:rastreamento_app_admin/services/delivery_service.dart';
import 'package:rastreamento_app_admin/widgets/custom_bottom_nav_bar.dart';
import 'package:rastreamento_app_admin/screens/map_page.dart';
import 'package:rastreamento_app_admin/screens/deliveries_page.dart';
import 'package:rastreamento_app_admin/screens/lojas_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;
  final GlobalKey<DeliveriesPageState> _deliveriesPageKey =
      GlobalKey<DeliveriesPageState>();
  late final List<Widget> _pages;

  final AuthService _authService = AuthService();

  void _signOut() {
    _authService.signOut();
  }

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      const MapPage(),
      DeliveriesPage(key: _deliveriesPageKey),
      const LojasPage(),
      const DriversPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      _deliveriesPageKey.currentState?.fetchDeliveries();
    }
  }

  void _onFabPressed() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const CreateDeliveryPage()),
    );
    if (result == true) {
      if (_selectedIndex != 1) {
        setState(() {
          _selectedIndex = 1;
        });
      }
      Future.delayed(const Duration(milliseconds: 50), () {
        _deliveriesPageKey.currentState?.fetchDeliveries();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Administrador'),
        backgroundColor: Colors.grey[900],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      drawer: Drawer(
        backgroundColor: Colors.grey[850],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.grey[900]),
              child: const Text(
                'Menu do Administrador',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white70),
              title: const Text('Meu Perfil',
                  style: TextStyle(color: Colors.white70)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white70),
              title: const Text('Configurações',
                  style: TextStyle(color: Colors.white70)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(color: Colors.white54),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.amber),
              title: const Text(
                'Sair',
                style:
                    TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
              ),
              onTap: _signOut,
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
        onFabPressed: _onFabPressed,
      ),
    );
  }
}
