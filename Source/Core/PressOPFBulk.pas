(*
  PressObjects, Persistence Bulk Operations Classes
  Copyright (C) 2008 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressOPFBulk;

{$I Press.inc}

interface

uses
  Contnrs,
  PressClasses,
  PressSubject,
  PressPersistence,
  PressOPFMapper,
  PressOPFStorage;

type
  TPressOPFBulkProxy = class;
  TPressOPFBulkProxyList = class;
  TPressOPFCustomBulkMap = class;

  TPressOPFCustomBulkRetrieve = class(TObject)
  private
    FMaps: TObjectList;
    FObjectMapper: TPressOPFObjectMapper;
    FPersistence: TPressPersistence;
    FProxyList: TPressOPFBulkProxyList;
    function GetProxyList: TPressOPFBulkProxyList;
  protected
    procedure AddMap(AClass: TPressObjectClass);
    procedure CreateMaps;
    function InternalCreateMap(AClass: TPressObjectClass): TPressOPFCustomBulkMap; virtual; abstract;
    function InternalOwnsProxy: Boolean; virtual; abstract;
    procedure RetrieveMaps;
    property Persistence: TPressPersistence read FPersistence;
    property ProxyList: TPressOPFBulkProxyList read GetProxyList;
  public
    constructor Create(AObjectMapper: TPressOPFObjectMapper);
    destructor Destroy; override;
    function CreateProxyListByClass(AClass: TPressObjectClass): TPressOPFBulkProxyList;
    property ObjectMapper: TPressOPFObjectMapper read FObjectMapper;
  end;

  TPressOPFBulkRetrieve = class(TPressOPFCustomBulkRetrieve)
  private
    FDepth: Integer;
    FSourceProxyList: TPressProxyList;
    procedure AfterRetrieveEvent;
  protected
    procedure CreateProxies(AStartingAt, AItemCount: Integer);
    function InternalCreateMap(AClass: TPressObjectClass): TPressOPFCustomBulkMap; override;
    function InternalOwnsProxy: Boolean; override;
    procedure UpdateProxies;
  public
    constructor Create(AObjectMapper: TPressOPFObjectMapper; ASourceProxyList: TPressProxyList; ADepth: Integer);
    procedure Execute(AStartingAt, AItemCount: Integer);
  end;

  TPressOPFBulkRetrieveComplementary = class(TPressOPFCustomBulkRetrieve)
  private
    FBaseClass: TPressObjectClass;
    FSourceProxyList: TPressOPFBulkProxyList;
  protected
    procedure CreateProxies;
    function InternalCreateMap(AClass: TPressObjectClass): TPressOPFCustomBulkMap; override;
    function InternalOwnsProxy: Boolean; override;
  public
    constructor Create(AObjectMapper: TPressOPFObjectMapper; ASourceProxyList: TPressOPFBulkProxyList; ABaseClass: TPressObjectClass);
    procedure Execute;
  end;

  TPressOPFBulkRefresh = class(TPressOPFCustomBulkRetrieve)
  private
    FSourceProxyList: TPressProxyList;
  protected
    procedure CreateProxies;
    function InternalCreateMap(AClass: TPressObjectClass): TPressOPFCustomBulkMap; override;
    function InternalOwnsProxy: Boolean; override;
  public
    constructor Create(AObjectMapper: TPressOPFObjectMapper; ASourceProxyList: TPressProxyList);
    procedure Execute;
  end;

  TPressOPFBulkProxy = class(TObject)
  private
    FInstance: TPressObject;
    FObjectClass: TPressObjectClass;
    FObjectId: string;
    FProxyList: TObjectList;
    procedure SetInstance(AValue: TPressObject);
  public
    constructor Create(AProxy: TPressProxy);
    destructor Destroy; override;
    procedure AddProxy(AProxy: TPressProxy);
    procedure UpdateProxy;
    property Instance: TPressObject read FInstance write SetInstance;
    property ObjectClass: TPressObjectClass read FObjectClass;
    property ObjectId: string read FObjectId;
  end;

  TPressOPFBulkProxyIterator = class;

  TPressOPFBulkProxyList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressOPFBulkProxy;
    procedure SetItems(AIndex: Integer; AValue: TPressOPFBulkProxy);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AProxy: TPressOPFBulkProxy): Integer;
    procedure AddProxy(AProxy: TPressProxy);
    procedure AssignInstances(AInstances: TPressObjectList);
    function CreateIterator: TPressOPFBulkProxyIterator;
    function IndexOfInstanceRef(AInstance: TPressObject): Integer;
    function IndexOfProxy(AProxy: TPressProxy): Integer;
    property Items[AIndex: Integer]: TPressOPFBulkProxy read GetItems write SetItems; default;
  end;

  TPressOPFBulkProxyIterator = class(TPressIterator)
  end;

  TPressOPFCustomBulkMap = class(TObject)
  private
    FMaps: TPressOPFStorageMapList;
    FObjectMapper: TPressOPFObjectMapper;
    FProxyList: TPressOPFBulkProxyList;
  protected
    function BuildIDs: TPressStringArray;
    function CreateObjectArray: TPressObjectArray;
  public
    constructor Create(AOwner: TPressOPFCustomBulkRetrieve; AClass: TPressObjectClass);
    destructor Destroy; override;
    procedure Retrieve; virtual;
    property Maps: TPressOPFStorageMapList read FMaps;
    property ObjectMapper: TPressOPFObjectMapper read FObjectMapper;
    property ProxyList: TPressOPFBulkProxyList read FProxyList;
  end;

  TPressOPFBulkMap = class(TPressOPFCustomBulkMap)
  private
    FDepth: Integer;
  protected
    procedure RetrieveBaseMaps;
    procedure RetrieveComplementaryMaps;
  public
    constructor Create(AOwner: TPressOPFBulkRetrieve; AClass: TPressObjectClass; ADepth: Integer);
    procedure Retrieve; override;
  end;

  TPressOPFBulkMapComplementary = class(TPressOPFCustomBulkMap)
  private
    FBaseClass: TPressObjectClass;
  public
    constructor Create(AOwner: TPressOPFBulkRetrieveComplementary; AClass, ABaseClass: TPressObjectClass);
    procedure Retrieve; override;
  end;

  TPressOPFBulkMapRefresh = class(TPressOPFCustomBulkMap)
  public
    procedure Retrieve; override;
  end;

