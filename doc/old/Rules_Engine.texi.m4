m4_include(texiGeneric.m4)m4_dnl -*-texinfo-*-
document_header(Rules Engine,Rules_Engine.info)

@ifnottex
@node Top
@top Rules Engine
@end ifnottex

@menu
* Overview::
* Features::
* Implementation::
@end menu

new_chapter(Overview)

The rules engine is a component available to be embedded into applications that are part of the m80 framework.

This document describes the rules engine and the implemenation of a rules engine.

new_chapter(Features)

The initial goal of this rules engine (and probably the best test case scenario) is to be able to upgrade
itself. This means that there will be a rules engine implemenation with some degree of versioning, and there
will be a test script that will allow the rules engine to rebuild the application with new rules logic and
versions. 

@enumerate
@item Graph based implemenation for the rules engine

@enumerate
@item Directed nodes represent steps in a process.

@item Undirected nodes are steps that are at the same level and must be evaluated for execution
as well as steps that might be able to run in parallel if that functionality is available.

@item Unconnected nodes will all be considered top level nodes of separate rules.
@end enumerate

@item A node can contain a rule or a graph. A graph is a collection of nodes. The top level implementation
will either be a graph with a bunch of Undirected nodes, or it will be a collection of starter points in a 
collection of graphs.

@item Graph is node-cost based. The cost of a node can be determined dynamically, or statically. Shortest
path calculations are based on the cost of a node.

@item Rules can be defined outside of the compiled application. I.e. there will be an interpreted Rules
language that is dynamically loaded.

@item Rules will also be allowed to be precompiled into the application. This will likely be through header
files or some type of include file mechanism.

@item The rules engine will version itself in memory and on disk. The language used to implement the rules
engine, both in preprocessing and runtime loads will specify it's own version. There will be a macro disallowing
upgrades of incompatible versions.

@item There will be a central "Whiteboard" for interaction of separate agents. This will be a queue type of
implemenation, it will be on disk, and it will allow for logging functionality. Agents will be allowed to
access the whiteboard based on some priority. The higher the priority, the sooner an agent can process it.

@item There will be some master process that has exclusive access to the whiteboard. This will be used for 
logging purposes, and possibly agent startup and shutdown processes.

@item The rules engine can be compiled into apps, and defines a simple-to-implement interface.
@end enumerate

new_chapter(Implementation)

The engine will be written in C.

The Whiteboard will be written in BerkleyDB (w/ transactions)

A perl wrapper will be written around the C libs for rules agent access in Perl.

@bye
