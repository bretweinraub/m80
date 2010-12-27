m4_divert(-1)  -*-asp-*-
m4_changequote(!***, ***!)
m4_changequote([,])

m4_define(DEBUG, [If Len(DebugPrint) > 0 Then _ECHO "DBG:" & $@])

# $1: Internal Variable Name, $2: Commandline arg, $3: Boolean- Produce WEB_REQUIRE
m4_define(VAR,
  [m4_pushdef(m4_ucase($1),
  [Len($1) > 0])m4_pushdef(m4_ucase(NOT$1),
  [Len($1) = 0])Dim $1 : $1 = _REQUEST($2)
DEBUG("$1=" & $1)
m4_ifelse([$3],[],[' VARIABLE $1
],[])])


' {{{ StringToArray(sData, sDelim)
m4_define([STRING_TO_ARRAY],[
Function StringToArray(sData, sDelim)
    Dim tmp, tmp2()
'    Wscript.Echo "STRINGTOARRAY:" & sData
    If InStr(sData, sDelim) > 0 Then
        tmp = Split(sData, sDelim, -1, 1)
        StringToArray = tmp
    Else
        ReDim tmp2(0)
        tmp2(0) = sData
        StringToArray = tmp2
    End If
End Function
])
' }}}

' {{{ ArraysToDictionary(sKeys, sValues)
m4_define([ARRAYS_TO_DICTIONARY],[
Function ArraysToDictionary(sKeys, sValues)
    Dim dic ' as Dictionary
    Dim Keys, k, Values, v, tmp()
    Set dic = CreateObject("Scripting.Dictionary")
    If InStr(sKeys, ",") = 0 And InStr(sValues, ",") = 0 Then
        dic.Add sKeys, sValues
        Set ArraysToDictionary = dic
        Exit Function
    End If
    Keys = StringToArray(sKeys, ",")
    Values = StringToArray(sValues, ",")
    If UBound(Values) > UBound(Keys) Then
        Err.Raise 998, , Err.Description & " Keys:" & sKeys & " Values:" & sValues
    End If
    For k = 0 To UBound(Keys)
        If Len(Keys(k)) > 0 Then
            If k <= UBound(Values) Then
                dic.add Keys(k), Values(k)
            Else
                dic.add Keys(k), ""
            End If
        End If
    Next
    Set ArraysToDictionary = dic
End Function
])
' }}}

m4_define([vbs_commandlineargs],[VBS_COMMANDLINEARGS($*)])
m4_define([VBS_COMMANDLINEARGS], [
' ******************************************************************
' Makes available Commandline Argument Processing along the lines
' of Perl::Getopt
'
' Include this into a script[,] and a global Dictionary named:
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
' Dictionary = pushDictionary(Dictionary[,] Key[,] Value)
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
                        Call oDic.Add(sKey[,] 1)
                Else
                        Call oDic.Add(sKey[,] sValue)
                End If
        End If
        Set pushDictionary = oDic
End Function


Dim Count[,] ttlCommandLineArgs
Dim $1
Set $1 = CreateObject("Scripting.Dictionary")
'Wscript.Echo "** Total: " & Wscript.Arguments.Count
Count = 0
ttlCommandLineArgs = Wscript.Arguments.Count - 1
While Count <= ttlCommandLineArgs
        
        ' The Following are command line flags and should get
        ' pushed onto the stack that get stored.
        If Left(Wscript.Arguments(Count)[,] 1) = "-" Or _
        Left(Wscript.Arguments(Count)[,] 1) = "/" Then
                
                If Instr(Wscript.Arguments(Count)[,] "=") <> 0 Then
                        Call pushDictionary($1[,] _
                                Mid(Wscript.Arguments(Count)[,] 1[,] Instr(Wscript.Arguments(Count)[,] "=") - 1)[,] _
                                Mid(Wscript.Arguments(Count)[,] Instr(Wscript.Arguments(Count)[,] "=") + 1))
                        Count = Count + 1

                ElseIf Count + 1 > ttlCommandLineArgs Then
                        Call pushDictionary($1[,] Wscript.Arguments(Count)[,] "")
                        Count = Count + 1

                ElseIf Left(Wscript.Arguments(Count + 1)[,] 1) = "-" Or _
                Left(Wscript.Arguments(Count + 1)[,] 1) = "/" Then
                        Call PushDictionary($1[,] Wscript.Arguments(Count)[,] "")
                        Count = Count + 1

                Else
                        Call pushDictionary($1[,] Wscript.Arguments(Count)[,] Wscript.Arguments(Count + 1))
                        Count = Count + 2

                End If
        
        Else
                Count = Count + 1
        End If
Wend
' -- End CommandLine Argument Processing --
' ******************************************************************
])

