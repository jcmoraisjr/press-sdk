(*
  PressObjects, Data Access Classes
  Copyright (C) 2007-2008 Laserpress Ltda.

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
  Classes,
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

  TPressDAOAttributes = class(TObject)
  private
    FList: TStringList;
  public
    constructor Create(const AAttributes: string = '');
    destructor Destroy; override;
    procedure Add(const AAttribute: string);
    procedure AddUnloadedAttributes(AObject: TPressObject; AIncludeLazyLoading: Boolean);
    function IsEmpty: Boolean;
    function Include(AAttribute: TPressAttributeMetadata): Boolean;
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
    procedure Finit; override;
    procedure InternalBulkRetrieve(AProxyList: TPressProxyList; AStartingAt, AItemCount: Integer; AAttributes: TPressDAOAttributes); virtual;
    function InternalCacheClass: TPressDAOCacheClass; virtual;
    procedure InternalCommit; virtual;
    procedure InternalDispose(AClass: TPressObjectClass; const AId: string); virtual;
    function InternalExecuteStatement(const AStatement: string; AParams: TPressParamList): Integer; virtual;
    function InternalGenerateOID(AClass: TPressObjectClass; const AAttributeName: string): string; virtual;
    function InternalImplementsBulkRetrieve: Boolean; virtual;
    function InternalImplementsLazyLoading: Boolean; virtual;
    procedure InternalLoad(AObject: TPressObject; AIncludeLazyLoading: Boolean); virtual;
    function InternalOQLQuery(const AOQLStatement: string; AParams: TPressParamList): TPressProxyList; virtual;
    procedure InternalRefresh(AObject: TPressObject); virtual;
    function InternalRetrieve(AClass: TPressObjectClass; const AId: string; AMetadata: TPressObjectMetadata; AAttributes: TPressDAOAttributes): TPressObject; virtual;
    procedure InternalRetrieveAttribute(AAttribute: TPressAttribute); virtual;
    function InternalRetrieveQuery(AQuery: TPressQuery): TPressProxyList; virtual;
    procedure InternalRollback; virtual;
    class function InternalServiceType: TPressServiceType; override;
    procedure InternalShowConnectionManager; virtual;
    function InternalSQLProxy(const ASQLStatement: string; AParams: TPressParamList): TPressProxyList; virtual;
    function InternalSQLQuery(AClass: TPressObjectClass; const ASQLStatement: string; AParams: TPressParamList): TPressProxyList; virtual;
    procedure InternalStartTransaction; virtual;
    procedure InternalStore(AObject: TPressObject); virtual;
    function UnsupportedFeatureError(const AFeatureName: string): EPressError;
    property Cache: TPressDAOCache read FCache;
  public
    constructor Create; override;
    function CreateObject(AClass: TPressObjectClass; AMetadata: TPressObjectMetadata): TPressObject;
    procedure AssignObject(AObject: TPressObject);
    procedure BulkRetrieve(AProxyList: TPressProxyList; AStartingAt, AItemCount: Integer; const AAttributes: string);
    procedure Commit;
    procedure Dispose(AClass: TPressObjectClass; const AId: string);
    function ExecuteStatement(const AStatement: string; AParams: TPressParamList = nil): Integer;
    function GenerateOID(AClass: TPressObjectClass; const AAttributeName: string = ''): string;
    procedure Load(AObject: TPressObject; AIncludeLazyLoading: Boolean = True);
    function OQLQuery(const AOQLStatement: string; AParams: TPressParamList = nil): TPressProxyList;
    procedure Refresh(AObject: TPressObject);
    procedure ReleaseObject(AObject: TPressObject);
    function Retrieve(AClass: TPressObjectClass; const AId: string; AMetadata: TPressObjectMetadata = nil; const AAttributes: string = ''): TPressObject;
    procedure RetrieveAttribute(AAttribute: TPressAttribute);
    function RetrieveQuery(AQuery: TPressQuery): TPressProxyList;
    procedure Rollback;
    procedure ShowConnectionManager;
    function SQLProxy(const ASQLStatement: string; AParams: TPressParamList = nil): TPressProxyList;
    function SQLQuery(AClass: TPressObjectClass; const ASQLStatement: string; AParams: TPressParamList = nil): TPressProxyList;
    procedure StartTransaction;
    procedure Store(AObject: TPressObject);
    procedure SynchronizeProxy(AProxy: TPressProxy);
    property LazyCommit: Boolean read FLazyCommit write FLazyCommit;
  end;

implementation

uses
  SysUtils,
{$IFDEF PressLog}
  PressLog,
{$ENDIF}
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
       (not Assigned(AClass) or (Result.ClassType.InheritsFrom(AClass))) then
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

{ TPressDAOAttributes }

procedure TPressDAOAttributes.Add(const AAttribute: string);
begin
  FList.Add(AAttribute);
end;

procedure TPressDAOAttributes.AddUnloadedAttributes(
  AObject: TPressObject; AIncludeLazyLoading: Boolean);
var
  VAttribute: TPressAttribute;
begin
  with AObject.CreateAttributeIterator do
  try
    BeforeFirstItem;
    while NextItem do
    begin
      VAttribute := CurrentItem;
      if VAttribute.IsPersistent and
       (AIncludeLazyLoading or not VAttribute.Metadata.LazyLoad) and
       (VAttribute.State = asNotLoaded) then
        Add(VAttribute.Metadata.Name);
    end;
  finally
    Free;
  end;
end;

constructor TPressDAOAttributes.Create(const AAttributes: string);
begin
  inherited Create;
  FList := TStringList.Create;
  FList.Sorted := True;
  FList.Duplicates := dupError;
  FList.CommaText := StringReplace(AAttributes, ';', ',', [rfReplaceAll]);
end;

destructor TPressDAOAttributes.Destroy;
begin
  FList.Free;
  inherited;
end;

function TPressDAOAttributes.Include(
  AAttribute: TPressAttributeMetadata): Boolean;
var
  VAttribute: string;
  VPos: Integer;
begin
  Result := ((FList.Count = 0) and not AAttribute.LazyLoad) or
   (FList.Count = 1) and (FList[0] = '*');
  if not Result and (FList.Count > 0) then
  begin
    VAttribute := AAttribute.Name;
    Result := FList.Find(VAttribute, VPos);
    if not Result and (VPos < FList.Count) then
      Result := Copy(FList[VPos], 1, Length(VAttribute) + 1) =
       VAttribute + SPressAttributeSeparator;
  end;
end;

function TPressDAOAttributes.IsEmpty: Boolean;
begin
  Result := FList.Count = 0;
end;

{ TPressDAO }

procedure TPressDAO.AssignObject(AObject: TPressObject);
begin
  FCache.AddObject(AObject);
end;

procedure TPressDAO.BulkRetrieve(
  AProxyList: TPressProxyList; AStartingAt, AItemCount: Integer;
  const AAttributes: string);
var
  VAttributes: TPressDAOAttributes;
begin
  if not InternalImplementsBulkRetrieve then
    Exit;
  StartTransaction;
  try
    VAttributes := TPressDAOAttributes.Create(AAttributes);
    try
      InternalBulkRetrieve(AProxyList, AStartingAt, AItemCount, VAttributes);
    finally
      VAttributes.Free;
    end;
    Commit;
  except
    Rollback;
    raise;
  end;
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
  FNotifier := TPressNotifier.Create({$IFDEF FPC}@{$ENDIF}Notify);
  FNotifier.AddNotificationItem(Self, [TPressDAOCommit]);
end;

function TPressDAO.CreateObject(AClass: TPressObjectClass;
  AMetadata: TPressObjectMetadata): TPressObject;
begin
  Result := TPressObject(AClass.NewInstance);
  try
    // lacks inherited Create
    TPressObjectFriend(Result).InitInstance(Self, AMetadata, True);
  except
    FreeAndNil(Result);
    raise;
  end;
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
{$IFDEF PressLogDAOInterface}
          PressLogMsg(Self, 'Disposing', [VObject]);
{$ENDIF}
          TPressObjectFriend(VObject).InternalDispose(
           {$IFDEF FPC}@{$ENDIF}DisposeObject);
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
  if Assigned(Cache) then
    Cache.ReleaseObjects;
end;

function TPressDAO.ExecuteStatement(
  const AStatement: string; AParams: TPressParamList): Integer;
begin
  StartTransaction;
  try
    Result := InternalExecuteStatement(AStatement, AParams);
    Commit;
  except
    Rollback;
    raise;
  end;
end;

procedure TPressDAO.Finit;
begin
  FNotifier.Free;
  FCache.Free;
  inherited;
end;

function TPressDAO.GenerateOID(AClass: TPressObjectClass;
  const AAttributeName: string): string;
begin
  Result := InternalGenerateOID(AClass, AAttributeName);
end;

procedure TPressDAO.InternalBulkRetrieve(
  AProxyList: TPressProxyList; AStartingAt, AItemCount: Integer;
  AAttributes: TPressDAOAttributes);
begin
  raise UnsupportedFeatureError('Bulk retrieve');
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

function TPressDAO.InternalExecuteStatement(
  const AStatement: string; AParams: TPressParamList): Integer;
begin
  raise UnsupportedFeatureError('Execute statement');
end;

function TPressDAO.InternalGenerateOID(AClass: TPressObjectClass;
  const AAttributeName: string): string;
begin
  raise UnsupportedFeatureError('Generator');
end;

function TPressDAO.InternalImplementsBulkRetrieve: Boolean;
begin
  Result := False;
end;

function TPressDAO.InternalImplementsLazyLoading: Boolean;
begin
  Result := False;
end;

procedure TPressDAO.InternalLoad(
  AObject: TPressObject; AIncludeLazyLoading: Boolean);
begin
  raise UnsupportedFeatureError('Load object');
end;

function TPressDAO.InternalOQLQuery(
  const AOQLStatement: string; AParams: TPressParamList): TPressProxyList;
begin
  raise UnsupportedFeatureError('OQL Query');
end;

procedure TPressDAO.InternalRefresh(AObject: TPressObject);
begin
  raise UnsupportedFeatureError('Refresh object');
end;

function TPressDAO.InternalRetrieve(
  AClass: TPressObjectClass; const AId: string;
  AMetadata: TPressObjectMetadata; AAttributes: TPressDAOAttributes): TPressObject;
begin
  raise UnsupportedFeatureError('Retrieve object');
end;

procedure TPressDAO.InternalRetrieveAttribute(AAttribute: TPressAttribute);
begin
  raise UnsupportedFeatureError('Retrieve attribute');
end;

function TPressDAO.InternalRetrieveQuery(
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
      Result := OQLQuery(VQueryStr, AQuery.Params);
    qsReference:
      Result := SQLProxy(VQueryStr, AQuery.Params);
    else {qsCustom}
      Result := SQLQuery(
       AQuery.Metadata.ItemObjectClass, VQueryStr, AQuery.Params);
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
  const ASQLStatement: string; AParams: TPressParamList): TPressProxyList;
begin
  raise UnsupportedFeatureError('SQL Proxy');
end;

function TPressDAO.InternalSQLQuery(AClass: TPressObjectClass;
  const ASQLStatement: string; AParams: TPressParamList): TPressProxyList;
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

procedure TPressDAO.Load(AObject: TPressObject; AIncludeLazyLoading: Boolean);
begin
  if not InternalImplementsLazyLoading then
    Exit;
  StartTransaction;
  try
    AObject.DisableChanges;
    try
      InternalLoad(AObject, AIncludeLazyLoading);
    finally
      AObject.EnableChanges;
    end;
    Commit;
  except
    Rollback;
    raise;
  end;
end;

procedure TPressDAO.Notify(AEvent: TPressEvent);
begin
  if FTransactionLevel = 1 then
  begin
    FTransactionLevel := 0;
    InternalCommit;
  end;
end;

function TPressDAO.OQLQuery(
  const AOQLStatement: string; AParams: TPressParamList): TPressProxyList;
begin
  StartTransaction;
  try
    Result := InternalOQLQuery(AOQLStatement, AParams);
    Commit;
  except
    Rollback;
    raise;
  end;
end;

procedure TPressDAO.Refresh(AObject: TPressObject);
begin
  if not AObject.IsPersistent then
    Exit;
  StartTransaction;
  try
    AObject.DisableChanges;
    try
{$IFDEF PressLogDAOInterface}
      PressLogMsg(Self, 'Refresh', [AObject]);
{$ENDIF}
      TPressObjectFriend(AObject).InternalRefresh(
       {$IFDEF FPC}@{$ENDIF}InternalRefresh);
    finally
      AObject.EnableChanges;
    end;
    AObject.Unchanged;
    Commit;
  except
    Rollback;
    raise;
  end;
end;

procedure TPressDAO.ReleaseObject(AObject: TPressObject);
begin
  Cache.RemoveObject(AObject);
end;

function TPressDAO.Retrieve(
  AClass: TPressObjectClass; const AId: string;
  AMetadata: TPressObjectMetadata; const AAttributes: string): TPressObject;
var
  VAttributes: TPressDAOAttributes;
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
      VAttributes := TPressDAOAttributes.Create(AAttributes);
      try
        Result := InternalRetrieve(AClass, AId, AMetadata, VAttributes);
      finally
        VAttributes.Free;
      end;
      Commit;
    except
      Rollback;
      raise;
    end;
    if Assigned(Result) then
      TPressObjectFriend(Result).AfterRetrieve;
  end;
end;

procedure TPressDAO.RetrieveAttribute(AAttribute: TPressAttribute);
begin
  if not InternalImplementsLazyLoading then
    Exit;
  StartTransaction;
  try
    AAttribute.DisableChanges;
    try
      InternalRetrieveAttribute(AAttribute);
    finally
      AAttribute.EnableChanges;
    end;
    Commit;
  except
    Rollback;
    raise;
  end;
end;

function TPressDAO.RetrieveQuery(AQuery: TPressQuery): TPressProxyList;
begin
  StartTransaction;
  try
    Result := InternalRetrieveQuery(AQuery);
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
  const ASQLStatement: string; AParams: TPressParamList): TPressProxyList;
