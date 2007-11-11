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
  ReportMVP;

{$R *.DFM}

initialization
  TReportGroupEditPresenter.RegisterVCLForm(TReportGroupEditForm);

end.
