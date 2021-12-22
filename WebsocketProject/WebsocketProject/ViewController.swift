//
//  ViewController.swift
//  WebsocketProject
//
//  Created by Dzmitry on 20.12.21.
//

import UIKit

class ViewController: UIViewController, URLSessionWebSocketDelegate {
    
    private var webSocket: URLSessionWebSocketTask?
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Send", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let listenButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Listen", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBlue
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        let url = URL(string: "wss://demo.piesocket.com/v3/channel_1?api_key=oCdCMcMPQpbvNjUIzqtvF1d2X2okWpDQj4AwARJuAgtjhzKxVEjQU6IdCjwm&notify_self")
        webSocket = session.webSocketTask(with: url!)
        webSocket?.resume()
        view.addSubview(closeButton)
        setCloseButtonConstraints()
        view.addSubview(sendButton)
        setSendButtonConstraints()
        view.addSubview(listenButton)
        setListenButtonConstraints()
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(send), for: .touchUpInside)
        listenButton.addTarget(self, action: #selector(listen), for: .touchUpInside)
        
        
        
    }
    
    func setCloseButtonConstraints() {
        NSLayoutConstraint.activate([
            closeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60),
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 100),
            closeButton.heightAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    func setSendButtonConstraints() {
        NSLayoutConstraint.activate([
            sendButton.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -20),
            sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 100),
            sendButton.heightAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    func setListenButtonConstraints() {
        NSLayoutConstraint.activate([
            listenButton.bottomAnchor.constraint(equalTo: sendButton.topAnchor, constant: -20),
            listenButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            listenButton.widthAnchor.constraint(equalToConstant: 100),
            listenButton.heightAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    @objc func listen() {
        ping()
    }
    
    func ping() {
        webSocket?.sendPing(pongReceiveHandler: {error in
            if let error = error {
                print("Ping error: \(error)")
            }
            
        })
    }
    
    @objc func close() {
        webSocket?.cancel(with: .goingAway, reason: "Demo ended".data(using: .utf8))
    }
    
    @objc func send() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            //self.send()
            self.webSocket?.send(.string("Send new message: \(Int.random(in: 0...10))"), completionHandler: { error in
                if let error = error {
                    print("Send error: \(error)")
                }
            })
        }
        
    }
    
    func receive() {
        webSocket?.receive(completionHandler: { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    print("Got data: \(data)")
                case .string(let message):
                    print("Got string: \(message)")
                @unknown default:
                    break
                }
                
            case .failure(let error):
                print("Receive error: \(error.localizedDescription)")
            }
            
            self?.receive()
        })
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Did connect to socket")
        ping()
        receive()
        send()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Did close connection")
    }

}

