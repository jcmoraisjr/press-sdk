inherited ContactEditForm: TContactEditForm
  Left = 241
  Top = 175
  Width = 462
  Height = 250
  Caption = 'ContactEditForm'
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited ClientPanel: TPanel
    Width = 454
    Height = 182
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
      Top = 180
      Width = 454
    end
    object NameEdit: TEdit
      Left = 16
      Top = 24
      Width = 217
      Height = 21
      TabOrder = 1
      Text = 'NameEdit'
    end
    object StreetEdit: TEdit
      Left = 16
      Top = 64
      Width = 217
      Height = 21
      TabOrder = 2
      Text = 'StreetEdit'
    end
    object ZipEdit: TEdit
      Left = 16
      Top = 104
      Width = 65
      Height = 21
      TabOrder = 3
      Text = 'ZipEdit'
    end
    object CityComboBox: TComboBox
      Left = 88
      Top = 104
      Width = 145
      Height = 21
      ItemHeight = 13
      TabOrder = 4
      Text = 'CityComboBox'
    end
    object PhonesGroupBox: TGroupBox
      Left = 248
      Top = 16
      Width = 185
      Height = 145
      Caption = 'Phones'
      TabOrder = 5
      object PhonesStringGrid: TStringGrid
        Left = 16
        Top = 24
        Width = 153
        Height = 105
        TabOrder = 0
      end
    end
  end
  inherited BottomPanel: TPanel
    Top = 182
    Width = 454
  end
end
