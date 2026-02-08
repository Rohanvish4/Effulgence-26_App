import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/sponsor_repository.dart';
import 'sponsors_state.dart';

/// Cubit for managing sponsors state
class SponsorsCubit extends Cubit<SponsorsState> {
  final SponsorRepository repository;

  SponsorsCubit({required this.repository}) : super(const SponsorsInitial());

  /// Load all sponsors
  Future<void> loadSponsors() async {
    emit(const SponsorsLoading());

    final result = await repository.getSponsors();

    result.fold(
      (failure) => emit(SponsorsError(message: failure.message)),
      (sponsors) => emit(SponsorsLoaded(sponsors: sponsors)),
    );
  }

  /// Refresh sponsors
  Future<void> refreshSponsors() async {
    await loadSponsors();
  }
}