begin
  StartTransaction;
  try
    Result := InternalSQLProxy(ASQLStatement, AParams);
    Commit;
  except
    Rollback;
    raise;
  end;
end;

function TPressDAO.SQLQuery(AClass: TPressObjectClass;
  const ASQLStatement: string; AParams: TPressParamList): TPressProxyList;
begin
  StartTransaction;
  try
    Result := InternalSQLQuery(AClass, ASQLStatement, AParams);
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
    AObject.Lock;
    try
      TPressObjectFriend(AObject).BeforeStore;
      StartTransaction;
      try
        AObject.DisableChanges;
        try
{$IFDEF PressLogDAOInterface}
          PressLogMsg(Self, 'Storing', [AObject]);
{$ENDIF}
          TPressObjectFriend(AObject).InternalStore(
           {$IFDEF FPC}@{$ENDIF}InternalStore);
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
    finally
      AObject.Unlock;
    end;
  end;
end;

procedure TPressDAO.SynchronizeProxy(AProxy: TPressProxy);
var
  VObject: TPressObject;
begin
  if not AProxy.HasInstance and AProxy.HasReference then
  begin
    VObject := Cache.FindObject(AProxy.ObjectClassType, AProxy.ObjectId);
    if Assigned(VObject) then
    begin
      { TODO : Lock between assignment and AddRef call }
      AProxy.Instance := VObject;
      if AProxy.ProxyType = ptOwned then
        VObject.AddRef;
    end;
  end;
end;

function TPressDAO.UnsupportedFeatureError(
  const AFeatureName: string): EPressError;
begin
  Result := EPressError.CreateFmt(SUnsupportedFeature, [AFeatureName]);
end;

end.
