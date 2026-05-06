import 'package:flutter/material.dart';
import 'package:wazzan_app/core/theme/app_colors.dart';
import 'package:wazzan_app/features/auth/data/auth_service.dart';
import '../../data/mood_model.dart';
import '../../data/mood_service.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  // 1. المتغيرات والمتحكمات
  String selectedEmoji = "😊";
  String selectedLabel = "سعيد";
  final TextEditingController _noteController = TextEditingController();
  final MoodService _moodService = MoodService();
  final AuthService _authService = AuthService();
  bool _isSaving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // 2. دالة حفظ الحالة
  void _saveMood() async {
    final user = _authService.currentUser;
    if (user == null) {
      _showSnackBar("يجب تسجيل الدخول أولاً", Colors.orange);
      return;
    }

    setState(() => _isSaving = true);

    final mood = MoodModel(
      userId: user.uid,
      emoji: selectedEmoji,
      label: selectedLabel,
      note: _noteController.text.trim(),
      date: DateTime.now(),
    );

    bool success = await _moodService.addMood(mood);

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      _noteController.clear();
      _showSnackBar("تم حفظ حالتك بنجاح 💚", AppColors.primary);

      // اختيارياً: العودة للرئيسية بعد الحفظ
      // Future.delayed(const Duration(seconds: 1), () {
      //   if (mounted) DefaultTabController.of(context).animateTo(0);
      // });
    } else {
      _showSnackBar("فشل في حفظ الحالة، تأكد من الإنترنت", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("تتبع حالتك", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              "كيف تشعر الآن يا إبراهيم؟", // الاسم أصبح شخصياً
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // ✅ حل مشكلة الـ Overflow النهائي مع تحسين شكل السحب
            SizedBox(
              height: 140, // زيادة الارتفاع للسماح بالظلال والحركة
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.none, // لضمان عدم قص الظلال أثناء السحب
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  children: [
                    _moodOption("😊", "سعيد"),
                    _moodOption("😌", "مرتاح"),
                    _moodOption("😐", "عادي"),
                    _moodOption("😔", "حزين"),
                    _moodOption("😠", "غاضب"),
                    _moodOption("😴", "مرهق"),
                    _moodOption("🤯", "مضغوط"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // قسم الملاحظات
            const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 5),
                child: Text("هل تريد إضافة ملاحظات؟",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _noteController,
              maxLines: 5,
              textAlign: TextAlign.right,
              style: const TextStyle(height: 1.5),
              decoration: InputDecoration(
                hintText: "اكتب ما يدور في خاطرك هنا...",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // زر الحفظ
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveMood,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: _isSaving
                    ? const SizedBox(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Text(
                    "حفظ الحالة الآن",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ويدجت مساعدة لبناء خيارات المزاج (مع أنيميشن Scale)
  Widget _moodOption(String emoji, String label) {
    bool isSelected = selectedEmoji == emoji;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedEmoji = emoji;
          selectedLabel = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        // إضافة تأثير تكبير بسيط عند الاختيار
        transform: Matrix4.identity()..scale(isSelected ? 1.08 : 1.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 45)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textLight,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}