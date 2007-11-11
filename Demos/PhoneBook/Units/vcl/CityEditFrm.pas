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
  ContactMVP;

{$R *.DFM}

initialization
  TCityEditPresenter.RegisterVCLForm(TCityEditForm);

end.
