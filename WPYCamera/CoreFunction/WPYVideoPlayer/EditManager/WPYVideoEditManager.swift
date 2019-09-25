//
//  WPYVideoEditManager.swift
//  WPYCamera
//
//  Created by 王鹏宇 on 1/21/19.
//  Copyright © 2019 王鹏宇. All rights reserved.


import UIKit
import AVFoundation

import MediaPlayer

class WPYVideoEditManager: NSObject {

    
//    class func getRecorderDataFromURL(url:URL)->(Data){
//
//        var data = Data.init() //用于保存音频数据
//        let asset = AVAsset(url: url) // 获取数据
//
//        let reader = try? AVAssetReader(asset: asset) // 创建读取
//        if reader == nil {
//            return data
//        }
//        // 从媒体中得到音频u轨道
//        guard let track = asset.tracks(withMediaType: AVMediaType.audio).first else{return data}
//
//        // 读取配置
//        let dict = [AVFormatIDKey : kAudioFormatLinearPCM,AVLinearPCMIsBigEndianKey:false,AVLinearPCMIsFloatKey:false,AVLinearPCMBitDepthKey:16] as [String : Any]
//        // 读取输出，在相应的轨道和输出对应格式的数据
//        let output = AVAssetReaderTrackOutput(track: track, outputSettings: dict)
//
//        //赋给读取并开启读取
//        reader?.add(output)
//        reader?.startReading()
//
//        //读取是一个持续的过程 每次只读取后面的大小数据，当读取的状态发生改变是 其status属性会发生变化，我们可以根据状态判断是否读取完成
//        while reader?.status ==  AVAssetReader.Status.reading{
//
//            if let sampleBuffer = output.copyNextSampleBuffer() //读取数据
//            {
//                // 取出数据
//                if let blockBufferRef = CMSampleBufferGetDataBuffer(sampleBuffer){
//                    // 返回一个大小 size_t 针对不同的品台有不同
//                     let length = CMBlockBufferGetDataLength(blockBufferRef)
//
////                    UnsafeMutableRawPointer(bitPattern: length)
//                    let sampleBytes:UnsafePointer<UInt8>
//
//
//                    CMBlockBufferCopyDataBytes(blockBufferRef, atOffset: 0, dataLength: length, destination: sampleBytes)
//
//                        data.append(sampleBytes, count: length)
//                        CMSampleBufferInvalidate(sampleBuffer)//销毁
//                        //释放
//
//                }
//            }
//        }
//
//        if reader?.status == AVAssetReader.Status.completed{
//
//        }
//
//
//        return data
//    }
    
    
//    class func cutAudioData(interval:Int,url:URL){
//
//        var filterArray = NSMutableArray.init()
//        let data:NSData = self.getRecorderDataFromURL(url: url)
//
//        guard let index = Int(kCMMetadataBaseDataType_SInt16 as String)else {return}
//
//        let sampleCount = data.length / index  //计算所有数据个数
//        let binSize = sampleCount / interval   //将数据分隔 也就是按照需求 按interval 分成一个个小包
//        let bytes = data.bytes
//
////        let maxSample
//
//        for i in 0..<sampleCount {
//
//            guard let sampleBin = UnsafeMutableRawPointer(bitPattern: binSize) else{return}
//
//            for j in 0..<binSize {
//                sampleBin.advanced(by: j) = CFSwapInt16LittleToHost(bytes[i+j])
//            }
//
//        }
//
//
//    }
    
    class func cropVideo(asset: AVAsset, cropRange:CMTimeRange, completion:((_ newUrl: URL, _ newDuration:CGFloat,_ result:Bool) -> ())?) {
        
        //        let asset = AVURLAsset.init(url: url, options: nil)
        let duration = CGFloat(CMTimeGetSeconds(asset.duration))
        
        //AVAssetExportPresetHighestQuality
        
        let outputUrl = mergeVideoURL()
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: asset)
        
