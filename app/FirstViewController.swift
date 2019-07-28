//
//  FirstViewController.swift
//  app
//
//  Created by Fulvio Fanelli on 13/07/19.
//  Copyright © 2019 zaatar. All rights reserved.
//

import UIKit
import Alamofire

class FirstViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var img: Array<DataCollectionViewCell> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        loadingCarregaFotos()
    }
    
    func carregaFotos() {
        
        var request = URLRequest(url: URL(string: "https://zaatar-api.herokuapp.com/photos")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, _, error) = URLSession.shared.synchronousDataTask(urlrequest: request)
        if let error = error {
            print("Synchronous task ended with error: \(error)")
        }
        else {
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Array<AnyObject>
                
                for i in 0...json.count-1 {
                    
                    if let index = json[i] as? Dictionary<String, Any> {
                        let name = index["name"] as! String
                        let imgData = index["data"] as! String
                        let id = index["_id"] as! String
                        
                        if let decodedImageData = Data(base64Encoded: imgData, options: .ignoreUnknownCharacters) {
                            let image = UIImage(data: decodedImageData)
                            
                            let cell: DataCollectionViewCell = DataCollectionViewCell.init()
                            cell.image = UIImageView(image: image)
                            cell.label = UILabel.init()
                            cell.label.text = name
                            cell.id = id
                            self.img.append(cell)
                        }
                    }
                }
                collectionView.reloadData()
            }
            catch {
                print("Erro")
            }
        }
    }
    
    func loadingCarregaFotos() {
        
        img = []
        
        let alert = UIAlertController(title: nil, message: "Carregando...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: false, completion: {
            self.carregaFotos()
        })
        
        escondeLoading()
    }
    
    func escondeLoading() {
        self.dismiss(animated: false, completion: nil)
    }
}

extension FirstViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return img.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? DataCollectionViewCell
        cell?.image.image = img[indexPath.row].image.image
        cell?.label.text = img[indexPath.row].label.text
        cell?.id = img[indexPath.row].id
        return cell!
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: nil, message: "Excluindo...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: false, completion: {
            
            let cell = self.img[indexPath.row]
            
            let url = "https://zaatar-api.herokuapp.com/photos/"+cell.id
            
            Alamofire.request(url, method: .delete).responseJSON { response in
                print("Photo deleted!")
            }
            
            self.img.remove(at: indexPath.row)
            
            self.collectionView.reloadData()
        })
        
        escondeLoading()
    }
}

extension UIImage {
    
    func scaled(with scale: CGFloat) -> UIImage? {
        // size has to be integer, otherwise it could get white lines
        let size = CGSize(width: floor(self.size.width * scale), height: floor(self.size.height * scale))
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension URLSession {
    func synchronousDataTask(urlrequest: URLRequest) -> (data: Data?, response: URLResponse?, error: Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let dataTask = self.dataTask(with: urlrequest) {
            data = $0
            response = $1
            error = $2
            
            semaphore.signal()
        }
        dataTask.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return (data, response, error)
    }
}
