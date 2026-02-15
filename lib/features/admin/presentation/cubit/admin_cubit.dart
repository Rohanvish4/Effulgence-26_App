import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../auth/domain/entity/user_entity.dart';
import '../../domain/repositories/admin_repository.dart';

// States
abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminUsersLoaded extends AdminState {
  final List<UserEntity> users;
  final bool hasReachedMax;

  const AdminUsersLoaded({required this.users, this.hasReachedMax = false});

  @override
  List<Object?> get props => [users, hasReachedMax];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class AdminCubit extends Cubit<AdminState> {
  final AdminRepository repository;
  int _currentPage = 1;
  final int _limit = 50;
  List<UserEntity> _allUsers = [];
  bool _hasReachedMax = false;
  bool _isFetching = false;  // Prevent duplicate fetches

  // State for filtering
  String _currentSearchQuery = '';
  String _currentFilterType = 'ALL';

  AdminCubit({required this.repository}) : super(AdminInitial());

  Future<void> getUsers({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _allUsers = [];
      if (state is! AdminUsersLoaded) { // Only emit loading if not already showing list (e.g. initial load or full refresh)
         emit(AdminLoading());
      }
    }

    // Prevent duplicate fetches
    if (_isFetching) return;

    // Prevent fetching if already reached max (unless refreshing)
    if (!refresh && state is AdminUsersLoaded && (state as AdminUsersLoaded).hasReachedMax) {
      return;
    }
    
    _isFetching = true;

    try {
      // Standard fetch
      final result = await repository.getAllUsers(page: _currentPage, limit: _limit);

      result.fold(
        (failure) => emit(AdminError(failure.message)),
        (users) {
        if (users.isNotEmpty) {
           _currentPage++;
           if (refresh) {
             _allUsers = users;
           } else {
             _allUsers.addAll(users);
           }
        } else {
          // If users is empty, we reached max, but we might still have data in _allUsers
           if (refresh) {
             _allUsers = [];
           }
        }
        
        _hasReachedMax = users.length < _limit;
        
        // Re-apply current filters
        _applyFilters();
      },
    );
    } finally {
      _isFetching = false;
    }
  }

  void filterUsers(String query, {String filterType = 'ALL'}) {
    _currentSearchQuery = query;
    _currentFilterType = filterType;
    _applyFilters();
  }

  void _applyFilters() {
    if (_allUsers.isEmpty && state is! AdminUsersLoaded) {
       emit(const AdminUsersLoaded(users: [], hasReachedMax: true));
       return;
    }

    final lowercaseQuery = _currentSearchQuery.toLowerCase();
    
    final filtered = _allUsers.where((user) {
        // 1. Text Search
        final matchesSearch = _currentSearchQuery.isEmpty || 
                user.name.toLowerCase().contains(lowercaseQuery) ||
                user.email.toLowerCase().contains(lowercaseQuery) ||
                user.rollNo.toString().contains(lowercaseQuery);

        if (!matchesSearch) return false;

        // 2. Filter Type
        switch (_currentFilterType) {
          case 'INTERNAL':
            return user.isInternalUser;
          case 'EXTERNAL':
            return !user.isInternalUser;
          case 'ADMIN':
            return user.role == 'ADMIN' || user.role == 'SUPER_ADMIN';
          case 'ALL':
          default:
            return true;
        }
    }).toList();
    
    // Check if we have fetched all possible users from backend
    // If the last fetch returned less than limit, we likely reached the end.
    // However, since we are filtering locally, 'hasReachedMax' technically refers to the backend pagination.
    // We can infer it from the last fetch result, but we don't store it explicitly here easily without extra state.
    // For now, let's assume if we have users, we are good. The UI will trigger load more.
    // Ideally, `getUsers` should update a `_hasReachedMax` flag. 
    // Let's rely on the fact that if `getUsers` was called and returned empty/less than limit, we should know.
    // Providing a default true if we have no users might be safe if we rely on backend.
    
    // Improving `hasReachedMax` logic:
    // We need to know if the *server* has more data.
    // We can check if `_allUsers.length` %_limit == 0, but that's imperfect.
    // Let's modify `getUsers` to set a flag.
    
    emit(AdminUsersLoaded(users: filtered, hasReachedMax: _hasReachedMax)); 
  }
}
