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
  PressVCLBroker, ReportMVP;

{$R *.DFM}

initialization
  PressVCLForm(TReportItemEditPresenter, TReportItemEditForm);

end.
