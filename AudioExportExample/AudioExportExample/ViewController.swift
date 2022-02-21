//
//  ViewController.swift
//  AudioExportExample
//
//  Created by Shawn Frank on 20/02/2022.
//

import UIKit
import Photos
import AVKit

class ViewController: UIViewController
{
    private let exportAudioButton = UIButton(type: .system)
    private let exportAudioEnhancedButton = UIButton(type: .system)
    var audioMovieExporter = AudioMovieExporter()
    
    private var moviePath: URL?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Audio movie export"
        layoutButtons()
        audioMovieExporter.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        requestPhotosPermissionsIfRequired()
    }
    
    private func playMovie()
    {
        if let moviePath = moviePath
        {
            let playerViewController = AVPlayerViewController()
            
            let player = AVPlayer(url: moviePath)
            
            playerViewController.player = player
            
            present(playerViewController, animated: true) {
                player.play()
            }
        }
    }
    
    private func presentSaveOptions()
    {
        let ac = UIAlertController(title: "What next?", message: nil, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Play movie",
                                       style: .default)
        { [weak self] _ in
            self?.playMovie()
        }
        
        let savePlayAction = UIAlertAction(title: "Save and Play",
                                           style: .default)
        { [weak self] action in
            
            self?.saveMovieToPhotos()
            self?.playMovie()
        }
        
        ac.addAction(saveAction)
        ac.addAction(savePlayAction)
        
        self.present(ac,
                     animated: true,
                     completion: nil)
    }
    
    // MARK: INTENTS
    @objc
    private func didTapExportButton()
    {
        if let audioURL = Bundle.main.url(forResource: "sample",
                                          withExtension: ".m4a")
        {
            let euxLoader = EUXLoader(withTitle: "Render in progress")
            present(euxLoader.loaderController, animated: true)
            {
                // Generate the movie on a background thread to free up
                // the UI in case of high quality exports
                DispatchQueue.global(qos: .background).async
                { [weak self] in
                    self?.audioMovieExporter.generateMovie(with: audioURL)
                }
            }
        }
    }
    
    @objc
    private func didTapEnhancedExportButton()
    {
        print("enh")
    }
}

extension ViewController: AudioMovieExporterDelegate
{
    func audioMovieExporter(_ audioMovieExporter: AudioMovieExporter,
                            didExportMovieTo location: URL)
    {
        DispatchQueue.main.async
        {
            self.dismiss(animated: true)
            { [weak self] in
                
                self?.moviePath = location
                self?.presentSaveOptions()
            }
        }
    }
}

// MARK: INTERFACE & AUTOLAYOUT
extension ViewController
{
    private func layoutButtons()
    {
        layoutExportButton()
        layoutExportEnhancedButton()
    }
    
    private func layoutExportButton()
    {
        exportAudioButton.translatesAutoresizingMaskIntoConstraints = false
        exportAudioButton.setTitle("Export Audio with No (Black) BG Movie", for: .normal)
        exportAudioButton.setTitleColor(.systemBlue, for: .normal)
        exportAudioButton.addTarget(self,
                                    action: #selector(didTapExportButton),
                                    for: .touchUpInside)
        view.addSubview(exportAudioButton)
        
        exportAudioButton.leadingAnchor
            .constraint(equalTo: view.leadingAnchor,
                        constant: 20).isActive = true
        
        exportAudioButton.bottomAnchor
            .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                        constant: -20).isActive = true
        
        exportAudioButton.trailingAnchor
            .constraint(equalTo: view.trailingAnchor,
                        constant: -20).isActive = true
        
        exportAudioButton.heightAnchor
            .constraint(equalToConstant: 50).isActive = true
    }
    
    private func layoutExportEnhancedButton()
    {
        exportAudioEnhancedButton.translatesAutoresizingMaskIntoConstraints = false
        exportAudioEnhancedButton.setTitle("Export Audio as Movie with BG Color", for: .normal)
        exportAudioEnhancedButton.setTitleColor(.systemBlue, for: .normal)
        exportAudioEnhancedButton.addTarget(self,
                                            action: #selector(didTapEnhancedExportButton),
                                            for: .touchUpInside)
        view.addSubview(exportAudioEnhancedButton)
        
        exportAudioEnhancedButton.leadingAnchor
            .constraint(equalTo: view.leadingAnchor,
                        constant: 20).isActive = true
        
        exportAudioEnhancedButton.bottomAnchor
            .constraint(equalTo: exportAudioButton.topAnchor,
                        constant: -20).isActive = true
        
        exportAudioEnhancedButton.trailingAnchor
            .constraint(equalTo: view.trailingAnchor,
                        constant: -20).isActive = true
        
        exportAudioEnhancedButton.heightAnchor
            .constraint(equalToConstant: 50).isActive = true
    }
}

// MARK: PHOTOS
extension ViewController
{
    private func requestPhotosPermissionsIfRequired()
    {
        // Request access to PhotosApp
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            
            // Handle restricted or denied state
            if status == .restricted || status == .denied
            {
                print("Status: Restricted or Denied")
            }
            
            // Handle limited state
            if status == .limited
            {
                print("Status: Limited")
            }
            
            // Handle authorized state
            if status == .authorized
            {
                print("Status: Full access")
            }
        }
    }
    
    private func saveMovieToPhotos()
    {
        if let moviePath = moviePath
        {
            // Handle no photos authorization better
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else { return }
                
                PHPhotoLibrary.shared().performChanges({
                    let request = PHAssetCreationRequest.forAsset()
                    request.addResource(with: .video, fileURL: moviePath, options: nil)
                })
                { (result, error) in
                    
                    DispatchQueue.main.async
                    {
                        if let error = error
                        {
                            // handle errors in saving
                            print(error.localizedDescription)
                        }
                        else
                        {
                            print("Saved successfully to photos")
                        }
                    }
                }
                
            }
        }
    }
}

