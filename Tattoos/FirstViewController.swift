//
//  FirstViewController.swift
//  Tattoos
//
//  Created by Kevin Carey on 9/21/23.
//

import UIKit

class FirstViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var currentPage = Int()
    var ordList = [String]()
    var completedArray = [String]()
    var newIndex = Int()
    var currIndex = Int()
    var artists = [[String]]()
    var artistIndex = Int()
    var n = Int()
    var secondView: Bool = false
    var del = [String]()
    var hasSwiped = false
    var rightLast = false
    var hardReset: Bool = false
    
    func saveData() {
        let defaults = UserDefaults.standard

        defaults.set(ordList, forKey: "ordListKey")
        defaults.set(artistIndex, forKey: "artistIndexKey")
        defaults.set(newIndex, forKey: "newIndexKey")
        defaults.set(currIndex, forKey: "currIndexKey")
        defaults.set(artists, forKey: "artistsKey")
        defaults.set(n, forKey: "nKey")
        defaults.set(secondView, forKey: "secondViewKey")
        defaults.set(del, forKey: "delKey")

        defaults.synchronize()
    }
    
    func loadData() {
            let defaults = UserDefaults.standard

            if let loadedOrdList = defaults.array(forKey: "ordListKey") as? [String] {
                ordList = loadedOrdList
            }

            if let loadedArtistIndex = defaults.integer(forKey: "artistIndexKey") as? Int,
               let loadedNewIndex = defaults.integer(forKey: "newIndexKey") as? Int,
               let loadedCurrIndex = defaults.integer(forKey: "currIndexKey") as? Int,
               let loadedArtists = defaults.array(forKey: "artistsKey") as? [[String]],
               let loadedN = defaults.integer(forKey: "nKey") as? Int,
               let loadedSecondView = defaults.bool(forKey: "secondViewKey") as? Bool,
               let loadedDel = defaults.array(forKey: "delKey") as? [String] {
                artistIndex = loadedArtistIndex
                newIndex = loadedNewIndex
                currIndex = loadedCurrIndex
                artists = loadedArtists
                n = loadedN
                secondView = loadedSecondView
                del = loadedDel
            } else {
                // If any data is not found in UserDefaults, use default values or initialize them here.
                processArtistStats()
                baseState()
                saveData() // Save the defaults to UserDefaults.
            }
        }
    
    
    let artistStats: [(String, Int)] = [
        ("baronart_zero",6),
        ("batuhanoter", 6),
        ("maddymisfit", 6)
    ]
     
    /*
     let artistStats: [(String, Int)] = [
         ("_johnmonterio",31),
         ("_mfox", 26),
         ("baronart_jackie", 10),
         ("baronart_zero",9),
         ("batuhanoter", 12),
         ("bjoern_holtappels", 15),
         ("conio", 42),
         ("debrartist", 14),
         ("echo.tattoo", 13),
         ("fiistattoo", 29),
         ("fill_tat", 18),
         ("flyingfishtattoo", 8),
         ("foundation.nyc", 21),
         ("gab7sz", 14),
         ("gullsahkaraca", 23),
         ("judz.ttt", 20),
         ("june_alison", 30),
         ("jw.inkrypt", 5),
         ("katia.zuela", 10),
         ("lmc_tatt", 6),
         ("lukovnikovtattoo", 18),
         ("maddymisfit", 8),
         ("markd_tattoo", 18),
         ("mj_tatt",6),
         ("noma_tattooer",10),
         ("odb_blackwork", 11),
         ("ondrashtattoo", 33),
         ("oozy_tattoo", 10),
         ("pejczi", 11),
         ("sansa.jr.tattoo", 9),
         ("sashanuisex", 14),
         ("soapy_tattoo", 4),
         ("stateofmindink", 24),
         ("tattooist_eq",26),
         ("tattooist_mul", 16),
         ("ulassyesilyurt",15),
         ("winston.dyk", 15),
         ("wm.tatt", 11),
         ("xsonseven", 9)
     ]
     */
    
    @IBAction func deleteOne(_ sender: Any) {
        let alertController = UIAlertController(title: "Delete Image", message: "Choose which image you would like removed from the top 5", preferredStyle: .alert)

        let leftAction = UIAlertAction(title: "Left", style: .default) { _ in
            self.del.append(self.ordList[self.currIndex-1])
            self.ordList.remove(at: self.currIndex-1)

            if self.newIndex > self.n {
                self.newIndex -= 1
                self.ordList[self.n] = self.ordList[self.newIndex]
                self.currIndex = self.n
            } else {
                self.currIndex = self.newIndex
            }

            self.leftButton(self)
            self.saveData()
        }

        let rightAction = UIAlertAction(title: "Right", style: .default) { _ in
            self.del.append(self.ordList[self.currIndex])
            self.ordList.remove(at: self.currIndex)

            self.newIndex -= 1

            if self.newIndex > self.n {
                self.ordList[self.n] = self.ordList[self.newIndex]
                self.currIndex = self.n
            } else {
                self.currIndex = self.newIndex
            }

            self.leftButton(self)
            self.saveData()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)

        alertController.addAction(leftAction)
        alertController.addAction(rightAction)
        alertController.addAction(cancelAction)

        // Present the alert
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func rightButton(_ sender: Any) {
        if hasSwiped || rightLast {
            let temp = ordList[currIndex]
            ordList[currIndex] = ordList[currIndex-1]
            ordList[currIndex-1] = temp
            if currIndex == 1 {
                newIndex += 1
                currIndex = min(newIndex,n)
                if newIndex >= ordList.count {
                    artists[artistIndex] = ordList
                    artistIndex += 1
                    if artistIndex >= artists.count {
                        performSegue(withIdentifier: "firstToSecond", sender: self)
                        secondView = true
                        
                    } else {
                        ordList = artists[artistIndex].shuffled()
                        newIndex = 1
                        currIndex = 1
                        currentPage = 0
                        del = []
                        rightLast = false
                    }
                } else {
                    ordList[currIndex] = ordList[newIndex]
                    rightLast = false
                }
            } else {
                currIndex -= 1
                rightLast = true
            }
            titleLabel.text = "\(newIndex-1+del.count) / \(ordList.count-1 + del.count) comparisons done for \(ordList[0]) \(artistIndex+1)/\(artistStats.count)"
            updateImages(withNewNames: [ordList[currIndex-1],ordList[currIndex]])
            saveData()
        } else {
            let alertController = UIAlertController(title: "Checking", message: "Haven't checked both options", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            
            // Present the alert
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func leftButton(_ sender: Any) {
        if hasSwiped || rightLast {
            newIndex += 1
            
            if newIndex >= ordList.count {
                artists[artistIndex] = ordList
                artistIndex += 1
                
                if artistIndex >= artists.count {
                    performSegue(withIdentifier: "firstToSecond", sender: self)
                    secondView = true
                    artistIndex = 0
                }
                
                ordList = artists[artistIndex].shuffled()
                newIndex = 1
                currIndex = 1
                currentPage = 0
                del = []
            } else {
                currIndex = min(newIndex,n)
                ordList[currIndex] = ordList[newIndex]
            }
            updateImages(withNewNames: [ordList[currIndex - 1], ordList[currIndex]])
            titleLabel.text = "\(newIndex-1+del.count) / \(ordList.count-1 + del.count) comparisons done for \(ordList[0]) \(artistIndex+1)/\(artistStats.count)"
            saveData()
            rightLast = false
        } else {
            let alertController = UIAlertController(title: "Checking", message: "Haven't checked both options", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            
            // Present the alert
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func baseState() {
        processArtistStats()
        artists = artists.shuffled()
        currentPage = 0
        artistIndex = 0
        ordList = artists[artistIndex].shuffled()
        newIndex = 1
        currIndex = 1
        n = 5
        del = []
        titleLabel.text = "\(newIndex-1+del.count) / \(ordList.count-1 + del.count) comparisons done for \(ordList[0]) \(artistIndex+1)/\(artistStats.count)"
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = currentPage
        
        // Disable vertical scrolling by resetting the y-content offset to 0
        scrollView.contentOffset.y = 0
        
        hasSwiped = true
        
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
    
    func processArtistStats() {
        artists = []
        for (name, num) in artistStats {
            var temp = [String]()
            for i in 1...num {
                temp.append("\(name)_\(i)")
            }
            artists.append(temp)
        }
    }
    
    func loadImages(_ names: [String]) {
        for (index, imageName) in names.enumerated() {
            if let image = UIImage(named: imageName) {
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFit
                let xPosition = CGFloat(index) * scrollView.frame.width
                imageView.frame = CGRect(x: xPosition, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
                scrollView.contentSize.width = scrollView.frame.width * CGFloat(index + 1)
                scrollView.addSubview(imageView)
            } else {
                print("Image named \(imageName) not found")
            }
        }
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        hasSwiped = false
    }
    
    func updateImages(withNewNames newNames: [String]) {
        
        for subview in scrollView.subviews {
            subview.removeFromSuperview()
        }
        
        loadImages(newNames)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "firstToSecond" {
            if let destinationVC = segue.destination as? ViewController {
                completedArray = []
                var outs = [Int]()
                for sublist in artists {
                    completedArray.append(contentsOf: Array(sublist.prefix(min(n,sublist.count))))
                    outs.append(min(n,sublist.count))
                }
                destinationVC.greaterArray = completedArray
                destinationVC.resetOuts = outs
                destinationVC.fresh = !secondView
            }
        }
    }
    
    @objc func pageControlValueChanged(_ sender: UIPageControl) {
        // Respond to page control value changes here
        let currentPage = sender.currentPage
        // Perform actions based on the current page, if needed
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create and configure the UIPageControl
        pageControl.currentPage = 0 // Set the initial current page
        pageControl.numberOfPages = 2 // Set the total number of pages
        pageControl.pageIndicatorTintColor = UIColor.lightGray // Color for inactive pages
        pageControl.currentPageIndicatorTintColor = UIColor.blue // Color for the current page
        view.addSubview(pageControl) // Add it to your view hierarchy
        
        NSLayoutConstraint.activate([
            // Center horizontally in the superview
            pageControl.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            // Pin to the bottom of the scrollView
            pageControl.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20), // You can adjust the constant value as needed
            // Set the width and height of the pageControl
            pageControl.widthAnchor.constraint(equalToConstant: 100), // Adjust the width as needed
            pageControl.heightAnchor.constraint(equalToConstant: 20) // Adjust the height as needed
        ])
        
        // Now, you can associate it with your UIScrollView
        pageControl.addTarget(self, action: #selector(pageControlValueChanged), for: .valueChanged)
        
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        
        loadData()
        
        if hardReset {
            processArtistStats()
            baseState()
            secondView = false
            hardReset = false
            saveData() // Save the defaults to UserDefaults.
        }
        
        titleLabel.text = "\(newIndex-1+del.count) / \(ordList.count-1 + del.count) comparisons done for \(ordList[0]) \(artistIndex+1)/\(artistStats.count)"
        
        loadImages([ordList[currIndex-1],ordList[currIndex]])

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print(hardReset)
        print(secondView)
        
        if secondView {
            performSegue(withIdentifier: "firstToSecond", sender: self)
        } else {
            // Display a warning message as an alert
            let alertController = UIAlertController(title: "Artists", message: "In this panel, you will go through each artist and find their top 5! Hit left if you like the left more, or right if you like the right more", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            
            // Present the alert
            present(alertController, animated: true, completion: nil)
            
            updateImages(withNewNames: [ordList[currIndex-1],ordList[currIndex]])
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
