import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quit_habit/providers/auth_provider.dart';
import 'package:quit_habit/services/goal_service.dart';
import 'package:quit_habit/utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  final List<Map<String, String>> _articles = [
    {
      'id': '1',
      'title': 'The Benefits of Quitting Smoking',
      'summary': 'Discover how your body heals after you stop smoking.',
      'content': 'Within 20 minutes, your heart rate and blood pressure drop. 12 hours later, the carbon monoxide level in your blood drops to normal. 2 weeks to 3 months later, your circulation improves and your lung function increases. 1 to 9 months later, coughing and shortness of breath decrease. 1 year later, the excess risk of coronary heart disease is half that of a continuing smoker\'s. 5 years later, risk of cancer of the mouth, throat, esophagus, and bladder is cut in half. Cervical cancer risk falls to that of a non-smoker. Stroke risk can fall to that of a non-smoker after 2-5 years. 10 years later, the risk of dying from lung cancer is about half that of a person who is still smoking. The risk of cancer of the larynx (voice box) and pancreas decreases. 15 years later, the risk of coronary heart disease is that of a non-smoker\'s.',
    },
    {
      'id': '2',
      'title': 'Managing Cravings',
      'summary': 'Tips and tricks to handle sudden urges to smoke.',
      'content': '1. Delay: If you feel like you are going to give in to your tobacco craving, tell yourself that you must first wait 10 more minutes. 2. Don\'t have "just one": You might be tempted to have just one cigarette to satisfy a tobacco craving. But don\'t fool yourself into believing that you can stop there. 3. Avoid triggers: Urges for tobacco are likely to be strongest in the situations where you smoked or chewed tobacco most often. 4. Get physical: Physical activity can help distract you from tobacco cravings and reduce their intensity. 5. Practice relaxation techniques: Smoking may have been your way to deal with stress. Fighting back against a tobacco craving can itself be stressful.',
    },
    {
      'id': '3',
      'title': 'Healthy Alternatives',
      'summary': 'Replace the habit with healthier choices.',
      'content': 'Chew on carrots, pickles, apples, celery, sugarless gum, or hard candy. Keep your mouth busy and stop the psychological need to smoke. Drink plenty of water. Keep your hands busy with a stress ball or a fidget spinner. Take deep breaths. Go for a walk. Call a friend. Read a book. Listen to music. Clean the house. Do a puzzle. Play a game. Write in a journal. Meditate. Do yoga. Take a nap. Take a shower. Brush your teeth.',
    },
    {
      'id': '4',
      'title': 'Understanding Nicotine Withdrawal',
      'summary': 'What to expect when you stop nicotine intake.',
      'content': 'Nicotine withdrawal is a group of symptoms that occur in the first few weeks after stopping or decreasing use of nicotine. Symptoms include intense cravings for nicotine, anger, irritability, frustration, anxiety, depression, difficulty concentrating, restlessness, insomnia, increased appetite, and weight gain. These symptoms are temporary and will fade over time. Remember that these feelings are a sign that your body is healing.',
    },
    {
      'id': '5',
      'title': 'Staying Motivated',
      'summary': 'Keep your eyes on the prize and stay smoke-free.',
      'content': 'Remind yourself why you quit. Calculate how much money you\'re saving. Reward yourself for reaching milestones. Lean on your support system. Avoid negative self-talk. Visualize yourself as a non-smoker. Focus on the benefits of quitting. Be patient with yourself. Celebrate your successes, no matter how small. Remember that every day smoke-free is a victory.',
    },
  ];

  Set<String> _readArticleIds = {};
  bool _isLoading = true;
  static Future<void> _prefsLock = Future.value();

  Future<void> _mutatePendingList(String userId, String articleId, bool isAdd) async {
    final completer = Completer<void>();
    final previousLock = _prefsLock;
    _prefsLock = completer.future;

    try {
      await previousLock;
      final prefs = await SharedPreferences.getInstance();
      final pendingKey = 'pending_goal_updates_$userId';
      final pendingIds = prefs.getStringList(pendingKey) ?? [];

      if (isAdd) {
        if (!pendingIds.contains(articleId)) {
          pendingIds.add(articleId);
          await prefs.setStringList(pendingKey, pendingIds);
        }
      } else {
        pendingIds.remove(articleId);
        if (pendingIds.isEmpty) {
          await prefs.remove(pendingKey);
        } else {
          await prefs.setStringList(pendingKey, pendingIds);
        }
      }
    } catch (e) {
      debugPrint('Error mutating pending list: $e');
    } finally {
      completer.complete();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadReadArticles();
  }

  Future<void> _loadReadArticles() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.uid;
    
    if (userId != null) {
      final key = 'read_articles_$userId';
      final List<String>? savedIds = prefs.getStringList(key);
      if (savedIds != null) {
        setState(() {
          _readArticleIds = savedIds.toSet();
        });
      }

      // Retry pending goal updates
      final pendingKey = 'pending_goal_updates_$userId';
      final List<String>? pendingIds = prefs.getStringList(pendingKey);
      
      if (pendingIds != null && pendingIds.isNotEmpty) {
        final List<String> remainingIds = List.from(pendingIds);
        final List<String> processedIds = [];

        for (final id in pendingIds) {
          try {
            // Process individually to avoid double counting on partial failures
            await GoalService().checkContentGoals(userId, 1);
            processedIds.add(id);
          } catch (e) {
            debugPrint('Failed to process pending article update for $id: $e');
          }
        }

        if (processedIds.isNotEmpty) {
          remainingIds.removeWhere((id) => processedIds.contains(id));
          
          if (remainingIds.isEmpty) {
            await prefs.remove(pendingKey);
          } else {
            await prefs.setStringList(pendingKey, remainingIds);
          }
          debugPrint('Successfully processed ${processedIds.length} pending article updates');
        }
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _markArticleAsRead(String articleId) async {
    if (_readArticleIds.contains(articleId)) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.uid;

    if (userId != null) {
      // 1. Immediate local update
      setState(() {
        _readArticleIds.add(articleId);
      });

      try {
        final prefs = await SharedPreferences.getInstance();
        final key = 'read_articles_$userId';
        
        // 2. Persist read state immediately
        final newReadIds = _readArticleIds.toList();
        await prefs.setStringList(key, newReadIds);

        // 3. Add to pending updates list (Serialized)
        await _mutatePendingList(userId, articleId, true);

        // 4. Attempt Goal Service update
        await GoalService().checkContentGoals(userId, 1);
        
        // 5. On success, remove from pending list (Serialized)
        await _mutatePendingList(userId, articleId, false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Article read! Progress updated.'),
              backgroundColor: AppColors.lightSuccess,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        // Goal service failed, but we already persisted the read state and pending update
        // It will be retried on next launch
        debugPrint('Goal update failed, queued for retry: $e');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Article marked as read. Goal progress will update shortly.'),
              backgroundColor: AppColors.lightTextSecondary,
            ),
          );
        }
      }
    }
  }

  void _openArticle(Map<String, String> article) {
    _markArticleAsRead(article['id']!);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                article['title']!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  child: Text(
                    article['content']!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.lightTextSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Health Resources',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _articles.length,
              itemBuilder: (context, index) {
                final article = _articles[index];
                final isRead = _readArticleIds.contains(article['id']);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  shadowColor: AppColors.black.withOpacity(0.05),
                  child: InkWell(
                    onTap: () => _openArticle(article),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isRead 
                                  ? AppColors.lightSuccess.withOpacity(0.1)
                                  : AppColors.lightPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isRead ? Icons.check_circle : Icons.article_rounded,
                              color: isRead ? AppColors.lightSuccess : AppColors.lightPrimary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  article['title']!,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  article['summary']!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.lightTextSecondary,
                                    fontSize: 13,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: AppColors.lightBorder,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
