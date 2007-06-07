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
  PressOPFConnector;

type
  TPressOPFAttributeMapper = class;
  TPressOPFAttributeMapperClass = class of TPressOPFAttributeMapper;
  TPressOPFDDLBuilder = class;
  TPressOPFDDLBuilderClass = class of TPressOPFDDLBuilder;
  TPressOPFDMLBuilder = class;
  TPressOPFDMLBuilderClass = class of TPressOPFDMLBuilder;
  TPressOPFStorageMap = class;
  TPressOPFStorageModel = class;

  TPressOPFObjectMapperClass = class of TPressOPFObjectMapper;

  TPressOPFObjectMapper = class(TObject)
  private
    { TODO : Implement concurrency control }
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
    function CreateDatabaseStatement: string;
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
    FDMLBuilder: TPressOPFDMLBuilder;
    FInsertDataset: TPressOPFDataset;
    FMap: TPressOPFStorageMap;
    FObjectMapper: TPressOPFObjectMapper;
    FPersistence: TPressPersistence;
    FSelectDataset: TPressOPFDataset;
    FUpdateDataset: TPressOPFDataset;
    procedure AddAttributeParam(ADataset: TPressOPFDataset; AAttribute: TPressAttribute);
    procedure AddAttributeParams(ADataset: TPressOPFDataset; AObject: TPressObject);
    procedure AddClassIdParam(ADataset: TPressOPFDataset; AObject: TPressObject);
    procedure AddRemovedIdParam(ADataset: TPressOPFDataset; AItems: TPressItems);
    procedure AddIntegerParam(ADataset: TPressOPFDataset; const AParamName: string; AValue: Integer);
    procedure AddLinkParams(ADataset: TPressOPFDataset; AItems: TPressItems; AProxy: TPressProxy; const AOwnerId: string; AIndex: Integer);
    procedure AddNullParam(ADataset: TPressOPFDataset; const AParamName: string);
    procedure AddPersistentIdParam(ADataset: TPressOPFDataset; const APersistentId: string);
    procedure AddStringParam(ADataset: TPressOPFDataset; const AParamName, AValue: string);
    procedure AddUpdateCountParam(ADataset: TPressOPFDataset; AObject: TPressObject);
    function DeleteDataset: TPressOPFDataset;
    function InsertDataset: TPressOPFDataset;
    procedure RetrieveAttributes(AObject: TPressObject; ADataRow: TPressOPFDataRow);
    function SelectDataset: TPressOPFDataset;
    function UpdateDataset(AObject: TPressObject): TPressOPFDataset;
  protected
    procedure DoConcurrencyError(AObject: TPressObject); virtual;
    property Connector: TPressOPFConnector read FConnector;
    property DMLBuilder: TPressOPFDMLBuilder read FDMLBuilder;
    property ObjectMapper: TPressOPFObjectMapper read FObjectMapper;
    property Persistence: TPressPersistence read FPersistence;
  public
    constructor Create(AObjectMapper: TPressOPFObjectMapper; AMap: TPressOPFStorageMap);
    destructor Destroy; override;
    procedure DisposeObject(AObject: TPressObject);
    procedure DisposeRecord(const AId: string);
    function Retrieve(AObject: TPressObject; const AId: string): Boolean;
    function RetrieveRootMap(AClass: TPressObjectClass; const AId: string; AMetadata: TPressObjectMetadata): TPressObject;
    procedure Store(AObject: TPressObject);
    property Map: TPressOPFStorageMap read FMap;
  end;

  TPressOPFSQLBuilder = class(TObject)
  protected
    procedure ConcatStatements(const AStatementStr, AConnectorToken: string; var ABuffer: string);
  end;

  TPressOPFTableMetadata = class;
  TPressOPFFieldMetadata = class;
  TPressOPFIndexMetadata = class;
  TPressOPFForeignKeyMetadata = class;

  TPressOPFDDLBuilder = class(TPressOPFSQLBuilder)
  protected
    function AttributeTypeToFieldType(AAttributeBaseType: TPressAttributeBaseType): TPressOPFFieldType;
    function BuildFieldType(AFieldMetadata: TPressOPFFieldMetadata): string;
    function BuildStringList(AList: TStrings): string;
    function InternalFieldTypeStr(AFieldType: TPressOPFFieldType): string; virtual;
  public
    function CreateDatabaseStatement(AModel: TPressOPFStorageModel): string; virtual;
    function CreateFieldStatement(AFieldMetadata: TPressOPFFieldMetadata): string; virtual;
    function CreateFieldStatementList(ATableMetadata: TPressOPFTableMetadata): string; virtual;
    function CreateForeignKeyStatement(ATableMetadata: TPressOPFTableMetadata; AForeignKeyMetadata: TPressOPFForeignKeyMetadata): string; virtual;
    function CreateIndexStatement(ATableMetadata: TPressOPFTableMetadata; AIndexMetadata: TPressOPFIndexMetadata): string; virtual;
    function CreatePrimaryKeyStatement(ATableMetadata: TPressOPFTableMetadata): string; virtual;
    function CreateTableStatement(ATableMetadata: TPressOPFTableMetadata): string; virtual;
  end;

  TPressOPFExternalField = class(TObject)
  private
    FAttributeMetadata: TPressAttributeMetadata;
    FId: Integer;
    FObjectMetadata: TPressObjectMetadata;
    function GetAsSQLField: string;
    function GetFieldAlias: string;
    function GetTableName: string;
    function GetTableAlias: string;
    function GetFieldName: string;
  public
    constructor Create(AAttributeMetadata: TPressAttributeMetadata; AId: Integer);
    property AsSQLField: string read GetAsSQLField;
    property AttributeMetadata: TPressAttributeMetadata read FAttributeMetadata;
    property FieldAlias: string read GetFieldAlias;
    property FieldName: string read GetFieldName;
    property ObjectMetadata: TPressObjectMetadata read FObjectMetadata;
    property TableAlias: string read GetTableAlias;
    property TableName: string read GetTableName;
  end;

  TPressOPFHelperField = (hfOID, hfClassId, hfUpdateCount);
  TPressOPFHelperFields = set of TPressOPFHelperField;
  TPressOPFPrefixType = (ptNone, ptColon, ptTableAlias);

  TPressOPFDMLBuilder = class(TPressOPFSQLBuilder)
  private
    FAttributeIterator: TPressAttributeMetadataIterator;
    FExternalFields: TObjectList;
    FMainTableAlias: string;
    FMap: TPressOPFStorageMap;
    function GetExternalFields(AAttributeMetadata: TPressAttributeMetadata): TPressOPFExternalField;
  protected
    function AttributeIterator: TPressAttributeMetadataIterator;
    function BuildFieldList(APrefixType: TPressOPFPrefixType; AHelperFields: TPressOPFHelperFields): string;
    function BuildLinkList(const APrefix: string; AMetadata: TPressAttributeMetadata): string;
    function BuildTableList: string;
    function CreateAssignParamToFieldList(AObject: TPressObject; out AConcurrency: Boolean): string;
    function CreateIdParamList(ACount: Integer): string;
    property ExternalFields[AAttributeMetadata: TPressAttributeMetadata]: TPressOPFExternalField read GetExternalFields;
    property MainTableAlias: string read FMainTableAlias;
    property Map: TPressOPFStorageMap read FMap;
  public
    constructor Create(AMap: TPressOPFStorageMap);
    destructor Destroy; override;
    function DeleteLinkItemsStatement(AItems: TPressItems): string; virtual;
    function DeleteLinkStatement(AMetadata: TPressAttributeMetadata): string; virtual;
    function DeleteStatement: string; virtual;
    function InsertLinkStatement(AMetadata: TPressAttributeMetadata): string; virtual;
    function InsertStatement: string; virtual;
    function SelectLinkStatement(AMetadata: TPressAttributeMetadata): string; virtual;
    function SelectStatement: string; virtual;
    function UpdateStatement(AObject: TPressObject): string; virtual;
  end;

  TPressOPFStorageMap = class(TPressAttributeMetadataList)
  private
    FMetadata: TPressObjectMetadata;
  public
    constructor Create(AMetadata: TPressObjectMetadata);
    property Metadata: TPressObjectMetadata read FMetadata;
  end;

  TPressOPFStorageMapIterator = class;

  TPressOPFStorageMapList = class(TPressList)
  private
    FMetadata: TPressObjectMetadata;
    FObjectClass: TPressObjectClass;
    procedure BuildStorageMaps;
    function GetItems(AIndex: Integer): TPressOPFStorageMap;
    procedure SetItems(AIndex: Integer; const Value: TPressOPFStorageMap);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    constructor Create(AObjectClass: TPressObjectClass);
    function Add(AObject: TPressOPFStorageMap): Integer;
    function CreateIterator: TPressOPFStorageMapIterator;
    function Extract(AObject: TPressOPFStorageMap): TPressOPFStorageMap;
    function First: TPressOPFStorageMap;
    function IndexOf(AObject: TPressOPFStorageMap): Integer;
    procedure Insert(AIndex: Integer; AObject: TPressOPFStorageMap);
    function Last: TPressOPFStorageMap;
    function Remove(AObject: TPressOPFStorageMap): Integer;
    property Items[AIndex: Integer]: TPressOPFStorageMap read GetItems write SetItems; default;
    property Metadata: TPressObjectMetadata read FMetadata;
    property ObjectClass: TPressObjectClass read FObjectClass;
  end;

  TPressOPFStorageMapIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressOPFStorageMap;
  public
    property CurrentItem: TPressOPFStorageMap read GetCurrentItem;
  end;

  TPressOPFMetadata = class(TObject)
  private
    FName: string;
  public
    constructor Create(const AName: string);
    property Name: string read FName;
  end;

  TPressOPFFieldOption = (foNotNull, foIndexed);
  TPressOPFFieldOptions = set of TPressOPFFieldOption;

  TPressOPFFieldMetadata = class(TPressOPFMetadata)
  private
    FDataType: TPressAttributeBaseType;
    FOptions: TPressOPFFieldOptions;
    FSize: Integer;
  public
    property DataType: TPressAttributeBaseType read FDataType write FDataType;
    property Options: TPressOPFFieldOptions read FOptions write FOptions;
    property Size: Integer read FSize write FSize;
  end;

  TPressOPFIndexOption = (ioUnique, ioDescending);
  TPressOPFIndexOptions = set of TPressOPFIndexOption;

  TPressOPFIndexMetadata = class(TPressOPFMetadata)
  private
    FFieldNames: TStrings;
    FOptions: TPressOPFIndexOptions;
  public
    constructor Create(const AName: string);
    destructor Destroy; override;
    property FieldNames: TStrings read FFieldNames;
    property Options: TPressOPFIndexOptions read FOptions write FOptions;
  end;

  TPressOPFReferentialAction = (raNoAction, raCascade, raSetNull, raSetDefault);

  TPressOPFForeignKeyMetadata = class(TPressOPFMetadata)
  private
    FKeyFieldNames: TStrings;
    FOnDeleteAction: TPressOPFReferentialAction;
    FOnUpdateAction: TPressOPFReferentialAction;
    FReferencedFieldNames: TStrings;
    FReferencedTableName: string;
  public
    constructor Create(const AName: string);
    destructor Destroy; override;
    property KeyFieldNames: TStrings read FKeyFieldNames;
    property OnUpdateAction: TPressOPFReferentialAction read FOnUpdateAction write FOnUpdateAction;
    property OnDeleteAction: TPressOPFReferentialAction read FOnDeleteAction write FOnDeleteAction;
    property ReferencedFieldNames: TStrings read FReferencedFieldNames;
    property ReferencedTableName: string read FReferencedTableName write FReferencedTableName;
  end;

  TPressOPFTableMetadata = class(TPressOPFMetadata)
  private
    FFields: TObjectList;
    FForeignKeys: TObjectList;
    FIndexes: TObjectList;
    FPrimaryKey: TPressOPFIndexMetadata;
    procedure EnsureListInstance(var AList: TObjectList);
    function GetFields(AIndex: Integer): TPressOPFFieldMetadata;
    function GetForeignKeys(AIndex: Integer): TPressOPFForeignKeyMetadata;
    function GetIndexes(AIndex: Integer): TPressOPFIndexMetadata;
    procedure SetPrimaryKey(AValue: TPressOPFIndexMetadata);
  public
    destructor Destroy; override;
    function AddField(const AName: string): TPressOPFFieldMetadata;
    function AddForeignKey(const AName: string): TPressOPFForeignKeyMetadata;
    function AddIndex(const AName: string): TPressOPFIndexMetadata;
    function FieldCount: Integer;
    function ForeignKeyCount: Integer;
    function IndexCount: Integer;
    property Fields[AIndex: Integer]: TPressOPFFieldMetadata read GetFields;
    property ForeignKeys[AIndex: Integer]: TPressOPFForeignKeyMetadata read GetForeignKeys;
    property Indexes[AIndex: Integer]: TPressOPFIndexMetadata read GetIndexes;
    property PrimaryKey: TPressOPFIndexMetadata read FPrimaryKey write SetPrimaryKey;
  end;

  TPressOPFStorageModel = class(TObject)
  private
    FClassIdList: TStrings;
    FClassIdMetadata: TPressObjectMetadata;
    FClassNameList: TStrings;
    FHasClassIdStorage: Boolean;
    FMapsList: TObjectList;
    FModel: TPressModel;
    FTableMetadatas: TObjectList;
    procedure BuildClassLists;
    function GetClassIdMetadata: TPressObjectMetadata;
    function CreateTableMetadatas: TObjectList;
    function GetMaps(AClass: TPressObjectClass): TPressOPFStorageMapList;
    function GetTableMetadatas(AIndex: Integer): TPressOPFTableMetadata;
  protected
    property ClassIdMetadata: TPressObjectMetadata read GetClassIdMetadata;
  public
    constructor Create(AModel: TPressModel);
    destructor Destroy; override;
    function ClassById(const AClassId: string): TPressObjectClass;
    function ClassIdByName(const AClassName: string): string;
    function ClassNameById(const AClassId: string): string;
    function TableMetadataCount: Integer;
    property HasClassIdStorage: Boolean read FHasClassIdStorage;
    property Maps[AClass: TPressObjectClass]: TPressOPFStorageMapList read GetMaps;
    property Model: TPressModel read FModel;
    property TableMetadatas[AIndex: Integer]: TPressOPFTableMetadata read GetTableMetadatas;
  end;

