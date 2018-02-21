//
//  NewTaskViewController.swift
//  addNewAndEditTask
//
//  Created by Ganna Melnyk on 2/8/18.
//  Copyright © 2018 Ganna Melnyk. All rights reserved.
//

import UIKit

class NewTaskViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let notificationManager = NotificationManager()
    var imageDoc = RMAFileManager()
    var taskToBeUpdated: RMATask?
    var isNewTask = true
    var editIsTapped = false
    var taskIdentifier = 0
    var imageURL: String?
    
    let allTagsResults = RMARealmManager.getAllTags()
    var tagList = Array<RMATag>()
    
    let defaultImage = #imageLiteral(resourceName: "defaultPic")
    let DESCRIPTION_PLACEHOLDER = "put a task description here, if you wish :)"
    let NAME_PLACEHOLDER = "put a name for the task here"
    //    var name: String?
    //    var date: NSDate?
    //    var formattedDate: String?
    //    var location: String?
    var image: UIImage?
    //    var descr: String?
    
    var picker = UIImagePickerController()
    let datePicker = UIDatePicker()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var tagTableView: UITableView!
    @IBOutlet weak var tagViewSelectButton: UIButton!
    
    @IBOutlet weak var tagViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTagViewConstraint: NSLayoutConstraint!
    
    //    func dataFromTask() {
    //        if let taskToBeUpdated = taskToBeUpdated {
    //            self.title = taskToBeUpdated.name
    //            name = taskToBeUpdated.name
    //            date = taskToBeUpdated.date
    //            //            imageURL = taskToBeUpdated.imageURL
    //            print("imageURLFromDB: \(String(describing: imageURL))")
    //            if let temp = taskToBeUpdated.imageURL {
    //                image = imageDoc.loadImageFromPath(imageURL: temp)
    //            }
    //            //            if imageURL != nil {
    //            //                image = imageDoc.loadImageFromPath(imageURL: imageURL!)
    //            //            }
    //            descr = taskToBeUpdated.fullDescription
    //            for tag in taskToBeUpdated.tags {
    //                tagList.append(tag)
    //            }
    //        }
    //    }
    
    func addNewTaskToDB() {
        RMARealmManager.addTask(newTask: taskToBeUpdated!)
        notificationManager.setNotification(with: taskToBeUpdated!)
    }
    
    
    
    @IBAction func saveTagsButton(_ sender: UIButton) {
        bottomTagViewConstraint.constant = -tagViewHeightConstraint.constant
        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()
        }
        self.tableView.reloadData()
    }
    
    func updateConstraints() {
        tagTableView.rowHeight = 40
        tagTableViewHeightConstraint.constant = tagTableView.rowHeight * CGFloat(allTagsResults.count)
        self.tagTableView.layoutIfNeeded()
        bottomTagViewConstraint.constant = -tagViewHeightConstraint.constant
        self.tagView.layoutIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let taskToBeUpdated = taskToBeUpdated {
            self.title = taskToBeUpdated.name
            isNewTask = false
            // TODO: fill the controls accoding to taskToBeUpdated
        } else {
            taskToBeUpdated = RMATask()
        }
        tableView.delegate = self
        tableView.dataSource = self
        tagTableView.delegate = self
        tagTableView.dataSource = self
        
        picker.delegate = self
        
        self.tabBarController?.tabBar.isHidden = true
        
        //        dataFromTask()
        addDatePicker()
        
        tagTableView.layer.cornerRadius = 15
        tagView.layer.cornerRadius = 30
        tagViewSelectButton.layer.cornerRadius = 15
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let rightBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "save_small"), style: .plain, target: self, action: #selector(self.navigationControllerButton))
        startBarButton(rightBarButton: rightBarButton)
        self.tableView.reloadData()
        updateConstraints()
        self.hideKeyboardWhenTappedAround()
    }
    
    func startBarButton(rightBarButton: UIBarButtonItem) {
        if !isNewTask {
            editIsTapped = false
            rightBarButton.image = #imageLiteral(resourceName: "edit_small")
        } else {
            editIsTapped = true
            rightBarButton.image = #imageLiteral(resourceName: "save_small")
        }
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc func navigationControllerButton(rightBarButton: UIBarButtonItem) {
        editIsTapped = !editIsTapped
        if editIsTapped {
            rightBarButton.image = #imageLiteral(resourceName: "save_small")
        } else {
            if taskIdentifier == 0 {
                if taskToBeUpdated?.name == nil || (taskToBeUpdated?.name.trimmingCharacters(in: .whitespaces).isEmpty)! || taskToBeUpdated?.name.count == 0 {
                    let alertController = UIAlertController(title: "Empty name field", message: "give a name to the task", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "ok", style: .destructive, handler: nil)
                    alertController.addAction(okAction)
                    present(alertController, animated: false, completion: nil)
                    editIsTapped = !editIsTapped
                } else {
                    rightBarButton.image = #imageLiteral(resourceName: "edit_small")
                    addNewTaskToDB()
                    let controllerIndex = self.navigationController?.viewControllers.index(where: { (viewController) -> Bool in
                        return viewController is RMATasksVC
                    })
                    let destination = self.navigationController?.viewControllers[controllerIndex!]
                    let transition = CATransition()
                    transition.duration = 0.5
                    transition.type = kCATransitionFade
                    self.navigationController?.view.layer.add(transition, forKey: nil)
                    self.navigationController?.popToViewController(destination!, animated: false)
                }
            }
        }
        UIView.transition(with: tableView,
                          duration: 1,
                          options: .transitionCrossDissolve,
                          animations:
            { () -> Void in
                self.tableView.reloadData()
        },
                          completion: nil);
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func formatDate(date: NSDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy hh:mm a"
        return dateFormatter.string(from: date as Date)
    }
    
    func addDatePicker() {
        
        datePicker.frame = CGRect(x: 10, y: self.view.frame.height , width: self.view.frame.width - 20, height: 200)
        datePicker.timeZone = NSTimeZone.local
        datePicker.backgroundColor = UIColor.white
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(_:)), for: .valueChanged)
        self.view.addSubview(datePicker)
        
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker){
        taskToBeUpdated?.date = sender.date as NSDate
        tableView.reloadData()
    }
    
    func cameraGalery() {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction: UIAlertAction = UIAlertAction(title: "Camera", style: .default) { action -> Void in
            print("Camera choosen")
            self.openCamera()
        }
        
        let secondAction: UIAlertAction = UIAlertAction(title: "Galery", style: .default) { action -> Void in
            print("Galery choosen")
            self.openGallery()
            
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(secondAction)
        actionSheetController.addAction(cancelAction)
        present(actionSheetController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let newImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            image = newImage
            let tempImage = newImage
            let imageDate = Date()
            imageDoc.addToUrl(tempImage, create: imageDate)
            taskToBeUpdated?.imageURL = String(describing: imageDate)
            print("imageURLTooDB: \(String(describing: imageURL))")
            self.tableView.reloadData()
            picker.dismiss(animated: true, completion: nil)
        }
        print("it have to store image in local var")
    }
    
    func openGallery() {
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            present(picker, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Camera Not Found", message: "This device has no Camera", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
}

extension NewTaskViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            if indexPath.row == 1 {
                UIView.animate(withDuration: 1, animations: {
                    self.taskToBeUpdated?.date = NSDate()
                    tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                    self.datePicker.frame.origin.y = self.view.frame.height - 200
                    self.datePicker.layoutIfNeeded()
                })
            } else if indexPath.row == 2 {
                guard let mapsVC = storyboard?.instantiateViewController(withIdentifier: String(describing: RMAMapVC.self)) as? RMAMapVC else { return }
                mapsVC.locationDelegate = self
                mapsVC.navigationItem.title = "Add location"
                mapsVC.navigationItem.backBarButtonItem?.title = "Cancel"
                mapsVC.navigationController?.navigationItem.leftBarButtonItem?.title = "Cancel"
                mapsVC.isInAddLocationMode = true
                navigationController?.pushViewController(mapsVC, animated: true)
                print("add location")
            } else if indexPath.row == 4 {
                bottomTagViewConstraint.constant = 0
                UIView.animate(withDuration: 1) {
                    self.view.layoutIfNeeded()
                }
            }
            if indexPath.row != 1 {
                UIView.animate(withDuration: 1, animations: {
                    self.datePicker.frame.origin.y = self.view.frame.height
                    self.datePicker.layoutIfNeeded()
                })
            }
        } else {
            let oneTag = allTagsResults[indexPath.row]
            if tagList.contains(where: {$0.name == oneTag.name}) {
                let index = tagList.index(where: {$0.name == oneTag.name})
                tagList.remove(at: index!)
            } else {
                tagList.append(oneTag)
            }
            tagTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
        }
        
    }
    
    @objc func imgTapped(sender: UITapGestureRecognizer) {
        cameraGalery()
        print("picture tapped")
    }
}

