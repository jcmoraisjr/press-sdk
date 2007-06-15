unit ReportGroupEdit;

{$I PhoneBook.inc}

interface

uses
  Classes, Controls, StdCtrls, ExtCtrls, Grids, CustomEdit;

type
  TReportGroupEditForm = class(TCustomEditForm)
    ReportsGroupBox: TGroupBox;
    ReportsStringGrid: TStringGrid;
  end;

implementation

{$R *.DFM}

end.
