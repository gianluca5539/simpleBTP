import 'package:flutter/material.dart';
import 'package:simpleBTP/components/AppTopBar/apptopbar.dart';
import 'package:simpleBTP/components/Footer/footer.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar('Esplora'),
      // add a body and a footer
      body: const Center(child: Icon(Icons.explore)),
      bottomNavigationBar: Footer('explore'),
    );
  }
}
