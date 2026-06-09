import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/book.dart';
import '../services/favorites_service.dart';
import '../services/open_library_service.dart';

class BookDetailsScreen extends StatefulWidget {
  final Book book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  late Book _book;
  bool _isFavorite = false;
  String? _description;
  bool _isLoadingDescription = true;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
    _isFavorite = FavoritesService.isFavorite(_book.key);
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final futures = <Future<dynamic>>[];

    if (_book.description == null) {
      futures.add(OpenLibraryService.fetchBookDescription(_book.key));
    } else {
      futures.add(Future.value(_book.description));
    }

    if (_book.rating == null) {
      futures.add(OpenLibraryService.fetchBookRating(_book.key));
    } else {
      futures.add(Future.value(_book.rating));
    }

    if (_book.pageCount == null) {
      futures.add(OpenLibraryService.fetchBookPageCount(_book.key));
    } else {
      futures.add(Future.value(_book.pageCount));
    }

    final results = await Future.wait(futures);

    if (mounted) {
      setState(() {
        _description = results[0] as String?;
        _isLoadingDescription = false;
        _book = _book.copyWith(
          description: results[0] as String?,
          rating: results[1] as double?,
          pageCount: results[2] as int?,
        );
      });

      if (FavoritesService.isFavorite(_book.key)) {
        FavoritesService.saveFavorite(_book);
      }
    }
  }

  void _toggleFavorite() async {
    final bool added = await FavoritesService.toggleFavorite(_book);
    setState(() {
      _isFavorite = added;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            added
                ? 'Added "${_book.title}" to library!'
                : 'Removed "${_book.title}" from library.',
            style: const TextStyle(fontFamily: 'Outfit'),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: added ? Colors.teal[700] : Colors.grey[800],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: size.height * 0.42,
            pinned: true,
            stretch: true,
            backgroundColor: isDark ? const Color(0xFF0a0a0a) : Colors.white,
            elevation: 0,
            leading: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: isDark ? const Color(0x66000000) : const Color(0x99FFFFFF),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
            actions: [
              ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: isDark ? const Color(0x66000000) : const Color(0x99FFFFFF),
                    child: IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.redAccent : (isDark ? Colors.white : Colors.black),
                      ),
                      onPressed: _toggleFavorite,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _book.coverId != null
                      ? ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Image.network(
                            _book.coverUrlMedium,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.teal[900]!, Colors.teal[600]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                  Container(
                    color: isDark ? const Color(0xA6000000) : const Color(0xB2FFFFFF),
                  ),
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 30),
                      height: size.height * 0.24,
                      width: size.height * 0.16,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x59000000),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Hero(
                        tag: 'cover_${_book.key}',
                        child: _book.coverId != null
                            ? Image.network(
                                _book.coverUrlLarge,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(color: Colors.grey[900]);
                                },
                                errorBuilder: (context, error, stackTrace) => _buildFallbackCover(),
                              )
                            : _buildFallbackCover(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0a0a0a) : Colors.grey[50],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _book.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _book.authors.isNotEmpty
                        ? 'by ${_book.authors.join(", ")}'
                        : 'by Unknown Author',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildStatsGrid(isDark),
                  const SizedBox(height: 28),
                  const Text(
                    'Synopsis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDescriptionSection(isDark),
                  const SizedBox(height: 28),
                  if (_book.subjects.isNotEmpty) ...[
                    const Text(
                      'Subjects & Genres',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _book.subjects.take(12).map((subject) {
                        return Chip(
                          label: Text(
                            subject,
                            style: TextStyle(
                              color: isDark ? Colors.teal[300] : Colors.teal[800],
                              fontSize: 12,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          backgroundColor: isDark ? const Color(0x26009688) : const Color(0x14009688),
                          side: BorderSide(
                            color: isDark ? const Color(0x4D009688) : const Color(0x33009688),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(bool isDark) {
    if (_isLoadingDescription) {
      return Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 14, width: double.infinity, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 14, width: double.infinity, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 14, width: double.infinity, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 14, width: 150, color: Colors.white),
          ],
        ),
      );
    }

    return Text(
      _description ?? 'No description has been provided for this book.',
      style: TextStyle(
        fontSize: 15,
        height: 1.6,
        color: isDark ? Colors.grey[300] : Colors.grey[800],
        fontFamily: 'Outfit',
      ),
    );
  }

  Widget _buildStatsGrid(bool isDark) {
    final Color cardColor = isDark ? const Color(0xFF1a1a1a) : Colors.white;
    final Color textColor = isDark ? Colors.white70 : Colors.black87;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(
          cardColor,
          Icons.star,
          Colors.amber,
          _book.rating != null ? _book.rating!.toStringAsFixed(1) : 'N/A',
          'Rating',
          textColor,
        ),
        _buildStatCard(
          cardColor,
          Icons.calendar_today,
          Colors.blueAccent,
          _book.firstPublishYear?.toString() ?? 'N/A',
          'Published',
          textColor,
        ),
        _buildStatCard(
          cardColor,
          Icons.menu_book,
          Colors.purpleAccent,
          _book.pageCount != null ? '${_book.pageCount}' : 'N/A',
          'Pages',
          textColor,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    Color cardColor,
    IconData icon,
    Color iconColor,
    String value,
    String label,
    Color textColor,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: iconColor.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontFamily: 'Outfit',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackCover() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal[800]!, Colors.teal[400]!],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.book_outlined,
                color: Colors.white70,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                _book.title,
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
