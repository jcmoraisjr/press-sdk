unit ContactEditFrm;

{$mode objfpc}{$H+}

interface

uses
  LResources, CustomEditFrm, Classes, Controls, StdCtrls, ExtCtrls, Grids;

type
  TContactEditForm = class(TCustomEditForm)
    NameLabel: TLabel;
    NameEdit: TEdit;
    NumberEdit: TEdit;
    NumberLabel: TLabel;
    PhoneTypeComboBox: TComboBox;
    PhoneTypeLabel: TLabel;
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


initialization
  {$i ContactEditFrm.lrs}

end.
