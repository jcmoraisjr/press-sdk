(*
  PressObjects, Persistence Mapper Classes
  Copyright (C) 2007-2008 Laserpress Ltda.

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
  PressSession,
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
    FAttributeMapperList: TObjectList;
    FConnector: TPressOPFConnector;
    FDDLBuilder: TPressOPFDDLBuilder;
    FGeneratorDatasetList: TStringList;
    FPersistence: TPressPersistence;
    FStorageModel: TPressOPFStorageModel;
    procedure CheckGenerators(AObject: TPressObject);
    procedure CheckOID(AObject: TPressObject);
    function GeneratorDataset(const AGeneratorName: string): TPressOPFDataset;
    function GetAttributeMapper(AMap: TPressOPFStorageMap): TPressOPFAttributeMapper;
    function GetDDLBuilder: TPressOPFDDLBuilder;
  protected
    function InternalAttributeMapperClass: TPressOPFAttributeMapperClass; virtual;
    function InternalDDLBuilderClass: TPressOPFDDLBuilderClass; virtual;
    function InternalDMLBuilderClass: TPressOPFDMLBuilderClass; virtual;
  public
    constructor Create(APersistence: TPressPersistence; AStorageModel: TPressOPFStorageModel; AConnector: TPressOPFConnector);
    destructor Destroy; override;
    procedure BulkRefresh(AProxyList: TPressProxyList; AAttributes: TPressSessionAttributes);
    procedure BulkRetrieve(AProxyList: TPressProxyList; AStartingAt, AItemCount: Integer; AAttributes: TPressSessionAttributes);
    function CreateDatabaseStatement(ACreateClearDatabaseStatements: Boolean = False): string;
    procedure Dispose(AClass: TPressObjectClass; const AId: string);
    function DMLBuilderClass: TPressOPFDMLBuilderClass;
    function GenerateId(const AGeneratorName: string): Integer;
    procedure Load(AObject: TPressObject; AIncludeLazyLoading: Boolean);
    procedure Refresh(AObject: TPressObject);
    function Retrieve(AClass: TPressObjectClass; const AId: string; AMetadata: TPressObjectMetadata; AAttributes: TPressSessionAttributes): TPressObject;
    procedure RetrieveAttribute(AAttribute: TPressAttribute);
    procedure Rollback;
    function SelectGeneratorStatement(const AGeneratorName: string): string;
    procedure Store(AObject: TPressObject);
    property AttributeMapper[AMap: TPressOPFStorageMap]: TPressOPFAttributeMapper read GetAttributeMapper;
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
    FDMLBuilder: TPressOPFDMLBuilder;
    FInsertDataset: TPressOPFDataset;
    FMap: TPressOPFStorageMap;
    FMaps: TPressOPFStorageMapList;
    FObjectMapper: TPressOPFObjectMapper;
    FPersistence: TPressPersistence;
    FSelectAttributeDataset: TPressOPFDataset;
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
    procedure AddIdParam(ADataset: TPressOPFDataset; const AParamName, AValue: string; AIdType: TPressAttributeBaseType = attUnknown);
    procedure AddIntegerParam(ADataset: TPressOPFDataset; const AParamName: string; AValue: Integer);
    procedure AddLinkParams(ADataset: TPressOPFDataset; AItems: TPressItems; AProxy: TPressProxy; const AOwnerId: string; AIndex: Integer);
    procedure AddNullParam(ADataset: TPressOPFDataset; const AParamName: string; AFieldType: TPressOPFFieldType);
    procedure AddPersistentIdParam(ADataset: TPressOPFDataset; const APersistentId: string);
    procedure AddUpdateCountParam(ADataset: TPressOPFDataset; AObject: TPressObject);
    function DeleteDataset: TPressOPFDataset;
    function GetDDLBuilder: TPressOPFDDLBuilder;
    function InsertDataset: TPressOPFDataset;
    function SelectAttributeDataset(AAttribute: TPressAttribute): TPressOPFDataset;
    function SelectBaseDataset(AAttributes: TPressSessionAttributes): TPressOPFDataset;
    function SelectBaseGroupDataset(AIdCount: Integer; AAttributes: TPressSessionAttributes): TPressOPFDataset;
    function SelectComplementaryDataset(ABaseClass: TPressObjectClass; AAttributes: TPressSessionAttributes): TPressOPFDataset;
    function SelectComplementaryGroupDataset(AIdCount: Integer; ABaseClass: TPressObjectClass; AAttributes: TPressSessionAttributes): TPressOPFDataset;
    function UpdateDataset(AObject: TPressObject): TPressOPFDataset;
  protected
    function CreateObject(AClass: TPressObjectClass; AMetadata: TPressObjectMetadata; const AId: string; ADataRow: TPressOPFDataRow; AAttributes: TPressSessionAttributes): TPressObject;
    procedure DoConcurrencyError(AObject: TPressObject); virtual;
    procedure ReadAttribute(AAttribute: TPressAttribute; ADataRow: TPressOPFDataRow; var ADatasetCache: TPressOPFDataset);
    procedure ReadAttributes(AObject: TPressObject; ADataRow: TPressOPFDataRow; AAttributes: TPressSessionAttributes);
    procedure ReadObject(AObject: TPressObject; ABaseClass: TPressObjectClass; ADataRow: TPressOPFDataRow; AAttributes: TPressSessionAttributes);
    function ResolveClassType(ADataRow: TPressOPFDataRow): TPressObjectClass;
    property Connector: TPressOPFConnector read FConnector;
    property DDLBuilder: TPressOPFDDLBuilder read GetDDLBuilder;
    property DMLBuilder: TPressOPFDMLBuilder read FDMLBuilder;
    property ObjectMapper: TPressOPFObjectMapper read FObjectMapper;
    property Persistence: TPressPersistence read FPersistence;
  public
    constructor Create(AObjectMapper: TPressOPFObjectMapper; AMap: TPressOPFStorageMap);
    destructor Destroy; override;
    procedure DisposeObject(AObject: TPressObject);
    procedure DisposeRecord(const AId: string);
    procedure RefreshStructures(AObjects: array of TPressObject; AAttributes: TPressSessionAttributes);
    procedure RetrieveAttribute(AAttribute: TPressAttribute);
    function RetrieveBaseMaps(const AId: string; AMetadata: TPressObjectMetadata; AAttributes: TPressSessionAttributes): TPressObject;
    procedure RetrieveBaseMapsList(AIDs: TPressStringArray; AObjects: TPressObjectList; AAttributes: TPressSessionAttributes);
    procedure RetrieveComplementaryMaps(AObject: TPressObject; ABaseClass: TPressObjectClass; AAttributes: TPressSessionAttributes);
    procedure RetrieveComplementaryMapsArray(AObjects: array of TPressObject; ABaseClass: TPressObjectClass; AAttributes: TPressSessionAttributes);
    procedure Store(AObject: TPressObject);
    property Map: TPressOPFStorageMap read FMap;
    property Maps: TPressOPFStorageMapList read FMaps;
  end;

implementation

uses
  SysUtils,
  TypInfo,
  {$IFDEF PressLog}PressLog,{$ENDIF}
  PressConsts,
  PressOPFBulk;

{ TPressOPFObjectMapper }

procedure TPressOPFObjectMapper.BulkRefresh(
  AProxyList: TPressProxyList; AAttributes: TPressSessionAttributes);
var
  VBulkRefresh: TPressOPFBulkRefresh;
begin
  VBulkRefresh := TPressOPFBulkRefresh.Create(Self, AAttributes, AProxyList);
  try
    VBulkRefresh.Execute;
  finally
    VBulkRefresh.Free;
  end;
end;

procedure TPressOPFObjectMapper.BulkRetrieve(
  AProxyList: TPressProxyList; AStartingAt, AItemCount: Integer;
  AAttributes: TPressSessionAttributes);
var
  VBulkRetrieve: TPressOPFBulkRetrieve;
begin
  VBulkRetrieve := TPressOPFBulkRetrieve.Create(Self, AProxyList, AAttributes);
  try
    VBulkRetrieve.Execute(AStartingAt, AItemCount);
  finally
    VBulkRetrieve.Free;
  end;
end;

procedure TPressOPFObjectMapper.CheckGenerators(AObject: TPressObject);

  procedure CheckAttr(AAttribute: TPressAttribute);
  begin
    if (AAttribute.Metadata.GeneratorName <> '') and AAttribute.IsNull and
     (AAttribute is TPressValue) then
      AAttribute.AsInteger :=
       GenerateId(AAttribute.Metadata.GeneratorName);
  end;

var
  I: Integer;
begin
  for I := 0 to Pred(AObject.AttributeCount) do
    CheckAttr(AObject.Attributes[I]);
end;

procedure TPressOPFObjectMapper.CheckOID(AObject: TPressObject);
begin
  if AObject.Id = '' then
    AObject.Id := Persistence.GenerateOID(AObject.Attributes[0]);
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
var
  I: Integer;
begin
  if Assigned(FGeneratorDatasetList) then
  begin
    for I := 0 to Pred(FGeneratorDatasetList.Count) do
      FGeneratorDatasetList.Objects[I].Free;
    FGeneratorDatasetList.Free;
  end;
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
        PressAssignPersistentId(Persistence, VObject, '');
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

function TPressOPFObjectMapper.GenerateId(
  const AGeneratorName: string): Integer;
var
  VDataset: TPressOPFDataset;
begin
  VDataset := GeneratorDataset(AGeneratorName);
  VDataset.Execute;
  Result := VDataset[0][0].Value;
end;

function TPressOPFObjectMapper.GeneratorDataset(
  const AGeneratorName: string): TPressOPFDataset;
var
  VIndex: Integer;
begin
  if not Assigned(FGeneratorDatasetList) then
  begin
    FGeneratorDatasetList := TStringList.Create;
    FGeneratorDatasetList.Sorted := True;
  end;
  VIndex := FGeneratorDatasetList.IndexOf(AGeneratorName);
  if VIndex = -1 then
  begin
    Result := Connector.CreateDataset;
    try
      Result.SQL :=
       Format(DDLBuilder.SelectGeneratorStatement, [AGeneratorName]);
      FGeneratorDatasetList.AddObject(AGeneratorName, Result);
    except
      FreeAndNil(Result);
      raise;
    end;
  end else
    Result := TPressOPFDataset(FGeneratorDatasetList.Objects[VIndex]);
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

procedure TPressOPFObjectMapper.Load(
  AObject: TPressObject; AIncludeLazyLoading: Boolean);
var
  VAttributes: TPressSessionAttributes;
begin
  VAttributes := TPressSessionAttributes.Create;
  try
    VAttributes.AddUnloadedAttributes(AObject, AIncludeLazyLoading);
    if not VAttributes.IsEmpty then
      AttributeMapper[StorageModel.Maps[AObject.ClassType].Last].RetrieveComplementaryMaps(
       AObject, nil, VAttributes);
  finally
    VAttributes.Free;
  end;
end;

procedure TPressOPFObjectMapper.Refresh(AObject: TPressObject);
var
  VAttributeMapper: TPressOPFAttributeMapper;
  VMaps: TPressOPFStorageMapList;
  VAttributes: TPressSessionAttributes;
begin
  VMaps := StorageModel.Maps[AObject.ClassType];
  if VMaps.Count > 0 then
  begin
    AObject.Id := AObject.PersistentId;
    VAttributeMapper := AttributeMapper[VMaps.Last];
    VAttributes := TPressSessionAttributes.Create('*');
    try
      VAttributeMapper.RetrieveComplementaryMaps(AObject, nil, VAttributes);
      VAttributeMapper.RefreshStructures([AObject], VAttributes);
    finally
      VAttributes.Free;
    end;
  end;
end;

function TPressOPFObjectMapper.Retrieve(AClass: TPressObjectClass;
  const AId: string; AMetadata: TPressObjectMetadata;
  AAttributes: TPressSessionAttributes): TPressObject;
var
  VMaps: TPressOPFStorageMapList;
  VObject: TPressObject;
begin
  VMaps := StorageModel.Maps[AClass];
  if VMaps.Count > 0 then
  begin
    VObject := AttributeMapper[VMaps.Last].RetrieveBaseMaps(AId, AMetadata, AAttributes);
    try
      if Assigned(VObject) and
       (VObject.ClassType <> AClass) and (VObject is AClass) then
      begin
        VObject.DisableChanges;
        AttributeMapper[StorageModel.Maps[VObject.ClassType].Last].
         RetrieveComplementaryMaps(VObject, AClass, AAttributes);
        VObject.EnableChanges;
      end;
    except
      VObject.Free;
      raise;
    end;
    Result := VObject;
  end else
    Result := nil;
end;

procedure TPressOPFObjectMapper.RetrieveAttribute(AAttribute: TPressAttribute);
begin
  AttributeMapper[StorageModel.Maps[AAttribute.Metadata.Owner.ObjectClass].Last].
   RetrieveAttribute(AAttribute);
end;

procedure TPressOPFObjectMapper.Rollback;
begin
  { TODO : Remove this method as well as ResetClassList from StorageModel
    after implement object transaction control }
  StorageModel.ResetClassList;
end;

function TPressOPFObjectMapper.SelectGeneratorStatement(const AGeneratorName: string): string;
begin
  if AGeneratorName <> '' then
    Result := Format(DDLBuilder.SelectGeneratorStatement, [AGeneratorName])
  else
    Result := '';
end;

procedure TPressOPFObjectMapper.Store(AObject: TPressObject);
var
  VMaps: TPressOPFStorageMapList;
  I: Integer;
begin
  CheckGenerators(AObject);
  CheckOID(AObject);
  PressEvolveUpdateCount(AObject);
  VMaps := StorageModel.Maps[AObject.ClassType];
  for I := Pred(VMaps.Count) downto 0 do
    AttributeMapper[VMaps[I]].Store(AObject);
  PressAssignPersistentId(Persistence, AObject, AObject.Id);
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
        attPlainString, attAnsiString:
          VParam.AsString := AValue.AsString;
        attInteger:
          if (AValue as TPressInteger).IsRelativelyChanged then
            VParam.AsInt32 := TPressInteger(AValue).Diff
          else
            VParam.AsInt32 := AValue.AsInteger;
        attDouble:
          if (AValue as TPressDouble).IsRelativelyChanged then
            VParam.AsDouble := TPressDouble(AValue).Diff
          else
            VParam.AsDouble := AValue.AsDouble;
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
    AddIdParam(ADataset, APart.PersistentName, VObject.Id, VObject.Metadata.IdType);
  end;

  procedure AddReferenceAttribute(AReference: TPressReference);
  begin
    if not AReference.Proxy.IsEmpty then
    begin
      if AReference.Proxy.HasInstance and
       not Persistence.IsPersistent(AReference.Value) then
        Persistence.Store(AReference.Value);
      AddIdParam(ADataset, AReference.PersistentName,
       AReference.Proxy.ObjectId, AReference.Proxy.Metadata.IdType);
    end else
      AddNullParam(ADataset, AReference.PersistentName,
       DDLBuilder.AttributeTypeToFieldType(
        AReference.Metadata.ObjectClassMetadata.IdType));
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
  VPartsAttribute: TPressAttributeMetadata;
  VIsPersistentObject: Boolean;
  I: Integer;
begin
  VIsPersistentObject := Persistence.IsPersistent(AObject);
  if not VIsPersistentObject then
    AddClassIdParam(ADataset, AObject);
  VPartsAttribute := Map.Metadata.OwnerPartsMetadata;
  if Assigned(VPartsAttribute) then
    if Assigned(AObject.Owner) and (AObject.Owner.Id <> '') then
    begin
      AddIdParam(ADataset, VPartsAttribute.PersLinkParentName,
       AObject.Owner.Id, AObject.Owner.Metadata.IdType);
      AddIntegerParam(ADataset, VPartsAttribute.PersLinkPosName, 0);
    end else
      raise EPressOPFError.Create(SCannotStoreOrphanObject);
  if Map.Count > 0 then
  begin
    VAttribute := AObject.AttributeByName(Map[0].Name);
    if not VIsPersistentObject or VAttribute.IsChanged then
      AddIdParam(ADataset, VAttribute.PersistentName, VAttribute.AsString,
       VAttribute.Metadata.AttributeClass.AttributeBaseType);
    for I := 1 to Pred(Map.Count) do
    begin
      VAttribute := AObject.AttributeByName(Map[I].Name);
      if not VIsPersistentObject or VAttribute.IsChanged then
        AddAttributeParam(ADataset, VAttribute);
    end;
  end;
  if not VIsPersistentObject or (Map.Metadata = AObject.Metadata) then
    AddUpdateCountParam(ADataset, AObject);
  if VIsPersistentObject then
    AddPersistentIdParam(ADataset, AObject.PersistentId);
end;

procedure TPressOPFAttributeMapper.AddClassIdParam(
  ADataset: TPressOPFDataset; AObject: TPressObject);
begin
  if Map.Metadata.ClassIdName <> '' then
    AddIdParam(ADataset, Map.Metadata.ClassIdName,
     ObjectMapper.StorageModel.ClassIdByName(AObject.ClassName),
     ObjectMapper.StorageModel.TableMetadatas.ClassIdMetadata.IdType);
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
  ADataset: TPressOPFDataset; const AParamName, AValue: string;
  AIdType: TPressAttributeBaseType);
