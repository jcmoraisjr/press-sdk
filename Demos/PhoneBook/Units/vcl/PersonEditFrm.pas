unit PersonEditFrm;

interface

uses
  ContactEditFrm, Classes, Controls, StdCtrls, ExtCtrls, Grids;

type
  TPersonEditForm = class(TContactEditForm)
    NickNameLabel: TLabel;
    NickNameEdit: TEdit;
  end;

implementation

uses
  PressVCLBroker, ContactMVP;

{$R *.DFM}

initialization
  PressVCLForm(TPersonEditPresenter, TPersonEditForm);

end.
