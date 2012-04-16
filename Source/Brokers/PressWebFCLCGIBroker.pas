unit PressWebFCLCGIBroker;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs,
  custweb,
  custcgi,
  PressClasses,
  PressApplication,
  PressWebHandler;

type

  TPressWebFCLCGIApp = class;

  { TPressWebFCLCGIAppManager }

  TPressWebFCLCGIAppManager = class(TPressManagedIObject, IPressAppManager)
  private
    FApp: TPressWebFCLCGIApp;
    FIdleMethod: TPressIdleMethod;
  protected
    procedure Finit; override;
  public
    procedure Done;
    procedure Finalize;
    function HasMainForm: Boolean;
    procedure IdleNotification(AIdleMethod: TPressIdleMethod);
    procedure Init;
    function MainForm: TObject;
    procedure Run;
  end;

  { TPressWebFCLCGIHandler }

  TPressWebFCLCGIHandler = class(TCGIHandler)
  public
    procedure HandleRequest(ARequest: TRequest; AResponse: TResponse); override;
  end;

  { TPressWebFCLCGIApp }

  TPressWebFCLCGIApp = class(TCustomCGIApplication)
  protected
    function InitializeWebHandler: TWebHandler; override;
  end;

implementation

uses
  SysUtils;

{ TPressWebFCLCGIAppManager }

procedure TPressWebFCLCGIAppManager.Finit;
begin
  FreeAndNil(FApp);
  inherited Finit;
end;

procedure TPressWebFCLCGIAppManager.Done;
begin
end;

procedure TPressWebFCLCGIAppManager.Finalize;
begin
end;

function TPressWebFCLCGIAppManager.HasMainForm: Boolean;
begin
  Result := False;
end;

procedure TPressWebFCLCGIAppManager.IdleNotification(AIdleMethod: TPressIdleMethod);
begin
  FIdleMethod := AIdleMethod;
end;

procedure TPressWebFCLCGIAppManager.Init;
begin
  FreeAndNil(FApp);
  FApp := TPressWebFCLCGIApp.Create(nil);
  FApp.Initialize;
end;

function TPressWebFCLCGIAppManager.MainForm: TObject;
begin
  Result := nil;
end;

procedure TPressWebFCLCGIAppManager.Run;
begin
  FApp.Run;
  if Assigned(FIdleMethod) then
    FIdleMethod;
end;

{ TPressWebFCLCGIHandler }

procedure TPressWebFCLCGIHandler.HandleRequest(ARequest: TRequest;
  AResponse: TResponse);
begin
  TPressWebHandler.DefaultService.HandleRequest(ARequest, AResponse);
end;

{ TPressWebFCLCGIApp }

function TPressWebFCLCGIApp.InitializeWebHandler: TWebHandler;
begin
  Result := TPressWebFCLCGIHandler.Create(Self);
end;

initialization
  PressApp.RegisterAppManager(TPressWebFCLCGIAppManager.Create);

end.