m4_define([vbs_stackclass],[VBS_STACKCLASS($*)])
m4_define([VBS_STACKCLASS], [
' ******************************************************************
' -- Start Class Stack --

' This handles all Variants except for Arrays. It uses an Array
' internally to manage it, so it is slightly faster than a collection.
'
' Exposes:
'       Stack.Push(Variant)
'       Variant = Stack.Pop
'       Stack.Reset
'
Class Stack
        Private arInternal()

        Public Sub Push(ByVal vValue)
                Dim Cnt
'               On Error GoTo Err
                 Cnt = UBound(arInternal)
                 If Cnt = 0 Then ' first push?
                          If VarType(arInternal(Cnt)) = vbObject Then
                                        If IsEmpty(arInternal(Cnt)) Or arInternal(Cnt) Is Nothing Then
                                                 Set arInternal(Cnt) = vValue
                                        End If
                          ElseIf CStr(arInternal(Cnt)) = "" Then
                                                 arInternal(Cnt) = vValue
                          Else
                                        ReDim Preserve arInternal(Cnt + 1)
                                        If VarType(arInternal) = vbObject Then
                                                 Set arInternal(Cnt + 1) = vValue
                                        Else
                                                 arInternal(Cnt + 1) = vValue
                                        End If
                          End If
                 Else
                          Cnt = Cnt + 1
                          ReDim Preserve arInternal(Cnt)
                          If VarType(vValue) = vbObject Then
                                        Set arInternal(Cnt) = vValue
                          Else
                                        arInternal(Cnt) = vValue
                          End If
                 End If
        Exit Sub
'       Err:
'                MsgBox Err.Description
        End Sub

        Public Function Pop()
                Dim Cnt
                Cnt = UBound(arInternal)
                If Cnt = 0 Then
                  If VarType(arInternal(Cnt)) = vbObject Then
                                If arInternal(Cnt) Is Nothing Or IsEmpty(arInternal(Cnt)) Then
                                         Set Pop = Nothing
                                End If
                  Else
                                If VarType(arInternal(Cnt)) = vbObject Then
                                         Set Pop = arInternal(Cnt)
                                         Set arInternal(Cnt) = Nothing
                                Else
                                         Pop = arInternal(Cnt)
                                         arInternal(Cnt) = ""
                                End If
                        End If
                 Else
                          If VarType(arInternal(Cnt)) = vbObject Then
                                        Set Pop = arInternal(Cnt)
                          Else
                                        Pop = arInternal(Cnt)
                          End If
                          ReDim Preserve arInternal(Cnt - 1)
                 End If
        End Function

        Public Function MembersExist
                MembersExist = False
                If UBound(arInternal) = 0 Then
                        If VarType(arInternal(0)) = vbObject Then
                                If arInternal(0) Is Not Nothing Then
                                        MembersExist = True
                                End If
                        Else
                                If Cstr(arInternal(0)) <> "" Then
                                        MembersExist = True
                                End If
                        End If
                Else
                        MembersExist = True
                End If
        End Function

        Public Sub Reset()
                 ReDim arInternal(0)
                 arInternal(0) = ""
        End Sub

        Private Sub Class_Initialize()
                 Reset
        End Sub

End Class
' -- End Class Stack --
' ******************************************************************
])

