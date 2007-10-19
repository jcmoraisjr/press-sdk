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

const
  CPressUserDataService = CPressUserServicesBase + $0001;

type
  TPressUserEvent = class(TPressEvent)
  end;

  TPressUserLogonEvent = class(TPressUserEvent)
  end;

  TPressUserLogoffEvent = class(TPressUserEvent)
  end;

  TPressAccessMode = (amInvisible, amVisible, amWritable);

  TPressCustomUser = class(TPressObject)
  protected
    procedure AfterLogon; virtual;
    procedure BeforeLogoff; virtual;
    function InternalAccessMode(AAccessObjectID: Integer): TPressAccessMode; virtual;
  public
    function AccessMode(AAccessObjectID: Integer): TPressAccessMode;
  end;

  TPressCustomUserData = class(TPressService)
  private
    FCurrentUser: TPressCustomUser;
    function GetCurrentUser: TPressCustomUser;
    function GetHasUser: Boolean;
  protected
    procedure DoneService; override;
    procedure Finit; override;
    function InternalQueryUser(const AUserID, APassword: string): TPressCustomUser; virtual;
    class function InternalServiceType: TPressServiceType; override;
  public
    procedure Logoff;
    function Logon(const AUserID: string = ''; const APassword: string = ''): Boolean;
    function QueryUser(const AUserID, APassword: string): TPressCustomUser;
    property CurrentUser: TPressCustomUser read GetCurrentUser;
    property HasUser: Boolean read GetHasUser;
    property User: TPressCustomUser read FCurrentUser;
  end;

function PressUserData: TPressCustomUserData;

implementation

uses
  SysUtils,
  PressClasses,
  PressConsts;

function PressUserData: TPressCustomUserData;
begin
  Result := PressApp.DefaultService(TPressCustomUserData) as TPressCustomUserData;
end;

{ TPressCustomUser }

function TPressCustomUser.AccessMode(AAccessObjectID: Integer): TPressAccessMode;
begin
  if AAccessObjectID >= 0 then
    Result := InternalAccessMode(AAccessObjectID)
  else
    Result := amWritable;
end;

procedure TPressCustomUser.AfterLogon;
begin
end;

procedure TPressCustomUser.BeforeLogoff;
begin
end;

function TPressCustomUser.InternalAccessMode(
  AAccessObjectID: Integer): TPressAccessMode;
begin
  Result := amWritable;
end;

{ TPressCustomUserData }

procedure TPressCustomUserData.DoneService;
begin
  inherited;
  Logoff;
end;

procedure TPressCustomUserData.Finit;
begin
  FCurrentUser.Free;
  inherited;
end;

function TPressCustomUserData.GetCurrentUser: TPressCustomUser;
begin
  if not Assigned(FCurrentUser) then
    raise EPressError.Create(SNoLoggedUser);
  Result := FCurrentUser;
end;

function TPressCustomUserData.GetHasUser: Boolean;
begin
  Result := Assigned(FCurrentUser);
end;

function TPressCustomUserData.InternalQueryUser(
  const AUserID, APassword: string): TPressCustomUser;
begin
  Result := TPressCustomUser.Create;
end;

class function TPressCustomUserData.InternalServiceType: TPressServiceType;
begin
  Result := CPressUserDataService;
end;

procedure TPressCustomUserData.Logoff;
begin
  if Assigned(FCurrentUser) then
  begin
    FCurrentUser.BeforeLogoff;  // friend class
    TPressUserLogoffEvent.Create(Self).Notify;
    FreeAndNil(FCurrentUser);
  end;
end;

function TPressCustomUserData.Logon(const AUserID, APassword: string): Boolean;
var
  VNewUser: TPressCustomUser;
begin
  VNewUser := InternalQueryUser(AUserID, APassword);
  Result := Assigned(VNewUser);
  if Result then
    try
      Logoff;
      FCurrentUser := VNewUser;
      TPressUserLogonEvent.Create(Self).Notify;
      FCurrentUser.AfterLogon;  // friend class
    except
      FCurrentUser := nil;
      VNewUser.Free;
      raise;
    end;
end;

function TPressCustomUserData.QueryUser(const AUserID,
  APassword: string): TPressCustomUser;
begin
  Result := InternalQueryUser(AUserID, APassword);
end;

initialization
  PressApp.Registry[CPressUserDataService].ServiceTypeName :=
   SPressUserServiceName;
  TPressCustomUser.RegisterClass;

finalization
  TPressCustomUser.UnregisterClass;
  TPressCustomUserData.UnregisterService;

end.
