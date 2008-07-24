unit PersonEditFrm;

{$mode objfpc}{$H+}

interface

uses
  LResources, ContactEditFrm, Classes, Controls, StdCtrls, ExtCtrls;

type
  TPersonEditForm = class(TContactEditForm)
    NickNameLabel: TLabel;
    NickNameEdit: TEdit;
  end;

implementation

uses
  PressLCLBroker, ContactMVP;

initialization
  {$i PersonEditFrm.lrs}
  PressLCLForm(TPersonEditPresenter, TPersonEditForm);

end.
