//
//  ViewController.swift
//  Tattoos
//
//  Created by Kevin Carey on 9/18/23.
//

import UIKit
import Foundation

class ViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var artistLabel: UILabel!
    
    // things for artist sort
    var greaterArray: [String] = []
    var leftArray = [String]()
    var rightArray = [String]()
    var leftIndex = Int()
    var rightIndex = Int()
    var setIndex = Int()
    var setCount = Int()
    var outs_i: Int = 0
    var mergedImages = [String]()
    var resetOuts: [Int] = []
    var outs = [Int]()
    var fresh: Bool = true
    var temp_outs = [Int]()
    var hasSwiped = false
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "onToTheNext" {
            if let destinationVC = segue.destination as? ViewController2 {
                destinationVC.ordList = greaterArray
            }
        }
    }
    
    @IBAction func leftButton(_ sender: Any) {
        if hasSwiped {
            mergedImages.append(leftArray[leftIndex])
            leftIndex += 1
            if leftIndex >= leftArray.count {
                while rightIndex < rightArray.count {
                    mergedImages.append(rightArray[rightIndex])
                    rightIndex += 1
                }
                greaterArray.replaceSubrange(setIndex..<setIndex + mergedImages.count, with: mergedImages)
                nextSet()
            } else {
                updateImages(withNewNames: [leftArray[leftIndex], rightArray[rightIndex]])
            }
            saveStateToUserDefaults()
        } else {
            let alertController = UIAlertController(title: "Checking", message: "Haven't checked both options", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            
            // Present the alert
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func rightButton(_ sender: Any) {
        if hasSwiped {
            mergedImages.append(rightArray[rightIndex])
            rightIndex += 1
            if rightIndex >= rightArray.count {
                while leftIndex < leftArray.count {
                    mergedImages.append(leftArray[leftIndex])
                    leftIndex += 1
                }
                greaterArray.replaceSubrange(setIndex..<setIndex + mergedImages.count, with: mergedImages)
                nextSet()
            } else {
                updateImages(withNewNames: [leftArray[leftIndex], rightArray[rightIndex]])
            }
            saveStateToUserDefaults()
        } else {
            let alertController = UIAlertController(title: "Checking", message: "Haven't checked both options", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            
            // Present the alert
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func nextSet() {
        print(greaterArray)
        print(outs)
        setIndex += outs[outs_i] + outs[outs_i + 1]
        print(setIndex)
        temp_outs.append(outs[outs_i] + outs[outs_i + 1])
        outs_i += 2
        if outs_i >= outs.count || setIndex + outs[outs_i] >= greaterArray.count || outs.count == 1 {
            setIndex = 0
            outs_i = 0
            if outs.count % 2 == 1 {
                temp_outs.append(outs[outs.count-1])
            }
            outs = temp_outs
            temp_outs = []
            if outs.count == 1 {
                performSegue(withIdentifier: "onToTheNext", sender: self)
                baseState()
            }
        }
        
        leftArray = Array(greaterArray[setIndex..<setIndex + outs[outs_i]])
        let endIndex = min(setIndex + outs[outs_i] + outs[outs_i+1], greaterArray.count)
        rightArray = Array(greaterArray[setIndex + outs[outs_i]..<endIndex])
        leftIndex = 0
        rightIndex = 0
        mergedImages = []
        updateImages(withNewNames: [leftArray[leftIndex], rightArray[rightIndex]])
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left:
            // Swipe left, move to the next image
            let nextPageOffset = scrollView.contentOffset.x + scrollView.frame.size.width
            scrollView.setContentOffset(CGPoint(x: nextPageOffset, y: 0), animated: true)
        case .right:
            // Swipe right, move to the previous image
            let previousPageOffset = scrollView.contentOffset.x - scrollView.frame.size.width
            scrollView.setContentOffset(CGPoint(x: previousPageOffset, y: 0), animated: true)
        default:
            break
        }
    }
    
    func baseState() {
        setIndex = 0
        leftIndex = 0
        rightIndex = 0
        mergedImages = []
        setCount = 1
        outs_i = 0
        temp_outs = []
        outs = resetOuts
        leftArray = Array(greaterArray.prefix(outs[0]))
        rightArray = Array(greaterArray[outs[0]..<outs[0]+outs[1]])
        saveStateToUserDefaults()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0
        
        hasSwiped = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        
        loadStateFromUserDefaults()
                
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        leftSwipeGesture.direction = .left
        scrollView.addGestureRecognizer(leftSwipeGesture)
        
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        rightSwipeGesture.direction = .right
        scrollView.addGestureRecognizer(rightSwipeGesture)
        
        loadImages([leftArray[leftIndex], rightArray[rightIndex]])
    }
    
    func loadImages(_ names: [String]) {
        // Remove any existing subviews
        for subview in scrollView.subviews {
            subview.removeFromSuperview()
        }
        
        var contentWidth: CGFloat = 0.0
        
        for (index, imageName) in names.enumerated() {
            if let image = UIImage(named: imageName) {
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFit
                let xPosition = CGFloat(index) * scrollView.frame.width
                imageView.frame = CGRect(x: xPosition, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
                
                scrollView.addSubview(imageView)
                
                // Update content width
                contentWidth = imageView.frame.maxX
            } else {
                print("Image named \(imageName) not found")
            }
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            hasSwiped = false
        }
        
        // Set the content size based on the total content width
        scrollView.contentSize = CGSize(width: contentWidth, height: scrollView.frame.height)
        
        // Clamp the contentOffset to valid values
        scrollView.contentOffset.x = min(max(scrollView.contentOffset.x, 0), scrollView.contentSize.width - scrollView.frame.width)
    }

    func updateImages(withNewNames newNames: [String]) {
        loadImages(newNames)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if outs.count == 1 {
            performSegue(withIdentifier: "onToTheNext", sender: self)
        } else {
            // Display a warning message as an alert
            let alertController = UIAlertController(title: "Finals", message: "In this panel, you will order every image in the top 5 of each artist and rank them using a sorting algorithm ", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            
            // Present the alert
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func saveStateToUserDefaults() {
        UserDefaults.standard.setValue(setIndex, forKey: "setIndex")
        UserDefaults.standard.setValue(leftIndex, forKey: "leftIndex")
        UserDefaults.standard.setValue(rightIndex, forKey: "rightIndex")
        UserDefaults.standard.setValue(mergedImages, forKey: "mergedImages")
        UserDefaults.standard.setValue(greaterArray, forKey: "greaterArray")
        UserDefaults.standard.setValue(setCount, forKey: "setCount")
        UserDefaults.standard.setValue(leftArray, forKey: "leftArray")
        UserDefaults.standard.setValue(rightArray, forKey: "rightArray")
        UserDefaults.standard.setValue(outs, forKey: "outs")
        UserDefaults.standard.setValue(resetOuts, forKey: "resetOuts")
        UserDefaults.standard.setValue(outs_i, forKey: "outs_i")
        UserDefaults.standard.setValue(temp_outs, forKey: "temp_outs")
        
        // Call synchronize to make sure the values are saved immediately
        UserDefaults.standard.synchronize()
    }
    
    func loadStateFromUserDefaults() {
        if !fresh {
            if let savedSetIndex = UserDefaults.standard.value(forKey: "setIndex") as? Int,
               let savedLeftIndex = UserDefaults.standard.value(forKey: "leftIndex") as? Int,
               let savedRightIndex = UserDefaults.standard.value(forKey: "rightIndex") as? Int,
               let savedMergedImages = UserDefaults.standard.value(forKey: "mergedImages") as? [String],
               let savedLeftArray = UserDefaults.standard.value(forKey: "leftArray") as? [String],
               let savedRightArray = UserDefaults.standard.value(forKey: "rightArray") as? [String],
               let savedOuts = UserDefaults.standard.value(forKey: "outs") as? [Int],
               let savedOuts_i = UserDefaults.standard.value(forKey: "outs_i") as? Int,
               let savedTemps = UserDefaults.standard.value(forKey: "temp_outs") as? [Int],
               let savedResetOuts = UserDefaults.standard.value(forKey: "resetOuts") as? [Int],
               let savedSetCount = UserDefaults.standard.value(forKey: "setCount") as? Int {
                
                setIndex = savedSetIndex
                leftIndex = savedLeftIndex
                rightIndex = savedRightIndex
                mergedImages = savedMergedImages
                setCount = savedSetCount
                leftArray = savedLeftArray
                rightArray = savedRightArray
                outs = savedOuts
                outs_i = savedOuts_i
                temp_outs = savedTemps
                resetOuts = savedResetOuts
                
                loadImages([leftArray[leftIndex], rightArray[rightIndex]])
            } else {
                baseState()
            }
        } else {
            baseState()
        }
    }
}
