import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final amountController = TextEditingController(text: '1');
  String from = 'USD';
  String to = 'BDT';
  String result = '0.00';
  bool loading = false;
  bool darkMode = false;

  final List<String> allCurrencies = [
    'USD','EUR','BDT','INR','GBP','JPY','AUD','CAD','CHF','CNY',
    'BTC','ETH','LTC','DOGE','ADA','BNB','XRP','SOL','DOT'
  ];

  bool get isCrypto => ['BTC','ETH','LTC','DOGE','ADA','BNB','XRP','SOL','DOT'].contains(from);

  List<String> get toCurrencyList {
    if (isCrypto) return ['USD','EUR','BDT','INR','GBP','JPY','AUD','CAD','CHF','CNY'];
    return allCurrencies;
  }

  Future<void> convert() async {
    final amt = double.tryParse(amountController.text) ?? 0;
    if (amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number.')),
      );
      return;
    }

    setState(() {
      loading = true;
      result = '...';
    });

    double value = 0;

    try {
      if (isCrypto) {
        value = await ApiService.convertCrypto(from, to, amt);
      } else {
        value = await ApiService.convertCurrency(from, to, amt);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Conversion failed: $e')),
      );
      value = 0;
    }

    setState(() {
      result = value.toStringAsFixed(2);
      loading = false;
    });
  }

  void swapCurrencies() {
    setState(() {
      final temp = from;
      from = to;
      to = temp;
    });
  }

  void openPlayStore() async {
    final url = 'https://play.google.com/store/apps/details?id=com.yourapp.package';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Play Store')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Conversion Card
    Widget conversionCard = Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Row(
              children: [
                Expanded(child: currencyDropdown(value: from, options: allCurrencies, onChanged: (val) => setState(() => from = val))),
                IconButton(
                  onPressed: swapCurrencies,
                  icon: Icon(Icons.swap_horiz, size: screenWidth * 0.08),
                ),
                Expanded(child: currencyDropdown(value: to, options: toCurrencyList, onChanged: (val) => setState(() => to = val))),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            SizedBox(
              width: double.infinity,
              height: screenHeight * 0.06,
              child: ElevatedButton(
                onPressed: loading ? null : convert,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Convert', style: TextStyle(fontSize: screenWidth * 0.045,color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );

    // Result Card
    Widget resultCard = Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            const Text('Result', style: TextStyle(color: Colors.grey, fontSize: 16)),
            SizedBox(height: screenHeight * 0.01),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(result, style: TextStyle(fontSize: screenWidth * 0.1, fontWeight: FontWeight.bold, color: Colors.indigo)),
            ),
          ],
        ),
      ),
    );

    // Rating Card
    Widget ratingCard = Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            const Text('Rate Our App', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: screenHeight * 0.01),
            SmoothStarRating(screenWidth: screenWidth, onTap: openPlayStore),
          ],
        ),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: darkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Currency & Crypto Converter',style: TextStyle(color: Colors.white),),
          centerTitle: true,
          backgroundColor: Colors.indigo,
          actions: [
            IconButton(
              icon: Icon(darkMode ? Icons.dark_mode : Icons.light_mode,color: Colors.orange,),
              onPressed: () {
                setState(() => darkMode = !darkMode);
              },
            )
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            bool isTablet = constraints.maxWidth > 600;

            return Column(
              children: [
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Column(
                      children: [
                        conversionCard,
                        SizedBox(height: screenHeight * 0.02),
                        resultCard,
                        // আরও future content যোগ করতে চাইলে এখানে
                      ],
                    ),
                  ),
                ),

                // Rating card fixed at bottom with copyright text
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ratingCard,
                      const SizedBox(height: 8),
                      const Text(
                        "© 2026 Aminul Islam. | AppInventive",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget currencyDropdown({
    required String value,
    required List<String> options,
    required void Function(String) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: options.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
      decoration: const InputDecoration(border: OutlineInputBorder()),
    );
  }
}

// ⭐ Smooth Star Rating Widget with sequential animation
class SmoothStarRating extends StatefulWidget {
  final VoidCallback? onTap;
  final double screenWidth;
  const SmoothStarRating({super.key, this.onTap, required this.screenWidth});

  @override
  State<SmoothStarRating> createState() => _SmoothStarRatingState();
}

class _SmoothStarRatingState extends State<SmoothStarRating> {
  int rating = 0;
  int displayedRating = 0;

  void fillStars(int newRating) {
    displayedRating = 0;
    int counter = 0;

    Timer.periodic(const Duration(milliseconds: 150), (timer) {
      counter++;
      if (counter > newRating) {
        timer.cancel();
        if (widget.onTap != null) widget.onTap!();
      } else {
        setState(() {
          displayedRating = counter;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            rating = index + 1;
            fillStars(rating);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.01),
            child: Icon(
              index < displayedRating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: widget.screenWidth * 0.08,
            ),
          ),
        );
      }),
    );
  }
}
