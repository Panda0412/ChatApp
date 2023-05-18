//
//  NetworkPhotosCollectionViewController.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 25.04.2023.
//

import UIKit

private enum Constants {
    static let itemCountInRow: CGFloat = 3
    static let spacing: CGFloat = 1.5
    static let cellIdentifier = "photosCollectionViewCell"
}

class NetworkPhotosCollectionViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewIsReady()
        
        setupUI()
    }
    
    init(output: NetworkPhotosCollectionViewOutput) {
        self.presenter = output
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    private let presenter: NetworkPhotosCollectionViewOutput
    
    private lazy var photosCollectionView = UICollectionView(frame: view.frame, collectionViewLayout: UICollectionViewLayout())
    private var imageList = [NetworkImage]()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - UI Elements
    
    private lazy var errorAlert: UIAlertController = {
        let alert = UIAlertController(title: "Ooops!", message: "Something went wrong :c", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self else { return }
            self.closeModal()
        }

        alert.addAction(dismissAction)

        return alert
    }()
    
    // MARK: - Setup
    
    private func setupCollectionView() {
        photosCollectionView.backgroundColor = .systemBackground
        photosCollectionView.showsVerticalScrollIndicator = false
        photosCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: Constants.spacing, left: Constants.spacing, bottom: Constants.spacing, right: Constants.spacing)
        layout.minimumInteritemSpacing = Constants.spacing
        layout.minimumLineSpacing = Constants.spacing
        layout.itemSize = CGSize(
            width: (view.frame.width - (Constants.itemCountInRow + 1) * Constants.spacing) / Constants.itemCountInRow,
            height: (view.frame.width - (Constants.itemCountInRow + 1) * Constants.spacing) / Constants.itemCountInRow
        )
        photosCollectionView.setCollectionViewLayout(layout, animated: false)
        
        photosCollectionView.register(PhotosCollectionViewCell.self, forCellWithReuseIdentifier: Constants.cellIdentifier)
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
        
        view.addSubview(photosCollectionView)

        NSLayoutConstraint.activate([
            photosCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            photosCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            photosCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            photosCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
    }
    
    private func setupUI() {
        title = "Select photo"
        navigationItem.setLeftBarButton(UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(closeModal)), animated: false)
        
        view.backgroundColor = .systemBackground
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
    
    // MARK: - Helpers
    
    @objc private func closeModal() {
        dismiss(animated: true)
    }
}

extension NetworkPhotosCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as? PhotosCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let imageItem = imageList[indexPath.row]
        
        cell.configure(with: imageItem)
        
        if imageItem.image != nil {
            return cell
        }
        
        DispatchQueue.global().async {
            self.presenter.loadImageData(for: imageItem) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let data):
                    let model = NetworkImage(color: imageItem.color, url: imageItem.url, image: UIImage(data: data))
                    cell.configure(with: model)
                    self.imageList[indexPath.row] = model
                case .failure:
                    break
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didSelectItem(imageList[indexPath.row])
    }
}

extension NetworkPhotosCollectionViewController: NetworkPhotosCollectionViewInput {
    func showData(_ images: [NetworkImage]) {
        imageList = images
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        setupCollectionView()
    }

    func showAlert() {
        present(errorAlert, animated: true)
    }
}