        if !compatiblePresets.contains(AVAssetExportPresetHighestQuality) {
            
            completion?(outputUrl,duration,false)
            return
        }
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            
            completion?(outputUrl,duration,false)
            return
        }
        exportSession.outputURL = outputUrl
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.timeRange = cropRange
        //        exportSession.
        exportSession.exportAsynchronously {
            let status = exportSession.status
            switch status {
            case .failed:
                
                completion?(outputUrl,duration,false)
                break
            case .cancelled:
                
                completion?(outputUrl,duration,false)
                break
            case .completed:
                
                completion?(outputUrl,duration,true)
                break
            default:
                break
            }
        }
    }
    
    
    //音视频剪切
    
    class func cutWith(avAsset:AVAsset?,audioPath:URL?,cropRange:CMTimeRange, completed:@escaping (_ videoPath:URL?, _ isSuccess:Bool)->()){
        
        if avAsset == nil && audioPath == nil {
            return
        }
        ///音频
        var asset = avAsset
        if let path = audioPath{
            asset = AVURLAsset(url: path)
        }
        
        /// 输出相关设置
        let exportSession = AVAssetExportSession(asset: asset!, presetName: AVAssetExportPresetAppleM4A)
        exportSession?.outputFileType = AVFileType.m4a
        
        exportSession?.outputURL = outPath()
        exportSession?.shouldOptimizeForNetworkUse = true
        
//        let startTime = CMTimeMake(value: Int64(fromTime), timescale: 1)
//        let duration = CMTimeMake(value: Int64(toTime - fromTime), timescale: 1)
        
        /// 截取的范围
        exportSession?.timeRange = cropRange
//        CMTimeRangeFromTimeToTime(start: startTime, end: endTime)
        
        exportSession?.exportAsynchronously {
            
            switch exportSession?.status{
                
            case .none,.some(.waiting),.some(.exporting),.some(.failed),.some(.cancelled),.some(.unknown):
                
                completed(exportSession?.outputURL,false)
                
                case .some(.completed):
                
                   completed(exportSession?.outputURL,true)
            }
        }
    }
    
    
    
  class  func addBackgroundMusic(_ recordUrl: URL,_ backMusicPath:String?, completed:@escaping(_ videoURL:URL?) ->()){
        
        var mixParams = [AVMutableAudioMixInputParameters]()
        //用来添加track轨道的混合素材
        let composition = AVMutableComposition()
    
    
    
    let firstTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID())
    
        let audioTrack  = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())

        var insertTime:CMTime = .zero //下次插入录音段起点

        let asset:AVAsset = AVURLAsset(url: recordUrl)
//
    
    do {
        try firstTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration), of:asset.tracks(withMediaType: AVMediaType.video)[0], at: insertTime)
    }catch _ {

    }
    
    do {
        
            try audioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration), of: asset.tracks(withMediaType: AVMediaType.audio)[0], at: insertTime)
        }catch _{
            
        }
    
    
