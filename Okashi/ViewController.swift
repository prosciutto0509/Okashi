//
//  ViewController.swift
//  Okashi
//
//  Created by 安田 悠麿 on 2020/08/15.
//  Copyright © 2020 安田 悠麿. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UISearchBarDelegate,UITableViewDataSource{

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchText.delegate = self
        
        searchText.placeholder = "お菓子の名前を入力して下さい"
        tableView.dataSource = self
    }


    @IBOutlet weak var searchText: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var okashiList : [(name:String , maker:String, link:URL , image:URL)] = []
//    検索ボタンをクリックした時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        
        if let searchWord = searchBar.text {
            print(searchWord)
            searchOkashi(keyword: searchWord)
        }
    }
            
//            jsonのitem内のデータ構造
            struct ItemJson: Codable {
                
                let name: String?
                 
               let maker: String?
                
                let url: URL?
                
                let image: URL?
            }
            struct ResultJson: Codable {
                let item:[ItemJson]?
            }
                
   
    
//    searchOkashiメソッド
//    第一引数
    func searchOkashi(keyword: String){
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
            return
        }
        guard let req_url = URL(string: "https://sysbird.jp/toriko/api/?apikey=guest&format=json&keyword=\(keyword_encode)&max=10&order=r") else{
        return
        }
         print(req_url)
        
//        リクエストに必要な情報を生成
        let req = URLRequest(url: req_url)
        
//        データ転送を管理するためのセッションを生成
        let session = URLSession(configuration: .default, delegate: nil,delegateQueue: OperationQueue.main)
//        リクエストをタスクとして登録
        let task = session.dataTask(with: req, completionHandler: {
            (data , response , error) in
            session.finishTasksAndInvalidate()
            //エラーハンドリング
            do {
                let decoder = JSONDecoder()
                
                let json = try decoder.decode(ResultJson.self, from: data!)
                
            //お菓子の情報を取得できているか確認
                if let items = json.item{
                    self.okashiList.removeAll()
                    self.okashiList.removeAll()
                    
                    for item in items {
                        if let name = item.name , let maker  = item.maker, let link = item.url , let image = item.image {
                            let okashi = (name,maker,link,image)
                            
                            self.okashiList.append(okashi)
                            
                        }
                    }
                    self.tableView.reloadData()
                    if let okashidbg = self.okashiList.first{
                        print("-----------------------------")
                        print("okashiList[0] = \(okashidbg)")
                    }
                }
            } catch{
                print("エラーが出ました")
            }
        })
        task.resume()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return okashiList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "okashiCell",for: indexPath)
        cell.textLabel?.text = okashiList[indexPath.row].name
        
        if let imageData = try? Data(contentsOf: okashiList[indexPath.row].image){
            cell.imageView?.image = UIImage(data: imageData)
        }
        return cell
    }
        
}

