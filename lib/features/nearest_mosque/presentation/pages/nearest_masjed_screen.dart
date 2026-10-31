import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          infoWindow: InfoWindow(title: m.name, snippet: m.vicinity),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    markers.add(
      Marker(
        markerId: const MarkerId('my_location'),
        position: LatLng(latitude, longitude),
        infoWindow: const InfoWindow(title: 'موقعي الحالي'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E2125) : const Color(0xFFFAF5ED),
      appBar: CustomAppBar(title: 'nearby_masjed'.tr(), showReciterIcon: false),
      body: BlocProvider(
        create: (context) {
          return NearestMasjedCubit(NearestMsajedRepo())..getNearestMasjeds();
        },
        child: BlocBuilder<NearestMasjedCubit, NearestMasjedState>(
          builder: (context, state) {
            if (state is NearestMasjedErrorState) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.r),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off_rounded,
                        size: 54.sp,
                        color: isDark ? const Color(0xFF81C784) : const Color(0xFF143427),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark ? Colors.white70 : const Color(0xFF736152),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is NearestMasjedLoadingState) {
              log(state.toString());
              return Center(
                child: CircularProgressIndicator(
                  color: isDark ? const Color(0xFF2E7D5E) : const Color(0xFF143427),
                ),
              );
            } else if (state is NearestMasjedSuccessState) {
              final position = state.position;
              final markers = _buildMarkers(
                state.masjeds,
                position.latitude,
                position.longitude,
              );
              return Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.38,
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
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 6.h),
                    child: Row(
                      children: [
                        Container(
                          width: 4.w,
                          height: 16.h,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF81C784) : const Color(0xFF143427),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'المساجد القريبة (${state.masjeds.length})',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF143427),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                      itemCount: state.masjeds.length,
                      itemBuilder: (context, index) {
                        final masjed = state.masjeds[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 10.h),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF282C32) : Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF383E46)
                                  : const Color(0xFFEADBCE),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                            leading: Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color: (isDark ? const Color(0xFF2E7D5E) : const Color(0xFF143427))
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.mosque_rounded,
                                color: isDark ? const Color(0xFF81C784) : const Color(0xFF143427),
                                size: 22.sp,
                              ),
                            ),
                            title: Text(
                              masjed.name,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF143427),
                              ),
                            ),
                            subtitle: Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Text(
                                masjed.vicinity,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: isDark ? Colors.white70 : const Color(0xFF736152),
                                ),
                              ),
                            ),
                            trailing: Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: (isDark ? const Color(0xFF2E7D5E) : const Color(0xFF143427))
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.location_on_rounded,
                                color: isDark ? const Color(0xFF81C784) : const Color(0xFF143427),
                                size: 18.sp,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}
