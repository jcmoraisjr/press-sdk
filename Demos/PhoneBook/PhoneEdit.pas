unit PhoneEdit;

{$I PhoneBook.inc}

interface

uses
  {$IFDEF FPC}LResources,{$ENDIF}
  Classes, Controls, StdCtrls, ExtCtrls, CustomEdit;

type
  TPhoneEditForm = class(TCustomEditForm)
    NumberLabel: TLabel;
    NumberEdit: TEdit;
    PhoneTypeLabel: TLabel;
    PhoneTypeComboBox: TComboBox;
  end;

implementation

{$IFNDEF FPC}
{$R *.DFM}
{$ELSE}
initialization
  {$i PhoneEdit.lrs}
{$ENDIF}

end.
