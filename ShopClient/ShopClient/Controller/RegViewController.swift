//
//  RegViewController.swift
//  ShopClient
//
//  Created by Maksim Volkov on 28.06.2025.
//

import UIKit

class RegViewController: UIViewController {

       
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var registrationButton: UIButton!
    
    let registrationService = RegistrationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        
        scrollView.delegate = self
        
        let hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        scrollView.addGestureRecognizer(hideKeyboardGesture)
    }
    
    @IBAction func regButton(_ sender: UIButton) {
        if passwordTextField.text != confirmPasswordTextField.text {
            let alertController = UIAlertController(title: "Проблема с паролем", message: "Пароли не одинаковы", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ОК", style: .default) { _ in}
            alertController.addAction(okAction)
            present(alertController, animated: true)
        } else if passwordTextField.text?.isEmpty == true {
            let alertController = UIAlertController(title: "Проблема с паролем", message: "Вы не ввели пароль", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ОК", style: .default) { _ in}
            alertController.addAction(okAction)
            present(alertController, animated: true)
        } else {
            guard userNameTextField.text?.isEmpty == false,
                  emailTextField.text?.isEmpty == false,
                  passwordTextField.text?.isEmpty == false,
                  let username = userNameTextField.text,
                  let email = emailTextField.text,
                  let password = passwordTextField.text
            else { return }
            // на получение response установлено 2 секунды
            let response = registrationService.request(username: username, email: email, password: password)
            if response != "" {
                afterRegistration(status: response)
            } else {
                let alertController = UIAlertController(title: "Что-то пошло не так!", message: "Наверное плохое соединение с интернетом", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "ОК", style: .default) { _ in}
                alertController.addAction(okAction)
                present(alertController, animated: true)
            }
        }
    }
    
    func afterRegistration(status: String) {
        // создаем алертконтроллер, который будет появляться после отправки введенных данных на сервер
        let alertController = UIAlertController(title: "Попытка регистрации", message: status, preferredStyle: .alert)
        // создаем кнопку "Войти"
        let enterAction = UIAlertAction(title: "Войти", style: .default) { _ in
            // после нажатия на кнопку "OK" будет произведен переход на экран авторизации
            self.performSegue(withIdentifier: "afterReg", sender: self)
        }
        // создаем кнопку "Назад"
        let backAction = UIAlertAction(title: "Назад", style: .default) { _ in}
        
        // формируем AlertController в зависимости от ответа сервера
        if status == "Регистрация прошла успешно!" {
            // добавляем кноку "Войти" в алертконтроллер
            alertController.addAction(enterAction)
        } else if status == "Пользователь с таким e-mail уже зарегистрирован" {
            // добавляем кноку "Назад" в алертконтроллер
            alertController.addAction(backAction)
        }
        // презентуем алертконтроллер с анимацией
        present(alertController, animated: true)
    }
}

// MARK: Отображение ScrollView при работе с клавиатурой
extension RegViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0.0
    }
}

// MARK: Отображение и сокрытие клавиатуры
extension RegViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWasShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillBeHidden),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc func hideKeyboard() {
        scrollView.endEditing(true)
    }
    
    @objc func keyboardWasShow(notification: Notification) {
        let info = notification.userInfo! as NSDictionary
        // получаем размер клавиатуры
        let kbSize = (info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
        // для скрола добавляем расстояние, равное клаве
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
    
    @objc func keyboardWillBeHidden(notification: Notification) {
        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
}


