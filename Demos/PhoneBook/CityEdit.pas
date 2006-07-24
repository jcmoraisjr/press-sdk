unit CityEdit;

interface

uses
  Classes, Controls, StdCtrls, ExtCtrls, CustomEdit;

type
  TCityEditForm = class(TCustomEditForm)
    NameLabel: TLabel;
    NameEdit: TEdit;
    StateLabel: TLabel;
    StateEdit: TEdit;
  end;

implementation

{$R *.DFM}

end.
