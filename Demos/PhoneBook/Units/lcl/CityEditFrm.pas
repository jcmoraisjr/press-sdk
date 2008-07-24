unit CityEditFrm;

{$mode objfpc}{$H+}

interface

uses
  LResources, CustomEditFrm, Classes, Controls, StdCtrls, ExtCtrls;

type
  TCityEditForm = class(TCustomEditForm)
    NameLabel: TLabel;
    NameEdit: TEdit;
    StateLabel: TLabel;
    StateEdit: TEdit;
  end;

implementation

uses
  PressLCLBroker, ContactMVP;

initialization
  {$i CityEditFrm.lrs}
  PressLCLForm(TCityEditPresenter, TCityEditForm);

end.
