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


/// Protocol describing implementation of store for Cronner.
public protocol CronnerStore {
    
    /// Saves/replaces record in store.
    ///
    /// - Parameter record: Record to save.
    /// - Returns: Void.
    func save (_ record: ScheduleRecord) -> Void
    
    /// Loads scheduling record for a task, if exists.
    ///
    /// - Parameter taskName: Task name to search for a record.
    /// - Returns: Record or nil.
    func load (_ taskName: String) -> ScheduleRecord?
    
    /// Loads all of the scheduling records.
    ///
    /// - Returns: Array of scheduling records.
    func loadAll () -> [ScheduleRecord]
    
    /// Removes scheduling record for a specified task.
    ///
    /// - Parameter taskName: Name of the task for which to remove scheduling record.
    /// - Returns: Void.
    func remove (_ taskName: String) -> Void
}

public struct ScheduleRecord: Encodable {
    public let taskName: String
    public var nextRun: Date
    public var runs: Int = -1
}
