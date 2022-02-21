# AudioMovieExporter for iOS (Swift)
A lightweight Swift library that helps you coverts audio from your iOS apps into movie files which can then be saved to the Photos app, shared on social media or played in your apps.

The motivation for this small project was [this StackOverflow question](https://stackoverflow.com/a/71187603/1619193) which also has an great alternative solution.

# How does it work
AudioMovieExporter creates an `AVMutableComposition` which merges the audio track from the audio file provided with the video track from a blank video file that is part of this library. There are 2 blank, 1 second video files, one for landscape and one for portrait and have a combined size of 65KB.

# Configuration
AudioMovieExporter gives you a few export options which allows you to configure your movie's:

 - Background color (ignore this if you want a black background)
 - File format (.mov or .mp4)
 - Orientation (Landscape: 1920 x 1080 or Portrait: 1080 x 1920)

# Usage
```
func launchAudioExporter()
{
	var audioMovieExporter = AudioMovieExporter()
	audioExporter.delegate = self
	var exporterConfiguration = AudioMovieConfiguration()
	exporterConfiguration.orientation = .portrait
	exporterConfiguration.backgroundColor = UIColor.purple.cgColor
	audioMovieExporter.configuration = exporterConfiguration
	
	// Replace with your audio url
	if let audioURL = Bundle.main.url(forResource: "sample",
					  withExtension: ".m4a") 
	{ 
		// Start showing your loading UI
		DispatchQueue.global(qos: .background).async 
		{
			audioMovieExporter.generateMovie(with: audioURL) 
		}
	}
}

extension YourClass: AudioMovieExporterDelegate 
{ 
	func audioMovieExporter(_ audioMovieExporter: AudioMovieExporter, 
	                        didExportMovieTo location: URL) 
	{ 
		DispatchQueue.main.async 
		{ 
			// Dismiss loading UI
			// Do what you want with the video URL saved in the documents directory
		}
	}
}
```
