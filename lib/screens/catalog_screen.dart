import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/book.dart';
import '../services/favorites_service.dart';
import '../services/open_library_service.dart';
import '../widgets/book_card.dart';
import 'book_details_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final List<String> _categories = const [
    'Sci-Fi',
    'Fantasy',
    'Romance',
    'History',
    'Mystery',
  ];

  String _activeCategory = 'Sci-Fi';
  List<Book> _onlineBooks = [];
  List<Book> _offlineBooks = [];
  bool _isOfflineMode = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCategoryBooks(_activeCategory);
    _loadOfflineBooks();
  }

  void _loadOfflineBooks() {
    final books = FavoritesService.getFavorites();
    setState(() {
      _offlineBooks = books;
    });
  }

  Future<void> _loadCategoryBooks(String category) async {
    setState(() {
      _isLoading = true;
      _onlineBooks = [];
      _errorMessage = '';
    });

    try {
      final String subjectParam = category == 'Sci-Fi' ? 'science_fiction' : category.toLowerCase();
      final results = await OpenLibraryService.fetchBooksBySubject(subjectParam, limit: 30);
      if (mounted) {
        setState(() {
          _onlineBooks = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not load data. Please verify your connection.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LibriVerse',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            fontFamily: 'Outfit',
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF0a0a0a) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0a0a0a) : Colors.white,
              boxShadow: [
                if (!isDark)
                  const BoxShadow(
                    color: Color(0x149E9E9E),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildModeTab(
                        label: 'Online Catalog',
                        active: !_isOfflineMode,
                        icon: Icons.public,
                        isDark: isDark,
                        onTap: () {
                          setState(() {
                            _isOfflineMode = false;
                          });
                          _loadCategoryBooks(_activeCategory);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModeTab(
                        label: 'My Shelf (Offline)',
                        active: _isOfflineMode,
                        icon: Icons.bookmark_outline,
                        isDark: isDark,
                        onTap: () {
                          setState(() {
                            _isOfflineMode = true;
                          });
                          _loadOfflineBooks();
                        },
                      ),
                    ),
                  ],
                ),
                if (!_isOfflineMode) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = cat == _activeCategory;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              cat,
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 13,
                                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: Colors.teal,
                            backgroundColor: isDark ? const Color(0xFF1a1a1a) : const Color(0xFFEEEEEE),
                            checkmarkColor: Colors.white,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _activeCategory = cat;
                                });
                                _loadCategoryBooks(cat);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: _buildContent(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab({
    required String label,
    required bool active,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? Colors.teal
              : (isDark ? const Color(0xFF1a1a1a) : const Color(0xFFEEEEEE)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: active ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Outfit',
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (_isOfflineMode) {
      if (_offlineBooks.isEmpty) {
        return _buildOfflineEmptyState(isDark);
      }
      return _buildGrid(_offlineBooks);
    }

    if (_isLoading) {
      return _buildSkeletonLoader(isDark);
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorState();
    }

    if (_onlineBooks.isEmpty) {
      return _buildNoResultsState();
    }

    return _buildGrid(_onlineBooks);
  }

  Widget _buildGrid(List<Book> books) {
    return RefreshIndicator(
      onRefresh: () async {
        if (_isOfflineMode) {
          _loadOfflineBooks();
        } else {
          _loadCategoryBooks(_activeCategory);
        }
      },
      color: Colors.teal,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return BookCard(
            book: book,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookDetailsScreen(book: book),
                ),
              ).then((_) {
                if (_isOfflineMode) {
                  _loadOfflineBooks();
                }
              });
            },
            onFavoriteToggled: () {
              if (_isOfflineMode) {
                _loadOfflineBooks();
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildOfflineEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0x14009688),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_outline,
                size: 64,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Shelf is Empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Switch to the online catalog to browse and save books to your offline shelf.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontFamily: 'Outfit',
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 56,
              color: Color(0x669E9E9E),
            ),
            SizedBox(height: 16),
            Text(
              'No Books Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'No books found in this category.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'Outfit',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'Connection Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _loadCategoryBooks(_activeCategory),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Try Again', style: TextStyle(color: Colors.white, fontFamily: 'Outfit')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }
}
