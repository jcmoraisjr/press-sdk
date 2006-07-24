unit ContactEdit;

interface

uses
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

{$R *.DFM}

end.
