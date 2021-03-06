VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CIniText"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
'--------------------------------------------------------------------------------
'    Component  : CiniText
'
'    Description: iniText Class
'
'    Author   : xrLin
'--------------------------------------------------------------------------------

Option Explicit

    Private Type iniSection
        name As String
        text As String
    End Type
    
    Private tSection() As iniSection
    Private iSecCount As Long
    Private m_iniString As String
    Public CompareMethod As VbCompareMethod
    'Private m_Text As CString
    
    Private Const cstExcapeBrace As String = "L" & vbNullChar & "eFT" & vbNullChar & "B" & vbNullChar & "raCe" & vbNullChar
    Private Const cstEscapeCRLF As String = vbBack & "CRLF" & vbBack
Public Sub Clear()
    iSecCount = 0
    
End Sub
        

Private Function ToString() As String
    Dim l As Long
    For l = 1 To iSecCount
        If tSection(l).name = "" Then
            ToString = ToString & "[NoNameSection" & l & "]" & vbCrLf
        Else
            ToString = ToString & "[" & tSection(l).name & "]" & vbCrLf
        End If
        ToString = ToString & tSection(l).text
    Next

End Function

Private Function iSectionIndex(ByRef sName As String) As Long

    Dim iPoint As Long
    
    For iPoint = 1 To iSecCount
    
        If StrComp(tSection(iPoint).name, sName, CompareMethod) = 0 Then
            iSectionIndex = iPoint
            Exit For
        End If
        
    Next
    
End Function

Public Sub DeleteSection(ByRef Section As String)

    Dim iPoint As Long
    Dim iDelPoint As Long
    Dim iEndPoint As Long
    
    'Section = Trim(Section)

    iDelPoint = iSectionIndex(Section)

    If iDelPoint < 1 Then Exit Sub
    iEndPoint = iSecCount - 1
    
    For iPoint = iDelPoint To iEndPoint
        tSection(iPoint).name = tSection(iPoint + 1).name
        tSection(iPoint).text = tSection(iPoint + 1).text
    Next
    
    iSecCount = iSecCount - 1
    
    If iSecCount > 0 Then
        ReDim Preserve tSection(1 To iSecCount) As iniSection
    Else
        Erase tSection
    End If

End Sub
Public Sub DeleteSetting(ByRef sSection As String, ByVal sKeyName As String)
    Dim iThis As Long
    'sSection = Trim(sSection)
    'sKeyName = Trim(sKeyName)
    iThis = iSectionIndex(sSection)
    
    If iThis < 1 Then Exit Sub
    
    Dim sSecText As String
    Dim iStart As Long, iEnd As Long
    Dim iLenSec As Long
    
    sSecText = tSection(iThis).text
    iLenSec = Len(sSecText)
    
    sKeyName = fliterEqual(sKeyName) & "="
    
    iStart = InStr(1, sSecText, sKeyName, CompareMethod)

    If iStart < 1 Then Exit Sub

        'iStart = iStart + Len(sKeyName)

        If iStart + Len(sKeyName) >= iLenSec Then
            iEnd = iLenSec
        Else
            iEnd = InStr(iStart + Len(sKeyName), sSecText, vbCrLf, CompareMethod)
            If iEnd < 0 Then
                iEnd = iLenSec
            Else
                iEnd = iEnd + Len(vbCrLf) - 1
            End If
        End If
        
        sSecText = Left$(sSecText, iStart - 1) & Right$(sSecText, iLenSec - iEnd)
        tSection(iThis).text = sSecText
        
End Sub
Public Sub SaveSetting(ByRef sSection As String, ByVal sKeyName As String, ByVal sValue As String)
    
    Dim iThis As Long
    'sSection = Trim(sSection)
    'sKeyName = Trim(sKeyName)
    iThis = iSectionIndex(sSection)
    sKeyName = fliterEqual(sKeyName)
    sValue = FilterCRLFIn(sValue)
    If iThis < 1 Then
        Call SaveSection(sSection, sKeyName & "=" & sValue & vbCrLf)
        Exit Sub
    End If
    
    DeleteSetting sSection, sKeyName
    Do While Right$(tSection(iThis).text, 2) = vbCrLf
        tSection(iThis).text = Left$(tSection(iThis).text, Len(tSection(iThis).text) - 2)
    Loop
    tSection(iThis).text = tSection(iThis).text & vbCrLf & sKeyName & "=" & sValue & vbCrLf
  
