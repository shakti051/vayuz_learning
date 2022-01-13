import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:vlcc/components/components.dart';
import 'package:vlcc/database/db_helper.dart';
import 'package:vlcc/models/center_master_model.dart';
import 'package:vlcc/screens/search/clinics.dart';
import 'package:vlcc/widgets/nodata.dart';

class PopularClinics extends StatefulWidget {
  final List<CenterMasterDatabase> centerMasterDatabaseList;
  final double currentLatitude;
  final double currentLongitude;
  const PopularClinics({
    Key? key,
    required this.centerMasterDatabaseList,
    required this.currentLatitude,
    required this.currentLongitude,
  }) : super(key: key);

  @override
  State<PopularClinics> createState() => _PopularClinicsState();
}

class _PopularClinicsState extends State<PopularClinics> {
  @override
  Widget build(BuildContext context) {
    final databaseProvider = context.watch<DatabaseHelper>();
    var clinics = databaseProvider.centerMasterDbList;
    int clinicsLength = clinics.length;
    if (clinicsLength == 0) {
      return NoDataScreen(
        noDataSelect: NoDataSelectType.feelsEmptyHere,
      );
    } else {
      return ListView.builder(
          itemCount: clinicsLength,
          physics: ClampingScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            var clinic = clinics[index];
            double clinicLatitude = double.parse(
                clinic.centerLatitude.isEmpty ? '0.0' : clinic.centerLatitude);
            double clinictLongitude = double.parse(
                clinic.centerLongitude.isEmpty
                    ? '0.0'
                    : clinic.centerLongitude);
            return FutureBuilder(
                future: getDistanceFromCurrentLocation(
                  currentLatitude: widget.currentLatitude,
                  currentLongitude: widget.currentLongitude,
                  clinicLatitude: clinicLatitude,
                  clinictLongitude: clinictLongitude,
                ),
                builder: (context, AsyncSnapshot<double> snapshot) {
                  Widget child = SizedBox();
                  if (snapshot.hasData) {
                    double distance = snapshot.data ?? 0.0;
                    if (distance < 30.0) {
                      child = GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Clinics(
                                centerMasterDatabase: clinics[index],
                              ),
                            ),
                          );
                        },
                        child: ClinicName(
                          centerMasterDatabase: clinic,
                          distance: distance,
                        ),
                      );
                    }
                  } else {
                    // if (snapshot.connectionState == ConnectionState.done) {
                    //   setState(() {
                    //     clinicsLength = 0;
                    //   });
                    // }

                    // child = NoDataScreen(
                    // noDataSelect: NoDataSelectType.feelsEmptyHere,
                    // );
                  }
                  return child;
                });
          });
    }
  }

  Future<double> getDistanceFromCurrentLocation({
    required double currentLatitude,
    required double currentLongitude,
    required double clinicLatitude,
    required double clinictLongitude,
  }) async {
    double distance = 0.0;
    var apikey = "AIzaSyCJ1HGjRHt15_gyI0fLho4T9hsF7TaOTZE";
    var response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/distancematrix/json?origins=$currentLatitude%2C$currentLongitude&destinations=$clinicLatitude%2C$clinictLongitude&units=meters&key=$apikey'));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        var rows = result['rows'] as List<dynamic>;
        var elements = rows.first['elements'] as List<dynamic>;
        var distanceObject = elements.first['distance'];
        distance = (distanceObject['value'] as num) / 1000.0;
      }
    }

    return distance.roundToDouble();
  }
}
