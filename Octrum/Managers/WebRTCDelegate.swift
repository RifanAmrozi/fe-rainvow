import Foundation
import WebRTC

class WebRTCDelegate: NSObject, RTCPeerConnectionDelegate {
    var onTrack: ((RTCVideoTrack) -> Void)?
    var onConnectionStateChange: ((RTCIceConnectionState) -> Void)?

    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCIceConnectionState) {
        print("🔗 ICE Connection State: \(stateChanged)")
        onConnectionStateChange?(stateChanged)
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        print("📺 Stream added with \(stream.videoTracks.count) video tracks")
        if let videoTrack = stream.videoTracks.first {
            print("✅ Video track found in stream - enabled: \(videoTrack.isEnabled)")
            videoTrack.isEnabled = true
            onTrack?(videoTrack)
        } else {
            print("❌ No video tracks found in stream")
        }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd rtpReceiver: RTCRtpReceiver, streams: [RTCMediaStream]) {
        print("📡 RTP Receiver added - track kind: \(rtpReceiver.track?.kind ?? "unknown")")
        if let videoTrack = rtpReceiver.track as? RTCVideoTrack {
            print("✅ Video track found in RTP receiver - enabled: \(videoTrack.isEnabled)")
            videoTrack.isEnabled = true
            onTrack?(videoTrack)
        } else {
            print("❌ No video track in RTP receiver")
        }
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCSignalingState) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCIceGatheringState) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {}
}
