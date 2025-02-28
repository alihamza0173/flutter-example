import 'package:flutter/material.dart';

import 'main.dart';

// Widget that contains the AdaptiveNavigationScaffold
class AppShell extends StatefulWidget {
  final BooksAppState appState;

  const AppShell({
    super.key,
    required this.appState,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  Widget build(BuildContext context) {
    print("inner build");
    var appState = widget.appState;

    return Scaffold(
      appBar: AppBar(),
      body: _buildBody(context),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: appState.selectedIndex,
        onTap: (newIndex) {
          appState.selectedIndex = newIndex;
        },
      ),
    );
  }

  Widget _buildDetailView(BuildContext context) {
    if (widget.appState.selectedBook != null) {
      return BookDetailsScreen(book: widget.appState.selectedBook);
    } else {
      return Container();
    }
  }

  void _handleBookTapped(Book book) {
    widget.appState.selectedBook = book;
  }

  Widget _buildTabletView(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
            child: BooksListScreen(
          books: widget.appState.books,
          onTapped: _handleBookTapped,
        )),
        Visibility(
            visible: widget.appState.selectedBook != null,
            child: Expanded(child: _buildDetailView(context)))
      ],
    );
  }

  Widget _buildMobileView(BuildContext context) {
    return Stack(children: [
      BooksListScreen(
        books: widget.appState.books,
        onTapped: _handleBookTapped,
      ),
      Visibility(
          visible: widget.appState.selectedBook != null,
          child: _buildDetailView(context))
    ]);
  }

  Widget _buildBody(BuildContext context) {
    if (widget.appState.selectedIndex == 0) {
      return LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth > 720) {
          return _buildTabletView(context);
        } else {
          return _buildMobileView(context);
        }
      });
    } else {
      return SettingsScreen();
    }
  }
}

// Screens
class BooksListScreen extends StatelessWidget {
  final List<Book?> books;
  final ValueChanged<Book> onTapped;

  const BooksListScreen({
    super.key,
    required this.books,
    required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          for (var book in books)
            ListTile(
              title: Text(book?.title ?? 'Title'),
              subtitle: Text(book?.author ?? 'Author'),
              onTap: () => onTapped(book!),
            )
        ],
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  final Book? book;

  const BookDetailsScreen({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Back'),
            ),
            if (book != null) ...[
              Text(
                book?.title ?? 'Book',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                book?.author ?? 'Author',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Settings screen'),
      ),
    );
  }
}

class Book {
  final String title;
  final String author;

  Book(this.title, this.author);
}
