import 'package:core/core.dart';
import 'package:imports/imports.dart';
import 'package:injectable/injectable.dart';

@module
abstract class ImportsModule {
  @lazySingleton
  ImportsRemoteDataSource importsRemoteDataSource(
    @Named('backend') HttpClient httpClient,
  ) => ImportsRemoteDataSourceImpl(httpClient);

  @lazySingleton
  ImportsRepository importsRepository(
    ImportsRemoteDataSource remoteDataSource,
    WebSocketClient webSocketClient,
  ) => ImportsRepositoryImpl(remoteDataSource, webSocketClient);

  @injectable
  StartImport startImport(ImportsRepository repository) =>
      StartImport(repository);

  @injectable
  GetImport getImport(ImportsRepository repository) => GetImport(repository);

  @injectable
  GetImports getImports(ImportsRepository repository) => GetImports(repository);

  @injectable
  ConfirmImport confirmImport(ImportsRepository repository) =>
      ConfirmImport(repository);

  @injectable
  CancelImport cancelImport(ImportsRepository repository) =>
      CancelImport(repository);

  @injectable
  WatchImportProgress watchImportProgress(ImportsRepository repository) =>
      WatchImportProgress(repository);

  @injectable
  GetUnmatchedItems getUnmatchedItems(ImportsRepository repository) =>
      GetUnmatchedItems(repository);

  @injectable
  ResolveUnmatchedItem resolveUnmatchedItem(ImportsRepository repository) =>
      ResolveUnmatchedItem(repository);
}
