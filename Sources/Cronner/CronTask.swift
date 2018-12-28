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


/// Protocol describing kind of task to be processed by a `Cronner`.
public protocol CronTask {
    
    /// Name of the task to perform.
    var taskName: String { get }
    
    /// Determines, whether task will be run just once, or if it is being periodically executed.
    var runOnlyOnce: Bool { get } // TODO: rename ??
    
    /// Determines, whether to run task immediately after registration, or to wait to a next schedule.
    var runImmediately: Bool { get }
    
    /// Function, which is to be executed by a `Cronner` as scheduled.
    ///
    /// - Returns: Void
    func run () -> Void
    
    /// Specifies, in seconds, after which time to schedule task execution.
    ///
    /// - Returns: Seconds.
    func runAfter () -> Int
    
    /// Specifies an exact date, from which to schedule task execution.
    /// Just return nil if you don't need to specify exact date.
    /// Current date will then be used to start scheduling process.
    ///
    /// - Returns: Date from which to start or nil to start schedule process right away.
    func firstRunAt () -> Date?
}
