//
//  CommentsViewController.swift
//  SAB-Cars
//
//  Created by Osama folta on 14/05/1443 AH.
//
import FirebaseAuth
import FirebaseFirestore
import Firebase
import UIKit

class CommentsViewController: UIViewController {
    
    var chatRoom = String()
    var photo = String()
    var carObject = Car()
    let userId = Auth.auth().currentUser?.uid
    var dbStore = Firestore.firestore().collection("users")
    let ref = Database.database().reference().child("Comments")
    var messages = [Comment]()
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        design.chageColore(self.view)
        super.viewDidLoad()
        readMsgs()
        // Do any additional setup after loading the view.
        tableview.register(UINib(nibName: "CarImageCell", bundle: nil), forCellReuseIdentifier: "bannerid")
    }
    
    @IBAction func clearChat(_ sender: UIBarButtonItem) {
        if carObject.userID == Auth.auth().currentUser?.uid{
                        print ("Can Delete")
                        self.deleteMessage()
        }else{
            sender.isEnabled = false
        }
        
    }
    @IBAction func sendButton(_ sender: Any) {
        if textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            design.useAlert(title: "Wrong Action", message: "No Text", vc: self)
        } else{ sendMsg() }
        
    }
    
    func sendMsg(){
        var fullname = String ()
        dbStore.whereField("uid", isEqualTo: Auth.auth().currentUser!.uid)
            .getDocuments { snapshot, err in
                guard let snapshot = snapshot else { return }
                let data = snapshot.documents.first!.data()
                let fname = data["firstName"] as! String
                let lname = data["lastName"] as! String
                fullname = fname + " " + lname
                let phoneNumber=(data["phoneNumber"]!) as! Int
                let show=(data["showPhone"]!) as! Bool
                if show == true{fullname = fname + " " + "\(phoneNumber)" }
                
                
                let dbRef = self.ref.child(self.chatRoom).childByAutoId()
                
                let liveChat=["sender":fullname , "message":self.textField.text!, "date": Date.now.formatted(.dateTime), "userID":self.userId,"MsgID":dbRef.key]
                
                dbRef.setValue(liveChat){(error,refernce)in
                    
                    if error != nil{
                        design.useAlert(title: "error", message: error!.localizedDescription, vc: self)
                    }
                }; self.textField.text=""
            }
    }
    func readMsgs(){
        
        ref.child(chatRoom).observe(.childAdded) { snapshot in
            
            let result=snapshot.value as! Dictionary<String,String>
            var sender=result["sender"]!
            let msg=result["message"]!
            let date=result["date"]!
            let user=result["userID"]!
            let id=result["MsgID"]!
            if user==self.userId{sender=" 👤 You"}
            let package=Comment(sender: sender, date: date, message: msg,id:id, userID: user)
            
            self.messages.append(package)
            self.tableview.reloadData()
           
        }
    }
    fileprivate func deleteMessage() {
        let alert = UIAlertController(title: " Are You Sure", message: "This action deletes all messages", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler:{(action) in
            Database.database().reference().child("Comments").child(self.chatRoom).removeValue()
            self.messages.removeAll()
            self.tableview.reloadData()
            
        }))
        present(alert, animated: true, completion: nil)
    }
}


extension CommentsViewController :UITableViewDelegate ,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {return 1}
        else{
            return  messages.count}
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let  cell = tableView.dequeueReusableCell(withIdentifier: "bannerid", for: indexPath) as! CarImageCell
            cell.bigImage.imageFromURL(imagUrl: photo)
            cell.carDescription.text = carObject.status
            cell.brand.text = carObject.brand
            return cell
        }
        else{
            let cell = tableview.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatCell
            var comment = messages[indexPath.row]
            if comment.userID == userId{
                cell.changeNameToGray()
            }
            if carObject.userID == messages[indexPath.row].userID {
                comment.sender = "Owner: \(comment.sender)" }
            cell.setData(name: comment.getSender(), msg: " \(comment.getmessage())", date: comment.getdate())
            
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { return 250 }
        else{  return 120 }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            let showvc = storyboard?.instantiateViewController(withIdentifier: "Connect") as! BigImageVC
            showvc.link = photo
            navigationController?.show(showvc, sender: self)
        }
    }
    
}
