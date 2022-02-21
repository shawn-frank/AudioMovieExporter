//
//  AudioMovieExporter.swift
//  AudioExportExample
//
//  Created by Shawn Frank on 20/02/2022.
//

import AVKit

struct AudioMovieExporter
{
    var configuration = AudioMovieConfiguration()
    
    weak var delegate: AudioMovieExporterDelegate?
    
    init() { }
    
    // MARK: FACTORY
    func generateMovie(with audioURL: URL)
    {
        delegate?.audioMovieExporterDidStart(self)
        
        let composition = AVMutableComposition()
        
        // Configure the audio and video tracks in the new composition
        guard let _ = configureAudioTrack(audioURL, inComposition: composition),
              let videoCompositionTrack = configureVideoTrack(inComposition: composition)
        else
        {
            return
        }
        
        let videoComposition = createVideoComposition(with: videoCompositionTrack)
        
        if let exporter = configureAVAssetExportSession(with: composition,
                                                        videoComposition: videoComposition)
        {
            exporter.exportAsynchronously
            {
                switch exporter.status {
                    
                    case .completed:
                        guard let videoURL = exporter.outputURL
                        else
                        {
                            manageError(nil, withMessage: "Error saving movie to disk")
                            return
                        }
                        
                        delegate?.audioMovieExporter(self, didExportMovieTo: videoURL)
                        
                    default:
                        manageError(exporter.error, withMessage: "Error saving movie to disk")
                }
            }
        }
    }
    
    private func configureAudioTrack(_ audioURL: URL,
                                     inComposition composition: AVMutableComposition) -> AVMutableCompositionTrack?
    {
        let audioAsset: AVURLAsset = AVURLAsset(url: audioURL)
        
        let trackTimeRange = CMTimeRange(start: .zero,
                                         duration: audioAsset.duration)
        
        // Get the audio track from the audio asset
        guard let sourceAudioTrack = audioAsset.tracks(withMediaType: .audio).first
        else
        {
            manageError(nil, withMessage: "Error retrieving audio track from source file")
            return nil
        }
        
        // Insert a new video track to the AVMutableComposition
        guard let audioTrack = composition.addMutableTrack(withMediaType: .audio,
                                                           preferredTrackID: CMPersistentTrackID())
        else
        {
            manageError(nil, withMessage: "Error creating new audio track")
            return nil
        }
        
        do {
            // Inset the contents of the audio source into the new audio track
            try audioTrack.insertTimeRange(trackTimeRange,
                                           of: sourceAudioTrack,
                                           at: .zero)
        }
        catch {
            manageError(error, withMessage: "Error initializing video time range")
        }
        
        return audioTrack
    }
    
    private func configureVideoTrack(inComposition composition: AVMutableComposition) -> AVMutableCompositionTrack?
    {
        // Initialize a video asset with the empty video file
        guard let videoAsset = configuration.videoAsset
        else
        {
            manageError(nil, withMessage: "Unable to initialize empty movie")
            return nil
        }
        
        // Get the video track from the empty video
        guard let sourceVideoTrack = videoAsset.tracks(withMediaType: .video).first
        else
        {
            manageError(nil, withMessage: "Error retrieving video track")
            return nil
        }
        
        // Insert a new video track to the AVMutableComposition
        guard let videoTrack = composition.addMutableTrack(withMediaType: .video,
                                                           preferredTrackID: kCMPersistentTrackID_Invalid)
        else
        {
            manageError(nil, withMessage: "Error creating new video track")
            return nil
        }
        
        let trackTimeRange = CMTimeRange(start: .zero,
                                         duration: composition.duration)
        
        do {
            
            // Inset the contents of the video source into the new audio track
            try videoTrack.insertTimeRange(trackTimeRange,
                                           of: sourceVideoTrack,
                                           at: .zero)
            
        }
        catch {
            manageError(error, withMessage: "Error initializing video time range")
        }
        
        return videoTrack
    }
    
    // Configure the video properties like resolution and fps
    private func createVideoComposition(with videoCompositionTrack: AVMutableCompositionTrack) -> AVMutableVideoComposition
    {
        let videoComposition = AVMutableVideoComposition()
        
        // Set the fps
        videoComposition.frameDuration = CMTime(value: 1,
                                                timescale: configuration.fps)
        
        // Video dimensions
        videoComposition.renderSize = configuration.resolution
        
        // Specify the duration of the video composition
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: .indefinite)
        
        // Add background color if required
        videoComposition.animationTool = generateCABackgroundLayerTool()
        
        // Add the video composition track to a new layer
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
        let transform = videoCompositionTrack.preferredTransform
        layerInstruction.setTransform(transform, at: .zero)
        
        // Apply the layer configuration instructions
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        return videoComposition
    }
    
    
    private func generateCABackgroundLayerTool() -> AVVideoCompositionCoreAnimationTool?
    {
        if let backgroundColor = configuration.backgroundColor
        {
            // No problem if the video layer cannot be seen
            let videoLayer = CALayer()
            videoLayer.frame = CGRect.zero
            
            let outputLayer = CALayer()
            outputLayer.backgroundColor = backgroundColor
            outputLayer.frame = CGRect(origin: .zero, size: configuration.resolution)
            outputLayer.addSublayer(videoLayer)
            
            return AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer,
                                                       in: outputLayer)
        }
        
        return nil
    }
    
    private func configureAVAssetExportSession(with composition: AVMutableComposition,
                                               videoComposition: AVMutableVideoComposition) -> AVAssetExportSession?
    {
        // Configure export session
        guard let exporter = AVAssetExportSession(asset: composition,
                                                  presetName: AVAssetExportPresetHighestQuality)
        else
        {
            let exportQuality = String(describing: configuration.exportFormat)
            let errorMessage = "Error \(exportQuality) preparing quality export"
            manageError(nil, withMessage: errorMessage)
            return nil
        }
        
        // Configure where the exported file will be stored
        let documentsURL = FileManager.default.urls(for: .documentDirectory,
                                                    in: .userDomainMask)[0]
        
        let fileName = "\(UUID().uuidString).\(String(describing: configuration.exportFormat))"
        let dirPath = documentsURL.appendingPathComponent(fileName)
        let outputFileURL = dirPath
        
        // Apply exporter settings
        exporter.videoComposition = videoComposition
        exporter.outputFileType = configuration.avFileType
        exporter.outputURL = outputFileURL
        exporter.shouldOptimizeForNetworkUse = true
        
        return exporter
    }
    
    private func manageError(_ error: Error?,
                             withMessage message: String)
    {
        delegate?.audioMovieExporter(self,
                                     didEncounterError: AudioMovieExporterError(message: message,
                                                                                error: nil))
    }
}
