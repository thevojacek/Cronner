# Cronner

Simple **asynchronous** cron task scheduler for Swift with straightforward interface.
All the tasks which you may register for scheduled execution are being executed asynchronously.
For list of all options you may configure your tasks, see **usage** section down below.

## Usage

In order to register a task to a cronner, you need to create a structure or a class which conforms to a `CronTask` protocol.
Protocol specification:

```swift
/// Protocol describing kind of task to be processed by a `Cronner`.
public protocol CronTask {

    /// Name of the task to perform.
    var taskName: String { get }

    /// Determines, whether task will be run just once, or if it is being periodically executed.
    var runOnlyOnce: Bool { get }

    /// Determines, whether to run task immediately after registration, or to wait to a next schedule.
    var runImmediately: Bool { get }

    /// Function, which is to be executed by a `Cronner` as scheduled.
    ///
    /// - Returns: Void
    func run () -> Void

    /// Specifies, in seconds, after which time to schedule task execution.
    ///
    /// - Returns: Seconds.
    func runAfter () -> UInt

    /// Specifies an exact date, from which to schedule task execution.
    /// Just return nil if you don't need to specify exact date.
    /// Current date will then be used to start scheduling process.
    ///
    /// - Returns: Date from which to start or nil to start schedule process right away.
    func firstRunAt () -> Date?
}
```

Then, you need to create an instance of a `Cronner` and register tasks you want to schedule to execution. You can control task execution by
calling `resume` or `pause` methods of a `Cronner`, which pauses or resumes/starts execution process respectivelly, as shown below.

```swift
import Cronner

// Create instance of your task to run
let task = TestTask(taskName: "Test task", runOnlyOnce: false, runImmediately: false, runAfter: 60)

// Instance of Cronner
let cronner = Cronner()

// Register task
try! cronner.registerTask(task)

// Starts/resumes cronner scheduling and execution process
cronner.resume()

// Pauses cronner
// cronner.pause()
```

Alternativelly, you have another ways how to initialize `Cronner` at your disposal to further modify it's behavior. You can initialize `Cronner`
instance with specification, after which time the instance should check if it is time to execute any tasks, and also you can modify store, which
instance should you use to store it's internal data needed for task scheduling. By default, `Cronner` uses in-memory store, but you can write
your own by conforming to `CronnerStore` protocol. It is worth mentioning, that such a store for MongoDB is on the way and will be available
as a separate package.

```swift
import Cronner

let instance_1 = Cronner(withCheckTime: UInt(5), withStore: nil)
let instance_2 = Cronner(withStore: YourCustomStore())
```


## License

MIT License

Copyright (c) 2018 Jan Vojáček

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.