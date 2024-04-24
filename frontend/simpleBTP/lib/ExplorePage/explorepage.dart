import 'package:flutter/material.dart';
import 'package:simpleBTP/ExplorePage/explorepagesearchandfiltercomponent.dart';
import 'package:simpleBTP/components/AppTopBar/apptopbar.dart';
import 'package:simpleBTP/components/Footer/footer.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  void searchWithFilters(search, filters) {
    print('searching with filters: $search, $filters');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        'Esplora',
      ),
      // add a body and a footer
      body: Column(
        children: [
          ExplorePageSearchAndFilterComponent(searchWithFilters),
        ],
      ),
      bottomNavigationBar: Footer('explore'),
    );
  }
}
