unit CompanyEditFrm;

interface

uses
  ContactEditFrm, Classes, Controls, StdCtrls, ExtCtrls, Grids;

type
  TCompanyEditForm = class(TContactEditForm)
    ContactLabel: TLabel;
    ContactComboBox: TComboBox;
  end;

implementation

uses
  PressXCLBroker, ContactMVP;

{$ifdef fpc}{$R *.lfm}{$else}{$R *.DFM}{$endif}

initialization
  PressXCLForm(TCompanyEditPresenter, TCompanyEditForm);

end.
