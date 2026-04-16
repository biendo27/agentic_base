import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination.freezed.dart';

@Assert('page > 0', 'page must be greater than zero')
@Assert('pageSize > 0', 'pageSize must be greater than zero')
@freezed
abstract class PaginationRequest with _$PaginationRequest {
  const PaginationRequest._();

  const factory PaginationRequest({
    @Default(1) int page,
    @Default(20) int pageSize,
    String? cursor,
  }) = _PaginationRequest;

  PaginationRequest nextPage({String? nextCursor}) {
    return PaginationRequest(
      page: page + 1,
      pageSize: pageSize,
      cursor: nextCursor ?? cursor,
    );
  }
}

@Assert('page > 0', 'page must be greater than zero')
@Assert('pageSize > 0', 'pageSize must be greater than zero')
@freezed
abstract class PaginatedResponse<T> with _$PaginatedResponse<T> {
  const PaginatedResponse._();

  const factory PaginatedResponse({
    required List<T> items,
    required int page,
    required int pageSize,
    int? totalItems,
    String? nextCursor,
  }) = _PaginatedResponse<T>;

  bool get hasNextPage {
    if (nextCursor != null && nextCursor!.isNotEmpty) {
      return true;
    }
    if (totalItems != null) {
      return page * pageSize < totalItems!;
    }
    return items.length == pageSize;
  }
}
