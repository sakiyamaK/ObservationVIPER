//
//  UserListRouter.swift
//
//
//  Created by sakiyamaK on 2024/09/16.
//

import Foundation

public protocol UserListRouter {
    func show(user: User)
}

public final class UserListRouterImpl: UserListRouter {
    
    deinit { print("\(Self.self) deinit") }

    private unowned var view: UserListView!
    init(view: UserListView!) {
        self.view = view
    }
    
    public static func assembleModules() -> UserListView {
        let view = UserListViewImpl()
        let interactor = UserListInteractorImpl()
        let router = UserListRouterImpl(view: view)
        let presenter = UserListPresenterImpl(
            view: view,
            interactor: interactor,
            router: router
        )
        view.inject(
            presenter: presenter
        )
        return view
    }
    
    public func show(user: User) {
        
    }
}
