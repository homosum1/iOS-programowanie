//
//  ViewController.swift
//  zadanie-02
//
//  Created by Alexander on 27/11/2024.
//

import UIKit

enum TaskStatus: String {
    case planned
    case started
    case completed
}

struct Task {
    var title: String
    var status: TaskStatus
    var text: String
    var image: UIImage?
}

class ViewController: UIViewController {

    var selectedIndex: Int?
    var selectedSection: TaskStatus = .planned
    
    @IBOutlet weak var addTaskButton: UIButton!
    
    // nav buttons
    @IBOutlet weak var plannedButton: UIButton!
    @IBOutlet weak var startedButton: UIButton!
    @IBOutlet weak var completedButton: UIButton!
    
    // settings panel - completion status
    @IBOutlet weak var settingsPlannedButton: UIButton!
    @IBOutlet weak var settingsStartedButton: UIButton!
    @IBOutlet weak var settingsCompletedButton: UIButton!
    
    
    
    var tasks: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        taskSettingPanel.isHidden = true
        
        addTaskButton.layer.borderWidth = 2.0
        addTaskButton.layer.borderColor = UIColor.white.cgColor
        addTaskButton.layer.cornerRadius = 0.0

        styleButtonAsActive(plannedButton)
        styleButtonAsInactive(startedButton)
        styleButtonAsInactive(completedButton)
        
        tasks = [
            Task(title: "Testowe zadanie", status: .planned, text: "Zobaczmy czy się to zepsuje"),
            Task(title: "Buy groceries", status: .planned, text: "Milk, Eggs, Bread", image: UIImage(named: "testImg")),
            Task(title: "Complete project", status: .completed, text: "Submit before the deadline",image: UIImage(named: "food")),
            Task(title: "Call Mom", status: .started, text: "Check on her health")
        ]

