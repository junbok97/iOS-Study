//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MenuViewController: UIViewController {
    // MARK: - Life Cycle
    
    let cellId = "MenuItemTableViewCell"
    
    let viewModel = MenuListViewModel.shard
    var disposBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.menuObservable
            .observeOn(MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: cellId, cellType: MenuItemTableViewCell.self)) { index, item, cell in
                cell.title.text = item.name
                cell.price.text = "\(item.price)"
                cell.count.text = "\(item.count)"
                
                cell.onChange = { [weak self] increase in
                    self?.viewModel.changeCount(item, increase)
                }
                
            }
            .disposed(by: disposBag)
        
        viewModel.itemsCount
            .map { "\($0)" }
            .asDriver(onErrorJustReturn: "")
            .drive(itemCountLabel.rx.text)
            .disposed(by: disposBag)
        
        viewModel.totalPrice
            .map { $0.currencyKR() }
            .observeOn(MainScheduler.instance)
            .bind(to: totalPrice.rx.text)
            .disposed(by: disposBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier ?? ""
        if identifier == "OrderViewController",
           let orderVC = segue.destination as? OrderViewController {
            // TODO: pass selected menus
        }
    }
    
    func showAlert(_ title: String, _ message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertVC, animated: true, completion: nil)
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var itemCountLabel: UILabel!
    @IBOutlet var totalPrice: UILabel!
    
    @IBAction func onClear() {
        viewModel.clearAllItemsSelections()
    }
    
    @IBAction func onOrder(_ sender: UIButton) {
        // TODO: no selection
        // showAlert("Order Fail", "No Orders")
        //        performSegue(withIdentifier: "OrderViewController", sender: nil)
        
        viewModel.onOrder()
        
        viewModel.menuObservable.accept([
            Menu(name: "change", price: Int.random(in: 100...1000), count: Int.random(in: 0...5)),
            Menu(name: "change", price: Int.random(in: 100...1000), count: Int.random(in: 0...5)),
            Menu(name: "change", price: Int.random(in: 100...1000), count: Int.random(in: 0...5)),
            Menu(name: "change", price: Int.random(in: 100...1000), count: Int.random(in: 0...5)),
            Menu(name: "change", price: Int.random(in: 100...1000), count: Int.random(in: 0...5))
        ])


    }
}

//extension MenuViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel.menus.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! MenuItemTableViewCell
//
//        let menu = viewModel.menus[indexPath.row ]
//        cell.title.text = menu.name
//        cell.price.text = "\(menu.price)"
//        cell.count.text = "\(menu.count)"
//
//        return cell
//    }
//}
