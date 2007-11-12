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
  ContactMVP;

initialization
  {$i PersonEditFrm.lrs}
  TPersonEditPresenter.RegisterLCLForm(TPersonEditForm);

end.
