unit CityEditFrm;

interface

uses
  CustomEditFrm, Classes, Controls, StdCtrls, ExtCtrls;

type
  TCityEditForm = class(TCustomEditForm)
    NameLabel: TLabel;
    NameEdit: TEdit;
    StateLabel: TLabel;
    StateEdit: TEdit;
  end;

implementation

uses
  PressXCLBroker, ContactMVP;

{$ifdef fpc}{$R *.lfm}{$else}{$R *.DFM}{$endif}

initialization
  PressXCLForm(TCityEditPresenter, TCityEditForm);

end.
