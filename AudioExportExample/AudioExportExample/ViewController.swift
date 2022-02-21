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
    private var exportTypeSegmentControl: UISegmentedControl!
    private var videoOrientationSegmentControl: UISegmentedControl!
    private var videoBGColorSegmentControl: UISegmentedControl!
    private let exportAudioButton = UIButton(type: .system)
    private let colors: [UIColor] = [.red, .blue, .purple]
    private var segmentLabelColorQueue: [UIColor] = [.red, .blue, .purple]
    private var isLayoutConfigured = false
    
    var audioMovieExporter = AudioMovieExporter()
    var exporterConfiguration = AudioMovieConfiguration()
    
    private var moviePath: URL?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        layoutInterface()
        audioMovieExporter.delegate = self
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        if !isLayoutConfigured
        {
            updateSegmentTextColor(videoBGColorSegmentControl)
            videoBGColorSegmentControl.selectedSegmentIndex = 0
            isLayoutConfigured = true
            
        }
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
    
    private func reset()
    {
        exporterConfiguration.backgroundColor = nil
        exporterConfiguration.orientation = .landscape
        
        videoOrientationSegmentControl.isHidden = true
        videoOrientationSegmentControl.selectedSegmentIndex = 0
        
        videoBGColorSegmentControl.isHidden = true
        videoBGColorSegmentControl.selectedSegmentIndex = 0
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
            audioMovieExporter.configuration = exporterConfiguration
            
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
    private func didUpdateVideoType(_ segmentControl: UISegmentedControl)
    {
        if segmentControl.selectedSegmentIndex == 1
        {
            videoOrientationSegmentControl.isHidden = false
            videoBGColorSegmentControl.isHidden = false
            return
        }
        
        reset()
    }
    
    @objc
    private func didUpdateVideoOrientation(_ segmentControl: UISegmentedControl)
    {
        if segmentControl.selectedSegmentIndex == 0
        {
            exporterConfiguration.orientation = .landscape
            return
        }
        
        exporterConfiguration.orientation = .portrait
    }
    
    @objc
    private func didUpdateVideoBGColor(_ segmentControl: UISegmentedControl)
    {
        exporterConfiguration.backgroundColor
            = colors[segmentControl.selectedSegmentIndex].cgColor
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
    private func layoutInterface()
    {
        view.backgroundColor = .white
        title = "Audio movie export"
        
        layoutExportTypeSegment()
        layoutVideoOrientationSegment()
        layoutVideoBGColorSegment()
        layoutVideoBGColorSegment()
        layoutExportButton()
    }
    
    private func layoutExportButton()
    {
        exportAudioButton.translatesAutoresizingMaskIntoConstraints = false
        exportAudioButton.setTitle("Export Audio as Movie", for: .normal)
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
    
    private func layoutExportTypeSegment()
    {
        exportTypeSegmentControl = UISegmentedControl(items: ["Standard Video", "Enhanced Video"])
        exportTypeSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        exportTypeSegmentControl.selectedSegmentIndex = 0
        exportTypeSegmentControl.addTarget(self,
                                           action: #selector(didUpdateVideoType(_:)),
                                           for: .valueChanged)
        
        view.addSubview(exportTypeSegmentControl)
        
        exportTypeSegmentControl.leadingAnchor
            .constraint(equalTo: view.leadingAnchor,
                        constant: 20).isActive = true
        
        exportTypeSegmentControl.topAnchor
            .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                        constant: 20).isActive = true
        
        exportTypeSegmentControl.trailingAnchor
            .constraint(equalTo: view.trailingAnchor,
                        constant: -20).isActive = true
        
        exportTypeSegmentControl.heightAnchor
            .constraint(equalToConstant: 50).isActive = true
    }
    
    private func layoutVideoOrientationSegment()
    {
        videoOrientationSegmentControl = UISegmentedControl(items: ["Landscape", "Portrait"])
        videoOrientationSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        videoOrientationSegmentControl.selectedSegmentIndex = 0
        videoOrientationSegmentControl.isHidden = true
        videoOrientationSegmentControl.addTarget(self,
                                           action: #selector(didUpdateVideoOrientation(_:)),
                                           for: .valueChanged)
        
        view.addSubview(videoOrientationSegmentControl)
        
        videoOrientationSegmentControl.leadingAnchor
            .constraint(equalTo: view.leadingAnchor,
                        constant: 20).isActive = true
        
        videoOrientationSegmentControl.topAnchor
            .constraint(equalTo: exportTypeSegmentControl.bottomAnchor,
                        constant: 20).isActive = true
        
        videoOrientationSegmentControl.trailingAnchor
            .constraint(equalTo: view.trailingAnchor,
                        constant: -20).isActive = true
        
        videoOrientationSegmentControl.heightAnchor
            .constraint(equalToConstant: 50).isActive = true
    }
    
    private func layoutVideoBGColorSegment()
    {
        videoBGColorSegmentControl = UISegmentedControl(items: ["Red", "Blue", "Purple"])
        videoBGColorSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        videoBGColorSegmentControl.isHidden = true
        videoBGColorSegmentControl.addTarget(self,
                                           action: #selector(didUpdateVideoBGColor(_:)),
                                           for: .valueChanged)
        
        view.addSubview(videoBGColorSegmentControl)
        
        videoBGColorSegmentControl.leadingAnchor
            .constraint(equalTo: view.leadingAnchor,
                        constant: 20).isActive = true
        
        videoBGColorSegmentControl.topAnchor
            .constraint(equalTo: videoOrientationSegmentControl.bottomAnchor,
                        constant: 20).isActive = true
        
        videoBGColorSegmentControl.trailingAnchor
            .constraint(equalTo: view.trailingAnchor,
                        constant: -20).isActive = true
        
        videoBGColorSegmentControl.heightAnchor
            .constraint(equalToConstant: 50).isActive = true
    }
    
    private func updateSegmentTextColor(_ rootView: UIView)
    {
        for subview in rootView.subviews
        {
            if let label = subview as? UILabel,
               !segmentLabelColorQueue.isEmpty
            {
                let color = segmentLabelColorQueue.removeFirst()
                label.textColor = color
            }
            
            updateSegmentTextColor(subview)
        }
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

