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
    BottomLinePanel: TPanel;
    MainMenu: TMainMenu;
    FileMenuGroup: TMenuItem;
    ConnectorMenuItem: TMenuItem;
    N1: TMenuItem;
    CloseMenuItem: TMenuItem;
    TopLinePanel: TPanel;
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
