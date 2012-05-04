(*
  PressObjects, Persistence Storage Classes
  Copyright (C) 2007-2008 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressOPFStorage;

{$I Press.inc}

interface

uses
  Classes,
  Contnrs,
  PressClasses,
  PressNotifier,
  PressSubject,
  PressSession;

type
  TPressOPFStorageMap = class;
  TPressOPFStorageMapArray = array of TPressOPFStorageMap;

  TPressOPFStorageMap = class(TPressAttributeMetadataList)
  private
    FIdType: TPressAttributeBaseType;
    FMetadata: TPressObjectMetadata;
    FObjectClass: TPressObjectClass;
  public
    constructor Create(AMetadata: TPressObjectMetadata);
    property IdType: TPressAttributeBaseType read FIdType;
    property Metadata: TPressObjectMetadata read FMetadata;
    property ObjectClass: TPressObjectClass read FObjectClass;
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
    FShortName: string;
    FSize: Integer;
  public
    constructor Create(const AName, AShortName: string);
    property DataType: TPressAttributeBaseType read FDataType write FDataType;
    property Options: TPressOPFFieldOptions read FOptions write FOptions;
    property ShortName: string read FShortName;
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
    FShortName: string;
    procedure EnsureListInstance(var AList: TObjectList);
    function GetFields(AIndex: Integer): TPressOPFFieldMetadata;
    function GetForeignKeys(AIndex: Integer): TPressOPFForeignKeyMetadata;
    function GetIndexes(AIndex: Integer): TPressOPFIndexMetadata;
    procedure SetPrimaryKey(AValue: TPressOPFIndexMetadata);
  public
    constructor Create(const AName, AShortName: string);
    destructor Destroy; override;
    function AddField(const AName, AShortName: string): TPressOPFFieldMetadata;
    function AddForeignKey(const AName: string): TPressOPFForeignKeyMetadata;
    function AddIndex(const AName: string): TPressOPFIndexMetadata;
    function FieldCount: Integer;
    function ForeignKeyCount: Integer;
    function IndexCount: Integer;
    property Fields[AIndex: Integer]: TPressOPFFieldMetadata read GetFields;
    property ForeignKeys[AIndex: Integer]: TPressOPFForeignKeyMetadata read GetForeignKeys;
    property Indexes[AIndex: Integer]: TPressOPFIndexMetadata read GetIndexes;
    property PrimaryKey: TPressOPFIndexMetadata read FPrimaryKey write SetPrimaryKey;
    property ShortName: string read FShortName;
  end;

  TPressOPFTableMetadatas = class(TObject)
  private
    FClassIdMetadata: TPressObjectMetadata;
    FGeneratorList: TStringList;
    FHasClassIdStorage: Boolean;
    FMapsList: TObjectList;
    FModel: TPressModel;
    FTableList: TObjectList;
    function GetClassIdMetadata: TPressObjectMetadata;
    function GetItems(AIndex: Integer): TPressOPFTableMetadata;
    function GetMaps(AClass: TPressObjectClass): TPressOPFStorageMapList;
  protected
    procedure AddAttributeItemMetadata(ATableMetadata: TPressOPFTableMetadata; AAttributeMetadata: TPressAttributeMetadata);
    procedure AddAttributeItemsMetadata(ATableMetadata: TPressOPFTableMetadata; AAttributeMetadata: TPressAttributeMetadata);
    procedure AddAttributeMetadata(AStorageMap: TPressOPFStorageMap; ATableMetadata: TPressOPFTableMetadata; AAttributeMetadata: TPressAttributeMetadata);
    procedure AddAttributeOwnedPartsMetadata;
    procedure AddAttributeValueMetadata(AStorageMap: TPressOPFStorageMap; ATableMetadata: TPressOPFTableMetadata; AAttributeMetadata: TPressAttributeMetadata);
    function AddField(const AFieldName, AShortFieldName: string; ADataType: TPressAttributeBaseType; ASize: Integer; AFieldOptions: TPressOPFFieldOptions; AIndexOptions: TPressOPFIndexOptions; ATableMetadata: TPressOPFTableMetadata): TPressOPFFieldMetadata;
    procedure AddForeignKey(ATableMetadata: TPressOPFTableMetadata; AFieldMetadata: TPressOPFFieldMetadata; AReferencedObject: TPressObjectMetadata);
    procedure AddGeneratorName(const AName: string);
    procedure AddIndex(ATableMetadata: TPressOPFTableMetadata; AFieldMetadata: TPressOPFFieldMetadata; AIndexOptions: TPressOPFIndexOptions; AIndexName: string = '');
    procedure AddObjectMetadata(AStorageMap: TPressOPFStorageMap);
    procedure AddTableMetadata(ATableMetadata: TPressOPFTableMetadata);
    property HasClassIdStorage: Boolean read FHasClassIdStorage;
  public
    constructor Create(AModel: TPressModel);
    destructor Destroy; override;
    function Count: Integer;
    property ClassIdMetadata: TPressObjectMetadata read GetClassIdMetadata;
    property GeneratorList: TStringList read FGeneratorList;
    property Items[AIndex: Integer]: TPressOPFTableMetadata read GetItems; default;
    property Maps[AClass: TPressObjectClass]: TPressOPFStorageMapList read GetMaps;
  end;

  TPressOPFStorageModel = class(TObject)
  private
    FClassIdList: TStrings;
    FClassNameList: TStrings;
    FHasClassIdStorage: Boolean;
    FModel: TPressModel;
    FNotifier: TPressNotifier;
    FSession: TPressSession;
    FTableMetadatas: TPressOPFTableMetadatas;
    procedure BuildClassLists;
    function FindClass(var AClassList: TStrings; const AValue: string): Integer;
    function GetMaps(AClass: TPressObjectClass): TPressOPFStorageMapList;
    function GetTableMetadatas: TPressOPFTableMetadatas;
    procedure Notify(AEvent: TPressEvent);
  public
    constructor Create(ASession: TPressSession; AModel: TPressModel);
    destructor Destroy; override;
    function ClassById(const AClassId: string): TPressObjectClass;
    function ClassIdByName(const AClassName: string): string;
    function ClassNameById(const AClassId: string): string;
    procedure ResetClassList;
    property HasClassIdStorage: Boolean read FHasClassIdStorage;
    property Maps[AClass: TPressObjectClass]: TPressOPFStorageMapList read GetMaps;
    property Model: TPressModel read FModel;
    property Session: TPressSession read FSession;
    property TableMetadatas: TPressOPFTableMetadatas read GetTableMetadatas;
  end;

function PressStorageModel(ASession: TPressSession): TPressOPFStorageModel;

implementation

uses
{$IFDEF D2006UP}
  Windows,
{$ENDIF}
  SysUtils,
  PressConsts,
  PressAttributes,
  PressOPFClasses;

type
  TPressInstanceClass = class(TPressObject)
  private
    FObjectClassName: TPressPlainString;
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

function PressStorageModel(ASession: TPressSession): TPressOPFStorageModel;
begin
  { TODO : Implement }
  if not Assigned(_PressStorageModel) then
    _PressStorageModel := TPressOPFStorageModel.Create(ASession, PressModel);
  Result := _PressStorageModel;
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
   'ObjectClassName: PlainString(32))', [
   PressModel.ClassIdType.AttributeName,
   PressModel.ClassIdStorageName]);
