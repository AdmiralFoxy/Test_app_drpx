//
//  MediaFilesModelTests.swift
//  Test_app_drpxTests
//
//  Created by Stanislav Avramenko on 07/09/2023.
//

import XCTest
import CombineExpectations
import SwiftyDropbox
@testable import Test_app_drpx

final class MediaFilesModelTests: XCTestCase {

    private var model: MediaFilesModel?
    private var dropboxServiceMock: DropboxServiceMock?
    private var dropboxCacheServiceMock: DropboxCacheServiceMock?

    private let parent: NavigationNode? = nil
    
    override func setUp() {
        super.setUp()
        
        dropboxServiceMock = DropboxServiceMock()
        dropboxCacheServiceMock = DropboxCacheServiceMock()
        
        model = MediaFilesModel(
            parent: parent,
            dropboxService: dropboxServiceMock!,
            dropboxCacheService: dropboxCacheServiceMock!
        )
    }

    override func tearDown() {
        model = nil
        dropboxServiceMock = nil
        dropboxCacheServiceMock = nil
        
        super.tearDown()
    }

    func test_initialState() {
        XCTAssertEqual(
            model?.mediaFiles.value,
            [],
            "Initial mediaFiles should be empty"
        )
        XCTAssertEqual(
            model?.viewState.value,
            .idle,
            "Initial viewState should be idle"
        )
    }
    
    func test_cellTapAction_withInvalidFormat() {
        let invalidFilePath = FilePath(path: "invalid_format")
        
        model?.cellTapAction.send(invalidFilePath)
        
        XCTAssertEqual(model?.viewState.value, ViewState.onFailure("error file format"), "ViewState should indicate an error for invalid file format")
    }
    
}
