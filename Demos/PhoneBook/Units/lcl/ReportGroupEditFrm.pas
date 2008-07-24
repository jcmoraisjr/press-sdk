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
  PressLCLBroker, ReportMVP;

initialization
  {$i ReportGroupEditFrm.lrs}
  PressLCLForm(TReportGroupEditPresenter, TReportGroupEditForm);

end.
