//
//  CreateGameViewController.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/18.
//

import UIKit
import Firebase

class CreateGameViewController: UIViewController {
    
    @IBOutlet weak var userNameView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet var digitCodeLabels: [UILabel]!
    
    var digits: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        userNameView.layer.cornerRadius = 12
        userNameView.layer.borderWidth = 2
        userNameView.layer.borderColor = UIColor.black.cgColor
        UsersManager.shared.beginListening(changeListener: updateNameView)
        RoomsManager.shared.beginListeningForRooms(changeListener: addRoom)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        RoomsManager.shared.stopListening()
        RoomManager.shared.stopListening()
        UsersManager.shared.stopListening()
    }
    
    func addRoom() {
        RoomsManager.shared.stopListening()
        digits = "4057" // TODO: Set it back
        while RoomsManager.shared.getOngoingWithId(roomId: digits) != nil {
            digits = RandomStringGenerator.shared.generateRandomRoomNumber()
        }
        RoomsManager.shared.addNewRoom(id: digits)
        updateDigitCodes(digits: digits)
        RoomManager.shared.setReference(roomId: digits)
        RoomManager.shared.beginListening(changeListener: playerJoined)
    }
    
    func playerJoined() {
        if RoomManager.shared.clientId == nil {
            return
        }
        print(RoomManager.shared.clientId!)
        performSegue(withIdentifier: gameSelectionSegueIdentifier, sender: self)
    }
    
    func updateNameView() {
        userNameLabel.text = UsersManager.shared.getNameWithId(uid: UserManager.shared.uid)
    }
    
    func updateDigitCodes(digits: String) {
        for label in digitCodeLabels {
            let index = label.tag
            label.text = String(Array(digits)[index])
        }
    }
    
    @IBAction func pressedBackButton(_ sender: Any) {
        RoomsManager.shared.deleteRoom(id: digits)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == gameSelectionSegueIdentifier {
            (segue.destination as! GameSelectionViewController).roomId = digits
            (segue.destination as! GameSelectionViewController).isHost = true
            (segue.destination as! GameSelectionViewController).score = 0
        }
    }
}
