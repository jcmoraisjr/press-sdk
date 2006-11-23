unit ContactEdit;

{$I PhoneBook.inc}

interface

uses
  {$IFDEF FPC}LResources,{$ENDIF}
  Classes, Controls, StdCtrls, ExtCtrls, CustomEdit, Grids;

type
  TContactEditForm = class(TCustomEditForm)
    NameLabel: TLabel;
    NameEdit: TEdit;
    StreetLabel: TLabel;
    StreetEdit: TEdit;
    ZipEdit: TEdit;
    ZipLabel: TLabel;
    CityLabel: TLabel;
    CityComboBox: TComboBox;
    PhonesGroupBox: TGroupBox;
    PhonesStringGrid: TStringGrid;
  end;

implementation

{$IFNDEF FPC}
{$R *.DFM}
{$ELSE}
initialization
  {$i ContactEdit.lrs}
{$ENDIF}

end.
