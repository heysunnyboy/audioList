//
//  ReAudioListViewController.swift
//  Recorder
//
//  Created by yebaojia on 16/3/15.
//  Copyright © 2016年 mjia. All rights reserved.
//

import UIKit

class ReAudioListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet  var tableView1: UITableView!
    var timeTick:NSTimer!
    var curIndex:NSIndexPath =  NSIndexPath.init()  //当前选中的索引
    var isfirst = true   //判断是否第一次加载列表（） 这次没有上次选中的索引 和当前选中的索引
    var isPlay = false   //是否正在播放
    var curCell:ReAudioListTableViewCell?
    var playProgress:Float = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "储存夹"
        //view 初始化
        let height = UIScreen.mainScreen().bounds.size.height
        let width = UIScreen.mainScreen().bounds.size.width
        tableView1 = UITableView.init(frame: CGRectMake(0, 64, width, height - 64))
        self.view.addSubview(tableView1)
        tableView1.registerNib(UINib.init(nibName: "ReAudioListTableViewCell", bundle:nil ), forCellReuseIdentifier: "cell")
        tableView1.delegate = self
        tableView1.dataSource = self
        tableView1.tableFooterView = UIView.init()
        self.automaticallyAdjustsScrollViewInsets = false
        //value
        // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //value
    //delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCellWithIdentifier("cell") as! ReAudioListTableViewCell
        //记录下来判断是否为可见cell
        cell.tag = indexPath.row
        
        //加载本地音乐
        let path:String = NSBundle.mainBundle().pathForResource("lj", ofType:"mp3")!
        let dict  = ["path" : path , "time":"64.0" , "size":"1.8" ,"second":"64.0"]
        
        cell.getAudioDict(dict)
        
        cell.title.text = "录音" + String(indexPath.row+1) + ".aac"
        if isfirst
        {
            //第一次加载默认不播放状态
            cell.noPlay()
        }
        else
        {
            //当前点击的索引
            if indexPath.row == curIndex.row
            {
                //如果播放设置为播放的状态
                if isPlay == true
                {
                    cell.playBtn.selected = true
                    cell.playBar.playProgress(CGFloat(playProgress))
                }
                    //如果没有播放显示未播放状态
                else
                {
                    cell.noPlay()
                }
            }
                //不是当前点击说明没有播放
            else{
                cell.noPlay()
            }
            
        }
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 69
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ReAudioListTableViewCell
        //如果首次播放 curIndex 没有赋值 ，需要特殊处理一下
        if isfirst
        {
            //记录当前选中索引
            //已非第一次选中
            isfirst = false
            //运行定时器
            timeTick = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "playingAction", userInfo: nil, repeats: true)
//            NSRunLoop.currentRunLoop().addTimer(timeTick, forMode: NSRunLoopCommonModes)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            cell.startPlay()
           //////////////////////////////////注意
           ////////////curIndex = indexPath 需要写在timeTick.fire() 之前，因为fire() 会让定时器先跑完一次方法，才会执行下面的代码，由于这个curIndex 赋值在定时器方法用到，所以需要先赋值，如果想改变可以将定时器放入队列中
            
            curIndex = indexPath
            timeTick.fire()
        }
        else
        {
            //如果上次选中和当前选中索引相同，说明用户再次点击正在播放的cell，希望音乐暂停
            if(curIndex.row == indexPath.row)
            {
                //如果正在播放
                
                if isPlay == true
                {
                    isPlay = false
                    cell.stopPlay()
                    timeTick.invalidate()
                    
                }
                else
                {
                    cell.startPlay()
                    isPlay = true
                    timeTick = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "playingAction", userInfo: nil, repeats: true)
                    NSRunLoop.currentRunLoop().addTimer(timeTick, forMode: NSRunLoopCommonModes)
                    tableView.deselectRowAtIndexPath(indexPath, animated: true)
                    cell.playBtn.selected = true
                    
                    timeTick.fire()
                    curIndex = indexPath
                }
            }
                //点击一个新的cell播放
            else
            {
                //////////////////////////////////注意
                ////////////需要判断lastcell 是否为空，如果lastcell 不可见可能会为空
                if let lastcell : ReAudioListTableViewCell = tableView1.cellForRowAtIndexPath(curIndex) as? ReAudioListTableViewCell {
                    lastcell.stopPlay()
                }
                
                if RecorderTool.getTool().player.playing {
                    RecorderTool.getTool().player.stop()
                }
                
                
                //当前cell 开始播放
                cell.startPlay()
                isPlay = true
                //设置定时器
                timeTick = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "playingAction", userInfo: nil, repeats: true)
                NSRunLoop.currentRunLoop().addTimer(timeTick, forMode: NSRunLoopCommonModes)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                curIndex = indexPath
                timeTick.fire()
                
            }
            
         }
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    func playingAction()
    {
        let recordTool = RecorderTool.getTool()
            isPlay = true
            if let audioplayer = recordTool.player {
                //
                //修改上次选中cell的播放状态
                let tt = Float(audioplayer.currentTime) //播放器播放时间
                playProgress = tt / 65.0 //本地歌曲（63秒）
                if audioplayer.playing
                {
                if   let cell : ReAudioListTableViewCell = tableView1.cellForRowAtIndexPath(curIndex) as? ReAudioListTableViewCell{
                   
                    cell.playBar.playProgress(CGFloat(playProgress))
                    cell.playBar.timeStart.text = cell.playBar.calTime(Int(tt))
                }
                }
                else
                {
                    if   let cell : ReAudioListTableViewCell = tableView1.cellForRowAtIndexPath(curIndex) as? ReAudioListTableViewCell
                    {
                        cell.noPlay()
                    }
                    isPlay = false
                    timeTick.invalidate()
               }
            }
                //播放器停止播放
    }
   
    
        
}
