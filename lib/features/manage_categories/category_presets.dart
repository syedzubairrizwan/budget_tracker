/// Static preset category groups with subcategories.
/// Each entry: (name, emoji, defaultHexColor)
class CategoryPresets {
  static const Map<String, List<(String, String, String)>> groups = {
    'Life': [
      ('Childcare', '👶', '#7C4DFF'),
      ('Clothing', '👗', '#E91E8C'),
      ('Education', '📚', '#1565C0'),
      ('Gifts', '🎁', '#E53935'),
      ('Insurance', '🛡️', '#2E7D32'),
      ('Medical', '💊', '#C62828'),
      ('Tax', '📋', '#4E342E'),
    ],
    'Entertainment': [
      ('Games', '🎮', '#6A1B9A'),
      ('Movies', '🎬', '#D84315'),
      ('Music', '🎵', '#00838F'),
      ('Other', '✨', '#546E7A'),
      ('Sports', '⚽', '#2E7D32'),
    ],
    'Food & Drinks': [
      ('Dining Out', '🍽️', '#EF6C00'),
      ('Groceries', '🛒', '#558B2F'),
      ('Liquor', '🍺', '#6D4C41'),
    ],
    'Utilities': [
      ('Cleaning', '🧹', '#00796B'),
      ('Electricity', '⚡', '#F9A825'),
      ('Trash', '🗑️', '#757575'),
      ('Water', '💧', '#0288D1'),
      ('TV/Phone/Internet', '📡', '#1565C0'),
    ],
    'Transportation': [
      ('Bus', '🚌', '#1976D2'),
      ('Car', '🚗', '#424242'),
      ('Taxi', '🚕', '#F9A825'),
    ],
  };

  /// Group background gradient colors
  static const Map<String, (int, int)> groupGradients = {
    'Life': (0xFF7C4DFF, 0xFFE91E8C),
    'Entertainment': (0xFF6A1B9A, 0xFFD84315),
    'Food & Drinks': (0xFFEF6C00, 0xFF558B2F),
    'Utilities': (0xFF00796B, 0xFF0288D1),
    'Transportation': (0xFF1976D2, 0xFF424242),
  };

