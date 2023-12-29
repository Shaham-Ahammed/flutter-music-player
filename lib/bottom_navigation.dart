import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lazits/Reusable_widgets/app_theme.dart';
import 'package:lazits/Reusable_widgets/mediaquery.dart';
import 'package:lazits/screens/all_songs_screen.dart';
import 'package:lazits/screens/favorites_screen.dart';
import 'package:lazits/screens/playslist_screen.dart';
import 'package:lazits/screens/recorder_screen.dart';
import 'package:lazits/screens/search_screen.dart';

class BottomNavigation extends StatefulWidget {
 
  const BottomNavigation({Key? key, }) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
   int lastUpdate=2;
  @override
  void initState() {
   
    super.initState();
  }

  final pages = [
    const Playlist(),
    const Search(),
    const AllSongs(),
    const Recorder(),
    const Favorites()
  ];

  final PageController _pageController = PageController(initialPage: 2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: pages,
              onPageChanged: (index) {
                  FocusScope.of(context).unfocus();
                setState(() {
                  lastUpdate = index;
                });
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: Container(
          height: mediaqueryWidth(0.18, context),
          decoration: BoxDecoration(
            gradient: bgTheme(),
          ),
          child: BottomNavigationBar(
            currentIndex: lastUpdate,
            onTap: (value) {
              _pageController.animateToPage(
                value,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );
            },
            iconSize: mediaqueryWidth(0.054, context),
            selectedItemColor: const Color.fromARGB(255, 114, 217, 231),
            items: [
              BottomNavigationBarItem(
                backgroundColor: const Color(0xFF1A1424).withOpacity(0.58),
                icon: const Icon(Icons.queue_music),
                label: "___",
              ),
              BottomNavigationBarItem(
                backgroundColor: const Color(0xFF1A1424).withOpacity(0.58),
                icon: const FaIcon(FontAwesomeIcons.magnifyingGlass),
                label: "___",
              ),
              BottomNavigationBarItem(
                backgroundColor: const Color(0xFF1A1424).withOpacity(0.58),
                icon: const FaIcon(FontAwesomeIcons.music),
                label: "___",
              ),
              BottomNavigationBarItem(
                backgroundColor: const Color(0xFF1A1424).withOpacity(0.58),
                icon: const FaIcon(FontAwesomeIcons.microphone),
                label: "___",
              ),
              BottomNavigationBarItem(
                backgroundColor: const Color(0xFF1A1424).withOpacity(0.58),
                icon: const FaIcon(
                  FontAwesomeIcons.solidHeart,
                  color: Colors.red,
                ),
                label: "___",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
