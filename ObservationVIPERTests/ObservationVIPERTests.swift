//
//  ObservationVIPERTests.swift
//  ObservationVIPERTests
//
//  Created by sakiyamaK on 2024/09/21.
//

import XCTest
@testable import ObservationVIPER

extension User {
    static var testList: [User] = [
        .init(
            id: .init(name: "test taro", value: "123"),
            picture: .init(thumbnail: nil)
        ),
        .init(
            id: .init(name: "test hanako", value: "456"),
            picture: .init(thumbnail: nil)
        )
    ]
}

final class UserListPresenterTests: XCTestCase {
    
    @Observable
    final class MockSomeUserListInteractor: UserListInteractor {
        deinit { print("\(Self.self) deinit") }

        public private(set) var loading: Bool = false
        public private(set) var users: [User]?
        public var initilalLoading: Bool {
            users == nil && loading
        }
        public var refreshLoading: Bool {
            users != nil && loading
        }

        public func fetch() async {
            defer {
                loading = false
            }
            
            do {
                loading = true
                // 0.5秒遅らせる
                let delayInNanoseconds = 500_000_000 // 500ミリ秒をナノ秒に変換
                try await Task.sleep(nanoseconds: UInt64(delayInNanoseconds))
                users = User.testList
            } catch _ {
                users = []
            }
        }
        
        public func set(users: [User]) {
            self.users = users
        }
    }
    
    @Observable
    final class MockRouter: UserListRouter {
        var user: User?
        func show(user: User) {
            self.user = user
        }
    }
    
    func test_ユーザ情報の取得() async throws {
        let view = await UserListViewImpl()
        let mockIntearctor = MockSomeUserListInteractor()
        let router = MockRouter()
        let presenter = UserListPresenterImpl(view: view, interactor: mockIntearctor, router: router)
        await view.inject(presenter: presenter)
        

        XCTAssertTrue(presenter.users.isEmpty)
        XCTAssertFalse(presenter.initilalLoading)
        XCTAssertFalse(presenter.refreshLoading)

        presenter.viewDidLoad()

        try await Task.sleep(nanoseconds: 000_000_100)

        XCTAssertTrue(presenter.initilalLoading)
        XCTAssertFalse(presenter.refreshLoading)

        try await Task.sleep(nanoseconds: 550_000_000)

        XCTAssertFalse(presenter.initilalLoading)
        XCTAssertFalse(presenter.refreshLoading)

        XCTAssertTrue(!presenter.users.isEmpty)
    }
    
    func test_ひっぱりリロード() async throws {
        let view = await UserListViewImpl()
        let mockIntearctor = MockSomeUserListInteractor()
        let router = UserListRouterImpl(view: view)
        let presenter = UserListPresenterImpl(view: view, interactor: mockIntearctor, router: router)
        await view.inject(presenter: presenter)
        
        mockIntearctor.set(users: User.testList)

        XCTAssertFalse(presenter.initilalLoading)
        XCTAssertFalse(presenter.refreshLoading)

        presenter.changeValueRefreshControl()
        
        try await Task.sleep(nanoseconds: 000_000_100)

        XCTAssertFalse(presenter.initilalLoading)
        XCTAssertTrue(presenter.refreshLoading)

        try await Task.sleep(nanoseconds: 550_000_000)

        XCTAssertFalse(presenter.initilalLoading)
        XCTAssertFalse(presenter.refreshLoading)

        XCTAssertTrue(!presenter.users.isEmpty)
    }
    
    func test_ユーザの選択() async throws {
        let view = await UserListViewImpl()
        let mockIntearctor = MockSomeUserListInteractor()
        let router = MockRouter()
        let presenter = UserListPresenterImpl(view: view, interactor: mockIntearctor, router: router)
        await view.inject(presenter: presenter)
        
        mockIntearctor.set(users: User.testList)

        presenter.select(indexPath: .init(item: 0, section: 0))
        
        XCTAssertTrue(router.user == User.testList.first)

        presenter.select(indexPath: .init(item: 1, section: 0))

        XCTAssertTrue(router.user == User.testList[1])
    }
}
