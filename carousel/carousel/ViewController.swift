//
//  ViewController.swift
//  carousel
//
//  Created by Euan Traynor on 14/9/20.
//

import UIKit
import PencilKit


class collectionViewCell: UICollectionViewCell, PKToolPickerObserver {
//    @IBOutlet weak var mainView: UIView!
    
    let toolPicker = PKToolPicker()
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var canvasView: PKCanvasView!
}

class ViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {
    
    var currentCell = 0
    let numberOfCells = 10
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        collectionView.isMultipleTouchEnabled = true
        
        let flowLayout = UPCarouselFlowLayout()
        flowLayout.itemSize = CGSize(width: 210, height: 297) //CGSize(width: UIScreen.main.bounds.size.width, height: collectionView.frame.size.height)
        flowLayout.scrollDirection = .horizontal
        flowLayout.sideItemScale = 0.7
        flowLayout.sideItemAlpha = 0.8
        flowLayout.spacingMode = .fixed(spacing: 55)

        collectionView.collectionViewLayout = flowLayout
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
        let pageSaveName = "pg-0"
        let data_get = canvasView.drawing.dataRepresentation()
        let url = self.getDocumentsDirectory().appendingPathComponent(pageSaveName)
        do {
            try data_get.write(to: url)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfCells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! collectionViewCell
        
        cell.toolPicker.addObserver(cell.canvasView)
//        toolPicker.addObserver(self)
        
        if indexPath.row == currentCell {
            print("\(indexPath.row) -> yes")
            cell.canvasView.becomeFirstResponder()
            cell.toolPicker.setVisible(true, forFirstResponder: cell.canvasView)
        } else {
            cell.canvasView.resignFirstResponder()
            cell.toolPicker.setVisible(false, forFirstResponder: cell.canvasView)
        }
        
        cell.layer.cornerRadius = 15
        cell.label.textColor = .secondaryLabel
        cell.label.text = "Page \(indexPath.row + 1)"
        
        let pageSaveName = "pg-0" //pageSelected
        
        //retrieving process
        let url = self.getDocumentsDirectory().appendingPathComponent(pageSaveName)
        do {
            let data = try Data(contentsOf: url)
//            print(data)
            do {
                let myDrawing = try PKDrawing(data: data)
                cell.canvasView.drawing = myDrawing
            } catch {
                print(error.localizedDescription)
                cell.canvasView.drawing = PKDrawing()
            }
        } catch {
            print(error.localizedDescription)
            cell.canvasView.drawing = PKDrawing()
        }
        
        cell.canvasView.delegate = self
        cell.canvasView.frame = cell.bounds
        cell.canvasView.layer.cornerRadius = 10
        
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        print(collectionView.contentOffset)
        getRestore()
    }
    
    func getRestore() {
        var highestValue = 0

        print("\n")
        for cell in collectionView.visibleCells {
            let indexPath = collectionView.indexPath(for: cell)
            print(indexPath!)
            if indexPath!.row > highestValue {
                highestValue  = indexPath!.row
            }
        }
        
        if highestValue != (numberOfCells - 1) {
            currentCell = highestValue - 1
        } else {
            currentCell = highestValue
        }
        print(currentCell)
        collectionView.reloadData()
    }
}