extension NewTaskViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView {
            return 5
        }
        if tableView == self.tagTableView {
            return allTagsResults.count
        }
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            if !editIsTapped {
                tableView.isUserInteractionEnabled = false
                
            } else {
                tableView.isUserInteractionEnabled = true
            }
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell") as! NameTVCell
                cell.nameLabel.text = "name: "
                cell.putNameHere.textAlignment = .right
                cell.putNameHere.textContainer.maximumNumberOfLines = 1
                cell.putNameHere.delegate = self
                cell.putNameHere.tag = 1
                cell.putNameHere.autocorrectionType = .no
                cell.putNameHere.autocapitalizationType = .none
                
                if taskToBeUpdated?.name.count == 0 {
                    cell.putNameHere.text = NAME_PLACEHOLDER
                    cell.putNameHere.textColor = UIColor.lightGray
                } else {
                    cell.putNameHere.text = taskToBeUpdated?.name
                    cell.putNameHere.textColor = UIColor.black
                }
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell") as! DateOrLocationTVCell
                cell.informationLabel.textAlignment = .right
                cell.fieldNameLabel.text = "date: "
                if taskToBeUpdated?.date == nil {
                    cell.informationLabel.text = "select date"
                    cell.informationLabel.textColor = UIColor.lightGray
                } else {
                    cell.informationLabel.text = formatDate(date: (taskToBeUpdated?.date)!)
                    cell.informationLabel.textColor = UIColor.black
                }
                
                return cell
            } else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell") as! DateOrLocationTVCell
                cell.informationLabel.textAlignment = .right
                cell.fieldNameLabel.text = "location: "
                if taskToBeUpdated?.location?.name == nil {
                    cell.informationLabel.text = "select location"
                    cell.informationLabel.textColor = UIColor.lightGray
                } else {
                    cell.informationLabel.text = taskToBeUpdated?.location?.name
                    cell.informationLabel.textColor = UIColor.black
                }
                return cell
            } else if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "imageAndDescr") as! ImageAndDescrTVCell
                cell.descrTextView.text = "information: "
                cell.pictureView.image = image
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imgTapped(sender:)))
                cell.pictureView.addGestureRecognizer(tapGesture)
                cell.descrTextView.autocorrectionType = .no
                cell.descrTextView.autocapitalizationType = .none
                if let imageFromDB = taskToBeUpdated?.imageURL {
                    image = imageDoc.loadImageFromPath(imageURL: imageFromDB)
                    cell.pictureView.image = image
                } else {
                    cell.pictureView.image = defaultImage
                }
                cell.descrTextView.textAlignment = .right
                cell.descrTextView.delegate = self
                cell.descrTextView.tag = 2
                if taskToBeUpdated?.fullDescription == nil {
                    cell.descrTextView.text = DESCRIPTION_PLACEHOLDER
                    cell.descrTextView.textColor = UIColor.lightGray
                } else {
                    cell.descrTextView.text = taskToBeUpdated?.fullDescription
                    cell.descrTextView.textColor = UIColor.black
                }
                return cell
            }
            else if indexPath.row == 4 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "tagsCell") as! TagsTVCell
                for cellSubview in cell.subviews{
                    if cellSubview != cell.tagesLabel && cellSubview != cell.contentView {
                        cellSubview.removeFromSuperview()
                    }
                }
                cell.tagesLabel.text = "tags: "
                var i: CGFloat = 1
                for tag in tagList {
                    cell.addSubview(drawSquare(frameWidth: cell.frame.width, number: i, color: UIColor.fromHexString(tag.color)))
                    i += 1
                }
                return cell
            }  else {
                fatalError("wrong cell counter")
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "oneTagCell") as! TagScreenTVCell
            let tagForCell = allTagsResults[indexPath.row]
            cell.tagColorView.layer.cornerRadius = 10
            cell.tagColorView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cell.tagColorView.layer.borderWidth = 2
            cell.tagColorView.backgroundColor = UIColor.fromHexString(tagForCell.color)
            cell.tagLabel.text = tagForCell.name
            if tagList.contains(where: {$0.name == tagForCell.name}) {
                cell.tagIsChoosePic.image = #imageLiteral(resourceName: "check")
            } else  {
                cell.tagIsChoosePic.image = #imageLiteral(resourceName: "uncheck")
            }
            return cell
        }
    }
    
    func drawSquare(frameWidth: CGFloat, number: CGFloat, color: UIColor) -> UIView {
        let size: CGFloat = 20
        let space: CGFloat = 5
        let rectangle = UIView(frame: CGRect(x: frameWidth - (size * number) - (space * number), y: 12, width: size, height: size))
        rectangle.backgroundColor = color
        rectangle.layer.borderWidth = 1
        rectangle.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        rectangle.layer.cornerRadius = 10
        return rectangle
    }
}

