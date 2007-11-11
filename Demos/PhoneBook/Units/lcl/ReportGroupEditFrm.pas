unit ReportGroupEditFrm;

{$mode objfpc}{$H+}

interface

uses
  LResources, CustomEditFrm, Classes, Controls, StdCtrls, ExtCtrls, Grids;

type
  TReportGroupEditForm = class(TCustomEditForm)
    ReportsGroupBox: TGroupBox;
    ReportsStringGrid: TStringGrid;
  end;

implementation

uses
  ReportMVP;

initialization
  {$i ReportGroupEditFrm.lrs}
  TReportGroupEditPresenter.RegisterVCLForm(TReportGroupEditForm);

end.
