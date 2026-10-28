import 'package:flutter_bloc/flutter_bloc.dart';

import 'count_and_round_state.dart';

class CountAndRoundCubit extends Cubit<CountAndRoundState> {
  CountAndRoundCubit() : super(SibhaLoadedStateWithUpdate(7, 1, counter: 0));

  int count = 7;
  int round = 1;
  int counter = 0;

  void updateCount(int newCount) {
    count = newCount;
    emit(SibhaLoadedStateWithUpdate(count, round, counter: counter));
  }

  void updateRound(int newRound) {
    round = newRound;
    emit(SibhaLoadedStateWithUpdate(count, round, counter: counter));
  }

  void incrementCounter() {
    counter += 1;

    if (counter == count) {
      counter = 0;
      round += 1;
    }

    emit(SibhaLoadedStateWithUpdate(count, round, counter: counter));
  }

  void resetCounter() {
    counter = 0;
    round = 1;
    emit(SibhaLoadedStateWithUpdate(count, round, counter: counter));
  }
}
