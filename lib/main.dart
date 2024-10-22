import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sunnah',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF808000), // Olive green
          primary: const Color(0xFF808000), // Olive green
          secondary: const Color(0xFFFFFFFF), // White
          surface: const Color(0xFFF0F0E0), // Light olive surface
        ),
        appBarTheme: AppBarTheme(
          color: const Color(0xFF808000), // Olive green
          elevation: 0,
          titleTextStyle: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.lato(color: Colors.black87),
          bodyMedium: GoogleFonts.lato(color: Colors.black54),
        ),
        useMaterial3: true,
      ),
      home: const SplashScr(),
    );
  }
}

class SplashScr extends StatefulWidget {
  const SplashScr({super.key});

  @override
  State<SplashScr> createState() => _SplashScrState();
}

class _SplashScrState extends State<SplashScr>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const HadithsScreen()));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF808000), // Olive green
                  Color(0xFFBDB76B), // Lighter olive
                ],
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Sunnah",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "jameel",
                      fontSize: 40,
                      color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  "السنة",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "jameel",
                      fontSize: 35,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HadithsScreen extends StatefulWidget {
  const HadithsScreen({super.key});

  @override
  State<HadithsScreen> createState() => _HadithsScreenState();
}

class _HadithsScreenState extends State<HadithsScreen> {
  late Map mapresp;
  late List listresp = [];

  Future apicallkardo() async {
    var apiKey =
        "\$2y\$10\$BylaBcXs5Lw7ZOtYmQ3PXO1x15zpp26oc1FeGktdmF6YeYoRd88e";
    http.Response response = await http
        .get(Uri.parse("https://hadithapi.com/api/books?apiKey=$apiKey"));

    if (response.statusCode == 200) {
      setState(() {
        mapresp = jsonDecode(response.body);
        listresp = mapresp["books"];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    apicallkardo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hadith Collections"),
        centerTitle: true,
      ),
      body: listresp.isNotEmpty
          ? ListView.builder(
              itemCount: listresp.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    onTap: () {
                      var bookslug = listresp[index]["bookSlug"];
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChaptersScreen(bookslug),
                          ));
                    },
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF808000), // Olive green
                      radius: 30,
                      child: Text(
                        "${index + 1}",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    title: Text(listresp[index]["bookName"],
                        style: GoogleFonts.lato(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text(listresp[index]["writerName"],
                        style: const TextStyle(color: Colors.grey)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Hadiths: ${listresp[index]["hadiths_count"]}"),
                        Text("Chapters: ${listresp[index]["chapters_count"]}"),
                      ],
                    ),
                  ),
                );
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class ChaptersScreen extends StatefulWidget {
  final String bookslug;
  const ChaptersScreen(this.bookslug, {super.key});

  @override
  State<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {
  late Map mapresp;
  late List listresp = [];

  Future apicallkardo() async {
    var bookname = widget.bookslug;
    var apiKey =
        "\$2y\$10\$BylaBcXs5Lw7ZOtYmQ3PXO1x15zpp26oc1FeGktdmF6YeYoRd88e";
    http.Response response = await http.get(Uri.parse(
        "https://hadithapi.com/api/$bookname/chapters?apiKey=$apiKey"));

    if (response.statusCode == 200) {
      setState(() {
        mapresp = jsonDecode(response.body);
        listresp = mapresp["chapters"];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    apicallkardo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chapters"),
        centerTitle: true,
      ),
      body: listresp.isNotEmpty
          ? ListView.builder(
              itemCount: listresp.length,
              itemBuilder: (context, index) {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    onTap: () {
                      var bookslug = listresp[index]["bookSlug"];
                      var chapterNumber = int.tryParse(
                              listresp[index]["chapterNumber"].toString()) ??
                          0; // Convert to int
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HadithScreen(bookslug, chapterNumber),
                          ));
                    },
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF808000), // Olive green
                      radius: 30,
                      child: Text(
                        listresp[index]["chapterNumber"].toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    title: Text(
                      listresp[index]["chapterArabic"],
                      style: GoogleFonts.amiriQuran(fontSize: 20),
                    ),
                    subtitle: Text(
                      "${listresp[index]["chapterEnglish"]} | ${listresp[index]["chapterUrdu"]}",
                      style: const TextStyle(
                          fontFamily: "jameel", fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class HadithScreen extends StatefulWidget {
  final String bookSlug;
  final int chapterNumber;
  const HadithScreen(this.bookSlug, this.chapterNumber, {super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  late Map mapresp;
  late List listresp = [];

  Future apicallkardo() async {
    var bookname = widget.bookSlug;
    var chapter = widget.chapterNumber;
    var apiKey =
        "\$2y\$10\$BylaBcXs5Lw7ZOtYmQ3PXO1x15zpp26oc1FeGktdmF6YeYoRd88e";
    http.Response response = await http.get(Uri.parse(
        "https://hadithapi.com/api/$bookname/chapter/$chapter/hadiths?apiKey=$apiKey"));

    if (response.statusCode == 200) {
      setState(() {
        mapresp = jsonDecode(response.body);
        listresp = mapresp["hadiths"];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    apicallkardo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hadiths"),
        centerTitle: true,
      ),
      body: listresp.isNotEmpty
          ? ListView.builder(
              itemCount: listresp.length,
              itemBuilder: (context, index) {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    title: Text(
                      listresp[index]["hadithArabic"],
                      style: GoogleFonts.amiriQuran(fontSize: 18),
                    ),
                    subtitle: Text(
                      listresp[index]["hadithUrdu"],
                      style: const TextStyle(
                          fontFamily: "jameel",
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
