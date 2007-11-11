unit CompanyEditFrm;

{$mode objfpc}{$H+}

interface

uses
  LResources, ContactEditFrm, Classes, Controls, StdCtrls, ExtCtrls;

type
  TCompanyEditForm = class(TContactEditForm)
    ContactLabel: TLabel;
    ContactComboBox: TComboBox;
  end;

implementation

uses
  ContactMVP;

initialization
  {$i CompanyEditFrm.lrs}
  TCompanyEditPresenter.RegisterLCLForm(TCompanyEditForm);

end.