function PressStorageModel: TPressOPFStorageModel;

implementation

uses
  {$IFDEF D6+}Variants,{$ENDIF}
  SysUtils,
  TypInfo,
  {$IFDEF PressLog}PressLog,{$ENDIF}
  PressConsts;

type
  TPressInstanceClass = class(TPressObject)
  private
    FObjectClassName: TPressString;
    function GetObjectClassName: string;
    procedure SetObjectClassName(AValue: string);
  protected
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    class function InternalMetadataStr: string; override;
  published
    property ObjectClassName: string read GetObjectClassName write SetObjectClassName;
  end;

var
  _PressStorageModel: TPressOPFStorageModel;

{ Global routines }

function PressStorageModel: TPressOPFStorageModel;
begin
  if not Assigned(_PressStorageModel) then
    _PressStorageModel := TPressOPFStorageModel.Create(PressModel);
  Result := _PressStorageModel;
end;

{ TPressOPFObjectMapper }

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

function TPressOPFObjectMapper.CreateDatabaseStatement: string;
begin
  Result := DDLBuilder.CreateDatabaseStatement(StorageModel);
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
  VRootMapIndex, I: Integer;
begin
  { TODO : Improve, building one inner join with all maps }
  VMaps := StorageModel.Maps[AClass];
  if VMaps.Count > 0 then
  begin
    VRootMapIndex := Pred(VMaps.Count);
    Result := AttributeMapper[VMaps[VRootMapIndex]].RetrieveRootMap(
     AClass, AId, AMetadata);
    if Assigned(Result) then
    begin
      try
        Result.DisableChanges;
        for I := Pred(VRootMapIndex) downto 0 do
          AttributeMapper[VMaps[I]].Retrieve(Result, AId);
        PressAssignPersistentId(Result, AId);
        Result.EnableChanges;
      except
        FreeAndNil(Result);
        raise;
      end;
    end;
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
        if not AValue.IsNull then
          VParam.AsInt16 := AValue.AsInteger
        else
          VParam.AsVariant := Null;
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
      AddNullParam(ADataset, AReference.PersistentName);
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
  ADataset: TPressOPFDataset; const AParamName: string);
