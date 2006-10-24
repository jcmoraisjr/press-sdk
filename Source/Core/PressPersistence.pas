(*
  PressObjects, Persistence Broker Class
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

unit PressPersistence;

interface

{$I Press.inc}

uses
  PressApplication,
  PressNotifier,
  PressSubject,
  PressQuery,
  PressUser;

type
  TPressPersistenceEvent = class(TPressEvent)
  end;

  TPressPersistenceLogonEvent = class(TPressPersistenceEvent)
  end;

  TPressPersistenceLogoffEvent = class(TPressPersistenceEvent)
  end;

  TPressOIDGeneratorClass = class of TPressOIDGenerator;

  TPressOIDGenerator = class(TPressQuery)
  protected
    function InternalGenerateOID(AObjectClass: TPressObjectClass): string; virtual;
    procedure InternalReleaseOID(AObjectClass: TPressObjectClass; const AOID: string); virtual;
  public
    function GenerateOID(AObjectClass: TPressObjectClass = nil): string;
    procedure ReleaseOID(AObjectClass: TPressObjectClass; const AOID: string);
  end;

  TPressPersistence = class(TPressService)
  private
    FCurrentUser: TPressUser;
    FOIDGenerator: TPressOIDGenerator;
    FUsers: TPressUsers;
    function GetCurrentUser: TPressUser;
    function GetHasUser: Boolean;
    function GetOIDGenerator: TPressOIDGenerator;
    function GetUsers: TPressUsers;
  protected
    procedure DoneService; override;
    function GetIdentifierQuotes: string; virtual;
    function GetStrQuote: Char; virtual;
    procedure InternalCommitTransaction; virtual;
    procedure InternalDispose(AObject: TPressObject); virtual; abstract;
    procedure InternalConnect; virtual;
    procedure InternalExecuteStatement(const AStatement: string); virtual;
    function InternalUsersClass: TPressUsersClass; virtual;
    function InternalLogon(const AUserID, APassword: string): Boolean; virtual;
    function InternalOIDGeneratorClass: TPressOIDGeneratorClass; virtual;
    function InternalRetrieve(const AClass, AId: string): TPressObject; virtual; abstract;
    function InternalRetrieveProxyList(AQuery: TPressQuery): TPressProxyList; virtual; abstract;
    procedure InternalRollbackTransaction; virtual;
    class function InternalServiceType: TPressServiceType; override;
    procedure InternalStartTransaction; virtual;
    procedure InternalStore(AObject: TPressObject); virtual; abstract;
    property Users: TPressUsers read GetUsers;
  public
    destructor Destroy; override;
    procedure CommitTransaction;
    procedure Connect;
    procedure Dispose(const AClass, AId: string); overload;
    procedure Dispose(AObject: TPressObject); overload;
    procedure Dispose(AProxy: TPressProxy); overload;
    procedure ExecuteStatement(const AStatement: string);
    procedure Logoff;
    function Logon(const AUserID, APassword: string): Boolean;
    function Retrieve(const AClass, AId: string): TPressObject;
    function RetrieveProxyList(AQuery: TPressQuery): TPressProxyList;
    procedure RollbackTransaction;
    procedure StartTransaction;
    procedure Store(AObject: TPressObject);
    property CurrentUser: TPressUser read GetCurrentUser;
    property HasUser: Boolean read GetHasUser;
    property IdentifierQuotes: string read GetIdentifierQuotes;
    property OIDGenerator: TPressOIDGenerator read GetOIDGenerator;
    property StrQuote: Char read GetStrQuote;
  end;

function PressDefaultPersistence: TPressPersistence;

implementation

uses
  SysUtils,
  Contnrs,
  ActiveX,
  ComObj,
  PressClasses,
  PressConsts
  {$IFDEF PressLog},PressLog{$ENDIF};

type
  TPressUserFriend = class(TPressUser);
  TPressObjectFriend = class(TPressObject);

var
  _PressDefaultPersistence: TPressPersistence;

{ Global routines }

function PressDefaultPersistence: TPressPersistence;
begin
  { TODO : Use a fast, but *functional* way }
  if not Assigned(_PressDefaultPersistence) then
    _PressDefaultPersistence :=
     PressApp.DefaultService(stPersistence) as TPressPersistence;
  Result := _PressDefaultPersistence;
end;

{ TPressOIDGenerator }

function TPressOIDGenerator.GenerateOID(
  AObjectClass: TPressObjectClass): string;
begin
  Result := InternalGenerateOID(AObjectClass);
end;

function TPressOIDGenerator.InternalGenerateOID(
  AObjectClass: TPressObjectClass): string;
var
  VId: array[0..15] of Byte;
  I: Integer;
begin
  OleCheck(CoCreateGUID(TGUID(VId)));
  SetLength(Result, 32);
  for I := 0 to 15 do
    Move(IntToHex(VId[I], 2)[1], Result[2*I+1], 2);
end;

procedure TPressOIDGenerator.InternalReleaseOID(
  AObjectClass: TPressObjectClass; const AOID: string);
begin
end;

procedure TPressOIDGenerator.ReleaseOID(
  AObjectClass: TPressObjectClass; const AOID: string);
begin
  InternalReleaseOID(AObjectClass, AOID);
end;

{ TPressPersistence }

procedure TPressPersistence.CommitTransaction;
begin
  InternalCommitTransaction;
end;

procedure TPressPersistence.Connect;
begin
  InternalConnect;
end;

destructor TPressPersistence.Destroy;
begin
  FOIDGenerator.Free;
  FUsers.Free;
  inherited;
end;

procedure TPressPersistence.Dispose(AProxy: TPressProxy);
begin
  Dispose(AProxy.Instance);
end;

procedure TPressPersistence.DoneService;
begin
  inherited;
  Logoff;
end;

procedure TPressPersistence.Dispose(AObject: TPressObject);
begin
  if Assigned(AObject) then
  begin
    AObject.DisableChanges;
    try
      {$IFDEF PressLogOPF}PressLogMsg(Self, 'Disposing', [AObject]);{$ENDIF}
      InternalDispose(AObject);
    finally
      AObject.EnableChanges;
    end;
  end;
end;

procedure TPressPersistence.Dispose(const AClass, AId: string);
var
  VObject: TPressObject;
begin
  VObject := Retrieve(AClass, AId);
  try
    Dispose(VObject);
  finally
    VObject.Free;
  end;
end;

procedure TPressPersistence.ExecuteStatement(const AStatement: string);
begin
  InternalExecuteStatement(AStatement);
end;

function TPressPersistence.GetCurrentUser: TPressUser;
begin
  if not Assigned(FCurrentUser) then
    raise EPressError.Create(SNoLoggedUser);
  Result := FCurrentUser;
end;

function TPressPersistence.GetHasUser: Boolean;
begin
  Result := Assigned(FCurrentUser);
end;

function TPressPersistence.GetIdentifierQuotes: string;
begin
  Result := '"';
end;

function TPressPersistence.GetOIDGenerator: TPressOIDGenerator;
begin
  if not Assigned(FOIDGenerator) then
    FOIDGenerator := InternalOIDGeneratorClass.Create;
  Result := FOIDGenerator;
end;

function TPressPersistence.GetStrQuote: Char;
begin
  Result := '''';
end;

function TPressPersistence.GetUsers: TPressUsers;
begin
  if not Assigned(FUsers) then
    FUsers := InternalUsersClass.Create;
  Result := FUsers;
end;

procedure TPressPersistence.InternalCommitTransaction;
begin
end;

procedure TPressPersistence.InternalConnect;
begin
end;

procedure TPressPersistence.InternalExecuteStatement(
  const AStatement: string);
begin
end;

function TPressPersistence.InternalLogon(
  const AUserID, APassword: string): Boolean;
var
  VNewUser: TPressUser;
begin
  { TODO : Implement DB Connection }
  VNewUser := Users.CheckLogon(AUserID, APassword);
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

function TPressPersistence.InternalOIDGeneratorClass: TPressOIDGeneratorClass;
begin
  Result := TPressOIDGenerator;
end;

procedure TPressPersistence.InternalRollbackTransaction;
begin
end;

class function TPressPersistence.InternalServiceType: TPressServiceType;
begin
  Result := stPersistence;
end;

procedure TPressPersistence.InternalStartTransaction;
begin
end;

function TPressPersistence.InternalUsersClass: TPressUsersClass;
begin
  Result := TPressDefaultUsers;
end;

procedure TPressPersistence.Logoff;
begin
  if Assigned(FCurrentUser) then
  begin
    TPressUserFriend(FCurrentUser).BeforeLogoff;  // friend class
    TPressPersistenceLogoffEvent.Create(Self).Notify;
    FreeAndNil(FCurrentUser);
  end;
end;

function TPressPersistence.Logon(
  const AUserID, APassword: string): Boolean;
begin
  Result := InternalLogon(AUserID, APassword);
  if Result then
  begin
    TPressPersistenceLogonEvent.Create(Self).Notify;
    TPressUserFriend(CurrentUser).AfterLogon;  // friend class
  end;
end;

function TPressPersistence.Retrieve(const AClass, AId: string): TPressObject;
begin
  Result := PressFindObject(AClass, AId);
  if Assigned(Result) then
    Result.AddRef
  else
  begin
    {$IFDEF PressLogOPF}PressLogMsg(Self,
     Format('Retrieving %s(%s)', [AClass, AId]));{$ENDIF}
    { TODO : Ensure the class type of the retrieved object }
    Result := InternalRetrieve(AClass, AId);
    if Assigned(Result) then
      TPressObjectFriend(Result).AfterRetrieve;
  end;
end;

function TPressPersistence.RetrieveProxyList(
  AQuery: TPressQuery): TPressProxyList;
begin
  Result := InternalRetrieveProxyList(AQuery);
end;

procedure TPressPersistence.RollbackTransaction;
begin
  InternalRollbackTransaction;
end;

procedure TPressPersistence.StartTransaction;
begin
  InternalStartTransaction;
end;

procedure TPressPersistence.Store(AObject: TPressObject);
begin
  if Assigned(AObject) and not AObject.IsOwned and not AObject.IsUpdated then
  begin
    AObject.DisableChanges;
    try
      {$IFDEF PressLogOPF}PressLogMsg(Self, 'Storing', [AObject]);{$ENDIF}
      InternalStore(AObject);
      AObject.Unchanged;
    finally
      AObject.EnableChanges;
    end;
  end;
end;

end.
