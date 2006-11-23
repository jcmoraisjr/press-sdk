unit CompanyEdit;

{$I PhoneBook.inc}

interface

uses
  {$IFDEF FPC}LResources,{$ENDIF}
  Classes, Controls, StdCtrls, ExtCtrls, Grids, ContactEdit;

type
  TCompanyEditForm = class(TContactEditForm)
    ContactLabel: TLabel;
    ContactComboBox: TComboBox;
  end;

var
  CompanyEditForm: TCompanyEditForm;

implementation

{$IFNDEF FPC}
{$R *.DFM}
{$ELSE}
initialization
  {$i CompanyEdit.lrs}
{$ENDIF}

end.