begin
  if AParamName <> '' then
  begin
    if AIdType = attUnknown then
      AIdType := Map.IdType;
    case AIdType of
      attPlainString:
        ADataset.Params.ParamByName(AParamName).AsString := AValue;
      attInteger:
        ADataset.Params.ParamByName(AParamName).AsInt32 := StrToInt(AValue);
      else
        raise EPressOPFError.CreateFmt(SUnsupportedFieldType, [
         GetEnumName(TypeInfo(TPressAttributeBaseType), Ord(AIdType))]);
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
    AddIdParam(ADataset, AItems.Metadata.PersLinkIdName,
     Persistence.GenerateOID(AItems),
     ObjectMapper.StorageModel.Model.DefaultKeyType.AttributeBaseType);
  AddIdParam(ADataset, AItems.Metadata.PersLinkParentName,
   AOwnerId, AItems.Owner.Metadata.IdType);
  AddIdParam(ADataset, AItems.Metadata.PersLinkChildName, AProxy.ObjectId,
   AItems.Metadata.ObjectClassMetadata.IdType);
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
    AddIdParam(ADataset, SPressIdString + InttoStr(I),
     AItems.RemovedProxies[I].ObjectId,
     AItems.Metadata.ObjectClassMetadata.IdType);
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
  FDMLBuilder := FObjectMapper.DMLBuilderClass.Create(Maps);