m4_define([VBS_B64DECODE],[
Class Encoder
    Private Base64 ' As string
    
    Function Base64Encode(inData)
        'rfc1521
        '2001 Antonin Foller, Motobit Software, http://Motobit.cz
        Dim cOut, sOut, I
        
        'For each group of 3 bytes
        For I = 1 To Len(inData) Step 3
            Dim nGroup, pOut, sGroup
    
            'Create one long from this 3 bytes.
            nGroup = &H10000 * Asc(Mid(inData, I, 1)) + _
                   &H100 * MyASC(Mid(inData, I + 1, 1)) + MyASC(Mid(inData, I + 2, 1))
    
            'Oct splits the long To 8 groups with 3 bits
            nGroup = Oct(nGroup)
    
            'Add leading zeros
            nGroup = String(8 - Len(nGroup), "0") & nGroup
    
            'Convert To base64
            pOut = Mid(Base64, CLng("&o" & Mid(nGroup, 1, 2)) + 1, 1) + _
                 Mid(Base64, CLng("&o" & Mid(nGroup, 3, 2)) + 1, 1) + _
                 Mid(Base64, CLng("&o" & Mid(nGroup, 5, 2)) + 1, 1) + _
                 Mid(Base64, CLng("&o" & Mid(nGroup, 7, 2)) + 1, 1)
    
            'Add the part To OutPut string
            sOut = sOut + pOut
    
            'Add a new line For Each 76 chars In dest (76*3/4 = 57)
            'If (I + 2) Mod 57 = 0 Then sOut = sOut + vbCrLf
        Next
        Select Case Len(inData) Mod 3
            Case 1: '8 bit final
                sOut = Left(sOut, Len(sOut) - 2) + "=="
            Case 2: '16 bit final
                sOut = Left(sOut, Len(sOut) - 1) + "="
        End Select
        Base64Encode = sOut
    End Function

    Function MyASC(OneChar)
        If OneChar = "" Then MyASC = 0 Else MyASC = Asc(OneChar)
    End Function

    Function Base64Decode(ByVal base64String)
        'rfc1521
        '1999 Antonin Foller, Motobit Software, http://Motobit.cz
        Dim dataLength, sOut, groupBegin
  
        'remove white spaces, If any
        base64String = Replace(base64String, vbCrLf, "")
        base64String = Replace(base64String, vbTab, "")
        base64String = Replace(base64String, " ", "")
  
        'The source must consists from groups with Len of 4 chars
        dataLength = Len(base64String)
        If dataLength Mod 4 <> 0 Then
            Err.Raise 1, "Base64Decode", "Bad Base64 string."
            Exit Function
        End If

  
        ' Now decode each group:
        For groupBegin = 1 To dataLength Step 4
            Dim numDataBytes, CharCounter, thisChar, thisData, nGroup, pOut
            ' Each data group encodes up To 3 actual bytes.
            numDataBytes = 3
            nGroup = 0

            For CharCounter = 0 To 3
                ' Convert each character into 6 bits of data, And add it To
                ' an integer For temporary storage.  If a character is a '=', there
                ' is one fewer data byte.  (There can only be a maximum of 2 '=' In
                ' the whole string.)
                
                thisChar = Mid(base64String, groupBegin + CharCounter, 1)

                If thisChar = "=" Then
                    numDataBytes = numDataBytes - 1
                    thisData = 0
                Else
                    thisData = InStr(1, Base64, thisChar, vbBinaryCompare) - 1
                End If
                If thisData = -1 Then
                    Err.Raise 2, "Base64Decode", "Bad character In Base64 string."
                    Exit Function
                End If

                nGroup = 64 * nGroup + thisData
            Next
    
            'Hex splits the long To 6 groups with 4 bits
            nGroup = Hex(nGroup)
    
            'Add leading zeros
            nGroup = String(6 - Len(nGroup), "0") & nGroup
    
            'Convert the 3 byte hex integer (6 chars) To 3 characters
            pOut = Chr(CByte("&H" & Mid(nGroup, 1, 2))) + _
                 Chr(CByte("&H" & Mid(nGroup, 3, 2))) + _
                 Chr(CByte("&H" & Mid(nGroup, 5, 2)))
            
            'add numDataBytes characters To out string
            sOut = sOut & Left(pOut, numDataBytes)
        Next
        
        Base64Decode = sOut
    End Function

    Private Sub Class_Initialize()
        Base64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    End Sub
End Class

Function Parse(ByRef Encoder, ByVal sdata)
    Dim RE : Set RE = New RegExp
    Dim ArOut(), cnt, out

    cnt = -1
    RE.Pattern = "(\d{8})"
    RE.Global = False
    out = out & "BLOCK:" & Len(sdata) & " Characters" & vbNewLine
    Set Matches = RE.Execute(sdata)
    While Matches.Count > 0
        For Each Match in Matches   ' Iterate Matches collection.
            cnt = cnt + 1
            ReDim preserve arout(cnt)
            arout(cnt) = Mid(sdata, 9, CLng(Match.Value))
            sdata = Mid(sdata, 9 + CLng(Match.Value))
            If Left(arout(cnt), 4) = "MDAw" Then
                out = out & Parse(Encoder, Encoder.Base64Decode(arout(cnt))) & vbNewLine
            Else
                out = out & arout(cnt) & vbNewLine
            End If

        Next
        Set Matches = RE.Execute(sdata)
    Wend
    Parse = out
End Function
])

m4_divert[]