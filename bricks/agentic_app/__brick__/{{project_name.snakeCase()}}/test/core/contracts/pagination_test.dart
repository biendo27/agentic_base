import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name.snakeCase()}}/core/contracts/pagination.dart';

final class _ExampleFilter implements JsonRequestFilter {
  const _ExampleFilter({required this.category});

  final String category;

  @override
  Map<String, Object?> toJson() => <String, Object?>{'category': category};
}

void main() {
  test('serializes pagination requests with shared query fields', () {
    const request = PaginationRequest<_ExampleFilter>(
      page: 2,
      pageSize: 50,
      searchTerm: 'starter',
      orderBy: 'created_at',
      sortDirection: SortDirection.asc,
      filter: _ExampleFilter(category: 'demo'),
    );

    expect(
      request.toJson(),
      <String, Object?>{
        'page': 2,
        'page_size': 50,
        'order': 'asc',
        'search': 'starter',
        'order_by': 'created_at',
        'category': 'demo',
      },
    );
    expect(request.nextPage().page, 3);
  });

  test('rejects filter keys that collide with reserved pagination fields', () {
    final request = PaginationRequest<_ConflictingFilter>(
      filter: const _ConflictingFilter(),
    );

    expect(request.toJson, throwsArgumentError);
  });

  test('derives pagination response helpers from the envelope', () {
    final response = PaginatedResponse<int>.fromJson(
      <String, Object?>{
        'items': <Object?>[1, 2, 3],
        'page': 1,
        'page_size': 3,
        'total_items': 9,
      },
      (json) => json as int,
    );

    expect(response.hasPreviousPage, isFalse);
    expect(response.hasNextPage, isTrue);
    expect(response.nextPageNumber, 2);
    expect(
      response.toJson((value) => value),
      <String, Object?>{
        'items': <Object?>[1, 2, 3],
        'page': 1,
        'page_size': 3,
        'total_items': 9,
      },
    );
  });
}

final class _ConflictingFilter implements JsonRequestFilter {
  const _ConflictingFilter();

  @override
  Map<String, Object?> toJson() => <String, Object?>{'page': 99};
}