end;

function TPressOPFAttributeMapper.CreateObject(
  AClass: TPressObjectClass; AMetadata: TPressObjectMetadata;
  const AId: string; ADataRow: TPressOPFDataRow;
  AAttributes: TPressSessionAttributes): TPressObject;
var
  VId: string;
  I: Integer;
begin
  Result := Persistence.CreateObject(AClass, AMetadata);
  try
    Result.DisableChanges;
    if AId <> '' then
      VId := AId
    else
      VId := ADataRow.FieldByName(Map[0].PersistentName).AsString;
    Result.Id := VId;
    ReadAttributes(Result, ADataRow, AAttributes);
    for I := Maps.Count - 2 downto 0 do
      ObjectMapper.AttributeMapper[Maps[I]].ReadAttributes(
       Result, ADataRow, AAttributes);
    if Result.Metadata.UpdateCountName <> '' then
      PressAssignUpdateCount(Result,
       ADataRow.FieldByName(Result.Metadata.UpdateCountName).Value);
    PressAssignPersistentId(Persistence, Result, VId);
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
  FSelectAttributeDataset.Free;
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

  {procedure DisposePartObjects;}
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
          if CurrentItem.HasId then
            ObjectMapper.Dispose(
             CurrentItem.ObjectClassType, CurrentItem.ObjectId);
      finally
        Free;
      end;
    end;

  {procedure DisposeLinkedObjects;}
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
          if not VMetadata.IsEmbeddedLink then
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

