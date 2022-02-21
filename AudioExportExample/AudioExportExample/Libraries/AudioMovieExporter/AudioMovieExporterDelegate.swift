//
//  AudioMovieExporterDelegate.swift
//  AudioExportExample
//
//  Created by Shawn Frank on 21/02/2022.
//

import Foundation

protocol AudioMovieExporterDelegate: class
{
    func audioMovieExporterDidStart(_ audioMovieExporter: AudioMovieExporter)
    
    func audioMovieExporter(_ audioMovieExporter: AudioMovieExporter,
                            didEncounterError error: AudioMovieExporterError)
    
    func audioMovieExporter(_ audioMovieExporter: AudioMovieExporter,
                            didExportMovieTo location: URL)
}

// MARK: DEFAULT IMPLEMENTATION TO MAKE SOME PROTOCOL IMPLEMENTATIONS OPTIONAL
extension AudioMovieExporterDelegate
{
    func audioMovieExporterDidStart(_ audioMovieExporter: AudioMovieExporter) { }
    
    func audioMovieExporter(_ audioMovieExporter: AudioMovieExporter,
                            didEncounterError error: AudioMovieExporterError) { }
}
