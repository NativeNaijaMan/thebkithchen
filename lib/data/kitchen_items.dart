/// Registry of all kitchen items available in the puzzle grid.
class KitchenItem {
  const KitchenItem({
    required this.id,
    required this.name,
    required this.emoji,
  });

  final String id;
  final String name;
  final String emoji;
}

abstract final class KitchenItems {
  static const Map<String, KitchenItem> catalog = {
    // Cooking tools
    'frying_pan': KitchenItem(id: 'frying_pan', name: 'Frying Pan', emoji: '🍳'),
    'pot': KitchenItem(id: 'pot', name: 'Pot', emoji: '🍲'),
    'knife': KitchenItem(id: 'knife', name: 'Knife', emoji: '🔪'),
    'cutting_board': KitchenItem(id: 'cutting_board', name: 'Cutting Board', emoji: '🪓'),
    'spatula': KitchenItem(id: 'spatula', name: 'Spatula', emoji: '🥄'),
    'whisk': KitchenItem(id: 'whisk', name: 'Whisk', emoji: '🥢'),
    'bowl': KitchenItem(id: 'bowl', name: 'Mixing Bowl', emoji: '🥣'),
    'plate': KitchenItem(id: 'plate', name: 'Plate', emoji: '🍽️'),
    'oven_mitt': KitchenItem(id: 'oven_mitt', name: 'Oven Mitt', emoji: '🧤'),
    'rolling_pin': KitchenItem(id: 'rolling_pin', name: 'Rolling Pin', emoji: '📏'),
    'colander': KitchenItem(id: 'colander', name: 'Colander', emoji: '🫗'),
    'ladle': KitchenItem(id: 'ladle', name: 'Ladle', emoji: '🫕'),

    // Ingredients
    'egg': KitchenItem(id: 'egg', name: 'Egg', emoji: '🥚'),
    'butter': KitchenItem(id: 'butter', name: 'Butter', emoji: '🧈'),
    'oil': KitchenItem(id: 'oil', name: 'Oil', emoji: '🫒'),
    'salt': KitchenItem(id: 'salt', name: 'Salt', emoji: '🧂'),
    'pepper': KitchenItem(id: 'pepper', name: 'Pepper', emoji: '🌶️'),
    'onion': KitchenItem(id: 'onion', name: 'Onion', emoji: '🧅'),
    'tomato': KitchenItem(id: 'tomato', name: 'Tomato', emoji: '🍅'),
    'pasta': KitchenItem(id: 'pasta', name: 'Pasta', emoji: '🍝'),
    'bread': KitchenItem(id: 'bread', name: 'Bread', emoji: '🍞'),
    'cheese': KitchenItem(id: 'cheese', name: 'Cheese', emoji: '🧀'),
    'lettuce': KitchenItem(id: 'lettuce', name: 'Lettuce', emoji: '🥬'),
    'chicken': KitchenItem(id: 'chicken', name: 'Chicken', emoji: '🍗'),
    'water': KitchenItem(id: 'water', name: 'Water', emoji: '💧'),
    'flour': KitchenItem(id: 'flour', name: 'Flour', emoji: '🌾'),
    'sugar': KitchenItem(id: 'sugar', name: 'Sugar', emoji: '🍬'),
    'milk': KitchenItem(id: 'milk', name: 'Milk', emoji: '🥛'),

    // Heat sources / appliances
    'stove': KitchenItem(id: 'stove', name: 'Stove', emoji: '🔥'),
    'oven': KitchenItem(id: 'oven', name: 'Oven', emoji: '♨️'),
    'toaster': KitchenItem(id: 'toaster', name: 'Toaster', emoji: '🍞'),
    'microwave': KitchenItem(id: 'microwave', name: 'Microwave', emoji: '📡'),
  };

  static KitchenItem? get(String id) => catalog[id];

  static String emojiFor(String id) => catalog[id]?.emoji ?? '❓';

  static String nameFor(String id) => catalog[id]?.name ?? id;
}