function TPressOPFAttributeMapper.GetDDLBuilder: TPressOPFDDLBuilder;
begin
  Result := ObjectMapper.DDLBuilder;
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

procedure TPressOPFAttributeMapper.ReadAttribute(
  AAttribute: TPressAttribute; ADataRow: TPressOPFDataRow;
  var ADatasetCache: TPressOPFDataset);

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
    if not Assigned(ADatasetCache) then
      ADatasetCache := Connector.CreateDataset;
    ADatasetCache.SQL := DMLBuilder.SelectLinkStatement(AItems.Metadata);
    AddPersistentIdParam(ADatasetCache, AItems.Owner.Id);
    ADatasetCache.Execute;
    AItems.Clear;
    for I := 0 to Pred(ADatasetCache.Count) do
      AItems.AddReference(AItems.ObjectClass.ClassName,
       ADatasetCache[I][0].Value);
  end;

begin
  AAttribute.Assigning;
  if AAttribute is TPressValue then
    LoadValue(TPressValue(AAttribute))
  else if AAttribute is TPressItem then
    LoadItem(TPressItem(AAttribute))
  else if AAttribute is TPressItems then
    LoadItems(TPressItems(AAttribute));
end;

procedure TPressOPFAttributeMapper.ReadAttributes(
  AObject: TPressObject; ADataRow: TPressOPFDataRow;
  AAttributes: TPressSessionAttributes);