begin
  if AParamName <> '' then
    ADataset.Params.ParamByName(AParamName).Clear;
end;

procedure TPressOPFAttributeMapper.AddPersistentIdParam(
  ADataset: TPressOPFDataset; const APersistentId: string);
begin
  AddStringParam(ADataset, SPressPersistentIdParamString, APersistentId);
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
  FDMLBuilder := FObjectMapper.DMLBuilderClass.Create(AMap);
  FMap := AMap;
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
  FSelectDataset.Free;
  FUpdateDataset.Free;
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
        Persistence.Dispose(VProxy.ObjectClassType, VProxy.ObjectId);
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
            Persistence.Dispose(
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

function TPressOPFAttributeMapper.Retrieve(
  AObject: TPressObject; const AId: string): Boolean;
var
  VDataset: TPressOPFDataset;
begin
  VDataset := SelectDataset;
  AddPersistentIdParam(VDataset, AId);
  VDataset.Execute;
  Result := VDataset.Count = 1;
  if Result then
    RetrieveAttributes(AObject, VDataset[0]);
end;

procedure TPressOPFAttributeMapper.RetrieveAttributes(
  AObject: TPressObject; ADataRow: TPressOPFDataRow);
var
  VDataset: TPressOPFDataset;

  procedure LoadValue(AValue: TPressValue);
  begin
    AValue.AsVariant := ADataRow.FieldByName(AValue.PersistentName).Value;
  end;

  procedure LoadItem(AItem: TPressItem);
  begin
    AItem.AssignReference(ObjectMapper.StorageModel.ClassNameById(
     ADataRow.FieldByName(DMLBuilder.ExternalFields[AItem.Metadata].FieldAlias).AsString),
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
      AItems.AddReference(ObjectMapper.StorageModel.ClassNameById(
       VDataset[I][1].Value), VDataset[I][0].Value, Persistence);
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

function TPressOPFAttributeMapper.RetrieveRootMap(AClass: TPressObjectClass;
  const AId: string; AMetadata: TPressObjectMetadata): TPressObject;
var
  VClass: TPressObjectClass;
  VDataset: TPressOPFDataset;
begin
  VDataset := SelectDataset;
  AddPersistentIdParam(VDataset, AId);
  VDataset.Execute;
  if VDataset.Count = 1 then
  begin
    if Map.Metadata.ClassIdName <> '' then
      VClass := ObjectMapper.StorageModel.ClassById(
       VDataset[0].FieldByName(Map.Metadata.ClassIdName).Value)
    else
      VClass := AClass;
    if not VClass.InheritsFrom(AClass) then
      { TODO : Implement }
      ;
    Result := VClass.Create(Persistence, AMetadata);
    try
      Result.DisableChanges;
      Result.Id := AId;
      if Result.Metadata.UpdateCountName <> '' then
        PressAssignUpdateCount(Result,
         VDataset[0].FieldByName(Result.Metadata.UpdateCountName).Value);
      RetrieveAttributes(Result, VDataset[0]);
      Result.EnableChanges;
    except
      FreeAndNil(Result);
      raise;
    end;
  end else
    Result := nil;
end;

function TPressOPFAttributeMapper.SelectDataset: TPressOPFDataset;
begin
  if not Assigned(FSelectDataset) then
  begin
    FSelectDataset := Connector.CreateDataset;
    FSelectDataset.SQL := DMLBuilder.SelectStatement;
  end;
  Result := FSelectDataset;
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
      if not NeedRebuild then
      begin
        if not Assigned(VDataset) and ((AItems.RemovedProxies.Count > 0) or
         (AItems.AddedProxies.Count > 0)) then
          VDataset := Connector.CreateDataset;
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
        if not Assigned(VDataset) then
          VDataset := Connector.CreateDataset;
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
      I: Integer;
    begin
      for I := 0 to Pred(AParts.Count) do
      begin
        VProxy := AParts.Proxies[I];
        if VProxy.HasInstance and VProxy.Instance.IsChanged then
          ObjectMapper.Store(VProxy.Instance);
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
          VObject := VProxy.Instance
        else
          VObject := nil;
        if Assigned(VObject) and not VObject.IsPersistent then
          Persistence.Store(VObject);
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

{ TPressOPFSQLBuilder }

procedure TPressOPFSQLBuilder.ConcatStatements(
  const AStatementStr, AConnectorToken: string; var ABuffer: string);
begin
  { TODO : Merge with TPressQuery.ConcatStatements }
  if ABuffer = '' then
    ABuffer := AStatementStr
  else if AStatementStr <> '' then
    ABuffer := ABuffer + AConnectorToken + AStatementStr;
end;

{ TPressOPFDDLBuilder }

function TPressOPFDDLBuilder.AttributeTypeToFieldType(
  AAttributeBaseType: TPressAttributeBaseType): TPressOPFFieldType;
const
  CFieldType: array[TPressAttributeBaseType] of TPressOPFFieldType = (
   oftUnknown,    // attUnknown
   oftString,     // attString
   oftInt32,      // attInteger
   oftFloat,      // attFloat
   oftCurrency,   // attCurrency
   oftInt16,      // attEnum
   oftBoolean,    // attBoolean
   oftDate,       // attDate
   oftTime,       // attTime
   oftDateTime,   // attDateTime
   oftUnknown,    // attVariant
   oftMemo,       // attMemo
   oftBinary,     // attBinary
   oftBinary,     // attPicture
   oftUnknown,    // attPart
   oftUnknown,    // attReference
   oftUnknown,    // attParts
   oftUnknown);   // attReferences
begin
  Result := CFieldType[AAttributeBaseType];
  if Result = oftUnknown then
    raise EPressOPFError.CreateFmt(SUnsupportedAttributeType, [
     GetEnumName(TypeInfo(TPressAttributeBaseType), Ord(AAttributeBaseType))]);
end;

function TPressOPFDDLBuilder.BuildFieldType(
  AFieldMetadata: TPressOPFFieldMetadata): string;
begin
  Result :=
   InternalFieldTypeStr(AttributeTypeToFieldType(AFieldMetadata.DataType));
  if AFieldMetadata.DataType = attString then
    Result := Result + Format('(%d)', [AFieldMetadata.Size]);
end;

function TPressOPFDDLBuilder.BuildStringList(AList: TStrings): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Pred(AList.Count) do
    ConcatStatements(AList[I], ', ', Result);
end;

function TPressOPFDDLBuilder.CreateDatabaseStatement(
  AModel: TPressOPFStorageModel): string;
var
  VTable: TPressOPFTableMetadata;
  I, J: Integer;
begin
  Result := '';
  for I := 0 to Pred(AModel.TableMetadataCount) do
  begin
    VTable := AModel.TableMetadatas[I];
    Result := Result +
     CreateTableStatement(VTable) +
     CreatePrimaryKeyStatement(VTable);
    for J := 0 to Pred(VTable.IndexCount) do
      Result := Result + CreateIndexStatement(VTable, VTable.Indexes[J]);
  end;
  for I := 0 to Pred(AModel.TableMetadataCount) do
  begin
    VTable := AModel.TableMetadatas[I];
    for J := 0 to Pred(VTable.ForeignKeyCount) do
      Result := Result +
       CreateForeignKeyStatement(VTable, VTable.ForeignKeys[J]);
  end;
end;

function TPressOPFDDLBuilder.CreateFieldStatement(
  AFieldMetadata: TPressOPFFieldMetadata): string;
begin
  Result := Format('%s %s', [
   AFieldMetadata.Name,
   BuildFieldType(AFieldMetadata)]);
  if foNotNull in AFieldMetadata.Options then
    Result := Result + ' not null';
end;

function TPressOPFDDLBuilder.CreateFieldStatementList(
  ATableMetadata: TPressOPFTableMetadata): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Pred(ATableMetadata.FieldCount) do
    ConcatStatements(
     CreateFieldStatement(ATableMetadata.Fields[I]), ','#10'  ', Result);
end;

function TPressOPFDDLBuilder.CreateForeignKeyStatement(
  ATableMetadata: TPressOPFTableMetadata;
  AForeignKeyMetadata: TPressOPFForeignKeyMetadata): string;
const
  CReferentialAction: array[TPressOPFReferentialAction] of string = (
   'no action', 'cascade', 'set null', 'set default');
begin
  Result := Format(
   'alter table %s add constraint %s'#10 +
   '  foreign key (%s)'#10 +
   '  references %s (%s)'#10 +
   '  on delete %s'#10 +
   '  on update %s;'#10#10, [
   ATableMetadata.Name,
   AForeignKeyMetadata.Name,
   BuildStringList(AForeignKeyMetadata.KeyFieldNames),
   AForeignKeyMetadata.ReferencedTableName,
   BuildStringList(AForeignKeyMetadata.ReferencedFieldNames),
   CReferentialAction[AForeignKeyMetadata.OnDeleteAction],
   CReferentialAction[AForeignKeyMetadata.OnUpdateAction]]);
end;

function TPressOPFDDLBuilder.CreateIndexStatement(
  ATableMetadata: TPressOPFTableMetadata; AIndexMetadata: TPressOPFIndexMetadata): string;
const
  CUnique: array[Boolean] of string = ('', 'unique ');
  CDescending: array[Boolean] of string = ('', 'descending ');
begin
  Result := Format('create %s%sindex %s'#10'  on %s (%s);'#10#10, [
   CUnique[ioUnique in AIndexMetadata.Options],
   CDescending[ioDescending in AIndexMetadata.Options],
   AIndexMetadata.Name,
   ATableMetadata.Name,
   BuildStringList(AIndexMetadata.FieldNames)]);
end;

function TPressOPFDDLBuilder.CreatePrimaryKeyStatement(
  ATableMetadata: TPressOPFTableMetadata): string;
begin
  if Assigned(ATableMetadata.PrimaryKey) then
    Result := Format(
     'alter table %s add constraint %s'#10 +
     '  primary key (%s);'#10#10, [
     ATableMetadata.Name,
     ATableMetadata.PrimaryKey.Name,
     BuildStringList(ATableMetadata.PrimaryKey.FieldNames)])
  else
    Result := '';
