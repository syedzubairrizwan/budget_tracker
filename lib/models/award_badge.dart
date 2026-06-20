import 'package:flutter/material.dart';

class AwardBadge {
  final String id;
  final String emoji;
  final String title;
  final String description;
  final int target;
  final Color color;

  const AwardBadge({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.target,
    required this.color,
  });

  static List<AwardBadge> get badges => const [
        // Goals Category
        AwardBadge(
          id: 'goal_1',
          emoji: '🎯',
          title: 'First Target',
          description: 'Set your first financial goal.',
          target: 1,
          color: Color(0xFFFF9800), // Orange
        ),
        AwardBadge(
          id: 'goal_5',
          emoji: '🏹',
          title: 'Goal Setter',
          description: 'Set 5 different goals.',
          target: 5,
          color: Color(0xFFE91E63), // Pink
        ),
        AwardBadge(
          id: 'goal_achieved_1',
          emoji: '🏆',
          title: 'Legend',
          description: 'Achieve your first goal.',
          target: 1,
          color: Color(0xFFFFC107), // Gold
        ),
        AwardBadge(
          id: 'goal_achieved_5',
          emoji: '👑',
          title: 'Flawless Finisher',
          description: 'Achieve 5 goals.',
          target: 5,
          color: Color(0xFF9C27B0), // Purple
        ),
        AwardBadge(
          id: 'goal_fast',
          emoji: '⚡',
          title: 'Speed Racer',
          description: 'Achieve a goal in record time.',
          target: 1,
          color: Color(0xFFF44336), // Red
        ),

        // Budgets Category
        AwardBadge(
          id: 'budget_1',
          emoji: '📝',
          title: 'First Budget',
          description: 'Create your first budget.',
          target: 1,
          color: Color(0xFF4CAF50), // Green
        ),
        AwardBadge(
          id: 'budget_5',
          emoji: '📊',
          title: 'Budget Master',
          description: 'Create 5 budgets.',
          target: 5,
          color: Color(0xFF2196F3), // Blue
        ),
        AwardBadge(
          id: 'budget_kept_1',
          emoji: '🤓',
          title: 'Smart Spender',
          description: 'Stay under budget for one category.',
          target: 1,
          color: Color(0xFF00BCD4), // Cyan
        ),
        AwardBadge(
          id: 'budget_kept_10',
          emoji: '🧠',
          title: 'Mindful Money',
          description: 'Stay under budget 10 times.',
          target: 10,
          color: Color(0xFF3F51B5), // Indigo
        ),

        // Transactions Category
        AwardBadge(
          id: 'tx_10',
          emoji: '🧾',
          title: 'Receipt Collector',
          description: 'Log 10 transactions.',
          target: 10,
          color: Color(0xFF795548), // Brown
        ),
        AwardBadge(
          id: 'tx_50',
          emoji: '🛍️',
          title: 'Active Shopper',
          description: 'Log 50 transactions.',
          target: 50,
          color: Color(0xFFFF5722), // Deep Orange
        ),
        AwardBadge(
          id: 'tx_100',
          emoji: '🛒',
          title: 'Transaction Titan',
          description: 'Log 100 transactions.',
          target: 100,
          color: Color(0xFF607D8B), // Blue Grey
        ),

        // Streaks Category
        AwardBadge(
          id: 'streak_3',
          emoji: '🔥',
          title: 'On Fire',
          description: '3-day activity streak.',
          target: 3,
          color: Color(0xFFFF5252), // Red Accent
        ),
        AwardBadge(
          id: 'streak_7',
          emoji: '🗓️',
          title: 'Week Warrior',
          description: '7-day activity streak.',
          target: 7,
          color: Color(0xFF00E676), // Green Accent
        ),
        AwardBadge(
          id: 'streak_30',
          emoji: '📅',
          title: 'Monthly Master',
          description: '30-day activity streak.',
          target: 30,
          color: Color(0xFFE040FB), // Purple Accent
        ),

        // Savings Habits
        AwardBadge(
          id: 'save_100',
          emoji: '🐷',
          title: 'Piggy Banker',
          description: 'Save \$100.',
          target: 100,
          color: Color(0xFFF06292), // Light Pink
        ),
        AwardBadge(
          id: 'save_1000',
          emoji: '💰',
          title: 'Wealth Builder',
          description: 'Save \$1,000.',
          target: 1000,
          color: Color(0xFFFFD54F), // Amber
        ),
        AwardBadge(
          id: 'save_5000',
          emoji: '🏦',
          title: 'Vault Owner',
          description: 'Save \$5,000.',
          target: 5000,
          color: Color(0xFF8D6E63), // Brown
        ),

        // Spending Habits
        AwardBadge(
          id: 'frugal_fox',
          emoji: '🦊',
          title: 'Frugal Fox',
          description: 'No expenses for 3 days straight.',
          target: 3,
          color: Color(0xFFFF7043), // Deep Orange Light
        ),
        AwardBadge(
          id: 'weekend_saver',
          emoji: '🏖️',
          title: 'Weekend Saver',
          description: 'Zero spending on a weekend.',
          target: 1,
          color: Color(0xFF4DD0E1), // Cyan Light
        ),
        AwardBadge(
          id: 'no_dining_out',
          emoji: '🍳',
          title: 'Home Chef',
          description: 'No dining out expenses for a week.',
          target: 7,
          color: Color(0xFFAED581), // Light Green
        ),
        AwardBadge(
          id: 'better_month',
          emoji: '📈',
          title: 'Level Up',
          description: 'Spend less than last month.',
          target: 1,
          color: Color(0xFF81C784), // Green
        ),
        
        // Income
        AwardBadge(
          id: 'income_first',
          emoji: '💸',
          title: 'First Paycheck',
          description: 'Log your first income.',
          target: 1,
          color: Color(0xFF66BB6A), // Green
        ),
        AwardBadge(
          id: 'income_5',
          emoji: '🤑',
          title: 'Money Maker',
          description: 'Log 5 income sources.',
          target: 5,
          color: Color(0xFF26A69A), // Teal
        ),
        AwardBadge(
          id: 'side_hustle',
          emoji: '💼',
          title: 'Side Hustler',
          description: 'Log income outside of salary.',
          target: 1,
          color: Color(0xFF7E57C2), // Deep Purple
        ),

        // Social / Split
        AwardBadge(
          id: 'split_1',
          emoji: '🍕',
          title: 'Going Dutch',
          description: 'Split your first bill.',
          target: 1,
          color: Color(0xFFFFCA28), // Amber
        ),
        AwardBadge(
          id: 'split_10',
          emoji: '🤝',
          title: 'Fair Share',
          description: 'Split 10 bills.',
          target: 10,
          color: Color(0xFF8D6E63), // Brown
        ),

        // Random/Fun
        AwardBadge(
          id: 'night_owl',
          emoji: '🦉',
          title: 'Night Owl',
          description: 'Log an expense after midnight.',
          target: 1,
          color: Color(0xFF5C6BC0), // Indigo
        ),
        AwardBadge(
          id: 'early_bird',
          emoji: '🌅',
          title: 'Early Bird',
          description: 'Log an expense before 6 AM.',
          target: 1,
          color: Color(0xFFFFB74D), // Orange
        ),
        AwardBadge(
          id: 'explorer',
          emoji: '🧭',
          title: 'Quest Explorer',
          description: 'Unlock 15 badges.',
          target: 15,
          color: Color(0xFF90A4AE), // Blue Grey
        ),
      ];
}
