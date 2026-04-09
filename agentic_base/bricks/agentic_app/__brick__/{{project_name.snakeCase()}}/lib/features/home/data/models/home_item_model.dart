import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_item_model.freezed.dart';
part 'home_item_model.g.dart';

@freezed
abstract class HomeItemModel with _$HomeItemModel {
  const factory HomeItemModel({
    required String id,
    required String title,
    required String description,
    @Default('') String imageUrl,
  }) = _HomeItemModel;

  factory HomeItemModel.fromJson(Map<String, dynamic> json) =>
      _$HomeItemModelFromJson(json);
}
