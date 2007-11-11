unit CustomMVP;

{$I PhoneBook.inc}

interface

uses
{$IFDEF UseReport}
  PressReportManager,
{$ENDIF}
  PressMVPModel, PressMVPPresenter;

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

  TCustomEditPresenter = class(TPressMVPFormPresenter)
  protected
    procedure InitPresenter; override;
    class function InternalModelClass: TPressMVPObjectModelClass; override;
  end;

implementation

uses
  PressMVPCommand;

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

{ TCustomEditPresenter }

procedure TCustomEditPresenter.InitPresenter;
begin
  inherited;
  BindCommand(TPressMVPSaveObjectCommand, 'OkButton');
  BindCommand(TPressMVPCancelObjectCommand, 'CancelButton');
end;

class function TCustomEditPresenter.InternalModelClass: TPressMVPObjectModelClass;
begin
  Result := TCustomEditModel;
end;

end.