end;

function TPressOPFDDLBuilder.CreateTableStatement(
  ATableMetadata: TPressOPFTableMetadata): string;
begin
  Result := Format('create table %s ('#10'  %s);'#10#10, [
   ATableMetadata.Name,
   CreateFieldStatementList(ATableMetadata)]);
end;

function TPressOPFDDLBuilder.InternalFieldTypeStr(
  AFieldType: TPressOPFFieldType): string;
begin
  raise EPressOPFError.CreateFmt(SUnsupportedFeature, ['field type str']);
end;

{ TPressOPFExternalField }

constructor TPressOPFExternalField.Create(
  AAttributeMetadata: TPressAttributeMetadata; AId: Integer);
begin
  inherited Create;
  FAttributeMetadata := AAttributeMetadata;
  FObjectMetadata := AAttributeMetadata.ObjectClass.ClassMetadata;
  FId := AId;
end;

function TPressOPFExternalField.GetAsSQLField: string;
begin
  Result := Format('%s.%s as %s', [
   TableAlias,
   FieldName,
   FieldAlias]);
end;

function TPressOPFExternalField.GetFieldAlias: string;
begin
  Result := TableName + SPressIdentifierSeparator + FieldName;
end;

function TPressOPFExternalField.GetFieldName: string;
begin
  Result := ObjectMetadata.ClassIdName;
end;

function TPressOPFExternalField.GetTableAlias: string;
begin
  Result := SPressTableAliasPrefix + InttoStr(FId);
end;

function TPressOPFExternalField.GetTableName: string;
begin
  Result := ObjectMetadata.PersistentName;
end;

{ TPressOPFDMLBuilder }

function TPressOPFDMLBuilder.AttributeIterator: TPressAttributeMetadataIterator;
begin
  if not Assigned(FAttributeIterator) then
    FAttributeIterator := Map.CreateIterator;
  Result := FAttributeIterator;
end;

function TPressOPFDMLBuilder.BuildFieldList(APrefixType: TPressOPFPrefixType;
  AHelperFields: TPressOPFHelperFields): string;

  procedure AddStatement(const AStatement: string);
  const
    CPrefix: array[TPressOPFPrefixType] of string = (
     '', ':', SPressTableAliasPrefix + '0.');
  begin
    if AStatement <> '' then
      ConcatStatements(CPrefix[APrefixType] + AStatement, ', ', Result);
  end;

  procedure AddExternalClassField(AAttribute: TPressAttributeMetadata);
  begin
    ConcatStatements(ExternalFields[AAttribute].AsSQLField, ', ', Result);
  end;

var
  VAttribute: TPressAttributeMetadata;
