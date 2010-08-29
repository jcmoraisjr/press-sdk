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
  PressXCLBroker, ContactMVP;

{$ifdef fpc}{$R *.lfm}{$else}{$R *.DFM}{$endif}

initialization
  PressXCLForm(TPersonEditPresenter, TPersonEditForm);

end.
