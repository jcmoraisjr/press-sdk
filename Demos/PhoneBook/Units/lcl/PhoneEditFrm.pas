unit PhoneEditFrm;

{$mode objfpc}{$H+}

interface

uses
  LResources, CustomEditFrm, Classes, Controls, StdCtrls, ExtCtrls;

type
  TPhoneEditForm = class(TCustomEditForm)
    NumberLabel: TLabel;
    NumberEdit: TEdit;
    PhoneTypeLabel: TLabel;
    PhoneTypeComboBox: TComboBox;
  end;

implementation

uses
  ContactMVP;

initialization
  {$i PhoneEditFrm.lrs}
  TPhoneEditPresenter.RegisterVCLForm(TPhoneEditForm);

end.