var
  VDataset: TPressOPFDataset;
  VAttribute: TPressAttributeMetadata;
  I: Integer;
begin
  VDataset := nil;
  try
    for I := 1 to Pred(Map.Count) do
    begin
      VAttribute := Map[I];
      if AAttributes.Include(VAttribute) then
        ReadAttribute(AObject.AttributeByName(VAttribute.Name), ADataRow, VDataset);
    end;
  finally
    VDataset.Free;
  end;
end;

procedure TPressOPFAttributeMapper.ReadObject(AObject: TPressObject;
  ABaseClass: TPressObjectClass; ADataRow: TPressOPFDataRow;
  AAttributes: TPressSessionAttributes);
var
  I: Integer;
begin
  if AObject.Metadata.UpdateCountName <> '' then
    PressAssignUpdateCount(AObject,
     ADataRow.FieldByName(AObject.Metadata.UpdateCountName).Value);
  ReadAttributes(AObject, ADataRow, AAttributes);
  for I := Maps.Count - 2 downto 0 do
  begin
    if Maps[I].ObjectClass = ABaseClass then
      Exit;
    ObjectMapper.AttributeMapper[Maps[I]].ReadAttributes(
     AObject, ADataRow, AAttributes);
  end;
end;

procedure TPressOPFAttributeMapper.RefreshStructures(
  AObjects: array of TPressObject; AAttributes: TPressSessionAttributes);
