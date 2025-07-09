import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rastreamento_app_admin/widgets/custom_fab_button.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onFabPressed;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onFabPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ClipPath(
            clipper: _BottomNavClipper(),
            child: Material(
              color: const Color(0xFFF0F0F0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    context,
                    icon: FontAwesomeIcons.mapLocationDot,
                    label: 'Mapa',
                    index: 0,
                    isSelected: selectedIndex == 0,
                    onTap: onItemSelected,
                  ),
                  _buildNavItem(
                    context,
                    icon: FontAwesomeIcons.motorcycle,
                    label: 'Entregas',
                    index: 1,
                    isSelected: selectedIndex == 1,
                    onTap: onItemSelected,
                  ),
                  const SizedBox(width: 90),
                  _buildNavItem(
                    context,
                    icon: FontAwesomeIcons.store,
                    label: 'Lojas',
                    index: 2,
                    isSelected: selectedIndex == 2,
                    onTap: onItemSelected,
                  ),
                  _buildNavItem(
                    context,
                    icon: FontAwesomeIcons.userGroup,
                    label: 'Entregador',
                    index: 3,
                    isSelected: selectedIndex == 3,
                    onTap: onItemSelected,
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          child: Transform.translate(
            offset: const Offset(5.0, 0.0),
            child: CustomFabButton(onPressed: onFabPressed),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required ValueChanged<int> onTap,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 72,
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFc107) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, color: Colors.black, size: 26),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.40, 0);

    path.quadraticBezierTo(size.width * 0.45, 0, size.width * 0.45, 20);
    path.arcToPoint(
      Offset(size.width * 0.55, 20),
      radius: const Radius.circular(20),
      clockwise: false,
    );
    path.quadraticBezierTo(size.width * 0.55, 0, size.width * 0.60, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
