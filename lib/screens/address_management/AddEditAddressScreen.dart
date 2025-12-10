// ignore_for_file: file_names, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/address_model.dart';
import '../../services/AddressService.dart';
import '../../services/location_service.dart'; // 👈 لخدمات الموقع الجغرافي

class AddEditAddressScreen extends StatefulWidget {
  // AddressModel سيكون موجوداً فقط عند التعديل
  final AddressModel? addressToEdit;

  const AddEditAddressScreen({super.key, this.addressToEdit});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();

  final AddressService _addressService = AddressService();
  final LocationService _locationService = LocationService();

  // 🔥 البيانات الأساسية لإرسالها للسيرفر 🔥
  double _selectedLatitude = 0.0;
  double _selectedLongitude = 0.0;

  bool _isLoading = false;
  bool _isEditing = false; // هل نحن في وضع التعديل؟

  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkBackground = const Color(0xFF1A1A1A);
  final Color _fieldColor = const Color(0xFF2C2C2C);

  @override
  void initState() {
    super.initState();
    if (widget.addressToEdit != null) {
      _isEditing = true;
      _titleController.text = widget.addressToEdit!.title;
      _detailsController.text = widget.addressToEdit!.details;
      _selectedLatitude = widget.addressToEdit!.latitude;
      _selectedLongitude = widget.addressToEdit!.longitude;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  // ===============================================
  // 🆕🆕 دالة لعرض مربع حوار التأكيد 🆕🆕
  // ===============================================
  Future<bool?> _showConfirmationDialog(AppLocalizations localizations) async {
    final String actionText = _isEditing
        ? localizations
              .confirmUpdateAddress // نص: تأكيد تعديل العنوان
        : localizations.confirmAddAddress; // نص: تأكيد إضافة العنوان

    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.confirmation), // نص: تأكيد
          content: Text(actionText),
          backgroundColor: _fieldColor, // لون خلفية مناسب
          titleTextStyle: TextStyle(color: _goldColor, fontSize: 20),
          contentTextStyle: const TextStyle(color: Colors.white70),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // لا
              child: Text(
                localizations.cancel,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true), // نعم، تابع
              style: ElevatedButton.styleFrom(backgroundColor: _goldColor),
              child: Text(
                localizations.confirm,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===============================================
  // 🔥 اختيار الموقع باستخدام GPS أو الخريطة (Placeholder)
  // ===============================================
  Future<void> _pickLocation(AppLocalizations localizations) async {
    // ... (هذا الجزء لا يتطلب تعديلاً)
    Position? currentPosition = await _locationService.getCurrentPositionSafe();

    if (currentPosition != null) {
      String geoDetails =
          'Lat: ${currentPosition.latitude.toStringAsFixed(4)}, Lng: ${currentPosition.longitude.toStringAsFixed(4)}';

      setState(() {
        _selectedLatitude = currentPosition.latitude;
        _selectedLongitude = currentPosition.longitude;
        _detailsController.text = geoDetails;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.locationPickedSuccess),
          backgroundColor: Colors.blueGrey,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.locationPermissionError),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ===============================================
  // 🔥 دالة الحفظ (إضافة أو تعديل) - تم التعديل لإضافة التأكيد 🔥
  // ===============================================
  Future<void> _saveAddress(AppLocalizations localizations) async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLatitude == 0.0 && _selectedLongitude == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.selectLocationRequired),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 🆕🆕 خطوة التأكيد 🆕🆕
    final bool? confirmed = await _showConfirmationDialog(localizations);
    if (confirmed != true) {
      return; // توقف إذا لم يتم التأكيد
    }

    setState(() => _isLoading = true);

    final newAddress = AddressModel(
      id: widget.addressToEdit?.id ?? '', // سيتم استخدام الـ ID في التعديل
      title: _titleController.text,
      details: _detailsController.text,
      latitude: _selectedLatitude,
      longitude: _selectedLongitude,
    );

    String? errorMessage;

    if (_isEditing) {
      errorMessage = await _addressService.updateAddress(newAddress);
    } else {
      errorMessage = await _addressService.addAddress(newAddress);
    }

    setState(() => _isLoading = false);

    if (errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? localizations.addressUpdatedSuccess
                : localizations.addressAddedSuccess,
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // إرسال true كإشارة للنجاح
    } else {
      // ✅✅ ترجمة الخطأ 🔥
      String translatedError = _translateError(errorMessage, localizations);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translatedError), backgroundColor: Colors.red),
      );
    }
  }

  // دالة مساعدة لترجمة الأخطاء الثابتة (تم التصحيح)
  String _translateError(String errorCode, AppLocalizations localizations) {
    switch (errorCode) {
      case 'connectionError':
        return localizations.connectionError;
      case 'loginRequired':
        return localizations.loginRequired;
      case 'addressAddFailed':
        return localizations.addressAddFailed;
      // 🔥 إضافة الخطأ الجديد 🔥
      case 'addressUpdateFailed':
        return localizations.addressUpdateFailed;
      default:
        return localizations.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final title = _isEditing
        ? localizations.editAddressTitle
        : localizations.addAddressTitle;

    return Scaffold(
      backgroundColor: _darkBackground,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        foregroundColor: _goldColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. حقل عنوان الموقع (المنزل، العمل، إلخ)
              _buildTextField(
                controller: _titleController,
                label: localizations.addressTitlePlaceholder, // نص مترجم جديد
                icon: Icons.home_work_outlined,
                validator: (val) =>
                    val!.isEmpty ? localizations.requiredField : null,
              ),
              const SizedBox(height: 20),

              // 2. حقل التفاصيل (اسم الشارع/المبنى)
              _buildTextField(
                controller: _detailsController,
                label: localizations.addressDetailsPlaceholder, // نص مترجم جديد
                icon: Icons.description_outlined,
                maxLines: 2,
                validator: (val) =>
                    val!.isEmpty ? localizations.requiredField : null,
              ),
              const SizedBox(height: 20),

              // 3. زر اختيار الموقع
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () => _pickLocation(localizations),
                  icon: Icon(Icons.map_outlined, color: _goldColor),
                  label: Text(
                    _selectedLatitude == 0.0
                        ? localizations
                              .selectLocationButton // نص مترجم جديد
                        : localizations.locationSelected, // نص مترجم جديد
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _goldColor,
                    backgroundColor: _selectedLatitude == 0.0
                        ? _fieldColor
                        : _goldColor.withOpacity(0.1),
                    side: BorderSide(
                      color: _selectedLatitude == 0.0
                          ? Colors.grey
                          : _goldColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              // 4. عرض إحداثيات الموقع الحالي
              if (_selectedLatitude != 0.0)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Lat: ${_selectedLatitude.toStringAsFixed(6)}, Lng: ${_selectedLongitude.toStringAsFixed(6)}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ),

              const Spacer(),

              // 5. زر الحفظ
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () => _saveAddress(
                          localizations,
                        ), // 👈 تم التعديل لاستدعاء دالة الحفظ
                  style: ElevatedButton.styleFrom(backgroundColor: _goldColor),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                          localizations.saveChanges, // نص مترجم
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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

  // دالة مساعدة لـ Text Field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: _goldColor),
        filled: true,
        fillColor: _fieldColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _goldColor, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      validator: validator,
    );
  }
}
