import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:meta/meta.dart';

import '../../../home/data/model/furniture_material_colors_response.dart';
import '../../domain/usecases/get_detail_colors_usecase.dart';
import '../../domain/usecases/get_my_rating_usecase.dart';
import '../../domain/usecases/rate_furniture_material_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';
import '../../domain/usecases/try_in_room_usecase.dart';

part 'detail_event.dart';
part 'detail_state.dart';

class DetailBloc extends Bloc<DetailEvent, DetailState> {
  DetailBloc({
    required this.useCase,
    required this.getMyRatingUseCase,
    required this.rateFurnitureMaterialUseCase,
    required this.tryInRoomUseCase,
    required this.toggleFavoriteUseCase,
  }) : super(DetailInitial()) {
    on<DetailFetchRequested>(_onFetchRequested);
    on<DetailMyRatingRequested>(_onMyRatingRequested);
    on<DetailRateSubmitted>(_onRateSubmitted);
    on<DetailTryInRoomRequested>(_onTryInRoom);
    on<DetailFavoriteToggled>(_onFavoriteToggled);
  }

  final GetDetailColorsUseCase useCase;
  final GetMyRatingUseCase getMyRatingUseCase;
  final RateFurnitureMaterialUseCase rateFurnitureMaterialUseCase;
  final TryInRoomUseCase tryInRoomUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;

  FurnitureMaterialColorsResponse? _lastData;
  String? _lastMaterialId;
  int? _lastMyRating;
  bool _lastIsFavorite = false;

  void _cacheLoaded(DetailState s) {
    if (s is DetailLoaded) {
      _lastData = s.data;
      _lastMaterialId = s.currentMaterialId;
      _lastMyRating = s.myRating;
      _lastIsFavorite = s.isFavorite;
    }
  }

  Future<void> _onFetchRequested(
    DetailFetchRequested event,
    Emitter<DetailState> emit,
  ) async {
    emit(DetailLoading());
    try {
      final data = await useCase(
        furnitureMaterialId: event.furnitureMaterialId,
      );
      final loaded = DetailLoaded(
        data: data,
        currentMaterialId: event.furnitureMaterialId,
        isFavorite: data.isFavorited,
      );
      _cacheLoaded(loaded);
      emit(loaded);
    } catch (e) {
      emit(DetailError(message: e.toString()));
    }
  }

  Future<void> _onMyRatingRequested(
    DetailMyRatingRequested event,
    Emitter<DetailState> emit,
  ) async {
    final current = state;
    if (current is! DetailLoaded) return;
    try {
      final score = await getMyRatingUseCase(
        furnitureMaterialId: event.furnitureMaterialId,
      );
      final loaded = DetailLoaded(
        data: current.data,
        currentMaterialId: current.currentMaterialId,
        myRating: score,
        isFavorite: current.isFavorite,
      );
      _cacheLoaded(loaded);
      emit(loaded);
    } catch (_) {}
  }

  Future<void> _onRateSubmitted(
    DetailRateSubmitted event,
    Emitter<DetailState> emit,
  ) async {
    final current = state;
    if (current is! DetailLoaded) return;
    try {
      final result = await rateFurnitureMaterialUseCase(
        furnitureMaterialId: event.furnitureMaterialId,
        score: event.score,
      );
      final updatedData = current.data.copyWithStats(
        avgRating: result.avgRating,
        ratingCount: result.ratingCount,
      );
      final loaded = DetailLoaded(
        data: updatedData,
        currentMaterialId: current.currentMaterialId,
        myRating: result.userScore,
        isFavorite: current.isFavorite,
      );
      _cacheLoaded(loaded);
      emit(loaded);
    } catch (_) {}
  }

  Future<void> _onTryInRoom(
    DetailTryInRoomRequested event,
    Emitter<DetailState> emit,
  ) async {
    if (_lastData == null || _lastMaterialId == null) return;
    emit(DetailAiProcessing(
      data: _lastData!,
      currentMaterialId: _lastMaterialId!,
    ));
    try {
      final base64Image = await tryInRoomUseCase(
        roomImagePath: event.roomImagePath,
        furnitureImageUrl: event.furnitureImageUrl,
      );
      emit(DetailAiSuccess(
        base64Image: base64Image,
        data: _lastData!,
        currentMaterialId: _lastMaterialId!,
        myRating: _lastMyRating,
      ));
    } on dio_pkg.DioException catch (e) {
      final code = e.response?.statusCode;
      String msg;
      if (code == 429) {
        msg = 'limit_exceeded';
      } else if (code == 400) {
        msg = 'bad_request';
      } else {
        msg = 'server_error';
      }
      emit(DetailAiError(
        message: msg,
        data: _lastData!,
        currentMaterialId: _lastMaterialId!,
        myRating: _lastMyRating,
      ));
    } catch (_) {
      emit(DetailAiError(
        message: 'error',
        data: _lastData!,
        currentMaterialId: _lastMaterialId!,
        myRating: _lastMyRating,
      ));
    }
  }

  Future<void> _onFavoriteToggled(
    DetailFavoriteToggled event,
    Emitter<DetailState> emit,
  ) async {
    final current = state;
    if (current is! DetailLoaded) return;
    final newFav = !current.isFavorite;
    final optimistic = DetailLoaded(
      data: current.data,
      currentMaterialId: current.currentMaterialId,
      myRating: current.myRating,
      isFavorite: newFav,
    );
    _cacheLoaded(optimistic);
    emit(optimistic);
    try {
      await toggleFavoriteUseCase(
        furnitureMaterialId: event.furnitureMaterialId,
        isFavorite: newFav,
      );
    } catch (_) {
      final reverted = DetailLoaded(
        data: current.data,
        currentMaterialId: current.currentMaterialId,
        myRating: current.myRating,
        isFavorite: !newFav,
      );
      _cacheLoaded(reverted);
      emit(reverted);
    }
  }
}
