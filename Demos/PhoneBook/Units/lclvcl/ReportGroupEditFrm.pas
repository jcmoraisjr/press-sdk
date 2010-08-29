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
  PressXCLBroker, ReportMVP;

{$ifdef fpc}{$R *.lfm}{$else}{$R *.DFM}{$endif}

initialization
  PressXCLForm(TReportGroupEditPresenter, TReportGroupEditForm);

end.
