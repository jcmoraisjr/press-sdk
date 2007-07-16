(*
  PressObjects, Data Access Classes
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressDAO;

{$I Press.inc}

interface

uses
  PressApplication,
  PressClasses,
  PressNotifier,
  PressSubject;

type
  TPressDAOCacheClass = class of TPressDAOCache;

  TPressDAOCache = class(TObject)
  private
    { TODO : Implement binary tree }
    { TODO : Implement IsBroken support }
    FObjectList: TPressObjectList;
  protected
    property ObjectList: TPressObjectList read FObjectList;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure AddObject(AObject: TPressObject); virtual;
    function CreateIterator: TPressObjectIterator;
    function FindObject(AClass: TPressObjectClass; const AId: string): TPressObject;
    function HasObject: Boolean;
    procedure ReleaseObjects; virtual;
    function RemoveObject(AObject: TPressObject): Integer; virtual;
  end;

  TPressDAO = class(TPressService, IPressDAO)
  private
    { TODO : Implement transacted object control }
    FCache: TPressDAOCache;
    FLazyCommit: Boolean;
    FNotifier: TPressNotifier;
    FTransactionLevel: Integer;
    procedure DisposeObject(AObject: TPressObject);
    procedure Notify(AEvent: TPressEvent);
  protected
    procedure DoneService; override;
    function InternalCacheClass: TPressDAOCacheClass; virtual;
    procedure InternalCommit; virtual;
    procedure InternalDispose(AClass: TPressObjectClass; const AId: string); virtual;
    function InternalExecuteStatement(const AStatement: string): Integer; virtual;
    function InternalGenerateOID(AClass: TPressObjectClass; const AAttributeName: string): string; virtual;
    function InternalOQLQuery(const AOQLStatement: string): TPressProxyList; virtual;
    function InternalRetrieve(AClass: TPressObjectClass; const AId: string; AMetadata: TPressObjectMetadata): TPressObject; virtual;
    function InternalRetrieveProxyList(AQuery: TPressQuery): TPressProxyList; virtual;
    procedure InternalRollback; virtual;
    class function InternalServiceType: TPressServiceType; override;
    procedure InternalShowConnectionManager; virtual;
    function InternalSQLProxy(const ASQLStatement: string): TPressProxyList; virtual;
    function InternalSQLQuery(AClass: TPressObjectClass; const ASQLStatement: string): TPressProxyList; virtual;
    procedure InternalStartTransaction; virtual;
    procedure InternalStore(AObject: TPressObject); virtual;
    function UnsupportedFeatureError(const AFeatureName: string): EPressError;
    property Cache: TPressDAOCache read FCache;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure AssignObject(AObject: TPressObject);
    procedure Commit;
    procedure Dispose(AClass: TPressObjectClass; const AId: string);
    function ExecuteStatement(const AStatement: string): Integer;
    function GenerateOID(AClass: TPressObjectClass; const AAttributeName: string = ''): string;
    function OQLQuery(const AOQLStatement: string): TPressProxyList;
    procedure Release(AObject: TPressObject);
    function Retrieve(AClass: TPressObjectClass; const AId: string; AMetadata: TPressObjectMetadata = nil): TPressObject;
    function RetrieveProxyList(AQuery: TPressQuery): TPressProxyList;
    procedure Rollback;
    procedure ShowConnectionManager;
    function SQLProxy(const ASQLStatement: string): TPressProxyList;
    function SQLQuery(AClass: TPressObjectClass; const ASQLStatement: string): TPressProxyList;
    procedure StartTransaction;
    procedure Store(AObject: TPressObject);
    property LazyCommit: Boolean read FLazyCommit write FLazyCommit;
  end;

implementation

uses
  {$IFDEF PressLog}SysUtils, PressLog,{$ENDIF}
  PressConsts;

type
  TPressObjectFriend = class(TPressObject);

  TPressDAOCommit = class(TPressEvent)
  end;

{ TPressDAOCache }

procedure TPressDAOCache.AddObject(AObject: TPressObject);
begin
  ObjectList.Add(AObject);
end;

constructor TPressDAOCache.Create;
begin
  inherited Create;
  FObjectList := TPressObjectList.Create(False);
end;

function TPressDAOCache.CreateIterator: TPressObjectIterator;
begin
  Result := ObjectList.CreateIterator;
end;

destructor TPressDAOCache.Destroy;
begin
  FObjectList.Free;
  inherited;
end;

function TPressDAOCache.FindObject(
  AClass: TPressObjectClass; const AId: string): TPressObject;
var
  I: Integer;
begin
  if AId <> '' then
    for I := 0 to Pred(ObjectList.Count) do
    begin
      Result := ObjectList[I];
      if (Result.PersistentId = AId) and
       (not Assigned(AClass) or (Result.ClassType = AClass)) then
        Exit;
    end;
  Result := nil;
end;

function TPressDAOCache.HasObject: Boolean;
begin
  Result := Assigned(FObjectList) and (FObjectList.Count > 0);
end;

procedure TPressDAOCache.ReleaseObjects;
begin
  { TODO : IsBroken support }
end;

function TPressDAOCache.RemoveObject(AObject: TPressObject): Integer;
begin
  Result := ObjectList.Remove(AObject);
end;

{ TPressDAO }

procedure TPressDAO.AssignObject(AObject: TPressObject);
begin
  FCache.AddObject(AObject);
end;

procedure TPressDAO.Commit;
begin
  if FTransactionLevel < 1 then
    Exit;
  if FTransactionLevel > 1 then
    Dec(FTransactionLevel)
  else if LazyCommit then
    TPressDAOCommit.Create(Self).QueueNotification
  else
  begin
    FTransactionLevel := 0;
    InternalCommit;
  end;
end;

constructor TPressDAO.Create;
begin
  inherited;
  FCache := InternalCacheClass.Create;
  FNotifier := TPressNotifier.Create(Notify);
  FNotifier.AddNotificationItem(Self, [TPressDAOCommit]);
end;

destructor TPressDAO.Destroy;
begin
  FNotifier.Free;
  FCache.Free;
  inherited;
end;

procedure TPressDAO.Dispose(AClass: TPressObjectClass; const AId: string);
var
  VObject: TPressObject;
begin
  StartTransaction;
  try
    { TODO : Improve }
    VObject := Retrieve(AClass, AId);
    try
      if Assigned(VObject) and VObject.IsPersistent then
      begin
        TPressObjectFriend(VObject).BeforeDispose;
        VObject.DisableChanges;
        try
          {$IFDEF PressLogDAOInterface}PressLogMsg(Self, 'Disposing', [VObject]);{$ENDIF}
          TPressObjectFriend(VObject).InternalDispose(DisposeObject);
          PressAssignPersistentId(VObject, '');
        finally
          VObject.EnableChanges;
        end;
        TPressObjectFriend(VObject).AfterDispose;
      end;
    finally
      VObject.Free;
    end;
    Commit;
  except
    Rollback;
    raise;
  end;
end;

procedure TPressDAO.DisposeObject(AObject: TPressObject);
begin
  InternalDispose(AObject.ClassType, AObject.PersistentId);
end;

procedure TPressDAO.DoneService;
begin
  inherited;
  Cache.ReleaseObjects;
end;

function TPressDAO.ExecuteStatement(const AStatement: string): Integer;
begin
  StartTransaction;
  try
    Result := InternalExecuteStatement(AStatement);
    Commit;
  except
    Rollback;
    raise;
  end;
end;

function TPressDAO.GenerateOID(AClass: TPressObjectClass;
  const AAttributeName: string): string;
begin
  Result := InternalGenerateOID(AClass, AAttributeName);
end;

function TPressDAO.InternalCacheClass: TPressDAOCacheClass;
begin
  Result := TPressDAOCache;
end;

procedure TPressDAO.InternalCommit;
begin
  raise UnsupportedFeatureError('Commit transaction');
end;

procedure TPressDAO.InternalDispose(
  AClass: TPressObjectClass; const AId: string);
begin
  raise UnsupportedFeatureError('Dispose object');
end;

function TPressDAO.InternalExecuteStatement(const AStatement: string): Integer;
begin
  raise UnsupportedFeatureError('Execute statement');
end;

function TPressDAO.InternalGenerateOID(AClass: TPressObjectClass;
  const AAttributeName: string): string;
begin
  raise UnsupportedFeatureError('Generator');
end;

function TPressDAO.InternalOQLQuery(
  const AOQLStatement: string): TPressProxyList;
begin
  raise UnsupportedFeatureError('OQL Query');
end;

function TPressDAO.InternalRetrieve(
  AClass: TPressObjectClass; const AId: string;
  AMetadata: TPressObjectMetadata): TPressObject;
begin
  raise UnsupportedFeatureError('Retrieve object');
end;

function TPressDAO.InternalRetrieveProxyList(
  AQuery: TPressQuery): TPressProxyList;

  function SelectPart: string;
  begin
    Result := 'select ' + AQuery.FieldNamesClause;
  end;

  function FromPart: string;
  begin
    Result := AQuery.FromClause;
    if Result <> '' then
      if (AQuery.Style = qsOQL) and AQuery.Metadata.IncludeSubClasses then
        Result := ' from any ' + Result
      else
        Result := ' from ' + Result;
  end;

  function WherePart: string;
  begin
    Result := AQuery.WhereClause;
    if Result <> '' then
      Result := ' where ' + Result;
  end;

  function GroupByPart: string;
  begin
    Result := AQuery.GroupByClause;
    if Result <> '' then
      Result := ' group by ' + Result;
  end;

  function OrderByPart: string;
  begin
    Result := AQuery.OrderByClause;
    if Result <> '' then
      Result := ' order by ' + Result;
  end;

var
  VQueryStr: string;
begin
  VQueryStr := SelectPart + FromPart + WherePart + GroupByPart + OrderByPart;
  {$IFDEF PressLogDAOPersistence}PressLogMsg(Self, 'Querying "' +  VQueryStr + '"');{$ENDIF}
  case AQuery.Style of
    qsOQL:
      Result := OQLQuery(VQueryStr);
    qsReference:
      Result := SQLProxy(VQueryStr);
    else {qsCustom}
      Result := SQLQuery(AQuery.Metadata.ItemObjectClass, VQueryStr);
  end;
end;

procedure TPressDAO.InternalRollback;
begin
  raise UnsupportedFeatureError('Rollback transaction');
end;

class function TPressDAO.InternalServiceType: TPressServiceType;
begin
  Result := CPressDAOService;
end;

procedure TPressDAO.InternalShowConnectionManager;
begin
end;

function TPressDAO.InternalSQLProxy(
  const ASQLStatement: string): TPressProxyList;
begin
  raise UnsupportedFeatureError('SQL Proxy');
end;

function TPressDAO.InternalSQLQuery(
  AClass: TPressObjectClass; const ASQLStatement: string): TPressProxyList;
begin
  raise UnsupportedFeatureError('SQL Query');
end;

procedure TPressDAO.InternalStartTransaction;
begin
  raise UnsupportedFeatureError('Start transaction');
end;

procedure TPressDAO.InternalStore(AObject: TPressObject);
begin
  raise UnsupportedFeatureError('Store object');
end;

procedure TPressDAO.Notify(AEvent: TPressEvent);
begin
  if FTransactionLevel = 1 then
  begin
    FTransactionLevel := 0;
    InternalCommit;
  end;
end;

function TPressDAO.OQLQuery(const AOQLStatement: string): TPressProxyList;
begin
  StartTransaction;
  try
    Result := InternalOQLQuery(AOQLStatement);
    Commit;
  except
    Rollback;
    raise;
  end;
end;

procedure TPressDAO.Release(AObject: TPressObject);
begin
  Cache.RemoveObject(AObject);
end;

function TPressDAO.Retrieve(
  AClass: TPressObjectClass; const AId: string;
  AMetadata: TPressObjectMetadata): TPressObject;
begin
  Result := Cache.FindObject(AClass, AId);
  if Assigned(Result) then
    Result.AddRef
  else
  begin
    StartTransaction;
    try
      {$IFDEF PressLogDAOInterface}PressLogMsg(Self,
       Format('Retrieving %s(%s)', [AClass.ClassName, AId]));{$ENDIF}
      { TODO : Ensure the class type of the retrieved object }
      Result := InternalRetrieve(AClass, AId, AMetadata);
      Commit;
    except
      Rollback;
      raise;
    end;
    if Assigned(Result) then
      TPressObjectFriend(Result).AfterRetrieve;
  end;
end;

function TPressDAO.RetrieveProxyList(AQuery: TPressQuery): TPressProxyList;
begin
  StartTransaction;
  try
    Result := InternalRetrieveProxyList(AQuery);
    Commit;
  except
    Rollback;
    raise;
  end;
end;

procedure TPressDAO.Rollback;
begin
  if FTransactionLevel < 1 then
    Exit;
  Dec(FTransactionLevel);
  if FTransactionLevel = 0 then
    InternalRollback;
end;

procedure TPressDAO.ShowConnectionManager;
begin
  InternalShowConnectionManager;
end;

function TPressDAO.SQLProxy(
  const ASQLStatement: string): TPressProxyList;
begin
  StartTransaction;
  try
    Result := InternalSQLProxy(ASQLStatement);
    Commit;
  except
    Rollback;
    raise;
  end;
end;

function TPressDAO.SQLQuery(AClass: TPressObjectClass; const ASQLStatement: string): TPressProxyList;
begin
  StartTransaction;
  try
    Result := InternalSQLQuery(AClass, ASQLStatement);
    Commit;
  except
    Rollback;
    raise;
  end;
end;

procedure TPressDAO.StartTransaction;
begin
  if FTransactionLevel > 0 then
    Inc(FTransactionLevel)
  else
  begin
    FTransactionLevel := 1;
    InternalStartTransaction;
  end;
end;

procedure TPressDAO.Store(AObject: TPressObject);
begin
  if Assigned(AObject) and not AObject.IsOwned and not AObject.IsUpdated then
  begin
    TPressObjectFriend(AObject).BeforeStore;
    StartTransaction;
    try
      AObject.DisableChanges;
      try
        {$IFDEF PressLogDAOInterface}PressLogMsg(Self, 'Storing', [AObject]);{$ENDIF}
        TPressObjectFriend(AObject).InternalStore(InternalStore);
        PressAssignPersistentId(AObject, AObject.Id);
      finally
        AObject.EnableChanges;
      end;
      AObject.Unchanged;
      Commit;
    except
      Rollback;
      raise;
    end;
    TPressObjectFriend(AObject).AfterStore;
  end;
end;

function TPressDAO.UnsupportedFeatureError(
  const AFeatureName: string): EPressError;
begin
  Result := EPressError.CreateFmt(SUnsupportedFeature, [AFeatureName]);
end;

end.
