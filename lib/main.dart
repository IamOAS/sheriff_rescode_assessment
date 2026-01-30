import 'package:flutter/material.dart';

/// An enum to represent the different types of cards.
enum CardType { small, medium, large }

/// A class to represent a card item.
class CardItem {
  final int index;
  final CardType type;
  final double height;

  CardItem({
    required this.index,
    required this.type,
    required this.height,
  });
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ScrollableListScreen(),
    );
  }
}

class ScrollableListScreen extends StatefulWidget {
  const ScrollableListScreen({super.key});

  @override
  State<ScrollableListScreen> createState() => _ScrollableListScreenState();
}

class _ScrollableListScreenState extends State<ScrollableListScreen> {
  late final ScrollController _scrollController;
  late final List<CardItem> _cardItems;

  int _firstVisibleIndex = 0;
  int _lastVisibleIndex = 0;

  static const int _totalCardItems = 50;
  static const double _cardItemPadding = 8.0;
  static const double _listPadding = 8.0;

  /// Returns the card type based on the index.
  CardType _getCardType(int index) {
    switch (index % 3) {
      case 0:
        return CardType.small;
      case 1:
        return CardType.medium;
      case 2:
        return CardType.large;
      default:
        return CardType.small;
    }
  }

  /// Returns the height for a given card type.
  double _getHeightForType(CardType type) {
    switch (type) {
      case CardType.small:
        return 120.0;
      case CardType.medium:
        return 180.0;
      case CardType.large:
        return 240.0;
    }
  }

  /// Updates the first and last visible indices based on scroll position.
  void _updateVisibleIndices() {
    if (!_scrollController.hasClients) return;

    // Get viewport boundaries
    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double scrollOffset = _scrollController.offset.clamp(0.0, maxScroll);
    final double viewportHeight = _scrollController.position.viewportDimension;
    final double visibleTop = scrollOffset;
    final double visibleBottom = scrollOffset + viewportHeight;

    // Handle empty list
    if (_cardItems.isEmpty) {
      if (_firstVisibleIndex != 0 || _lastVisibleIndex != 0) {
        setState(() {
          _firstVisibleIndex = 0;
          _lastVisibleIndex = 0;
        });
      }
      return;
    }

    int? firstVisible;
    int? lastVisible;
    double currentOffset = _listPadding;

    // Iterate through card items to find visible range
    for (int i = 0; i < _cardItems.length; i++) {
      final double cardItemHeight = _cardItems[i].height;
      final double cardItemTop = currentOffset;
      final double cardItemBottom = currentOffset + cardItemHeight;

      // Check if card item intersects the viewport
      if (cardItemBottom > visibleTop && cardItemTop < visibleBottom) {
        firstVisible ??= i;
        lastVisible = i;
      } else if (firstVisible != null && cardItemTop > visibleBottom) {
        // Early exit once we've passed the visible range
        break;
      }

      currentOffset += cardItemHeight + _cardItemPadding;
    }

    final int newFirst = firstVisible ?? 0;
    final int newLast = lastVisible ?? 0;

    // Only update state if indices changed
    if (newFirst != _firstVisibleIndex || newLast != _lastVisibleIndex) {
      setState(() {
        _firstVisibleIndex = newFirst;
        _lastVisibleIndex = newLast;
      });
    }
  }

  /// Scrolls the list to bring the specified index into view.
  void _scrollToIndex(int index) {
    // Validate index
    if (index < 0 || index >= _cardItems.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invalid index: $index. Valid range: 0 - ${_cardItems.length - 1}.',
          ),
        ),
      );
      return;
    }

    // Calculate target offset by summing heights of preceding items
    double targetOffset = _listPadding;
    for (int i = 0; i < index; i++) {
      targetOffset += _cardItems[i].height + _cardItemPadding;
    }

    // Clamp to valid scroll range
    final double maxScroll = _scrollController.position.maxScrollExtent;
    targetOffset = targetOffset.clamp(0.0, maxScroll);

    // Animate to target position
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  /// Shows a dialog to scroll to a specific index.
  void _showScrollDialog() {
    final TextEditingController indexController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Scroll to Index'),
        // Index Input Field
        content: TextField(
          autofocus: true,
          controller: indexController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter index (0-${_cardItems.length - 1})',
          ),
        ),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          // Go Button
          ElevatedButton(
            onPressed: () {
              final int? index = int.tryParse(
                indexController.text.trim(),
              );
              Navigator.pop(context);
              if (index != null) {
                _scrollToIndex(index);
              }
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _cardItems = List<CardItem>.generate(
      _totalCardItems,
      (int index) {
        final CardType type = _getCardType(index);
        return CardItem(
          index: index,
          type: type,
          height: _getHeightForType(type),
        );
      },
    );

    _scrollController = ScrollController();
    _scrollController.addListener(_updateVisibleIndices);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _updateVisibleIndices(),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateVisibleIndices);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Scrollable List Assignment'),
      ),
      body: SafeArea(
        child: Column(
          spacing: 8,
          children: [
            // First visible and last visible indices
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Text(
                'First visible: $_firstVisibleIndex | Last visible: $_lastVisibleIndex',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            // List of cards
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(_listPadding),
                itemCount: _cardItems.length,
                itemBuilder: (BuildContext context, int index) {
                  final CardItem cardItem = _cardItems[index];
                  final bool isVisible = index >= _firstVisibleIndex && index <= _lastVisibleIndex;
                  final Color color;

                  switch (cardItem.type) {
                    case CardType.small:
                      color = Colors.blue.shade100;
                      break;
                    case CardType.medium:
                      color = Colors.pink.shade100;
                      break;
                    case CardType.large:
                      color = Colors.orange.shade100;
                      break;
                  }

                  return GestureDetector(
                    onTap: () => _scrollToIndex(cardItem.index),
                    child: Container(
                      height: cardItem.height,
                      margin: const EdgeInsets.only(bottom: _cardItemPadding),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card Item Details
                          Expanded(
                            child: Column(
                              spacing: 8,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Card Item Index
                                Text(
                                  'Card Item Index: ${cardItem.index}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // Card Item Type
                                Text(
                                  'Card Item Type: ${cardItem.type.name.toUpperCase()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // Card Item Height
                                Text(
                                  'Card Item Height: ${cardItem.height.toInt()}px',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Visibility Indicator
                          if (isVisible) ...{
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'VISIBLE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          },
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showScrollDialog,
        icon: const Icon(Icons.search),
        label: const Text('Go to Index'),
      ),
    );
  }
}
