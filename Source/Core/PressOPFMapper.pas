(*
  PressObjects, Persistence Mapper Classes
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressOPFMapper;

{$I Press.inc}

interface

uses
  Classes,
  Contnrs,
  PressClasses,
  PressSubject,
  PressAttributes,
  PressPersistence,
  PressOPFClasses,
  PressOPFConnector,
  PressOPFStorage,
  PressOPFSQLBuilder;

type
  TPressOPFAttributeMapper = class;
  TPressOPFAttributeMapperClass = class of TPressOPFAttributeMapper;

  TPressOPFObjectMapperClass = class of TPressOPFObjectMapper;

  TPressOPFObjectMapper = class(TObject)
  private
    { TODO : Implement owned Part(s) objects mapping }
    FAttributeMapperList: TObjectList;
    FConnector: TPressOPFConnector;
    FDDLBuilder: TPressOPFDDLBuilder;
    FPersistence: TPressPersistence;
    FStorageModel: TPressOPFStorageModel;
    procedure CheckId(AObject: TPressObject);
    function GetAttributeMapper(AMap: TPressOPFStorageMap): TPressOPFAttributeMapper;
    function GetDDLBuilder: TPressOPFDDLBuilder;
  protected
    function InternalAttributeMapperClass: TPressOPFAttributeMapperClass; virtual;
    function InternalDDLBuilderClass: TPressOPFDDLBuilderClass; virtual;
    function InternalDMLBuilderClass: TPressOPFDMLBuilderClass; virtual;
    property AttributeMapper[AMap: TPressOPFStorageMap]: TPressOPFAttributeMapper read GetAttributeMapper;
  public
    constructor Create(APersistence: TPressPersistence; AStorageModel: TPressOPFStorageModel; AConnector: TPressOPFConnector);
    destructor Destroy; override;
    procedure BulkRetrieve(AProxyList: TPressProxyList; AStartingAt, AItemCount, ADepth: Integer);
    function CreateDatabaseStatement(ACreateClearDatabaseStatements: Boolean = False): string;
    procedure Dispose(AClass: TPressObjectClass; const AId: string);
    function DMLBuilderClass: TPressOPFDMLBuilderClass;
    function Retrieve(AClass: TPressObjectClass; const AId: string; AMetadata: TPressObjectMetadata): TPressObject;
    procedure Store(AObject: TPressObject);
    property Connector: TPressOPFConnector read FConnector;
    property DDLBuilder: TPressOPFDDLBuilder read GetDDLBuilder;
    property Persistence: TPressPersistence read FPersistence;
    property StorageModel: TPressOPFStorageModel read FStorageModel;
  end;

  TPressOPFAttributeMapper = class(TObject)
  private
    { TODO : Maximize dataset caches, minimize dmlbuild and
      createdataset calls }
    FConnector: TPressOPFConnector;
    FDeleteDataset: TPressOPFDataset;
    FDDLBuilder: TPressOPFDDLBuilder;
    FDMLBuilder: TPressOPFDMLBuilder;
    FInsertDataset: TPressOPFDataset;
    FMap: TPressOPFStorageMap;
    FMaps: TPressOPFStorageMapList;
    FObjectMapper: TPressOPFObjectMapper;
    FPersistence: TPressPersistence;
    FSelectBaseDataset: TPressOPFDataset;
    FSelectBaseGroupDataset: TPressOPFDataset;
    FSelectComplementaryDataset: TPressOPFDataset;
    FSelectComplementaryGroupDataset: TPressOPFDataset;
    FUpdateDataset: TPressOPFDataset;
    procedure AddAttributeParam(ADataset: TPressOPFDataset; AAttribute: TPressAttribute);
    procedure AddAttributeParams(ADataset: TPressOPFDataset; AObject: TPressObject);
    procedure AddClassIdParam(ADataset: TPressOPFDataset; AObject: TPressObject);
    procedure AddRemovedIdParam(ADataset: TPressOPFDataset; AItems: TPressItems);
    procedure AddIdArrayParam(ADataset: TPressOPFDataset; AIDs: TPressStringArray);
    procedure AddIdParam(ADataset: TPressOPFDataset; const AParamName, AValue: string);
    procedure AddIntegerParam(ADataset: TPressOPFDataset; const AParamName: string; AValue: Integer);
    procedure AddLinkParams(ADataset: TPressOPFDataset; AItems: TPressItems; AProxy: TPressProxy; const AOwnerId: string; AIndex: Integer);
    procedure AddNullParam(ADataset: TPressOPFDataset; const AParamName: string; AFieldType: TPressOPFFieldType);
    procedure AddPersistentIdParam(ADataset: TPressOPFDataset; const APersistentId: string);
    procedure AddStringParam(ADataset: TPressOPFDataset; const AParamName, AValue: string);
    procedure AddUpdateCountParam(ADataset: TPressOPFDataset; AObject: TPressObject);
    function DeleteDataset: TPressOPFDataset;
    function InsertDataset: TPressOPFDataset;
    function SelectBaseDataset: TPressOPFDataset;
    function SelectBaseGroupDataset(AIdCount: Integer): TPressOPFDataset;
    function SelectComplementaryDataset(ABaseClass: TPressObjectClass): TPressOPFDataset;
    function SelectComplementaryGroupDataset(AIdCount: Integer; ABaseClass: TPressObjectClass): TPressOPFDataset;
    function UpdateDataset(AObject: TPressObject): TPressOPFDataset;
  protected
    function CreateObject(AClass: TPressObjectClass; AMetadata: TPressObjectMetadata; const AId: string; ADataRow: TPressOPFDataRow): TPressObject;
    procedure DoConcurrencyError(AObject: TPressObject); virtual;
    procedure ReadAttributes(AObject: TPressObject; ADataRow: TPressOPFDataRow);
    procedure ReadObject(AObject: TPressObject; ABaseClass: TPressObjectClass; ADataRow: TPressOPFDataRow);
    function ResolveClassType(ADataRow: TPressOPFDataRow): TPressObjectClass;
    property Connector: TPressOPFConnector read FConnector;
    property DDLBuilder: TPressOPFDDLBuilder read FDDLBuilder;
    property DMLBuilder: TPressOPFDMLBuilder read FDMLBuilder;
    property ObjectMapper: TPressOPFObjectMapper read FObjectMapper;
    property Persistence: TPressPersistence read FPersistence;
  public
    constructor Create(AObjectMapper: TPressOPFObjectMapper; AMap: TPressOPFStorageMap);
    destructor Destroy; override;
    procedure DisposeObject(AObject: TPressObject);
    procedure DisposeRecord(const AId: string);
    function RetrieveBaseMaps(const AId: string; AMetadata: TPressObjectMetadata): TPressObject;
    procedure RetrieveBaseMapsList(AIDs: TPressStringArray; AObjects: TPressObjectList);
    procedure RetrieveComplementaryMaps(AObject: TPressObject; ABaseClass: TPressObjectClass);
    procedure RetrieveComplementaryMapsList(AObjects: TPressObjectList; ABaseClass: TPressObjectClass);
    procedure Store(AObject: TPressObject);
    property Map: TPressOPFStorageMap read FMap;
    property Maps: TPressOPFStorageMapList read FMaps;
  end;

  TPressOPFBulkProxy = class;
  TPressOPFBulkProxyList = class;
  TPressOPFCustomBulkMap = class;

  TPressOPFCustomBulkRetrieve = class(TObject)
  private
    FMaps: TObjectList;
    FObjectMapper: TPressOPFObjectMapper;
    FProxyList: TPressOPFBulkProxyList;
    function GetProxyList: TPressOPFBulkProxyList;
  protected
    procedure AddMap(AClass: TPressObjectClass);
    procedure CreateMaps;
    function InternalCreateMap(AClass: TPressObjectClass): TPressOPFCustomBulkMap; virtual; abstract;
    function InternalOwnsProxy: Boolean; virtual; abstract;
    procedure RetrieveMaps;
    procedure UpdateProxies;
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
  protected
    procedure CreateProxies(AStartingAt, AItemCount: Integer);
    function InternalCreateMap(AClass: TPressObjectClass): TPressOPFCustomBulkMap; override;
    function InternalOwnsProxy: Boolean; override;
  public
    constructor Create(AObjectMapper: TPressOPFObjectMapper; AProxyList: TPressProxyList; ADepth: Integer);
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
  protected
    function CreateObjectList: TPressObjectList;
  public
    constructor Create(AOwner: TPressOPFBulkRetrieveComplementary; AClass, ABaseClass: TPressObjectClass);
    procedure Retrieve; override;
  end;

implementation

uses
  SysUtils,
  TypInfo,
  {$IFDEF PressLog}PressLog,{$ENDIF}
  PressConsts;

{ TPressOPFObjectMapper }

procedure TPressOPFObjectMapper.BulkRetrieve(
  AProxyList: TPressProxyList; AStartingAt, AItemCount, ADepth: Integer);
var
  VBulkRetrieve: TPressOPFBulkRetrieve;
begin
  VBulkRetrieve := TPressOPFBulkRetrieve.Create(Self, AProxyList, ADepth);
  try
    VBulkRetrieve.Execute(AStartingAt, AItemCount);
  finally
    VBulkRetrieve.Free;
  end;
end;

procedure TPressOPFObjectMapper.CheckId(AObject: TPressObject);
begin
  if AObject.Id = '' then
    AObject.Id := Persistence.GenerateOID(
     AObject.ClassType, AObject.Metadata.IdMetadata.PersistentName);
end;

constructor TPressOPFObjectMapper.Create(APersistence: TPressPersistence;
  AStorageModel: TPressOPFStorageModel; AConnector: TPressOPFConnector);
begin
  inherited Create;
  FPersistence := APersistence;
  FStorageModel := AStorageModel;
  FConnector := AConnector;
end;

function TPressOPFObjectMapper.CreateDatabaseStatement(
  ACreateClearDatabaseStatements: Boolean): string;
begin
  Result := DDLBuilder.CreateHints(StorageModel);
  if ACreateClearDatabaseStatements then
    Result := Result + DDLBuilder.CreateClearDatabaseStatement(StorageModel);
  Result := Result + DDLBuilder.CreateDatabaseStatement(StorageModel);
end;

destructor TPressOPFObjectMapper.Destroy;
begin
  FDDLBuilder.Free;
  FAttributeMapperList.Free;
  inherited;
end;

procedure TPressOPFObjectMapper.Dispose(
  AClass: TPressObjectClass; const AId: string);

  function HasExternals(AMetadata: TPressObjectMetadata): Boolean;
  var
    VAttributeClass: TPressAttributeClass;
    I: Integer;
  begin
    for I := 0 to Pred(AMetadata.Map.Count) do
    begin
      VAttributeClass := AMetadata.Map[I].AttributeClass;
      Result := VAttributeClass.InheritsFrom(TPressPart) or
       VAttributeClass.InheritsFrom(TPressItems);
      if Result then
        Exit;
    end;
    Result := False;
  end;

var
  VMaps: TPressOPFStorageMapList;
  VObject: TPressObject;
  I: Integer;
begin
  VMaps := StorageModel.Maps[AClass];
  if HasExternals(VMaps.Metadata) then
  begin
    { TODO : Retrieve only the containers when the object isn't in the cache }
    VObject := Persistence.Retrieve(AClass, AId);
    if Assigned(VObject) then
    begin
      try
        for I := Pred(VMaps.Count) downto 0 do
          AttributeMapper[VMaps[I]].DisposeObject(VObject);
        PressAssignPersistentId(VObject, '');
      finally
        VObject.Free;
      end;
    end else
      { TODO : Implement }
      ;
  end else
  begin
    for I := Pred(VMaps.Count) downto 0 do
      AttributeMapper[VMaps[I]].DisposeRecord(AId);
  end;
end;

function TPressOPFObjectMapper.DMLBuilderClass: TPressOPFDMLBuilderClass;
begin
  Result := InternalDMLBuilderClass;
end;

function TPressOPFObjectMapper.GetAttributeMapper(
  AMap: TPressOPFStorageMap): TPressOPFAttributeMapper;
var
  I: Integer;
begin
  if not Assigned(FAttributeMapperList) then
    FAttributeMapperList := TObjectList.Create(True);
  for I := 0 to Pred(FAttributeMapperList.Count) do
  begin
    Result := FAttributeMapperList[I] as TPressOPFAttributeMapper;
    if Result.Map = AMap then
      Exit;
  end;
  Result := InternalAttributeMapperClass.Create(Self, AMap);
  FAttributeMapperList.Add(Result);
end;

function TPressOPFObjectMapper.GetDDLBuilder: TPressOPFDDLBuilder;
begin
  if not Assigned(FDDLBuilder) then
    FDDLBuilder := InternalDDLBuilderClass.Create;
  Result := FDDLBuilder;
end;

function TPressOPFObjectMapper.InternalAttributeMapperClass: TPressOPFAttributeMapperClass;
begin
  Result := TPressOPFAttributeMapper;
end;

function TPressOPFObjectMapper.InternalDDLBuilderClass: TPressOPFDDLBuilderClass;
begin
  Result := TPressOPFDDLBuilder;
end;

function TPressOPFObjectMapper.InternalDMLBuilderClass: TPressOPFDMLBuilderClass;
begin
  Result := TPressOPFDMLBuilder;
end;

function TPressOPFObjectMapper.Retrieve(AClass: TPressObjectClass;
  const AId: string; AMetadata: TPressObjectMetadata): TPressObject;
var
  VMaps: TPressOPFStorageMapList;
  VObject: TPressObject;
begin
  VMaps := StorageModel.Maps[AClass];
  if VMaps.Count > 0 then
  begin
    VObject := AttributeMapper[VMaps.Last].RetrieveBaseMaps(AId, AMetadata);
    if Assigned(VObject) then
    begin
      try
        VObject.DisableChanges;
        if (VObject.ClassType <> AClass) and (VObject is AClass) then
          AttributeMapper[StorageModel.Maps[VObject.ClassType].Last].
           RetrieveComplementaryMaps(VObject, AClass);
        VObject.EnableChanges;
      except
        VObject.Free;
        raise;
      end;
    end;
    Result := VObject;
  end else
    Result := nil;
end;

procedure TPressOPFObjectMapper.Store(AObject: TPressObject);
var
  VMaps: TPressOPFStorageMapList;
  I: Integer;
begin
  CheckId(AObject);
  PressEvolveUpdateCount(AObject);
  VMaps := StorageModel.Maps[AObject.ClassType];
  for I := Pred(VMaps.Count) downto 0 do
    AttributeMapper[VMaps[I]].Store(AObject);
  PressAssignPersistentId(AObject, AObject.Id);
  PressAssignPersistentUpdateCount(AObject);
end;

{ TPressOPFAttributeMapper }

procedure TPressOPFAttributeMapper.AddAttributeParam(
  ADataset: TPressOPFDataset; AAttribute: TPressAttribute);

  procedure AddValueAttribute(AValue: TPressValue);
  var
    VParam: TPressOPFParam;
  begin
    VParam := ADataset.Params.ParamByName(AValue.PersistentName);
    if not AValue.IsNull then
    begin
      case AValue.AttributeBaseType of
        attString:
          VParam.AsString := AValue.AsString;
        attInteger:
          if (AValue as TPressInteger).IsRelativelyChanged then
            VParam.AsInt32 := TPressInteger(AValue).Diff
          else
            VParam.AsInt32 := AValue.AsInteger;
        attFloat:
          if (AValue as TPressFloat).IsRelativelyChanged then
            VParam.AsFloat := TPressFloat(AValue).Diff
          else
            VParam.AsFloat := AValue.AsFloat;
        attCurrency:
          if (AValue as TPressCurrency).IsRelativelyChanged then
            VParam.AsCurrency := TPressCurrency(AValue).Diff
          else
            VParam.AsCurrency := AValue.AsCurrency;
        attEnum:
          VParam.AsInt16 := AValue.AsInteger;
        attBoolean:
          VParam.AsBoolean := AValue.AsBoolean;
        attDate:
          VParam.AsDate := AValue.AsDate;
        attTime:
          VParam.AsTime := AValue.AsTime;
        attDateTime:
          VParam.AsDateTime := AValue.AsDateTime;
        attMemo:
          VParam.AsMemo := AValue.AsString;
        attBinary, attPicture:
          VParam.AsBinary := AValue.AsString;
        else
          VParam.AsVariant := AValue.AsVariant;
      end;
    end else
      VParam.Clear(DDLBuilder.AttributeTypeToFieldType(
       AValue.AttributeBaseType));
  end;

  procedure AddPartAttribute(APart: TPressPart);
  var
    VObject: TPressObject;
  begin
    VObject := APart.Value;
    ObjectMapper.Store(VObject);
    AddStringParam(ADataset, APart.PersistentName, VObject.Id);
  end;

  procedure AddReferenceAttribute(AReference: TPressReference);
  begin
    if not AReference.Proxy.IsEmpty then
    begin
      if AReference.Proxy.HasInstance and
       not AReference.Value.IsPersistent then
        Persistence.Store(AReference.Value);
      AddStringParam(
       ADataset, AReference.PersistentName, AReference.Proxy.ObjectId);
    end else
      AddNullParam(ADataset, AReference.PersistentName,
       DDLBuilder.AttributeTypeToFieldType(
       AReference.Metadata.ObjectClass.ClassMetadata.IdMetadata.AttributeClass.AttributeBaseType));
  end;

begin
  if AAttribute is TPressValue then
    AddValueAttribute(TPressValue(AAttribute))
  else if AAttribute is TPressPart then
    AddPartAttribute(TPressPart(AAttribute))
  else if AAttribute is TPressReference then
    AddReferenceAttribute(TPressReference(AAttribute));
end;

procedure TPressOPFAttributeMapper.AddAttributeParams(
  ADataset: TPressOPFDataset; AObject: TPressObject);
var
  VAttribute: TPressAttribute;
  I: Integer;
begin
  if not AObject.IsPersistent then
    AddClassIdParam(ADataset, AObject);
  for I := 0 to Pred(Map.Count) do
  begin
    VAttribute := AObject.AttributeByName(Map[I].Name);
    if not AObject.IsPersistent or VAttribute.IsChanged then
      AddAttributeParam(ADataset, VAttribute);
  end;
  if not AObject.IsPersistent or (Map.Metadata = AObject.Metadata) then
    AddUpdateCountParam(ADataset, AObject);
  if AObject.IsPersistent then
    AddPersistentIdParam(ADataset, AObject.PersistentId);
end;

procedure TPressOPFAttributeMapper.AddClassIdParam(
  ADataset: TPressOPFDataset; AObject: TPressObject);
begin
  if Map.Metadata.ClassIdName <> '' then
    AddStringParam(ADataset, Map.Metadata.ClassIdName,
     ObjectMapper.StorageModel.ClassIdByName(AObject.ClassName));
end;

procedure TPressOPFAttributeMapper.AddIdArrayParam(
  ADataset: TPressOPFDataset; AIDs: TPressStringArray);
var
  I: Integer;
begin
  for I := 0 to Pred(Length(AIDs)) do
    AddIdParam(ADataset, SPressIdString + IntToStr(I), AIDs[I]);
end;

procedure TPressOPFAttributeMapper.AddIdParam(
  ADataset: TPressOPFDataset; const AParamName, AValue: string);
begin
  if AParamName <> '' then
  begin
    case Map.IdType of
      attString:
        ADataset.Params.ParamByName(AParamName).AsString := AValue;
      attInteger:
        ADataset.Params.ParamByName(AParamName).AsInt32 := StrToInt(AValue);
      else
        raise EPressOPFError.CreateFmt(SUnsupportedFieldType, [
         GetEnumName(TypeInfo(TPressAttributeBaseType), Ord(Map.IdType))]);
    end;
  end;
end;

procedure TPressOPFAttributeMapper.AddIntegerParam(
  ADataset: TPressOPFDataset; const AParamName: string; AValue: Integer);
begin
  if AParamName <> '' then
    ADataset.Params.ParamByName(AParamName).AsInt32 := AValue;
end;

procedure TPressOPFAttributeMapper.AddLinkParams(
  ADataset: TPressOPFDataset; AItems: TPressItems; AProxy: TPressProxy;
  const AOwnerId: string; AIndex: Integer);
begin
  if AItems.Metadata.PersLinkIdName <> '' then
    ADataset.Params.ParamByName(AItems.Metadata.PersLinkIdName).AsString :=
     Persistence.GenerateOID(
     AProxy.Instance.ClassType, AItems.Metadata.PersLinkIdName);
  AddStringParam(ADataset, AItems.Metadata.PersLinkParentName, AOwnerId);
  AddStringParam(ADataset, AItems.Metadata.PersLinkChildName,
   AProxy.ObjectId);
  AddIntegerParam(ADataset, AItems.Metadata.PersLinkPosName, AIndex);
end;

procedure TPressOPFAttributeMapper.AddNullParam(
  ADataset: TPressOPFDataset; const AParamName: string; AFieldType: TPressOPFFieldType);
begin
  if AParamName <> '' then
    ADataset.Params.ParamByName(AParamName).Clear(AFieldType);
end;

procedure TPressOPFAttributeMapper.AddPersistentIdParam(
  ADataset: TPressOPFDataset; const APersistentId: string);
begin
  AddIdParam(ADataset, SPressPersistentIdParamString, APersistentId);
end;

procedure TPressOPFAttributeMapper.AddRemovedIdParam(
  ADataset: TPressOPFDataset; AItems: TPressItems);
var
  I: Integer;
begin
  for I := 0 to Pred(AItems.RemovedProxies.Count) do
    ADataset.Params.ParamByName(SPressIdString + InttoStr(I)).AsString :=
     AItems.RemovedProxies[I].ObjectId;
end;

procedure TPressOPFAttributeMapper.AddStringParam(
  ADataset: TPressOPFDataset; const AParamName, AValue: string);
begin
  if AParamName <> '' then
    ADataset.Params.ParamByName(AParamName).AsString := AValue;
end;

procedure TPressOPFAttributeMapper.AddUpdateCountParam(
  ADataset: TPressOPFDataset; AObject: TPressObject);
begin
  AddIntegerParam(ADataset, Map.Metadata.UpdateCountName, AObject.UpdateCount);
end;

constructor TPressOPFAttributeMapper.Create(
  AObjectMapper: TPressOPFObjectMapper; AMap: TPressOPFStorageMap);
begin
  inherited Create;
  FObjectMapper := AObjectMapper;
  FConnector := FObjectMapper.Connector;
  FPersistence := FObjectMapper.Persistence;
  FMap := AMap;
  FMaps := ObjectMapper.StorageModel.Maps[FMap.ObjectClass];
  FDDLBuilder := FObjectMapper.DDLBuilder;
  FDMLBuilder := FObjectMapper.DMLBuilderClass.Create(Maps);
end;

function TPressOPFAttributeMapper.CreateObject(
  AClass: TPressObjectClass; AMetadata: TPressObjectMetadata;
  const AId: string; ADataRow: TPressOPFDataRow): TPressObject;
var
  VId: string;
  I: Integer;
begin
  Result := AClass.Create(Persistence, AMetadata);
  try
    Result.DisableChanges;
    if AId <> '' then
      VId := AId
    else
      VId := ADataRow.FieldByName(Map[0].PersistentName).AsString;
    Result.Id := VId;
    ReadAttributes(Result, ADataRow);
    for I := Maps.Count - 2 downto 0 do
      ObjectMapper.AttributeMapper[Maps[I]].ReadAttributes(
       Result, ADataRow);
    if Result.Metadata.UpdateCountName <> '' then
      PressAssignUpdateCount(Result,
       ADataRow.FieldByName(Result.Metadata.UpdateCountName).Value);
    PressAssignPersistentId(Result, VId);
    Result.EnableChanges;
  except
    FreeAndNil(Result);
    raise;
  end;
end;

function TPressOPFAttributeMapper.DeleteDataset: TPressOPFDataset;
begin
  if not Assigned(FDeleteDataset) then
  begin
    FDeleteDataset := Connector.CreateDataset;
    FDeleteDataset.SQL := DMLBuilder.DeleteStatement;
  end;
  Result := FDeleteDataset;
end;

destructor TPressOPFAttributeMapper.Destroy;
begin
  FDeleteDataset.Free;
  FInsertDataset.Free;
  FUpdateDataset.Free;
  FSelectBaseDataset.Free;
  FSelectBaseGroupDataset.Free;
  FSelectComplementaryDataset.Free;
  FSelectComplementaryGroupDataset.Free;
  FDMLBuilder.Free;
  inherited;
end;

procedure TPressOPFAttributeMapper.DisposeObject(AObject: TPressObject);

  procedure DisposePartObjects;

    procedure DisposePartObject(AAttribute: TPressPart);
    var
      VProxy: TPressProxy;
    begin
      VProxy := AAttribute.Proxy;
      if not VProxy.IsEmpty then
        ObjectMapper.Dispose(VProxy.ObjectClassType, VProxy.ObjectId);
    end;

  var
    VMetadata: TPressAttributeMetadata;
    I: Integer;
  begin
    for I := 0 to Pred(Map.Count) do
    begin
      VMetadata := Map[I];
      if VMetadata.AttributeClass.InheritsFrom(TPressPart) then
        DisposePartObject(TPressPart(AObject.AttributeByName(VMetadata.Name)));
    end;
  end;

  procedure DisposeLinkedObjects;
  var
    VDataset: TPressOPFDataset;

    procedure DisposeLinks(AItems: TPressItems);
    begin
      if not Assigned(VDataset) then
        VDataset := Connector.CreateDataset;
      VDataset.SQL := DMLBuilder.DeleteLinkStatement(AItems.Metadata);
      AddPersistentIdParam(VDataset, AObject.PersistentId);
      VDataset.Execute;
    end;

    procedure DisposePartsObjects(AAttribute: TPressParts);
    begin
      with AAttribute.CreateProxyIterator do
      try
        BeforeFirstItem;
        while NextItem do
          if not CurrentItem.IsEmpty then
            ObjectMapper.Dispose(
             CurrentItem.ObjectClassType, CurrentItem.ObjectId);
      finally
        Free;
      end;
    end;

  var
    VMetadata: TPressAttributeMetadata;
    VItems: TPressItems;
    I: Integer;
  begin
    VDataset := nil;
    try
      for I := 0 to Pred(Map.Count) do
      begin
        VMetadata := Map[I];
        if VMetadata.AttributeClass.InheritsFrom(TPressItems) then
        begin
          VItems := AObject.AttributeByName(VMetadata.Name) as TPressItems;
          DisposeLinks(VItems);
          if VItems is TPressParts then
            DisposePartsObjects(TPressParts(VItems));
        end;
      end;
    finally
      VDataset.Free;
    end;
  end;

var
  VDataset: TPressOPFDataset;
begin
  DisposeLinkedObjects;
  VDataset := DeleteDataset;
  AddPersistentIdParam(VDataset, AObject.PersistentId);
  VDataset.Execute;
  DisposePartObjects;
end;

procedure TPressOPFAttributeMapper.DisposeRecord(const AId: string);
var
  VDataset: TPressOPFDataset;
begin
  VDataset := DeleteDataset;
  AddPersistentIdParam(VDataset, AId);
  VDataset.Execute;
end;

procedure TPressOPFAttributeMapper.DoConcurrencyError(
  AObject: TPressObject);
begin
  { TODO : Implement }
  raise EPressOPFError.CreateFmt(SObjectChangedError, [
   AObject.ClassName, AObject.Signature]);
end;

function TPressOPFAttributeMapper.InsertDataset: TPressOPFDataset;
begin
  if not Assigned(FInsertDataset) then
  begin
    FInsertDataset := Connector.CreateDataset;
    FInsertDataset.SQL := DMLBuilder.InsertStatement;
  end;
  Result := FInsertDataset;
end;

procedure TPressOPFAttributeMapper.ReadAttributes(
  AObject: TPressObject; ADataRow: TPressOPFDataRow);
var
  VDataset: TPressOPFDataset;

  procedure LoadValue(AValue: TPressValue);
  begin
    AValue.AsVariant := ADataRow.FieldByName(AValue.PersistentName).Value;
  end;

  procedure LoadItem(AItem: TPressItem);
  begin
    AItem.AssignReference(AItem.ObjectClass.ClassName,
     ADataRow.FieldByName(AItem.PersistentName).AsString);
  end;

  procedure LoadItems(AItems: TPressItems);
  var
    I: Integer;
  begin
    if not Assigned(VDataset) then
      VDataset := Connector.CreateDataset;
    VDataset.SQL := DMLBuilder.SelectLinkStatement(AItems.Metadata);
    AddPersistentIdParam(VDataset, AObject.Id);
    VDataset.Execute;
    for I := 0 to Pred(VDataset.Count) do
      AItems.AddReference(AItems.ObjectClass.ClassName,
       VDataset[I][0].Value, Persistence);
  end;

var
  VAttribute: TPressAttribute;
  I: Integer;
begin
  VDataset := nil;
  try
    for I := 1 to Pred(Map.Count) do
    begin
      VAttribute := AObject.AttributeByName(Map[I].Name);
      if VAttribute is TPressValue then
        LoadValue(TPressValue(VAttribute))
      else if VAttribute is TPressItem then
        LoadItem(TPressItem(VAttribute))
      else if VAttribute is TPressItems then
        LoadItems(TPressItems(VAttribute));
    end;
  finally
    VDataset.Free;
  end;
end;

procedure TPressOPFAttributeMapper.ReadObject(AObject: TPressObject;
  ABaseClass: TPressObjectClass; ADataRow: TPressOPFDataRow);
var
  I: Integer;
begin
  if AObject.Metadata.UpdateCountName <> '' then
    PressAssignUpdateCount(AObject,
     ADataRow.FieldByName(AObject.Metadata.UpdateCountName).Value);
  ReadAttributes(AObject, ADataRow);
  for I := Maps.Count - 2 downto 0 do
  begin
    if Maps[I].ObjectClass = ABaseClass then
      Exit;
    ObjectMapper.AttributeMapper[Maps[I]].ReadAttributes(
     AObject, ADataRow);
  end;
end;

function TPressOPFAttributeMapper.ResolveClassType(
  ADataRow: TPressOPFDataRow): TPressObjectClass;
var
  VClass: TPressObjectClass;
begin
  Result := Map.ObjectClass;
  if Map.Metadata.ClassIdName <> '' then
  begin
    VClass := ObjectMapper.StorageModel.ClassById(
     ADataRow.FieldByName(Map.Metadata.ClassIdName).AsString);
    if VClass.InheritsFrom(Result) then
      Result := VClass;
  end;
end;

function TPressOPFAttributeMapper.RetrieveBaseMaps(
  const AId: string; AMetadata: TPressObjectMetadata): TPressObject;
var
  VDataset: TPressOPFDataset;
begin
  VDataset := SelectBaseDataset;
  AddPersistentIdParam(VDataset, AId);
  VDataset.Execute;
  if VDataset.Count = 1 then
    Result := CreateObject(
     ResolveClassType(VDataset[0]), AMetadata, AId, VDataset[0])
  else
    Result := nil;
end;

procedure TPressOPFAttributeMapper.RetrieveBaseMapsList(
  AIDs: TPressStringArray; AObjects: TPressObjectList);
var
  VDataset: TPressOPFDataset;
  I: Integer;
begin
  VDataset := SelectBaseGroupDataset(Length(AIDs));
  AddIdArrayParam(VDataset, AIDs);
  VDataset.Execute;
  for I := 0 to Pred(VDataset.Count) do
    AObjects.Add(CreateObject(
     ResolveClassType(VDataset[I]), nil, '', VDataset[I]));
end;

procedure TPressOPFAttributeMapper.RetrieveComplementaryMaps(
  AObject: TPressObject; ABaseClass: TPressObjectClass);
var
  VDataset: TPressOPFDataset;
begin
  VDataset := SelectComplementaryDataset(ABaseClass);
  AddPersistentIdParam(VDataset, AObject.Id);
  VDataset.Execute;
  if VDataset.Count = 1 then
    ReadObject(AObject, ABaseClass, VDataset[0]);
end;

procedure TPressOPFAttributeMapper.RetrieveComplementaryMapsList(
  AObjects: TPressObjectList; ABaseClass: TPressObjectClass);

  function BuildIDs: TPressStringArray;
  var
    I: Integer;
  begin
    SetLength(Result, AObjects.Count);
    for I := 0 to Pred(AObjects.Count) do
      Result[I] := AObjects[I].Id;
  end;

var
  VDataset: TPressOPFDataset;
  VIndex, I: Integer;
begin
  VDataset := SelectComplementaryGroupDataset(AObjects.Count, ABaseClass);
  AddIdArrayParam(VDataset, BuildIDs);
  VDataset.Execute;
  for I := 0 to Pred(VDataset.Count) do
  begin
    VIndex := AObjects.IndexOfId(
     VDataset[I].FieldByName(Map[0].PersistentName).Value);
    if VIndex >= 0 then
      ReadObject(AObjects[VIndex], ABaseClass, VDataset[I]);
  end;
end;

function TPressOPFAttributeMapper.SelectBaseDataset: TPressOPFDataset;
begin
  if not Assigned(FSelectBaseDataset) then
  begin
    FSelectBaseDataset := Connector.CreateDataset;
    FSelectBaseDataset.SQL := DMLBuilder.SelectStatement;
  end;
  Result := FSelectBaseDataset;
end;

function TPressOPFAttributeMapper.SelectBaseGroupDataset(
  AIdCount: Integer): TPressOPFDataset;
begin
  if not Assigned(FSelectBaseGroupDataset) then
    FSelectBaseGroupDataset := Connector.CreateDataset;
  FSelectBaseGroupDataset.SQL := DMLBuilder.SelectGroupStatement(AIdCount);
  Result := FSelectBaseGroupDataset;
end;

function TPressOPFAttributeMapper.SelectComplementaryDataset(
  ABaseClass: TPressObjectClass): TPressOPFDataset;
begin
  if not Assigned(FSelectComplementaryDataset) then
    FSelectComplementaryDataset := Connector.CreateDataset;
  FSelectComplementaryDataset.SQL := DMLBuilder.SelectStatement(ABaseClass);
  Result := FSelectComplementaryDataset;
end;

function TPressOPFAttributeMapper.SelectComplementaryGroupDataset(
  AIdCount: Integer; ABaseClass: TPressObjectClass): TPressOPFDataset;
begin
  if not Assigned(FSelectComplementaryGroupDataset) then
    FSelectComplementaryGroupDataset := Connector.CreateDataset;
  FSelectComplementaryGroupDataset.SQL :=
   DMLBuilder.SelectGroupStatement(AIdCount, ABaseClass);
  Result := FSelectComplementaryGroupDataset;
end;

procedure TPressOPFAttributeMapper.Store(AObject: TPressObject);

  procedure StoreItems;
  var
    VDataset: TPressOPFDataset;

    procedure UpdateLinks(AItems: TPressItems);

      function NeedRebuild: Boolean;
      begin
        { TODO : Implement }
        Result := True;
      end;

    var
      VCount, I: Integer;
    begin
      if not Assigned(VDataset) then
        VDataset := Connector.CreateDataset;
      if not NeedRebuild then
      begin
        if AItems.RemovedProxies.Count > 0 then
        begin
          VDataset.SQL := DMLBuilder.DeleteLinkItemsStatement(AItems);
          AddRemovedIdParam(VDataset, AItems);
          VDataset.Execute;
        end;
        VDataset.SQL := DMLBuilder.InsertLinkStatement(AItems.Metadata);
        VCount := AItems.Count - AItems.AddedProxies.Count;
        for I := 0 to Pred(AItems.AddedProxies.Count) do
        begin
          AddLinkParams(
           VDataset, AItems, AItems.AddedProxies[I], AObject.Id, VCount + I);
          VDataset.Execute;
        end;
      end else
      begin
        VDataset.SQL := DMLBuilder.DeleteLinkStatement(AItems.Metadata);
        AddPersistentIdParam(VDataset, AObject.Id);
        VDataset.Execute;
        VDataset.SQL := DMLBuilder.InsertLinkStatement(AItems.Metadata);
        for I := 0 to Pred(AItems.Count) do
        begin
          AddLinkParams(VDataset, AItems, AItems.Proxies[I], AObject.Id, I);
          VDataset.Execute;
        end;
      end;
    end;

    procedure StoreParts(AParts: TPressParts);
    var
      VProxy: TPressProxy;
      VObject: TPressObject;
      I: Integer;
    begin
      for I := 0 to Pred(AParts.Count) do
      begin
        VProxy := AParts.Proxies[I];
        if VProxy.HasInstance then
        begin
          VObject := VProxy.Instance;
          if not VObject.IsPersistent or VObject.IsChanged then
            ObjectMapper.Store(VObject);
        end;
      end;
      UpdateLinks(AParts);
      for I := 0 to Pred(AParts.RemovedProxies.Count) do
        with AParts.RemovedProxies[I] do
          ObjectMapper.Dispose(ObjectClassType, ObjectId);
    end;

    procedure StoreReferences(AReferences: TPressReferences);
    var
      VProxy: TPressProxy;
      VObject: TPressObject;
      I: Integer;
    begin
      for I := 0 to Pred(AReferences.Count) do
      begin
        VProxy := AReferences.Proxies[I];
        if VProxy.HasInstance then
        begin
          VObject := VProxy.Instance;
          if not VObject.IsPersistent then
            Persistence.Store(VObject);
        end;
      end;
      UpdateLinks(AReferences);
    end;

  var
    VAttribute: TPressAttribute;
    I: Integer;
  begin
    VDataset := nil;
    try
      for I := 0 to Pred(Map.Count) do
        if Map[I].AttributeClass.InheritsFrom(TPressItems) then
        begin
          VAttribute := AObject.AttributeByName(Map[I].Name);
          if VAttribute.IsChanged then
            if VAttribute is TPressParts then
              StoreParts(TPressParts(VAttribute))
            else if VAttribute is TPressReferences then
              StoreReferences(TPressReferences(VAttribute));
        end;
    finally
      VDataset.Free;
    end;
  end;

var
  VDataset: TPressOPFDataset;
begin
  if AObject.IsPersistent then
    VDataset := UpdateDataset(AObject)
  else
    VDataset := InsertDataset;
  if VDataset.SQL <> '' then
  begin
    AddAttributeParams(VDataset, AObject);
    if VDataset.Execute = 0 then
      DoConcurrencyError(AObject);
  end;
  StoreItems;
end;

function TPressOPFAttributeMapper.UpdateDataset(
  AObject: TPressObject): TPressOPFDataset;
begin
  if not Assigned(FUpdateDataset) then
    FUpdateDataset := Connector.CreateDataset;
  FUpdateDataset.SQL := DMLBuilder.UpdateStatement(AObject);
  Result := FUpdateDataset;
end;

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
      (FMaps[I] as TPressOPFBulkMap).Retrieve;
end;

procedure TPressOPFCustomBulkRetrieve.UpdateProxies;
var
  I: Integer;
begin
  if Assigned(FProxyList) then
    for I := 0 to Pred(FProxyList.Count) do
      (FProxyList[I] as TPressOPFBulkProxy).UpdateProxy;
end;

{ TPressOPFBulkRetrieve }

constructor TPressOPFBulkRetrieve.Create(
  AObjectMapper: TPressOPFObjectMapper;
  AProxyList: TPressProxyList; ADepth: Integer);
begin
  inherited Create(AObjectMapper);
  FSourceProxyList := AProxyList;
  FDepth := ADepth;
end;

procedure TPressOPFBulkRetrieve.CreateProxies(
  AStartingAt, AItemCount: Integer);
var
  VProxy: TPressProxy;
  VObject: TPressObject;
  I, J: Integer;
begin
  I := 0;
  J := AStartingAt;
  while (I < AItemCount) and (J < FSourceProxyList.Count) do
  begin
    VProxy := FSourceProxyList[J];
    if VProxy.HasReference and not VProxy.HasInstance then
    begin
      VObject := ObjectMapper.Persistence.FindObject(
       VProxy.ObjectClassType, VProxy.ObjectId);
      if not Assigned(VObject) then
      begin
        ProxyList.AddProxy(VProxy);
        Inc(I);
      end else
        VProxy.Instance := VObject;
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

{ TPressOPFBulkProxy }

procedure TPressOPFBulkProxy.AddProxy(AProxy: TPressProxy);
begin
  FProxyList.Add(AProxy);
end;

constructor TPressOPFBulkProxy.Create(AProxy: TPressProxy);
begin
  inherited Create;
  FProxyList := TObjectList.Create(False);
  FObjectId := AProxy.ObjectId;
  FObjectClass := AProxy.ObjectClassType;
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

function TPressOPFBulkMapComplementary.CreateObjectList: TPressObjectList;
var
  I: Integer;
begin
  Result := TPressObjectList.Create(False);
  try
    for I := 0 to Pred(ProxyList.Count) do
      Result.Add(ProxyList[I].Instance);
  except
    FreeAndNil(Result);
    raise;
  end;
end;

procedure TPressOPFBulkMapComplementary.Retrieve;
var
  VObjects: TPressObjectList;
begin
  inherited;
  VObjects := CreateObjectList;
  try
    ObjectMapper.AttributeMapper[Maps.Last].RetrieveComplementaryMapsList(
     VObjects, FBaseClass);
  finally
    VObjects.Free;
  end;
end;

end.
