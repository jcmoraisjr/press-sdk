unit PhoneEditFrm;

interface

uses
  CustomEditFrm, Classes, Controls, StdCtrls, ExtCtrls;

type
  TPhoneEditForm = class(TCustomEditForm)
    NumberLabel: TLabel;
    NumberEdit: TEdit;
    PhoneTypeLabel: TLabel;
    PhoneTypeComboBox: TComboBox;
  end;

implementation

uses
  PressVCLBroker, ContactMVP;

{$R *.DFM}

initialization
  PressVCLForm(TPhoneEditPresenter, TPhoneEditForm);

end.
