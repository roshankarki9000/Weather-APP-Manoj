import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  late TextEditingController _latController;
  late TextEditingController _lonController;

  @override
  void initState() {
    super.initState();
    final loc = Provider.of<LocationProvider>(context, listen: false);
    _latController = TextEditingController(text: loc.latitude.toString());
    _lonController = TextEditingController(text: loc.longitude.toString());
  }

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  void _save() {
    final lat = double.tryParse(_latController.text.trim());
    final lon = double.tryParse(_lonController.text.trim());
    if (lat == null || lon == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid coordinates')));
      return;
    }
    Provider.of<LocationProvider>(context, listen: false).update(lat, lon);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(62, 45, 143, 1),
              Color.fromRGBO(157, 82, 172, 0.7),
            ],
          ),
        ),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40.h),
            Text('Add Location', style: TextStyle(fontSize: 20.sp, color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 20.h),
            TextField(
              controller: _latController,
              keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Latitude',
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: const BorderSide(color: Colors.white24)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: const BorderSide(color: Colors.white)),
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _lonController,
              keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Longitude',
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: const BorderSide(color: Colors.white24)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: const BorderSide(color: Colors.white)),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 12.h)),
                onPressed: _save,
                child: Text('Save', style: TextStyle(color: Colors.purple, fontSize: 16.sp)),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
