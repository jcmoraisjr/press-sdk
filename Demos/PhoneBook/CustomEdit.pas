unit CustomEdit;

interface

uses
  Classes, Controls, StdCtrls, ExtCtrls, Forms;

type
  TCustomEditForm = class(TForm)
    ClientPanel: TPanel;
    BottomPanel: TPanel;
    OkButton: TButton;
    CancelButton: TButton;
    LinePanel: TPanel;
  end;

implementation

{$R *.DFM}

end.
