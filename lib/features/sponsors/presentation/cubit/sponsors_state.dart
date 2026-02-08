import 'package:equatable/equatable.dart';
import '../../domain/entities/sponsor_entity.dart';

/// Base state for sponsors
abstract class SponsorsState extends Equatable {
  const SponsorsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SponsorsInitial extends SponsorsState {
  const SponsorsInitial();
}

/// Loading state
class SponsorsLoading extends SponsorsState {
  const SponsorsLoading();
}

/// Loaded state with sponsors data
class SponsorsLoaded extends SponsorsState {
  final List<SponsorEntity> sponsors;

  const SponsorsLoaded({required this.sponsors});

  @override
  List<Object?> get props => [sponsors];

  /// Get sponsors by tier
  List<SponsorEntity> getSponsorsByTier(SponsorTier tier) {
    return sponsors.where((s) => s.tier == tier).toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  }
}

/// Error state
class SponsorsError extends SponsorsState {
  final String message;

  const SponsorsError({required this.message});

  @override
  List<Object?> get props => [message];
}
