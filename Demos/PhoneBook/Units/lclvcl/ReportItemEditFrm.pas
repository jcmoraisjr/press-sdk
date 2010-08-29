unit ReportItemEditFrm;

interface

uses
  CustomEditFrm, Classes, Controls, StdCtrls, ExtCtrls, Buttons;

type
  TReportItemEditForm = class(TCustomEditForm)
    CaptionLabel: TLabel;
    CaptionEdit: TEdit;
    VisibleCheckBox: TCheckBox;
    DesignButton: TSpeedButton;
  end;

implementation

uses
  PressXCLBroker, ReportMVP;

{$ifdef fpc}{$R *.lfm}{$else}{$R *.DFM}{$endif}

initialization
  PressXCLForm(TReportItemEditPresenter, TReportItemEditForm);

end.