extension NewTaskViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        if textView.tag == 1 {
            textView.text = taskToBeUpdated?.name
        } else if textView.tag == 2 {
            textView.text = taskToBeUpdated?.fullDescription
            
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.tag == 1 {
            taskToBeUpdated?.name = textView.text
        } else if textView.tag == 2 {
            taskToBeUpdated?.fullDescription = textView.text
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (taskToBeUpdated?.name == nil || taskToBeUpdated?.name.count == 0) && textView.tag == 1 {
            textView.text = NAME_PLACEHOLDER
            textView.textColor = UIColor.lightGray
        } else if (taskToBeUpdated?.fullDescription == nil || taskToBeUpdated?.fullDescription?.count == 0) && textView.tag == 2 {
            textView.text = DESCRIPTION_PLACEHOLDER
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        if textView.tag == 1 {
            return numberOfChars <= 25
        } else {
            return numberOfChars <= 200
        }
    }
}

extension NewTaskViewController: SetLocationDelegate {
    func setLocation(location: RMALocation) {
        taskToBeUpdated?.location? = location
        print("\(String(describing: taskToBeUpdated?.location))")
    }
    
    //    func setLocation(location: TaskLocation) {
    //        self.location = "\(location.coordinates.latitude), \(location.coordinates.latitude)"
    //        print("\(self.location)")
    //    }
}
