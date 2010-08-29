inherited ReportGroupEditForm: TReportGroupEditForm
  Caption = 'ReportGroupEditForm'
  ClientHeight = 308
  ClientWidth = 316
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited ClientPanel: TPanel
    Width = 316
    Height = 267
    inherited LinePanel: TPanel
      Top = 265
      Width = 316
    end
  end
  inherited BottomPanel: TPanel
    Top = 267
    Width = 316
  end
  object ReportsGroupBox: TGroupBox
    Left = 16
    Top = 16
    Width = 281
    Height = 233
    Caption = 'Reports:'
    TabOrder = 2
    object ReportsStringGrid: TStringGrid
      Left = 16
      Top = 24
      Width = 249
      Height = 193
      DefaultColWidth = 32
      DefaultRowHeight = 16
      TabOrder = 0
    end
  end
end
