//
//  ViewController2.swift
//  Tattoos
//
//  Created by Kevin Carey on 9/19/23.
//

import UIKit
import MessageUI

class ViewController2: UIViewController, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIScrollViewDelegate {
    
    
    @IBOutlet weak var numTitle: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var currentPage: Int = 0
    var ordList: [String] = []
    
    @IBAction func sendText(_ sender: Any) {
        let listContent = ordList.joined(separator: "\n")
        sendTextMessageWithList(listContent: listContent)
    }
    
    @IBAction func emailButton(_ sender: Any) {
        let listContent = ordList.joined(separator: "\n")
        sendEmailWithList(listContent: listContent)
    }
    
    @IBAction func resetButton(_ sender: Any) {
        performSegue(withIdentifier: "resetOrder", sender: self)
    }
    @IBAction func swapNext(_ sender: Any) {
        if currentPage != ordList.count - 1 {
            let temp = ordList[currentPage]
            ordList[currentPage] = ordList[currentPage + 1]
            ordList[currentPage + 1] = temp
            updateImages(withNewNames: ordList)
        }
    }
    @IBAction func swapPrev(_ sender: Any) {
        if currentPage != 0 {
            let temp = ordList[currentPage]
            ordList[currentPage] = ordList[currentPage - 1]
            ordList[currentPage - 1] = temp
            updateImages(withNewNames: ordList)
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        
        // Update the numTitle label with the current page number
        numTitle.text = "\(currentPage + 1) / \(ordList.count)"
        // Disable vertical scrolling by resetting the y-content offset to 0
        scrollView.contentOffset.y = 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "resetOrder" {
            if let destinationVC = segue.destination as? FirstViewController {
                destinationVC.hardReset = true
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        numTitle.text = " 1 / \(ordList.count)"
        
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        leftSwipeGesture.direction = .left
        scrollView.addGestureRecognizer(leftSwipeGesture)
        
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        rightSwipeGesture.direction = .right
        scrollView.addGestureRecognizer(rightSwipeGesture)
        
        loadImages(ordList)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Display a warning message as an alert
        let alertController = UIAlertController(title: "Congrats!!!", message: "This is your order!! Thanks for helping me pick out some hopefully sick art", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(okAction)
        
        // Present the alert
        present(alertController, animated: true, completion: nil)
        
        updateImages(withNewNames: ordList)
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
    }
    
    func updateImages(withNewNames newNames: [String]) {
        let previousPageIndex = currentPage
        
        for subview in scrollView.subviews {
            subview.removeFromSuperview()
        }
        
        loadImages(newNames)
        
        let newContentOffsetX = CGFloat(previousPageIndex) * scrollView.frame.width
        scrollView.contentOffset = CGPoint(x: newContentOffsetX, y: 0)
        currentPage = previousPageIndex
    }
    
    func sendTextMessageWithList(listContent: String) {
        if MFMessageComposeViewController.canSendText() {
            let messageComposeViewController = MFMessageComposeViewController()
            messageComposeViewController.messageComposeDelegate = self
           
            messageComposeViewController.body = "Here is my list:\n\n\(listContent)"
            
            self.present(messageComposeViewController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Text Messaging Not Available", message: "Your device is not set up to send text messages.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func sendEmailWithList(listContent: String) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
           
            mailComposeViewController.setToRecipients(["racynniv@gmail.com"])
            mailComposeViewController.setSubject("My List")
            mailComposeViewController.setMessageBody("Here is my list:\n\n\(listContent)", isHTML: false)
            
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Email Not Configured", message: "Your device is not set up to send emails.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
        switch result {
        case .cancelled:
            print("Email cancelled")
        case .saved:
            print("Email saved as a draft")
        case .sent:
            print("Email sent successfully")
        case .failed:
            print("Email sending failed")
        @unknown default:
            break
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
        
        switch result {
        case .cancelled:
            print("Message composition cancelled")
        case .sent:
            print("Message sent successfully")
        case .failed:
            print("Message sending failed")
        @unknown default:
            break
        }
    }
}
