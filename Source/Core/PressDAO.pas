(*
  PressObjects, Data Access Object Classes
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
    procedure ReleaseObjects; virtual;
    function RemoveObject(AObject: TPressObject): Integer; virtual;
  end;

  TPressDAO = class(TPressService, IPressDAO)
  private
    FCache: TPressDAOCache;
    procedure DisposeObject(AObject: TPressObject);
  protected
    procedure DoneService; override;
    function InternalCacheClass: TPressDAOCacheClass; virtual;
    procedure InternalCommit; virtual;
    procedure InternalDispose(AClass: TPressObjectClass; const AId: string); virtual;
    procedure InternalExecuteStatement(const AStatement: string); virtual;
    function InternalGenerateOID(AClass: TPressObjectClass; const AAttributeName: string): string; virtual;
    function InternalOQLQuery(const AOQLStatement: string): TPressProxyList; virtual;
    function InternalRetrieve(AClass: TPressObjectClass; const AId: string; AMetadata: TPressObjectMetadata): TPressObject; virtual;
    function InternalRetrieveProxyList(AQuery: TPressQuery): TPressProxyList; virtual;
    procedure InternalRollback; virtual;
    class function InternalServiceType: TPressServiceType; override;
    procedure InternalShowConnectionManager; virtual;
    function InternalSQLForObject(const ASQLStatement: string): TPressProxyList; virtual;
    function InternalSQLQuery(AClass: TPressObjectClass; const ASQLStatement: string): TPressProxyList; virtual;
    procedure InternalStartTransaction; virtual;
    procedure InternalStore(AObject: TPressObject); virtual;
    function UnsupportedFeatureError(const AFeatureName: string): EPressError;
    property Cache: TPressDAOCache read FCache;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Assign(AObject: TPressObject);
    procedure Commit;
    procedure Dispose(AClass: TPressObjectClass; const AId: string);
    procedure ExecuteStatement(const AStatement: string);
    function GenerateOID(AClass: TPressObjectClass; const AAttributeName: string = ''): string;
    function OQLQuery(const AOQLStatement: string): TPressProxyList;
    procedure Release(AObject: TPressObject);
    function Retrieve(AClass: TPressObjectClass; const AId: string; AMetadata: TPressObjectMetadata = nil): TPressObject;
    function RetrieveProxyList(AQuery: TPressQuery): TPressProxyList;
    procedure Rollback;
    procedure ShowConnectionManager;
    function SQLForObject(const ASQLStatement: string): TPressProxyList;
    function SQLQuery(AClass: TPressObjectClass; const ASQLStatement: string): TPressProxyList;
    procedure StartTransaction;
    procedure Store(AObject: TPressObject);
  end;

implementation

uses
  PressConsts
  {$IFDEF PressLog}, PressLog{$ENDIF};

type
  TPressObjectFriend = class(TPressObject);

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

procedure TPressDAOCache.ReleaseObjects;
begin
  { TODO : IsBroken support }
end;

function TPressDAOCache.RemoveObject(AObject: TPressObject): Integer;
begin
  Result := ObjectList.Remove(AObject);
end;

{ TPressDAO }

procedure TPressDAO.Assign(AObject: TPressObject);
begin
  FCache.AddObject(AObject);
end;

procedure TPressDAO.Commit;
begin
  InternalCommit;
end;

constructor TPressDAO.Create;
begin
  inherited;
  FCache := InternalCacheClass.Create;
end;

destructor TPressDAO.Destroy;
begin
  FCache.Free;
  inherited;
end;

procedure TPressDAO.Dispose(AClass: TPressObjectClass; const AId: string);
var
  VObject: TPressObject;
begin
  { TODO : Improve }
  VObject := Retrieve(AClass, AId);
  try
    if Assigned(VObject) and VObject.IsPersistent then
    begin
      TPressObjectFriend(VObject).BeforeDispose;
      StartTransaction;
      try
        VObject.DisableChanges;
        try
          {$IFDEF PressLogDAO}PressLogMsg(Self, 'Disposing', [VObject]);{$ENDIF}
          TPressObjectFriend(VObject).InternalDispose(DisposeObject);
          Cache.RemoveObject(VObject);
          PressAssignPersistentId(VObject, '');
        finally
          VObject.EnableChanges;
        end;
        Commit;
      except
        Rollback;
        raise;
      end;
      TPressObjectFriend(VObject).AfterDispose;
    end;
  finally
    VObject.Free;
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

procedure TPressDAO.ExecuteStatement(const AStatement: string);
begin
  InternalExecuteStatement(AStatement);
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

procedure TPressDAO.InternalExecuteStatement(const AStatement: string);
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
begin
  raise UnsupportedFeatureError('Retrieve proxy list');
end;

procedure TPressDAO.InternalRollback;
begin
  raise UnsupportedFeatureError('Rollback transaction');
end;

class function TPressDAO.InternalServiceType: TPressServiceType;
begin
  Result := stDAO;
end;

procedure TPressDAO.InternalShowConnectionManager;
begin
end;

function TPressDAO.InternalSQLForObject(
  const ASQLStatement: string): TPressProxyList;
begin
  raise UnsupportedFeatureError('SQL Query');
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

function TPressDAO.OQLQuery(const AOQLStatement: string): TPressProxyList;
begin
  Result := InternalOQLQuery(AOQLStatement);
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
    {$IFDEF PressLogDAO}PressLogMsg(Self,
     Format('Retrieving %s(%s)', [AClass.ClassName, AId]));{$ENDIF}
    { TODO : Ensure the class type of the retrieved object }
    Result := InternalRetrieve(AClass, AId, AMetadata);
    if Assigned(Result) then
      TPressObjectFriend(Result).AfterRetrieve;
  end;
end;

function TPressDAO.RetrieveProxyList(AQuery: TPressQuery): TPressProxyList;
begin
  Result := InternalRetrieveProxyList(AQuery);
end;

procedure TPressDAO.Rollback;
begin
  InternalRollback;
end;

procedure TPressDAO.ShowConnectionManager;
begin
  InternalShowConnectionManager;
end;

function TPressDAO.SQLForObject(
  const ASQLStatement: string): TPressProxyList;
begin
  Result := InternalSQLForObject(ASQLStatement);
end;

function TPressDAO.SQLQuery(AClass: TPressObjectClass; const ASQLStatement: string): TPressProxyList;
begin
  Result := InternalSQLQuery(AClass, ASQLStatement);
end;

procedure TPressDAO.StartTransaction;
begin
  InternalStartTransaction;
end;

procedure TPressDAO.Store(AObject: TPressObject);
var
  VId: string;
begin
  if Assigned(AObject) and not AObject.IsOwned and not AObject.IsUpdated then
  begin
    TPressObjectFriend(AObject).BeforeStore;
    VId := AObject.Id;
    StartTransaction;
    try
      AObject.DisableChanges;
      try
        {$IFDEF PressLogDAO}PressLogMsg(Self, 'Storing', [AObject]);{$ENDIF}
        TPressObjectFriend(AObject).InternalStore(InternalStore);
        PressAssignPersistentId(AObject, VId);
        AObject.Unchanged;
      finally
        AObject.EnableChanges;
      end;
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