implementation

{$IFDEF PressLog}
uses
  PressLog;
{$ENDIF}

{ TPressOPFCustomBulkRetrieve }

procedure TPressOPFCustomBulkRetrieve.AddMap(AClass: TPressObjectClass);
var
  VMap: TPressOPFCustomBulkMap;
begin
  if not Assigned(FMaps) then
    FMaps := TObjectList.Create(True);
  VMap := InternalCreateMap(AClass);
  try
    FMaps.Add(VMap);
  except
    VMap.Free;
    raise;
  end;
end;

constructor TPressOPFCustomBulkRetrieve.Create(AObjectMapper: TPressOPFObjectMapper);
begin
  inherited Create;
  FObjectMapper := AObjectMapper;
  FPersistence := AObjectMapper.Persistence;
end;

procedure TPressOPFCustomBulkRetrieve.CreateMaps;

  function ClassExists(AClasses: TPressObjectClassArray;
    ALength: Integer; AClass: TPressObjectClass): Boolean;

    function CommonBasePersistentClass(
      AClass1, AClass2: TPressObjectClass): TPressObjectClass;
    var
      VMetadata: TPressObjectMetadata;
    begin
      VMetadata := AClass1.ClassMetadata;
      while Assigned(VMetadata) and VMetadata.IsPersistent and
       not VMetadata.ObjectClass.InheritsFrom(AClass2) do
        VMetadata := VMetadata.Parent;
      if Assigned(VMetadata) and VMetadata.IsPersistent then
        Result := VMetadata.ObjectClass
      else
        Result := nil;
    end;

  var
    VCommonClass: TPressObjectClass;
    I: Integer;
  begin
    Result := True;
    for I := 0 to Pred(ALength) do
      if not AClass.InheritsFrom(AClasses[I]) then
      begin
        VCommonClass := CommonBasePersistentClass(AClass, AClasses[I]);
        if Assigned(VCommonClass) then
        begin
          AClasses[I] := VCommonClass;
          Exit;
        end;
      end else
        Exit;
    Result := False;
  end;

