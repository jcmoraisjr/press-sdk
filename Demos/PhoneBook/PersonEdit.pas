unit PersonEdit;

{$I PhoneBook.inc}

interface

uses
  {$IFDEF FPC}LResources,{$ENDIF}
  Classes, Controls, StdCtrls, ExtCtrls, Grids, ContactEdit;

type
  TPersonEditForm = class(TContactEditForm)
    NickNameLabel: TLabel;
    NickNameEdit: TEdit;
  end;

implementation

{$IFNDEF FPC}
{$R *.DFM}
{$ELSE}
initialization
  {$i PersonEdit.lrs}
{$ENDIF}

end.
