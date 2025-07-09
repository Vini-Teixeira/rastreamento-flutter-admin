import 'package:flutter/material.dart';

class CustomLoginButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const CustomLoginButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.4),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(4, 18),
            ),
          ],
        ),
        child:
            isLoading
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.secondary,
                    strokeWidth: 3,
                  ),
                )
                : Text(
                  text,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
      ),
    );
  }
}
