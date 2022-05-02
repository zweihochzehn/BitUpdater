import 'package:bit_updater/cubit/bit_updater_cubit.dart';
import 'package:bit_updater/services/bit_updater_service.dart';
import 'package:bit_updater/services/shared_preferences_service.dart';
import 'package:get_it/get_it.dart';

GetIt bitUpdaterGetIt = GetIt.instance;

void setUpLocatorService() {
  bitUpdaterGetIt.registerLazySingleton(() => SharedPreferencesService());
  bitUpdaterGetIt.registerLazySingleton(() => BitUpdaterCubit());
  bitUpdaterGetIt.registerLazySingleton(() => BitUpdaterService());
}