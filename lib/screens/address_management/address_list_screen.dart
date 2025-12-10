// lib/screens/address_management/address_list_screen.dart

// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import '../../../models/address_model.dart';
import '../../services/AddressService.dart';
import 'AddEditAddressScreen.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  final AddressService _addressService = AddressService();
  late Future<List<AddressModel>> _addressesFuture;

  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkBackground = const Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _addressesFuture = _addressService.fetchAddresses();
  }

  Future<void> _refreshAddresses() async {
    setState(() {
      _addressesFuture = _addressService.fetchAddresses();
    });
  }

  // 🔥 دالة حذف العنوان الفعلية (تنفذ بعد التأكيد) 🔥
  void _executeDelete(String addressId, AppLocalizations localizations) async {
    bool success = await _addressService.deleteAddress(addressId);
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.addressDeletedSuccess),
            backgroundColor: Colors.green,
          ),
        );
        _refreshAddresses();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.addressDeleteFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 🔥🔥 الدالة الجديدة: ديالوج تأكيد الحذف 🔥🔥
  void _showDeleteConfirmationDialog(
    AddressModel address,
    AppLocalizations localizations,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(
          localizations.confirmDeleteTitle, // نص مترجم جديد
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(
          localizations.confirmDeleteAddressMessage(
            address.title,
          ), // نص مترجم جديد مع متغير
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          // زر الإلغاء
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              localizations.cancelButton, // نص مترجم
              style: TextStyle(color: Colors.grey[500]),
            ),
          ),
          // زر التأكيد
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // إغلاق الديالوج
              _executeDelete(address.id, localizations); // تنفيذ الحذف
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              localizations.deleteButton, // نص مترجم جديد
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥🔥 الدالة المعدلة: الانتقال لشاشة إضافة/تعديل العنوان 🔥🔥
  void _navigateToAddEditScreen([AddressModel? address]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditAddressScreen(addressToEdit: address),
      ),
    );
    if (result == true) {
      _refreshAddresses();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _darkBackground,
      appBar: AppBar(
        title: Text(localizations.addressesTitle),
        backgroundColor: Colors.transparent,
        foregroundColor: _goldColor,
      ),
      body: FutureBuilder<List<AddressModel>>(
        future: _addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: _goldColor));
          } else if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data == null) {
            return Center(
              child: Text(
                localizations.connectionError,
                style: TextStyle(color: Colors.grey),
              ),
            );
          } else if (snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, color: Colors.grey[700], size: 50),
                  const SizedBox(height: 10),
                  Text(
                    localizations.noAddressesFound,
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () => _navigateToAddEditScreen(),
                    child: Text(
                      localizations.addAddressTitle,
                      style: TextStyle(color: _goldColor),
                    ),
                  ),
                ],
              ),
            );
          }

          final addresses = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return _buildAddressCard(address, localizations);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditScreen(),
        backgroundColor: _goldColor,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  // 🔥 كارت العنوان (Address Card) 🔥
  Widget _buildAddressCard(
    AddressModel address,
    AppLocalizations localizations,
  ) {
    return Card(
      color: const Color(0xFF2C2C2C),
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: _goldColor.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 15,
        ),
        leading: Icon(Icons.location_on_outlined, color: _goldColor, size: 30),
        title: Text(
          address.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            address.details,
            style: TextStyle(color: Colors.grey[400]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // زر التعديل (Edit)
            IconButton(
              icon: Icon(Icons.edit, color: Colors.grey),
              onPressed: () => _navigateToAddEditScreen(address),
            ),
            // 🔥 استبدال الاستدعاء المباشر باستدعاء الديالوج 🔥
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () =>
                  _showDeleteConfirmationDialog(address, localizations),
            ),
          ],
        ),
      ),
    );
  }
}
