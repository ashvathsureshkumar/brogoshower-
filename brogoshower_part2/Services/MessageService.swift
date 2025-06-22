import Foundation
import MessageUI
import UIKit

class MessageService {
    static let shared = MessageService()
    
    private init() {}
    
    func sendChallenge(from viewController: UIViewController, delegate: MFMessageComposeViewControllerDelegate) {
        guard MFMessageComposeViewController.canSendText() else {
            let alert = UIAlertController(title: "Messages Not Available", message: "Your device cannot send text messages.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            viewController.present(alert, animated: true, completion: nil)
            return
        }
        
        let messageController = MFMessageComposeViewController()
        messageController.messageComposeDelegate = delegate
        messageController.body = """
        bro u fucking smell 🤢
        
        i doubt you even showered today
        
        prove me wrong. i dare u
        
        <app link>

        stinky ahh 🤮
        """
        
        viewController.present(messageController, animated: true, completion: nil)
    }
    
    static func handleMessageResult(_ result: MessageComposeResult, viewController: UIViewController) {
        switch result {
        case .cancelled:
            break
        case .sent:
            let alert = UIAlertController(title: "Challenge Sent! 🏆", message: "Your shower challenge has been sent!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Awesome!", style: .default, handler: nil))
            viewController.present(alert, animated: true, completion: nil)
        case .failed:
            let alert = UIAlertController(title: "Failed to Send", message: "Could not send your challenge message.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            viewController.present(alert, animated: true, completion: nil)
        @unknown default:
            break
        }
    }
} 