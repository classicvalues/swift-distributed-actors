//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Distributed Actors open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Distributed Actors project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.md for the list of Swift Distributed Actors project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import DistributedActors
import Stencil

protocol Renderable {
    func render() throws -> String
}

enum Rendering {
    static let generatedFileHeader: String =
        """
        //===----------------------------------------------------------------------===//
        //
        // This source file is part of the Swift Distributed Actors open source project
        //
        // Copyright (c) 2019 Apple Inc. and the Swift Distributed Actors project authors
        // Licensed under Apache License v2.0
        //
        // See LICENSE.txt for license information
        // See CONTRIBUTORS.md for the list of Swift Distributed Actors project authors
        //
        // SPDX-License-Identifier: Apache-2.0
        //
        //===----------------------------------------------------------------------===//

        // ==== ------------------------------------------------------------------ ====
        // === DO NOT EDIT: Generated by GenActors (version: ...).                              
        // ==== ------------------------------------------------------------------ ====

        import DistributedActors

        """

    struct ActorShellTemplate: Renderable {
        let baseName: String
        let funcs: [ActorFunc]

        static let template = Template(
            templateString:
            """
            // ==== ----------------------------------------------------------------------------------------------------------------
            // MARK: DO NOT EDIT: Generated {{baseName}} messages 

            extension {{baseName}} {
                enum Message { {% for func in funcs %}
                case {{func.name}}({% for param, type in func.params %} {{param}}: {{type}} {% endfor %})
                {% endfor %} 
                }
            }

            // ==== ----------------------------------------------------------------------------------------------------------------
            // MARK: DO NOT EDIT: Generated {{baseName}} behavior

            extension {{baseName}} {
                public static func makeBehavior(context: ActorContext<Message>) -> Behavior<Message> {
                    return .setup { context in
                        var instance = Self(context: context) // TODO: has to become some "make"            

                        // /* await */ self.instance.preStart(context: context) // TODO: enable preStart

                        return .receiveMessage { message in
                            switch message { {% for func in funcs %}
                            case .{{func.name}}({% for param, type in func.params %} let {{param}} {% endfor %}):
                                instance.{{func.name}}( {% for param, type in func.params %} {{param}}: {{param}} {% endfor %} )
                            {% endfor %} }
                            return .same
                        }
                    }
                }

            }

            // ==== ----------------------------------------------------------------------------------------------------------------
            // MARK: Extend Actor for {{baseName}}

            // TODO: could this be ActorRef?
            // extension Actor where Message: Greetings { // FIXME would be nicer
            extension Actor where Myself.Message == {{baseName}}.Message {

                {% for func in funcs %}
                func {{func.name}}({% for param, type in func.params %} {{param}}: {{type}} {% endfor %}) {
                    self.ref.tell({{baseName}}.Message.greet(name: name))
                }
                {% endfor %}
            }

            """
        )

        func render() throws -> String {
            let context: [String: Any] = [
                "baseName": self.baseName,
                "funcs": self.funcs,
            ]

            let rendered = try Self.template.render(context)
            print(rendered)

            return rendered
        }
    }
}

// ==== ----------------------------------------------------------------------------------------------------------------
// MARK: Rendering models

struct ActorFunc {
    let access: String?
    let name: String
    typealias Name = String
    typealias TypeName = String
    let params: [Name: TypeName] // FIXME: rather do a list since order matters

    func renderCaseDelegateToInstance() throws -> String {
        let context: [String: Any] = [
            "name": self.name,
            "params": self.params,
        ]
        return try Template(
            templateString:
            """
            case .{{name}}(): // TODO: let the params
                self.instance.{{name}}() // TODO delegate the params
            """
        ).render(context)
    }
}