var
  VProxyList: TPressProxyList;

  procedure CheckProxy(AProxy: TPressProxy);
  begin
    Persistence.SynchronizeProxy(AProxy);
    if AProxy.HasInstance then
    begin
      if not Assigned(VProxyList) then
        VProxyList := TPressProxyList.Create(Persistence, False, ptShared);
      VProxyList.Add(AProxy);
    end;
  end;

  procedure RefreshItem(AItem: TPressItem);
  begin
    CheckProxy(AItem.Proxy);
  end;

  procedure RefreshItems(AItems: TPressItems);
  var
    I: Integer;
  begin
    for I := 0 to Pred(AItems.Count) do
      CheckProxy(AItems.ProxyList[I]);
  end;

var
  VMetadata: TPressAttributeMetadata;
  VAttribute: TPressAttribute;
  I, J: Integer;
begin
  VProxyList := nil;
  try
    for I := 0 to Pred(Map.Count) do
    begin
      VMetadata := Map[I];
      if VMetadata.AttributeClass.InheritsFrom(TPressStructure) then
      begin
        for J := 0 to Pred(Length(AObjects)) do
        begin
          VAttribute := AObjects[J].AttributeByName(VMetadata.Name);
          if VAttribute is TPressItem then
            RefreshItem(TPressItem(VAttribute))
          else if VAttribute is TPressItems then
            RefreshItems(TPressItems(VAttribute));
        end;
      end;
    end;
    if Assigned(VProxyList) then
      ObjectMapper.BulkRefresh(VProxyList, AAttributes);
  finally
    VProxyList.Free;
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

procedure TPressOPFAttributeMapper.RetrieveAttribute(
  AAttribute: TPressAttribute);
var
  VDataset, VDatasetCache: TPressOPFDataset;
  VDataRow: TPressOPFDataRow;
begin
  VDataRow := nil;
  if not (AAttribute is TPressItems) then
  begin
    VDataset := SelectAttributeDataset(AAttribute);
    VDataset.Execute;
    if VDataset.Count = 1 then
      VDataRow := VDataset[0]
    else
      raise EPressOPFError.CreateFmt(SInstanceNotFound,
       [AAttribute.Owner.ClassName, AAttribute.Owner.Id]);
  end;
  VDatasetCache := nil;
  try
    ReadAttribute(AAttribute, VDataRow, VDatasetCache);
  finally
    VDatasetCache.Free;
  end;
end;

