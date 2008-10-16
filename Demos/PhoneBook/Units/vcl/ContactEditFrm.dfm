inherited ContactEditForm: TContactEditForm
  Left = 241
  Top = 175
  Caption = 'ContactEditForm'
  ClientHeight = 307
  ClientWidth = 454
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited ClientPanel: TPanel
    Width = 454
    Height = 266
    object NameLabel: TLabel [0]
      Left = 16
      Top = 8
      Width = 31
      Height = 13
      Caption = 'Name:'
      FocusControl = NameEdit
    end
    object StreetLabel: TLabel [1]
      Left = 16
      Top = 48
      Width = 31
      Height = 13
      Caption = 'Street:'
      FocusControl = StreetEdit
    end
    object ZipLabel: TLabel [2]
      Left = 16
      Top = 88
      Width = 18
      Height = 13
      Caption = 'Zip:'
      FocusControl = ZipEdit
    end
    object CityLabel: TLabel [3]
      Left = 88
      Top = 88
      Width = 20
      Height = 13
      Caption = 'City:'
      FocusControl = CityComboBox
    end
    inherited LinePanel: TPanel
      Top = 264
      Width = 454
    end
    object NameEdit: TEdit
      Left = 16
      Top = 24
      Width = 217
      Height = 21
      TabOrder = 1
    end
    object StreetEdit: TEdit
      Left = 16
      Top = 64
      Width = 217
      Height = 21
      TabOrder = 2
    end
    object ZipEdit: TEdit
      Left = 16
      Top = 104
      Width = 65
      Height = 21
      TabOrder = 3
    end
    object CityComboBox: TComboBox
      Left = 88
      Top = 104
      Width = 145
      Height = 21
      ItemHeight = 13
      TabOrder = 4
    end
    object PhonesGroupBox: TGroupBox
      Left = 248
      Top = 16
      Width = 185
      Height = 225
      Caption = 'Phones'
      TabOrder = 5
      object NumberLabel: TLabel
        Left = 16
        Top = 176
        Width = 40
        Height = 13
        Caption = 'Number:'
        FocusControl = NumberEdit
      end
      object PhoneTypeLabel: TLabel
        Left = 16
        Top = 136
        Width = 58
        Height = 13
        Caption = 'PhoneType:'
        FocusControl = PhoneTypeComboBox
      end
      object PhonesStringGrid: TStringGrid
        Left = 16
        Top = 24
        Width = 153
        Height = 105
        DefaultColWidth = 32
        DefaultRowHeight = 16
        TabOrder = 0
      end
      object NumberEdit: TEdit
        Left = 16
        Top = 192
        Width = 121
        Height = 21
        TabOrder = 1
      end
      object PhoneTypeComboBox: TComboBox
        Left = 16
        Top = 152
        Width = 121
        Height = 21
        ItemHeight = 13
        TabOrder = 2
      end
    end
  end
  inherited BottomPanel: TPanel
    Top = 266
    Width = 454
  end
end
