import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:islamic_app/core/utils/service_locator.dart';
import '../../data/models/audio_model.dart';
import '../../data/repositories/audio_repo.dart';
import '../widgets/radio_station_card.dart';
import '../../../../../core/widgets/custom_app_bar.dart';

class RadioViewBody extends StatelessWidget {
  const RadioViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // App Bar
          SafeArea(
            child: CustomAppBar(showReciterIcon: false, title: "radio".tr()),
          ),

          // 📻 Radio Stations List
          Expanded(
            child: FutureBuilder<List<RadioStationModel>>(
              future: getIt<AudioRepository>().getRadioStations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final stations = snapshot.data ?? [];

                return ListView.builder(
                  itemCount: stations.length,
                  itemBuilder: (context, index) {
                    final station = stations[index];
                    return RadioStationCard(station: station);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
