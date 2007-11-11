unit CustomEditFrm;

{$mode objfpc}{$H+}

interface

uses
  LResources, Forms, Classes, Controls, StdCtrls, ExtCtrls, Buttons;

type
  TCustomEditForm = class(TForm)
    ClientPanel: TPanel;
    BottomPanel: TPanel;
    OkButton: TButton;
    CancelButton: TButton;
    LinePanel: TPanel;
  end;

implementation

initialization
  {$i CustomEditFrm.lrs}

end.
