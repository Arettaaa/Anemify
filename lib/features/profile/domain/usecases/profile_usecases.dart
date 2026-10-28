import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class GetProfiles {
  final ProfileRepository _repo;
  GetProfiles(this._repo);
  Future<List<Profile>> call() => _repo.getAll();
}

class GetActiveProfile {
  final ProfileRepository _repo;
  GetActiveProfile(this._repo);
  Future<Profile?> call() => _repo.getActive();
}

class AddProfile {
  final ProfileRepository _repo;
  AddProfile(this._repo);
  Future<void> call(Profile p, {bool setActive = false}) =>
      _repo.add(p, setActive: setActive);
}

class UpdateProfile {
  final ProfileRepository _repo;
  UpdateProfile(this._repo);
  Future<void> call(Profile p) => _repo.update(p);
}

class SetActiveProfile {
  final ProfileRepository _repo;
  SetActiveProfile(this._repo);
  Future<void> call(String id) => _repo.setActive(id);
}