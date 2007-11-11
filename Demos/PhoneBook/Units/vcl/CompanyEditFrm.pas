unit CompanyEditFrm;

interface

uses
  ContactEditFrm, Classes, Controls, StdCtrls, ExtCtrls, Grids;

type
  TCompanyEditForm = class(TContactEditForm)
    ContactLabel: TLabel;
    ContactComboBox: TComboBox;
  end;

implementation

uses
  ContactMVP;

{$R *.DFM}

initialization
  TCompanyEditPresenter.RegisterVCLForm(TCompanyEditForm);

end.
