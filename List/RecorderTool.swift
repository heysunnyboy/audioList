//
//  RecorderTool.swift
//  Recorder
//
//  Created by yebaojia on 16/3/9.
//  Copyright © 2016年 mjia. All rights reserved.
//

import UIKit
import AVFoundation
class RecorderTool: NSObject {
    var recorder :AVAudioRecorder?
    var player: AVAudioPlayer!
    
    var recorderSeetingDic :[String : AnyObject]? //硬件设置
    var volumeTimer:NSTimer! //定时器线程，循环监测录音的音量大小
    var aacPath:String? //录音存储路径
    var audioArr:[[String:String]] = [[:]] //录音信息数组
    var seconds:Float = 0   //记录录音时间
    static let tool:RecorderTool = RecorderTool()
    override init() {
        super.init()
        
    }
    //单例
    class func getTool() -> RecorderTool
    {
        return tool
    }
    func startRecord(){
        let  session = AVAudioSession.sharedInstance();
        //设置录音类型
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.setActive(true);
        }catch
        {
            print("session 设置失败")
        }
        
        //获取Document目录
        let docDir: AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask, true)[0]
        //组合录音文件路径
        aacPath = (docDir as! String) + "/play1.aac"
        //初始化字典并添加设置参数
        recorderSeetingDic =
            [AVSampleRateKey : NSNumber(float: Float(44100.0)),//声音采样率
                AVFormatIDKey : NSNumber(int: Int32(kAudioFormatMPEG4AAC)),//编码格式
                AVNumberOfChannelsKey : NSNumber(int: 1),//采集音轨
                AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.Medium.rawValue))]//音频质量
        recorder =  try! AVAudioRecorder(URL: NSURL(string: aacPath!)!,
            settings: recorderSeetingDic!)
        
        //开启仪表计数功能
        recorder!.meteringEnabled = true
        //准备录音
        recorder!.prepareToRecord()
        //开始录音
        recorder!.record()
        //启动定时器，定时更新录音音量
        volumeTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self,
            selector: "levelTimer", userInfo: nil, repeats: true)
        //计时
        seconds = 0
    }
    func stopRecord(){
        
        recorder?.stop()
        //录音器释放
        recorder = nil
        
        //暂停定时器
        volumeTimer.invalidate()
        volumeTimer = nil
    }
    func playRecord(aduioPath:String){
        
        do {
            let session = AVAudioSession.sharedInstance();
            try session.setCategory(AVAudioSessionCategoryPlayback)
            try session.setActive(true);
            let url = NSURL(string: aduioPath);
            player = try AVAudioPlayer(contentsOfURL: url!)//(contentsOfURL: NSURL(string: aacPath!))
            
        }
        catch
        {
            print("播放失败")
        }
        if player == nil {
            print("播放失败")
        }else{
            player.prepareToPlay()
            player.play()
        }
    }
    func stopPlayRecord(aduioPath:String)
    {
        do {
            player = try AVAudioPlayer(contentsOfURL: NSURL(string: aduioPath)!)//(contentsOfURL: NSURL(string: aacPath!))
        }
        catch
        {
            print("播放失败")
        }
        if player == nil {
            print("播放失败")
        }else{
            player.stop()
        }
        
    }
    //保存文件
    func saveRecord(){
        let docDir: AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask, true)[0]
        //组合录音文件路径
        //
        let date : NSDate = NSDate()
        let timeInterval =  date.timeIntervalSince1970*1000
        let timeStr = String(format:"%f",timeInterval)
        let saveAacPath = (docDir as! String) + "/audio/" + timeStr + ".aac"
        //
        let fileManager = NSFileManager.defaultManager()
        //创建另存为路径
        let isDirExist = fileManager.fileExistsAtPath((docDir as! String) + "/audio")
        if !isDirExist{
            do
            {
                try fileManager.createDirectoryAtPath((docDir as! String) + "/audio", withIntermediateDirectories: true, attributes: nil)
            }
            catch
            {
                
            }
        }
        
        if fileManager.fileExistsAtPath(aacPath!)
        {
            
            do
            {
                try fileManager.copyItemAtPath(aacPath!, toPath: saveAacPath)
                let userDefault:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                var audioDict = [String:String]()
                var arr = [[String :String]]()
              
                if let a = userDefault.objectForKey("audio")
                {
                    arr = a as! [[String : String]]
                }
                do{
                    let dict = try fileManager.attributesOfItemAtPath(saveAacPath)
                    let fileSize = dict["NSFileSize"] as! CGFloat
                    audioDict = ["path" : saveAacPath,"second":String(seconds/10),"size":String(format: "%.2f",fileSize/(1024.0*1024.0)),"time":getTodayTime()]
                }
                catch
                {
                    audioDict = ["path" : saveAacPath,"second":String(seconds/10),"size":"0","time":getTodayTime()]
                    
                }
                
                arr += [audioDict]
                print("arr is %@",arr)
                userDefault.setObject(arr, forKey: "audio")
                userDefault.synchronize()
                
            }
            catch
            {
                print("复制失败")
            }
            
        }
    }
    // delete record
    func deleteRecord(filePath : String ){
        //删除配置
        
        let fileManager = NSFileManager.defaultManager()
        
        do
        {
            try fileManager.removeItemAtPath(filePath)
        }
        catch
        {
            
        }
        
        
    }
    //定时检测录音音量
    func levelTimer(){
        recorder!.updateMeters() // 刷新音量数据
        seconds++
        
    }
    //获取时间
    func getTodayTime() ->String{
        let curDate = NSDate()
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd"
        return timeFormatter.stringFromDate(curDate)
    }
    
}
