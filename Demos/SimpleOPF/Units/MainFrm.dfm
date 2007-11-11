object MainForm: TMainForm
  Left = 228
  Top = 119
  BorderStyle = bsDialog
  Caption = 'SimpleOPF'
  ClientHeight = 338
  ClientWidth = 636
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object NameLabel: TLabel
    Left = 8
    Top = 40
    Width = 31
    Height = 13
    Caption = 'Name:'
    FocusControl = NameEdit
  end
  object IDLabel: TLabel
    Left = 8
    Top = 184
    Width = 14
    Height = 13
    Caption = 'ID:'
  end
  object WhereLabel: TLabel
    Left = 8
    Top = 112
    Width = 35
    Height = 13
    Caption = 'Where:'
    FocusControl = WhereEdit
  end
  object GenerateDBMetaButton: TButton
    Left = 8
    Top = 8
    Width = 105
    Height = 25
    Caption = 'Generate DB Meta'
    TabOrder = 0
    OnClick = GenerateDBMetaButtonClick
  end
  object IncludeNameButton: TButton
    Left = 8
    Top = 80
    Width = 105
    Height = 25
    Caption = 'Include name'
    TabOrder = 1
    OnClick = IncludeNameButtonClick
  end
  object NameEdit: TEdit
    Left = 8
    Top = 56
    Width = 105
    Height = 21
    TabOrder = 2
  end
  object ListNamesButton: TButton
    Left = 8
    Top = 152
    Width = 105
    Height = 25
    Caption = 'List names'
    TabOrder = 3
    OnClick = ListNamesButtonClick
  end
  object OIDEdit: TEdit
    Left = 8
    Top = 200
    Width = 105
    Height = 21
    TabOrder = 4
  end
  object RemoveNameButton: TButton
    Left = 8
    Top = 224
    Width = 105
    Height = 25
    Caption = 'Remove name'
    TabOrder = 5
    OnClick = RemoveNameButtonClick
  end
  object ClearButton: TButton
    Left = 8
    Top = 256
    Width = 105
    Height = 25
    Caption = 'Clear output'
    TabOrder = 6
    OnClick = ClearButtonClick
  end
  object OutputMemo: TMemo
    Left = 120
    Top = 8
    Width = 505
    Height = 321
    ScrollBars = ssVertical
    TabOrder = 7
  end
  object CloseButton: TButton
    Left = 8
    Top = 304
    Width = 105
    Height = 25
    Caption = 'Close'
    TabOrder = 8
    OnClick = CloseButtonClick
  end
  object WhereEdit: TEdit
    Left = 8
    Top = 128
    Width = 105
    Height = 21
    TabOrder = 9
  end
end
