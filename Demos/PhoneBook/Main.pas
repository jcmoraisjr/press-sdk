unit Main;

interface

uses
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

{$R *.DFM}

end.
