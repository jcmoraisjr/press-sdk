unit ReportItemEditFrm;

{$mode objfpc}{$H+}

interface

uses
  LResources, CustomEditFrm, Classes, Controls, StdCtrls, ExtCtrls, Buttons;

type
  TReportItemEditForm = class(TCustomEditForm)
    CaptionLabel: TLabel;
    CaptionEdit: TEdit;
    VisibleCheckBox: TCheckBox;
    DesignButton: TSpeedButton;
  end;

implementation

uses
  ReportMVP;

initialization
  {$i ReportItemEditFrm.lrs}
  TReportItemEditPresenter.RegisterLCLForm(TReportItemEditForm);

end.
