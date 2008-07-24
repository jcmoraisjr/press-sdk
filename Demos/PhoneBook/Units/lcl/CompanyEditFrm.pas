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
  PressLCLBroker, ContactMVP;

initialization
  {$i CompanyEditFrm.lrs}
  PressLCLForm(TCompanyEditPresenter, TCompanyEditForm);

end.
