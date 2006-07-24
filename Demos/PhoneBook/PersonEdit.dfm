inherited PersonEditForm: TPersonEditForm
  Caption = 'Person'
  PixelsPerInch = 96
  TextHeight = 13
  inherited ClientPanel: TPanel
    inherited StreetLabel: TLabel
      Top = 88
    end
    inherited ZipLabel: TLabel
      Top = 128
    end
    inherited CityLabel: TLabel
      Top = 128
    end
    object NickNameLabel: TLabel [4]
      Left = 16
      Top = 48
      Width = 53
      Height = 13
      Caption = 'NickName:'
      FocusControl = NickNameEdit
    end
    inherited StreetEdit: TEdit
      Top = 104
      TabOrder = 3
    end
    inherited ZipEdit: TEdit
      Top = 144
      TabOrder = 4
    end
    inherited CityComboBox: TComboBox
      Top = 144
      TabOrder = 5
    end
    inherited PhonesGroupBox: TGroupBox
      TabOrder = 6
    end
    object NickNameEdit: TEdit
      Left = 16
      Top = 64
      Width = 217
      Height = 21
      TabOrder = 2
      Text = 'NickNameEdit'
    end
  end
end
