//
//  File.swift
//  
//
//  Created by 季勤强 on 2020/3/26.
//

import UIKit

open class JYLagMonitor {
  
  static open let shared = JYLagMonitor()
  
  var runLoopObserver: CFRunLoopObserver?
  var dispatchSemaphore: DispatchSemaphore?
  var runLoopActivity: CFRunLoopActivity = CFRunLoopActivity.entry
  var timeoutCount = 0
  var isMoniting = false
  
  open func start() {
    self.isMoniting = true
    if runLoopObserver != nil {
      return
    }
    
    dispatchSemaphore = DispatchSemaphore(value: 0)
    
    let info = Unmanaged<JYLagMonitor>.passUnretained(self).toOpaque()
    var context = CFRunLoopObserverContext(version: 0, info: info, retain: nil, release: nil, copyDescription: nil)
    runLoopObserver = CFRunLoopObserverCreate(kCFAllocatorDefault, CFRunLoopActivity.allActivities.rawValue, true, 0, runLoopObserverCallBack(), &context)
    
    CFRunLoopAddObserver(CFRunLoopGetMain(), runLoopObserver, CFRunLoopMode.commonModes)
    
    DispatchQueue.global().async {
      while true {
        let semaphoreWait = self.dispatchSemaphore!.wait(timeout: DispatchTime.now() + 0.088)
        if DispatchTimeoutResult.timedOut == semaphoreWait {
          if self.runLoopObserver == nil {
            self.dispatchSemaphore = nil
            self.runLoopActivity = CFRunLoopActivity.entry
            return
          }
          
          /**
          kCFRunLoopBeforeSources  // 触发 Source0 回调
          kCFRunLoopAfterWaiting  // 接收 mach_port 消息
           */
          if [CFRunLoopActivity.beforeSources, CFRunLoopActivity.afterWaiting].contains(self.runLoopActivity) {
            // If it continuous appears three times, then we can say, it must be blocked.
            if self.timeoutCount < 3 {
              self.timeoutCount += 1
              continue
            }
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
              // TODO
              print("check the block info...")
            }
            
          }
        }
        self.timeoutCount = 0
      }
    }
  }
  
  open func end() {
    self.isMoniting = false
    guard runLoopObserver != nil else {
      return
    }
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), self.runLoopObserver, CFRunLoopMode.commonModes)
    self.runLoopObserver = nil
  }
  
  func runLoopObserverCallBack() -> CFRunLoopObserverCallBack {
    return { observer, activity, info in
      guard let context = info else {
        return
      }
      let weakSelf = Unmanaged<JYLagMonitor>.fromOpaque(context).takeUnretainedValue()
      weakSelf.runLoopActivity = activity
      weakSelf.dispatchSemaphore?.signal()
    }
  }
  
}
