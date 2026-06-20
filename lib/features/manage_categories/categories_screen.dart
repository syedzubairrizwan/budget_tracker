import 'package:budget_tracker/core/constants.dart';
import 'package:budget_tracker/features/manage_categories/add_category_screen.dart';
import 'package:budget_tracker/features/manage_categories/category_bloc.dart';
import 'package:budget_tracker/features/manage_categories/category_presets.dart';
import 'package:budget_tracker/models/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  // Track which preset groups are expanded
  final Set<String> _expandedGroups = {'Life'};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            _buildSearchBar(context, isDark),
            const SizedBox(height: 12),
            _buildSegmentedControl(context),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildExpenseTab(context, isDark),
                  _buildIncomeTab(context, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2F69FD), Color(0xFF1A6BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button if pushed as route
          if (Navigator.canPop(context))
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            )
          else
            const SizedBox(width: 48),
          Text(
            'Categories',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AddCategoryScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Search or type to find a category…',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          filled: true,
          fillColor: isDark ? AppColors.darkSurface : Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedControl(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 44,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorPadding: const EdgeInsets.all(4),
        indicator: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.primaryColor
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            if (Theme.of(context).brightness == Brightness.light)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        labelColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : AppColors.lightTextPrimary,
        unselectedLabelColor: Colors.grey,
        labelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        tabs: const [Tab(text: 'Expenses'), Tab(text: 'Income')],
      ),
    );
  }

  /// Build the Expense tab: preset groups + existing custom categories
  Widget _buildExpenseTab(BuildContext context, bool isDark) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final existing =
            state is CategoryLoaded ? state.categories : <Category>[];

        // Smart suggestion from search query
        final suggestion = _searchQuery.isNotEmpty
            ? CategoryPresets.suggestFromInput(_searchQuery)
            : null;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
          children: [
            // Search suggestion banner
            if (suggestion != null) ...[
              _buildSuggestionBanner(context, suggestion, isDark),
              const SizedBox(height: 12),
            ],

            // Preset groups accordion
            ...CategoryPresets.groups.entries.map((groupEntry) {
              return _buildGroupAccordion(
                  context, groupEntry.key, groupEntry.value, existing, isDark);
            }),

            // Custom / existing categories
            if (existing.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'My Categories',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              ...existing
                  .where((c) =>
                      _searchQuery.isEmpty ||
                      c.name.toLowerCase().contains(_searchQuery))
                  .map((c) => _buildExistingCategoryTile(context, c, isDark)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildIncomeTab(BuildContext context, bool isDark) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final existing =
            state is CategoryLoaded ? state.categories : <Category>[];

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          children: [
            // Income presets (simplified)
            _buildSimplePresetGroup(
              context,
              'Income Sources',
              '💰',
              const Color(0xFF2E7D32),
              [
                ('Salary', '💼', '#1B5E20'),
                ('Freelance', '💻', '#1565C0'),
                ('Business', '🏢', '#4A148C'),
                ('Investment', '📈', '#006064'),
                ('Rental', '🏠', '#E65100'),
                ('Bonus', '🎉', '#880E4F'),
                ('Other Income', '✅', '#37474F'),
              ],
              existing,
              isDark,
            ),
            const SizedBox(height: 8),
            if (existing.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'My Categories',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              ...existing
                  .where((c) =>
                      _searchQuery.isEmpty ||
                      c.name.toLowerCase().contains(_searchQuery))
                  .map((c) => _buildExistingCategoryTile(context, c, isDark)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSuggestionBanner(
      BuildContext context, (String, String) suggestion, bool isDark) {
    final (group, sub) = suggestion;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withValues(alpha: 0.15),
            AppColors.primaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded,
              color: AppColors.primaryColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Smart Suggestion',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.primaryColor)),
                Text(
                  '"$_searchQuery" matches $group › $sub',
                  style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () =>
                _quickAddPreset(context, sub, '⭐', '#2F69FD'),
            child: const Text('Quick Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupAccordion(
    BuildContext context,
    String groupName,
    List<(String, String, String)> subcategories,
    List<Category> existing,
    bool isDark,
  ) {
    final gradients = CategoryPresets.groupGradients[groupName];
    final c1 = gradients != null ? Color(gradients.$1) : AppColors.primaryColor;
    final c2 = gradients != null ? Color(gradients.$2) : AppColors.primaryColor;
    final isExpanded = _expandedGroups.contains(groupName);

    // Filter subcategories by search
    final filtered = _searchQuery.isEmpty
        ? subcategories
        : subcategories
            .where((s) => s.$1.toLowerCase().contains(_searchQuery))
            .toList();

    if (_searchQuery.isNotEmpty && filtered.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Group header
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() {
              if (isExpanded) {
                _expandedGroups.remove(groupName);
              } else {
                _expandedGroups.add(groupName);
              }
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    c1.withValues(alpha: 0.12),
                    c2.withValues(alpha: 0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [c1, c2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        _groupEmoji(groupName),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          groupName,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${subcategories.length} subcategories',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          // Subcategory chips
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filtered.map((sub) {
                  final alreadyAdded = existing.any(
                      (c) => c.name.toLowerCase() == sub.$1.toLowerCase());
                  return _SubcategoryChip(
                    name: sub.$1,
                    emoji: sub.$2,
                    hexColor: sub.$3,
                    alreadyAdded: alreadyAdded,
                    onAdd: () =>
                        _quickAddPreset(context, sub.$1, sub.$2, sub.$3),
                  );
                }).toList(),
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildSimplePresetGroup(
    BuildContext context,
    String groupName,
    String emoji,
    Color color,
    List<(String, String, String)> subcategories,
    List<Category> existing,
    bool isDark,
  ) {
    final filtered = _searchQuery.isEmpty
        ? subcategories
        : subcategories
            .where((s) => s.$1.toLowerCase().contains(_searchQuery))
            .toList();
    if (filtered.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 10),
              Text(groupName,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filtered.map((sub) {
              final alreadyAdded = existing.any(
                  (c) => c.name.toLowerCase() == sub.$1.toLowerCase());
              return _SubcategoryChip(
                name: sub.$1,
                emoji: sub.$2,
                hexColor: sub.$3,
                alreadyAdded: alreadyAdded,
                onAdd: () =>
                    _quickAddPreset(context, sub.$1, sub.$2, sub.$3),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingCategoryTile(
      BuildContext context, Category category, bool isDark) {
    if (_searchQuery.isNotEmpty &&
        !category.name.toLowerCase().contains(_searchQuery)) {
      return const SizedBox.shrink();
    }
    final catColor = Color(
        int.parse(category.color.replaceAll('#', ''), radix: 16) + 0xFF000000);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: catColor.withValues(alpha: 0.15),
          child: Text(category.icon, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(category.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AddCategoryScreen(category: category)),
              ),
            ),
            IconButton(
              icon:
                  const Icon(Icons.delete_outline, size: 18, color: Colors.red),
              onPressed: () => _confirmDelete(context, category),
            ),
          ],
        ),
      ),
    );
  }

  void _quickAddPreset(
      BuildContext context, String name, String emoji, String hexColor) async {
    final state = context.read<CategoryBloc>().state;
    if (state is CategoryLoaded) {
      final already = state.categories.any(
          (c) => c.name.toLowerCase() == name.toLowerCase());
      if (already) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"$name" is already in your categories.')),
        );
        return;
      }
    }
    final color = hexColor.replaceAll('#', '');
    context.read<CategoryBloc>().add(
          AddCategory(
            category: Category(
              id: const Uuid().v4(),
              name: name,
              icon: emoji,
              color: color,
            ),
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$emoji $name added to categories!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _confirmDelete(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
            'Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context
                  .read<CategoryBloc>()
                  .add(DeleteCategory(id: category.id));
              Navigator.pop(ctx);
            },
            child:
                const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _groupEmoji(String groupName) {
    switch (groupName) {
      case 'Life':
        return '🏠';
      case 'Entertainment':
        return '🎭';
      case 'Food & Drinks':
        return '🍔';
      case 'Utilities':
        return '⚡';
      case 'Transportation':
        return '🚗';
      default:
        return '📦';
    }
  }
}

class _SubcategoryChip extends StatelessWidget {
  final String name;
  final String emoji;
  final String hexColor;
  final bool alreadyAdded;
  final VoidCallback onAdd;

  const _SubcategoryChip({
    required this.name,
    required this.emoji,
    required this.hexColor,
    required this.alreadyAdded,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(
        int.parse(hexColor.replaceAll('#', ''), radix: 16) + 0xFF000000);

    return GestureDetector(
      onTap: alreadyAdded ? null : onAdd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: alreadyAdded
              ? Colors.green.withValues(alpha: 0.1)
              : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: alreadyAdded
                ? Colors.green.withValues(alpha: 0.5)
                : color.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: alreadyAdded ? Colors.green[700] : color,
              ),
            ),
            if (alreadyAdded) ...[
              const SizedBox(width: 4),
              Icon(Icons.check_circle_rounded,
                  size: 12, color: Colors.green[700]),
            ] else ...[
              const SizedBox(width: 4),
              Icon(Icons.add_rounded, size: 12, color: color),
            ],
          ],
        ),
      ),
    );
  }
}
