// lib/screens/address_management/address_list_screen.dart

import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import '../../../models/address_model.dart';
import '../../services/AddressService.dart';
// 🔥🔥 استيراد شاشة الإضافة/التعديل 🔥🔥
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

  // 🔥 حذف العنوان 🔥
  void _deleteAddress(String addressId, AppLocalizations localizations) async {
    bool success = await _addressService.deleteAddress(addressId);
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.addressDeletedSuccess), // نص مترجم
            backgroundColor: Colors.green,
          ),
        );
        _refreshAddresses();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.addressDeleteFailed), // نص مترجم
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 🔥🔥 الدالة المعدلة: الانتقال لشاشة إضافة/تعديل العنوان 🔥🔥
  void _navigateToAddEditScreen([AddressModel? address]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditAddressScreen(addressToEdit: address),
      ),
    );
    // إذا عادت قيمة true، هذا يعني أن عملية الحفظ نجحت
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
        title: Text(localizations.addressesTitle), // 👈 نص مترجم
        backgroundColor: Colors.transparent,
        foregroundColor: _goldColor,
      ),
      body: FutureBuilder<List<AddressModel>>(
        future: _addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: _goldColor));
          } else if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text(
                localizations.connectionError, // 👈 نص مترجم
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
                    localizations.noAddressesFound, // 👈 نص مترجم
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

          // عرض قائمة العناوين
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
            // زر الحذف (Delete)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteAddress(address.id, localizations),
            ),
          ],
        ),
      ),
    );
  }
}
