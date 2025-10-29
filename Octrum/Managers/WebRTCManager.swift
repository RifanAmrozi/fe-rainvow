import Combine
import Foundation
import WebRTC

public class WebRTCManager: ObservableObject {
    @Published var remoteVideoTrack: RTCVideoTrack?
    @Published var isConnected: Bool = false
    @Published var isConnecting: Bool = false

    private var peerConnection: RTCPeerConnection?
    private var webRTCDelegate: WebRTCDelegate?
    private let factory = RTCPeerConnectionFactory()
    
    // Set timeout
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30.0
        config.timeoutIntervalForResource = 60.0
        config.waitsForConnectivity = true
        return URLSession(configuration: config)
    }()

    func connect(whepURL: String) {
        var finalURL = whepURL
        if !whepURL.hasSuffix("/whep") {
            finalURL = whepURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            finalURL += "/whep"
        }
        
        guard let url = URL(string: finalURL), url.scheme == "http" || url.scheme == "https" else {
            print("Error: Invalid WHEP URL - \(finalURL)")
            return
        }
        
        DispatchQueue.main.async {
            self.isConnecting = true
        }
        print("WHEP: Starting connection to \(url)")

        self.webRTCDelegate = WebRTCDelegate()
        self.webRTCDelegate?.onTrack = { track in
            DispatchQueue.main.async {
                print("WHEP: Video track received.")
                self.remoteVideoTrack = track
                self.isConnected = true
                self.isConnecting = false
            }
        }
        self.webRTCDelegate?.onConnectionStateChange = { state in
            print("WHEP: Connection state changed to \(state.rawValue)")
            if state == .failed || state == .disconnected || state == .closed {
                DispatchQueue.main.async {
                    self.disconnect()
                }
            }
        }

        let config = RTCConfiguration()
        config.iceServers = []
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        
        guard let pc = self.factory.peerConnection(with: config, constraints: constraints, delegate: self.webRTCDelegate) else {
            print("Error: Could not create PeerConnection.")
            DispatchQueue.main.async {
                self.isConnecting = false
            }
            return
        }
        self.peerConnection = pc

        let transceiverInit = RTCRtpTransceiverInit()
        transceiverInit.direction = .recvOnly
        pc.addTransceiver(of: .video, init: transceiverInit)

        pc.offer(for: constraints) { offer, error in
            if let error = error {
                print("Error creating offer: \(error.localizedDescription)")
                DispatchQueue.main.async { self.disconnect() }
                return
            }
            guard let offer = offer else {
                print("Error: Offer is nil")
                DispatchQueue.main.async { self.disconnect() }
                return
            }

            pc.setLocalDescription(offer) { error in
                if let error = error {
                    print("Error setting local description: \(error.localizedDescription)")
                    DispatchQueue.main.async { self.disconnect() }
                    return
                }
                print("WHEP: Local description set. Sending offer...")
                self.sendOffer(offer: offer, url: url)
            }
        }
    }

    private func sendOffer(offer: RTCSessionDescription, url: URL) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/sdp", forHTTPHeaderField: "Content-Type")
        request.httpBody = offer.sdp.data(using: .utf8)
        request.timeoutInterval = 30.0

        print("WHEP: Sending POST request to \(url)")
        print("WHEP: SDP Offer length: \(offer.sdp.count) bytes")

        urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                let nsError = error as NSError
                print("❌ Error POSTing offer: \(error.localizedDescription)")
                print("   Error domain: \(nsError.domain), code: \(nsError.code)")
                DispatchQueue.main.async { self.disconnect() }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Error: No HTTP response received")
                DispatchQueue.main.async { self.disconnect() }
                return
            }
            
            print("WHEP: HTTP Status Code: \(httpResponse.statusCode)")
            print("WHEP: Response Headers: \(httpResponse.allHeaderFields)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("❌ Error: HTTP error \(httpResponse.statusCode)")
                if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                    print("   Response body: \(responseBody)")
                }
                DispatchQueue.main.async { self.disconnect() }
                return
            }
            
            guard let data = data, let answerSDP = String(data: data, encoding: .utf8) else {
                print("❌ Error: Could not get answer SDP from response.")
                DispatchQueue.main.async { self.disconnect() }
                return
            }

            print("✅ WHEP: Received SDP answer (\(answerSDP.count) bytes)")
            print("WHEP: Setting remote description...")
            let answer = RTCSessionDescription(type: .answer, sdp: answerSDP)
            self.peerConnection?.setRemoteDescription(answer) { error in
                if let error = error {
                    print("❌ Error setting remote description: \(error.localizedDescription)")
                    DispatchQueue.main.async { self.disconnect() }
                } else {
                    print("✅ WHEP: Remote description set successfully! Waiting for tracks...")
                }
            }
        }.resume()
    }

    func disconnect() {
        guard isConnected || isConnecting else { return }
        print("WHEP: Disconnecting...")
        peerConnection?.close()
        peerConnection = nil
        DispatchQueue.main.async {
            self.remoteVideoTrack = nil
            self.isConnected = false
            self.isConnecting = false
        }
    }
}
