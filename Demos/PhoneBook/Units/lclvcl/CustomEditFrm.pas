unit CustomEditFrm;

interface

uses
  Forms, Classes, Controls, StdCtrls, ExtCtrls, Buttons;

type
  TCustomEditForm = class(TForm)
    ClientPanel: TPanel;
    BottomPanel: TPanel;
    OkButton: TButton;
    CancelButton: TButton;
    LinePanel: TPanel;
  end;

implementation

{$ifdef fpc}{$R *.lfm}{$else}{$R *.DFM}{$endif}

end.
