unit CustomEdit;

{$I PhoneBook.inc}

interface

uses
  {$IFDEF FPC}LResources,{$ENDIF}
  Classes, Controls, StdCtrls, ExtCtrls, Forms, Buttons;

type
  TCustomEditForm = class(TForm)
    ClientPanel: TPanel;
    BottomPanel: TPanel;
    OkButton: TButton;
    CancelButton: TButton;
    LinePanel: TPanel;
  end;

implementation

{$IFNDEF FPC}
{$R *.DFM}
{$ELSE}
initialization
  {$i CustomEdit.lrs}
{$ENDIF}

end.