function TPressOPFAttributeMapper.RetrieveBaseMaps(
  const AId: string; AMetadata: TPressObjectMetadata;
  AAttributes: TPressSessionAttributes): TPressObject;
var
  VDataset: TPressOPFDataset;
begin
  VDataset := SelectBaseDataset(AAttributes);
  AddPersistentIdParam(VDataset, AId);
  VDataset.Execute;
  if VDataset.Count = 1 then
    Result := CreateObject(
     ResolveClassType(VDataset[0]), AMetadata, AId, VDataset[0], AAttributes)
  else
    Result := nil;
end;

procedure TPressOPFAttributeMapper.RetrieveBaseMapsList(
  AIDs: TPressStringArray; AObjects: TPressObjectList;
  AAttributes: TPressSessionAttributes);

  function FindID(const AID: string; ADataset: TPressOPFDataset; AIndex: Integer): Boolean;
  var
    I: Integer;
  begin
    Result := True;
    for I := 0 to Pred(ADataset.Count) do
      if ADataset[I][AIndex].AsString = AID then
        Exit;
    Result := False;
  end;

var
  VDataset: TPressOPFDataset;
  VIndex: Integer;
  I: Integer;
begin
  VDataset := SelectBaseGroupDataset(Length(AIDs), AAttributes);
  AddIdArrayParam(VDataset, AIDs);
  VDataset.Execute;
  if VDataset.Count < Length(AIDs) then
  begin
    VIndex := VDataset.FieldDefs.IndexOfName(Map[0].PersistentName);
    for I := 0 to Pred(Length(AIDs)) do
      if not FindID(AIDs[I], VDataset, VIndex) then
        raise EPressOPFError.CreateFmt(SInstanceNotFound,
         [Map.ObjectClass.ClassName, AIDs[I]]);
  end;
  for I := 0 to Pred(VDataset.Count) do
    AObjects.Add(CreateObject(
     ResolveClassType(VDataset[I]), nil, '', VDataset[I], AAttributes));
end;

procedure TPressOPFAttributeMapper.RetrieveComplementaryMaps(
  AObject: TPressObject; ABaseClass: TPressObjectClass;
  AAttributes: TPressSessionAttributes);
var
  VDataset: TPressOPFDataset;
begin
  VDataset := SelectComplementaryDataset(ABaseClass, AAttributes);
  AddPersistentIdParam(VDataset, AObject.Id);
  VDataset.Execute;
  if VDataset.Count = 1 then
    ReadObject(AObject, ABaseClass, VDataset[0], AAttributes)
  else
    raise EPressOPFError.CreateFmt(SInstanceNotFound,
     [AObject.ClassName, AObject.Id]);
end;

procedure TPressOPFAttributeMapper.RetrieveComplementaryMapsArray(
  AObjects: array of TPressObject; ABaseClass: TPressObjectClass;
  AAttributes: TPressSessionAttributes);

  function BuildIDs: TPressStringArray;
  var
    I: Integer;
  begin
    SetLength(Result, Length(AObjects));
    for I := 0 to Pred(Length(AObjects)) do
      Result[I] := AObjects[I].Id;
  end;

  function IndexOfId(const AId: string): Integer;
  begin
    for Result := 0 to Pred(Length(AObjects)) do
      if AObjects[Result].Id = AId then
        Exit;
    Result := -1;
  end;

var
  VDataset: TPressOPFDataset;
  VIDs: TPressStringArray;
  VIndex, I: Integer;
begin
  VDataset := SelectComplementaryGroupDataset(Length(AObjects), ABaseClass, AAttributes);
  VIDs := BuildIDs;
  AddIdArrayParam(VDataset, VIDs);
  VDataset.Execute;
  for I := 0 to Pred(VDataset.Count) do
  begin
    VIndex := IndexOfId(VDataset[I].FieldByName(Map[0].PersistentName).Value);
    if VIndex >= 0 then
    begin
      ReadObject(AObjects[VIndex], ABaseClass, VDataset[I], AAttributes);
      VIDs[VIndex] := '';
    end;
  end;
  for I := 0 to Pred(Length(VIDs)) do
    if VIDs[I] <> '' then
      raise EPressOPFError.CreateFmt(SInstanceNotFound,
       [AObjects[I].ClassName, VIDs[I]]);
end;

function TPressOPFAttributeMapper.SelectAttributeDataset(
  AAttribute: TPressAttribute): TPressOPFDataset;