//        let track = asset.tracks(withMediaType: AVMediaType.audio).first
        
          insertTime = asset.duration
    //旋转视频图像，防止90度颠倒
    firstTrack?.preferredTransform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        // 从录音轨道中生成一个混音素材，添加到数组中
        let  recorderMix = AVMutableAudioMixInputParameters(track: audioTrack)
        recorderMix.setVolume(2, at: CMTimeMake(value: 0, timescale: 1))
        mixParams.append(recorderMix)
    
        //插入背景音乐
        
        if let backMusicPath = backMusicPath{
            
            let backMutableTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            
            let asset = AVURLAsset(url: URL(fileURLWithPath: backMusicPath))
            let track = asset.tracks(withMediaType: AVMediaType.audio).first!
            
            let duration = asset.duration > insertTime ? insertTime : asset.duration
            
            try?backMutableTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: duration), of: track, at: CMTime.zero)
            
            let backTrackMix = AVMutableAudioMixInputParameters(track: backMutableTrack)
            
            backTrackMix.setVolume(0.4, at: CMTimeMake(value: 0, timescale: 1))
            mixParams.append(backTrackMix)
        }
        
        //创建一个可变的音频混音
        let audioMix = AVMutableAudioMix()
        audioMix.inputParameters = mixParams
    
   
    let exportSession:AVAssetExportSession!
        
    if #available(iOS 11.0, *) {
        exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHEVC1920x1080)!
    } else {
        exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPreset1920x1080)!
    }
        
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        //如果有混音就设置这个参数
        exportSession.audioMix = audioMix
    
    //获取合并后的视频路径
    guard let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
        return
    }
    
    let destinationPath = documentsPath + "/Video.mp4"
    print("合并后的视频：\(destinationPath)")
    
    let videoPath = URL(fileURLWithPath: destinationPath)
    
    if(FileManager.default.fileExists(atPath: destinationPath)){
        do{
            try FileManager.default.removeItem(atPath: destinationPath)
        }catch _{
            
        }
        print("删除视频片段:\(destinationPath)")
    }
    
    
        exportSession.outputURL = videoPath
        
        exportSession.exportAsynchronously {
            
            if exportSession.status == .completed{
                
                completed(exportSession.outputURL)
            }
        }
        
        
    }
    
    
    
    
    class func audioVideMerge(audioURL:URL, videoURL:URL, audioVolume:Float, videoVolume:Float,handly:@escaping (_ outputPath:URL,_ isSuccess:Bool) -> ()) -> (){
        
        //1 准备素材
        let audioAsset = AVAsset(url: audioURL)
        let videoAsset = AVAsset(url: videoURL)
        
        //2 分离素材
        let videoAudioTrack = videoAsset.tracks(withMediaType:.audio).first
        let videoVideoTrack = videoAsset.tracks(withMediaType:.video).first
        
        let audioTrack = audioAsset.tracks(withMediaType:.audio).first
        
        let videoTime = CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration)
        
        //3 建立环境组合素材
        
        let composition = AVMutableComposition.init()
        
        
        
        //视频
        let  videoComposition = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        do {
            try videoComposition?.insertTimeRange(videoTime, of: videoVideoTrack!, at: CMTime.zero)
        }catch {
            print(error)
        }
        //旋转视频图像，防止90度颠倒
        videoComposition?.preferredTransform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        
        //音频
        let audioComposition = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let audioVideoComposition = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        do {
            try audioComposition?.insertTimeRange(videoTime, of: audioTrack!, at: CMTime.zero)
            
            try audioVideoComposition?.insertTimeRange(videoTime, of: videoAudioTrack!, at: CMTime.zero)
        }catch{
            print(error)
        }
        
        //4 导出组合好的素材
        
        let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetMediumQuality)
        exportSession?.outputFileType = AVFileType.mp4
        exportSession?.shouldOptimizeForNetworkUse = true
        
        exportSession?.audioMix = volumeControl(avtrack: audioVideoComposition, atrack: audioComposition, videoVolume: videoVolume, audioVolume: audioVolume, time: CMTime.zero)
        
        let outPath = outputPath()
        
        exportSession?.outputURL = outPath
        
        exportSession?.exportAsynchronously(completionHandler: {
            
            if exportSession?.status == .some(.completed){
                handly(outPath,true)
            }else{
                
                handly(outPath,false)
                print(exportSession?.error ?? "")
            }
        })
        
        
    }
    
    // 音量设置
    
    class func volumeControl(avtrack:AVCompositionTrack?,atrack:AVCompositionTrack?, videoVolume:Float,audioVolume:Float,time:CMTime) -> AVMutableAudioMix {
        
        let avInput = AVMutableAudioMixInputParameters.init(track: avtrack)
        avInput.setVolume(videoVolume, at: time)
        
        let aInput = AVMutableAudioMixInputParameters.init(track: atrack)
        aInput.setVolume(audioVolume, at: time)
        
        let audioMix = AVMutableAudioMix.init()
        audioMix.inputParameters = [aInput,avInput]
        
        return audioMix
    }
    
    
    
    
    //最终合成视频路径
    
    class func outputPath()->URL {
        
        //获取合并后的视频路径
        guard let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return URL(string: "Video.mp4")!
        }
        
        let date = Date()
        let str = dateString(date, dateFormat: "yyyy-MM-dd-HH-mm-ss")
    
        let destinationPath = documentsPath + "/\(str)Video.mp4"
        print("合并后的视频：\(destinationPath)")
        
        let videoPath = URL(fileURLWithPath: destinationPath)
       
//        deleteTheVideoWithPath(path: destinationPath)
        
        return videoPath
    }
    
    
    //    输出地址
    class func outPath() -> URL {
        let documentDicectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        
//        let time = Date.init().timeIntervalSince1970
        
        let pathStr = documentDicectory! + "/audio.mp4"
        
        deleteTheVideoWithPath(path: pathStr)
        
        return URL.init(fileURLWithPath: pathStr)
    }
    
    class func mergeVideoURL()->URL{
        
        //获取合并后的视频路径
        guard let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return URL(string:"/mergeVideo.mp4")!
        }
        
        let destinationPath = documentsPath + "/mergeVideo.mp4"
        print("合并后的视频：\(destinationPath)")
        
        deleteTheVideoWithPath(path: destinationPath)
        
        
        return URL(fileURLWithPath: destinationPath)
        
    }
    
    class func mergeVideoPath()->String {
        
        //获取合并后的视频路径
        guard let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return "mergeVideo.mp4"
        }
        
        let destinationPath = documentsPath + "/mergeVideo.mp4"
        
        
        return destinationPath
    }
    
    
   class func dateString(_ date:Date,dateFormat:String)-> String{
        
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        let str = formatter.string(from: date)
        
        return  str
    }
    
    
    class func deleteTheVideoWithPath(path:String){
        
        if(FileManager.default.fileExists(atPath: path)){
            do{
                try FileManager.default.removeItem(atPath: path)
            }catch _{
                
            }
            print("已经删除删除视频片段:\(path)")
        }
    }
}


