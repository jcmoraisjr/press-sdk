inherited PhoneEditForm: TPhoneEditForm
  Width = 196
  Height = 177
  Caption = 'Phone'
  PixelsPerInch = 96
  TextHeight = 13
  inherited ClientPanel: TPanel
    Width = 188
    Height = 109
    object NumberLabel: TLabel [0]
      Left = 16
      Top = 56
      Width = 40
      Height = 13
      Caption = 'Number:'
      FocusControl = NumberEdit
    end
    object PhoneTypeLabel: TLabel [1]
      Left = 16
      Top = 8
      Width = 58
      Height = 13
      Caption = 'PhoneType:'
      FocusControl = PhoneTypeComboBox
    end
    inherited LinePanel: TPanel
      Top = 107
      Width = 188
    end
    object NumberEdit: TEdit
      Left = 16
      Top = 72
      Width = 121
      Height = 21
      TabOrder = 2
      Text = 'NumberEdit'
    end
    object PhoneTypeComboBox: TComboBox
      Left = 16
      Top = 24
      Width = 121
      Height = 21
      ItemHeight = 13
      TabOrder = 1
      Text = 'PhoneTypeComboBox'
    end
  end
  inherited BottomPanel: TPanel
    Top = 109
    Width = 188
  end
end
