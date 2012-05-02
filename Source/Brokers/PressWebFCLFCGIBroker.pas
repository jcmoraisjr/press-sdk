(*
  PressObjects, FCL-Web Fast-CGI Broker
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  Collaborator(s):
    . silvioprog@gmail.com

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressWebFCLFCGIBroker;

{$I Press.inc}

interface

uses
  HTTPDefs,
  custweb,
  custfcgi,
  Classes,
  PressClasses,
  PressApplication,
  PressWebHandler;

type

  TPressWebFCLFCGIApp = class;

  { TPressWebFCLFCGIAppManager }

  TPressWebFCLFCGIAppManager = class(TPressManagedIObject, IPressAppManager)
  private
    FApp: TPressWebFCLFCGIApp;
    FIdleMethod: TPressIdleMethod;
    FOnIdle: TNotifyEvent;
    procedure AppIdle(ASender: TObject);
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

  { TPressWebFCLFCGIHandler }

  TPressWebFCLFCGIHandler = class(TFCGIHandler)
  public
    procedure HandleRequest(ARequest: TRequest; AResponse: TResponse); override;
  end;

  { TPressWebFCLFCGIApp }

  TPressWebFCLFCGIApp = class(TCustomFCGIApplication)
  private
    function GetOnIdle: TNotifyEvent;
    procedure SetOnIdle(const AValue: TNotifyEvent);
  protected
    function InitializeWebHandler: TWebHandler; override;
    property OnIdle: TNotifyEvent read GetOnIdle write SetOnIdle;
  end;

implementation

uses
  SysUtils;

{ TPressWebFCLFCGIAppManager }

procedure TPressWebFCLFCGIAppManager.AppIdle(ASender: TObject);
begin
  if Assigned(FIdleMethod) then
    FIdleMethod;
  if Assigned(FOnIdle) then
    FOnIdle(ASender);
end;

procedure TPressWebFCLFCGIAppManager.Finit;
begin
  FApp.OnIdle := nil;
  FreeAndNil(FApp);
  inherited Finit;
end;

procedure TPressWebFCLFCGIAppManager.Done;
begin
  FApp.OnIdle := FOnIdle;
end;

procedure TPressWebFCLFCGIAppManager.Finalize;
begin
end;

function TPressWebFCLFCGIAppManager.HasMainForm: Boolean;
begin
  Result := False;
end;

procedure TPressWebFCLFCGIAppManager.IdleNotification(AIdleMethod: TPressIdleMethod);
begin
  FIdleMethod := AIdleMethod;
end;

procedure TPressWebFCLFCGIAppManager.Init;
begin
  FreeAndNil(FApp);
  FApp := TPressWebFCLFCGIApp.Create(nil);
  FOnIdle := FApp.OnIdle;
  FApp.OnIdle := @AppIdle;
  FApp.Initialize;
end;

function TPressWebFCLFCGIAppManager.MainForm: TObject;
begin
  Result := nil;
end;

procedure TPressWebFCLFCGIAppManager.Run;
begin
  FApp.Run;
end;

{ TPressWebFCLFCGIHandler }

procedure TPressWebFCLFCGIHandler.HandleRequest(ARequest: TRequest;
  AResponse: TResponse);
begin
  TPressWebHandler.DefaultService.HandleRequest(ARequest, AResponse);
end;

{ TPressWebFCLFCGIApp }

function TPressWebFCLFCGIApp.InitializeWebHandler: TWebHandler;
begin
  Result := TPressWebFCLFCGIHandler.Create(Self);
end;

function TPressWebFCLFCGIApp.GetOnIdle: TNotifyEvent;
begin
  Result := WebHandler.OnIdle;
end;

procedure TPressWebFCLFCGIApp.SetOnIdle(const AValue: TNotifyEvent);
begin
  WebHandler.OnIdle := AValue;
end;

initialization
  PressApp.RegisterAppManager(TPressWebFCLFCGIAppManager.Create);

end.

