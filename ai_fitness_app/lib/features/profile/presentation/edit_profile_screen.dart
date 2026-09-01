import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../auth/domain/auth_session_store.dart';
import '../data/profile_api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _profileApiService = ProfileApiService();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String _gender = 'Male';
  String _fitnessGoal = 'Build Muscle';
  String _activityLevel = 'Moderate';
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = AuthSessionStore.name;
    _loadInitialProfile();
  }

  Future<void> _loadInitialProfile() async {
    setState(() => _isLoading = true);
    try {
      final data = await _profileApiService.getProfile();
      if (mounted) {
        setState(() {
          if (data['fullName'] != null) _nameController.text = data['fullName'].toString();
          if (data['age'] != null) _ageController.text = data['age'].toString();
          if (data['currentWeightKg'] != null) _weightController.text = data['currentWeightKg'].toString();
          if (data['heightCm'] != null) _heightController.text = data['heightCm'].toString();
          if (data['gender'] != null && data['gender'].toString().isNotEmpty) _gender = data['gender'].toString();
          if (data['fitnessGoal'] != null && data['fitnessGoal'].toString().isNotEmpty) _fitnessGoal = data['fitnessGoal'].toString();
          if (data['activityLevel'] != null && data['activityLevel'].toString().isNotEmpty) _activityLevel = data['activityLevel'].toString();
        });
      }
    } catch (_) {
      // Keep initial defaults
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      await _profileApiService.updateProfile(
        fullName: _nameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()),
        gender: _gender,
        heightCm: double.tryParse(_heightController.text.trim()),
        currentWeightKg: double.tryParse(_weightController.text.trim()),
        fitnessGoal: _fitnessGoal,
        activityLevel: _activityLevel,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textPrimary, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Full Name'),
                    _buildTextField(controller: _nameController),
                    _buildFieldLabel('Age'),
                    _buildTextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                    ),
                    _buildFieldLabel('Current Weight (kg)'),
                    _buildTextField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    _buildFieldLabel('Height (cm)'),
                    _buildTextField(
                      controller: _heightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    _buildFieldLabel('Gender'),
                    _buildDropdown(['Male', 'Female', 'Other'], _gender, (val) {
                      setState(() => _gender = val);
                    }),
                    _buildFieldLabel('Fitness Goal'),
                    _buildDropdown([
                      'Build Muscle',
                      'Lose Weight',
                      'Improve Endurance',
                      'Stay Fit',
                      'Strength & Power',
                    ], _fitnessGoal, (val) {
                      setState(() => _fitnessGoal = val);
                    }),
                    _buildFieldLabel('Activity Level'),
                    _buildDropdown(['Sedentary', 'Lightly Active', 'Moderate', 'Very Active'], _activityLevel, (val) {
                      setState(() => _activityLevel = val);
                    }),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _isSaving ? null : _saveProfile,
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String currentVal, ValueChanged<String> onChanged) {
    final value = items.contains(currentVal) ? currentVal : items.first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }
}
