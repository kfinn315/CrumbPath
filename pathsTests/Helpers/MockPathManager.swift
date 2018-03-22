//
import RxSwift
import RxCocoa
@testable import paths

class MockPathManager : IPathManager {
    var invokedCurrentPathObservableGetter = false
    var invokedCurrentPathObservableGetterCount = 0
    var stubbedCurrentPathObservable: Observable<IPath?>!
    var currentPathObservable : Observable<IPath?>? {
        invokedCurrentPathObservableGetter = true
        invokedCurrentPathObservableGetterCount += 1
        return stubbedCurrentPathObservable
    }
    var invokedHasNewPathSetter = false
    var invokedHasNewPathSetterCount = 0
    var invokedHasNewPath: Bool?
    var invokedHasNewPathList = [Bool]()
    var invokedHasNewPathGetter = false
    var invokedHasNewPathGetterCount = 0
    var stubbedHasNewPath: Bool! = false
    var hasNewPath : Bool {
        set {
            invokedHasNewPathSetter = true
            invokedHasNewPathSetterCount += 1
            invokedHasNewPath = newValue
            invokedHasNewPathList.append(newValue)
        }
        get {
            invokedHasNewPathGetter = true
            invokedHasNewPathGetterCount += 1
            return stubbedHasNewPath
        }
    }
    var invokedUpdateCurrentAlbum = false
    var invokedUpdateCurrentAlbumCount = 0
    var invokedUpdateCurrentAlbumParameters: (collectionid: String, Void)?
    var invokedUpdateCurrentAlbumParametersList = [(collectionid: String, Void)]()
    func updateCurrentAlbum(collectionid: String) {
        invokedUpdateCurrentAlbum = true
        invokedUpdateCurrentAlbumCount += 1
        invokedUpdateCurrentAlbumParameters = (collectionid, ())
        invokedUpdateCurrentAlbumParametersList.append((collectionid, ()))
    }
    var invokedSetCurrentPath = false
    var invokedSetCurrentPathCount = 0
    var invokedSetCurrentPathParameters: (path: IPath?, Void)?
    var invokedSetCurrentPathParametersList = [(path: IPath?, Void)]()
    func setCurrentPath(_ path: IPath?) {
        invokedSetCurrentPath = true
        invokedSetCurrentPathCount += 1
        invokedSetCurrentPathParameters = (path, ())
        invokedSetCurrentPathParametersList.append((path, ()))
    }
    var invokedGetNewPath = false
    var invokedGetNewPathCount = 0
    var stubbedGetNewPathResult: Path!
    func getNewPath() -> Path {
        invokedGetNewPath = true
        invokedGetNewPathCount += 1
        return stubbedGetNewPathResult
    }
    var invokedSave = false
    var invokedSaveCount = 0
    var invokedSaveParameters: (path: IPath?, Void)?
    var invokedSaveParametersList = [(path: IPath?, Void)]()
    var stubbedSaveCallbackResult: (IPath?, Error?)?
    func save(path: IPath?, callback: @escaping (IPath?,Error?) -> Void) {
        invokedSave = true
        invokedSaveCount += 1
        invokedSaveParameters = (path, ())
        invokedSaveParametersList.append((path, ()))
        if let result = stubbedSaveCallbackResult {
            callback(result.0, result.1)
        }
    }
    var invokedUpdateCurrentPathInCoreData = false
    var invokedUpdateCurrentPathInCoreDataCount = 0
    var invokedUpdateCurrentPathInCoreDataParameters: (notify: Bool, Void)?
    var invokedUpdateCurrentPathInCoreDataParametersList = [(notify: Bool, Void)]()
    func updateCurrentPathInCoreData(notify: Bool) {
        invokedUpdateCurrentPathInCoreData = true
        invokedUpdateCurrentPathInCoreDataCount += 1
        invokedUpdateCurrentPathInCoreDataParameters = (notify, ())
        invokedUpdateCurrentPathInCoreDataParametersList.append((notify, ()))
    }
    var invokedGetAllPaths = false
    var invokedGetAllPathsCount = 0
    var stubbedGetAllPathsResult: [Path]!
    func getAllPaths() -> [Path]? {
        invokedGetAllPaths = true
        invokedGetAllPathsCount += 1
        return stubbedGetAllPathsResult
    }
}
