import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination.freezed.dart';

abstract interface class JsonRequestFilter {
  Map<String, Object?> toJson();
}

enum SortDirection { asc, desc }

extension SortDirectionX on SortDirection {
  String get wireName => switch (this) {
    SortDirection.asc => 'asc',
    SortDirection.desc => 'desc',
  };

  static SortDirection fromWireName(String? value) => switch (value) {
    'asc' => SortDirection.asc,
    _ => SortDirection.desc,
  };
}

@Assert('page > 0', 'page must be greater than zero')
@Assert('pageSize > 0', 'pageSize must be greater than zero')
@freezed
abstract class PaginationRequest<T extends JsonRequestFilter>
    with _$PaginationRequest<T> {
  const PaginationRequest._();

  const factory PaginationRequest({
    @Default(1) int page,
    @Default(20) int pageSize,
    String? cursor,
    String? searchTerm,
    String? orderBy,
    @Default(SortDirection.desc) SortDirection sortDirection,
    T? filter,
  }) = _PaginationRequest<T>;

  static const reservedKeys = <String>{
    'page',
    'page_size',
    'pageSize',
    'take',
    'cursor',
    'search',
    'searchTerm',
    'order',
    'orderBy',
    'order_by',
    'sortDirection',
  };

  factory PaginationRequest.fromJson(
    Map<String, Object?> json, {
    T Function(Map<String, Object?> json)? filterFromJson,
  }) {
    final filterJson = Map<String, Object?>.from(json)
      ..removeWhere((key, _) => reservedKeys.contains(key));

    return PaginationRequest<T>(
      page: _readPositiveInt(json['page']) ?? 1,
      pageSize:
          _readPositiveInt(
            json['page_size'] ?? json['pageSize'] ?? json['take'],
          ) ??
          20,
      cursor: _readString(json['cursor']),
      searchTerm: _readString(json['search'] ?? json['searchTerm']),
      orderBy: _readString(json['order_by'] ?? json['orderBy']),
      sortDirection: SortDirectionX.fromWireName(
        _readString(json['order'] ?? json['sortDirection']),
      ),
      filter:
          filterFromJson != null && filterJson.isNotEmpty
              ? filterFromJson(filterJson)
              : null,
    );
  }
}

extension PaginationRequestX<T extends JsonRequestFilter>
    on PaginationRequest<T> {
  Map<String, Object?> toJson() {
    final json = <String, Object?>{
      'page': page,
      'page_size': pageSize,
      'order': sortDirection.wireName,
    };

    if (cursor != null && cursor!.isNotEmpty) {
      json['cursor'] = cursor;
    }
    if (searchTerm != null && searchTerm!.isNotEmpty) {
      json['search'] = searchTerm;
    }
    if (orderBy != null && orderBy!.isNotEmpty) {
      json['order_by'] = orderBy;
    }
    if (filter == null) {
      return json;
    }

    for (final entry in filter!.toJson().entries) {
      if (PaginationRequest.reservedKeys.contains(entry.key)) {
        throw ArgumentError(
          'Filter key "${entry.key}" conflicts with reserved pagination keys.',
        );
      }
      if (entry.value == null) {
        continue;
      }
      json[entry.key] = entry.value;
    }

    return json;
  }

  PaginationRequest<T> nextPage({String? nextCursor}) {
    return PaginationRequest<T>(
      page: page + 1,
      pageSize: pageSize,
      cursor: nextCursor ?? cursor,
      searchTerm: searchTerm,
      orderBy: orderBy,
      sortDirection: sortDirection,
      filter: filter,
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

  factory PaginatedResponse.fromJson(
    Map<String, Object?> json,
    T Function(Object? json) fromJsonT,
  ) {
    final rawItems = switch (json['items'] ?? json['data']) {
      final List<Object?> values => values,
      _ => const <Object?>[],
    };

    return PaginatedResponse<T>(
      items: rawItems.map(fromJsonT).toList(),
      page: _readPositiveInt(json['page'] ?? json['currentPage']) ?? 1,
      pageSize:
          _readPositiveInt(
            json['page_size'] ?? json['pageSize'] ?? json['itemsPerPage'],
          ) ??
          rawItems.length,
      totalItems: _readInt(json['total_items'] ?? json['totalItems']),
      nextCursor: _readString(json['next_cursor'] ?? json['nextCursor']),
    );
  }
}

extension PaginatedResponseX<T> on PaginatedResponse<T> {
  bool get hasNextPage {
    if (nextCursor != null && nextCursor!.isNotEmpty) {
      return true;
    }
    if (totalItems != null) {
      return page * pageSize < totalItems!;
    }
    return items.length == pageSize;
  }

  bool get hasPreviousPage => page > 1;

  int get nextPageNumber => hasNextPage ? page + 1 : page;

  Map<String, Object?> toJson(Object? Function(T value) toJsonT) {
    return <String, Object?>{
      'items': items.map(toJsonT).toList(),
      'page': page,
      'page_size': pageSize,
      if (totalItems != null) 'total_items': totalItems,
      if (nextCursor != null) 'next_cursor': nextCursor,
    };
  }
}

int? _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

int? _readPositiveInt(Object? value) {
  final parsed = _readInt(value);
  if (parsed == null || parsed <= 0) {
    return null;
  }
  return parsed;
}

String? _readString(Object? value) {
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }
  return null;
}