end;

procedure TPressInstanceClass.SetObjectClassName(AValue: string);
begin
  FObjectClassName.Value := AValue;
end;

{ TPressOPFStorageMap }

constructor TPressOPFStorageMap.Create(AMetadata: TPressObjectMetadata);
begin
  inherited Create(False);
  FMetadata := AMetadata;
  FObjectClass := FMetadata.ObjectClass;
  FIdType := FMetadata.IdMetadata.AttributeClass.AttributeBaseType;
end;

{ TPressOPFStorageMapList }

function TPressOPFStorageMapList.Add(
  AObject: TPressOPFStorageMap): Integer;
begin
  Result := inherited Add(AObject);
end;

procedure TPressOPFStorageMapList.BuildStorageMaps;

  procedure BuildMaps(AClass: TPressObjectClass);

    function IsOverriding(AMetadata: TPressAttributeMetadata): Boolean;
    var
      I: Integer;
    begin
      Result := True;
      for I := 0 to Pred(Count) do
        if Items[I].IndexOfName(AMetadata.Name) >= 0 then
          Exit;
      Result := False;
    end;

  var
    VStorageMap: TPressOPFStorageMap;
    VMetadatas: TPressAttributeMetadataList;
    VMetadata: TPressAttributeMetadata;
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
      begin
        VMetadata := VMetadatas[I];
        if VMetadata.IsPersistent and not IsOverriding(VMetadata) then
          VStorageMap.Add(VMetadata);
      end;
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

