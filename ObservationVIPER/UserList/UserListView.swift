//
//  UserListViewController.swift
//  
//
//  Created by sakiyamaK on 2024/09/16.
//

import UIKit
import Kingfisher

public protocol UserListView: UIViewController {
}

public final class UserListViewImpl: UIViewController, UserListView {
    
    private var presenter: UserListPresenter!
    func inject(presenter: UserListPresenter) {
        self.presenter = presenter
    }
    
    private var diffableDataSource: UICollectionViewDiffableDataSource<Int, User>!
    
    private lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewCompositionalLayout.list(using: .init(appearance: .plain))
        let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.refreshControl = UIRefreshControl()
        
        collectionView.refreshControl?.addAction(.init(handler: {[weak self] _ in
            self!.presenter.changeValueRefreshControl()
        }), for: .valueChanged)
        
        return collectionView
    }()
    
    private var activityIndicatorView: UIActivityIndicatorView = .init(style: .large)
    
    public override func viewDidLoad() {
        super.viewDidLoad()
                
        self.setupUI()
        self.setupDataSource()
        self.setupObservation()

        presenter.viewDidLoad()
    }
    
    private func setupUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.applyArroundConstraint(equalTo: self.view)

        self.view.addSubview(collectionView)
        collectionView.applyArroundConstraint(equalTo: self.view)
    }
    
    private func setupObservation() {
        collectionView
            .observation(
                tracking: {[weak self] in
                    self!.presenter.initilalLoading
                },
                onChange: { collectionView, loading in
                    collectionView.isHidden = loading
                }
            ).observation(
                tracking: {[weak self] in
                    self!.presenter.refreshLoading
                }, onChange: { collectionView, refreshLoading in
                    collectionView.refreshControl?.endRefreshing()
                }
            ).observation(
                tracking: {[weak self] in
                    self!.presenter.users
                }, onChange: {[weak self] _, users in
                    
                    var snapshot = NSDiffableDataSourceSnapshot<Int, User>()
                    snapshot.appendSections([0])
                    snapshot.appendItems(users)
                    self!.diffableDataSource.apply(snapshot, animatingDifferences: false)
                }
            )
        
        activityIndicatorView
            .observation(
                tracking: {[weak self] in
                    self!.presenter.initilalLoading
                }, onChange: { activityIndicatorView, loading in
                    if loading {
                        activityIndicatorView.startAnimating()
                    } else {
                        activityIndicatorView.stopAnimating()
                    }
                }
            )
    }
    
    private func setupDataSource() {
        
        let imageSize = CGSize(width: 40, height: 40)
        let dummyImage = UIImage.createImage(with: imageSize, color: .clear)
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, User> { cell, indexPath, item in
            
            var config = UIListContentConfiguration.cell()
            
            config.text = item.id.displayName
            config.imageProperties.maximumSize = imageSize
            config.imageProperties.reservedLayoutSize = imageSize
            config.image = dummyImage
            cell.contentConfiguration = config
            
            Task {
                guard let urlStr = item.picture.thumbnail, let url = URL(string: urlStr) else { return }
                guard let image = try? await KingfisherManager.shared.asyncRetrieveImage(with: url)
                else { return }
                config.image = image
                cell.contentConfiguration = config
            }
        }
        
        diffableDataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: itemIdentifier
            )
        }
    }
}

extension UserListViewImpl: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.select(indexPath: indexPath)
    }
}

#Preview {
    MainActor.assumeIsolated {
        UserListRouterImpl.assembleModules()
    }
}
