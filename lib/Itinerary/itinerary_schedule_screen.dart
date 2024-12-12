import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:Tripster/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ItineraryScheduleScreen extends StatefulWidget {
  final List<Spot> spots;
  final DateTime startDate;
  final DateTime endDate;

  const ItineraryScheduleScreen({
    Key? key,
    required this.spots,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  _ItineraryScheduleScreenState createState() =>
      _ItineraryScheduleScreenState();
}

class _ItineraryScheduleScreenState extends State<ItineraryScheduleScreen> {
  late List<ItinerarySlot> itinerary;
  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    itinerary =
        generateItinerary(widget.spots, widget.startDate, widget.endDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Itinerary Schedule',
          style: AppColors.titleTextStyle,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isEditMode ? Icons.save : Icons.edit),
            onPressed: () {
              setState(() {
                isEditMode = !isEditMode;
              });
            },
          ),
          if (!isEditMode)
            IconButton(
              icon: Icon(Icons.download),
              onPressed: () => _downloadPdf(context, itinerary),
            ),
        ],
      ),
      body: isEditMode ? _buildEditModeListView() : _buildRegularListView(),
    );
  }

  Widget _buildEditModeListView() {
    return Scaffold(
      body: ReorderableListView(
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1; // Adjust the index for removal
            }
            final slot = itinerary.removeAt(oldIndex);
            itinerary.insert(newIndex, slot);
          });
        },
        children: [
          for (int index = 0; index < itinerary.length; index++)
            _buildEditableListItem(index, itinerary[index]),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isEditMode = false;
            _updateArrivalAndDepartureTimes();
          });
        },
        child: Icon(Icons.check),
      ),
    );
  }

  Widget _buildEditableListItem(int index, ItinerarySlot slot) {
    DateTime arrivalTime = slot.arrivalTime;
    DateTime departureTime = slot.departureTime;

    return ListTile(
      key: ValueKey(slot), // Required for reordering
      title: Text(
        '${slot.spot.name}',
        style: AppColors.subtitleTextStyle,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Arrival: ',
                style: AppColors.subtextStyle,
              ),
              InkWell(
                onTap: () async {
                  final pickedArrivalTime = await showTimePicker(
                    context: context as BuildContext,
                    initialTime: TimeOfDay.fromDateTime(arrivalTime),
                  );
                  if (pickedArrivalTime != null) {
                    setState(() {
                      arrivalTime = DateTime(
                        arrivalTime.year,
                        arrivalTime.month,
                        arrivalTime.day,
                        pickedArrivalTime.hour,
                        pickedArrivalTime.minute,
                      );
                      _updateArrivalAndDepartureTimes();
                    });
                  }
                },
                child: Text(
                  '${arrivalTime.hour}:${arrivalTime.minute}',
                  style: AppColors.subtextStyle,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'Departure: ',
                style: AppColors.subtextStyle,
              ),
              InkWell(
                onTap: () async {
                  final pickedDepartureTime = await showTimePicker(
                    context: context as BuildContext,
                    initialTime: TimeOfDay.fromDateTime(departureTime),
                  );
                  if (pickedDepartureTime != null) {
                    setState(() {
                      departureTime = DateTime(
                        departureTime.year,
                        departureTime.month,
                        departureTime.day,
                        pickedDepartureTime.hour,
                        pickedDepartureTime.minute,
                      );
                      _updateArrivalAndDepartureTimes();
                    });
                  }
                },
                child: Text(
                  '${departureTime.hour}:${departureTime.minute}',
                  style: AppColors.subtextStyle,
                ),
              ),
            ],
          ),
          if (_isLunchTime(arrivalTime))
            const Text(
              'You should have your lunch here',
              style: AppColors.subtextStyle,
            ),
          if (_isDinnerTime(arrivalTime))
            const Text(
              'You should have your dinner here',
              style: AppColors.subtextStyle,
            ),
        ],
      ),
      trailing: const Icon(Icons.reorder),
    );
  }

  Widget _buildRegularListView() {
    return ListView.builder(
      itemCount: itinerary.length,
      itemBuilder: (context, index) {
        final slot = itinerary[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index == 0 ||
                slot.arrivalTime.day != itinerary[index - 1].arrivalTime.day)
              _buildDateHeading(slot.arrivalTime),
            ListTile(
              title: Text(
                '${slot.spot.name}',
                style: AppColors.subtitleTextStyle,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Arrival: ${slot.arrivalTime.hour}:${slot.arrivalTime.minute}',
                    style: AppColors.subtextStyle,
                  ),
                  Text(
                    'Departure: ${slot.departureTime.hour}:${slot.departureTime.minute}',
                    style: AppColors.subtextStyle,
                  ),
                  if (_isLunchTime(slot.arrivalTime))
                    const Text(
                      'You should have your lunch here',
                      style: AppColors.subtextStyle,
                    ),
                  if (_isDinnerTime(slot.arrivalTime))
                    const Text(
                      'You should have your dinner here',
                      style: AppColors.subtextStyle,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _downloadPdf(BuildContext context, List<ItinerarySlot> itinerary) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            _buildPdfTitle(),
            for (final slot in itinerary) _buildPdfSlot(slot),
          ],
        ),
      ),
    );

    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/itinerary_schedule.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF downloaded at $path'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  pw.Widget _buildPdfTitle() {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Text(
        'Itinerary Schedule',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
      ),
    );
  }

  pw.Widget _buildPdfSlot(ItinerarySlot slot) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Spot: ${slot.spot.name}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Text('Arrival: ${slot.arrivalTime.hour}:${slot.arrivalTime.minute}'),
        pw.Text(
            'Departure: ${slot.departureTime.hour}:${slot.departureTime.minute}'),
      ],
    );
  }

  Widget _buildDateHeading(DateTime date) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          '${_getFormattedDate(date)}',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  String _getFormattedDate(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  List<ItinerarySlot> generateItinerary(
      List<Spot> spots, DateTime startDate, DateTime endDate) {
    List<ItinerarySlot> itinerary = [];
    DateTime currentTime = DateTime(
        startDate.year, startDate.month, startDate.day, 8, 0); // Start at 9 AM

    for (final spot in spots) {
      // Calculate travel time between spots (you'll need to implement this part)
      // For now, assume travel time is 30 minutes between each spot
      Duration travelTime = const Duration(minutes: 30);

      // Calculate time needed to visit the spot
      Duration timeNeeded = Duration(hours: spot.timeNeeded.toInt());

      // Include a 45-minute break for meals
      Duration mealBreak = const Duration(minutes: 45);

      // Check if the current time + travel time + time needed exceeds the end time for the day
      if (currentTime.add(travelTime).add(timeNeeded).isAfter(DateTime(
          currentTime.year, currentTime.month, currentTime.day, 21, 0))) {
        // Move to the next day
        currentTime = DateTime(
            currentTime.year, currentTime.month, currentTime.day + 1, 9, 0);
      }

      // Add the spot to the itinerary with arrival and departure times
      itinerary.add(ItinerarySlot(
        spot: spot,
        arrivalTime: currentTime.add(travelTime),
        departureTime: currentTime.add(travelTime).add(timeNeeded),
      ));

      // Update the current time for the next spot
      currentTime = currentTime.add(travelTime).add(timeNeeded).add(mealBreak);
    }

    return itinerary;
  }

  bool _isLunchTime(DateTime time) {
    return time.hour >= 12 && time.hour < 14;
  }

  bool _isDinnerTime(DateTime time) {
    return time.hour >= 19 && time.hour < 21;
  }

  void _updateArrivalAndDepartureTimes() {
    DateTime currentTime = DateTime(
      widget.startDate.year,
      widget.startDate.month,
      widget.startDate.day,
      9,
      0,
    ); // Start at 9 AM
    Duration mealBreak = const Duration(minutes: 45);
    bool isNextDay = false;

    for (int i = 0; i < itinerary.length; i++) {
      final slot = itinerary[i];
      slot.arrivalTime = currentTime;
      slot.departureTime =
          currentTime.add(Duration(hours: slot.spot.timeNeeded.toInt()));

      if (_isLunchTime(currentTime)) {
        slot.departureTime =
            slot.departureTime.add(const Duration(minutes: 30));
      }
      if (_isDinnerTime(currentTime)) {
        slot.departureTime =
            slot.departureTime.add(const Duration(minutes: 30));
      }

      currentTime = slot.departureTime.add(mealBreak);

      if (currentTime.hour >= 21) {
        currentTime = DateTime(
          currentTime.year,
          currentTime.month,
          currentTime.day,
          9,
          0,
        );
        isNextDay = true;
      }

      if (isNextDay) {
        currentTime = DateTime(
          currentTime.year,
          currentTime.month,
          currentTime.day + 1,
          9,
          0,
        );
        isNextDay = false;
      }
    }
  }
}

class Spot {
  final String name;
  final double timeNeeded; // in hours

  Spot({required this.name, required this.timeNeeded});
}

class ItinerarySlot {
  late Spot spot;
  late DateTime arrivalTime;
  late DateTime departureTime;

  ItinerarySlot({
    required this.spot,
    required this.arrivalTime,
    required this.departureTime,
  });
}
