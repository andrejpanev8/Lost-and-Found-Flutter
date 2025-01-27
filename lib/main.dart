import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lost_and_found_app/presentation/widgets/add_item_pop.dart';
import 'package:lost_and_found_app/providers/user_info_provider.dart';
import 'package:lost_and_found_app/service/auth_service.dart';
import 'package:lost_and_found_app/utils/connections.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'presentation/screens/found_items_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/lost_items_screen.dart';
import 'presentation/screens/my_items_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/user_profile_screen.dart';
import 'presentation/widgets/custom_app_bar.dart';
import 'providers/items_provider.dart';
import 'utils/color_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Supabase.initialize(url: supabaseURL, anonKey: supabaseKey);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ItemsProvider>(
          create: (_) => ItemsProvider(),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
        )
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lost and Found',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: greenPrimary),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/profile': (context) => const UserProfileScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context: context),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        destinations: [
          const NavigationDestination(
              icon: Icon(Icons.error), label: 'Lost Items'),
          const NavigationDestination(
              icon: Icon(Icons.check_circle), label: 'Found Items'),
          const NavigationDestination(
              icon: Icon(Icons.inventory), label: 'My Items'),
        ],
        selectedIndex: currentPageIndex,
      ),
      body: [
        const LostItemsScreen(),
        const FoundItemsScreen(),
        myItems(context, currentPageIndex),
      ][currentPageIndex],
    );
  }
}

Widget myItems(BuildContext context, int index) {
  if (index == 2) {
    if (AuthService().currentUser != null) {
      ItemsProvider().loadUserItems();
      return MyItemsScreen();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        UserProvider().navigate(context, "/login");
      });
    }
  }
  return const SizedBox.shrink();
}
