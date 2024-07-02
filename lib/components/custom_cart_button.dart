import 'package:flutter/material.dart';

class CustomCartButton extends StatelessWidget {
  const CustomCartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          Navigator.of(context).pushNamed('cart-page');
        },
        icon: Icon(
          Icons.shopping_cart,
          color: Theme.of(context).colorScheme.secondary,
        ));
  }
}
