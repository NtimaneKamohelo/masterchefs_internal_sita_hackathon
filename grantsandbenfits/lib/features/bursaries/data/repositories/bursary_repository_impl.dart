import 'package:grantsandbenfits/core/error/failure.dart';
import 'package:grantsandbenfits/core/error/result.dart';
import 'package:grantsandbenfits/features/bursaries/data/datasources/local_bursary_data_source.dart';
import 'package:grantsandbenfits/features/bursaries/domain/entities/bursary_application.dart';
import 'package:grantsandbenfits/features/bursaries/domain/entities/bursary_program.dart';
import 'package:grantsandbenfits/features/bursaries/domain/repositories/bursary_repository.dart';

class BursaryRepositoryImpl implements BursaryRepository {
  BursaryRepositoryImpl(this._dataSource);

  final LocalBursaryDataSource _dataSource;

  @override
  Future<Result<List<BursaryProgram>>> loadBursaries() async {
    try {
      return Ok(await _dataSource.readBursaries());
    } catch (_) {
      return const Err(ValidationFailure('Could not load available bursaries.'));
    }
  }

  @override
  Future<Result<List<BursaryApplication>>> loadApplications(
    String userId,
  ) async {
    try {
      return Ok(await _dataSource.readApplications(userId));
    } catch (_) {
      return const Err(
        ValidationFailure('Could not load your bursary applications.'),
      );
    }
  }

  @override
  Future<Result<BursaryApplication>> submitApplication(
    BursaryApplication application,
  ) async {
    try {
      return Ok(await _dataSource.writeApplication(application));
    } catch (_) {
      return const Err(
        ValidationFailure('Could not submit your application. Please try again.'),
      );
    }
  }
}
