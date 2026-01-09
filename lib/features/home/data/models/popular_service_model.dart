import '../../domain/entities/popular_service.dart';

class PopularServiceModel extends PopularService {
  const PopularServiceModel({
    required super.id,
    required super.title,
    required super.priceRs,
    required super.categoryTag,
  });

  factory PopularServiceModel.fromEntity(PopularService service) {
    return PopularServiceModel(
      id: service.id,
      title: service.title,
      priceRs: service.priceRs,
      categoryTag: service.categoryTag,
    );
  }

  PopularService toEntity() {
    return PopularService(
      id: id,
      title: title,
      priceRs: priceRs,
      categoryTag: categoryTag,
    );
  }
}