End Sub
Public Function GetSetting(ByRef sSection As String, ByVal sKeyName As String) As String

    Dim iThis As Long
    'sSection = Trim(sSection)
    'sKeyName = Trim(sKeyName)
    iThis = iSectionIndex(sSection)
    
    If iThis < 1 Then Exit Function
    
    Dim sSecText As String
    Dim iStart As Long, iEnd As Long
    Dim iLenSec As Long
    
    sSecText = tSection(iThis).text
    iLenSec = Len(sSecText)
    
    sKeyName = fliterEqual(sKeyName) & "="
    
    iStart = InStr(1, sSecText, sKeyName, CompareMethod)

    If iStart < 1 Then Exit Function
    
    iStart = iStart + Len(sKeyName)
    If iStart >= iLenSec Then Exit Function

    iEnd = InStr(iStart, sSecText, vbCrLf, CompareMethod)
    If iEnd < 0 Then
        iEnd = iLenSec
    Else
        iEnd = iEnd - 1
    End If
    
    GetSetting = FilterCRLFOut(Mid$(sSecText, iStart, iEnd - iStart + 1))
    'FilterCRLFOut GetSetting
    'Debug.Print GetSetting

End Function

Public Function GetSectionText(ByRef Section As String) As String

    Dim iThis As Long
    
    'Section = Trim(Section)
    iThis = iSectionIndex(Section)
    If iThis < 1 Then Exit Function
    GetSectionText = tSection(iThis).text

End Function

Public Sub SaveSection(ByRef Section As String, ByRef sSecText As String)
    
    Dim iThis As Long
    'Section = Trim(Section)
    If Section = "" Then Section = "NonameSection"
    
    iThis = iSectionIndex(Section)
    If iThis < 1 Then
        iSecCount = iSecCount + 1
        ReDim Preserve tSection(1 To iSecCount) As iniSection
        tSection(iSecCount).name = Section
        'tSection(iSecCount).Text = ""
        iThis = iSecCount
    End If
        If Right$(sSecText, 2) = vbCrLf Then
        tSection(iThis).text = sSecText
        Else
        tSection(iThis).text = sSecText & vbCrLf
        End If


End Sub

Public Property Get iniString() As String

    iniString = ToString

End Property


'使用open语句打开文件
Public Property Let iniString(ByRef Value As String)

    m_iniString = Value
    
    On Error GoTo FileReadErr


    Dim strArrLine() As String
    Dim strLine As String
    Dim i As Long
    Dim lStart As Long
    Dim lEnd As Long
    Dim sName As String
   ' Dim bText() As Byte
   ' Dim sText As String
        
    strArrLine = Split(m_iniString, vbCrLf)
    lStart = LBound(strArrLine)
    lEnd = UBound(strArrLine)
    
    iSecCount = 0
    Erase tSection

    For i = lStart To lEnd
        strLine = strArrLine(i)
        sName = Trim$(strLine)
        'strLine = Trim(strLine)

        If isSectionLine(sName) Then
            iSecCount = iSecCount + 1
            ReDim Preserve tSection(1 To iSecCount) As iniSection
            sName = Mid$(sName, 2, Len(sName) - 2)
            If sName = "" Then sName = "NoNameSection" & iSecCount
            tSection(iSecCount).name = sName ' Mid$(strLine, 2, Len(strLine) - 2)
        Else

            If iSecCount < 1 Then
                iSecCount = iSecCount + 1
                ReDim Preserve tSection(1 To iSecCount) As iniSection
                tSection(iSecCount).name = "DefaultSection"
                tSection(iSecCount).text = strLine
            Else
                tSection(iSecCount).text = tSection(iSecCount).text & strLine & vbCrLf
            End If

        End If

    Next
    
    Exit Property
FileReadErr:
    'm_Text = ""
    'Err.Raise Err.Number, "CLini.File", Err.Description

End Property


Private Sub Class_Initialize()
    CompareMethod = vbTextCompare    'vbBinaryCompare
End Sub

Private Function fliterEqual(ByRef strText As String) As String
    fliterEqual = Replace(strText, "=", "_")
End Function


Private Function isSectionLine(ByRef strText As String) As Boolean
    If InStrRev(strText, "[") <> 1 Then Exit Function
    If InStr(strText, "]") <> Len(strText) Then Exit Function
    isSectionLine = True
End Function

Private Function FilterCRLFIn(ByRef StringValue As String) As String
        FilterCRLFIn = Replace$(StringValue, vbCrLf, cstEscapeCRLF)
End Function

Private Function FilterCRLFOut(ByRef StringValue As String) As String
        FilterCRLFOut = Replace$(StringValue, cstEscapeCRLF, vbCrLf)
End Function
        

