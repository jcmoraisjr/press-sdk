inherited ReportItemEditForm: TReportItemEditForm
  Caption = 'ReportItemEditForm'
  ClientHeight = 148
  ClientWidth = 279
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited ClientPanel: TPanel
    Width = 279
    Height = 107
    object CaptionLabel: TLabel [0]
      Left = 24
      Top = 16
      Width = 39
      Height = 13
      Caption = 'Caption:'
      FocusControl = CaptionEdit
    end
    object DesignButton: TSpeedButton [1]
      Left = 152
      Top = 64
      Width = 97
      Height = 25
      Caption = 'Design'
    end
    inherited LinePanel: TPanel
      Top = 105
      Width = 279
      TabOrder = 2
    end
    object CaptionEdit: TEdit
      Left = 24
      Top = 32
      Width = 225
      Height = 21
      TabOrder = 0
    end
    object VisibleCheckBox: TCheckBox
      Left = 24
      Top = 68
      Width = 113
      Height = 17
      Caption = 'Visible'
      TabOrder = 1
    end
  end
  inherited BottomPanel: TPanel
    Top = 107
    Width = 279
  end
end
