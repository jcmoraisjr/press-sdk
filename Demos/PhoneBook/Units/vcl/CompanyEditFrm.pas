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
  PressVCLBroker, ContactMVP;

{$R *.DFM}

initialization
  PressVCLForm(TCompanyEditPresenter, TCompanyEditForm);

end.