{ TPressOPFMetadata }

constructor TPressOPFMetadata.Create(const AName: string);
begin
  inherited Create;
  FName := AName;
end;

{ TPressOPFFieldMetadata }

constructor TPressOPFFieldMetadata.Create(const AName, AShortName: string);
begin
  inherited Create(AName);
  if AShortName <> '' then
    FShortName := AShortName
  else
    FShortName := AName;
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
  const AName, AShortName: string): TPressOPFFieldMetadata;
begin
  EnsureListInstance(FFields);
  Result := TPressOPFFieldMetadata.Create(AName, AShortName);
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

constructor TPressOPFTableMetadata.Create(const AName, AShortName: string);
begin
  inherited Create(AName);
  if AShortName <> '' then
    FShortName := AShortName
  else
    FShortName := AName;
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

{ TPressOPFTableMetadatas }

procedure TPressOPFTableMetadatas.AddAttributeItemMetadata(
  ATableMetadata: TPressOPFTableMetadata;
  AAttributeMetadata: TPressAttributeMetadata);
var
  VField: TPressOPFFieldMetadata;
  VObjectMetadata: TPressObjectMetadata;
begin
  VField := ATableMetadata.AddField(
   AAttributeMetadata.PersistentName, AAttributeMetadata.ShortName);
  VObjectMetadata := AAttributeMetadata.ObjectClassMetadata;
  VField.DataType :=
   VObjectMetadata.IdMetadata.AttributeClass.AttributeBaseType;
  VField.Size := VObjectMetadata.IdMetadata.Size;
  VField.Options := [];
  AddForeignKey(ATableMetadata, VField, VObjectMetadata);
end;

procedure TPressOPFTableMetadatas.AddAttributeItemsMetadata(
  ATableMetadata: TPressOPFTableMetadata;
  AAttributeMetadata: TPressAttributeMetadata);
var
  VTableMetadata: TPressOPFTableMetadata;
  VField: TPressOPFFieldMetadata;
  VObjectMetadata: TPressObjectMetadata;
  VHasId: Boolean;
begin
  VTableMetadata := TPressOPFTableMetadata.Create(
   AAttributeMetadata.PersLinkName, '');
  AddTableMetadata(VTableMetadata);
  VTableMetadata.PrimaryKey := TPressOPFIndexMetadata.Create(
   SPressPrimaryKeyNamePrefix + VTableMetadata.Name);
  VHasId := AAttributeMetadata.PersLinkIdName <> '';
  if VHasId then
  begin
    VField :=
     VTableMetadata.AddField(AAttributeMetadata.PersLinkIdName, '');
    { TODO : Implement }
    VField.DataType := FModel.DefaultKeyType.AttributeBaseType;
    VField.Size := 32;
    VField.Options := [foNotNull];
    VTableMetadata.PrimaryKey.FieldNames.Text := VField.Name;
  end;

  VField :=
   VTableMetadata.AddField(AAttributeMetadata.PersLinkParentName, '');
  VObjectMetadata := AAttributeMetadata.Owner;
  VField.DataType :=
   VObjectMetadata.IdMetadata.AttributeClass.AttributeBaseType;
  VField.Size := VObjectMetadata.IdMetadata.Size;
  VField.Options := [foNotNull];
  AddForeignKey(VTableMetadata, VField, VObjectMetadata);
  if not VHasId then
    VTableMetadata.PrimaryKey.FieldNames.Text := VField.Name;

  VField :=
   VTableMetadata.AddField(AAttributeMetadata.PersLinkChildName, '');
  VObjectMetadata := AAttributeMetadata.ObjectClassMetadata;
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
     VTableMetadata.AddField(AAttributeMetadata.PersLinkPosName, '');
    VField.DataType := attInteger;
    VField.Options := [foNotNull];
  end;
end;

procedure TPressOPFTableMetadatas.AddAttributeMetadata(
  AStorageMap: TPressOPFStorageMap;
  ATableMetadata: TPressOPFTableMetadata;
  AAttributeMetadata: TPressAttributeMetadata);
var
  VTargetOwner: TPressObjectMetadata;