var
  VClass: TPressObjectClass;
  VClasses: TPressObjectClassArray;
  I, J: Integer;
begin
  if not Assigned(FProxyList) then
    Exit;
  SetLength(VClasses, FProxyList.Count);
  J := 0;
  for I := 0 to Pred(FProxyList.Count) do
  begin
    VClass := FProxyList[I].ObjectClass;
    if not ClassExists(VClasses, J, VClass) then
    begin
      VClasses[J] := VClass;
      Inc(J);
    end;
  end;
  for I := 0 to Pred(J) do
    AddMap(VClasses[I]);
end;

function TPressOPFCustomBulkRetrieve.CreateProxyListByClass(
  AClass: TPressObjectClass): TPressOPFBulkProxyList;
var
  VProxy: TPressOPFBulkProxy;
  I: Integer;
begin
  Result := TPressOPFBulkProxyList.Create(False);
  try
    if Assigned(FProxyList) then
      for I := 0 to Pred(FProxyList.Count) do
      begin
        VProxy := FProxyList[I];
        if VProxy.ObjectClass.InheritsFrom(AClass) then
          Result.Add(VProxy);
      end;
  except
    Result.Free;
    raise;
  end;
end;

destructor TPressOPFCustomBulkRetrieve.Destroy;
begin
  FMaps.Free;
  FProxyList.Free;
  inherited;
end;

function TPressOPFCustomBulkRetrieve.GetProxyList: TPressOPFBulkProxyList;
begin
  if not Assigned(FProxyList) then
    FProxyList := TPressOPFBulkProxyList.Create(InternalOwnsProxy);
  Result := FProxyList;
end;

procedure TPressOPFCustomBulkRetrieve.RetrieveMaps;
var
  I: Integer;
begin
  if Assigned(FMaps) then
    for I := 0 to Pred(FMaps.Count) do
      (FMaps[I] as TPressOPFCustomBulkMap).Retrieve;
end;

{ TPressOPFBulkRetrieve }

type
  TPressObjectFriend = class(TPressObject);
procedure TPressOPFBulkRetrieve.AfterRetrieveEvent;
var
  VInstance: TPressObject;
  I: Integer;
begin
  { TODO : Implement AfterRetrieve event in the DAO class }
  if Assigned(FProxyList) then  // friend class
    for I := 0 to Pred(FProxyList.Count) do
    begin
      VInstance := FProxyList[I].Instance;
      if Assigned(VInstance) then
        TPressObjectFriend(VInstance).AfterRetrieve;
    end;
end;

constructor TPressOPFBulkRetrieve.Create(
  AObjectMapper: TPressOPFObjectMapper;
  ASourceProxyList: TPressProxyList; ADepth: Integer);
begin
  inherited Create(AObjectMapper);
  FSourceProxyList := ASourceProxyList;
  FDepth := ADepth;
end;

procedure TPressOPFBulkRetrieve.CreateProxies(
  AStartingAt, AItemCount: Integer);
var
  VProxy: TPressProxy;
  I, J: Integer;
begin
  I := 0;
  J := AStartingAt;
  while (I < AItemCount) and (J < FSourceProxyList.Count) do
  begin
    VProxy := FSourceProxyList[J];
    Persistence.SynchronizeProxy(VProxy);
    if VProxy.HasReference and not VProxy.HasInstance then
    begin
      ProxyList.AddProxy(VProxy);
      Inc(I);
    end;
    Inc(J);
  end;
