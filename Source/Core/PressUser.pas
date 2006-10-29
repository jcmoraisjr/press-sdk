(*
  PressObjects, User Control Classes
  Copyright (C) 2006 Laserpress Ltda.

  http://www.pressobjects.org

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
*)

unit PressUser;

interface

{$I Press.inc}

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

initialization
  TPressUserData.RegisterService;

end.
