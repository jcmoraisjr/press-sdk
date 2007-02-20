(*
  PressObjects, Base Persistence Classes
  Copyright (C) 2006 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressPersistence;

{$I Press.inc}

interface

uses
  PressApplication,
  PressClasses,
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

  TPressPersistence = class;

  TPressOIDGeneratorClass = class of TPressOIDGenerator;

  TPressOIDGenerator = class(TPressService)
  protected
    function InternalGenerateOID(Sender: TPressPersistence; AObjectClass: TPressObjectClass; const AAttributeName: string): string; virtual;
    procedure InternalReleaseOID(Sender: TPressPersistence; AObjectClass: TPressObjectClass; const AAttributeName, AOID: string); virtual;
    class function InternalServiceType: TPressServiceType; override;
  public
    function GenerateOID(Sender: TPressPersistence; AObjectClass: TPressObjectClass; const AAttributeName: string): string;
    procedure ReleaseOID(Sender: TPressPersistence; AObjectClass: TPressObjectClass; const AAttributeName, AOID: string);
  end;

  TPressPersistence = class(TPressService)
  private
    FCurrentUser: TPressUser;
    FOIDGenerator: TPressOIDGenerator;
    FUserQuery: TPressUserQuery;
    function GetCurrentUser: TPressUser;
    function GetHasUser: Boolean;
    function GetOIDGenerator: TPressOIDGenerator;
    function GetUserQuery: TPressUserQuery;
    function UnsuportedFeatureError(const AFeatureName: string): EPressError;
  protected
    procedure DoneService; override;
    function GetIdentifierQuotes: string; virtual;
    function GetStrQuote: Char; virtual;
    procedure InternalCommitTransaction; virtual;
    procedure InternalDispose(AObject: TPressObject); virtual;
    procedure InternalConnect; virtual;
    procedure InternalExecuteStatement(const AStatement: string); virtual;
    function InternalLogon(const AUserID, APassword: string): Boolean; virtual;
    function InternalOIDGeneratorClass: TPressOIDGeneratorClass; virtual;
    function InternalOQLQuery(const AOQLStatement: string): TPressProxyList; virtual;
    function InternalRetrieve(const AClass, AId: string): TPressObject; virtual;
    function InternalRetrieveProxyList(AQuery: TPressQuery): TPressProxyList; virtual;
    procedure InternalRollbackTransaction; virtual;
    function InternalSQLQuery(const ASQLStatement: string): TPressProxyList; virtual;
    function InternalUserQueryClass: TPressUserQueryClass;
    class function InternalServiceType: TPressServiceType; override;
    procedure InternalStartTransaction; virtual;
    procedure InternalStore(AObject: TPressObject); virtual;
    property OIDGenerator: TPressOIDGenerator read GetOIDGenerator;
    property UserQuery: TPressUserQuery read GetUserQuery;
  public
    destructor Destroy; override;
    procedure CommitTransaction;
    procedure Connect;
    procedure Dispose(const AClass, AId: string); overload;
    procedure Dispose(AObject: TPressObject); overload;
    procedure Dispose(AProxy: TPressProxy); overload;
    procedure ExecuteStatement(const AStatement: string);
    function GenerateOID(AObjectClass: TPressObjectClass; const AAttributeName: string = ''): string;
    procedure Logoff;
    function Logon(const AUserID: string = ''; const APassword: string = ''): Boolean;
    function OQLQuery(const AOQLStatement: string): TPressProxyList;
    function Retrieve(const AClass, AId: string): TPressObject;
    function RetrieveProxyList(AQuery: TPressQuery): TPressProxyList;
    procedure RollbackTransaction;
    function SQLQuery(const ASQLStatement: string): TPressProxyList;
    procedure StartTransaction;
    procedure Store(AObject: TPressObject);
    property CurrentUser: TPressUser read GetCurrentUser;
    property HasUser: Boolean read GetHasUser;
    property IdentifierQuotes: string read GetIdentifierQuotes;
    property StrQuote: Char read GetStrQuote;
  end;

function PressDefaultPersistence: TPressPersistence;

implementation

uses
  SysUtils,
  PressCompatibility,
  PressConsts
  {$IFDEF PressLog},PressLog{$ENDIF};

type
  TPressUserFriend = class(TPressUser);
  TPressObjectFriend = class(TPressObject);

{ Global routines }

function PressDefaultPersistence: TPressPersistence;
begin
  Result := TPressPersistence(PressApp.DefaultService(TPressPersistence));
end;

{ TPressOIDGenerator }

function TPressOIDGenerator.GenerateOID(
  Sender: TPressPersistence; AObjectClass: TPressObjectClass;
  const AAttributeName: string): string;
begin
  Result := InternalGenerateOID(Sender, AObjectClass, AAttributeName);
end;

function TPressOIDGenerator.InternalGenerateOID(
  Sender: TPressPersistence; AObjectClass: TPressObjectClass;
  const AAttributeName: string): string;
var
  VId: array[0..15] of Byte;
  I: Integer;
begin
  GenerateGUID(TGUID(VId));
  SetLength(Result, 32);
  for I := 0 to 15 do
    Move(IntToHex(VId[I], 2)[1], Result[2*I+1], 2);
end;

procedure TPressOIDGenerator.InternalReleaseOID(Sender: TPressPersistence;
  AObjectClass: TPressObjectClass; const AAttributeName, AOID: string);
begin
end;

class function TPressOIDGenerator.InternalServiceType: TPressServiceType;
begin
  Result := stOIDGenerator;
end;

procedure TPressOIDGenerator.ReleaseOID(Sender: TPressPersistence;
  AObjectClass: TPressObjectClass; const AAttributeName, AOID: string);
begin
  InternalReleaseOID(Sender, AObjectClass, AAttributeName, AOID);
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
  FUserQuery.Free;
  inherited;
end;

procedure TPressPersistence.Dispose(AProxy: TPressProxy);
begin
  Dispose(AProxy.Instance);
end;

procedure TPressPersistence.Dispose(AObject: TPressObject);
begin
  if Assigned(AObject) and AObject.IsPersistent then
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

procedure TPressPersistence.DoneService;
begin
  inherited;
  Logoff;
end;

procedure TPressPersistence.ExecuteStatement(const AStatement: string);
begin
  InternalExecuteStatement(AStatement);
end;

function TPressPersistence.GenerateOID(
  AObjectClass: TPressObjectClass; const AAttributeName: string): string;
begin
  Result := OIDGenerator.GenerateOID(Self, AObjectClass, AAttributeName);
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

function TPressPersistence.GetUserQuery: TPressUserQuery;
begin
  if not Assigned(FUserQuery) then
    FUserQuery := InternalUserQueryClass.Create;
  Result := FUserQuery;
end;

procedure TPressPersistence.InternalCommitTransaction;
begin
  raise UnsuportedFeatureError('Commit transaction');
end;

procedure TPressPersistence.InternalConnect;
begin
  raise UnsuportedFeatureError('Connect');
end;

procedure TPressPersistence.InternalDispose(AObject: TPressObject);
begin
  raise UnsuportedFeatureError('Dispose object');
end;

procedure TPressPersistence.InternalExecuteStatement(const AStatement: string);
begin
  raise UnsuportedFeatureError('Execute statement');
end;

function TPressPersistence.InternalLogon(
  const AUserID, APassword: string): Boolean;
var
  VNewUser: TPressUser;
begin
  { TODO : Implement DB Connection }
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

function TPressPersistence.InternalOIDGeneratorClass: TPressOIDGeneratorClass;
begin
  Result :=
   TPressOIDGeneratorClass(PressApp.DefaultServiceClass(stOIDGenerator));
end;

function TPressPersistence.InternalOQLQuery(
  const AOQLStatement: string): TPressProxyList;
begin
  raise UnsuportedFeatureError('OQL Query');
end;

function TPressPersistence.InternalRetrieve(const AClass,
  AId: string): TPressObject;
begin
  raise UnsuportedFeatureError('Retrieve object');
end;

function TPressPersistence.InternalRetrieveProxyList(
  AQuery: TPressQuery): TPressProxyList;
begin
  raise UnsuportedFeatureError('Retrieve proxy list');
end;

procedure TPressPersistence.InternalRollbackTransaction;
begin
  raise UnsuportedFeatureError('Rollback transaction');
end;

class function TPressPersistence.InternalServiceType: TPressServiceType;
begin
  Result := stPersistence;
end;

function TPressPersistence.InternalSQLQuery(
  const ASQLStatement: string): TPressProxyList;
begin
  raise UnsuportedFeatureError('SQL Query');
end;

procedure TPressPersistence.InternalStartTransaction;
begin
  raise UnsuportedFeatureError('Start transaction');
end;

procedure TPressPersistence.InternalStore(AObject: TPressObject);
begin
  raise UnsuportedFeatureError('Store object');
end;

function TPressPersistence.InternalUserQueryClass: TPressUserQueryClass;
begin
  Result := PressUserData.UserQueryClass;
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

function TPressPersistence.OQLQuery(
  const AOQLStatement: string): TPressProxyList;
begin
  Result := InternalOQLQuery(AOQLStatement);
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

function TPressPersistence.SQLQuery(
  const ASQLStatement: string): TPressProxyList;
begin
  Result := InternalSQLQuery(ASQLStatement);
end;

procedure TPressPersistence.StartTransaction;
begin
  InternalStartTransaction;
end;

procedure TPressPersistence.Store(AObject: TPressObject);
var
  VIsUpdating: Boolean;
begin
  if Assigned(AObject) and not AObject.IsOwned and not AObject.IsUpdated then
  begin
    VIsUpdating := AObject.IsPersistent;
    TPressObjectFriend(AObject).BeforeStore;
    AObject.DisableChanges;
    try
      {$IFDEF PressLogOPF}PressLogMsg(Self, 'Storing', [AObject]);{$ENDIF}
      InternalStore(AObject);
      AObject.Unchanged;
    finally
      AObject.EnableChanges;
    end;
    TPressObjectFriend(AObject).AfterStore(VIsUpdating);
  end;
end;

function TPressPersistence.UnsuportedFeatureError(
  const AFeatureName: string): EPressError;
begin
  Result := EPressError.CreateFmt(SUnsupportedFeature, [AFeatureName]);
end;

initialization
  TPressOIDGenerator.RegisterService;

end.
