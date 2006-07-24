unit PhoneEdit;

interface

uses
  Classes, Controls, StdCtrls, ExtCtrls, CustomEdit;

type
  TPhoneEditForm = class(TCustomEditForm)
    NumberLabel: TLabel;
    NumberEdit: TEdit;
    PhoneTypeLabel: TLabel;
    PhoneTypeComboBox: TComboBox;
  end;

implementation

{$R *.DFM}

end.
