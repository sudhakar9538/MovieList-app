//
//  ViewController.swift
//  MovieList
//
//  Created by Activ Doctors Online on 05/07/18.
//  Copyright © 2018 Activ Doctors Online. All rights reserved.
//

import UIKit
//https://api.themoviedb.org/3/genre/movie/list?api_key=2f87163f35577e44e9ac39bb7b57defb&language=en-US
extension UIImageView
{
    public func imageFromServerURL(urlString: String, defaultImage : String?)
    {
        if let di = defaultImage {
            self.image = UIImage(named: di)
        }
        
        URLSession.shared.dataTask(with: URL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil
            {
                print(error ?? "error")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                if image != nil
                {
                    self.image = image
                }
                else
                {
                    self.image = UIImage(named: "")
                }
                MBProgressHUD.hide(for: self, animated: true)
                
            })
            
        }).resume()
    }
}
class MovieModel: NSObject
{
    var mTitle: String?
    var posterPath: String?
    var overView: String?
    var releaseDate: String?
    var popularity: NSNumber?
    var movieId: NSNumber?
    var genre_id: [NSNumber]?
    init(mTitle: String?, posterPath: String?, overView: String?, releaseDate: String?, popularity: NSNumber?,movieId: NSNumber?,genre_id: [NSNumber]?)
    {
        self.mTitle = mTitle
        self.posterPath = posterPath
        self.overView = overView
        self.releaseDate = releaseDate
        self.popularity = popularity
        self.movieId = movieId
        self.genre_id = genre_id
    }
    
}
class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource
{
    var pageIndex: Int = 1
    var movieList: [MovieModel] = []
    var model: MovieModel?
    var genreList: [[String: Any]] = []
    var totalPages: Int = 0
    var moreList: [MovieModel] = []
    @IBOutlet weak var movieView: UICollectionView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = "Popular Movies"
        self.startAuthenticatingUser()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(true)
        print(self.movieList.count)
    }
    func getGenre()
    {
        let urlStr = String(format : "%@?api_key=%@&language=%@", "https://api.themoviedb.org/3/genre/movie/list", "2f87163f35577e44e9ac39bb7b57defb","en-US")
        let request = URLRequest(url: URL(string: urlStr)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
        let session = URLSession.shared
        let task = session.dataTask(with: request)
        {
            (data, response, error) in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                //  MBProgressHUD.hide(for: self.view, animated: true)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200
            {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                // MBProgressHUD.hide(for: self.view, animated: true)
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                let queryDic = json?["genres"] as? [[String : Any]]
            {
                var filtered = [[String : Any]]()
                UserDefaults.standard.synchronize()
                DispatchQueue.main.async
                    {
                        if queryDic.count == 0
                        {
                            // MBProgressHUD.hide(for: self.view, animated: true)
                        }
                        else
                        {
                            for item in queryDic
                            {
                                var prunedDictionary = [String: Any]()
                                for key: String in item.keys
                                {
                                    if !(item[key] is NSNull) {
                                        prunedDictionary[key] = item[key]
                                    }
                                    else {
                                        prunedDictionary[key] = ""
                                    }
                                }
                                filtered.append(prunedDictionary)
                            }
                            //  self.vetModelList = [VetModel]()
                            self.genreList  = filtered
                            self.movieView.reloadData()
                            
                            // MBProgressHUD.hide(for: self.view, animated: true)
                        }
                }
            }
            else
            {
                //self.noDataLbl?.isHidden = false
                //MBProgressHUD.hide(for: self.view, animated: true)
            }
            
        }
        task.resume()
    }
    func startAuthenticatingUser()
    {
        //first check internet connectivity
        if CheckNetwork.isExistenceNetwork()
        {
            print("Internet connection")
            MBProgressHUD.showAdded(to: view, animated: true).labelText = NSLocalizedString("Loading", comment: "")
            self.movieList = []
            
            self.getList()
            self.getGenre()
        }
        else {
            print("No internet connection")
            MBProgressHUD.hide(for: view, animated: true)
        }
    }
    func getList()
    {
        let urlStr = String(format : "%@?api_key=%@&language=%@&page=%d", "https://api.themoviedb.org/3/movie/popular", "2f87163f35577e44e9ac39bb7b57defb","en-US",pageIndex)
        let request = URLRequest(url: URL(string: urlStr)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
        let session = URLSession.shared
        let task = session.dataTask(with: request)
        {
            (data, response, error) in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                MBProgressHUD.hide(for: self.view, animated: true)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200
            {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                let queryDic = json?["results"] as? [[String : Any]]
            {
                var filtered = [[String : Any]]()
                UserDefaults.standard.synchronize()
                DispatchQueue.main.async
                    {
                        self.totalPages = Int(truncating: (json!["total_pages"] as? NSNumber)!)
                        if queryDic.count == 0
                        {
                            MBProgressHUD.hide(for: self.view, animated: true)
                        }
                        else
                        {
                            for item in queryDic
                            {
                                var prunedDictionary = [String: Any]()
                                for key: String in item.keys
                                {
                                    if !(item[key] is NSNull) {
                                        prunedDictionary[key] = item[key]
                                    }
                                    else {
                                        prunedDictionary[key] = ""
                                    }
                                }
                                filtered.append(prunedDictionary)
                            }
                            //  self.vetModelList = [VetModel]()
                            for item in filtered
                            {
                                let Movie = MovieModel (mTitle: item["title"] as? String , posterPath: item["poster_path"] as? String , overView: item["overview"] as? String , releaseDate: item["release_date"] as? String , popularity: item["popularity"] as? NSNumber ,movieId: item["id"] as? NSNumber, genre_id: item["genre_ids"] as? [NSNumber]  )
                                
                                self.movieList.append(Movie)
                            }
                            self.movieView.reloadData()
                            MBProgressHUD.hide(for: self.view, animated: true)
                        }
                }
            }
            else
            {
                //self.noDataLbl?.isHidden = false
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            
        }
        task.resume()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.movieList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell: MovieCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Movie", for: indexPath) as! MovieCollectionViewCell
        let model = self.movieList[indexPath.row]
        let str: String = "https://image.tmdb.org/t/p/w200" + model.posterPath!
        cell.poster.imageFromServerURL(urlString: str, defaultImage: nil)
        cell.releaseDate.text = model.releaseDate
        cell.movieTitle.text = model.mTitle
        var genStr: [String] = []
        for i in 0...(model.genre_id?.count)!-1
        {
            let genreId = model.genre_id![i]
            for genre in self.genreList
            {
                if genre["id"] as? NSNumber == genreId
                {
                    genStr.append(genre["name"] as! String)
                }
            }
        }
        cell.genre.text = genStr.joined(separator: ",")
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let model = self.movieList[indexPath.row]
        self.performSegue(withIdentifier: "details", sender: model)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    {
        if indexPath.row == self.movieList.count-1
        {
            print(pageIndex)
            self.pageIndex = pageIndex + 1
            print(pageIndex)
            if pageIndex > self.totalPages
            {
                
            }
            else
            {
                self.moreList = []
                self.getMoreList()
            }
        }
    }
    func getMoreList()
    {
        MBProgressHUD.showAdded(to: view, animated: true).labelText = NSLocalizedString("Loading", comment: "")
        let urlStr = String(format : "%@?api_key=%@&language=%@&page=%d", "https://api.themoviedb.org/3/movie/popular", "2f87163f35577e44e9ac39bb7b57defb","en-US",pageIndex)
        let request = URLRequest(url: URL(string: urlStr)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
        let session = URLSession.shared
        let task = session.dataTask(with: request)
        {
            (data, response, error) in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                MBProgressHUD.hide(for: self.view, animated: true)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200
            {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                let queryDic = json?["results"] as? [[String : Any]]
            {
                var filtered = [[String : Any]]()
                UserDefaults.standard.synchronize()
                DispatchQueue.main.async
                    {
                       
                        if queryDic.count == 0
                        {
                            MBProgressHUD.hide(for: self.view, animated: true)
                        }
                        else
                        {
                            for item in queryDic
                            {
                                var prunedDictionary = [String: Any]()
                                for key: String in item.keys
                                {
                                    if !(item[key] is NSNull) {
                                        prunedDictionary[key] = item[key]
                                    }
                                    else {
                                        prunedDictionary[key] = ""
                                    }
                                }
                                filtered.append(prunedDictionary)
                            }
                            //  self.vetModelList = [VetModel]()
                            for item in filtered
                            {
                                let Movie = MovieModel (mTitle: item["title"] as? String , posterPath: item["poster_path"] as? String , overView: item["overview"] as? String , releaseDate: item["release_date"] as? String , popularity: item["popularity"] as? NSNumber ,movieId: item["id"] as? NSNumber, genre_id: item["genre_ids"] as? [NSNumber]  )
                                
                                self.moreList.append(Movie)
                            }
                            print(self.movieList.count)
                            print(self.moreList.count)
                            self.movieList.append(contentsOf: self.moreList)
                            print(self.movieList.count)
                            self.movieView.reloadData()
                            MBProgressHUD.hide(for: self.view, animated: true)
                        }
                }
            }
            else
            {
                //self.noDataLbl?.isHidden = false
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            
        }
        task.resume()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let details = segue.destination as! MovieDetailsViewController
        details.model = sender as? MovieModel
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

