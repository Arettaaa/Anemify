import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<List<Profile>> getAll();
  Future<Profile?> getActive();
  Future<void> add(Profile profile, {bool setActive = false});
  Future<void> update(Profile profile);
  Future<void> setActive(String id);
}