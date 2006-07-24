unit PersonEdit;

interface

uses
  Classes, Controls, StdCtrls, ExtCtrls, Grids, ContactEdit;

type
  TPersonEditForm = class(TContactEditForm)
    NickNameLabel: TLabel;
    NickNameEdit: TEdit;
  end;

implementation

{$R *.DFM}

end.
