final class PaginationRequest {
  const PaginationRequest({
    this.page = 1,
    this.pageSize = 20,
    this.cursor,
  }) : assert(page > 0, 'page must be greater than zero'),
       assert(pageSize > 0, 'pageSize must be greater than zero');

  final int page;
  final int pageSize;
  final String? cursor;

  PaginationRequest nextPage({String? nextCursor}) {
    return PaginationRequest(
      page: page + 1,
      pageSize: pageSize,
      cursor: nextCursor ?? cursor,
    );
  }
}

final class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    this.totalItems,
    this.nextCursor,
  }) : assert(page > 0, 'page must be greater than zero'),
       assert(pageSize > 0, 'pageSize must be greater than zero');

  final List<T> items;
  final int page;
  final int pageSize;
  final int? totalItems;
  final String? nextCursor;

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