begin
  Result := '';
  with AttributeIterator do
  begin
    FirstItem;  // skips ID
    if hfOID in AHelperFields then
      AddStatement(CurrentItem.PersistentName);
    if hfClassId in AHelperFields then
      AddStatement(Map.Metadata.ClassIdName);
    if hfUpdateCount in AHelperFields then
      AddStatement(Map.Metadata.UpdateCountName);
    while NextItem do
    begin
      VAttribute := CurrentItem;
      if not VAttribute.AttributeClass.InheritsFrom(TPressItems) then
      begin
        AddStatement(VAttribute.PersistentName);
        if (APrefixType = ptTableAlias) and
         VAttribute.AttributeClass.InheritsFrom(TPressItem) then
          AddExternalClassField(VAttribute);
      end;
    end;
  end;
end;

function TPressOPFDMLBuilder.BuildLinkList(
  const APrefix: string; AMetadata: TPressAttributeMetadata): string;

  procedure AddStatement(const AStatement: string);
  begin
    if AStatement <> '' then
      ConcatStatements(APrefix + AStatement, ', ', Result);
  end;

begin
  Result := '';
  AddStatement(AMetadata.PersLinkIdName);
  AddStatement(AMetadata.PersLinkParentName);
  AddStatement(AMetadata.PersLinkChildName);
  AddStatement(AMetadata.PersLinkPosName);
end;

function TPressOPFDMLBuilder.BuildTableList: string;

  procedure AddExternalTable(AExternalField: TPressOPFExternalField);
  begin
    Result := Format('%s left outer join %s %s on %s.%s = %2:s.%5:s', [
     Result,
     AExternalField.TableName,
     AExternalField.TableAlias,
     MainTableAlias,
     AExternalField.AttributeMetadata.PersistentName,
     AExternalField.ObjectMetadata.IdMetadata.PersistentName]);
  end;

var
  I: Integer;
begin
  Result := Map.Metadata.PersistentName + ' ' + MainTableAlias;
  if Assigned(FExternalFields) then
    for I := 0 to Pred(FExternalFields.Count) do
      AddExternalTable(FExternalFields[I] as TPressOPFExternalField);
end;

constructor TPressOPFDMLBuilder.Create(AMap: TPressOPFStorageMap);
begin
  inherited Create;
  FMap := AMap;
  FMainTableAlias := SPressTableAliasPrefix + '0';
end;

function TPressOPFDMLBuilder.CreateAssignParamToFieldList(
  AObject: TPressObject; out AConcurrency: Boolean): string;

  procedure AddRelativeChange(AAttribute: TPressNumeric);
  begin
    { TODO : Relative changes might break obj x db synchronization }
    ConcatStatements(Format('%s = %0:s + :%0:s', [
     AAttribute.PersistentName]), ', ', Result);
  end;

  procedure AddParam(const AParamName: string);
  begin
    ConcatStatements(Format('%s = :%0:s', [AParamName]), ', ', Result);
  end;

var
  VAttribute: TPressAttribute;
begin
  AConcurrency := False;
  Result := '';
  with AttributeIterator do
  begin
    BeforeFirstItem;
    while NextItem do
    begin
      VAttribute := AObject.AttributeByName(CurrentItem.Name);
      if not (VAttribute is TPressItems) then
      begin
        if VAttribute.IsChanged and (VAttribute.PersistentName <> '') then
        begin
          if (VAttribute is TPressNumeric) and
           TPressNumeric(VAttribute).IsRelativelyChanged then
            AddRelativeChange(TPressNumeric(VAttribute))
          else
          begin
            AddParam(VAttribute.PersistentName);
            AConcurrency := True;
          end;
        end;
      end else if VAttribute.IsChanged and
       (VAttribute.PersistentName <> '') then
        AConcurrency := True;
    end;
    if AConcurrency or (Result <> '') or (Map.Metadata = AObject.Metadata) then
      AddParam(Map.Metadata.UpdateCountName);
  end;
end;

function TPressOPFDMLBuilder.CreateIdParamList(ACount: Integer): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Pred(ACount) do
    ConcatStatements(':' + SPressIdString + InttoStr(I), ', ', Result);
end;

function TPressOPFDMLBuilder.DeleteLinkItemsStatement(
  AItems: TPressItems): string;
begin
  Result := Format('delete from %s where %s in (%s)', [
   AItems.Metadata.PersLinkName,
   AItems.Metadata.PersLinkChildName,
   CreateIdParamList(AItems.RemovedProxies.Count)]);
end;

function TPressOPFDMLBuilder.DeleteLinkStatement(
  AMetadata: TPressAttributeMetadata): string;
begin
  Result := Format('delete from %s where %s = %s', [
   AMetadata.PersLinkName,
   AMetadata.PersLinkParentName,
   ':' + SPressPersistentIdParamString]);
end;

function TPressOPFDMLBuilder.DeleteStatement: string;
begin
  Result := Format('delete from %s where %s = %s', [
   Map.Metadata.PersistentName,
   Map.Metadata.KeyName,
   ':' + SPressPersistentIdParamString]);
end;

destructor TPressOPFDMLBuilder.Destroy;
begin
  FAttributeIterator.Free;
  FExternalFields.Free;
  inherited;
end;

function TPressOPFDMLBuilder.GetExternalFields(
  AAttributeMetadata: TPressAttributeMetadata): TPressOPFExternalField;
var
  I: Integer;
begin
  if not Assigned(FExternalFields) then
    FExternalFields := TObjectList.Create(True);
  for I := 0 to Pred(FExternalFields.Count) do
  begin
    Result := FExternalFields[I] as TPressOPFExternalField;
    if Result.AttributeMetadata = AAttributeMetadata then
      Exit;
  end;
  Result := TPressOPFExternalField.Create(
   AAttributeMetadata, Succ(FExternalFields.Count));
  FExternalFields.Add(Result);
end;

function TPressOPFDMLBuilder.InsertLinkStatement(
  AMetadata: TPressAttributeMetadata): string;
begin
  Result := Format('insert into %s (%s) values (%s)', [
   AMetadata.PersLinkName,
   BuildLinkList('', AMetadata),
   BuildLinkList(':', AMetadata)]);
end;

function TPressOPFDMLBuilder.InsertStatement: string;
begin
  Result := Format('insert into %s (%s) values (%s)', [
   Map.Metadata.PersistentName,
   BuildFieldList(ptNone, [hfOID, hfClassId, hfUpdateCount]),
   BuildFieldList(ptColon, [hfOID, hfClassId, hfUpdateCount])]);
end;

function TPressOPFDMLBuilder.SelectLinkStatement(
  AMetadata: TPressAttributeMetadata): string;
var
  VObjectMetadata: TPressObjectMetadata;
begin
  VObjectMetadata := AMetadata.ObjectClass.ClassMetadata;
  Result := Format(
   'select %0:s.%2:s, %1:s.%3:s from %4:s %0:s ' +
   'inner join %5:s %1:s on %0:s.%2:s = %1:s.%6:s ' +
   'where %0:s.%7:s = %8:s', [
   SPressTableAliasPrefix + '0',
   SPressTableAliasPrefix + '1',
   AMetadata.PersLinkChildName,
   VObjectMetadata.ClassIdName,
   AMetadata.PersLinkName,
   VObjectMetadata.PersistentName,
   VObjectMetadata.IdMetadata.PersistentName,
   AMetadata.PersLinkParentName,
   ':' + SPressPersistentIdParamString]);
  if AMetadata.PersLinkPosName <> '' then
    Result := Result + ' order by ' + AMetadata.PersLinkPosName;