  /// Word-parsing keyword map for smart category suggestion.
  /// Maps lowercase keywords → (groupName, subcategoryName)
  static const Map<String, (String, String)> keywordMap = {
    // Life
    'daycare': ('Life', 'Childcare'),
    'babysitter': ('Life', 'Childcare'),
    'nursery': ('Life', 'Childcare'),
    'childcare': ('Life', 'Childcare'),
    'nanny': ('Life', 'Childcare'),
    'clothes': ('Life', 'Clothing'),
    'clothing': ('Life', 'Clothing'),
    'shirt': ('Life', 'Clothing'),
    'dress': ('Life', 'Clothing'),
    'shoes': ('Life', 'Clothing'),
    'jeans': ('Life', 'Clothing'),
    'fashion': ('Life', 'Clothing'),
    'apparel': ('Life', 'Clothing'),
    'school': ('Life', 'Education'),
    'tuition': ('Life', 'Education'),
    'university': ('Life', 'Education'),
    'college': ('Life', 'Education'),
    'course': ('Life', 'Education'),
    'book': ('Life', 'Education'),
    'books': ('Life', 'Education'),
    'education': ('Life', 'Education'),
    'gift': ('Life', 'Gifts'),
    'present': ('Life', 'Gifts'),
    'birthday': ('Life', 'Gifts'),
    'wedding': ('Life', 'Gifts'),
    'insurance': ('Life', 'Insurance'),
    'premium': ('Life', 'Insurance'),
    'policy': ('Life', 'Insurance'),
    'health': ('Life', 'Medical'),
    'doctor': ('Life', 'Medical'),
    'hospital': ('Life', 'Medical'),
    'medicine': ('Life', 'Medical'),
    'pharmacy': ('Life', 'Medical'),
    'clinic': ('Life', 'Medical'),
    'dental': ('Life', 'Medical'),
    'medical': ('Life', 'Medical'),
    'tax': ('Life', 'Tax'),
    'taxes': ('Life', 'Tax'),
    'income tax': ('Life', 'Tax'),
    'filing': ('Life', 'Tax'),

    // Entertainment
    'game': ('Entertainment', 'Games'),
    'gaming': ('Entertainment', 'Games'),
    'steam': ('Entertainment', 'Games'),
    'playstation': ('Entertainment', 'Games'),
    'xbox': ('Entertainment', 'Games'),
    'movie': ('Entertainment', 'Movies'),
    'cinema': ('Entertainment', 'Movies'),
    'netflix': ('Entertainment', 'Movies'),
    'amazon prime': ('Entertainment', 'Movies'),
    'hulu': ('Entertainment', 'Movies'),
    'film': ('Entertainment', 'Movies'),
    'music': ('Entertainment', 'Music'),
    'spotify': ('Entertainment', 'Music'),
    'concert': ('Entertainment', 'Music'),
    'itunes': ('Entertainment', 'Music'),
    'apple music': ('Entertainment', 'Music'),
    'sport': ('Entertainment', 'Sports'),
    'gym': ('Entertainment', 'Sports'),
    'cricket': ('Entertainment', 'Sports'),
    'football': ('Entertainment', 'Sports'),
    'fitness': ('Entertainment', 'Sports'),
    'swimming': ('Entertainment', 'Sports'),

    // Food & Drinks
    'restaurant': ('Food & Drinks', 'Dining Out'),
    'cafe': ('Food & Drinks', 'Dining Out'),
    'lunch': ('Food & Drinks', 'Dining Out'),
    'dinner': ('Food & Drinks', 'Dining Out'),
    'breakfast': ('Food & Drinks', 'Dining Out'),
    'takeout': ('Food & Drinks', 'Dining Out'),
    'pizza': ('Food & Drinks', 'Dining Out'),
    'burger': ('Food & Drinks', 'Dining Out'),
    'kfc': ('Food & Drinks', 'Dining Out'),
    'mcdonalds': ('Food & Drinks', 'Dining Out'),
    'grocery': ('Food & Drinks', 'Groceries'),
    'groceries': ('Food & Drinks', 'Groceries'),
    'supermarket': ('Food & Drinks', 'Groceries'),
    'vegetables': ('Food & Drinks', 'Groceries'),
    'fruits': ('Food & Drinks', 'Groceries'),
    'imtiaz': ('Food & Drinks', 'Groceries'),
    'carrefour': ('Food & Drinks', 'Groceries'),
    'alcohol': ('Food & Drinks', 'Liquor'),
    'beer': ('Food & Drinks', 'Liquor'),
    'wine': ('Food & Drinks', 'Liquor'),
    'liquor': ('Food & Drinks', 'Liquor'),
    'whiskey': ('Food & Drinks', 'Liquor'),

    // Utilities
    'cleaning': ('Utilities', 'Cleaning'),
    'laundry': ('Utilities', 'Cleaning'),
    'sweep': ('Utilities', 'Cleaning'),
    'maid': ('Utilities', 'Cleaning'),
    'electricity': ('Utilities', 'Electricity'),
    'electric': ('Utilities', 'Electricity'),
    'wapda': ('Utilities', 'Electricity'),
    'iesco': ('Utilities', 'Electricity'),
    'lesco': ('Utilities', 'Electricity'),
    'light bill': ('Utilities', 'Electricity'),
    'trash': ('Utilities', 'Trash'),
    'garbage': ('Utilities', 'Trash'),
    'waste': ('Utilities', 'Trash'),
    'water': ('Utilities', 'Water'),
    'water bill': ('Utilities', 'Water'),
    'internet': ('Utilities', 'TV/Phone/Internet'),
    'wifi': ('Utilities', 'TV/Phone/Internet'),
    'phone bill': ('Utilities', 'TV/Phone/Internet'),
    'mobile bill': ('Utilities', 'TV/Phone/Internet'),
    'cable': ('Utilities', 'TV/Phone/Internet'),
    'ptcl': ('Utilities', 'TV/Phone/Internet'),
    'tv': ('Utilities', 'TV/Phone/Internet'),

    // Transportation
    'bus': ('Transportation', 'Bus'),
    'rickshaw': ('Transportation', 'Bus'),
    'metro': ('Transportation', 'Bus'),
    'car': ('Transportation', 'Car'),
    'fuel': ('Transportation', 'Car'),
    'petrol': ('Transportation', 'Car'),
    'parking': ('Transportation', 'Car'),
    'maintenance': ('Transportation', 'Car'),
    'service': ('Transportation', 'Car'),
    'taxi': ('Transportation', 'Taxi'),
    'uber': ('Transportation', 'Taxi'),
    'careem': ('Transportation', 'Taxi'),
    'indriver': ('Transportation', 'Taxi'),
    'cab': ('Transportation', 'Taxi'),
  };

  /// Returns (groupName, subcategoryName) if input matches any keyword, else null.
  static (String, String)? suggestFromInput(String input) {
    if (input.trim().isEmpty) return null;
    final lower = input.toLowerCase();
    for (final entry in keywordMap.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }
}
