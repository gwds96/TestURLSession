import UIKit
import Foundation

struct Main: Codable, Equatable {
    let status: Int?
    let response: Response
}

struct Response: Codable, Equatable {
    let news: [News]
}

struct News: Codable, Equatable {
    let id: Int?
    let feed: String?
    let title: String?
    let thumb_img: String?
    let detail_url: String?
    let description: String?
    let author: String?
    let publish_date: String?
    let created_at: String?
    let updated_at: String?
}

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var news = [News]()
    
    let imageCache = NSCache<AnyObject, AnyObject>()
    
    func takeImage(url: String) -> UIImage {
        var image: UIImage? = nil
        
        if let imageFromCache = imageCache.object(forKey: url as AnyObject) as? UIImage {
            image = imageFromCache
            return image!
        }
        
        if let urlImage = URL(string: url) {
            do {
                let dataImage = try Data(contentsOf: urlImage)
                let img = UIImage(data: dataImage)!
                imageCache.setObject(img, forKey: url as AnyObject)
                image = img
                return image!
            } catch let error {
                print(error.localizedDescription)
            }
        }
        return UIImage.init(named: "Noimage")!
    }
    
    override func viewDidLoad() {
        let task = URLSession.shared.dataTask(with: URL(
            string: "http://172.16.18.91/18175d1_mobile_100_fresher/public/api/v0/listNews")!) {(result, response, error) in
                guard
                    let data = result,
                    error == nil else {
                        return
                }
                do {
                    guard let obj = try? JSONDecoder().decode(Main.self, from: data) else {
                        return
                    }
                    DispatchQueue.main.async {
                        self.news = obj.response.news
                        self.tableView.reloadData()
                    }
                }
        }
        task.resume()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let certifier = "TestURLCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: certifier, for: indexPath) as! TestURLCell
        cell.titleLabel.text = news[indexPath.row].title ?? ""
        cell.feedLabel.text = news[indexPath.row].feed ?? ""
        cell.thumbImage.image = takeImage(url: news[indexPath.row].thumb_img!)
        cell.textView.text = news[indexPath.row].description ?? ""
        cell.authorLabel.text = news[indexPath.row].author ?? ""
        if cell.authorLabel.text == "" {
            cell.autLbl.text = ""
        } else {
            cell.autLbl.text = "Tác giả:"
        }
        if let date = news[indexPath.row].publish_date?.prefix(10) {
            cell.dateLabel.text = "Date: \(String(date))"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
