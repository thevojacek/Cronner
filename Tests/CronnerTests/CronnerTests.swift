import XCTest
import Dispatch
@testable import Cronner


/// Testable task
struct TestTask: CronTask {
    
    var taskName: String
    var runOnlyOnce: Bool
    var runImmediately: Bool
    
    let pointer: UnsafeMutablePointer<Int>
    let after: UInt
    
    init (taskName: String, runOnlyOnce: Bool, runImmediately: Bool, pointer: UnsafeMutablePointer<Int>, runAfter: UInt) {
        self.taskName = taskName
        self.runOnlyOnce = runOnlyOnce
        self.runImmediately = runImmediately
        self.pointer = pointer
        self.after = runAfter
    }
    
    func run() {
        print("Task `\(self.taskName)` is being executed.")
        self.pointer.pointee = self.pointer.pointee + 1
    }
    
    func runAfter () -> UInt {
        return self.after
    }
    
    func firstRunAt() -> Date? {
        return nil
    }
}


final class CronnerTests: XCTestCase {
    
    func test() {

        let timeout = Date().addingTimeInterval(TimeInterval(exactly: 10)!)
        var run = true
        
        // Pointers initialization
        let pointer_1 = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        pointer_1.initialize(to: 0)
        
        let pointer_2 = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        pointer_2.initialize(to: 0)
        
        let pointer_3 = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        pointer_3.initialize(to: 0)
        
        // Deallocation
        defer {
            pointer_1.deallocate()
            pointer_2.deallocate()
            pointer_3.deallocate()
        }
        
        // Tasks
        let task_1 = TestTask(taskName: "task 1", runOnlyOnce: true, runImmediately: true, pointer: pointer_1, runAfter: 1)
        let task_2 = TestTask(taskName: "task 2", runOnlyOnce: false, runImmediately: false, pointer: pointer_2, runAfter: 2)
        let task_3 = TestTask(taskName: "task 3", runOnlyOnce: false, runImmediately: false, pointer: pointer_3, runAfter: 15)
        
        // Cronner
        let cronner = Cronner(withCheckTime: UInt(2), withStore: nil)
        
        try! cronner.registerTask(task_1)
        try! cronner.registerTask(task_2)
        try! cronner.registerTask(task_3)
        
        cronner.resume()

        // Main thread needs to be occupied in order to let `Cronner` operate in another one asynchronously.
        while (run) {
            
            if Date() > timeout {
                run = false
                cronner.pause()
                XCTAssert(false) // Forces test to fail when conditions are not met in given time
            }
            
            let stop = pointer_1.pointee == 1 && pointer_2.pointee > 2 && pointer_3.pointee == 0
            
            if stop {
                cronner.pause()
                run = false
            }
        }
    }

    static var allTests = [
        ("test", test),
    ]
}
