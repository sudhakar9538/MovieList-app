//
//  MovieDetailsViewController.swift
//  MovieList
//
//  Created by Activ Doctors Online on 05/07/18.
//  Copyright © 2018 Activ Doctors Online. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController
{
    @IBOutlet weak var movoieImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var overView: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var popularity: UILabel!
    @IBOutlet weak var budget: UILabel!
    var model: MovieModel?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = model?.mTitle
        self.movieTitle.text = model?.mTitle
        let str: String = "https://image.tmdb.org/t/p/w300" + model!.posterPath!
        self.movoieImage.imageFromServerURL(urlString: str, defaultImage: nil)
        self.overView.text = model?.overView
        self.popularity.text = String(format: "%@", (model?.popularity)!)
        self.releaseDate.text = model?.releaseDate
       // print(model?.movieId)
        let leftItem = UIBarButtonItem(image: UIImage(named: "back.png"), style: .done, target: self, action: #selector(self.leftClk))
        navigationItem.leftBarButtonItem = leftItem
        
        self.getMovieDetails()
        // Do any additional setup after loading the view.
    }
    @objc func leftClk(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    func getMovieDetails()
    {
        MBProgressHUD.showAdded(to: view, animated: true).labelText = NSLocalizedString("Loading", comment: "")
        let urlStr = String(format : "%@%@?api_key=%@&language=%@", "https://api.themoviedb.org/3/movie/", (self.model?.movieId)!, "2f87163f35577e44e9ac39bb7b57defb","en-US")
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
                let queryDic = json?["budget"] as? NSNumber
            {
                DispatchQueue.main.async
                    {
                        MBProgressHUD.hide(for: self.view, animated: true)
                        if queryDic != nil && queryDic != 0
                        {
                            
                            self.budget.text = String(format:"%@", queryDic)
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
