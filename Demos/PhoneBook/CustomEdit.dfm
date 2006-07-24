object CustomEditForm: TCustomEditForm
  Left = 250
  Top = 143
  Width = 305
  Height = 223
  Caption = 'CustomEditForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ClientPanel: TPanel
    Left = 0
    Top = 0
    Width = 297
    Height = 155
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object LinePanel: TPanel
      Left = 0
      Top = 153
      Width = 297
      Height = 2
      Align = alBottom
      BevelOuter = bvLowered
      TabOrder = 0
    end
  end
  object BottomPanel: TPanel
    Left = 0
    Top = 155
    Width = 297
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object OkButton: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = 'OK'
      TabOrder = 0
    end
    object CancelButton: TButton
      Left = 88
      Top = 8
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 1
    end
  end
end
