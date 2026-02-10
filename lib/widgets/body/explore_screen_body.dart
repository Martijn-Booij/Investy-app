import 'package:flutter/material.dart';

class ExploreScreenBody extends StatelessWidget {
  const ExploreScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Explore',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }
}
