import 'package:quit_habit/models/plan_mission.dart';

/// Helper to generate zero-padded day IDs for proper Firestore sorting
/// e.g., day_01, day_02, ... day_90
String _dayId(int day) => 'day_${day.toString().padLeft(2, '0')}';

/// All 90 days of plan missions
/// Milestones are only on phase-end days: Day 7, 21, 66, 90
List<PlanMission> getAllPlanMissions() {
  return [
    // ============ PHASE 1: Awareness & Analysis (Days 1-7) ============
    PlanMission(
      id: _dayId(1),
      dayNumber: 1,
      phase: PlanPhaseType.awareness,
      missionTitle: 'The Commitment Contract',
      missionDescription: 'Begin the journey with a serious commitment.',
      tasks: [
        'Sign your Non-Smoker Commitment Contract inside the app.',
        'Set your "Quit Date" (usually Day 7).',
        'Read your commitment out loud once: "I am starting a new life without smoking."',
      ],
      reflectionQuestions: [
        'Why is now the right time to quit?',
      ],
      requiresContract: true,
    ),
    PlanMission(
      id: _dayId(2),
      dayNumber: 2,
      phase: PlanPhaseType.awareness,
      missionTitle: 'The "Why" Stack',
      missionDescription: 'Find your deepest motivation for quitting.',
      tasks: [
        'Write 5 reasons you want to quit smoking.',
        'For each reason, ask "Why?" three times to reveal the root cause.',
        'Choose one master WHY to focus on.',
      ],
      reflectionQuestions: [
        'Which "Why" hit you emotionally the most?',
        'How will life improve smoke-free?',
      ],
    ),
    PlanMission(
      id: _dayId(3),
      dayNumber: 3,
      phase: PlanPhaseType.awareness,
      missionTitle: 'Trigger Hunting',
      missionDescription: 'Start tracking every craving.',
      tasks: [
        'Every time you feel the urge to smoke, tap "Log Craving."',
        'Record: Time, place, emotion, what you were doing.',
        'Do NOT try to quit today — just observe.',
      ],
      reflectionQuestions: [
        'What was the most common trigger? (stress, boredom, after eating, social?)',
      ],
    ),
    PlanMission(
      id: _dayId(4),
      dayNumber: 4,
      phase: PlanPhaseType.awareness,
      missionTitle: 'Reward Analysis',
      missionDescription: 'Understand what smoking actually gives you.',
      tasks: [
        'After each cigarette, log what you felt afterward (relief, calm, social comfort, break, boredom escape).',
        'Add a quick note: Did smoking truly fix the problem?',
        'Identify at least one need the cigarette is replacing.',
      ],
      reflectionQuestions: [
        'What emotional need does smoking fulfill for you?',
      ],
    ),
    PlanMission(
      id: _dayId(5),
      dayNumber: 5,
      phase: PlanPhaseType.awareness,
      missionTitle: 'Environmental Audit',
      missionDescription: 'Remove cues that trigger you to smoke.',
      tasks: [
        'Hide cigarettes, lighters, ashtrays from visible places.',
        'Avoid visiting your "smoking spots" today.',
        'Clean your car/room to remove smoke smell.',
        'Reduce exposure to smokers (if possible).',
      ],
      reflectionQuestions: [
        'Which cue was the strongest trigger?',
        'How did removing cues affect cravings?',
      ],
    ),
    PlanMission(
      id: _dayId(6),
      dayNumber: 6,
      phase: PlanPhaseType.awareness,
      missionTitle: 'The Replacement Plan',
      missionDescription: 'Choose a healthier action to perform when cravings strike.',
      tasks: [
        'Select ONE replacement action: Drink water, 5 deep breaths, Chewing gum, Short walk, or Brush teeth.',
        'Practice doing this once before smoking.',
        'Add this to your "If → Then" plan. Example: If I feel the urge, then I take 5 deep breaths.',
      ],
      reflectionQuestions: [
        'Which replacement action felt most natural?',
      ],
    ),
    PlanMission(
      id: _dayId(7),
      dayNumber: 7,
      phase: PlanPhaseType.awareness,
      missionTitle: 'The Last Hurrah (or Quit Day)',
      missionDescription: 'Mark the transition point.',
      tasks: [
        'Choose: Mindful Final Cigarette OR Quit Day Ceremony',
        'If final cigarette: Smoke slowly and mindfully, notice the smell, taste, throat hit, observe if it actually feels good.',
        'If ceremony: Throw away remaining cigarettes, declare "Today, I stop smoking."',
        'Review your WHY list and triggers from Days 3–5.',
        'Visualize tomorrow without smoking.',
      ],
      reflectionQuestions: [
        'Did smoking feel different today?',
        'Are you mentally ready for the Detox Phase?',
      ],
      isMilestone: true,
      badgeId: 'phase_1_awareness',
    ),

    // ============ PHASE 2: Detox & Pattern Interrupt (Days 8-21) ============
    PlanMission(
      id: _dayId(8),
      dayNumber: 8,
      phase: PlanPhaseType.detox,
      missionTitle: 'Friction Challenge (Part 1)',
      missionDescription: 'Make smoking slightly harder today.',
      tasks: [
        'Put your cigarettes in another room.',
        'Place your lighter in a drawer or zip bag.',
        'Each time you want to smoke, delay by 20 seconds before deciding.',
        'Log your urges (time, place, emotion).',
      ],
      reflectionQuestions: [
        'What did delaying 20 seconds feel like?',
        'Did any cravings fade before you smoked?',
      ],
    ),
    PlanMission(
      id: _dayId(9),
      dayNumber: 9,
      phase: PlanPhaseType.detox,
      missionTitle: 'Friction Challenge (Part 2)',
      missionDescription: 'Increase the friction even more.',
      tasks: [
        'Wrap a rubber band around the cigarette pack.',
        'Keep your lighter in a hard-to-access spot (backpack, top shelf).',
        'Before smoking, force yourself to walk to another room first.',
        'Log every craving spike.',
      ],
      reflectionQuestions: [
        'Did friction reduce the number of cigarettes today?',
        'Which friction method worked best?',
      ],
    ),
    PlanMission(
      id: _dayId(10),
      dayNumber: 10,
      phase: PlanPhaseType.detox,
      missionTitle: 'Friction Challenge (Part 3)',
      missionDescription: 'Max friction. Make smoking inconvenient.',
      tasks: [
        'Store cigarettes in a sealed box or container.',
        'Keep all smoking-related items out of sight.',
        'Wait 60 seconds before each cigarette. Use the timer.',
        'Track cravings duration.',
      ],
      reflectionQuestions: [
        'How many cravings disappeared during the 60-second delay?',
        'Are you feeling more aware of your cues?',
      ],
    ),
    PlanMission(
      id: _dayId(11),
      dayNumber: 11,
      phase: PlanPhaseType.detox,
      missionTitle: 'Urge Surfing Day',
      missionDescription: 'Learn to "ride the wave" instead of reacting.',
      tasks: [
        'When a craving hits, open the 3-minute Urge Surf Audio.',
        'Practice breathing through the urge.',
        'Only decide after the urge passes.',
        'Log urge peak + fall.',
      ],
      reflectionQuestions: [
        'Did the urge pass without smoking?',
        'How long did the peak last?',
      ],
    ),
    PlanMission(
      id: _dayId(12),
      dayNumber: 12,
      phase: PlanPhaseType.detox,
      missionTitle: 'Identity Shift Begins',
      missionDescription: 'Start reprogramming your identity.',
      tasks: [
        'Write once: "I am a non-smoker."',
        'Read your WHY list.',
        'Mark one smoking trigger you overcame today.',
        'Decline one opportunity to smoke.',
      ],
      reflectionQuestions: [
        'Did calling yourself a non-smoker change behavior?',
      ],
    ),
    PlanMission(
      id: _dayId(13),
      dayNumber: 13,
      phase: PlanPhaseType.detox,
      missionTitle: 'Strengthen the Identity',
      missionDescription: 'Build belief in your new non-smoker identity.',
      tasks: [
        'Repeat 3 times today: "I don\'t smoke."',
        'Replace one smoking situation with your replacement habit (water, walk, deep breaths).',
        'Log every urge.',
      ],
      reflectionQuestions: [
        'Which situation was easiest to skip smoking?',
        'Do you feel any mental shift?',
      ],
    ),
    PlanMission(
      id: _dayId(14),
      dayNumber: 14,
      phase: PlanPhaseType.detox,
      missionTitle: 'Identity Lock-In',
      missionDescription: 'Commit mentally: You are becoming a non-smoker.',
      tasks: [
        'Journal: "What does a non-smoker version of me look like?"',
        'Avoid smoking in 1 environment where you normally smoke (car, balcony, break area).',
        'Use replacement action once.',
      ],
      reflectionQuestions: [
        'Who are you now compared to Day 1?',
      ],
    ),
    PlanMission(
      id: _dayId(15),
      dayNumber: 15,
      phase: PlanPhaseType.detox,
      missionTitle: 'NOT ONE PUFF RULE BEGINS',
      missionDescription: 'Absolute zero smoking. Not even a single puff.',
      tasks: [
        'Morning check-in: "I commit to NO PUFFS today."',
        'Use urge surfing at least once.',
        'Replace 1 smoking moment with a healthy action.',
        'Evening check-in.',
      ],
      reflectionQuestions: [
        'How did your body respond without nicotine today?',
      ],
    ),
    PlanMission(
      id: _dayId(16),
      dayNumber: 16,
      phase: PlanPhaseType.detox,
      missionTitle: 'Zero Puff Reinforcement',
      missionDescription: 'Continue 100% abstinence.',
      tasks: [
        'Avoid one major trigger you identified in Phase 1.',
        'Take a 2-minute walk instead of smoking.',
        'Drink a full glass of water during cravings.',
        'Log cravings intensity.',
      ],
      reflectionQuestions: [
        'Which craving was strongest? What helped reduce it?',
      ],
    ),
    PlanMission(
      id: _dayId(17),
      dayNumber: 17,
      phase: PlanPhaseType.detox,
      missionTitle: 'Dopamine Reset Day',
      missionDescription: 'Counter withdrawal with healthy dopamine.',
      tasks: [
        'Choose one positive dopamine activity: walk, music, sunlight, stretching.',
        'Avoid all smoking spots for the day.',
        'Resist every urge using urge surfing.',
      ],
      reflectionQuestions: [
        'Did positive activities help stabilize energy?',
      ],
    ),
    PlanMission(
      id: _dayId(18),
      dayNumber: 18,
      phase: PlanPhaseType.detox,
      missionTitle: 'Breaking Rituals',
      missionDescription: 'Break routines linked to smoking.',
      tasks: [
        'Change one daily routine: coffee mug → tea glass, walk route, break timing.',
        'Remove one smoking cue from your surroundings.',
        'Practice your replacement action at least twice.',
      ],
      reflectionQuestions: [
        'Which old routine triggered smoking the most?',
      ],
    ),
    PlanMission(
      id: _dayId(19),
      dayNumber: 19,
      phase: PlanPhaseType.detox,
      missionTitle: 'Craving Mastery',
      missionDescription: 'Build mastery over urges.',
      tasks: [
        'Label each craving: stress, boredom, habit, social.',
        'Practice 5 deep breaths during each urge.',
        'Avoid all smokers for today (if possible).',
        'Track your mood.',
      ],
      reflectionQuestions: [
        'What type of craving was most common?',
      ],
    ),
    PlanMission(
      id: _dayId(20),
      dayNumber: 20,
      phase: PlanPhaseType.detox,
      missionTitle: 'Mental Strength Day',
      missionDescription: 'Strengthen mental resistance.',
      tasks: [
        'Watch a 1-minute motivational clip inside the app.',
        'Look at your streak and money saved.',
        'Consciously say no to one old smoking trigger.',
        'Use urge surf once.',
      ],
      reflectionQuestions: [
        'What are you proud of today?',
      ],
    ),
    PlanMission(
      id: _dayId(21),
      dayNumber: 21,
      phase: PlanPhaseType.detox,
      missionTitle: 'End of Detox Phase',
      missionDescription: 'Finish the hardest phase. Celebrate.',
      tasks: [
        'Write: "21 days without nicotine."',
        'Take a photo (self-progress).',
        'Compare your breathing/energy with Day 1.',
        'Mark all triggers you overcame.',
      ],
      reflectionQuestions: [
        'What changed the most in the past 21 days?',
        'What do you want to protect moving forward?',
      ],
      isMilestone: true,
      badgeId: 'phase_2_detox',
    ),

    // ============ PHASE 3: Rewiring & Resilience (Days 22-66) ============
    PlanMission(
      id: _dayId(22),
      dayNumber: 22,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Identify Your Stress Triggers',
      missionDescription: 'Stress is the #1 relapse trigger. Start building emotional resilience.',
      tasks: [
        'List top 3 stress triggers (work, family, boredom, deadlines).',
        'Note how each one used to push you to smoke.',
      ],
      reflectionQuestions: [
        'Which trigger hits you most often?',
      ],
    ),
    PlanMission(
      id: _dayId(23),
      dayNumber: 23,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Build Your Stress Coping Menu',
      missionDescription: 'Create healthy alternatives for stress.',
      tasks: [
        'Choose five healthy alternatives: walk, water, deep breaths, stretching, cold splash.',
        'Save them as quick buttons in the app.',
      ],
      reflectionQuestions: [
        'Which alternative feels most realistic for you?',
      ],
    ),
    PlanMission(
      id: _dayId(24),
      dayNumber: 24,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Replace 1 Stress Habit',
      missionDescription: 'Practice replacing stress with healthy action.',
      tasks: [
        'Whenever stress hits, immediately do alternative #1 from your list.',
        'Log stress → action in the app.',
      ],
      reflectionQuestions: [
        'Did replacing the habit work today?',
      ],
    ),
    PlanMission(
      id: _dayId(25),
      dayNumber: 25,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Pre-Stress Planning',
      missionDescription: 'Plan your response to stressful moments.',
      tasks: [
        'Predict 3 stressful moments that may happen today.',
        'Assign each one a coping action.',
      ],
      reflectionQuestions: [
        'Did planning reduce your cravings?',
      ],
    ),
    PlanMission(
      id: _dayId(26),
      dayNumber: 26,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Build Emotional Awareness',
      missionDescription: 'Label feelings to reduce craving intensity.',
      tasks: [
        'Every time you feel tension, label the feeling ("I\'m anxious," "I\'m irritated").',
        'This reduces craving intensity by 30–40%.',
      ],
      reflectionQuestions: [
        'What emotion triggered the biggest urge?',
      ],
    ),
    PlanMission(
      id: _dayId(27),
      dayNumber: 27,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Break the Stress-Smoking Link',
      missionDescription: 'Delay smoking urges during stress.',
      tasks: [
        'During stress, delay smoking urge by 5 minutes.',
        'Do deep breathing for those 5 minutes.',
      ],
      reflectionQuestions: [
        'Did delaying make the urge weaker?',
      ],
    ),
    PlanMission(
      id: _dayId(28),
      dayNumber: 28,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Body Stress Reset',
      missionDescription: 'Reset your stress physically.',
      tasks: [
        '10-minute walk.',
        '2 minutes deep breathing.',
        'Drink one full glass of water.',
      ],
      reflectionQuestions: [
        'How did your body respond?',
      ],
    ),
    PlanMission(
      id: _dayId(29),
      dayNumber: 29,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Cognitive Reframe',
      missionDescription: 'Replace false beliefs about smoking.',
      tasks: [
        'Re-write this belief: "Smoking calms me down."',
        'Replace it with truth: "Nicotine causes stress; quitting removes stress."',
      ],
      reflectionQuestions: [
        'Which truth felt strongest?',
      ],
    ),
    PlanMission(
      id: _dayId(30),
      dayNumber: 30,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Stress Mastery Checkpoint',
      missionDescription: 'Review your stress logs and lock in your best coping method.',
      tasks: [
        'Review your stress logs for a week.',
        'Choose your best coping action and lock it as "Primary Response."',
        'Set a goal: "Next target: Day 40."',
      ],
      reflectionQuestions: [
        'Which coping method will you rely on next month?',
      ],
    ),
    PlanMission(
      id: _dayId(31),
      dayNumber: 31,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Meet Your Streak',
      missionDescription: 'Connect with your progress.',
      tasks: [
        'Look at your streak counter for at least 10 seconds.',
        'Tap "I choose to protect this streak today."',
      ],
      reflectionQuestions: [
        'What emotion did you feel seeing your streak?',
      ],
    ),
    PlanMission(
      id: _dayId(32),
      dayNumber: 32,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Don\'t Break the Chain',
      missionDescription: 'Keep the momentum going.',
      tasks: [
        'Pick ONE tiny healthy action to keep your chain intact (walk 2 minutes, drink water, chew gum).',
        'Mark your streak in the app.',
      ],
      reflectionQuestions: [
        'What was the easiest action you used?',
      ],
    ),
    PlanMission(
      id: _dayId(33),
      dayNumber: 33,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Strengthen Motivation',
      missionDescription: 'Visualize the cost of relapse.',
      tasks: [
        'Write: "If I smoke today, I lose ___ days of progress."',
        'Re-read it once during the day.',
      ],
      reflectionQuestions: [
        'Did this thought stop a craving today?',
      ],
    ),
    PlanMission(
      id: _dayId(34),
      dayNumber: 34,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Visual Reward Setup',
      missionDescription: 'Plan a reward for Day 40.',
      tasks: [
        'Open "Money Saved" and check your total.',
        'Set a reward for Day 40 (snack, movie, small purchase).',
      ],
      reflectionQuestions: [
        'What reward motivates you most?',
      ],
    ),
    PlanMission(
      id: _dayId(35),
      dayNumber: 35,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Screenshot Your Victory',
      missionDescription: 'Capture your progress.',
      tasks: [
        'Take a screenshot of your streak counter.',
        'Write 1 sentence: "I earned every day on this streak."',
      ],
      reflectionQuestions: [
        'What part of your streak are you proud of?',
      ],
    ),
    PlanMission(
      id: _dayId(36),
      dayNumber: 36,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Craving Pattern Discovery',
      missionDescription: 'Find your peak craving times.',
      tasks: [
        'Log every craving today (time + place).',
        'Let the app show your "peak craving hour."',
      ],
      reflectionQuestions: [
        'What was your strongest craving time today?',
      ],
    ),
    PlanMission(
      id: _dayId(37),
      dayNumber: 37,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Counter-Action Planning',
      missionDescription: 'Plan substitute actions for peak craving times.',
      tasks: [
        'For your peak craving time, plan a substitute action (e.g., 5 deep breaths at 4 pm).',
        'Perform it when the craving hits.',
      ],
      reflectionQuestions: [
        'Did the counter-action reduce the urge?',
      ],
    ),
    PlanMission(
      id: _dayId(38),
      dayNumber: 38,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'New Routine Installation',
      missionDescription: 'Build a new healthy habit.',
      tasks: [
        'Choose ONE healthy habit to repeat daily (evening walk, green tea, cold splash).',
        'Do it today.',
      ],
      reflectionQuestions: [
        'How did the new habit feel?',
      ],
    ),
    PlanMission(
      id: _dayId(39),
      dayNumber: 39,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Strength Through Repetition',
      missionDescription: 'Strengthen the habit through repetition.',
      tasks: [
        'Do the new habit TWICE today (morning + evening).',
        'Mark both in the app.',
      ],
      reflectionQuestions: [
        'Did repeating make the habit easier?',
      ],
    ),
    PlanMission(
      id: _dayId(40),
      dayNumber: 40,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Reward Day',
      missionDescription: 'Celebrate your progress!',
      tasks: [
        'Claim the reward you planned on Day 34.',
        'Take 30 seconds to admire your streak.',
      ],
      reflectionQuestions: [
        'How does celebrating smoke-free success feel?',
      ],
    ),
    PlanMission(
      id: _dayId(41),
      dayNumber: 41,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Identity Lock-In',
      missionDescription: 'Reinforce your non-smoker identity.',
      tasks: [
        'Write the sentence: "I am a non-smoker, and my actions today will match that identity."',
        'Read it once in the morning and once at night.',
      ],
      reflectionQuestions: [
        'When did you most feel like a non-smoker today?',
      ],
    ),
    PlanMission(
      id: _dayId(42),
      dayNumber: 42,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Trigger Removal Upgrade',
      missionDescription: 'Remove leftover triggers.',
      tasks: [
        'Identify one leftover smoking trigger in your environment (old lighter, ashtray, habitual spot).',
        'Remove, replace, or relocate it.',
      ],
      reflectionQuestions: [
        'Which trigger did you remove and how did it feel?',
      ],
    ),
    PlanMission(
      id: _dayId(43),
      dayNumber: 43,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Social Strengthening',
      missionDescription: 'Share your progress with someone.',
      tasks: [
        'Tell one person you trust that you\'re on Day 43 and smoke-free.',
        'Ask them to check in with you once this week.',
      ],
      reflectionQuestions: [
        'How did sharing your progress affect your motivation?',
      ],
    ),
    PlanMission(
      id: _dayId(44),
      dayNumber: 44,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Stress-Proofing',
      missionDescription: 'Practice stress relief proactively.',
      tasks: [
        'Practice one stress-relief skill today (deep breathing, stretching, quick walk, music).',
        'Use it at least once when you don\'t feel stressed to build the habit.',
      ],
      reflectionQuestions: [
        'Which stress tool worked best for you today?',
      ],
    ),
    PlanMission(
      id: _dayId(45),
      dayNumber: 45,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Halfway Review to 90 Days',
      missionDescription: 'Celebrate being halfway there!',
      tasks: [
        'Open your streak + money saved + health stats.',
        'Write down three benefits you\'ve noticed since quitting.',
      ],
      reflectionQuestions: [
        'Which benefit feels the most meaningful to you right now?',
      ],
    ),
    PlanMission(
      id: _dayId(46),
      dayNumber: 46,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Craving Confidence Training',
      missionDescription: 'Build confidence in handling cravings.',
      tasks: [
        'When a craving appears, say: "This is temporary. I know exactly what to do."',
        'Use a 30-second delay technique before doing anything else.',
      ],
      reflectionQuestions: [
        'Did the delay technique weaken the craving?',
      ],
    ),
    PlanMission(
      id: _dayId(47),
      dayNumber: 47,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Habit Expansion',
      missionDescription: 'Strengthen your healthy habits.',
      tasks: [
        'Add one small improvement to the healthy habit you chose earlier (longer walk, extra water, longer stretch).',
        'Do it today.',
      ],
      reflectionQuestions: [
        'How did upgrading your habit change how you felt?',
      ],
    ),
    PlanMission(
      id: _dayId(48),
      dayNumber: 48,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Future-Self Motivation',
      missionDescription: 'Connect with your future self.',
      tasks: [
        'Write a short message to your Day-60 self about why this streak matters.',
        'Save it or screenshot it so you can read it later.',
      ],
      reflectionQuestions: [
        'What did you want your future self to remember most?',
      ],
    ),
    PlanMission(
      id: _dayId(49),
      dayNumber: 49,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Craving Mastery Check',
      missionDescription: 'Analyze the craving chain.',
      tasks: [
        'Log any craving today (even if very small).',
        'Identify the trigger → thought → action pattern.',
        'Choose one part of the chain you can break next time.',
      ],
      reflectionQuestions: [
        'Which part of the craving chain is easiest for you to interrupt?',
      ],
    ),
    PlanMission(
      id: _dayId(50),
      dayNumber: 50,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Milestone Celebration',
      missionDescription: 'Celebrate 50 days smoke-free!',
      tasks: [
        'Take a screenshot of your Day 50 streak.',
        'Choose one uplifting way to celebrate (favorite snack, relaxing time, treat, small reward).',
        'Spend 30 seconds appreciating how far you\'ve come.',
      ],
      reflectionQuestions: [
        'What does reaching 50 smoke-free days mean to you?',
      ],
      isMilestone: true,
      badgeId: 'milestone_50_days',
    ),
    PlanMission(
      id: _dayId(51),
      dayNumber: 51,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Strengthen Your "Why"',
      missionDescription: 'Reconnect with your motivation.',
      tasks: [
        'Rewrite your quit "WHY" in one clear sentence.',
        'Put it somewhere you\'ll see it today (notes app, lock screen, paper).',
      ],
      reflectionQuestions: [
        'What part of your "why" felt strongest today?',
      ],
    ),
    PlanMission(
      id: _dayId(52),
      dayNumber: 52,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Energy Boost Check-In',
      missionDescription: 'Notice the physical improvements.',
      tasks: [
        'Do one activity that boosts your energy (light exercise, hydration, fresh air).',
        'Notice any positive body changes since quitting.',
      ],
      reflectionQuestions: [
        'What improvement in your energy or breathing did you notice?',
      ],
    ),
    PlanMission(
      id: _dayId(53),
      dayNumber: 53,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Remove a Mental Block',
      missionDescription: 'Address lingering fears.',
      tasks: [
        'Write down one lingering fear about staying smoke-free.',
        'Replace it with a realistic, empowering belief.',
      ],
      reflectionQuestions: [
        'What belief helped you feel more confident today?',
      ],
    ),
    PlanMission(
      id: _dayId(54),
      dayNumber: 54,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Build a Craving Escape Route',
      missionDescription: 'Plan your escape from sudden cravings.',
      tasks: [
        'Plan one specific action to escape sudden cravings (go outside, drink water, text someone).',
        'Use it at least once today, even during a mild urge.',
      ],
      reflectionQuestions: [
        'Did having a clear plan help your confidence?',
      ],
    ),
    PlanMission(
      id: _dayId(55),
      dayNumber: 55,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Check Your Health Wins',
      missionDescription: 'Celebrate your health improvements.',
      tasks: [
        'Review your health progress (breathing, stamina, smell, sleep, skin, mood).',
        'Write down two improvements you want to keep building.',
      ],
      reflectionQuestions: [
        'Which health win surprised you most?',
      ],
    ),
    PlanMission(
      id: _dayId(56),
      dayNumber: 56,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Habit Double Down',
      missionDescription: 'Reinforce your habits.',
      tasks: [
        'Choose one positive habit from the last weeks.',
        'Do it twice today (morning + evening) to reinforce it.',
      ],
      reflectionQuestions: [
        'Did repeating the habit make it feel more natural?',
      ],
    ),
    PlanMission(
      id: _dayId(57),
      dayNumber: 57,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Empowering Self-Talk',
      missionDescription: 'Use affirmations to build strength.',
      tasks: [
        'Say this sentence once in the morning: "I\'m stronger than every craving I\'ve ever had."',
        'Say it again before bed.',
      ],
      reflectionQuestions: [
        'Did this sentence shift how you felt about cravings?',
      ],
    ),
    PlanMission(
      id: _dayId(58),
      dayNumber: 58,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Reward Preview',
      missionDescription: 'Plan your Day 60 celebration.',
      tasks: [
        'Look at your money saved or health progress.',
        'Plan a Day 60 reward (small treat, experience, comfort, relaxation).',
        'Visualize enjoying it.',
      ],
      reflectionQuestions: [
        'What reward did you choose and why?',
      ],
    ),
    PlanMission(
      id: _dayId(59),
      dayNumber: 59,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Consistency Over Intensity',
      missionDescription: 'Focus on small consistent actions.',
      tasks: [
        'Pick one small healthy action and repeat it throughout the day (water, stretching, 1-minute walk).',
        'Keep it light — focus on consistency.',
      ],
      reflectionQuestions: [
        'Which action was easiest to stay consistent with?',
      ],
    ),
    PlanMission(
      id: _dayId(60),
      dayNumber: 60,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Major Milestone Celebration',
      missionDescription: 'Celebrate 60 days smoke-free!',
      tasks: [
        'Celebrate with the reward you planned yesterday.',
        'Open your streak and take 30 seconds to acknowledge your achievement.',
        'Save or screenshot your Day 60 progress.',
      ],
      reflectionQuestions: [
        'What does reaching 60 days smoke-free say about who you are becoming?',
      ],
    ),
    PlanMission(
      id: _dayId(61),
      dayNumber: 61,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Deep Craving Insight',
      missionDescription: 'Understand your craving types.',
      tasks: [
        'Notice any cravings today and label each one: physical, emotional, or habit-based.',
        'Write a short note on which type appears most.',
      ],
      reflectionQuestions: [
        'Which type of craving showed up the most today?',
      ],
    ),
    PlanMission(
      id: _dayId(62),
      dayNumber: 62,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Resilience Rehearsal',
      missionDescription: 'Mentally rehearse handling tough situations.',
      tasks: [
        'Imagine a tough situation (stress, social event, boredom).',
        'Visualize yourself staying smoke-free and choosing a healthy action instead.',
        'Practice this mental rehearsal twice today.',
      ],
      reflectionQuestions: [
        'Which imagined situation felt the most empowering to overcome?',
      ],
    ),
    PlanMission(
      id: _dayId(63),
      dayNumber: 63,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Crush the "Just One" Myth',
      missionDescription: 'Reinforce commitment to zero cigarettes.',
      tasks: [
        'Write: "One cigarette = full reset. I choose freedom instead."',
        'Read it once during a normal moment—not a craving moment—to anchor it.',
      ],
      reflectionQuestions: [
        'How did this sentence affect your mindset today?',
      ],
    ),
    PlanMission(
      id: _dayId(64),
      dayNumber: 64,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Future-Focused Motivation',
      missionDescription: 'Visualize your smoke-free future.',
      tasks: [
        'Think about yourself 6 months from now: healthier, freer, stronger.',
        'List three benefits you expect if you continue smoke-free.',
        'Keep them somewhere visible.',
      ],
      reflectionQuestions: [
        'Which future benefit motivates you the most?',
      ],
    ),
    PlanMission(
      id: _dayId(65),
      dayNumber: 65,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Consistency Check',
      missionDescription: 'Strengthen automatic behaviors.',
      tasks: [
        'Choose one smoke-free skill you\'ve learned (delay, replacement habit, breathing, logging).',
        'Use it intentionally at least once today—even if the urge is small or absent.',
        'This strengthens automatic behavior.',
      ],
      reflectionQuestions: [
        'Which skill felt the most natural today?',
      ],
    ),
    PlanMission(
      id: _dayId(66),
      dayNumber: 66,
      phase: PlanPhaseType.rewiring,
      missionTitle: 'Phase 3 Victory Recognition',
      missionDescription: 'Complete Phase 3 and celebrate!',
      tasks: [
        'Review your streak, money saved, and health improvements.',
        'Write one sentence: "I grew stronger in Phase 3 because I learned ______."',
        'Take a moment to appreciate your progress.',
      ],
      reflectionQuestions: [
        'What lesson from Phase 3 will you carry into the next phase?',
      ],
      isMilestone: true,
      badgeId: 'phase_3_rewiring',
    ),

    // ============ PHASE 4: Mastery & Freedom (Days 67-90) ============
    PlanMission(
      id: _dayId(67),
      dayNumber: 67,
      phase: PlanPhaseType.mastery,
      missionTitle: 'Automatic Habit Awareness',
      missionDescription: 'Notice your automatic non-smoking behaviors.',
      tasks: [
        'Notice one moment today where you automatically chose a non-smoking behavior (walking away, drinking water, breathing).',
        'Acknowledge it by saying: "This is who I am now."',
      ],
      reflectionQuestions: [
        'What smoke-free action is becoming automatic for you?',
      ],
    ),
    PlanMission(
      id: _dayId(68),
      dayNumber: 68,
      phase: PlanPhaseType.mastery,
      missionTitle: 'Stress Shield Upgrade',
      missionDescription: 'Strengthen your stress management.',
      tasks: [
        'Choose one stress-management habit you want to strengthen.',
        'Use it twice today: once when calm, once when stressed or busy.',
      ],
      reflectionQuestions: [
        'Which moment showed you the skill is helping?',
      ],
    ),
    PlanMission(
      id: _dayId(69),
      dayNumber: 69,
      phase: PlanPhaseType.mastery,
      missionTitle: 'Reward System Refresh',
      missionDescription: 'Plan new motivating rewards.',
      tasks: [
        'Check money saved + health data.',
        'Plan a new reward for Day 80 (a treat, upgrade, or experience).',
        'Visualize enjoying it smoke-free.',
      ],
      reflectionQuestions: [
        'What reward makes Day 80 feel motivating?',
      ],
    ),
    PlanMission(
      id: _dayId(70),
      dayNumber: 70,
      phase: PlanPhaseType.mastery,
      missionTitle: 'Peak Strength Check',
      missionDescription: 'Evaluate your craving levels.',
      tasks: [
        'Note any cravings today (if any).',
        'Rate each from 1–10 on intensity.',
        'Celebrate how low cravings have become compared to your early days.',
      ],
      reflectionQuestions: [
        'What was the strongest craving today, and how did you handle it?',
      ],
    ),
    PlanMission(
      id: _dayId(71),
      dayNumber: 71,
      phase: PlanPhaseType.mastery,
      missionTitle: 'Environment Mastery',
      missionDescription: 'Conquer old smoking environments.',
      tasks: [
        'Identify one environment where smoking used to be part of your routine.',
        'Visit it smoke-free or imagine yourself in it confidently.',
        'Perform a healthy replacement action there.',
      ],
      reflectionQuestions: [
        'How did you feel in the old smoking environment today?',
      ],
    ),
    PlanMission(
      id: _dayId(72),
      dayNumber: 72,
      phase: PlanPhaseType.mastery,
      missionTitle: 'Self-Compassion Strengthening',
      missionDescription: 'Practice self-compassion.',
      tasks: [
        'Write a short message to yourself: "I am proud of how far I\'ve come. I\'m learning and improving every day."',
        'Read it once this evening.',
      ],
      reflectionQuestions: [
        'Which part of the message felt most true today?',
      ],
    ),
    PlanMission(
      id: _dayId(73),
      dayNumber: 73,
      phase: PlanPhaseType.mastery,
      missionTitle: 'Craving Firewall Refresh',
      missionDescription: 'Create a powerful phrase to block cravings.',
      tasks: [
        'Choose a "firewall phrase" like: "I don\'t smoke anymore." / "That chapter is over." / "Not even one."',
        'Use it at the first hint of any urge.',
      ],
      reflectionQuestions: [
        'Which phrase felt the strongest?',
      ],
    ),
    PlanMission(
      id: _dayId(74),
      dayNumber: 74,
      phase: PlanPhaseType.mastery,
      missionTitle: 'Routine Strengthening',
      missionDescription: 'Deepen your healthy routines.',
      tasks: [
        'Repeat one healthy habit you\'ve been building (walk, tea, stretching).',
        'Make it a little stronger today: slightly longer, deeper, or more mindful.',
      ],
      reflectionQuestions: [
        'What made today\'s version of the habit feel better or easier?',
      ],
    ),
    PlanMission(
      id: _dayId(75),
      dayNumber: 75,
      phase: PlanPhaseType.mastery,
      missionTitle: 'Confidence Snapshot',
      missionDescription: 'Capture your confidence.',
      tasks: [
        'Open your streak counter and look for 20 seconds.',
        'Write one sentence: "I am becoming someone who takes care of myself consistently."',
      ],
      reflectionQuestions: [
        'What does your streak tell you about your personal strength?',
      ],
    ),
    PlanMission(
      id: _dayId(76),
      dayNumber: 76,
      phase: PlanPhaseType.mastery,
      missionTitle: 'Break the Old Narrative',
      missionDescription: 'Replace old beliefs about smoking.',
      tasks: [
        'Write down one old belief you used to have about smoking (e.g., "It relaxes me").',
        'Replace it with the truth (e.g., "It caused stress, not relief").',
      ],
      reflectionQuestions: [
        'Which false belief were you most ready to let go of?',
      ],
    ),
    PlanMission(
      id: _dayId(77),
      dayNumber: 77,
      phase: PlanPhaseType.mastery,
      missionTitle: 'Micro-Moment Victory',
      missionDescription: 'Celebrate small wins.',
      tasks: [
        'Pay attention to tiny cravings or old cues.',
        'Every time you notice one, say: "I felt that — and I stayed free."',
      ],
      reflectionQuestions: [
        'What small moment today showed your growth?',
      ],
    ),
    PlanMission(
      id: _dayId(78),
      dayNumber: 78,
      phase: PlanPhaseType.mastery,
      missionTitle: 'Energy Restoration',
      missionDescription: 'Focus on renewal.',
      tasks: [
        'Do one intentionally restorative activity today (hydration, short nap, stretching, slow walk, breathing).',
        'Keep it slow and gentle — today is about renewal.',
      ],
      reflectionQuestions: [
        'What did your body feel grateful for today?',
      ],
    ),
    PlanMission(
      id: _dayId(79),
      dayNumber: 79,
      phase: PlanPhaseType.mastery,
      missionTitle: 'Prepare for Celebration',
      missionDescription: 'Plan your Day 80 celebration.',
      tasks: [
        'Revisit your Day 80 reward plan.',
        'Add one more small treat, comfort, or experience to make the celebration special.',
      ],
      reflectionQuestions: [
        'What addition to your reward made it feel exciting?',
      ],
    ),
    PlanMission(
      id: _dayId(80),
      dayNumber: 80,
      phase: PlanPhaseType.mastery,
      missionTitle: 'Milestone Celebration',
      missionDescription: 'Celebrate 80 days smoke-free!',
      tasks: [
        'Claim your Day 80 reward.',
        'Take a screenshot of your streak or write a short victory message.',
        'Spend 30 seconds acknowledging how far you\'ve come.',
      ],
      reflectionQuestions: [
        'What does reaching 80 days smoke-free mean to you personally?',
      ],
      isMilestone: true,
      badgeId: 'milestone_80_days',
    ),
    PlanMission(
      id: _dayId(81),
      dayNumber: 81,
      phase: PlanPhaseType.mastery,
      missionTitle: 'Freedom Identity Check',
      missionDescription: 'Confirm your non-smoker identity.',
      tasks: [
        'Write the sentence: "I live like a non-smoker now."',
        'Notice at least one moment today that proves it\'s true.',
      ],
      reflectionQuestions: [
        'What moment today confirmed that you live smoke-free now?',
      ],
    ),
    PlanMission(
      id: _dayId(82),
      dayNumber: 82,
      phase: PlanPhaseType.mastery,
      missionTitle: 'Confidence Anchor',
      missionDescription: 'Strengthen your confidence statements.',
      tasks: [
        'Choose one positive statement that has helped you (e.g., "Not even one," "I choose freedom," "I\'m stronger than cravings").',
        'Say it three times today: morning, midday, evening.',
      ],
      reflectionQuestions: [
        'Which moment made your confidence anchor feel powerful?',
      ],
    ),
    PlanMission(
      id: _dayId(83),
      dayNumber: 83,
      phase: PlanPhaseType.mastery,
      missionTitle: 'Lifestyle Upgrade',
      missionDescription: 'Add small improvements to your routine.',
      tasks: [
        'Add one small but meaningful improvement to your daily routine (extra water, tidy a space, walk five more minutes).',
        'Do it with intention.',
      ],
      reflectionQuestions: [
        'How did this small upgrade improve your day?',
      ],
    ),
    PlanMission(
      id: _dayId(84),
      dayNumber: 84,
      phase: PlanPhaseType.mastery,
      missionTitle: 'Trigger Mastery',
      missionDescription: 'Acknowledge your power over triggers.',
      tasks: [
        'Identify one situation that used to trigger smoking but no longer does.',
        'Acknowledge the change by writing one sentence: "This used to control me — now it doesn\'t."',
      ],
      reflectionQuestions: [
        'Which old trigger has lost its power over you?',
      ],
    ),
    PlanMission(
      id: _dayId(85),
      dayNumber: 85,
      phase: PlanPhaseType.mastery,
      missionTitle: 'Resilience Rehearsal II',
      missionDescription: 'Practice handling temptation.',
      tasks: [
        'Visualize a future scenario where someone offers you a cigarette or vape.',
        'Practice responding confidently and walking away.',
        'Repeat twice today.',
      ],
      reflectionQuestions: [
        'How did rehearsing the situation change how you\'d handle it?',
      ],
    ),
    PlanMission(
      id: _dayId(86),
      dayNumber: 86,
      phase: PlanPhaseType.mastery,
      missionTitle: 'Long-Term Motivation Map',
      missionDescription: 'Focus on long-term benefits.',
      tasks: [
        'Write down three long-term benefits you\'re already noticing or expect soon (better breathing, clearer skin, more money, fewer cravings, independence).',
        'Choose one to focus on today.',
      ],
      reflectionQuestions: [
        'Which long-term benefit motivates you most right now?',
      ],
    ),
    PlanMission(
      id: _dayId(87),
      dayNumber: 87,
      phase: PlanPhaseType.mastery,
      missionTitle: 'Stress-Proof Habits',
      missionDescription: 'Use stress relief proactively.',
      tasks: [
        'Use your stress-relief habit when a mild stressor appears — BEFORE a craving forms.',
        'Practice this at least once intentionally.',
      ],
      reflectionQuestions: [
        'How did your stress skill improve your ability to stay calm?',
      ],
    ),
    PlanMission(
      id: _dayId(88),
      dayNumber: 88,
      phase: PlanPhaseType.mastery,
      missionTitle: 'Gratitude for Progress',
      missionDescription: 'Appreciate what quitting has given you.',
      tasks: [
        'Write down 3 things quitting has given you (energy, clarity, pride, time, freedom).',
        'Read them once slowly.',
      ],
      reflectionQuestions: [
        'Which gift of being smoke-free feels the most meaningful?',
      ],
    ),
    PlanMission(
      id: _dayId(89),
      dayNumber: 89,
      phase: PlanPhaseType.mastery,
      missionTitle: 'Prepare for Completion',
      missionDescription: 'Get ready to complete the 90-day journey.',
      tasks: [
        'Look at your streak and money saved.',
        'Choose a meaningful reward for Day 90 — something that symbolizes your transformation.',
        'Take 20 seconds to appreciate how steady you\'ve become.',
      ],
      reflectionQuestions: [
        'What reward feels worthy of your 90-day achievement?',
      ],
    ),
    PlanMission(
      id: _dayId(90),
      dayNumber: 90,
      phase: PlanPhaseType.mastery,
      missionTitle: 'Celebrate Your New Life',
      missionDescription: 'You\'ve completed the 90-day plan! 🎉',
      tasks: [
        'Claim your Day 90 reward.',
        'Take a screenshot of your streak or write a victory note.',
        'Say out loud: "I earned this — and this is just the beginning."',
      ],
      reflectionQuestions: [
        'What does reaching 90 days smoke-free mean for your future?',
      ],
      isMilestone: true,
      badgeId: 'phase_4_mastery',
    ),
  ];
}
