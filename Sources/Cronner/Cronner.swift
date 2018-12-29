/// MIT License
///
/// Copyright (c) 2018 Jan Vojáček
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

import Foundation
import Dispatch


public class Cronner {
    
    private var store: CronnerStore
    
    private let checkTime: Int
    
    private var tasks = [String: CronTask]()
    
    private var running = false
    
    /// Initializes Cronner with default usage of in memory store for records and with checking time of 10 seconds.
    public init () {
        self.checkTime = 10
        self.store = InMemoryStore()
    }
    
    /// Initializes Cronner with custom checking time and optional store.
    ///
    /// - Parameters:
    ///   - checkTime: Determines, how often will Cronner check if task is scheduled to run, in seconds.
    ///   - store: Store to use, defaults to in memory store.
    public init (withCheckTime checkTime: UInt, withStore store: CronnerStore?) {
        self.checkTime = checkTime == 0 ? Int(1) : Int(checkTime)
        self.store = store ?? InMemoryStore()
    }
    
    /// Initializes Cronner with given store.
    ///
    /// - Parameter store: Store to use for storing scheduling records.
    public init (withStore store: CronnerStore) {
        self.checkTime = 10
        self.store = store
    }
}

/// Public functions
extension Cronner {
    
    /// Registers and schedule task to be run based on task's options.
    ///
    /// - Parameter task: task to be registered
    /// - Throws: `CronnerError`
    public func registerTask (_ task: CronTask) throws {
        
        let taskName = task.taskName
        
        if self.tasks[taskName] != nil {
            throw CronnerError.duplicateName
        }
        
        self.tasks[taskName] = task
        self.scheduleTask(self.tasks[taskName]!)
    }
    
    /// Resumes / starts the cronner job.
    public func resume () {
        self.running = true
        self.check()
    }
    
    /// Pauses cronner job.
    public func pause () {
        self.running = false
    }
}

/// Private functions
extension Cronner {
    
    /// Performs asynchronous check, if one of the registered task should be run and if so, runs it asynchronously.
    /// Schedules another check after specified number of seconds.
    private func check () {
        
        let date = Date()
        
        self.store.getAll().forEach { (record) in
            
            let task = self.tasks[record.taskName]
            
            // Removes scheduling record if task does not exist.
            if task == nil {
                self.store.remove(record.taskName)
            }
            
            // Determines whether to run task immediately, but only on the first run!
            let runImmediately = (task?.runImmediately ?? false) && (record.runs < 1)
            
            if record.nextRun <= date || runImmediately {
                self.runTask(task)
                self.scheduleTask(task)
            }
        }
        
        if self.running {
            
            // This will work for up-to 584 years at most. :)
            let at = DispatchTime(uptimeNanoseconds: (DispatchTime.now().rawValue) + UInt64(self.checkTime * 1_000_000_000))
            
            DispatchQueue.global(qos: .default).asyncAfter(deadline: at) {
                if self.running {
                    self.check()
                }
            }
        }
    }
    
    /// Schedules task for running.
    ///
    /// - Parameter task: Task to schedule.
    private func scheduleTask (_ task: CronTask?) {
        
        guard let task = task else { return }
        
        let date = Date().addingTimeInterval(TimeInterval(exactly: Int(task.runAfter()))!)
        var record = self.store.load(task.taskName) ?? ScheduleRecord(taskName: task.taskName, nextRun: date, runs: -1)
        
        // Sets next run shcedule and increment runs
        record.nextRun = date
        record.runs = record.runs + 1
        
        // Sets first run to a specified date, if set
        if record.runs < 1 && task.firstRunAt() != nil {
            record.nextRun = task.firstRunAt()!
        }

        // Remove task when it was run and only if it should be run just once
        if task.runOnlyOnce && record.runs > 0 {
            return self.removeTask(task.taskName)
        }
        
        self.store.save(record)
    }
    
    /// Removes task and it's scheduling record.
    ///
    /// - Parameter taskName: Name of the task to remove.
    private func removeTask (_ taskName: String) {
        self.tasks.removeValue(forKey: taskName)
        self.store.remove(taskName)
    }
    
    /// Runs task asynchronously.
    ///
    /// - Parameter task: Task to run asynchronously.
    private func runTask (_ task: CronTask?) {
        DispatchQueue.global(qos: .default).async {
            task?.run()
        }
    }
}
