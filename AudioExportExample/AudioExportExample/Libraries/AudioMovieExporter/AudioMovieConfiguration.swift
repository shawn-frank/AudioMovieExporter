//
//  AudioMovieConfiguration.swift
//  AudioExportExample
//
//  Created by Shawn Frank on 21/02/2022.
//

import AVKit

enum ExportOrientation
{
    case landscape
    case portrait
}

struct AudioMovieConfiguration
{
    enum ExportFormat
    {
        case mov
        case mp4
    }
    
    var resolution: CGSize
    {
        get
        {
            if orientation == .landscape
            {
                return CGSize(width: 1920, height: 1080)
            }
            
            return CGSize(width: 1080, height: 1920)
        }
    }
    
    var videoAsset: AVAsset?
    {
        get
        {
            let blankMovieFileName = "blank_\(String(describing: orientation))"
            
            if let blankMoviePathURL = Bundle.main.url(forResource: blankMovieFileName,
                                                    withExtension: ".mp4")
            {
                return AVAsset(url: blankMoviePathURL)
            }
            
            return nil
        }
    }
    
    var avFileType: AVFileType
    {
        get
        {
            if exportFormat == .mov { return .mov }
            return .mp4
        }
    }
    
    var fps: Int32 = 25
    var orientation = ExportOrientation.landscape
    var color: CGColor?
    var exportFormat = ExportFormat.mov
}
