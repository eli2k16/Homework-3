import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math'; // Import dart:math for shuffling

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: CardMatchingGame(),
    ),
  );
}

class CardMatchingGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Matching Game',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.green, // Set the background color to green
      ),
      navigatorKey: navigatorKey,
      home: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50.0), // Add padding at the top for the title
              child: Center(
                child: Text(
                  'Card Matching Game',
                  style: TextStyle(
                    fontSize: 32, // Title size
                    color: Colors.white, // Title color
                    fontWeight: FontWeight.bold, // Make title bold
                  ),
                ),
              ),
            ),
            Expanded(
              child: GameGrid(), // Use Expanded to fill the remaining space
            ),
            Padding(
              padding: const EdgeInsets.all(16.0), // Add padding for the button
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<GameProvider>(context, listen: false).resetGame();
                },
                child: Text('Reset Game'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // Number of columns
        childAspectRatio: 0.6, // Adjust the aspect ratio
      ),
      itemBuilder: (context, index) {
        return CardWidget(index: index);
      },
      itemCount: gameProvider.cards.length,
    );
  }
}

class CardWidget extends StatelessWidget {
  final int index;

  const CardWidget({required this.index});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final card = gameProvider.cards[index];

    return GestureDetector(
      onTap: () {
        gameProvider.flipCard(index);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 60, // Set the width of the card smaller
        height: 80, // Set the height of the card smaller
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: AssetImage(card.isFaceUp ? card.frontDesign : card.backDesign),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class GameProvider with ChangeNotifier {
  List<CardModel> cards = [];

  int? firstCardIndex;
  int? secondCardIndex;

  GameProvider() {
    _initializeCards(); // Initialize the cards when the provider is created
  }

  void _initializeCards() {
    List<CardModel> tempCards = [
      CardModel(frontDesign: 'images/card1.jpg', backDesign: 'images/back.jpg'),
      CardModel(frontDesign: 'images/card1.jpg', backDesign: 'images/back.jpg'),
      CardModel(frontDesign: 'images/card2.jpg', backDesign: 'images/back.jpg'),
      CardModel(frontDesign: 'images/card2.jpg', backDesign: 'images/back.jpg'),
      CardModel(frontDesign: 'images/card3.jpg', backDesign: 'images/back.jpg'),
      CardModel(frontDesign: 'images/card3.jpg', backDesign: 'images/back.jpg'),
      CardModel(frontDesign: 'images/card4.jpg', backDesign: 'images/back.jpg'),
      CardModel(frontDesign: 'images/card4.jpg', backDesign: 'images/back.jpg'),
      CardModel(frontDesign: 'images/card5.jpg', backDesign: 'images/back.jpg'),
      CardModel(frontDesign: 'images/card5.jpg', backDesign: 'images/back.jpg'),
      CardModel(frontDesign: 'images/card6.jpg', backDesign: 'images/back.jpg'),
      CardModel(frontDesign: 'images/card6.jpg', backDesign: 'images/back.jpg'),
      CardModel(frontDesign: 'images/card7.jpg', backDesign: 'images/back.jpg'),
      CardModel(frontDesign: 'images/card7.jpg', backDesign: 'images/back.jpg'),
      CardModel(frontDesign: 'images/card8.jpg', backDesign: 'images/back.jpg'),
      CardModel(frontDesign: 'images/card8.jpg', backDesign: 'images/back.jpg'),
    ];

    // Shuffle the cards
    tempCards.shuffle(Random());
    cards = tempCards;
  }

  void flipCard(int index) {
    if (cards[index].isFaceUp || (firstCardIndex != null && secondCardIndex != null)) {
      return; // Prevent flipping already face-up cards or if two cards are already flipped
    }

    cards[index].isFaceUp = true;
    notifyListeners();

    if (firstCardIndex == null) {
      firstCardIndex = index;
    } else {
      secondCardIndex = index;
      Future.delayed(Duration(seconds: 1), () => checkForMatch());
    }
  }

  void checkForMatch() {
    if (firstCardIndex != null && secondCardIndex != null) {
      if (cards[firstCardIndex!].frontDesign == cards[secondCardIndex!].frontDesign) {
        // Cards match, do nothing
      } else {
        // Cards do not match, flip them back down
        cards[firstCardIndex!].isFaceUp = false;
        cards[secondCardIndex!].isFaceUp = false;
      }
      notifyListeners();
      firstCardIndex = null;
      secondCardIndex = null;

      // Check for win condition
      if (cards.every((card) => card.isFaceUp)) {
        showVictoryDialog();
      }
    }
  }

  void resetGame() {
    // Reset all cards to face down and shuffle them again
    for (var card in cards) {
      card.isFaceUp = false;
    }
    _initializeCards(); // Reinitialize and shuffle cards
    firstCardIndex = null;
    secondCardIndex = null;
    notifyListeners(); // Notify listeners to update the UI
  }

  void showVictoryDialog() {
    // Display victory message
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text('You have matched all the cards!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class CardModel {
  final String frontDesign;
  final String backDesign;
  bool isFaceUp;

  CardModel({required this.frontDesign, required this.backDesign, this.isFaceUp = false});
}
