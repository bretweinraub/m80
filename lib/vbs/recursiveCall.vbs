'
' This file is part of m80.
'
' Check the license file @ m80.sourceforge.net
'
' ******************************************************************
' Makes available Commandline Argument Processing along the lines
' of Perl::Getopt
'
' Include this into a script, and a global Dictionary named:
' CommandLineArgs becomes available with all arguments.
' 
' Accepted Argument Formats:
'       -name=value
'       -name value
'       -name   (Can use multiples)
'
' Limitations:
'       Doesn't support Arrays yet!
'
' ******************************************************************
' -- Start CommandLine Argument Processing --
'
' Dictionary = pushDictionary(Dictionary, Key, Value)
' Process: will add or update after checking Key existence
'
' Side Effects: Updates the Dictionary.
Function pushDictionary(ByRef oDic, sKey, sValue)
        If oDic.Exists(sKey) Then
                If sValue = "" Then     
                        oDic(sKey) = oDic(sKey) + 1
                Else
                        oDic(sKey) = sValue
                End If
        Else
                If sValue = "" Then
                        Call oDic.Add(sKey, 1)
                Else
                        Call oDic.Add(sKey, sValue)
                End If
        End If
        Set pushDictionary = oDic
End Function
 

Dim Count, ttlCommandLineArgs
Dim CommandLineArgs
Set CommandLineArgs = CreateObject("Scripting.Dictionary")
'Wscript.Echo "** Total: " & Wscript.Arguments.Count
Count = 0
ttlCommandLineArgs = Wscript.Arguments.Count - 1
While Count <= ttlCommandLineArgs
        
        ' The Following are command line flags and should get
        ' pushed onto the stack that get stored.
        If Left(Wscript.Arguments(Count), 1) = "-" Or _
        Left(Wscript.Arguments(Count), 1) = "/" Then
                
                If Instr(Wscript.Arguments(Count), "=") <> 0 Then
                        Call pushDictionary(CommandLineArgs, _
                                Mid(Wscript.Arguments(Count), 1, Instr(Wscript.Arguments(Count), "=") - 1), _
                                Mid(Wscript.Arguments(Count), Instr(Wscript.Arguments(Count), "=") + 1))
                        Count = Count + 1
 
                ElseIf Count + 1 > ttlCommandLineArgs Then
                        Call pushDictionary(CommandLineArgs, Wscript.Arguments(Count), "")
                        Count = Count + 1
 
                ElseIf Left(Wscript.Arguments(Count + 1), 1) = "-" Or _
                Left(Wscript.Arguments(Count + 1), 1) = "/" Then
                        Call PushDictionary(CommandLineArgs, Wscript.Arguments(Count), "")
                        Count = Count + 1
 
                Else
                        Call pushDictionary(CommandLineArgs, Wscript.Arguments(Count), Wscript.Arguments(Count + 1))
                        Count = Count + 2
 
                End If
        
        Else
                Count = Count + 1
        End If
Wend
' -- End CommandLine Argument Processing --
' ******************************************************************
 
Sub RecurseDirectoriesMatchFileExtension(ByVal AppendPath, ByRef FSO)
    Dim File, Folder, SubFolder, FileName
    Set Folder = FSO.GetFolder(AppendPath)
                
    ' Process the Files in this folder
    For Each File In Folder.Files
'        Wscript.Echo "Evaluating : " & File.Path
        If Right(File, Len(Extension)) = Extension Then
            FileName = AppendPath & "\" & File.Name
            Wscript.Echo "Opened :" & FileName
            oShell.Run ApplicationName & " " & FileName, 1, true
'	    oShell.Run(ApplicationName & " " & FileName, 1, true)	
        End If
    Next
 
    ' Process the sub folders
    For Each SubFolder In Folder.SubFolders
        Call RecurseDirectoriesMatchFileExtension(AppendPath & "\" & SubFolder.Name, FSO)
    Next
End Sub
 
Dim FSO, Have
Set FSO = CreateObject("Scripting.FileSystemObject")
Set oShell = CreateObject("Wscript.Shell")
Root = CommandLineArgs("-Root")
Extension = CommandLineArgs("-ext")
ApplicationName = CommandLineArgs("-App")
Const Usage = "recursedirectories -Root <root> -ext <extension> -App <application path name>"
If Len(Root) = 0 Or Len(Extension) = 0 Or Len(ApplicationName) = 0 Then
    Wscript.Echo Usage
Else
    RecurseDirectoriesMatchFileExtension Root, FSO
End If