begin
  if not Assigned(FSelectAttributeDataset) then
    FSelectAttributeDataset := Connector.CreateDataset;
  FSelectAttributeDataset.SQL :=
   DMLBuilder.SelectAttributeStatement(AAttribute.Metadata);
  AddIdParam(
   FSelectAttributeDataset, SPressPersistentIdParamString, AAttribute.Owner.Id);
  Result := FSelectAttributeDataset;
end;

function TPressOPFAttributeMapper.SelectBaseDataset(
  AAttributes: TPressSessionAttributes): TPressOPFDataset;
begin
  if not Assigned(FSelectBaseDataset) then
    FSelectBaseDataset := Connector.CreateDataset;
  FSelectBaseDataset.SQL := DMLBuilder.SelectStatement(nil, AAttributes);
  Result := FSelectBaseDataset;
end;

function TPressOPFAttributeMapper.SelectBaseGroupDataset(
  AIdCount: Integer; AAttributes: TPressSessionAttributes): TPressOPFDataset;
begin
  if not Assigned(FSelectBaseGroupDataset) then
    FSelectBaseGroupDataset := Connector.CreateDataset;
  FSelectBaseGroupDataset.SQL :=
   DMLBuilder.SelectGroupStatement(AIdCount, nil, AAttributes);
  Result := FSelectBaseGroupDataset;
end;

function TPressOPFAttributeMapper.SelectComplementaryDataset(
  ABaseClass: TPressObjectClass;
  AAttributes: TPressSessionAttributes): TPressOPFDataset;
begin
  if not Assigned(FSelectComplementaryDataset) then
    FSelectComplementaryDataset := Connector.CreateDataset;
  FSelectComplementaryDataset.SQL :=
   DMLBuilder.SelectStatement(ABaseClass, AAttributes);
  Result := FSelectComplementaryDataset;
end;

function TPressOPFAttributeMapper.SelectComplementaryGroupDataset(
  AIdCount: Integer; ABaseClass: TPressObjectClass;
  AAttributes: TPressSessionAttributes): TPressOPFDataset;
begin
  if not Assigned(FSelectComplementaryGroupDataset) then
    FSelectComplementaryGroupDataset := Connector.CreateDataset;
  FSelectComplementaryGroupDataset.SQL :=
   DMLBuilder.SelectGroupStatement(AIdCount, ABaseClass, AAttributes);
  Result := FSelectComplementaryGroupDataset;
end;

procedure TPressOPFAttributeMapper.Store(AObject: TPressObject);

  procedure StoreItems;
  var
    VDataset: TPressOPFDataset;

    function NeedRebuild(AItems: TPressItems): Boolean;
    begin
      Result := (AItems.AddedProxies.Count > 0) or
       (AItems.RemovedProxies.Count > 0);
      { TODO : or Items.Inserted instead of Added }
    end;

    procedure UpdateEmbeddedLinks(AItems: TPressItems);
    begin
      { TODO : Implement }
    end;

    procedure UpdateExternalLinks(AItems: TPressItems);
    var
      VCount, I: Integer;
    begin
      if not Assigned(VDataset) then
        VDataset := Connector.CreateDataset;
      if not NeedRebuild(AItems) then
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
          AddLinkParams(VDataset, AItems, AItems.ProxyList[I], AObject.Id, I);
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
      if AParts.Metadata.IsEmbeddedLink then
        UpdateEmbeddedLinks(AParts);
      for I := 0 to Pred(AParts.Count) do
      begin
        VProxy := AParts.ProxyList[I];
        if VProxy.HasInstance then
        begin
          VObject := VProxy.Instance;
          if not Persistence.IsPersistent(VObject) or VObject.IsChanged then
            ObjectMapper.Store(VObject);
        end;
      end;
      if not AParts.Metadata.IsEmbeddedLink then
        UpdateExternalLinks(AParts);
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
        VProxy := AReferences.ProxyList[I];
        if VProxy.HasInstance then
        begin
          VObject := VProxy.Instance;
          if not Persistence.IsPersistent(VObject) then
            Persistence.Store(VObject);
        end;
      end;
      UpdateExternalLinks(AReferences);
    end;

  {procedure StoreItems;}
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
  if Persistence.IsPersistent(AObject) then
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

end.
