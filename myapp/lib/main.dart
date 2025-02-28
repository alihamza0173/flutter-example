import 'package:flutter/material.dart';

import 'detail.dart';

void main() {
  runApp(NestedRouterDemo());
}

class NestedRouterDemo extends StatefulWidget {
  const NestedRouterDemo({super.key});

  @override
  State<NestedRouterDemo> createState() => _NestedRouterDemoState();
}

class _NestedRouterDemoState extends State<NestedRouterDemo> {
  final BookRouterDelegate _routerDelegate = BookRouterDelegate();
  final BookRouteInformationParser _routeInformationParser =
      BookRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Books App',
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}

class BooksAppState extends ChangeNotifier {
  int _selectedIndex;

  Book? _selectedBook;

  final List<Book> books = [
    Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
    Book('Foundation', 'Isaac Asimov'),
    Book('Fahrenheit 451', 'Ray Bradbury'),
  ];

  BooksAppState() : _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  set selectedIndex(int idx) {
    _selectedIndex = idx;
    if (_selectedIndex == 1) {
      // Remove this line if you want to keep the selected book when navigating
      // between "settings" and "home" which book was selected when Settings is
      // tapped.
      _selectedBook = null;
    }
    notifyListeners();
  }

  Book? get selectedBook => _selectedBook;

  set selectedBook(Book? book) {
    _selectedBook = book;
    notifyListeners();
  }

  int getSelectedBookById() {
    if (_selectedBook == null || !books.contains(_selectedBook)) return 0;
    return books.indexOf(_selectedBook!);
  }

  void setSelectedBookById(int id) {
    if (id < 0 || id > books.length - 1) {
      return;
    }

    _selectedBook = books[id];
    notifyListeners();
  }
}

class BookRouteInformationParser extends RouteInformationParser<BookRoutePath> {
  @override
  Future<BookRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = routeInformation.uri;

    if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'settings') {
      return BooksSettingsPath();
    } else {
      if (uri.pathSegments.length >= 2) {
        if (uri.pathSegments[0] == 'book') {
          return BooksDetailsPath(int.tryParse(uri.pathSegments[1]) ?? 0);
        }
      }
      return BooksListPath();
    }
  }

  @override
  RouteInformation? restoreRouteInformation(BookRoutePath configuration) {
    if (configuration is BooksListPath) {
      return RouteInformation(uri: Uri.parse('/home'));
    }
    if (configuration is BooksSettingsPath) {
      return RouteInformation(uri: Uri.parse('/settings'));
    }
    if (configuration is BooksDetailsPath) {
      return RouteInformation(uri: Uri.parse('/book/${configuration.id}'));
    }
    return null;
  }
}

class BookRouterDelegate extends RouterDelegate<BookRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<BookRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  BooksAppState appState = BooksAppState();

  BookRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>() {
    appState.addListener(notifyListeners);
  }

  @override
  BookRoutePath get currentConfiguration {
    if (appState.selectedIndex == 1) {
      return BooksSettingsPath();
    } else {
      if (appState.selectedBook == null) {
        return BooksListPath();
      } else {
        return BooksDetailsPath(appState.getSelectedBookById());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("build");
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          child: AppShell(appState: appState),
        ),
      ],
      onDidRemovePage: (final page) {
        print("onDidRemovePage");
        if (appState.selectedBook != null) {
          appState.selectedBook = null;
        }
        notifyListeners();
      },
    );
  }

  @override
  Future<void> setNewRoutePath(BookRoutePath path) async {
    print("setNewRoutePath");
    if (path is BooksListPath) {
      appState.selectedIndex = 0;
      appState.selectedBook = null;
    } else if (path is BooksSettingsPath) {
      appState.selectedIndex = 1;
    } else if (path is BooksDetailsPath) {
      appState.setSelectedBookById(path.id);
    }
  }
}

// Routes
abstract class BookRoutePath {}

class BooksListPath extends BookRoutePath {}

class BooksSettingsPath extends BookRoutePath {}

class BooksDetailsPath extends BookRoutePath {
  final int id;

  BooksDetailsPath(this.id);
}
