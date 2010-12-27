m4_include(texiGeneric.m4)m4_dnl -*-texinfo-*-
m4_define([projectName],[M(V)80])
m4_define([new_word],[
new_section([$1])
$2])
document_header(projectName 1.x Architecture Discussion,Architecture_Discussion.info)


@ifnottex
@node Top
@top projectName Architecture Discussion
@end ifnottex

@menu
* Dictionary::
* Architecture::
@end menu


m80 arose from a need to speed change management in a controlled fashion and
to embed application meta-knowledge into the application. Jim sees these two 
problems as the fundamental problems facing s/w development today.

To meet these challenges, the m80 toolset abstracts the software development 
process into two separate and distinct phases: that which goes into producing 
a working piece of software and that which goes into building and distributing 
that software. Change management concerns are managed so as to be incorporated 
into the first (and all subsequent) releases. Knowledge management is incorporated
into the architecture, metadata, and build.

The most important thing about this framework is that there is nothing new
here. This is an amalgamation of tools and concepts that have existed since
the 50's and 60's. A sub goal of this project is to NOT re-invent the wheel!

new_chapter([Dictionary])

@menu
* Namespace::
* Inheritence::
* Component::
@end menu

new_word([Namespace], [
Jim: could be equal to what we have been calling a component. I think the important part
of this is that it is implied by default, but can be defined explicitly. There should also 
be some type of map that will allow us to show where a particular namespace is located on
disk - in the component code tree])

new_word([Inheritence], [
Jim: Needs to be implied either from the hierarchy on disk, or from the namespaces. ])


new_word([Component], [
Jim: WAY TOO OVERLOADED! I want to lock this down to mean ONLY:
1) FolderNames under M80_REPOSITORY
2) The Namespace of all code in that folder
3) The conceptual component which that code represents.

So the ``Client.DB'' component would live in the Client/DB folder and would include
source files: Client/DB/src library files: Client/DB/lib])

new_chapter([Architecture])

@menu
* Nodes and Trees::
* PreCompilers::
* PreCompiler Libraries::
* Component Libraries::
* Automated Build::
* Metadata::
* Working Environment::
* Autoconf - m80 Developers::
@end menu

new_section(Nodes and Trees)

The Node is the most basic element in the framework. A Node is conceptually equivalent
to a component, an application, a system, or generally - something that makes up the 
software or system being written. Nodes come together into Trees. Trees are actually 
Directed Acyclic Graphs which track parent and child Nodes. 

At the implementation level, a Node is a folder and a tree is the stack of folders
defined from the root $M80_REPOSITORY

new_section(PreCompilers)

An Evaluator is a typed, extensible pre-processor. One type defines how to take a file written in a 
preprocessor language like Lisp, Perl or m4 and marry it to the appropriate templates
to create the appropriate output file. Another type may define how to move a collection of files
around on disk based on some input configuration and some input Node. Everything about this 
type of tool is configurable either at runtime or at compile time (if it is a compiled Evaluator).

At the implementation level, an Evaluator is primarily a shell script - although it could 
really be implemented in any manner. This is too abstract - Real examples of Evaluators are:
m80.sh, the %.java.m4 suffix rule.

new_section(PreCompiler Libraries)

There are 3-4 pieces to an Evaluator - 

@enumerate
@item The actual Evaluator
@item The Evaluator Template Libraries
@item A Shell Snippet that implements the Evaluator
@end enumerate

For example: The Perl Pre-Processor is a Perl script and a bunch of language constructs 
defined in library files that can be included by a source file processed by this Evaluator.


new_section(Component Libraries)

Component Libraries.

new_section(Automated Build)

Make rules - possibly wrapped into a tool that will do some generic pre-processor hygiene 
prior to running a pre-processor.

new_section(Metadata)

New structure that defines:

@enumerate
@item name value pairs
@item lists
@item properties
@end enumerate

Essentially a Node in Metadata is a Node in the DAG. Name Value pairs are the simplest
representation, and all structures, lists, and properties should be able to be reduced
to this. Bret wants a namespace, and I think we are both thinking Java import like
syntax. This can get unwieldy as far as name value "names" are concerned. There will be
some tools that wrap this up and provide a nice/consistent interface.

new_section(Working Environment)

The Unix shell is the top level on this. The only other main IDE should be Emacs.
At least to start. Of course the IDE is extensible so if someone writes the hooks any
IDE can plug in.

new_section(Autoconf - m80 Developers)

Any node can get wrapped up as a deployment bundle that includes all the information that
it needs to build itself and create it's own new deployment bundle.

@bye