        updateTaskViews()
    }


    @IBAction func addTaskButtonClicked(_ sender: Any) {
        let newTask = Task(title: "wprowadz tytul", status: selectedSection, text: "wprowadz opis")
       tasks.insert(newTask, at: 0)
       updateTaskViews()
    }
    
    func updateTaskViews() {
        tasksStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let plannedTasks = tasks.enumerated().filter { $0.element.status == selectedSection }
           
        
        for (index, task) in plannedTasks {
            let taskView = createTaskView(task: task, index: index)
            tasksStackView.addArrangedSubview(taskView)
        }
    }
    
    @IBOutlet weak var tasksStackView: UIStackView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var tasksView: UIView!
    @IBOutlet weak var addNoteView: UIView!
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
  
    
    
    @IBOutlet weak var taskSettingPanel: UIView!
    
    func createTaskView(task: Task, index: Int) -> UIView {
        let tasksListPanel = UIView()
        tasksListPanel.translatesAutoresizingMaskIntoConstraints = false

        // Title Label
        let titleLabel = UILabel()
        titleLabel.text = task.title
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.numberOfLines = 0

        // Description Label
        let descriptionLabel = UILabel()
        descriptionLabel.text = task.text
        descriptionLabel.textColor = UIColor.white
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0

        // Delete button
          let deleteButton = UIButton(type: .system)
          deleteButton.setTitle("Delete", for: .normal)
          deleteButton.setTitleColor(.red, for: .normal)
          deleteButton.tag = index
          deleteButton.addTarget(self, action: #selector(deleteTaskButtonTapped(_:)), for: .touchUpInside)
          deleteButton.translatesAutoresizingMaskIntoConstraints = false

        
        // Vertical Stack for Title and Description
        let textStack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, deleteButton])
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.spacing = 5
        textStack.translatesAutoresizingMaskIntoConstraints = false

        // Image View
        let imageView = UIImageView()
        if let taskImage = task.image {
            imageView.image = taskImage
            imageView.contentMode = .scaleAspectFit
        }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true

            
        // Horizontal Stack for Image and Text
        let mainStack = UIStackView(arrangedSubviews: [imageView, textStack])
        mainStack.axis = .horizontal
        mainStack.alignment = .center
        mainStack.spacing = 10
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        tasksListPanel.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: tasksListPanel.leadingAnchor, constant: 10),
            mainStack.trailingAnchor.constraint(equalTo: tasksListPanel.trailingAnchor, constant: -10),
            mainStack.topAnchor.constraint(equalTo: tasksListPanel.topAnchor, constant: 10),
            mainStack.bottomAnchor.constraint(equalTo: tasksListPanel.bottomAnchor, constant: -10)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(taskClicked(_:)))
        tasksListPanel.addGestureRecognizer(tapGesture)

        tasksListPanel.tag = index
        return tasksListPanel
    }

    
    @objc func taskClicked(_ sender: UITapGestureRecognizer) {
        if let taskView = sender.view {
            let index = taskView.tag
            
            performTaskAction(at: index)
        }
    }
    
    @objc func deleteTaskButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index < tasks.count else { return }

        tasks.remove(at: index)
        updateTaskViews()
    }
    
    func performTaskAction(at index: Int) {
        selectedIndex = index

        
        let task = tasks[index]
        titleField.text = task.title
        descriptionField.text = task.text
        
        mainView.isHidden = true
        buttonsView.isHidden = true
        tasksView.isHidden = true
        addNoteView.isHidden = true
        
        taskSettingPanel.isHidden = false
        
        let assignedStage = task.status
        
        
        styleButtonAsInactive(settingsPlannedButton)
        styleButtonAsInactive(settingsStartedButton)
        styleButtonAsInactive(settingsCompletedButton)
        
        if(assignedStage == .planned) {
            styleButtonAsActive(settingsPlannedButton)
        } else if (assignedStage == .started) {
            styleButtonAsActive(settingsStartedButton)
        } else {
            styleButtonAsActive(settingsCompletedButton)
        }
    }

    
    
    @IBAction func closeSettingsPanel(_ sender: Any) {
        disableSettingDisplay()
    }
    
    @IBAction func saveButtonPanel(_ sender: Any) {
        
        guard let index = selectedIndex else { return }

         tasks[index].title = titleField.text ?? ""
         tasks[index].text = descriptionField.text ?? ""

         updateTaskViews()
        
        disableSettingDisplay()
    }
    
    
    func disableSettingDisplay() {
               
        mainView.isHidden = false
        buttonsView.isHidden = false
        tasksView.isHidden = false
        addNoteView.isHidden = false
        
        taskSettingPanel.isHidden = true
    }
    
    
    @IBAction func plannedButtonClick(_ sender: Any) {
        selectedSection = .planned
        
        styleButtonAsActive(plannedButton)
        styleButtonAsInactive(startedButton)
        styleButtonAsInactive(completedButton)
        
        updateTaskViews()
    }
    
    @IBAction func startedButtonClick(_ sender: Any) {
        selectedSection = .started
        
        styleButtonAsInactive(plannedButton)
        styleButtonAsActive(startedButton)
        styleButtonAsInactive(completedButton)
        
        updateTaskViews()
    }
    
    @IBAction func completedButtonClick(_ sender: Any) {
        selectedSection = .completed

        styleButtonAsInactive(plannedButton)
        styleButtonAsInactive(startedButton)
        styleButtonAsActive(completedButton)
        
        updateTaskViews()
    }
    
    func styleButtonAsActive(_ button: UIButton) {
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.systemGray6
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.cornerRadius = 0
    }
    
    func styleButtonAsInactive(_ button: UIButton) {
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.black
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.cornerRadius = 0
    }
    
    
    // change label
    
    @IBAction func plannedButton(_ sender: Any) {
        
        guard let index = selectedIndex else { return }
        tasks[index].status = .planned
        
        styleButtonAsActive(settingsPlannedButton)
        styleButtonAsInactive(settingsStartedButton)
        styleButtonAsInactive(settingsCompletedButton)
        
        updateTaskViews()
    }
     
    @IBAction func startedButton(_ sender: Any) {
        
        guard let index = selectedIndex else { return }
        tasks[index].status = .started
        
        styleButtonAsInactive(settingsPlannedButton)
        styleButtonAsActive(settingsStartedButton)
        styleButtonAsInactive(settingsCompletedButton)
        
        updateTaskViews()
    }
    
    @IBAction func completedButton(_ sender: Any) {
        
        guard let index = selectedIndex else { return }
        tasks[index].status = .completed
        
        styleButtonAsInactive(settingsPlannedButton)
        styleButtonAsInactive(settingsStartedButton)
        styleButtonAsActive(settingsCompletedButton)
        
        updateTaskViews()
    }
    
    
    
}


