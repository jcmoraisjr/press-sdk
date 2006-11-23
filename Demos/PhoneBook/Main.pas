unit Main;

{$I PhoneBook.inc}

interface

uses
  {$IFDEF FPC}LResources,{$ENDIF}
  Classes, Controls, StdCtrls, ExtCtrls, Menus, Buttons, Grids, Forms;

type
  TMainForm = class(TForm)
    QueryPanel: TPanel;
    ItemsPanel: TPanel;
    NameQueryEdit: TEdit;
    NameQueryLabel: TLabel;
    QuerySpeedButtonPanel: TPanel;
    QuerySpeedButton: TSpeedButton;
    ItemsStringGrid: TStringGrid;
    LinePanel: TPanel;
  end;

var
  MainForm: TMainForm;

implementation

{$IFNDEF FPC}
{$R *.DFM}
{$ELSE}
initialization
  {$i Main.lrs}
{$ENDIF}

end.
