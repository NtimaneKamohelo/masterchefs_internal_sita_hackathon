import 'package:grantsandbenfits/core/error/result.dart';
import 'package:grantsandbenfits/features/bursaries/domain/entities/bursary_application.dart';
import 'package:grantsandbenfits/features/bursaries/domain/entities/bursary_program.dart';

abstract interface class BursaryRepository {
  Future<Result<List<BursaryProgram>>> loadBursaries();

  Future<Result<List<BursaryApplication>>> loadApplications(String userId);

  Future<Result<BursaryApplication>> submitApplication(
    BursaryApplication application,
  );
}
