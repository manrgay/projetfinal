// map_picker_page.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({Key? key}) : super(key: key);

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  LatLng _selectedPosition = const LatLng(13.736717, 100.523186); // กรุงเทพฯ เป็นตำแหน่งเริ่มต้น
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // ถ้า GPS ปิด แจ้งเตือนผู้ใช้ (เพิ่มเองถ้าต้องการ)
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position pos = await Geolocator.getCurrentPosition();
    setState(() {
      _selectedPosition = LatLng(pos.latitude, pos.longitude);
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(_selectedPosition));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกตำแหน่งพิกัด'),
        backgroundColor: const Color(0xFFFF6600),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, _selectedPosition);
            },
          )
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _selectedPosition,
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('selected-position'),
            position: _selectedPosition,
            draggable: true,
            onDragEnd: (newPos) {
              setState(() {
                _selectedPosition = newPos;
              });
            },
          ),
        },
        onMapCreated: (controller) {
          _mapController = controller;
        },
        onTap: (pos) {
          setState(() {
            _selectedPosition = pos;
          });
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
