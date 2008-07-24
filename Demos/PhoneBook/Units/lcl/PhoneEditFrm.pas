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
  PressLCLBroker, ContactMVP;

initialization
  {$i PhoneEditFrm.lrs}
  PressLCLForm(TPhoneEditPresenter, TPhoneEditForm);

end.
