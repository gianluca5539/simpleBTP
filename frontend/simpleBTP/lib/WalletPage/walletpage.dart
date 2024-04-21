import 'package:flutter/material.dart';
import 'package:simpleBTP/btp_scraper.dart';
import 'package:simpleBTP/components/AppTopBar/apptopbar.dart';
import 'package:simpleBTP/components/Footer/footer.dart';
import 'package:fl_chart/fl_chart.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar('Portafoglio'),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchMyBTPHistories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: AspectRatio(
                aspectRatio: 1.0, // To make the chart square
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      drawHorizontalLine: true,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      ),
                      getDrawingVerticalLine: (value) => FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            // Customizing the text for bottom titles
                            return Text(value.toInt().toString(),
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 12));
                          },
                          reservedSize: 22,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            // Customizing the text for left titles
                            return Text('${value.toInt()}€',
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 12));
                          },
                          reservedSize: 40, // Adjust as needed
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: false,
                        dotData: const FlDotData(show: false), // Hide the dots
                        color: Theme.of(context).primaryColor,
                        belowBarData: BarAreaData(
                          show: true,
                          color: Theme.of(context).primaryColor.withOpacity(
                              0.3), // The fill color with some opacity
                        ),
                        spots: _getSpots(snapshot.data!),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: Text('No data found'));
          }
        },
      ),
      bottomNavigationBar: Footer('wallet'),
    );
  }

  List<FlSpot> _getSpots(List<Map<String, dynamic>> data) {
    var first = data.first;
    var history = first["priceHistory"];
    var series = history["series"];
    List<dynamic> firstSeries = series;
    return List.generate(firstSeries.length, (index) {
      return FlSpot(index.toDouble(), firstSeries[index]["close"]);
    });
  }
}