end;

procedure TPressOPFBulkRetrieve.Execute(
  AStartingAt, AItemCount: Integer);
begin
  CreateProxies(AStartingAt, AItemCount);
  CreateMaps;
  RetrieveMaps;
  AfterRetrieveEvent;
  UpdateProxies;
end;

function TPressOPFBulkRetrieve.InternalCreateMap(
  AClass: TPressObjectClass): TPressOPFCustomBulkMap;
begin
  Result := TPressOPFBulkMap.Create(Self, AClass, FDepth);
end;

function TPressOPFBulkRetrieve.InternalOwnsProxy: Boolean;
begin
  Result := True;
end;

procedure TPressOPFBulkRetrieve.UpdateProxies;
var
  I: Integer;
begin
  if Assigned(FProxyList) then  // friend class
    for I := 0 to Pred(FProxyList.Count) do
      FProxyList[I].UpdateProxy;
end;

{ TPressOPFBulkRetrieveComplementary }

constructor TPressOPFBulkRetrieveComplementary.Create(
  AObjectMapper: TPressOPFObjectMapper;
  ASourceProxyList: TPressOPFBulkProxyList; ABaseClass: TPressObjectClass);
begin
  inherited Create(AObjectMapper);
  FSourceProxyList := ASourceProxyList;
  FBaseClass := ABaseClass;
end;

procedure TPressOPFBulkRetrieveComplementary.CreateProxies;
var
  VProxy: TPressOPFBulkProxy;
  I: Integer;
begin
  for I := 0 to Pred(FSourceProxyList.Count) do
  begin
    VProxy := FSourceProxyList[I];
    if (VProxy.ObjectClass <> FBaseClass) and
     VProxy.ObjectClass.InheritsFrom(FBaseClass) then
      ProxyList.Add(VProxy);
  end;
end;

procedure TPressOPFBulkRetrieveComplementary.Execute;
begin
  CreateProxies;
  CreateMaps;
  RetrieveMaps;
end;

function TPressOPFBulkRetrieveComplementary.InternalCreateMap(
  AClass: TPressObjectClass): TPressOPFCustomBulkMap;
begin
  Result := TPressOPFBulkMapComplementary.Create(Self, AClass, FBaseClass);
end;

function TPressOPFBulkRetrieveComplementary.InternalOwnsProxy: Boolean;
begin
  Result := False;
end;

{ TPressOPFBulkRefresh }

constructor TPressOPFBulkRefresh.Create(
  AObjectMapper: TPressOPFObjectMapper;
  ASourceProxyList: TPressProxyList);
begin
  inherited Create(AObjectMapper);
  FSourceProxyList := ASourceProxyList;
end;

procedure TPressOPFBulkRefresh.CreateProxies;
var
  VProxy: TPressProxy;
  I: Integer;
begin
  if Assigned(FSourceProxyList) then
    for I := 0 to Pred(FSourceProxyList.Count) do
    begin
      VProxy := FSourceProxyList[I];
      if VProxy.HasInstance then
        ProxyList.AddProxy(VProxy);
    end;
end;

procedure TPressOPFBulkRefresh.Execute;
begin
  CreateProxies;
  CreateMaps;
  RetrieveMaps;
end;

function TPressOPFBulkRefresh.InternalCreateMap(
  AClass: TPressObjectClass): TPressOPFCustomBulkMap;
begin
  Result := TPressOPFBulkMapRefresh.Create(Self, AClass);
end;

function TPressOPFBulkRefresh.InternalOwnsProxy: Boolean;
begin
  Result := True;
end;

{ TPressOPFBulkProxy }

procedure TPressOPFBulkProxy.AddProxy(AProxy: TPressProxy);
begin
  FProxyList.Add(AProxy);
  if not Assigned(FInstance) and AProxy.HasInstance then
    Instance := AProxy.Instance;
