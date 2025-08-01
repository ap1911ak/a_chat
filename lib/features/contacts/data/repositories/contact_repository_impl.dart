import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/contact.dart';
import '../../domain/repositories/contact_repository.dart';
import '../datasources/contact_remote_datasource.dart';
import '../models/contact_model.dart';

class ContactRepositoryImpl implements ContactRepository {
  final ContactRemoteDataSource remoteDataSource;

  ContactRepositoryImpl({required this.remoteDataSource});

 @override
  Stream<Either<Failure, List<ContactEntity>>> getContacts(String userId) async* {
    try {
      // 1. รับ Stream ของ List<ContactModel> จาก remoteDataSource
      final streamOfContactModels = remoteDataSource.getContacts(userId);

      // 2. ใช้ await for เพื่อวนลูปรับค่าจาก Stream
      await for (final List<ContactModel> models in streamOfContactModels) {
        // 3. แปลง List<ContactModel> ไปเป็น List<ContactEntity>
        final List<ContactEntity> entities = models.map((model) => model.toEntity()).toList(); // ใช้ toEntity()
        // 4. ส่งค่าที่สำเร็จพร้อม Either.right
        yield Right(entities);
      }
    } on ServerException catch (e) {
      // 5. จับ ServerException ที่อาจจะถูก throw มาจาก DataSource (เช่นใน addContact)
      //    หรืออาจจะไม่ได้ใช้แล้วถ้า DataSource ไม่ throw
      yield Left(ServerFailure(e.message)); // ส่ง Failure พร้อมข้อความ error
    } on Exception catch (e) {
      // 6. จับ Exception อื่นๆ ที่อาจจะเกิดขึ้น (เช่น network error ที่ไม่ได้ถูกแปลงใน DataSource)
      yield Left(ServerFailure(e.toString())); // หรือ UnknownFailure() ถ้ามี
    }
  }

  @override
  Future<Either<Failure, void>> addContact(String currentUserId, String contactEmail) async {
    try {
      await remoteDataSource.addContact(currentUserId, contactEmail);
      return Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}