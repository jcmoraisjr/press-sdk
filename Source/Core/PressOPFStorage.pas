(*
  PressObjects, Persistence Storage Classes
  Copyright (C) 2007 Laserpress Ltda.

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
  PressSubject;

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

  TPressOPFStorageModel = class(TObject)
  private
    FClassIdList: TStrings;
    FClassIdMetadata: TPressObjectMetadata;
    FClassNameList: TStrings;
    FHasClassIdStorage: Boolean;
    FMapsList: TObjectList;
    FModel: TPressModel;
    FNotifier: TPressNotifier;
    FTableMetadatas: TObjectList;
    procedure BuildClassLists;
    function CreateTableMetadatas: TObjectList;
    function FindClass(var AClassList: TStrings; const AValue: string): Integer;
    function GetClassIdMetadata: TPressObjectMetadata;
    function GetMaps(AClass: TPressObjectClass): TPressOPFStorageMapList;
    function GetTableMetadatas(AIndex: Integer): TPressOPFTableMetadata;
    procedure Notify(AEvent: TPressEvent);
  protected
    property ClassIdMetadata: TPressObjectMetadata read GetClassIdMetadata;
  public
    constructor Create(AModel: TPressModel);
    destructor Destroy; override;
    function ClassById(const AClassId: string): TPressObjectClass;
    function ClassIdByName(const AClassName: string): string;
    function ClassNameById(const AClassId: string): string;
    procedure ResetClassList;
    function TableMetadataCount: Integer;
    property HasClassIdStorage: Boolean read FHasClassIdStorage;
    property Maps[AClass: TPressObjectClass]: TPressOPFStorageMapList read GetMaps;
    property Model: TPressModel read FModel;
    property TableMetadatas[AIndex: Integer]: TPressOPFTableMetadata read GetTableMetadatas;
  end;

function PressStorageModel: TPressOPFStorageModel;

implementation

uses
  SysUtils,
  PressConsts,
  PressAttributes,
  PressOPFClasses;

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
    VIndex := FindClass(FClassNameList, AClassName);
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
    VIndex := FindClass(FClassIdList, AClassId);
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
  FNotifier := TPressNotifier.Create({$IFDEF FPC}@{$ENDIF}Notify);
  FNotifier.AddNotificationItem(FModel, [TPressModelBusinessClassChangedEvent]);
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
        AIndexName := SPressIndexNamePrefix + ATableMetadata.ShortName +
         SPressIdentifierSeparator + AFieldMetadata.ShortName;
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
       ATable.ShortName + SPressIdentifierSeparator + AField.ShortName);
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
        VField := ATableMetadata.AddField(
         AAttributeMetadata.PersistentName, AAttributeMetadata.ShortName);
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
        VField := ATableMetadata.AddField(
         AAttributeMetadata.PersistentName, AAttributeMetadata.ShortName);
        VObjectMetadata := AAttributeMetadata.ObjectClassMetadata;
        VField.DataType :=
         VObjectMetadata.IdMetadata.AttributeClass.AttributeBaseType;
        VField.Size := VObjectMetadata.IdMetadata.Size;
        VField.Options := [];
        AddForeignKey(ATableMetadata, VField, VObjectMetadata);
      end;

      procedure AddOwnedPartsMetadata;
      begin
      end;

      procedure AddItemsMetadata;
      var
        VTableMetadata: TPressOPFTableMetadata;
        VField: TPressOPFFieldMetadata;
        VObjectMetadata: TPressObjectMetadata;
        VHasId: Boolean;
      begin
        VTableMetadata := TPressOPFTableMetadata.Create(
         AAttributeMetadata.PersLinkName, '');
        ATableMetadatas.Add(VTableMetadata);
        VTableMetadata.PrimaryKey := TPressOPFIndexMetadata.Create(
         SPressPrimaryKeyNamePrefix + VTableMetadata.Name);
        VHasId := AAttributeMetadata.PersLinkIdName <> '';
        if VHasId then
        begin
          VField :=
           VTableMetadata.AddField(AAttributeMetadata.PersLinkIdName, '');
          { TODO : Implement }
          VField.DataType := Model.DefaultKeyType.AttributeBaseType;
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

    {procedure AddAttributeMetadata(AAttributeMetadata: TPressAttributeMetadata;
      ATableMetadata: TPressOPFTableMetadata);}
    begin
      if AAttributeMetadata.AttributeClass.InheritsFrom(TPressValue) then
        AddFieldMetadata
      else if AAttributeMetadata.AttributeClass.InheritsFrom(TPressStructure) then
      begin
        if not AAttributeMetadata.ObjectClassMetadata.IsPersistent then
          raise EPressOPFError.CreateFmt(STargetClassIsNotPersistent, [
           AAttributeMetadata.Owner.ObjectClassName,
           AAttributeMetadata.Name,
           AAttributeMetadata.ObjectClass.ClassName]);
        if AAttributeMetadata.AttributeClass.InheritsFrom(TPressItem) then
          AddItemMetadata
        else if AAttributeMetadata.AttributeClass.InheritsFrom(TPressItems) then
          if AAttributeMetadata.IsEmbeddedLink then
            AddOwnedPartsMetadata
          else
            AddItemsMetadata;
      end;
    end;

    function AddFieldMetadata(const AFieldName, AShortFieldName: string;
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

  {procedure AddObjectMetadata(
    AStorageMap: TPressOPFStorageMap; ATableMetadatas: TObjectList);}
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
    ATableMetadatas.Add(VTableMetadata);
    AddAttributeMetadata(VMetadata.IdMetadata, VTableMetadata);

    if VMetadata.ClassIdName <> '' then
    begin
      VFieldMetadata := AddFieldMetadata(VMetadata.ClassIdName, '',
       ClassIdMetadata.IdMetadata.AttributeClass.AttributeBaseType,
       ClassIdMetadata.IdMetadata.Size,
       [foNotNull], [], VTableMetadata);
      if HasClassIdStorage then
        AddForeignKey(VTableMetadata, VFieldMetadata, ClassIdMetadata);
    end;

    if VMetadata.UpdateCountName <> '' then
      AddFieldMetadata(VMetadata.UpdateCountName, '',
       attInteger, 0, [foNotNull], [], VTableMetadata);

    if Assigned(VMetadata.OwnerPartsMetadata) then
    begin
      if VMetadata.OwnerPartsMetadata.PersLinkParentName <> '' then
      begin
        VIdMetadata := VMetadata.OwnerMetadata.IdMetadata;
        VFieldMetadata := AddFieldMetadata(
         VMetadata.OwnerPartsMetadata.PersLinkParentName, '',
         VIdMetadata.AttributeClass.AttributeBaseType, VIdMetadata.Size,
         [foNotNull], [], VTableMetadata);
        AddForeignKey(
         VTableMetadata, VFieldMetadata, VMetadata.OwnerMetadata);
      end;
      if VMetadata.OwnerPartsMetadata.PersLinkPosName <> '' then
        AddFieldMetadata(VMetadata.OwnerPartsMetadata.PersLinkPosName, '',
         attInteger, 0, [foNotNull], [], VTableMetadata);
    end;

    for I := 1 to Pred(AStorageMap.Count) do  // skips ID
      AddAttributeMetadata(AStorageMap[I], VTableMetadata);
  end;

{function TPressOPFStorageModel.CreateTableMetadatas: TObjectList;}
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
  FNotifier.Free;
  FClassIdList.Free;
  FClassNameList.Free;
  FMapsList.Free;
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

procedure TPressOPFStorageModel.Notify(AEvent: TPressEvent);
begin
  if AEvent is TPressModelBusinessClassChangedEvent then
  begin
    FreeAndNil(FClassIdList);
    FreeAndNil(FClassNameList);
    FreeAndNil(FMapsList);
    FreeAndNil(FTableMetadatas);
  end;
end;

procedure TPressOPFStorageModel.ResetClassList;
begin
  FreeAndNil(FClassIdList);
  FreeAndNil(FClassNameList);
end;

function TPressOPFStorageModel.TableMetadataCount: Integer;
begin
  if not Assigned(FTableMetadatas) then
    FTableMetadatas := CreateTableMetadatas;
  Result := FTableMetadatas.Count;
end;

initialization
  TPressInstanceClass.RegisterClass;

finalization
  TPressInstanceClass.UnregisterClass;
  _PressStorageModel.Free;

end.
