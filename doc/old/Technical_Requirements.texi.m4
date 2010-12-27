m4_include(texiGeneric.m4)m4_dnl -*-texinfo-*-
m4_define([projectName],[M(V)80])
document_header(projectName 1.x Technical Requirements,Technical_Requirements.info)


@ifnottex
@node Top
@top projectName Technical Requirements
@end ifnottex

@menu
* Main Feature Sets::
* Freeware distributable installation model::
* Project Builder/Maker::
@end menu


new_chapter([Main Feature Sets])

@enumerate
@item Freeware distributable installation model.
@item Project builder/maker.
@item Build/Upgrade Tool.
@item Code generation libraries.
@item Database management utilities.
@end enumerate

new_chapter([Freeware distributable installation model])

@menu
* Distribution Type::
* Use Of Autotools::
* Additional Modules::
* Upgrade Constraints::
@end menu

new_section([Distribution Type])

The software should be available as a gzipped tar file.  Upon download the entire source should be installable with a simple: ``./configure; make install''

new_section([Use Of Autotools])

The distribution itself should be maintained with the GNU autotools suite.  The tarball itself will be output of a ``make dist'' command in the source.

new_section([Additional Modules])

Optional add-ons should be available as separate distributions.  This can install into optional directories like "site-m80" as with perl.  Individual utilities in m80 should have access to a consistent interface that can interrogate the modules that are installed on a particular machine to determine what is available.

new_section([Upgrade Constraints])

Upgrades need to happen in a managed fashion.  This means that upgrading m80 should never break an existing m80 project.  Some clever versioning will probably be required at the utility/macro level.

One implementation alternative is that for objects that are "upgradeable" (as opposed to replaceable), the code-generation source that produces the deliverable object must be archived so that upgrades to m80 do not invalidate notions of "baselined" code.

new_chapter([Project Builder/Maker])

@menu
* Overview::
* Notion of a Project::
@c * Notion of an environment::
@c * Support for core (multi-project, multi-environment) variables::
@c * Create New Project utility::
@c * Create New Environment utility::
@c * Create New Module utility::
@c * Create Module Group utility::
@end menu

new_section(Overview)

Once m80 is installed, a set of utilities is required to make the m80 backend available to any generic project.
These utilities will need to support the notion of a ``simple'' or ``complex'' project.  Simple as defined by a single module with no hierarchy, or ``complex'' as hierarchical collection of modules and module groups.

new_section(Notion of a Project)
A project means a collection of code of namespaces (or environments) and associated modules (or module groups) that can be associated in a ``build''.

m4_divert(-1)
new_section(Notion of an environment)

new_section(Support for core [(multi-project, multi-environment)] variables)

new_section(Create New Project utility)

new_section(Create New Environment utility)

new_section(Create New Module utility)

new_section(Create Module Group utility)
m4_divert

@bye
