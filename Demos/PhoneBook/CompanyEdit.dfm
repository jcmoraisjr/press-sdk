inherited CompanyEditForm: TCompanyEditForm
  Caption = 'Company'
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
    object ContactLabel: TLabel [4]
      Left = 16
      Top = 48
      Width = 40
      Height = 13
      Caption = 'Contact:'
      FocusControl = ContactComboBox
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
    object ContactComboBox: TComboBox
      Left = 16
      Top = 64
      Width = 217
      Height = 21
      ItemHeight = 13
      TabOrder = 2
      Text = 'ContactComboBox'
    end
  end
end
