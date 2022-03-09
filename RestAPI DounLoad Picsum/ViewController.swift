//
//  ViewController.swift
//  RestAPI DounLoad Picsum
//
//  Created by Gevorg Hovhannisyan on 06.10.21.
//

import UIKit

class ViewController: UIViewController {
    
    var collectionView: UICollectionView
    
    var images = [ImageURL]()
    var dounLoadImages = [IndexPath: UIImage]()
    var spacing: CGFloat = 8

    
    required init?(coder: NSCoder) {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let layout = UICollectionViewFlowLayout.init()
        layout.sectionInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        layout.minimumLineSpacing = 8
        layout.itemSize = .init(width: 200, height: 200)
        collectionView = UICollectionView(frame: rect, collectionViewLayout: layout)
        collectionView.backgroundColor = .brown
        super.init(coder: coder)
    }
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - CollectionView Register
        view.addSubview(collectionView)
        collectionView.register(UINib(nibName: "MyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        getImages()
        
    }
    
    func getImages() {
        
        RequestManager.getImages(for: RequestManager.currentPage) {parsedImages, error in DispatchQueue.main.async {
            if error != nil {
                
                return
            }
            
            self.images += parsedImages!
            self.collectionView.reloadData()
            self.title = "\(RequestManager.currentPage += 1)"
            RequestManager.currentPage += 1
            
        }
    }
}

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.frame = view.bounds
        
    }
}

//MARK: - Extensions

extension ViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let imageURL = images[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! MyCollectionViewCell
        
        cell.imageView.image = nil
        if let image = dounLoadImages[indexPath] {
            cell.imageView.image = image
            
            return cell
        }
        
        let oldIndexPath = indexPath
        DispatchQueue.global().async {
            
            let urlString = "https://picsum.photos/id/\(imageURL.id)/200/300"
            if let data = try? Data.init(contentsOf: URL .init(string: urlString)!) {
                DispatchQueue.main.async {
                    if let currentIndexPath = collectionView.indexPath(for: cell),
                        oldIndexPath.row == currentIndexPath.row {
                        cell.imageView.image = UIImage(data: data)
                        self.dounLoadImages[indexPath] = cell.imageView.image
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == images.count - 4 {
            getImages()
        }
    }
    
    //MARK: - Rotate 3 Cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let safeFrame = view.safeAreaLayoutGuide.layoutFrame
        let size = CGSize(width: safeFrame.width, height: safeFrame.height)
        return setCollectionViewItemSize(size: size)
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.invalidateLayout()
        }
    }
    
    func setCollectionViewItemSize(size: CGSize) -> CGSize {
        
        if UIApplication.shared.statusBarOrientation.isPortrait {
            
            let width = (view.frame.width / 2 ) - 40
            return CGSize(width: width, height: width)
            
        } else {
            
            let width = (size.width - 2 * spacing) / 3
            return CGSize(width: width, height: width)
        }
    }
}

