//
//  ViewController.swift
//  zadanie-01
//
//  Created by Alexander on 07/11/2024.
//

import UIKit

class ViewController: UIViewController {
    
    
    var currentNum: Double = 0
    var previousNum: Double = 0
    
    var duringOperation = false
    var operation = ""
    var isDecimal = false

    
    override func viewDidLoad() {
        super.viewDidLoad()

        label_button.text = "0"
    }
    
    @IBOutlet weak var label_button: UILabel!
    
    
    @IBAction func AC_button(_ sender: Any) {
        
        currentNum = 0
        previousNum = 0
        duringOperation = false
        operation = ""
        isDecimal = false
        label_button.text = "0"
    }
    
    @IBAction func changeSign_button(_ sender: Any) {
        if (!duringOperation) {
            currentNum = -currentNum
            label_button.text = formatNumber(currentNum)
        }
    }
    
    @IBAction func percentage_button(_ sender: Any) {
        if (!duringOperation) {
            currentNum = currentNum/100
            label_button.text = formatNumber(currentNum)
        }
    }
    
    @IBAction func divide_button(_ sender: Any) {
        setOperation("/")
    }
    
   
    @IBAction func multiply_button(_ sender: Any) {
        setOperation("*")
    }
    
    
    @IBAction func substract_button(_ sender: Any) {
        setOperation("-")
    }
    
    
    @IBAction func add_button(_ sender: Any) {
        setOperation("+")
    }
    
    @IBAction func equal_button(_ sender: Any) {
    
        print("operation:")
        print(operation)
        print(currentNum)
        print(previousNum)
        
        switch operation {
        case "+":
            currentNum = previousNum + currentNum
            break
        case "-":
            currentNum = previousNum - currentNum
            break
        case "*":
            currentNum = previousNum * currentNum
            break
        case "/":
            if currentNum != 0 {
                currentNum = previousNum / currentNum
                break
            } else {
                label_button.text = "Err"
                break
            }
            
        default:
            break
        }
        
        print(currentNum)
        
        label_button.text = formatNumber(currentNum)
        duringOperation = false

        operation = ""
    }
    
    @IBAction func comma_button(_ sender: Any) {
        if !isDecimal {
            label_button.text = label_button.text! + "."
            isDecimal = true
        }
    }
    
    
    func setOperation(_ oper: String) {
        previousNum = currentNum
        operation = oper
        duringOperation = true
    }
    
    
    // numbers
    
    @IBAction func zero_button(_ sender: Any) {
        addNumber(0)
    }
    
    @IBAction func one_button(_ sender: Any) {
        addNumber(1)
    }
    
    @IBAction func two_button(_ sender: Any) {
        addNumber(2)
    }
    
    @IBAction func three_button(_ sender: Any) {
        addNumber(3)
    }
    

    @IBAction func four_button_2(_ sender: Any) {
        addNumber(4)
    }
    
    @IBAction func five_button(_ sender: Any) {
        addNumber(5)
    }
    
    @IBAction func six_button(_ sender: Any) {
        addNumber(6)
    }
    
    @IBAction func seven_button(_ sender: Any) {
        addNumber(7)
    }
    
    @IBAction func eight_button(_ sender: Any) {
        addNumber(8)
    }
    
    @IBAction func nine_button(_ sender: Any) {
        addNumber(9)
    }
    
    
    func formatNumber(_ number: Double) -> String {
        if number == floor(number) {
            return String(Int(number)) // del .0
        } else {
            return String(number)
        }
    }
    
    func addNumber(_ number: Int) {
        if(duringOperation) {
            label_button.text = "\(number)"
            duringOperation = false
            isDecimal = false
        } else {
            if(label_button.text == "0") {                
                label_button.text = "\(number)"
            } else {
                label_button.text = label_button.text! + "\(number)"
            }
        }
        
        if(Double(label_button.text!) != nil) {
            currentNum = Double(label_button.text!)!
        } else {
            currentNum = 0
        }
    }
}