begin
  if AAttributeMetadata.GeneratorName <> '' then
    AddGeneratorName(AAttributeMetadata.GeneratorName);
  if AAttributeMetadata.AttributeClass.InheritsFrom(TPressValue) then
    AddAttributeValueMetadata(AStorageMap, ATableMetadata, AAttributeMetadata)
  else if AAttributeMetadata.AttributeClass.InheritsFrom(TPressStructure) then
  begin
    if not AAttributeMetadata.ObjectClassMetadata.IsPersistent then
      raise EPressOPFError.CreateFmt(STargetClassIsNotPersistent, [
       AAttributeMetadata.Owner.ObjectClassName,
       AAttributeMetadata.Name,
       AAttributeMetadata.ObjectClass.ClassName]);
    VTargetOwner := AAttributeMetadata.ObjectClassMetadata.OwnerMetadata;
    if Assigned(VTargetOwner) and
     (VTargetOwner <> AAttributeMetadata.Owner) then
      raise EPressOPFError.CreateFmt(SAttributeReferencesOwnedClass, [
       AAttributeMetadata.Owner.ObjectClassName,
       AAttributeMetadata.Name,
       AAttributeMetadata.ObjectClass.ClassName,
       VTargetOwner.ObjectClassName]);
    if AAttributeMetadata.AttributeClass.InheritsFrom(TPressItem) then
      AddAttributeItemMetadata(ATableMetadata, AAttributeMetadata)
    else if AAttributeMetadata.AttributeClass.InheritsFrom(TPressItems) then
      if AAttributeMetadata.IsEmbeddedLink then
        AddAttributeOwnedPartsMetadata
      else
        AddAttributeItemsMetadata(ATableMetadata, AAttributeMetadata);
  end;
end;

procedure TPressOPFTableMetadatas.AddAttributeOwnedPartsMetadata;
begin
end;

procedure TPressOPFTableMetadatas.AddAttributeValueMetadata(
  AStorageMap: TPressOPFStorageMap;
  ATableMetadata: TPressOPFTableMetadata;
  AAttributeMetadata: TPressAttributeMetadata);
var
  VField: TPressOPFFieldMetadata;
  VFieldOptions: TPressOPFFieldOptions;
  VIndexOptions: TPressOPFIndexOptions;
begin
  VFieldOptions := [];
  if AAttributeMetadata.NotNull then
    VFieldOptions := VFieldOptions + [foNotNull];
  if AAttributeMetadata.Index then
    VFieldOptions := VFieldOptions + [foIndexed];
  VIndexOptions := [];
  if AAttributeMetadata.Unique then
    VIndexOptions := VIndexOptions + [ioUnique];
  VField := AddField(
   AAttributeMetadata.PersistentName, AAttributeMetadata.ShortName,
   AAttributeMetadata.AttributeClass.AttributeBaseType,
   AAttributeMetadata.Size, VFieldOptions, VIndexOptions, ATableMetadata);
  if AStorageMap.Metadata.IdMetadata = AAttributeMetadata then
  begin
    ATableMetadata.PrimaryKey := TPressOPFIndexMetadata.Create(
     SPressPrimaryKeyNamePrefix + ATableMetadata.Name);
    ATableMetadata.PrimaryKey.FieldNames.Text := VField.Name;
    VField.Options := [foNotNull];
  end;
end;

function TPressOPFTableMetadatas.AddField(
  const AFieldName, AShortFieldName: string;
  ADataType: TPressAttributeBaseType; ASize: Integer;
  AFieldOptions: TPressOPFFieldOptions;
  AIndexOptions: TPressOPFIndexOptions;
  ATableMetadata: TPressOPFTableMetadata): TPressOPFFieldMetadata;
var
  VField: TPressOPFFieldMetadata;
begin
  VField := ATableMetadata.AddField(AFieldName, AShortFieldName);
  VField.DataType := ADataType;
  VField.Size := ASize;
  VField.Options := AFieldOptions;
  if foIndexed in AFieldOptions then
    AddIndex(ATableMetadata, VField, AIndexOptions);
  Result := VField;
end;

procedure TPressOPFTableMetadatas.AddForeignKey(
  ATableMetadata: TPressOPFTableMetadata;
  AFieldMetadata: TPressOPFFieldMetadata;
  AReferencedObject: TPressObjectMetadata);
var
  VForeignKey: TPressOPFForeignKeyMetadata;
begin
  VForeignKey := ATableMetadata.AddForeignKey(SPressForeignKeyNamePrefix +
   ATableMetadata.ShortName + SPressIdentifierSeparator + AFieldMetadata.ShortName);
  VForeignKey.KeyFieldNames.Text := AFieldMetadata.Name;
  VForeignKey.ReferencedFieldNames.Text :=
   AReferencedObject.IdMetadata.PersistentName;
  VForeignKey.ReferencedTableName := AReferencedObject.PersistentName;
  VForeignKey.OnUpdateAction := raCascade;
  VForeignKey.OnDeleteAction := raNoAction;
