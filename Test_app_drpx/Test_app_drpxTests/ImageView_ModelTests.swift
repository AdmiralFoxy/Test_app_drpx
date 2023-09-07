//
//  Test_app_drpxTests.swift
//  Test_app_drpxTests
//
//  Created by Stanislav Avramenko on 30/08/2023.
//

import XCTest
import CombineExpectations
@testable import Test_app_drpx

final class ImageView_ModelTests: XCTestCase {
    
    private var model: ImageView_Model?
    private let parent: NavigationNode? = nil
    private var dropboxService: DropboxServiceMock?
    
    override func setUp() {
        super.setUp()
        
        dropboxService = DropboxServiceMock()
        model = ImageView_Model(
            parent: parent,
            path: FilePath(path: ""),
            dropboxService: dropboxService!
        )
    }
    
    override func tearDown() {
        model = nil
        dropboxService = nil
        
        super.tearDown()
    }
    
}

extension ImageView_ModelTests {
    
    func test_loadFileDataViewStateHandle() {
        let file = MediaFile(name: "_", path: "__")
        let service = DropboxServiceMock(downloadFileResult: .success(file))
        let model = ImageView_Model(
            parent: nil,
            path: .init(path: ""),
            dropboxService: service
        )
        
        let recorder = model.viewState.record()
        _ = model.loadFileData(FilePath(path: ""))
        
        do {
            let items = try wait(for: recorder.next(2), timeout: 3.0)
            
            XCTAssertEqual(items[1], .loading, "second state should still be '.loading' as the file is being loaded but not yet set")
        } catch {
            XCTFail("Failed to receive items: \(error)")
        }
    }
    
    func test_initialFileInfoState() {
        let model = ImageView_Model(
            parent: nil,
            path: .init(path: ""),
            dropboxService: DropboxServiceMock()
        )
        
        XCTAssertNil(model.fileInfo.value, "Initial fileInfo should be nil")
    }
    
    func test_loadFileDataAndSetupFileInfoAction() {
        let testData = Data("Test data".utf8)
        let file = MediaFile(name: "test_1_0", path: "none any path", data: testData)
        let service = DropboxServiceMock(downloadFileResult: .success(file))
        
        let model = ImageView_Model(
            parent: nil,
            path: .init(path: ""),
            dropboxService: service
        )
        
        let recorder = model.fileInfo.record()
        _ = model.loadFileData(FilePath(path: ""))
        
        do {
            let items = try wait(for: recorder.next(1), timeout: 3.0)
            
            XCTAssertEqual(items[0]?.name, "test_1_0", "fileInfo should be updated with the correct name")
        } catch {
            XCTFail("Failed to receive items: \(error)")
        }
    }
    
}