end;

function TPressOPFDMLBuilder.SelectStatement: string;
begin
  Result := Format('select %s from %s where %s.%s = %s', [
   BuildFieldList(ptTableAlias, [hfClassId, hfUpdateCount]),
   BuildTableList,
   MainTableAlias,
   Map.Metadata.KeyName,
   ':' + SPressPersistentIdParamString]);
end;

function TPressOPFDMLBuilder.UpdateStatement(
  AObject: TPressObject): string;
var
  VAssignParamList: string;
  VConcurrency: Boolean;
begin
  VAssignParamList := CreateAssignParamToFieldList(AObject, VConcurrency);
  if VAssignParamList <> '' then
  begin
    Result := Format('update %s set %s where (%s = %s)', [
     Map.Metadata.PersistentName,
     VAssignParamList,
     Map.Metadata.KeyName,
     ':' + SPressPersistentIdParamString]);
    if VConcurrency and (Map.Metadata.UpdateCountName <> '') then
      Result := Format('%s and (%s = %d)', [
       Result,
       Map.Metadata.UpdateCountName,
       AObject.PersUpdateCount]);
  end else
    Result := '';
end;

{ TPressOPFStorageMap }

constructor TPressOPFStorageMap.Create(AMetadata: TPressObjectMetadata);
begin
  inherited Create(False);
  FMetadata := AMetadata;
end;

{ TPressOPFStorageMapList }

function TPressOPFStorageMapList.Add(
  AObject: TPressOPFStorageMap): Integer;
begin
  Result := inherited Add(AObject);
end;

procedure TPressOPFStorageMapList.BuildStorageMaps;

  procedure BuildMaps(AClass: TPressObjectClass);
  var
    VStorageMap: TPressOPFStorageMap;
    VMetadatas: TPressAttributeMetadataList;
    VObjectMetadata: TPressObjectMetadata;
    I: Integer;
  begin
    { TODO : persistent base-classes' map are being duplicated
      inside its sub-classes' map list; a very small overhead though }
    if AClass <> TPressObject then
    begin
      VObjectMetadata := AClass.ClassMetadata;
      if VObjectMetadata.Parent.IsPersistent then
      begin
        BuildMaps(TPressObjectClass(AClass.ClassParent));
        VMetadatas := VObjectMetadata.AttributeMetadatas;
      end else
        VMetadatas := VObjectMetadata.Map;
      VStorageMap := TPressOPFStorageMap.Create(VObjectMetadata);
      Add(VStorageMap);
      VStorageMap.Add(VObjectMetadata.IdMetadata);
      for I := 0 to Pred(VMetadatas.Count) do
        if VMetadatas[I].IsPersistent then
          VStorageMap.Add(VMetadatas[I]);
    end;
  end;

begin
  Clear;
  BuildMaps(FObjectClass);
end;

constructor TPressOPFStorageMapList.Create(
  AObjectClass: TPressObjectClass);
var
  VMetadata: TPressObjectMetadata;
begin
  VMetadata := AObjectClass.ClassMetadata;
  if not VMetadata.IsPersistent then
    raise EPressOPFError.CreateFmt(SClassIsNotPersistent, [
     AObjectClass.ClassName]);
  inherited Create(True);
  FObjectClass := AObjectClass;
  FMetadata := VMetadata;
  BuildStorageMaps;
end;

function TPressOPFStorageMapList.CreateIterator: TPressOPFStorageMapIterator;
begin
  Result := TPressOPFStorageMapIterator.Create(Self);
end;

function TPressOPFStorageMapList.Extract(
  AObject: TPressOPFStorageMap): TPressOPFStorageMap;
begin
  Result := inherited Extract(AObject) as TPressOPFStorageMap;
end;

function TPressOPFStorageMapList.First: TPressOPFStorageMap;
begin
  Result := inherited First as TPressOPFStorageMap;
end;

function TPressOPFStorageMapList.GetItems(
  AIndex: Integer): TPressOPFStorageMap;
begin
  Result := inherited Items[AIndex] as TPressOPFStorageMap;
end;

function TPressOPFStorageMapList.IndexOf(
  AObject: TPressOPFStorageMap): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressOPFStorageMapList.Insert(AIndex: Integer;
  AObject: TPressOPFStorageMap);
begin
  inherited Insert(AIndex, AObject);
end;

function TPressOPFStorageMapList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressOPFStorageMapList.Last: TPressOPFStorageMap;
begin
  Result := inherited Last as TPressOPFStorageMap;
end;

function TPressOPFStorageMapList.Remove(
  AObject: TPressOPFStorageMap): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressOPFStorageMapList.SetItems(AIndex: Integer;
  const Value: TPressOPFStorageMap);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressOPFStorageMapIterator }

function TPressOPFStorageMapIterator.GetCurrentItem: TPressOPFStorageMap;
begin
  Result := inherited CurrentItem as TPressOPFStorageMap;
end;

{ TPressInstanceClass }

function TPressInstanceClass.GetObjectClassName: string;
begin
  Result := FObjectClassName.Value;
end;

function TPressInstanceClass.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'ObjectClassName') then
    Result := Addr(FObjectClassName)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressInstanceClass.InternalMetadataStr: string;
begin
  Result := Format(
   'TPressInstanceClass ' +
   'KeyType=%s PersistentName="%s" ClassIdName="" UpdateCountName="" (' +
   'ObjectClassName: String(32))', [
   PressModel.ClassIdType.AttributeName,
   PressModel.ClassIdStorageName]);
end;

procedure TPressInstanceClass.SetObjectClassName(AValue: string);
begin
  FObjectClassName.Value := AValue;
end;

{ TPressOPFMetadata }

constructor TPressOPFMetadata.Create(const AName: string);
begin
  inherited Create;
  FName := AName;
end;

{ TPressOPFIndexMetadata }

constructor TPressOPFIndexMetadata.Create(const AName: string);
begin
  inherited Create(AName);
  FFieldNames := TStringList.Create;
end;

destructor TPressOPFIndexMetadata.Destroy;
begin
  FFieldNames.Free;
  inherited;
end;

{ TPressOPFForeignKeyMetadata }

constructor TPressOPFForeignKeyMetadata.Create(const AName: string);
begin
  inherited Create(AName);
  FKeyFieldNames := TStringList.Create;
  FReferencedFieldNames := TStringList.Create;
  FOnUpdateAction := raNoAction;
  FOnDeleteAction := raNoAction;
end;

destructor TPressOPFForeignKeyMetadata.Destroy;
begin
  FKeyFieldNames.Free;
  FReferencedFieldNames.Free;
  inherited;
end;

{ TPressOPFTableMetadata }

function TPressOPFTableMetadata.AddField(
  const AName: string): TPressOPFFieldMetadata;
begin
  EnsureListInstance(FFields);
  Result := TPressOPFFieldMetadata.Create(AName);
  FFields.Add(Result);
end;

function TPressOPFTableMetadata.AddForeignKey(
  const AName: string): TPressOPFForeignKeyMetadata;
begin
  EnsureListInstance(FForeignKeys);
  Result := TPressOPFForeignKeyMetadata.Create(AName);
  FForeignKeys.Add(Result);
end;

function TPressOPFTableMetadata.AddIndex(
  const AName: string): TPressOPFIndexMetadata;
