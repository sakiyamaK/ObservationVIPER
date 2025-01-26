//
//  UserListPresenter.swift
//  
//
//  Created by sakiyamaK on 2024/09/16.
//

import Foundation

@MainActor
public protocol UserListPresenter {
    var initilalLoading: Bool { get }
    var refreshLoading: Bool { get }
    var users: [User] { get }
    
    func viewDidLoad()
    func select(indexPath: IndexPath)
    func changeValueRefreshControl()
}

@Observable
public final class UserListPresenterImpl: UserListPresenter {
    
    deinit { print("\(Self.self) deinit") }

    public var initilalLoading: Bool {
        interactor.initilalLoading
    }
    public var refreshLoading: Bool {
        interactor.refreshLoading
    }
    public var users: [User] {
        interactor.users ?? []
    }
    
    private let interactor: UserListInteractor
    private let router: UserListRouter
        
    init(
        interactor: UserListInteractor,
        router: UserListRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    public func viewDidLoad() {
        Task {
            await self.interactor.fetch()
        }
    }

    public func changeValueRefreshControl() {
        Task {
            await self.interactor.fetch()
        }
    }

    public func select(indexPath: IndexPath) {
        router.show(user: users[indexPath.item])
    }    
}
