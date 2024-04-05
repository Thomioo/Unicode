import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<(String, int, bool)> chars = [];
  List<(String, int)> temp = [];
  List<int> favourites = [];

  @override
  void initState() {
    super.initState();
    print("init");
    getFavourites().then((value) {
      favourites = value;
      getUnicodeChars();
    });
  }

  void changeToFavouritesPage() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const FavouritesPage()));
  }

  Future<void> saveFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    favourites.sort();
    prefs.setStringList('favourites', favourites.map((e) => "$e").toList());
  }

  Future<List<int>> getFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('favourites')?.map(int.parse).toList() ?? [];
  }

  void toggleStar(int index) {
    if (favourites.contains(chars[index].$2)) {
      favourites.remove(chars[index].$2);
    } else {
      favourites.add(chars[index].$2);
    }
    setState(() {
      chars[index] =
          (chars[index].$1, chars[index].$2, favourites.contains(index));
      saveFavourites();
    });
  }

  void getUnicodeChars() {
    for (int i = 0; i < 0x10FFFF; i++) {
      String char = String.fromCharCode(i);
      chars.add((char, i, favourites.contains(i)));
    }
    setState(() {});
  }

  void _copyToClipBoard(String char) {
    Clipboard.setData(ClipboardData(text: char)).then((value) =>
        Fluttertoast.showToast(
            msg: 'Copied "$char" to clipboard', gravity: ToastGravity.CENTER));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        _HomePageState().initState();
      },
      child: Scaffold(
        appBar: appBar(),
        body: body(),
        backgroundColor: Colors.lightGreen.shade50,
      ),
    );
  }

  Padding body() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: GridView.builder(
        itemCount: chars.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 8 / 11),
        itemBuilder: (context, index) {
          return itemInGrid(index);
        },
      ),
    );
  }

  InkWell itemInGrid(int index) {
    return InkWell(
      onTap: () => _copyToClipBoard(chars[index].$1),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.green.shade100,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: Row()),
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: InkWell(
                    onTap: () => toggleStar(index),
                    child: chars[index].$3
                        ? const Icon(
                            Icons.star,
                            color: Colors.amber,
                          )
                        : const Icon(
                            Icons.star_border,
                          ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      chars[index].$1,
                      style:
                          const TextStyle(fontSize: 32, fontFamily: 'NotoSans'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      "U+${chars[index].$2.toRadixString(16).toUpperCase().padLeft(4, '0')}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Colors.lightGreen.shade50,
      title: Row(
        children: [
          InkWell(
            onTap: () => changeToFavouritesPage(),
            child: const Icon(Icons.star_border),
          ),
          const Expanded(
              child: SizedBox(
            height: 10,
          )),
          InkWell(
            onTap: () => Fluttertoast.showToast(msg: "made by Tomeš"),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.lightGreen.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Padding(
                padding: EdgeInsets.only(left: 15, right: 15),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(left: 4, right: 4),
                    child: Text(
                      "Unicode Picker",
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Expanded(
              child: SizedBox(
            height: 10,
          )),
        ],
      ),
    );
  }
}

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  List<(String, int, bool)> chars = [];
  List<int> favourites = [];

  @override
  void initState() {
    super.initState();
    getFavourites().then((value) {
      favourites = value;
      generateCharsFromFavourites();
    });
  }

  void changeToHomePage() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()));
  }

  void generateCharsFromFavourites() {
    setState(() {
      chars = [];
    });
    for (int i = 0; i < favourites.length; i++) {
      setState(() {
        chars.add((
          String.fromCharCode(favourites[i]),
          favourites[i],
          favourites.contains(favourites[i])
        ));
      });
    }
  }

  Future<List<int>> getFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('favourites')?.map(int.parse).toList() ?? [];
  }

  void _copyToClipBoard(String char) {
    Clipboard.setData(ClipboardData(text: char)).then((value) =>
        Fluttertoast.showToast(
            msg: 'Copied "$char" to clipboard', gravity: ToastGravity.CENTER));
  }

  Future<void> saveFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    favourites.sort();
    prefs.setStringList('favourites', favourites.map((e) => "$e").toList());
  }

  void toggleStar(int ind) {
    if (favourites.contains(chars[ind].$2)) {
      favourites.remove(chars[ind].$2);
      saveFavourites().then((value) => generateCharsFromFavourites());
    } else {
      favourites.add(chars[ind].$2);
      saveFavourites().then((value) => generateCharsFromFavourites());
    }
    setState(() {
      chars[ind] = (chars[ind].$1, chars[ind].$2, favourites.contains(ind));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: body(),
      backgroundColor: Colors.lightGreen.shade50,
    );
  }

  Padding body() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: GridView.builder(
        itemCount: favourites.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 8 / 11),
        itemBuilder: (context, index) {
          return itemInGrid(index);
        },
      ),
    );
  }

  InkWell itemInGrid(int ind) {
    return InkWell(
      onTap: () => _copyToClipBoard(chars[ind].$1),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.green.shade100,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: Row()),
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: InkWell(
                    onTap: () => toggleStar(ind),
                    child: chars[ind].$3
                        ? const Icon(
                            Icons.star,
                            color: Colors.amber,
                          )
                        : const Icon(
                            Icons.star_border,
                          ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      chars[ind].$1,
                      style:
                          const TextStyle(fontSize: 32, fontFamily: 'NotoSans'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      "U+${chars[ind].$2.toRadixString(16).toUpperCase().padLeft(4, '0')}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Colors.lightGreen.shade50,
      title: Row(
        children: [
          InkWell(
            onTap: () => changeToHomePage(),
            child: const Icon(Icons.home_outlined),
          ),
          const Expanded(
              child: SizedBox(
            height: 10,
          )),
          Container(
            decoration: BoxDecoration(
              color: Colors.lightGreen.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Padding(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 4, right: 4),
                  child: Text(
                    "Favourites",
                    style: TextStyle(fontSize: 25),
                  ),
                ),
              ),
            ),
          ),
          const Expanded(
              child: SizedBox(
            height: 10,
          )),
        ],
      ),
    );
  }
}