begin
  EnsureListInstance(FIndexes);
  Result := TPressOPFIndexMetadata.Create(AName);
  FIndexes.Add(Result);
end;

destructor TPressOPFTableMetadata.Destroy;
begin
  FFields.Free;
  FForeignKeys.Free;
  FIndexes.Free;
  FPrimaryKey.Free;
  inherited;
end;

procedure TPressOPFTableMetadata.EnsureListInstance(var AList: TObjectList);
begin
  if not Assigned(AList) then
    AList := TObjectList.Create(True);
end;

function TPressOPFTableMetadata.FieldCount: Integer;
begin
  if Assigned(FFields) then
    Result := FFields.Count
  else
    Result := 0;
end;

function TPressOPFTableMetadata.ForeignKeyCount: Integer;
begin
  if Assigned(FForeignKeys) then
    Result := FForeignKeys.Count
  else
    Result := 0;
end;

function TPressOPFTableMetadata.GetFields(
  AIndex: Integer): TPressOPFFieldMetadata;
begin
  EnsureListInstance(FFields);
  Result := FFields[AIndex] as TPressOPFFieldMetadata;
end;

function TPressOPFTableMetadata.GetForeignKeys(
  AIndex: Integer): TPressOPFForeignKeyMetadata;
begin
  EnsureListInstance(FForeignKeys);
  Result := FForeignKeys[AIndex] as TPressOPFForeignKeyMetadata;
end;

function TPressOPFTableMetadata.GetIndexes(
  AIndex: Integer): TPressOPFIndexMetadata;
begin
  EnsureListInstance(FIndexes);
  Result := FIndexes[AIndex] as TPressOPFIndexMetadata;
end;

function TPressOPFTableMetadata.IndexCount: Integer;
begin
  if Assigned(FIndexes) then
    Result := FIndexes.Count
  else
    Result := 0;
end;

procedure TPressOPFTableMetadata.SetPrimaryKey(AValue: TPressOPFIndexMetadata);
begin
  FPrimaryKey.Free;
  FPrimaryKey := AValue;
end;

{ TPressOPFStorageModel }

procedure TPressOPFStorageModel.BuildClassLists;
var
  VObjects: TPressProxyList;
  VInstance: TPressInstanceClass;
  I: Integer;
begin
  { TODO : Remove coupling with the default DAO }
  if not Assigned(FClassIdList) or not Assigned(FClassNameList) then
  begin
    FreeAndNil(FClassIdList);
    FreeAndNil(FClassNameList);
    FClassIdList := TStringList.Create;
    FClassNameList := TStringList.Create;
    VObjects := PressDefaultDAO.OQLQuery(
     'select * from ' + TPressInstanceClass.ClassName);
    try
      for I := 0 to Pred(VObjects.Count) do
      begin
        VInstance := VObjects[I].Instance as TPressInstanceClass;
        FClassIdList.Add(VInstance.Id);
        FClassNameList.Add(VInstance.ObjectClassName);
      end;
    finally
      VObjects.Free;
    end;
  end;
end;

function TPressOPFStorageModel.ClassById(
  const AClassId: string): TPressObjectClass;
begin
  Result := Model.ClassByName(ClassNameById(AClassId));
end;

function TPressOPFStorageModel.ClassIdByName(const AClassName: string): string;
var
  VInstance: TPressInstanceClass;
  VIndex: Integer;
begin
  { TODO : Remove coupling with the default DAO }
  if HasClassIdStorage and (AClassName <> '') then
  begin
    BuildClassLists;
    VIndex := FClassNameList.IndexOf(AClassName);
    if VIndex >= 0 then
      Result := FClassIdList[VIndex]
    else
    begin
      Model.ClassByName(AClassName);
      VInstance := TPressInstanceClass.Create;
      try
        VInstance.ObjectClassName := AClassName;
        PressDefaultDAO.Store(VInstance);
        Result := VInstance.Id;
        FClassNameList.Add(AClassName);
        FClassIdList.Add(Result);
      finally
        VInstance.Free;
      end;
    end;
  end else
    Result := AClassName;
end;

function TPressOPFStorageModel.ClassNameById(const AClassId: string): string;
var
  VIndex: Integer;
begin
  if HasClassIdStorage and (AClassId <> '') then
  begin
    BuildClassLists;
    VIndex := FClassIdList.IndexOf(AClassId);
    if VIndex >= 0 then
      Result := FClassNameList[VIndex]
    else
      raise EPressOPFError.CreateFmt(SClassNotFound, [AClassId]);
  end else
    Result := AClassId;
end;

constructor TPressOPFStorageModel.Create(AModel: TPressModel);
begin
  inherited Create;
  FModel := AModel;
  FHasClassIdStorage := TPressInstanceClass.ClassMetadata.IsPersistent;
end;

