unit MainModel;

interface

uses
  PressMVPModel;

type
  TMainModel = class(TPressMVPReferencesModel)
  protected
    procedure InternalCreateAddCommands; override;
  end;

implementation

uses
  MainCommand;

{ TMainModel }

procedure TMainModel.InternalCreateAddCommands;
begin
  //inherited;
  AddCommands([TMainAddPersonCommand, TMainAddCompanyCommand]);
end;

end.
