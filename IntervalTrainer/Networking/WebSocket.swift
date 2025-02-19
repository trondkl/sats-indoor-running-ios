import Foundation

class WebSocket: NSObject, URLSessionWebSocketDelegate {
    private var webSocket: URLSessionWebSocketTask?
    private var sessionUpdateHandler: ((WorkoutSession) -> Void)?

    override init() {
        super.init()
        setupWebSocket()
    }

    private func setupWebSocket() {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())

        // Construct WebSocket URL using the same host as the web app
        let scheme = "wss"
        let host = Bundle.main.object(forInfoDictionaryKey: "API_HOST") as? String ?? "localhost:3000"
        let url = URL(string: "\(scheme)://\(host)/ws")!

        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()

        receiveMessage()
    }

    func joinSession(_ code: String, completion: @escaping (WorkoutSession) -> Void) {
        sessionUpdateHandler = completion

        let message = ["type": "join", "code": code]
        send(message)
    }

    func updateSession(code: String, currentInterval: Int? = nil, isActive: Bool? = nil) {
        var message: [String: Any] = ["type": "update", "code": code]
        if let currentInterval = currentInterval {
            message["currentInterval"] = currentInterval
        }
        if let isActive = isActive {
            message["isActive"] = isActive
        }
        send(message)
    }

    private func send(_ message: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: message) else { return }
        let message = URLSessionWebSocketTask.Message.data(data)
        webSocket?.send(message) { error in
            if let error = error {
                print("WebSocket sending error: \(error)")
            }
        }
    }

    private func receiveMessage() {
        webSocket?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    if let session = try? WorkoutSession.decode(from: data) {
                        DispatchQueue.main.async {
                            self?.sessionUpdateHandler?(session)
                        }
                    }
                case .string(let string):
                    if let data = string.data(using: .utf8),
                       let session = try? WorkoutSession.decode(from: data) {
                        DispatchQueue.main.async {
                            self?.sessionUpdateHandler?(session)
                        }
                    }
                @unknown default:
                    break
                }

                // Continue receiving messages
                self?.receiveMessage()

            case .failure(let error):
                print("WebSocket receive error: \(error)")
                // Attempt to reconnect after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self?.setupWebSocket()
                }
            }
        }
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket did connect")
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket did disconnect")
    }
}