function TPressOPFStorageModel.CreateTableMetadatas: TObjectList;

  procedure AddObjectMetadata(
    AStorageMap: TPressOPFStorageMap; ATableMetadatas: TObjectList);

    procedure AddIndex(ATableMetadata: TPressOPFTableMetadata;
      AFieldMetadata: TPressOPFFieldMetadata;
      AIndexOptions: TPressOPFIndexOptions; AIndexName: string = '');
    var
      VIndex: TPressOPFIndexMetadata;
    begin
      if AIndexName = '' then
        AIndexName := SPressIndexNamePrefix + ATableMetadata.Name +
         SPressIdentifierSeparator + AFieldMetadata.Name;
      VIndex := ATableMetadata.AddIndex(AIndexName);
      VIndex.FieldNames.Text := AFieldMetadata.Name;
      VIndex.Options := AIndexOptions;
    end;

    procedure AddForeignKey(ATable: TPressOPFTableMetadata;
      AField: TPressOPFFieldMetadata; AReferencedObject: TPressObjectMetadata);
    var
      VForeignKey: TPressOPFForeignKeyMetadata;
    begin
      VForeignKey := ATable.AddForeignKey(SPressForeignKeyNamePrefix +
       ATable.Name + SPressIdentifierSeparator + AField.Name);
      VForeignKey.KeyFieldNames.Text := AField.Name;
      VForeignKey.ReferencedFieldNames.Text :=
       AReferencedObject.IdMetadata.PersistentName;
      VForeignKey.ReferencedTableName := AReferencedObject.PersistentName;
      VForeignKey.OnUpdateAction := raCascade;
      VForeignKey.OnDeleteAction := raNoAction;
    end;

    procedure AddAttributeMetadata(AAttributeMetadata: TPressAttributeMetadata;
      ATableMetadata: TPressOPFTableMetadata);

      procedure AddFieldMetadata;
      var
        VField: TPressOPFFieldMetadata;
      begin
        VField := ATableMetadata.AddField(AAttributeMetadata.PersistentName);
        VField.DataType := AAttributeMetadata.AttributeClass.AttributeBaseType;
        VField.Size := AAttributeMetadata.Size;
        VField.Options := [];
        if AStorageMap.Metadata.IdMetadata = AAttributeMetadata then
        begin
          ATableMetadata.PrimaryKey := TPressOPFIndexMetadata.Create(
           SPressPrimaryKeyNamePrefix + ATableMetadata.Name);
          ATableMetadata.PrimaryKey.FieldNames.Text := VField.Name;
          VField.Options := [foNotNull];
        end;
      end;

      procedure AddItemMetadata;
      var
        VField: TPressOPFFieldMetadata;
        VObjectMetadata: TPressObjectMetadata;
      begin
        VField := ATableMetadata.AddField(AAttributeMetadata.PersistentName);
        VObjectMetadata := AAttributeMetadata.ObjectClass.ClassMetadata;
        VField.DataType :=
         VObjectMetadata.IdMetadata.AttributeClass.AttributeBaseType;
        VField.Size := VObjectMetadata.IdMetadata.Size;
        VField.Options := [];
        AddForeignKey(ATableMetadata, VField, VObjectMetadata);
      end;

      procedure AddItemsMetadata;
      var
        VTableMetadata: TPressOPFTableMetadata;
        VField: TPressOPFFieldMetadata;
        VObjectMetadata: TPressObjectMetadata;
        VHasId: Boolean;
      begin
        VTableMetadata :=
         TPressOPFTableMetadata.Create(AAttributeMetadata.PersLinkName);
        ATableMetadatas.Add(VTableMetadata);
        VTableMetadata.PrimaryKey := TPressOPFIndexMetadata.Create(
         SPressPrimaryKeyNamePrefix + VTableMetadata.Name);
        VHasId := AAttributeMetadata.PersLinkIdName <> '';
        if VHasId then
        begin
          VField :=
           VTableMetadata.AddField(AAttributeMetadata.PersLinkIdName);
          { TODO : Implement }
          VField.DataType := Model.DefaultKeyType.AttributeBaseType;
          VField.Size := 32;
          VField.Options := [foNotNull];
          VTableMetadata.PrimaryKey.FieldNames.Text := VField.Name;
        end;

        VField :=
         VTableMetadata.AddField(AAttributeMetadata.PersLinkParentName);
        VObjectMetadata := AAttributeMetadata.Owner;
        VField.DataType :=
         VObjectMetadata.IdMetadata.AttributeClass.AttributeBaseType;
        VField.Size := VObjectMetadata.IdMetadata.Size;
        VField.Options := [foNotNull];
        AddForeignKey(VTableMetadata, VField, VObjectMetadata);
        if not VHasId then
          VTableMetadata.PrimaryKey.FieldNames.Text := VField.Name;

        VField :=
         VTableMetadata.AddField(AAttributeMetadata.PersLinkChildName);
        VObjectMetadata := AAttributeMetadata.ObjectClass.ClassMetadata;
        VField.DataType :=
         VObjectMetadata.IdMetadata.AttributeClass.AttributeBaseType;
        VField.Size := VObjectMetadata.IdMetadata.Size;
        VField.Options := [foNotNull];
        AddForeignKey(VTableMetadata, VField, VObjectMetadata);
        if not VHasId then
          VTableMetadata.PrimaryKey.FieldNames.Add(VField.Name);

        if AAttributeMetadata.PersLinkPosName <> '' then
        begin
          VField :=
           VTableMetadata.AddField(AAttributeMetadata.PersLinkPosName);
          VField.DataType := attInteger;
          VField.Options := [foNotNull];
        end;
      end;

    begin
      if AAttributeMetadata.AttributeClass.InheritsFrom(TPressValue) then
        AddFieldMetadata
      else if AAttributeMetadata.AttributeClass.InheritsFrom(TPressItem) then
        AddItemMetadata
      else if AAttributeMetadata.AttributeClass.InheritsFrom(TPressItems) then
        AddItemsMetadata;
    end;

    function AddFieldMetadata(const AFieldName: string;
      ADataType: TPressAttributeBaseType; ASize: Integer;
      AFieldOptions: TPressOPFFieldOptions;
      AIndexOptions: TPressOPFIndexOptions;
      ATableMetadata: TPressOPFTableMetadata): TPressOPFFieldMetadata;
    var
      VField: TPressOPFFieldMetadata;
    begin
      VField := ATableMetadata.AddField(AFieldName);
      VField.DataType := ADataType;
      VField.Size := ASize;
      VField.Options := AFieldOptions;
      if foIndexed in AFieldOptions then
        AddIndex(ATableMetadata, VField, AIndexOptions);
      Result := VField;
    end;

  var
    VTableMetadata: TPressOPFTableMetadata;
    VFieldMetadata: TPressOPFFieldMetadata;
    VMetadata: TPressObjectMetadata;
    I: Integer;
  begin
    VMetadata := AStorageMap.Metadata;
    VTableMetadata :=
     TPressOPFTableMetadata.Create(VMetadata.PersistentName);
    ATableMetadatas.Add(VTableMetadata);
    AddAttributeMetadata(VMetadata.IdMetadata, VTableMetadata);
    if VMetadata.ClassIdName <> '' then
    begin
      VFieldMetadata := AddFieldMetadata(VMetadata.ClassIdName,
       ClassIdMetadata.IdMetadata.AttributeClass.AttributeBaseType,
       ClassIdMetadata.IdMetadata.Size,
       [foNotNull, foIndexed], [], VTableMetadata);
      if HasClassIdStorage then
        AddForeignKey(VTableMetadata, VFieldMetadata, ClassIdMetadata);
    end;
    if VMetadata.UpdateCountName <> '' then
      AddFieldMetadata(VMetadata.UpdateCountName,
       attInteger, 0, [foNotNull], [], VTableMetadata);
    for I := 1 to Pred(AStorageMap.Count) do  // skips ID
      AddAttributeMetadata(AStorageMap[I], VTableMetadata);
  end;

begin
  Result := TObjectList.Create(True);
  try
    with Model.CreateMetadataIterator do
    try
      BeforeFirstItem;
      while NextItem do
        if CurrentItem.IsPersistent then
          AddObjectMetadata(Maps[CurrentItem.ObjectClass].Last, Result);
    finally
      Free;
    end;
  except
    Result.Free;
    raise;
  end;
end;

destructor TPressOPFStorageModel.Destroy;
begin
  FClassIdList.Free;
  FClassNameList.Free;
  FMapsList.Free;
  FTableMetadatas.Free;
  inherited;
end;

function TPressOPFStorageModel.GetClassIdMetadata: TPressObjectMetadata;
begin
  if not Assigned(FClassIdMetadata) then
    FClassIdMetadata := TPressInstanceClass.ClassMetadata;
  Result := FClassIdMetadata;
end;

function TPressOPFStorageModel.GetMaps(
  AClass: TPressObjectClass): TPressOPFStorageMapList;
var
  I: Integer;
begin
  if not Assigned(FMapsList) then
    FMapsList := TObjectList.Create(True);
  for I := 0 to Pred(FMapsList.Count) do
  begin
    Result := FMapsList[I] as TPressOPFStorageMapList;
    if Result.ObjectClass = AClass then
      Exit;
  end;
  Result := TPressOPFStorageMapList.Create(AClass);
  FMapsList.Add(Result);
end;

function TPressOPFStorageModel.GetTableMetadatas(
  AIndex: Integer): TPressOPFTableMetadata;
begin
  if not Assigned(FTableMetadatas) then
    FTableMetadatas := CreateTableMetadatas;
  Result := FTableMetadatas[AIndex] as TPressOPFTableMetadata
end;

function TPressOPFStorageModel.TableMetadataCount: Integer;
begin
  if not Assigned(FTableMetadatas) then
    FTableMetadatas := CreateTableMetadatas;
  Result := FTableMetadatas.Count;
end;

procedure RegisterClasses;
begin
  TPressInstanceClass.RegisterClass;
end;

initialization
  RegisterClasses;

finalization
  _PressStorageModel.Free;

end.
