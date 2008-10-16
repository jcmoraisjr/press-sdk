unit ContactEditFrm;

interface

uses
  CustomEditFrm, Classes, Controls, StdCtrls, ExtCtrls, Grids;

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
    NumberLabel: TLabel;
    PhoneTypeLabel: TLabel;
    NumberEdit: TEdit;
    PhoneTypeComboBox: TComboBox;
  end;

implementation

{$R *.DFM}

end.
