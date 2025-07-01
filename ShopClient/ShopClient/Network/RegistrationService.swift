//
//  RegistrationService.swift
//  ShopClient
//
//  Created by Maksim Volkov on 28.06.2025.
//

import Foundation

final class RegistrationService {
    
    private let scheme = "https"
    private let host = "shopswift.volkovmd.ru"
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        return session
    }()
    
    func request(username: String, email: String, password: String) -> String {
        
        var resultMessage = ""
        // создаем словарь для отправки данных пользователя на сервер
        let param: [String: Any] = ["username": username,
                                    "email": email,
                                    "password": password
                                    ]
        
        // добавляем метод для регистрации
        let url = configureUrl(method: "/registration")
        print(url)
        
        // создаем data с данными пользователя
        let jsonData = try? JSONSerialization.data(withJSONObject: param)
        
        // create post request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // нужный способ передачи данных на Vapor
        request.httpBody = jsonData
        // без этого указания Vapor будет писать "Bad request"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            guard let data = data else { return }
            let decoder = JSONDecoder()
            
            do {
                let result = try decoder.decode(ServerResponseReg.self, from: data)
                resultMessage = result.userMessage
                print(resultMessage)
            } catch {
                print(error)
            }
        }
        task.resume()
        sleep(1)
        return resultMessage
    }
}


private extension RegistrationService {
    
    func configureUrl(method: String) -> URL {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
//        urlComponents.port = port
        urlComponents.path = method
        
        guard let url = urlComponents.url else {
            fatalError("URL is invalid")
        }
        return url
    }
}
