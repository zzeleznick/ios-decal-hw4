//
//  PlayerViewController.swift
//  Play
//
//  Created by Gene Yoo on 11/26/15.
//  Copyright © 2015 cs198-1. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    var tracks: [Track]!
    var scAPI: SoundCloudAPI!
    
    var priorIndex: Int!
    var currentIndex: Int! {
        willSet {
            if let idx = currentIndex {
                priorIndex = idx
            }
            else {
                print("Initializing")
                priorIndex = 0
            }
        }
        didSet {
            print("Track \(priorIndex+1) -> \(currentIndex+1)")
            loadTrackElements()
        }
    }
    var isPlaying: Bool = false
    var player: AVPlayer!
    var trackImageView: UIImageView!
    
    var playPauseButton: UIButton!
    var nextButton: UIButton!
    var previousButton: UIButton!
    
    var artistLabel: UILabel!
    var titleLabel: UILabel!
    
    var trackIndexLabel: UILabel!
    var maxTrackIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = UIView(frame: UIScreen.mainScreen().bounds)
        view.backgroundColor = UIColor.whiteColor()

        scAPI = SoundCloudAPI()
        scAPI.loadTracks(didLoadTracks)
        
        // MARK - Set Current Index
        currentIndex = 0
        
        player = AVPlayer()
        
        loadVisualElements()
        loadPlayerButtons()
    }
    
    func loadVisualElements() {
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        let offset = height - width
        
    
        trackImageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0,
            width: width, height: width))
        trackImageView.contentMode = UIViewContentMode.ScaleAspectFill
        trackImageView.clipsToBounds = true
        view.addSubview(trackImageView)
        
        titleLabel = UILabel(frame: CGRect(x: 0.0, y: width + offset * 0.15,
            width: width, height: 20.0))
        titleLabel.textAlignment = NSTextAlignment.Center
        view.addSubview(titleLabel)

        artistLabel = UILabel(frame: CGRect(x: 0.0, y: width + offset * 0.25,
            width: width, height: 20.0))
        artistLabel.textAlignment = NSTextAlignment.Center
        artistLabel.textColor = UIColor.grayColor()
        view.addSubview(artistLabel)
        
        trackIndexLabel = UILabel(frame: CGRect(x: 0.0, y: width + offset * 0.35,
            width: width, height: 20.0))
        trackIndexLabel.textAlignment = NSTextAlignment.Center
        trackIndexLabel.textColor = UIColor.grayColor()
        view.addSubview(trackIndexLabel)
        
    }
    
    
    func loadPlayerButtons() {
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        let offset = height - width
    
        let playImage = UIImage(named: "play")?.imageWithRenderingMode(.AlwaysTemplate)
        let pauseImage = UIImage(named: "pause")?.imageWithRenderingMode(.AlwaysTemplate)
        let nextImage = UIImage(named: "next")?.imageWithRenderingMode(.AlwaysTemplate)
        let previousImage = UIImage(named: "previous")?.imageWithRenderingMode(.AlwaysTemplate)
        
        playPauseButton = UIButton(type: UIButtonType.Custom)
        playPauseButton.frame = CGRectMake(width / 2.0 - width / 30.0,
                                           width + offset * 0.5,
                                           width / 15.0,
                                           width / 15.0)
        playPauseButton.setImage(playImage, forState: UIControlState.Normal)
        playPauseButton.setImage(pauseImage, forState: UIControlState.Selected)
        playPauseButton.addTarget(self, action: "playOrPauseTrack:",
            forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(playPauseButton)
        
        previousButton = UIButton(type: UIButtonType.Custom)
        previousButton.frame = CGRectMake(width / 2.0 - width / 30.0 - width / 5.0,
                                          width + offset * 0.5,
                                          width / 15.0,
                                          width / 15.0)
        previousButton.setImage(previousImage, forState: UIControlState.Normal)
        previousButton.addTarget(self, action: "previousTrackTapped:",
            forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(previousButton)

        nextButton = UIButton(type: UIButtonType.Custom)
        nextButton.frame = CGRectMake(width / 2.0 - width / 30.0 + width / 5.0,
                                      width + offset * 0.5,
                                      width / 15.0,
                                      width / 15.0)
        nextButton.setImage(nextImage, forState: UIControlState.Normal)
        nextButton.addTarget(self, action: "nextTrackTapped:",
            forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(nextButton)

    }

    
    func loadTrackElements() {
        if let track = tracks?[currentIndex] {
            asyncLoadTrackImage(track)
            titleLabel.text = track.title
            artistLabel.text = track.artist
            trackIndexLabel.text = "\(currentIndex+1) of \(maxTrackIndex)"
        }
        
    }
    
    // This Method updates the music track with currentIndex
    func updateTrack() {
        let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist")
        let clientID = NSDictionary(contentsOfFile: path!)?.valueForKey("client_id") as! String
        let track = tracks[currentIndex]
        let url = NSURL(string: "https://api.soundcloud.com/tracks/\(track.id)/stream?client_id=\(clientID)")!
        let song = AVPlayerItem(URL: url)
        player.replaceCurrentItemWithPlayerItem(song)
    }
    
    /* 
     *  This Method should play or pause the song, depending on the song's state
     *  It should also toggle between the play and pause images by toggling
     *  sender.selected
     * 
     *  If you are playing the song for the first time, you should be creating 
     *  an AVPlayerItem from a url and updating the player's currentitem 
     *  property accordingly.
     */
    func playOrPauseTrack(sender: UIButton) {
        
        updateTrack()
        // if player.currentItem!.status == .ReadyToPlay { }
        
        if self.isPlaying == false {
            player.play()
            sender.selected = true
            self.isPlaying = true
        }
        else {
            player.pause()
            sender.selected = false
            self.isPlaying = false
        }


    }
    
    /* 
     * Called when the next button is tapped. It should check if there is a next
     * track, and if so it will load the next track's data and
     * automatically play the song if a song is already playing
     * Remember to update the currentIndex
     */
    func nextTrackTapped(sender: UIButton) {
        if currentIndex < tracks.count - 1{
            currentIndex = currentIndex + 1
        }
        updateTrack()
        if self.isPlaying == true {
            player.play()
            sender.selected = true
        }
        else {
            // pass
        }
    }

    /*
     * Called when the previous button is tapped. It should behave in 2 possible
     * ways:
     *    a) If a song is more than 3 seconds in, seek to the beginning (time 0)
     *    b) Otherwise, check if there is a previous track, and if so it will 
     *       load the previous track's data and automatically play the song if
     *      a song is already playing
     *  Remember to update the currentIndex if necessary
     */

    func previousTrackTapped(sender: UIButton) {
        let elapsed = player.currentTime().seconds
        if elapsed > 3 {
            print("Starting from beginning")
            player.seekToTime(CMTimeMakeWithSeconds(3, 1))
        }
        else {
            currentIndex = max(0, currentIndex - 1)
        }
        // let elapsed
    }
    
    
    func asyncLoadTrackImage(track: Track) {
        let url = NSURL(string: track.artworkURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if error == nil {
                let image = UIImage(data: data!)
                let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                dispatch_async(dispatch_get_global_queue(priority, 0)) {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.trackImageView.image = image
                    }
                }
            }
        }
        task.resume()
    }
    
    func didLoadTracks(tracks: [Track]) {
        self.tracks = tracks
        self.maxTrackIndex = self.tracks.count
        loadTrackElements()
        player = AVPlayer()

    }
}

