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
  ContactMVP;

{$R *.DFM}

initialization
  TPersonEditPresenter.RegisterVCLForm(TPersonEditForm);

end.
