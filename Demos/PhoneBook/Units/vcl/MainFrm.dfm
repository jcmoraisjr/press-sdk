object MainForm: TMainForm
  Left = 265
  Top = 133
  Width = 376
  Height = 333
  Caption = 'PhoneBook'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object QueryPanel: TPanel
    Left = 0
    Top = 0
    Width = 368
    Height = 73
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object NameQueryLabel: TLabel
      Left = 16
      Top = 16
      Width = 31
      Height = 13
      Caption = 'Name:'
      FocusControl = NameQueryEdit
    end
    object NameQueryEdit: TEdit
      Left = 16
      Top = 32
      Width = 217
      Height = 21
      TabOrder = 0
    end
    object QuerySpeedButtonPanel: TPanel
      Left = 288
      Top = 2
      Width = 80
      Height = 69
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 1
      object QuerySpeedButton: TSpeedButton
        Left = 8
        Top = 8
        Width = 65
        Height = 22
        Caption = 'Query'
      end
    end
    object BottomLinePanel: TPanel
      Left = 0
      Top = 71
      Width = 368
      Height = 2
      Align = alBottom
      BevelOuter = bvLowered
      TabOrder = 2
    end
    object TopLinePanel: TPanel
      Left = 0
      Top = 0
      Width = 368
      Height = 2
      Align = alTop
      BevelOuter = bvLowered
      TabOrder = 3
    end
  end
  object ItemsPanel: TPanel
    Left = 0
    Top = 73
    Width = 368
    Height = 214
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 8
    TabOrder = 1
    object ItemsStringGrid: TStringGrid
      Left = 8
      Top = 8
      Width = 352
      Height = 198
      Align = alClient
      DefaultColWidth = 32
      DefaultRowHeight = 16
      TabOrder = 0
    end
  end
  object MainMenu: TMainMenu
    Left = 256
    Top = 16
    object FileMenuGroup: TMenuItem
      Caption = '&File'
      object ConnectorMenuItem: TMenuItem
        Caption = 'Create DDL'
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object CloseMenuItem: TMenuItem
        Caption = '&Close'
      end
    end
  end
end
