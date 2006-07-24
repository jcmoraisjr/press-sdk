unit CompanyEdit;

interface

uses
  Classes, Controls, StdCtrls, ExtCtrls, Grids, ContactEdit;

type
  TCompanyEditForm = class(TContactEditForm)
    ContactLabel: TLabel;
    ContactComboBox: TComboBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CompanyEditForm: TCompanyEditForm;

implementation

{$R *.DFM}

end.
