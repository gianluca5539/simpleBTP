import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/ExplorePage/explorepageinvestmentcomponent.dart';
import 'package:simpleBTP/ExplorePage/explorepagesearchandfiltercomponent.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/assets/defaults.dart';
import 'package:simpleBTP/assets/languages.dart';
import 'package:simpleBTP/btp_scraper.dart';
import 'package:simpleBTP/components/AppTopBar/apptopbar.dart';
import 'package:simpleBTP/components/Footer/footer.dart';
import 'package:simpleBTP/db/db.dart';
import 'package:simpleBTP/db/hivemodels.dart';

class ExplorePage extends StatefulWidget {
  ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String search = '';

  Map<String, dynamic> filters = defaultExploreFilters;

  Map<String, dynamic> ordering = defaultExploreOrdering;

  void searchWithFilters(String search, Map<String, dynamic> filters,
      Map<String, dynamic> ordering) {
    // update the state with the new search and filters
    setState(() {
      this.search = search;
      this.filters = filters;
      this.ordering = ordering;
    });
  }

  void _openBTPDetailPage(BuildContext context, isDarkMode, BTP btp) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            void searchWithFilters(String search, Map<String, dynamic> filters,
                Map<String, dynamic> ordering) {
              // update the state with the new search and filters
              setModalState(() {
                this.search = search;
                this.filters = filters;
                this.ordering = ordering;
              });
            }

            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.92,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 80,
                            height: 5,
                            decoration: BoxDecoration(
                              color:
                                  isDarkMode ? darkModeColor : Colors.grey[400],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          btp.name.toUpperCase(),
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? primaryColorLight
                                  : primaryColor),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        getString('ExplorePageBTPChartTitle'),
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'FRA FAI IL GRAFICO',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        getString('ExplorePageBTPInformationTitle'),
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDarkMode ? darkModeColor : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 8),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        getString(
                                            'ExplorePageBTPInformationPrice'),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        btp.value.toString(),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    color: Colors.grey[200],
                                    thickness: 1,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        getString(
                                            'ExplorePageBTPInformationCoupon'),
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${btp.cedola * 2}%',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    color: Colors.grey[200],
                                    thickness: 1,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        getString(
                                            'ExplorePageBTPInformationExpirationDate'),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${btp.expirationDate.day}/${btp.expirationDate.month}/${btp.expirationDate.year}',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    color: Colors.grey[200],
                                    thickness: 1,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        getString(
                                            'ExplorePageBTPInformationISIN'),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        btp.isin,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        getString('ExplorePageBTPInvestmentTitle'),
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDarkMode ? darkModeColor : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 8),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Price',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        btp.value.toString(),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    color: Colors.grey[200],
                                    thickness: 1,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Coupon',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${btp.cedola * 2}%',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    color: Colors.grey[200],
                                    thickness: 1,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Expiration date',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${btp.expirationDate.day}/${btp.expirationDate.month}/${btp.expirationDate.year}',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    color: Colors.grey[200],
                                    thickness: 1,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'ISIN code',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        btp.isin,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    Box box = Hive.box('settings');
    bool isDarkMode = box.get('darkMode', defaultValue: false);
    return Scaffold(
      backgroundColor: isDarkMode ? offBlackColor : offWhiteColor,
      appBar: AppTopBar(getString('appTopBarExplore'), null),
      // add a body and a footer
      body: SingleChildScrollView(
        child: Column(
          children: [
            ExplorePageSearchAndFilterComponent(searchWithFilters),
            FutureBuilder<List<BTP>>(
              future: getExplorePageBTPs(search, filters, ordering),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                      children: List.generate(
                          5,
                          (index) => const ExplorePageInvestmentComponent(
                              investmentName: null,
                              investmentDetail: null,
                              cedola: null,
                              investmentValue: null,
                              variation: null)));
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}'); // Handle errors
                } else if (snapshot.hasData) {
                  final assets = snapshot.data!;
                  final investmentList = assets.map((asset) {
                    final name = processString(asset.name);
                    // final percentage = name[0];
                    final withBtp = name[1];
                    final btpLess = name[2];
                    final double value = asset.value;
                    final double cedola = asset.cedola;
                    var variation = (value - 100);
                    // make it have 3 decimal places
                    variation = double.parse(variation.toStringAsFixed(3));

                    return TextButton(
                        onPressed: () => _openBTPDetailPage(
                              context,
                              isDarkMode,
                              asset,
                            ),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent),
                          padding: MaterialStateProperty.all(EdgeInsets.zero),
                          overlayColor: MaterialStateProperty.all(
                              primaryColor.withOpacity(0.3)),
                          shape: MaterialStateProperty.all(
                              const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero)),
                        ),
                        child: ExplorePageInvestmentComponent(
                          investmentName: btpLess ?? "Unknown",
                          investmentDetail: "$withBtp",
                          cedola: "${cedola * 2}%",
                          investmentValue: value,
                          variation: variation,
                        ));
                  }).toList();
                  return Column(children: investmentList);
                } else {
                  return const Text('No data'); // Handle the case of no data
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Footer('explore'),
    );
  }
}
