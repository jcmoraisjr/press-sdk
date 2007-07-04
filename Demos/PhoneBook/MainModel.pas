unit MainModel;

{$I PhoneBook.inc}

interface

uses
  PressMVPModel
  {$IFDEF UseReport}, PressReportManager{$ENDIF};

type
  TMainModel = class(TPressMVPQueryModel)
  private
    {$IFDEF UseReport}
    FReportManager: TPressReportManager;
    {$ENDIF}
  protected
    procedure InitCommands; override;
  public
    destructor Destroy; override;
  end;

  TMainGridModel = class(TPressMVPReferencesModel)
  protected
    procedure InternalCreateAddCommands; override;
  end;

implementation

uses
  MainCommand;

{ TMainModel }

destructor TMainModel.Destroy;
begin
  {$IFDEF UseReport}
  FReportManager.Free;
  {$ENDIF}
  inherited;
end;

procedure TMainModel.InitCommands;
begin
  inherited;
  {$IFDEF UseReport}
  FReportManager := TPressReportManager.Create(Self);
  {$ENDIF}
end;

{ TMainGridModel }

procedure TMainGridModel.InternalCreateAddCommands;
begin
  //inherited;
  AddCommands([TMainAddPersonCommand, TMainAddCompanyCommand]);
end;

end.
