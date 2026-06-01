// Playable cook-along mode.
//
// Flow:
//   1. Page opens → fires CookModeService.generateSteps(recipe).
//   2. While loading: spinner + "Preparing your recipe…".
//   3. On error: friendly message + retry button.
//   4. On success: step-by-step player with timer, prev/skip/next controls.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:recipe_app/models/cook_step_model.dart';
import 'package:recipe_app/models/recipe_details_model.dart';
import 'package:recipe_app/services/cook_mode_service.dart';

class CookModePage extends StatefulWidget {
  final RecipeDetailsModel recipe;
  const CookModePage({required this.recipe, super.key});

  @override
  State<CookModePage> createState() => _CookModePageState();
}

class _CookModePageState extends State<CookModePage> {
  // ---- Loading / error state -------------------------------------------
  bool isLoading = true;
  String? errorMessage;
  List<CookStep> steps = [];

  // ---- Player state ----------------------------------------------------
  int currentIndex = 0;
  int remainingSeconds = 0;
  bool isPaused = false;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _loadSteps();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _loadSteps() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await CookModeService.generateSteps(widget.recipe);
      if (!mounted) return;
      setState(() {
        steps = result;
        isLoading = false;
        currentIndex = 0;
      });
      _startStepTimer();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  // Start/restart the countdown for the current step. If the step has no
  // duration, the timer simply doesn't run and the UI shows a "Tap Next when
  // done" hint.
  void _startStepTimer() {
    _ticker?.cancel();
    final duration = steps[currentIndex].durationSeconds;
    if (duration == null) {
      setState(() {
        remainingSeconds = 0;
        isPaused = false;
      });
      return;
    }
    setState(() {
      remainingSeconds = duration;
      isPaused = false;
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (isPaused) return;
      if (remainingSeconds <= 0) {
        t.cancel();
        return;
      }
      setState(() => remainingSeconds--);
    });
  }

  void _goPrev() {
    if (currentIndex == 0) return;
    setState(() => currentIndex--);
    _startStepTimer();
  }

  void _goNext() {
    if (currentIndex >= steps.length - 1) return;
    setState(() => currentIndex++);
    _startStepTimer();
  }

  void _togglePause() {
    setState(() => isPaused = !isPaused);
  }

  String _formatTime(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  // ---- Build -----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff213A50), Color(0xff071938)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) return _buildLoading();
    if (errorMessage != null) return _buildError();
    if (steps.isEmpty) return _buildError(); // safety net
    return _buildPlayer();
  }

  // ---- Loading view ----------------------------------------------------
  Widget _buildLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: Colors.orangeAccent),
        const SizedBox(height: 24),
        const Text(
          "Preparing your recipe…",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 8),
        const Text(
          "Breaking it into easy steps for you",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  // ---- Error view ------------------------------------------------------
  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.orangeAccent,
            size: 72,
          ),
          const SizedBox(height: 20),
          const Text(
            "Couldn't prepare your recipe",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            errorMessage ?? "Check your connection and try again.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Back",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _loadSteps,
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---- Player view -----------------------------------------------------
  Widget _buildPlayer() {
    final step = steps[currentIndex];
    final isLastStep = currentIndex == steps.length - 1;
    final hasTimer = step.durationSeconds != null;
    final timerDone = hasTimer && remainingSeconds == 0;
    final progress = (currentIndex + 1) / steps.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Top row: close + "Step X of Y"
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
              const Spacer(),
              Text(
                "Step ${currentIndex + 1} of ${steps.length}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 48), // balance the close icon
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar across the top
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(Colors.orangeAccent),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 32),
          // Verb chip (optional, hidden when null)
          if (step.verb != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orangeAccent),
              ),
              child: Text(
                step.verb!.toUpperCase(),
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          // Instruction text — the headline of the screen
          Expanded(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  step.instruction,
                  key: ValueKey(currentIndex),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
          // Timer or "tap next when done" hint
          if (hasTimer)
            Column(
              children: [
                Text(
                  _formatTime(remainingSeconds),
                  style: TextStyle(
                    color: timerDone ? Colors.greenAccent : Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                  ),
                ),
                if (timerDone)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      "Time's up! Tap next when ready.",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            )
          else
            const Text(
              "Tap Next when you're done.",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          const SizedBox(height: 32),
          // Controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _circleButton(
                icon: Icons.skip_previous,
                label: "Prev",
                onTap: currentIndex == 0 ? null : _goPrev,
              ),
              if (hasTimer)
                _circleButton(
                  icon: isPaused ? Icons.play_arrow : Icons.pause,
                  label: isPaused ? "Resume" : "Pause",
                  onTap: timerDone ? null : _togglePause,
                ),
              if (!isLastStep)
                _circleButton(
                  icon: Icons.skip_next,
                  label: "Next",
                  onTap: _goNext,
                  highlight: timerDone || !hasTimer,
                )
              else
                _circleButton(
                  icon: Icons.check,
                  label: "Finish",
                  onTap: () => _showFinishedDialog(),
                  highlight: true,
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool highlight = false,
  }) {
    final color = onTap == null
        ? Colors.white24
        : (highlight ? Colors.orangeAccent : Colors.white);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: highlight && onTap != null
              ? Colors.orangeAccent
              : Colors.white12,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(
                icon,
                color: highlight && onTap != null ? Colors.white : color,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }

  void _showFinishedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff213A50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Enjoy your meal! 🎉",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "You're done cooking ${widget.recipe.title}.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // close dialog
              Navigator.pop(context); // close cook mode
            },
            child: const Text(
              "Back to recipe",
              style: TextStyle(color: Colors.orangeAccent),
            ),
          ),
        ],
      ),
    );
  }
}
