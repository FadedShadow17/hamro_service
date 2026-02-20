import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/phone_number_field.dart';
import '../../../../core/services/storage/user_session_service.dart';
import '../../data/repositories/provider_verification_repository_impl.dart';
import '../../presentation/providers/provider_verification_provider.dart';
import '../../presentation/providers/provider_dashboard_provider.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import 'provider_dashboard_page.dart';

// Hardcoded service roles matching the website
const List<String> _hardcodedServiceRoles = [
  'Plumber',
  'Electrician',
  'Cleaner',
  'Carpenter',
  'Painter',
  'HVAC Technician',
  'Appliance Repair Technician',
  'Gardener/Landscaper',
  'Pest Control Specialist',
  'Water Tank Cleaner',
];

final verificationStatusProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(providerVerificationRepositoryProvider);
  final result = await repository.getVerificationSummary();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (summary) => summary,
  );
});

class ProviderVerificationPage extends ConsumerStatefulWidget {
  const ProviderVerificationPage({super.key});

  @override
  ConsumerState<ProviderVerificationPage> createState() => _ProviderVerificationPageState();
}

class _ProviderVerificationPageState extends ConsumerState<ProviderVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _citizenshipController = TextEditingController();
  final _provinceController = TextEditingController();
  final _districtController = TextEditingController();
  final _municipalityController = TextEditingController();
  final _wardController = TextEditingController();
  final _toleController = TextEditingController();
  final _streetController = TextEditingController();

  String? _selectedServiceRole;
  File? _citizenshipFront;
  File? _citizenshipBack;
  File? _profileImage;
  File? _selfie;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _citizenshipController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    _municipalityController.dispose();
    _wardController.dispose();
    _toleController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, Function(File) onPicked) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        onPicked(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error picking image';
        if (e.toString().contains('permission') || e.toString().contains('Permission')) {
          errorMessage = 'Permission denied. Please grant camera/storage permission in app settings.';
        } else {
          errorMessage = 'Error picking image: ${e.toString()}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _showImageSourcePicker(Function(File) onPicked) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

        return SafeArea(
          child: Container(
            color: cardColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery, onPicked);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera, onPicked);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitVerification() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final sessionService = UserSessionService(prefs: prefs);
    final role = sessionService.getRole();
    
    if (role != 'provider') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be a provider to submit verification. Please sign up as a provider.'),
          backgroundColor: Colors.orange,
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      }
      return;
    }

    if (_selectedServiceRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service role')),
      );
      return;
    }

    if (_citizenshipFront == null || _citizenshipBack == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload citizenship front and back images')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository = ref.read(providerVerificationRepositoryProvider);
      
      final address = <String, dynamic>{
        'province': _provinceController.text.trim(),
        'district': _districtController.text.trim(),
        'municipality': _municipalityController.text.trim(),
        'ward': _wardController.text.trim(),
        if (_toleController.text.trim().isNotEmpty) 'tole': _toleController.text.trim(),
        if (_streetController.text.trim().isNotEmpty) 'street': _streetController.text.trim(),
      };

      final formattedPhone = '+977-${_phoneController.text.trim()}';

      final result = await repository.submitVerification(
        fullName: _fullNameController.text.trim(),
        phoneNumber: formattedPhone,
        citizenshipNumber: _citizenshipController.text.trim(),
        serviceRole: _selectedServiceRole!,
        address: address,
        citizenshipFront: _citizenshipFront,
        citizenshipBack: _citizenshipBack,
        profileImage: _profileImage,
        selfie: _selfie,
      );

      result.fold(
        (failure) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Verification submission failed: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (verification) async {
          setState(() {
            _isSubmitting = false;
          });
          ref.invalidate(verificationStatusProvider);
          ref.invalidate(providerVerificationStatusForDashboardProvider);
          ref.invalidate(providerDashboardDataProvider);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification submitted successfully! Your verification is being processed by admin.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          
          // Navigate to provider dashboard instead of just popping
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const ProviderDashboardPage(),
              ),
              (route) => false, // Remove all previous routes
            );
          }
        },
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusAsync = ref.watch(verificationStatusProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Provider Verification',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: statusAsync.when(
        data: (summary) => _buildVerificationForm(context, isDark, summary),
        loading: () => const AppLoadingWidget(),
        error: (error, stack) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(verificationStatusProvider),
        ),
      ),
    );
  }

  Widget _buildVerificationForm(BuildContext context, bool isDark, Map<String, dynamic> summary) {
    final status = summary['status'] as String? ?? 'pending';
    final isApproved = status == 'verified';
    final isPending = status == 'pending';

    if (isApproved) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              Text(
                'Verified',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your verification has been approved',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isPending) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pending,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                'Pending Review',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your verification is being processed by admin.',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }


    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _fullNameController,
              label: 'Full Name',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            PhoneNumberField(
              controller: _phoneController,
              label: 'Phone Number',
              hintText: 'XXXXXXXXXX',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                if (value.trim().length < 9 || value.trim().length > 10) {
                  return 'Phone number must be 9-10 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _citizenshipController,
              label: 'Citizenship Number',
              icon: Icons.badge,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your citizenship number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Service Role',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildServiceRoleDropdown(context, isDark),
            const SizedBox(height: 24),
            Text(
              'Address',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _provinceController,
              label: 'Province',
              icon: Icons.location_city,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter province';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _districtController,
              label: 'District',
              icon: Icons.map,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter district';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _municipalityController,
              label: 'Municipality',
              icon: Icons.business,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter municipality';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _wardController,
              label: 'Ward',
              icon: Icons.home,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter ward';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _toleController,
              label: 'Tole (Optional)',
              icon: Icons.place,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _streetController,
              label: 'Street (Optional)',
              icon: Icons.streetview,
            ),
            const SizedBox(height: 24),
            Text(
              'Documents',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildImagePicker(
              label: 'Citizenship Front',
              file: _citizenshipFront,
              onTap: () => _showImageSourcePicker((file) {
                setState(() {
                  _citizenshipFront = file;
                });
              }),
              isRequired: true,
            ),
            const SizedBox(height: 16),
            _buildImagePicker(
              label: 'Citizenship Back',
              file: _citizenshipBack,
              onTap: () => _showImageSourcePicker((file) {
                setState(() {
                  _citizenshipBack = file;
                });
              }),
              isRequired: true,
            ),
            const SizedBox(height: 16),
            _buildImagePicker(
              label: 'Profile Image (Optional)',
              file: _profileImage,
              onTap: () => _showImageSourcePicker((file) {
                setState(() {
                  _profileImage = file;
                });
              }),
            ),
            const SizedBox(height: 16),
            _buildImagePicker(
              label: 'Selfie (Optional)',
              file: _selfie,
              onTap: () => _showImageSourcePicker((file) {
                setState(() {
                  _selfie = file;
                });
              }),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Submit Verification',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          prefixIcon: Icon(icon, color: AppColors.primaryBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: cardColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker({
    required String label,
    File? file,
    required VoidCallback onTap,
    bool isRequired = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRequired && file == null
                ? Colors.red
                : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
            width: isRequired && file == null ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.image,
              color: AppColors.primaryBlue,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (file != null)
                    Text(
                      file.path.split('/').last,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (file != null)
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              )
            else
              Icon(
                Icons.add_circle_outline,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceRoleDropdown(BuildContext context, bool isDark) {
    return DropdownButtonFormField<String>(
      value: _selectedServiceRole,
      decoration: InputDecoration(
        labelText: 'Select Service Role',
        prefixIcon: const Icon(Icons.work),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: _hardcodedServiceRoles.map((role) {
        return DropdownMenuItem<String>(
          value: role,
          child: Text(role),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedServiceRole = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a service role';
        }
        return null;
      },
    );
  }
}