end;

procedure TPressOPFTableMetadatas.AddGeneratorName(const AName: string);
begin
  if FGeneratorList.IndexOf(AName) = -1 then
    FGeneratorList.Add(AName);
end;

procedure TPressOPFTableMetadatas.AddIndex(
  ATableMetadata: TPressOPFTableMetadata;
  AFieldMetadata: TPressOPFFieldMetadata;
  AIndexOptions: TPressOPFIndexOptions; AIndexName: string = '');
var
  VIndex: TPressOPFIndexMetadata;
begin
  if AIndexName = '' then
    AIndexName := SPressIndexNamePrefix + ATableMetadata.ShortName +
     SPressIdentifierSeparator + AFieldMetadata.ShortName;
  VIndex := ATableMetadata.AddIndex(AIndexName);
  VIndex.FieldNames.Text := AFieldMetadata.Name;
  VIndex.Options := AIndexOptions;
end;

procedure TPressOPFTableMetadatas.AddObjectMetadata(
  AStorageMap: TPressOPFStorageMap);
var
  VTableMetadata: TPressOPFTableMetadata;
  VFieldMetadata: TPressOPFFieldMetadata;
  VMetadata: TPressObjectMetadata;
  VIdMetadata: TPressAttributeMetadata;
  I: Integer;
begin
  VMetadata := AStorageMap.Metadata;
  VTableMetadata := TPressOPFTableMetadata.Create(
   VMetadata.PersistentName, VMetadata.ShortName);
  AddTableMetadata(VTableMetadata);
  AddAttributeMetadata(AStorageMap, VTableMetadata, VMetadata.IdMetadata);

  if VMetadata.ClassIdName <> '' then
  begin
    VFieldMetadata := AddField(VMetadata.ClassIdName, '',
     ClassIdMetadata.IdMetadata.AttributeClass.AttributeBaseType,
     ClassIdMetadata.IdMetadata.Size,
     [foNotNull], [], VTableMetadata);
    if HasClassIdStorage then
      AddForeignKey(VTableMetadata, VFieldMetadata, ClassIdMetadata);
  end;

  if VMetadata.UpdateCountName <> '' then
    AddField(VMetadata.UpdateCountName, '',
     attInteger, 0, [foNotNull], [], VTableMetadata);

  if Assigned(VMetadata.OwnerPartsMetadata) then
  begin
    if VMetadata.OwnerPartsMetadata.PersLinkParentName <> '' then
    begin
      VIdMetadata := VMetadata.OwnerMetadata.IdMetadata;
      VFieldMetadata := AddField(
       VMetadata.OwnerPartsMetadata.PersLinkParentName, '',
       VIdMetadata.AttributeClass.AttributeBaseType, VIdMetadata.Size,
       [foNotNull], [], VTableMetadata);
      AddForeignKey(
       VTableMetadata, VFieldMetadata, VMetadata.OwnerMetadata);
    end;
    if VMetadata.OwnerPartsMetadata.PersLinkPosName <> '' then
      AddField(VMetadata.OwnerPartsMetadata.PersLinkPosName, '',
       attInteger, 0, [foNotNull], [], VTableMetadata);
  end;

  for I := 1 to Pred(AStorageMap.Count) do  // skips ID
    AddAttributeMetadata(AStorageMap, VTableMetadata, AStorageMap[I]);
end;

procedure TPressOPFTableMetadatas.AddTableMetadata(
  ATableMetadata: TPressOPFTableMetadata);
begin
  FTableList.Add(ATableMetadata);
end;

function TableMetadataListCompare(Item1, Item2: Pointer): Integer;
begin
  Result := AnsiCompareStr(
   TPressOPFTableMetadata(Item1).Name, TPressOPFTableMetadata(Item2).Name);
end;

function TPressOPFTableMetadatas.Count: Integer;
begin
  Result := FTableList.Count;
end;

constructor TPressOPFTableMetadatas.Create(AModel: TPressModel);
begin
  inherited Create;
  FModel := AModel;
  FHasClassIdStorage := TPressInstanceClass.ClassMetadata.IsPersistent;
  FGeneratorList := TStringList.Create;
  FGeneratorList.Sorted := True;
  FTableList := TObjectList.Create(True);
  with FModel.CreateMetadataIterator do
  try
    BeforeFirstItem;
    while NextItem do
      if CurrentItem.IsPersistent then
        AddObjectMetadata(Maps[CurrentItem.ObjectClass].Last);
  finally
    Free;
  end;
  FTableList.Sort({$IFDEF FPC}@{$ENDIF}TableMetadataListCompare);
