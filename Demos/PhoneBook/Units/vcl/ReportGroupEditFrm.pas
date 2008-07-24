unit ReportGroupEditFrm;

interface

uses
  CustomEditFrm, Classes, Controls, StdCtrls, ExtCtrls, Grids;

type
  TReportGroupEditForm = class(TCustomEditForm)
    ReportsGroupBox: TGroupBox;
    ReportsStringGrid: TStringGrid;
  end;

implementation

uses
  PressVCLBroker, ReportMVP;

{$R *.DFM}

initialization
  PressVCLForm(TReportGroupEditPresenter, TReportGroupEditForm);

end.
