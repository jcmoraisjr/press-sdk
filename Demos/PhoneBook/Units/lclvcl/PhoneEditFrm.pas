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
  PressXCLBroker, ContactMVP;

{$ifdef fpc}{$R *.lfm}{$else}{$R *.DFM}{$endif}

initialization
  PressXCLForm(TPhoneEditPresenter, TPhoneEditForm);

end.
