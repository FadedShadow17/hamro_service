import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/contact_repository_impl.dart';

final contactRepositoryProvider = Provider<ContactRepositoryImpl>((ref) {
  throw UnimplementedError('contactRepositoryProvider must be overridden');
});
