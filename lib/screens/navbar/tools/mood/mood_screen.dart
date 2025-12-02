import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quit_habit/providers/auth_provider.dart';
import 'package:quit_habit/services/goal_service.dart';
import 'package:quit_habit/utils/app_colors.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  String? _selectedMood;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasLoggedToday = false;

  final List<Map<String, dynamic>> _moods = [
    {'label': 'Happy', 'icon': Icons.sentiment_very_satisfied, 'color': Colors.green},
    {'label': 'Good', 'icon': Icons.sentiment_satisfied, 'color': Colors.lightGreen},
    {'label': 'Neutral', 'icon': Icons.sentiment_neutral, 'color': Colors.amber},
    {'label': 'Sad', 'icon': Icons.sentiment_dissatisfied, 'color': Colors.orange},
    {'label': 'Angry', 'icon': Icons.sentiment_very_dissatisfied, 'color': Colors.red},
    {'label': 'Stressed', 'icon': Icons.bolt, 'color': Colors.deepPurple},
  ];

  @override
  void initState() {
    super.initState();
    _checkIfLoggedToday();
  }

  Future<void> _checkIfLoggedToday() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final now = DateTime.now();
    // Create UTC start of day to match server timestamp consistency
    final startOfDay = DateTime.utc(now.year, now.month, now.day);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('moods')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .limit(1)
          .get();

      if (mounted) {
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            _hasLoggedToday = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking mood logs: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveMood() async {
    if (_selectedMood == null) return;

    setState(() => _isSaving = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user != null) {
      try {
        // Save to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('moods')
            .add({
          'mood': _selectedMood,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Update Goal (non-blocking)
        try {
          await GoalService().checkJournalingGoals(user.uid);
        } catch (goalError) {
          debugPrint('Failed to update goals: $goalError');
        }

        if (mounted) {
          setState(() {
            _hasLoggedToday = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mood logged! Keep it up.'),
              backgroundColor: AppColors.lightSuccess,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save mood: $e'),
              backgroundColor: AppColors.lightError,
            ),
          );
        }
      }
    }

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Mood Check-in',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.lightTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How are you feeling today?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tracking your mood helps you understand your triggers and progress.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 32),
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_hasLoggedToday)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightSuccess.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightSuccess),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.lightSuccess),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You have already logged your mood today. Great job!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.lightSuccess,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _moods.length,
                  itemBuilder: (context, index) {
                    final mood = _moods[index];
                    final isSelected = _selectedMood == mood['label'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMood = mood['label'];
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected ? (mood['color'] as Color).withOpacity(0.1) : AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? (mood['color'] as Color) : AppColors.lightBorder,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              mood['icon'] as IconData,
                              size: 48,
                              color: mood['color'] as Color,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              mood['label'] as String,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            if (!_hasLoggedToday)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedMood == null || _isSaving ? null : _saveMood,
                  child: _isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Mood',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
