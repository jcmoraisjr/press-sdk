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
  ContactMVP;

{$R *.DFM}

initialization
  TPhoneEditPresenter.RegisterVCLForm(TPhoneEditForm);

end.
