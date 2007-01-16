(*
  PressObjects, User Control Classes
  Copyright (C) 2006 Laserpress Ltda.

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
  PressSubject,
  PressQuery;

type
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
  protected
    class function InternalServiceType: TPressServiceType; override;
    function InternalUserQueryClass: TPressUserQueryClass; virtual;
  public
    function UserQueryClass: TPressUserQueryClass;
  end;

function PressUserData: TPressUserData;

implementation

function PressUserData: TPressUserData;
begin
  Result := PressApp.DefaultService(stUserData) as TPressUserData;
end;

{ TPressUser }

function TPressUser.AccessMode(AAccessObjectID: Integer): TPressAccessMode;
begin
  Result := InternalAccessMode(AAccessObjectID);
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

class function TPressUserData.InternalServiceType: TPressServiceType;
begin
  Result := stUserData;
end;

function TPressUserData.InternalUserQueryClass: TPressUserQueryClass;
begin
  Result := TPressUserQuery;
end;

function TPressUserData.UserQueryClass: TPressUserQueryClass;
begin
  Result := InternalUserQueryClass;
end;

procedure RegisterServices;
begin
  TPressUserData.RegisterService;
end;

procedure RegisterClasses;
begin
  TPressUser.RegisterClass;
  TPressUserQuery.RegisterClass;
end;

initialization
  RegisterServices;
  RegisterClasses;

end.
