abstract class ILocalStorageRepository<T> {
  /// Initialize the repository (e.g. open the box)
  Future<void> init();

  /// Get all records
  Future<List<T>> getAll();

  /// Get a single record by id
  Future<T?> getById(String id);

  /// Save or update a record
  Future<void> save(String id, T item);

  /// Delete a record
  Future<void> delete(String id);

  /// Clear all records
  Future<void> clearAll();
}