end;

constructor TPressOPFBulkProxy.Create(AProxy: TPressProxy);
begin
  inherited Create;
  FProxyList := TObjectList.Create(False);
  FObjectId := AProxy.ObjectId;
  FObjectClass := AProxy.ObjectClassType;
  if AProxy.HasInstance then
    Instance := AProxy.Instance;
  FProxyList.Add(AProxy);
end;

destructor TPressOPFBulkProxy.Destroy;
begin
  if Assigned(FInstance) then
  begin
    FInstance.EnableChanges;
    FInstance.Free;
  end;
  FProxyList.Free;
  inherited;
end;

procedure TPressOPFBulkProxy.SetInstance(AValue: TPressObject);
begin
  if Assigned(FInstance) then
  begin
    FInstance.EnableChanges;
    FInstance.Free;
  end;
  FInstance := AValue;
  FInstance.AddRef;
  FInstance.DisableChanges;
  FObjectClass := FInstance.ClassType;
end;

procedure TPressOPFBulkProxy.UpdateProxy;
var
  VProxy: TPressProxy;
  I: Integer;
begin
  for I := 0 to Pred(FProxyList.Count) do
  begin
    VProxy := FProxyList[I] as TPressProxy;
    VProxy.Instance := FInstance;
    if VProxy.ProxyType = ptOwned then
      FInstance.AddRef;
  end;
end;

{ TPressOPFBulkProxyList }

function TPressOPFBulkProxyList.Add(AProxy: TPressOPFBulkProxy): Integer;
begin
  Result := inherited Add(AProxy);
end;

procedure TPressOPFBulkProxyList.AddProxy(AProxy: TPressProxy);
var
  VProxy: TPressOPFBulkProxy;
  VIndex: Integer;
begin
  VIndex := IndexOfProxy(AProxy);
  if VIndex = -1 then
  begin
    VProxy := TPressOPFBulkProxy.Create(AProxy);
    Add(VProxy);
  end else
  begin
    VProxy := Items[VIndex];
    VProxy.AddProxy(AProxy);
  end;
end;

procedure TPressOPFBulkProxyList.AssignInstances(AInstances: TPressObjectList);
var
  VIndex, I: Integer;
begin
  for I := 0 to Pred(AInstances.Count) do
  begin
    VIndex := IndexOfInstanceRef(AInstances[I]);
    if VIndex >= 0 then
      Items[VIndex].Instance := AInstances[I];
  end;
end;

function TPressOPFBulkProxyList.CreateIterator: TPressOPFBulkProxyIterator;
begin
  Result := TPressOPFBulkProxyIterator.Create(Self);
end;

function TPressOPFBulkProxyList.GetItems(AIndex: Integer): TPressOPFBulkProxy;
begin
  Result := inherited Items[AIndex] as TPressOPFBulkProxy;
end;

function TPressOPFBulkProxyList.IndexOfInstanceRef(
  AInstance: TPressObject): Integer;
var
  VProxy: TPressOPFBulkProxy;
begin
  for Result := 0 to Pred(Count) do
  begin
    VProxy := Items[Result];
    if (VProxy.ObjectId = AInstance.PersistentId) and
     (AInstance is VProxy.ObjectClass) then
      Exit;
  end;
  Result := -1;
end;

function TPressOPFBulkProxyList.IndexOfProxy(AProxy: TPressProxy): Integer;
var
  VProxy: TPressOPFBulkProxy;
begin
  for Result := 0 to Pred(Count) do
  begin
    VProxy := Items[Result];
    if AProxy.SameReference(VProxy.ObjectClass, VProxy.ObjectId) then
      Exit;
  end;
  Result := -1;
end;

function TPressOPFBulkProxyList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

procedure TPressOPFBulkProxyList.SetItems(
  AIndex: Integer; AValue: TPressOPFBulkProxy);
begin
  inherited Items[AIndex] := AValue;
