import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:islamic_app/core/widgets/custom_app_bar.dart';
import '../../data/repositories/nearest_msajed_repo.dart';
import '../cubit/nearest_msajed_cubit.dart';
import '../cubit/nearest_msajed_states.dart';

class NearestMasjedScreen extends StatelessWidget {
  const NearestMasjedScreen({super.key});

  Set<Marker> _buildMarkers(
    List<dynamic> masjeds,
    double latitude,
    double longitude,
  ) {
    final markers = <Marker>{};

    for (var m in masjeds) {
      markers.add(
        Marker(
          markerId: MarkerId(m.id),
          position: LatLng(m.lat, m.lng),
          infoWindow: InfoWindow(title: m.name),
        ),
      );
    }

    markers.add(
      Marker(
        markerId: const MarkerId('my_location'),
        position: LatLng(latitude, longitude),
        infoWindow: const InfoWindow(title: 'My Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'nearby_masjed'.tr(), showReciterIcon: false),
      body: BlocProvider(
        create: (context) {
          return NearestMasjedCubit(NearestMsajedRepo())..getNearestMasjeds();
        },
        child: BlocBuilder<NearestMasjedCubit, NearestMasjedState>(
          builder: (context, state) {
            if (state is NearestMasjedErrorState) {
              //  log(state.message);
              return Center(child: Text(state.message));
            } else if (state is NearestMasjedLoadingState) {
              log(state.toString());

              return const Center(child: CircularProgressIndicator());
            } else if (state is NearestMasjedSuccessState) {
              //log(state.position.latitude.toString());
              // log(state.position.toString());
              // markers للمساجد
              final position = state.position;
              final markers = _buildMarkers(
                state.masjeds,
                position.latitude,
                position.longitude,
              );
              return Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    width: double.infinity,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(position.latitude, position.longitude),
                        zoom: 14,
                      ),
                      markers: markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.masjeds.length,
                      itemBuilder: (context, index) {
                        final masjed = state.masjeds[index];
                        log(state.masjeds.first.toString());
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            title: Text(masjed.name),
                            subtitle: Text(masjed.vicinity),
                            trailing: const Icon(Icons.location_on),
                            onTap: () {},
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
              /*Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2,
                    color: Colors.amber,
                  ),
                ],
              );*/
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}
