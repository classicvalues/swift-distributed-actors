//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Distributed Actors open source project
//
// Copyright (c) 2018-2019 Apple Inc. and the Swift Distributed Actors project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.md for the list of Swift Distributed Actors project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Darwin
#else
import Glibc
#endif

/// :nodoc: Not intended to be used by end users.
public final class Mutex {
    @usableFromInline
    var mutex: pthread_mutex_t = pthread_mutex_t()

    public init() {
        var attr: pthread_mutexattr_t = pthread_mutexattr_t()
        pthread_mutexattr_init(&attr)
        pthread_mutexattr_settype(&attr, Int32(PTHREAD_MUTEX_RECURSIVE))

        let error = pthread_mutex_init(&mutex, &attr)
        pthread_mutexattr_destroy(&attr)

        switch error {
        case 0:
            return
        default:
            fatalError("Could not create mutex: \(error)")
        }
    }

    deinit {
        pthread_mutex_destroy(&mutex)
    }

    @inlinable
    public func lock() -> Void {
        let error = pthread_mutex_lock(&mutex)

        switch error {
        case 0:
            return
        case EDEADLK:
            fatalError("Mutex could not be acquired because it would have caused a deadlock")
        default:
            fatalError("Failed with unspecified error: \(error)")
        }
    }

    @inlinable
    public func unlock() -> Void {
        let error = pthread_mutex_unlock(&mutex)

        switch error {
        case 0:
            return
        case EPERM:
            fatalError("Mutex could not be unlocked because it is not held by the current thread")
        default:
            fatalError("Unlock failed with unspecified error: \(error)")
        }
    }

    @inlinable
    public func tryLock() -> Bool {
        let error = pthread_mutex_trylock(&mutex)

        switch error {
        case 0:
            return true
        case EBUSY:
            return false
        case EDEADLK:
            fatalError("Mutex could not be acquired because it would have caused a deadlock")
        default:
            fatalError("Failed with unspecified error: \(error)")
        }
    }

    @inlinable
    public func synchronized<A>(_ f: () -> A) -> A {
        lock()

        defer {
            unlock()
        }

        return f()
    }

    @inlinable
    public func synchronized<A>(_ f: () throws -> A) throws -> A {
        lock()

        defer {
            unlock()
        }

        return try f()
    }
}



// ------------ "locks.swift" of the proposal

/// :nodoc: Not intended to be used by end users.
///
/// A threading lock based on `libpthread` instead of `libdispatch`.
///
/// This object provides a lock on top of a single `pthread_mutex_t`. This kind
/// of lock is safe to use with `libpthread`-based threading models, such as the
/// one used by NIO.
internal final class ReadWriteLock {
    fileprivate let rwlock: UnsafeMutablePointer<pthread_rwlock_t> = UnsafeMutablePointer.allocate(capacity: 1)

    /// Create a new lock.
    public init() {
        let err = pthread_rwlock_init(self.rwlock, nil)
        precondition(err == 0)
    }

    deinit {
        let err = pthread_rwlock_destroy(self.rwlock)
        precondition(err == 0)
        self.rwlock.deallocate()
    }

    /// Acquire a reader lock.
    ///
    /// Whenever possible, consider using `withLock` instead of this method and
    /// `unlock`, to simplify lock handling.
    public func lockRead() {
        let err = pthread_rwlock_rdlock(self.rwlock)
        precondition(err == 0)
    }

    /// Acquire a writer lock.
    ///
    /// Whenever possible, consider using `withLock` instead of this method and
    /// `unlock`, to simplify lock handling.
    public func lockWrite() {
        let err = pthread_rwlock_wrlock(self.rwlock)
        precondition(err == 0)
    }

    /// Release the lock.
    ///
    /// Whenever possible, consider using `withLock` instead of this method and
    /// `lock`, to simplify lock handling.
    public func unlock() {
        let err = pthread_rwlock_unlock(self.rwlock)
        precondition(err == 0)
    }
}

/// :nodoc: Not intended to be used by end users.
extension ReadWriteLock {
    /// Acquire the reader lock for the duration of the given block.
    ///
    /// This convenience method should be preferred to `lock` and `unlock` in
    /// most situations, as it ensures that the lock will be released regardless
    /// of how `body` exits.
    ///
    /// - Parameter body: The block to execute while holding the lock.
    /// - Returns: The value returned by the block.
    @inlinable
    public func withReaderLock<T>(_ body: () throws -> T) rethrows -> T {
        self.lockRead()
        defer {
            self.unlock()
        }
        return try body()
    }

    /// Acquire the writer lock for the duration of the given block.
    ///
    /// This convenience method should be preferred to `lock` and `unlock` in
    /// most situations, as it ensures that the lock will be released regardless
    /// of how `body` exits.
    ///
    /// - Parameter body: The block to execute while holding the lock.
    /// - Returns: The value returned by the block.
    @inlinable
    public func withWriterLock<T>(_ body: () throws -> T) rethrows -> T {
        self.lockWrite()
        defer {
            self.unlock()
        }
        return try body()
    }

    // specialise Void return (for performance)
    @inlinable
    public func withReaderLockVoid(_ body: () throws -> Void) rethrows {
        try self.withReaderLock(body)
    }

    // specialise Void return (for performance)
    @inlinable
    public func withWriterLockVoid(_ body: () throws -> Void) rethrows {
        try self.withWriterLock(body)
    }
}