end;

{ TPressOPFCustomBulkMap }

function TPressOPFCustomBulkMap.BuildIDs: TPressStringArray;
var
  I: Integer;
begin
  SetLength(Result, ProxyList.Count);
  for I := 0 to Pred(ProxyList.Count) do
    Result[I] := ProxyList[I].ObjectId;
end;

constructor TPressOPFCustomBulkMap.Create(
  AOwner: TPressOPFCustomBulkRetrieve; AClass: TPressObjectClass);
begin
  inherited Create;
  FObjectMapper := AOwner.ObjectMapper;
  FProxyList := AOwner.CreateProxyListByClass(AClass);
  FMaps := FObjectMapper.StorageModel.Maps[AClass];
end;

function TPressOPFCustomBulkMap.CreateObjectArray: TPressObjectArray;
var
  I: Integer;
begin
  SetLength(Result, ProxyList.Count);
  for I := 0 to Pred(ProxyList.Count) do
    Result[I] := ProxyList[I].Instance;
end;

destructor TPressOPFCustomBulkMap.Destroy;
begin
  FProxyList.Free;
  inherited;
end;

procedure TPressOPFCustomBulkMap.Retrieve;
begin
end;

{ TPressOPFBulkMap }

constructor TPressOPFBulkMap.Create(AOwner: TPressOPFBulkRetrieve;
  AClass: TPressObjectClass; ADepth: Integer);
begin
  inherited Create(AOwner, AClass);
  FDepth := ADepth;
end;

procedure TPressOPFBulkMap.Retrieve;
begin
  inherited;
  RetrieveBaseMaps;
  RetrieveComplementaryMaps;
  { TODO : Implement Depth }
end;

procedure TPressOPFBulkMap.RetrieveBaseMaps;
var
  VObjects: TPressObjectList;
begin
  VObjects := TPressObjectList.Create(True);
  try
    ObjectMapper.AttributeMapper[Maps.Last].RetrieveBaseMapsList(
     BuildIDs, VObjects);
    ProxyList.AssignInstances(VObjects);
  finally
    VObjects.Free;
  end;
end;

procedure TPressOPFBulkMap.RetrieveComplementaryMaps;
var
  VBulkRetrieve: TPressOPFBulkRetrieveComplementary;
begin
  VBulkRetrieve := TPressOPFBulkRetrieveComplementary.Create(
   ObjectMapper, ProxyList, Maps.ObjectClass);
  try
    VBulkRetrieve.Execute;
  finally
    VBulkRetrieve.Free;
  end;
end;

{ TPressOPFBulkMapComplementary }

constructor TPressOPFBulkMapComplementary.Create(
  AOwner: TPressOPFBulkRetrieveComplementary;
  AClass, ABaseClass: TPressObjectClass);
begin
  inherited Create(AOwner, AClass);
  FBaseClass := ABaseClass;
end;

procedure TPressOPFBulkMapComplementary.Retrieve;
var
  VObjects: TPressObjectArray;
begin
  inherited;
  VObjects := CreateObjectArray;
  ObjectMapper.AttributeMapper[Maps.Last].RetrieveComplementaryMapsArray(
   VObjects, FBaseClass);
end;

{ TPressOPFBulkMapRefresh }

procedure TPressOPFBulkMapRefresh.Retrieve;
var
  VObjects: TPressObjectArray;
  VObject: TPressObject;
  VAttributeMapper: TPressOPFAttributeMapper;
  I: Integer;
begin
  inherited;
  VObjects := CreateObjectArray;
  for I := 0 to Pred(Length(VObjects)) do
  begin
    VObject := VObjects[I];
    VObject.Id := VObject.PersistentId;
  end;
  VAttributeMapper := ObjectMapper.AttributeMapper[Maps.Last];
  VAttributeMapper.RetrieveComplementaryMapsArray(VObjects, nil);
  VAttributeMapper.RefreshStructures(VObjects);
end;

end.
