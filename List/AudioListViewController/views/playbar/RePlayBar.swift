//
//  RePlayBar.swift
//  Recorder
//
//  Created by yebaojia on 16/3/23.
//  Copyright (c) 2016年 mjia. All rights reserved.
//

import UIKit

class RePlayBar: UIView {
    var timeStart = UILabel.init(frame: CGRectMake(0, 0, 50, 12))
    var endTime = UILabel.init()
    var timeScroolLine = UIView.init(frame: CGRectMake(47, 5, 0, 4))
    var scrollPoint = UIView.init(frame: CGRectMake(47, 4, 6, 6))
    var timeline = UIView.init()
    var scrollTime : Float = 0.0
     var audioDict : NSDictionary?
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        super.init(frame : frame)
       
    }
    func setUI(frame: CGRect){
        timeStart.text = "00:00"
        timeStart.textColor = UIColor.lightGrayColor()
        timeScroolLine.backgroundColor = UIColor.blackColor()
        timeScroolLine.layer.cornerRadius = 4
        self.addSubview(timeScroolLine)
        //
        
        //
        self.addSubview(timeStart)
        //
        let selfwidth = frame.size.width
        timeline.frame = CGRectMake(47, 5, selfwidth-100, 4)
        timeline.layer.cornerRadius = 4
        timeline.backgroundColor = UIColor.lightGrayColor()
        self.addSubview(timeline)
        //
        endTime.frame = CGRectMake(selfwidth - 50, 0, 50, 12)
        endTime.textColor = UIColor.lightGrayColor()
        self.addSubview(endTime)
        //
        scrollPoint.layer.cornerRadius = 3
        scrollPoint.backgroundColor = UIColor.redColor()
        self.addSubview(scrollPoint)

    }
    func playProgress(let p :CGFloat){
        let width = timeline.frame.size.width
        let a = CGFloat(47) + p*width
        scrollPoint.frame = CGRectMake(a, 4, 6, 6)
//        timeStart.text = calTime(scrollTime)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func calTime(second : Int) ->String{
        
        let hour = second / 3600
        let minutes = second / 60 - hour*60

        let second = Int(second % 60)
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
            secondStr = "0" + String(format:"%d",second)
        }
        else
        {
            secondStr =  String(format:"%d",second)
        }
        return   minuteStr + "." + secondStr
    }

}
