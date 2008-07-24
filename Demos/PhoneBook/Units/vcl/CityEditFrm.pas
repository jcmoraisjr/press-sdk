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
  PressVCLBroker, ContactMVP;

{$R *.DFM}

initialization
  PressVCLForm(TCityEditPresenter, TCityEditForm);

end.