end;

destructor TPressOPFTableMetadatas.Destroy;
begin
  FGeneratorList.Free;
  FMapsList.Free;
  FTableList.Free;
  inherited;
end;

function TPressOPFTableMetadatas.GetClassIdMetadata: TPressObjectMetadata;
begin
  if not Assigned(FClassIdMetadata) then
    FClassIdMetadata := TPressInstanceClass.ClassMetadata;
  Result := FClassIdMetadata;
end;

function TPressOPFTableMetadatas.GetItems(
  AIndex: Integer): TPressOPFTableMetadata;
begin
  Result := FTableList[AIndex] as TPressOPFTableMetadata;
end;

function TPressOPFTableMetadatas.GetMaps(
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

{ TPressOPFStorageModel }

procedure TPressOPFStorageModel.BuildClassLists;
var
  VObjects: TPressProxyList;
  VInstance: TPressInstanceClass;
  I: Integer;
begin
  if not Assigned(FClassIdList) or not Assigned(FClassNameList) then
  begin
    FreeAndNil(FClassIdList);
    FreeAndNil(FClassNameList);
    FClassIdList := TStringList.Create;
    FClassNameList := TStringList.Create;
    VObjects := Session.OQLQuery(
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
  if HasClassIdStorage and (AClassName <> '') then
  begin
    VIndex := FindClass(FClassNameList, AClassName);
    if VIndex >= 0 then
      Result := FClassIdList[VIndex]
    else
    begin
      Model.ClassByName(AClassName);
      VInstance := TPressInstanceClass.Create;
      try
        VInstance.ObjectClassName := AClassName;
        Session.Store(VInstance);
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
    VIndex := FindClass(FClassIdList, AClassId);
    if VIndex >= 0 then
      Result := FClassNameList[VIndex]
    else
      raise EPressOPFError.CreateFmt(SClassNotFound, [AClassId]);
  end else
    Result := AClassId;
end;

constructor TPressOPFStorageModel.Create(
  ASession: TPressSession; AModel: TPressModel);
begin
  inherited Create;
  FSession := ASession;
  FModel := AModel;
  FNotifier := TPressNotifier.Create({$IFDEF FPC}@{$ENDIF}Notify);
  FNotifier.AddNotificationItem(FModel, [TPressModelBusinessClassChangedEvent]);
  FHasClassIdStorage := TPressInstanceClass.ClassMetadata.IsPersistent;
end;

destructor TPressOPFStorageModel.Destroy;
begin
  FNotifier.Free;
  FClassIdList.Free;
  FClassNameList.Free;
  FTableMetadatas.Free;
  inherited;
end;

function TPressOPFStorageModel.FindClass(
  var AClassList: TStrings; const AValue: string): Integer;
begin
  BuildClassLists;
  Result := AClassList.IndexOf(AValue);
  if Result = -1 then
  begin
    FreeAndNil(FClassIdList);
    FreeAndNil(FClassNameList);
    BuildClassLists;
    Result := AClassList.IndexOf(AValue);
  end;
end;

function TPressOPFStorageModel.GetMaps(
  AClass: TPressObjectClass): TPressOPFStorageMapList;
begin
  Result := TableMetadatas.Maps[AClass];
end;

function TPressOPFStorageModel.GetTableMetadatas: TPressOPFTableMetadatas;
begin
  if not Assigned(FTableMetadatas) then
    FTableMetadatas := TPressOPFTableMetadatas.Create(Model);
  Result := FTableMetadatas;
end;

procedure TPressOPFStorageModel.Notify(AEvent: TPressEvent);
begin
  if AEvent is TPressModelBusinessClassChangedEvent then
  begin
    FreeAndNil(FClassIdList);
    FreeAndNil(FClassNameList);
    FreeAndNil(FTableMetadatas);
  end;
end;

procedure TPressOPFStorageModel.ResetClassList;
begin
  FreeAndNil(FClassIdList);
  FreeAndNil(FClassNameList);
end;

initialization
  TPressInstanceClass.RegisterClass;

finalization
  TPressInstanceClass.UnregisterClass;
  _PressStorageModel.Free;

end.
