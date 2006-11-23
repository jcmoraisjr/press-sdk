unit CityEdit;

{$I PhoneBook.inc}

interface

uses
  {$IFDEF FPC}LResources,{$ENDIF}
  Classes, Controls, StdCtrls, ExtCtrls, CustomEdit;

type
  TCityEditForm = class(TCustomEditForm)
    NameLabel: TLabel;
    NameEdit: TEdit;
    StateLabel: TLabel;
    StateEdit: TEdit;
  end;

implementation

{$IFNDEF FPC}
{$R *.DFM}
{$ELSE}
initialization
  {$i CityEdit.lrs}
{$ENDIF}

end.
