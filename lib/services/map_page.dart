// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// class MapPage extends StatefulWidget {
//   static const String route = '/';

//   const MapPage({super.key});

//   @override
//   State<MapPage> createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           FlutterMap(
//               options: MapOptions(
//                 initialCenter: const LatLng(51.5, -0.09),
//                 initialZoom: 5,
//                 cameraConstraint: CameraConstraint.contain(
//                   bounds: LatLngBounds(
//                     const LatLng(-90, -180),
//                     const LatLng(90, 180),
//                   ),
//                 ),
//               ),
//               children: [
//                 TileLayer(
//                   urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                   userAgentPackageName: 'dev.fleaflet.flutter_map.example',
//                 ),
//               ]),
//         ],
//       ),
//     );
//   }
// }
