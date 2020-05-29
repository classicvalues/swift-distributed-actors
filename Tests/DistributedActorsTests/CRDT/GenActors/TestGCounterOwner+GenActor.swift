// ==== ------------------------------------------------------------------ ====
// === DO NOT EDIT: Generated by GenActors                     
// ==== ------------------------------------------------------------------ ====

//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Distributed Actors open source project
//
// Copyright (c) 2019-2020 Apple Inc. and the Swift Distributed Actors project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.md for the list of Swift Distributed Actors project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

@testable import DistributedActors
import DistributedActorsTestKit
import NIO
import XCTest

// ==== ----------------------------------------------------------------------------------------------------------------
// MARK: DO NOT EDIT: Generated TestGCounterOwner messages 

/// DO NOT EDIT: Generated TestGCounterOwner messages
extension TestGCounterOwner {

    public enum Message: ActorMessage { 
        case increment(amount: Int, consistency: CRDT.OperationConsistency, timeout: DistributedActors.TimeAmount, _replyTo: ActorRef<Int>) 
        case read(consistency: CRDT.OperationConsistency, timeout: DistributedActors.TimeAmount, _replyTo: ActorRef<Result<Int, ErrorEnvelope>>) 
        case lastObservedValue(_replyTo: ActorRef<Int>) 
    }
    
}
// ==== ----------------------------------------------------------------------------------------------------------------
// MARK: DO NOT EDIT: Generated TestGCounterOwner behavior

extension TestGCounterOwner {

    public static func makeBehavior(instance: TestGCounterOwner) -> Behavior<Message> {
        return .setup { _context in
            let context = Actor<TestGCounterOwner>.Context(underlying: _context)
            let instance = instance

            instance.preStart(context: context)

            return Behavior<Message>.receiveMessage { message in
                switch message { 
                
                case .increment(let amount, let consistency, let timeout, let _replyTo):
                    let result = instance.increment(amount: amount, consistency: consistency, timeout: timeout)
                    _replyTo.tell(result)
 
                case .read(let consistency, let timeout, let _replyTo):
                    instance.read(consistency: consistency, timeout: timeout)
                        .whenComplete { res in
                            switch res {
                            case .success(let value):
                                _replyTo.tell(.success(value))
                            case .failure(let error):
                                _replyTo.tell(.failure(ErrorEnvelope(error)))
                            }
                        }
 
                case .lastObservedValue(let _replyTo):
                    let result = instance.lastObservedValue()
                    _replyTo.tell(result)
 
                
                }
                return .same
            }.receiveSignal { _context, signal in 
                let context = Actor<TestGCounterOwner>.Context(underlying: _context)

                switch signal {
                case is Signals.PostStop: 
                    instance.postStop(context: context)
                    return .same
                case let terminated as Signals.Terminated:
                    switch try instance.receiveTerminated(context: context, terminated: terminated) {
                    case .unhandled: 
                        return .unhandled
                    case .stop: 
                        return .stop
                    case .ignore: 
                        return .same
                    }
                default:
                    try instance.receiveSignal(context: context, signal: signal)
                    return .same
                }
            }
        }
    }
}
// ==== ----------------------------------------------------------------------------------------------------------------
// MARK: Extend Actor for TestGCounterOwner

extension Actor where A.Message == TestGCounterOwner.Message {

     func increment(amount: Int, consistency: CRDT.OperationConsistency, timeout: DistributedActors.TimeAmount) -> Reply<Int> {
        // TODO: FIXME perhaps timeout should be taken from context
        Reply.from(askResponse: 
            self.ref.ask(for: Int.self, timeout: .effectivelyInfinite) { _replyTo in
                Self.Message.increment(amount: amount, consistency: consistency, timeout: timeout, _replyTo: _replyTo)}
        )
    }
 

     func read(consistency: CRDT.OperationConsistency, timeout: DistributedActors.TimeAmount) -> Reply<Int> {
        // TODO: FIXME perhaps timeout should be taken from context
        Reply.from(askResponse: 
            self.ref.ask(for: Result<Int, ErrorEnvelope>.self, timeout: .effectivelyInfinite) { _replyTo in
                Self.Message.read(consistency: consistency, timeout: timeout, _replyTo: _replyTo)}
        )
    }
 

     func lastObservedValue() -> Reply<Int> {
        // TODO: FIXME perhaps timeout should be taken from context
        Reply.from(askResponse: 
            self.ref.ask(for: Int.self, timeout: .effectivelyInfinite) { _replyTo in
                Self.Message.lastObservedValue(_replyTo: _replyTo)}
        )
    }
 

}
