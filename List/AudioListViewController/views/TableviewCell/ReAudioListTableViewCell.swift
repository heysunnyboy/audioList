//
//  ReAudioListTableViewCell.swift
//  Recorder
//
//  Created by yebaojia on 16/3/15.
//  Copyright © 2016年 mjia. All rights reserved.
//

import UIKit

class ReAudioListTableViewCell: UITableViewCell {
    var audioDict : NSDictionary?
    let recorderTool = RecorderTool.getTool()
    var title = UILabel.init(frame: CGRectMake(78, 10, 100, 15))
    var detail = UILabel.init(frame: CGRectMake(78, 33, 200, 12))
    var timeStart = UILabel.init(frame: CGRectMake(78, 53, 50, 12))
    var endTime = UILabel.init()
    var timeScroolLine = UIView.init(frame: CGRectMake(125, 58, 0, 4))
    var scrollPoint = UIView.init(frame: CGRectMake(125, 57, 6, 6))
    var timer = NSTimer.init()
    var timeline = UIView.init()
    var aduioPath:String?
    var playBar = RePlayBar.init()
    @IBOutlet var playBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        let width = self.frame.size.width
        playBtn = UIButton.init(frame: CGRectMake(20, 14, 40, 40))
        self.addSubview(playBtn)
        playBtn.setImage(UIImage.init(named: "play"), forState: UIControlState.Normal)
        playBtn.setImage(UIImage.init(named: "resume"), forState: UIControlState.Selected)
        playBtn.userInteractionEnabled = false
        self.addSubview(title)
        //
        detail.font = UIFont.systemFontOfSize(12)
        detail.textColor = UIColor.lightGrayColor()
        self.addSubview(detail)
        playBar.frame =  CGRectMake(78, 53, width - 78, 12)
        playBar.setUI(CGRectMake(78, 53, width - 78, 12)
)
        self.addSubview(playBar)
       
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func getAudioDict(dict : [String:String])
    {
        audioDict = dict
        detail.text = dict["time"]! + " (" + dict["size"]! + "MB)"
        print(dict["second"])
        playBar.endTime.text = calTime( Float(dict["second"]!)!)
    }
       func startPlay()
    {
        playBtn.selected = true
        aduioPath = audioDict?.objectForKey("path") as? String
        recorderTool.playRecord(aduioPath!)


    }
    func stopPlay()
    {
        playBtn.selected = false
        //正在播放停止
        if recorderTool.player.playing
        {
        let aduioPath = audioDict?.objectForKey("path")
        recorderTool.stopPlayRecord(aduioPath as! String)
        }
        noPlay()
    }
    
    func noPlay(){
        playBtn.selected = false
        playBar.playProgress(0)
        playBar.timeStart.text = "00:00"
    }
    
    func calTime(second : Float) ->String{
        
        let hour = Int(second / 3600)
        print("hour is",hour)
        let minutes = Int(Int(second / 60) - hour*60)
        print("minute is ",minutes)
        let second = second % 60
        var minuteStr = ""
        var secondStr = ""
         if minutes < 10
        {
            minuteStr = "0" + String(format:"%d",minutes)
        }
        else
        {
            minuteStr = String(format:"%d",minutes)
        }
        if second < 10
        {
            secondStr = "0" + String(format:"%.0f",second)
        }
        else
        {
            secondStr =  String(format:"%.0f",second)
        }
        print("秒数 is  " + secondStr)
       return   minuteStr + "." + secondStr
    }

}
