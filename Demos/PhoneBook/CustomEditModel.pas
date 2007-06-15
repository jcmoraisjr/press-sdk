unit CustomEditModel;

{$I PhoneBook.inc}

interface

uses
  PressMVPModel,
  PressReportManager;

type
  TCustomEditModel = class(TPressMVPObjectModel)
  private
    {$IFDEF UseReport}
    FReportManager: TPressReportManager;
    {$ENDIF}
  protected
    procedure InitCommands; override;
  public
    destructor Destroy; override;
  end;

implementation

{ TCustomEditModel }

destructor TCustomEditModel.Destroy;
begin
  {$IFDEF UseReport}
  FReportManager.Free;
  {$ENDIF}
  inherited;
end;

procedure TCustomEditModel.InitCommands;
begin
  inherited;
  {$IFDEF UseReport}
  FReportManager := TPressReportManager.Create(Self);
  {$ENDIF}
end;

end.
