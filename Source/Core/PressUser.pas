(*
  PressObjects, User Control Classes
  Copyright (C) 2006-2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressUser;

{$I Press.inc}

interface

uses
  PressApplication,
  PressNotifier,
  PressSubject;

type
  TPressUserEvent = class(TPressEvent)
  end;

  TPressUserLogonEvent = class(TPressUserEvent)
  end;

  TPressUserLogoffEvent = class(TPressUserEvent)
  end;

  TPressAccessMode = (amInvisible, amVisible, amWritable);

  TPressUser = class(TPressObject)
  protected
    procedure AfterLogon; virtual;
    procedure BeforeLogoff; virtual;
    function InternalAccessMode(AAccessObjectID: Integer): TPressAccessMode; virtual;
  public
    function AccessMode(AAccessObjectID: Integer): TPressAccessMode;
  end;

  TPressUserQueryClass = class of TPressUserQuery;

  TPressUserQuery = class(TPressQuery)
  protected
    function InternalCheckLogon(const AUserID, APassword: string): TPressUser; virtual;
  public
    function CheckLogon(const AUserID, APassword: string): TPressUser;
  end;

  TPressUserData = class(TPressService)
  private
    FCurrentUser: TPressUser;
    FUserQuery: TPressUserQuery;
    function GetCurrentUser: TPressUser;
    function GetHasUser: Boolean;
  protected
    procedure DoneService; override;
    function InternalLogon(const AUserID, APassword: string): Boolean; virtual;
    function InternalUserQueryClass: TPressUserQueryClass; virtual;
    class function InternalServiceType: TPressServiceType; override;
    property UserQuery: TPressUserQuery read FUserQuery;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Logoff;
    function Logon(const AUserID: string = ''; const APassword: string = ''): Boolean;
    property CurrentUser: TPressUser read GetCurrentUser;
    property HasUser: Boolean read GetHasUser;
  end;

function PressUserData: TPressUserData;

implementation

uses
  SysUtils,
  PressClasses,
  PressConsts;

function PressUserData: TPressUserData;
begin
  Result := PressApp.DefaultService(TPressUserData) as TPressUserData;
end;

{ TPressUser }

function TPressUser.AccessMode(AAccessObjectID: Integer): TPressAccessMode;
begin
  if AAccessObjectID >= 0 then
    Result := InternalAccessMode(AAccessObjectID)
  else
    Result := amWritable;
end;

procedure TPressUser.AfterLogon;
begin
end;

procedure TPressUser.BeforeLogoff;
begin
end;

function TPressUser.InternalAccessMode(
  AAccessObjectID: Integer): TPressAccessMode;
begin
  Result := amWritable;
end;

{ TPressUserQuery }

function TPressUserQuery.CheckLogon(
  const AUserID, APassword: string): TPressUser;
begin
  Result := InternalCheckLogon(AUserID, APassword);
end;

function TPressUserQuery.InternalCheckLogon(
  const AUserID, APassword: string): TPressUser;
begin
  Result := TPressUser.Create;
end;

{ TPressUserData }

constructor TPressUserData.Create;
begin
  inherited Create;
  FUserQuery := InternalUserQueryClass.Create;
end;

destructor TPressUserData.Destroy;
begin
  FCurrentUser.Free;
  FUserQuery.Free;
  inherited;
end;

procedure TPressUserData.DoneService;
begin
  inherited;
  Logoff;
end;

function TPressUserData.GetCurrentUser: TPressUser;
begin
  if not Assigned(FCurrentUser) then
    raise EPressError.Create(SNoLoggedUser);
  Result := FCurrentUser;
end;

function TPressUserData.GetHasUser: Boolean;
begin
  Result := Assigned(FCurrentUser);
end;

function TPressUserData.InternalLogon(
  const AUserID, APassword: string): Boolean;
var
  VNewUser: TPressUser;
begin
  VNewUser := UserQuery.CheckLogon(AUserID, APassword);
  Result := Assigned(VNewUser);
  if Result then
    try
      Logoff;
      FCurrentUser := VNewUser;
    except
      VNewUser.Free;
      raise;
    end;
end;

class function TPressUserData.InternalServiceType: TPressServiceType;
begin
  Result := stUserData;
end;

function TPressUserData.InternalUserQueryClass: TPressUserQueryClass;
begin
  Result := TPressUserQuery;
end;

procedure TPressUserData.Logoff;
begin
  if Assigned(FCurrentUser) then
  begin
    FCurrentUser.BeforeLogoff;  // friend class
    TPressUserLogoffEvent.Create(Self).Notify;
    FreeAndNil(FCurrentUser);
  end;
end;

function TPressUserData.Logon(const AUserID, APassword: string): Boolean;
begin
  Result := InternalLogon(AUserID, APassword);
  if Result then
  begin
    TPressUserLogonEvent.Create(Self).Notify;
    CurrentUser.AfterLogon;  // friend class
  end;
end;

procedure RegisterClasses;
begin
  TPressUser.RegisterClass;
  TPressUserQuery.RegisterClass;
end;

initialization
  RegisterClasses;

end.
