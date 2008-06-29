(*
  PressObjects, Code Updater Classes
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressCodeUpdater;

{$I Press.inc}

interface

uses
  Classes,
  Contnrs,
  PressClasses,
  PressPascal,
  PressIDEIntf,
  PressProjectModel;

type
  TPressCodeUpdate = class(TObject)
  private
    FDeleteCount: Integer;
    FInsertText: string;
    FPosition: TPressTextPos;
  public
    constructor Create(APosition: TPressTextPos; ADeleteCount: Integer; const AInsertText: string);
    property DeleteCount: Integer read FDeleteCount;
    property InsertText: string read FInsertText;
    property Position: TPressTextPos read FPosition;
  end;

  TPressCodeUpdates = class(TObject)
  private
    FCodeUpdates: TObjectList;
    FUnitParser: TPressPascalUnit;
    FUnitReader: TPressPascalReader;
    function GetCodeUpdate(AIndex: Integer): TPressCodeUpdate;
    function GetCount: Integer;
  protected
    procedure AddCodeUpdate(APosition: TPressTextPos; ADeleteCount: Integer; const AInsertText: string);
    function InternalGetItem: TPressProjectItem; virtual; abstract;
    procedure InternalProcessItem; virtual;
    property UnitParser: TPressPascalUnit read FUnitParser;
    property UnitReader: TPressPascalReader read FUnitReader;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ProcessItem;
    property CodeUpdate[AIndex: Integer]: TPressCodeUpdate read GetCodeUpdate; default;
    property Count: Integer read GetCount;
  end;

  TPressCodeObjectBuilder = class(TObject)
  private
    FAttributeList: TStringList;
    FItem: TPressObjectMetadataRegistry;
    FHasContainerAttr: Boolean;
    FHasPlainAttr: Boolean;
    function BuildAttributeReferenceDeclaration(AAttr: TPressAttributeMetadataRegistry): string;
    function BuildCollectionPropertyDeclaration(AAttr: TPressAttributeMetadataRegistry): string;
    function BuildGetterDeclaration(AAttr: TPressAttributeMetadataRegistry): string;
    function BuildGetterImplementation(AAttr: TPressAttributeMetadataRegistry): string;
    function BuildMetadataStr: string;
    function BuildPlainPropertyDeclaration(AAttr: TPressAttributeMetadataRegistry): string;
    function BuildSetterDeclaration(AAttr: TPressAttributeMetadataRegistry): string;
    function BuildSetterImplementation(AAttr: TPressAttributeMetadataRegistry): string;
    procedure CheckAttributeList;
    function GetAttributeList(AIndex: Integer): TPressAttributeMetadataRegistry;
    function PressTypeToNativeType(AAttribute: TPressAttributeMetadataRegistry): string;
  public
    constructor Create(AItem: TPressObjectMetadataRegistry);
    destructor Destroy; override;
    function AttributeListCount: Integer;
    function BuildFinalizationSection: string;
    function BuildImplementationSection: string;
    function BuildInitializationSection: string;
    function BuildInterfaceSection: string;
    property AttributeList[AIndex: Integer]: TPressAttributeMetadataRegistry read GetAttributeList;
    property Item: TPressObjectMetadataRegistry read FItem;
  end;

  TPressCodeObjectUpdates = class(TPressCodeUpdates)
  private
    FBuilder: TPressCodeObjectBuilder;
    FItem: TPressObjectMetadataRegistry;
    function GetBuilder: TPressCodeObjectBuilder;
  protected
    function InternalGetItem: TPressProjectItem; override;
    procedure InternalProcessItem; override;
    property Builder: TPressCodeObjectBuilder read GetBuilder;
  public
    constructor Create(AItem: TPressObjectMetadataRegistry);
    destructor Destroy; override;
  end;

  TPressCodeAttributeTypeUpdates = class(TPressCodeUpdates)
  private
    FItem: TPressAttributeTypeRegistry;
  protected
    function InternalGetItem: TPressProjectItem; override;
    procedure InternalProcessItem; override;
  public
    constructor Create(AItem: TPressAttributeTypeRegistry);
  end;

  TPressCodeEnumUpdates = class(TPressCodeUpdates)
  private
    FItem: TPressEnumerationRegistry;
  protected
    function InternalGetItem: TPressProjectItem; override;
    procedure InternalProcessItem; override;
  public
    constructor Create(AItem: TPressEnumerationRegistry);
  end;

  TPressCodeUpdater = class(TObject)
  private
    FParsedModules: TInterfaceList;
    FProject: TPressProject;
    function CreateCodeUpdates(AItem: TPressProjectItem): TPressCodeUpdates;
  protected
    procedure ExtractBODeclarations(AModule: TPressProjectModule; Reader: TPressPascalReader; AProc: TPressPascalProcDeclaration);
    procedure ExtractClassDeclarations(AModule: TPressProjectModule; Reader: TPressPascalReader; ATypes: TPressPascalTypesDeclaration);
    procedure ExtractEnumDeclarations(AModule: TPressProjectModule; Reader: TPressPascalReader; AItems: TPressPascalObject);
    procedure ExtractMVPDeclarations(AModule: TPressProjectModule; Reader: TPressPascalReader; AProc: TPressPascalProcDeclaration);
    property ParsedModules: TInterfaceList read FParsedModules;
    property Project: TPressProject read FProject;
  public
    constructor Create(AProject: TPressProject);
    destructor Destroy; override;
    procedure ClearProjectModules;
    function ParseModule(AModuleIntf: IPressIDEModule): TPressProjectModule;
    procedure StoreProjectItem(AItem: TPressProjectItem);
  end;

implementation

uses
  SysUtils,
  PressConsts,
  PressSubject,
  PressAttributes,
  PressDesignClasses,
  PressDesignConsts;

{ TPressCodeUpdate }

constructor TPressCodeUpdate.Create(APosition: TPressTextPos;
  ADeleteCount: Integer; const AInsertText: string);
begin
  inherited Create;
  FPosition := APosition;
  FDeleteCount := ADeleteCount;
  FInsertText := AInsertText;
end;

{ TPressCodeUpdates }

procedure TPressCodeUpdates.AddCodeUpdate(APosition: TPressTextPos;
  ADeleteCount: Integer; const AInsertText: string);
begin
  FCodeUpdates.Add(
   TPressCodeUpdate.Create(APosition, ADeleteCount, AInsertText));
end;

constructor TPressCodeUpdates.Create;
begin
  inherited Create;
  FCodeUpdates := TObjectList.Create(True);
  FUnitParser := TPressPascalUnit.Create(nil);
end;

destructor TPressCodeUpdates.Destroy;
begin
  FUnitParser.Free;
  FUnitReader.Free;
  FCodeUpdates.Free;
  inherited;
end;

function TPressCodeUpdates.GetCodeUpdate(AIndex: Integer): TPressCodeUpdate;
begin
  Result := FCodeUpdates[AIndex] as TPressCodeUpdate;
end;

function TPressCodeUpdates.GetCount: Integer;
begin
  Result := FCodeUpdates.Count;
end;

procedure TPressCodeUpdates.InternalProcessItem;
begin
end;

procedure TPressCodeUpdates.ProcessItem;
begin
  FCodeUpdates.Clear;
  FreeAndNil(FUnitReader);
  FUnitReader := TPressPascalReader.Create(
   InternalGetItem.Module.ModuleIntf.SourceCode);
  FUnitParser.Read(FUnitReader);
  InternalProcessItem;
end;

{ TPressCodeObjectBuilder }

function TPressCodeObjectBuilder.AttributeListCount: Integer;
begin
  CheckAttributeList;
  Result := FAttributeList.Count;
end;

function TPressCodeObjectBuilder.BuildAttributeReferenceDeclaration(
  AAttr: TPressAttributeMetadataRegistry): string;
begin
  Result := Format('  %s%s: %s;' + SPressLineBreak, [
   SPressAttributePrefix, AAttr.Name, AAttr.AttributeType.ObjectClassName]);
end;

function TPressCodeObjectBuilder.BuildCollectionPropertyDeclaration(
  AAttr: TPressAttributeMetadataRegistry): string;
begin
  if AAttr.RuntimeMetadata.AttributeClass.InheritsFrom(TPressItems) then
    Result := Format('  property %0:s: %1:s read _%0:s;' + SPressLineBreak, [
     AAttr.Name, AAttr.AttributeType.ObjectClassName])
  else
    Result := '';
end;

function TPressCodeObjectBuilder.BuildFinalizationSection: string;
begin
  Result := Format('  %s.UnregisterClass;' + SPressLineBreak, [Item.ObjectClassName]);
end;

function TPressCodeObjectBuilder.BuildGetterDeclaration(
  AAttr: TPressAttributeMetadataRegistry): string;
begin
  if not AAttr.RuntimeMetadata.AttributeClass.InheritsFrom(TPressItems) then
    Result := Format('  function Get%s: %s;' + SPressLineBreak, [
     AAttr.Name, PressTypeToNativeType(AAttr)])
  else
    Result := '';
end;

function TPressCodeObjectBuilder.BuildGetterImplementation(
  AAttr: TPressAttributeMetadataRegistry): string;
var
  VAttrClass: TPressAttributeClass;
  VNativeType: string;
begin
  VAttrClass := AAttr.RuntimeMetadata.AttributeClass;
  if not VAttrClass.InheritsFrom(TPressItems) then
  begin
    VNativeType := PressTypeToNativeType(AAttr);
    Result := Format('function %s.Get%s: %s;' + SPressLineBreak, [
     Item.ObjectClassName, AAttr.Name, VNativeType]);
    Result := Result + 'begin' + SPressLineBreak + '  Result := ';
    if VAttrClass.InheritsFrom(TPressEnum) then
      Result := Result + VNativeType + '(';
    Result := Result + Format('%s%s.Value', [
     SPressAttributePrefix, AAttr.Name]);
    if VAttrClass.InheritsFrom(TPressEnum) then
      Result := Result + ')'
    else if VAttrClass.InheritsFrom(TPressItem) then
      Result := Result + ' as ' + VNativeType;
    Result := Result + ';' + SPressLineBreak + 'end;' + SPressLineBreak + SPressLineBreak;
  end else
    Result := '';
end;

function TPressCodeObjectBuilder.BuildImplementationSection: string;
var
  I: Integer;
begin
  Result := Format('{ %s }' + SPressLineBreak + SPressLineBreak, [Item.ObjectClassName]);
  for I := 0 to Pred(AttributeListCount) do
    Result := Result + BuildGetterImplementation(AttributeList[I]);
  { TODO : Alphabetical order }
  Result := Result + BuildMetadataStr;
  for I := 0 to Pred(AttributeListCount) do
    Result := Result + BuildSetterImplementation(AttributeList[I]);
end;

function TPressCodeObjectBuilder.BuildInitializationSection: string;
begin
  Result := Format('  %s.RegisterClass;' + SPressLineBreak, [Item.ObjectClassName]);
end;

function TPressCodeObjectBuilder.BuildInterfaceSection: string;
var
  I: Integer;
begin
  CheckAttributeList;
  Result := Format('{ %s }' + SPressLineBreak + SPressLineBreak, [Item.ObjectClassName]);
  Result := Result + Format('%s = class(%s)' + SPressLineBreak, [
   Item.ObjectClassName, Item.ParentClass.ObjectClassName]);
  for I := 0 to Pred(Item.AttributeList.Count) do
    Result := Result + BuildAttributeReferenceDeclaration(Item.AttributeList[I]);
  if FHasPlainAttr then
  begin
    Result := Result + 'private' + SPressLineBreak;
    for I := 0 to Pred(AttributeListCount) do
      Result := Result + BuildGetterDeclaration(AttributeList[I]);
    for I := 0 to Pred(AttributeListCount) do
      Result := Result + BuildSetterDeclaration(AttributeList[I]);
  end;
  Result := Result + 'protected' + SPressLineBreak;
  Result := Result + Format('  class function %s: string; override;' + SPressLineBreak, [
   SPressMetadataMethodName]);
  if FHasContainerAttr then
  begin
    Result := Result + 'public' + SPressLineBreak;
    for I := 0 to Pred(Item.AttributeList.Count) do
      Result := Result + BuildCollectionPropertyDeclaration(Item.AttributeList[I]);
  end;
  if FHasPlainAttr then
  begin
    Result := Result + 'published' + SPressLineBreak;
    for I := 0 to Pred(Item.AttributeList.Count) do
      Result := Result + BuildPlainPropertyDeclaration(Item.AttributeList[I]);
  end;
  Result := Result + 'end;' + SPressLineBreak + SPressLineBreak;
end;

function TPressCodeObjectBuilder.BuildMetadataStr: string;

  function FormatMetadataStr: string;
  var
    VMetadataList: TStrings;
    I: Integer;
  begin
    Item.UpdateRuntimeMetadata;
    VMetadataList := TStringList.Create;
    try
      VMetadataList.Text := Item.MetadataStr;
      Result := '';
      for I := 0 to Pred(VMetadataList.Count) do
        Result := Result +
         AnsiQuotedStr(Trim(VMetadataList[I]), '''') + ' +' + SPressLineBreak + '   ';
      if Result <> '' then
        SetLength(Result, Length(Result) - Length(SPressLineBreak) - 5);
    finally
      VMetadataList.Free;
    end;
  end;

begin
  Result := Format('class function %s.%s: string;' + SPressLineBreak, [
   Item.ObjectClassName, SPressMetadataMethodName]);
  Result := Result + 'begin' + SPressLineBreak;
  Result := Result + Format('  Result := %s;' + SPressLineBreak, [
   FormatMetadataStr]);
  Result := Result + 'end;' + SPressLineBreak + SPressLineBreak;
end;

function TPressCodeObjectBuilder.BuildPlainPropertyDeclaration(
  AAttr: TPressAttributeMetadataRegistry): string;
begin
  if not AAttr.RuntimeMetadata.AttributeClass.InheritsFrom(TPressItems) then
    Result := Format(
     '  property %0:s: %1:s read Get%0:s write Set%0:s;' + SPressLineBreak, [
     AAttr.Name, PressTypeToNativeType(AAttr)])
  else
    Result := '';
end;

function TPressCodeObjectBuilder.BuildSetterDeclaration(
  AAttr: TPressAttributeMetadataRegistry): string;
begin
  if not AAttr.RuntimeMetadata.AttributeClass.InheritsFrom(TPressItems) then
    Result := Format('  procedure Set%s(const AValue: %s);' + SPressLineBreak, [
     AAttr.Name, PressTypeToNativeType(AAttr)])
  else
    Result := '';
end;

function TPressCodeObjectBuilder.BuildSetterImplementation(
  AAttr: TPressAttributeMetadataRegistry): string;
var
  VAttrClass: TPressAttributeClass;
begin
  VAttrClass := AAttr.RuntimeMetadata.AttributeClass;
  if not VAttrClass.InheritsFrom(TPressItems) then
  begin
    Result := Format('procedure %s.Set%s(const AValue: %s);' + SPressLineBreak, [
     Item.ObjectClassName, AAttr.Name, PressTypeToNativeType(AAttr)]);
    Result := Result + 'begin' + SPressLineBreak +
     Format('  %s%s.Value := ', [SPressAttributePrefix, AAttr.Name]);
    if VAttrClass.InheritsFrom(TPressEnum) then
      Result := Result + 'Ord(AValue)'
    else
      Result := Result + 'AValue';
    Result := Result + ';' + SPressLineBreak + 'end;' + SPressLineBreak + SPressLineBreak;
  end else
    Result := '';
end;

procedure TPressCodeObjectBuilder.CheckAttributeList;
var
  VAttr: TPressAttributeMetadataRegistry;
  VIsContainer: Boolean;
  I: Integer;
begin
  if Assigned(FAttributeList) then
    Exit;
  FAttributeList := TStringList.Create;
  FAttributeList.Sorted := True;
  FHasPlainAttr := False;
  FHasContainerAttr := False;
  for I := 0 to Pred(Item.AttributeList.Count) do
  begin
    VAttr := Item.AttributeList[I];
    VIsContainer := VAttr.RuntimeMetadata.AttributeClass.InheritsFrom(TPressItems);
    if VIsContainer then
      FHasContainerAttr := True
    else
      FHasPlainAttr := True;
    FAttributeList.AddObject(VAttr.Name, VAttr);
  end;
end;

constructor TPressCodeObjectBuilder.Create(
  AItem: TPressObjectMetadataRegistry);
begin
  inherited Create;
  FItem := AItem;
end;

destructor TPressCodeObjectBuilder.Destroy;
begin
  FAttributeList.Free;
  inherited;
end;

function TPressCodeObjectBuilder.GetAttributeList(
  AIndex: Integer): TPressAttributeMetadataRegistry;
begin
  if not Assigned(FAttributeList) then
    CheckAttributeList;
  Result := TPressAttributeMetadataRegistry(FAttributeList.Objects[AIndex]);
end;

function TPressCodeObjectBuilder.PressTypeToNativeType(
  AAttribute: TPressAttributeMetadataRegistry): string;
begin
  case AAttribute.RuntimeMetadata.AttributeClass.AttributeBaseType of
    attString, attMemo, attBinary, attPicture:
      Result := 'string';
    attInteger:
      Result := 'Integer';
    attFloat:
      Result := 'Double';
    attCurrency:
      Result := 'Currency';
    attEnum: { TODO : Improve }
      Result := AAttribute.RuntimeMetadata.EnumMetadata.Name;
    attBoolean:
      Result := 'Boolean';
    attDate:
      Result := 'TDate';
    attTime:
      Result := 'TTime';
    attDateTime:
      Result := 'TDateTime';
    attVariant:
      Result := 'Variant';
    attPart, attReference:
      Result := AAttribute.RuntimeMetadata.ObjectClassName;
    else
      Result := '';
  end;
end;

{ TPressCodeObjectUpdates }

constructor TPressCodeObjectUpdates.Create(
  AItem: TPressObjectMetadataRegistry);
begin
  inherited Create;
  FItem := AItem;
end;

destructor TPressCodeObjectUpdates.Destroy;
begin
  FBuilder.Free;
  inherited;
end;

function TPressCodeObjectUpdates.GetBuilder: TPressCodeObjectBuilder;
begin
  if not Assigned(FBuilder) then
    FBuilder := TPressCodeObjectBuilder.Create(FItem);
  Result := FBuilder;
end;

function TPressCodeObjectUpdates.InternalGetItem: TPressProjectItem;
begin
  Result := FItem;
end;

procedure TPressCodeObjectUpdates.InternalProcessItem;
begin
  inherited;
  { TODO : Implement }
  AddCodeUpdate(UnitReader.Position, 0,
   Builder.BuildInterfaceSection + '***' + SPressLineBreak + SPressLineBreak +
   Builder.BuildImplementationSection + '***' + SPressLineBreak + SPressLineBreak +
   Builder.BuildInitializationSection + SPressLineBreak + '***' + SPressLineBreak + SPressLineBreak +
   Builder.BuildFinalizationSection);
end;

{ TPressCodeAttributeTypeUpdates }

constructor TPressCodeAttributeTypeUpdates.Create(
  AItem: TPressAttributeTypeRegistry);
begin
  inherited Create;
  FItem := AItem;
end;

function TPressCodeAttributeTypeUpdates.InternalGetItem: TPressProjectItem;
begin
  Result := FItem;
end;

procedure TPressCodeAttributeTypeUpdates.InternalProcessItem;
begin
  inherited;
  { TODO : Implement }
end;

{ TPressCodeEnumUpdates }

constructor TPressCodeEnumUpdates.Create(AItem: TPressEnumerationRegistry);
begin
  inherited Create;
  FItem := AItem;
end;

function TPressCodeEnumUpdates.InternalGetItem: TPressProjectItem;
begin
  Result := FItem;
end;

procedure TPressCodeEnumUpdates.InternalProcessItem;
begin
  inherited;
  { TODO : Implement }
end;

{ TPressCodeUpdater }

procedure TPressCodeUpdater.ClearProjectModules;
begin
  Project.ClearItems;
  ParsedModules.Clear;
  PressIDEInterface.ClearModules;
end;

constructor TPressCodeUpdater.Create(AProject: TPressProject);
begin
  inherited Create;
  FProject := AProject;
  FParsedModules := TInterfaceList.Create;
end;

function TPressCodeUpdater.CreateCodeUpdates(
  AItem: TPressProjectItem): TPressCodeUpdates;
begin
  if AItem is TPressObjectMetadataRegistry then
    Result :=
     TPressCodeObjectUpdates.Create(TPressObjectMetadataRegistry(AItem))
  else if AItem is TPressAttributeTypeRegistry then
    Result :=
     TPressCodeAttributeTypeUpdates.Create(TPressAttributeTypeRegistry(AItem))
  else if AItem is TPressEnumerationRegistry then
    Result :=
     TPressCodeEnumUpdates.Create(TPressEnumerationRegistry(AItem))
  else
    raise EPressDesignError.CreateFmt(
     SUnsupportedProjectItemClass, [AItem.ClassName]);
end;

destructor TPressCodeUpdater.Destroy;
begin
  PressIDEInterface.ClearModules;
  FParsedModules.Free;
  inherited;
end;

procedure TPressCodeUpdater.ExtractBODeclarations(AModule: TPressProjectModule;
  Reader: TPressPascalReader; AProc: TPressPascalProcDeclaration);

  function ExtractResultString(ABlock: TPressPascalBlockStatement): string;
  var
    VLastStatement: TPressPascalStatement;
  begin
    Result := '';
    VLastStatement := ABlock[Pred(ABlock.ItemCount)] as TPressPascalStatement;
    if VLastStatement is TPressPascalPlainStatement then
    begin
      Reader.Position := VLastStatement.StartPos;
      if SameText(Reader.ReadToken, SPressResultStr) and
       (Reader.ReadToken = ':=') then
      begin
        { TODO : Support something beyond a string constant? }
        Result := Reader.ReadNextToken;
        if (Result <> '') and
         (SameText(Result, 'concat') or (Result[1] = '''')) then
          Result := Reader.ReadConcatString;
      end;
    end;
  end;

  procedure ExtractBOMetadata(
    AMetadata: TPressObjectMetadataRegistry; ABlock: TPressPascalBlockStatement);

    function ExtractClassTypeName(AMetadataStr: string): string;
    var
      I, J: Integer;
    begin
      I := 1;
      while (Length(AMetadataStr) >= I) and (AMetadataStr[I] = ' ') do
        Inc(I);
      J := I;
      while (Length(AMetadataStr) >= J) and
       (AMetadataStr[J] in ['A'..'Z', 'a'..'z', '0', '9', '_']) do
        Inc(J);
      Result := Copy(AMetadataStr, I, J - I);
    end;

  var
    VMetadataStr: string;
    VClassTypeName: string;
  begin
    VMetadataStr := ExtractResultString(ABlock);
    VClassTypeName := AProc.Header.ClassTypeName;
    if (VMetadataStr <> '') and
     not SameText(ExtractClassTypeName(VMetadataStr), VClassTypeName) then
      raise EPressDesignError.CreateFmt(
       SClassNameAndMetadataMismatch, [VClassTypeName]);
    AMetadata.MetadataStr := VMetadataStr;
  end;

  procedure ExtractAttributeName(
    AType: TPressAttributeTypeRegistry; ABlock: TPressPascalBlockStatement);
  var
    VAttrName: string;
  begin
    VAttrName := ExtractResultString(ABlock);
    { TODO : Work around while the parser does not read complex statements }
    if VAttrName <> '' then
      AType.Name := VAttrName;
  end;

var
  VBlock: TPressPascalBlockStatement;
  VProjectClass: TPressProjectItem;
  VClassMethodName: string;
begin
  VBlock := AProc.Body.Block;
  VProjectClass := AModule.FindClass(AProc.Header.ClassTypeName);
  if Assigned(VProjectClass) then
  begin
    VProjectClass.DisableChanges;
    try
      VClassMethodName := AProc.Header.ClassMethodName;
      if (VProjectClass is TPressObjectMetadataRegistry) and
       SameText(VClassMethodName, SPressMetadataMethodName) then
        ExtractBOMetadata(TPressObjectMetadataRegistry(VProjectClass), VBlock)
      else if (VProjectClass is TPressAttributeTypeRegistry) and
       SameText(VClassMethodName, SPressAttributeNameMethodName) then
        ExtractAttributeName(TPressAttributeTypeRegistry(VProjectClass), VBlock);
    finally
      VProjectClass.EnableChanges;
    end;
  end;

  { TODO : Improve }
  ExtractEnumDeclarations(AModule, Reader, VBlock);

end;

procedure TPressCodeUpdater.ExtractClassDeclarations(
  AModule: TPressProjectModule; Reader: TPressPascalReader;
  ATypes: TPressPascalTypesDeclaration);

  function PressClassByName(const AClassName: string): TPressProjectClass;

    function FindBOClass(var AClass: TPressProjectClass): Boolean;
    var
      VClass: TPressObjectClass;
    begin
      VClass := PressModel.FindClass(AClassName);
      if Assigned(VClass) then
        if VClass.InheritsFrom(TPressQuery) then
          AClass := Project.RootQueryClasses
        else
          AClass := Project.RootPersistentClasses
      else
        AClass := nil;
      Result := Assigned(AClass);
    end;

    function FindAttributeClass(var AClass: TPressProjectClass): Boolean;
    var
      VAttributeClass: TPressAttributeClass;
      VItems: TPressProjectClassReferences;
    begin
      VAttributeClass := PressModel.FindAttributeClass(AClassName);
      Result := Assigned(VAttributeClass);
      if Result then
      begin
        VItems := Project.RootUserAttributes.ChildItems;
        AClass := TPressProjectClass(VItems.FindItem(
         VAttributeClass.AttributeName, TPressAttributeTypeRegistry));
        if not Assigned(AClass) then
        begin
          AClass := VItems.Add;
          AClass.ObjectClassName := VAttributeClass.ClassName;
          AClass.Name := VAttributeClass.AttributeName;
        end;
      end;
    end;

    function FindMVPClass(var AClass: TPressProjectClass): Boolean;

      function IsMVP(const ASuffix: string): Boolean;
      begin
        Result :=
         SameText(Copy(AClassName, 1, 9), 'TPressMVP') and
         SameText(Copy(AClassName, Length(AClassName) - Length(ASuffix) + 1,
         Length(ASuffix)), ASuffix);
      end;

    begin
      if IsMVP('Model') then
        AClass := Project.RootModels
      else if IsMVP('View') then
        AClass := Project.RootViews
      else if IsMVP('Presenter') then
        AClass := Project.RootPresenters
      else if IsMVP('Command') then
        AClass := Project.RootCommands
      else if IsMVP('Interactor') then
        AClass := Project.RootInteractors
      else
        AClass := nil;
      Result := Assigned(AClass);
    end;

    function FindChildItem(
      AItems: TPressProjectClassReferences): TPressProjectClass;
    begin
      Result := TPressProjectClass(
       AItems.FindItem(AClassName, TPressProjectClass, False));
      if not Assigned(Result) then
      begin
        Result := AItems.Add;
        Result.ObjectClassName := AClassName;
      end;
    end;

  begin
    if FindBOClass(Result) then
      //
    else if FindAttributeClass(Result) then
      //
    else if SameText(AClassName, SPressOIDGeneratorClassNameStr) then
      Result := Project.RootUserGenerators
    else if SameText(AClassName, SPressFormClassNameStr) then
      Result := Project.RootForms
    else if SameText(AClassName, SPressFrameClassNameStr) then
      Result := Project.RootFrames
    else if FindMVPClass(Result) then
      //
    else
      Result := Project.RootUnknownClasses;
    if not SameText(Result.ObjectClassName, AClassName) then
      Result := FindChildItem(Result.ChildItems);
  end;

  function FindClassFromModules(const AClassName: string;
    AModules: array of TPressProjectModule): TPressProjectClass;
  var
    I: Integer;
  begin
    for I := 0 to Pred(Length(AModules)) do
    begin
      Result := AModules[I].FindClass(AClassName);
      if Assigned(Result) then
        Exit;
    end;
    Result := nil;
  end;

  function ClassDeclarationByName(const AClassName: string): TPressProjectClass;
  begin
    Result := FindClassFromModules(AClassName, [AModule]);
    if not Assigned(Result) then
    begin
      Result := FindClassFromModules(AClassName, AModule.IntfUses);
      if not Assigned(Result) then
      begin
        Result := FindClassFromModules(AClassName, AModule.ImplUses);
        if not Assigned(Result) then
          Result := PressClassByName(AClassName);
      end;
    end;
  end;

var
  VClassDecl: TPressPascalClassType;
  VParentClass: TPressProjectClass;
  VClass: TPressProjectClass;
  I: Integer;
begin
  for I := 0 to Pred(ATypes.ItemCount) do
    if ATypes[I] is TPressPascalClassType then
    begin
      VClassDecl := TPressPascalClassType(ATypes[I]);
      VParentClass := ClassDeclarationByName(VClassDecl.ParentName);
      VParentClass.DisableChanges;
      try
        VClass := VParentClass.ChildItems.Add as TPressProjectClass;
        VClass.DisableChanges;
        try
          VClass.ObjectClassName := VClassDecl.Name;
          VClass.ParentClass := VParentClass;
          VClass.Module := AModule;
          AModule.Items.Add(VClass);
        finally
          VClass.EnableChanges;
        end;
      finally
        VParentClass.EnableChanges;
      end;
    end;
end;

procedure TPressCodeUpdater.ExtractEnumDeclarations(
  AModule: TPressProjectModule; Reader: TPressPascalReader;
  AItems: TPressPascalObject);

  procedure CheckEnumRegistration(AStatement: TPressPascalPlainStatement);
  begin
    Reader.Position := AStatement.StartPos;
    if (Reader.ReadToken <> '') and (Reader.ReadToken = '.') and
     SameText(Reader.ReadToken, SPressRegisterEnumMethodName) and
     (Reader.ReadToken = '(') and SameText(Reader.ReadToken, 'typeinfo') and
     (Reader.ReadToken = '(') and (Reader.ReadToken <> '') and
     (Reader.ReadToken = ')') and (Reader.ReadToken = ',') then
      Project.RootUserEnumerations.ChildItems.Add.Name :=
       Reader.ReadUnquotedString;
  end;

var
  I: Integer;
begin
  for I := 0 to Pred(AItems.ItemCount) do
    if AItems[I] is TPressPascalPlainStatement then
      CheckEnumRegistration(TPressPascalPlainStatement(AItems[I]));
end;

procedure TPressCodeUpdater.ExtractMVPDeclarations(AModule: TPressProjectModule;
  Reader: TPressPascalReader; AProc: TPressPascalProcDeclaration);
begin
  { TODO : Implement }
end;

function TPressCodeUpdater.ParseModule(
  AModuleIntf: IPressIDEModule): TPressProjectModule;

  function ReadUnitList(
    AUses: TPressPascalUsesDeclaration): TPressProjectModuleArray;
  var
    VModuleIntf: IPressIDEModule;
    VUsedUnitCount: Integer;
    I, J: Integer;
  begin
    if Assigned(AUses) then
      VUsedUnitCount := AUses.UsedUnitCount
    else
      VUsedUnitCount := 0;
    SetLength(Result, VUsedUnitCount);
    if VUsedUnitCount > 0 then
    begin
      J := 0;
      for I := 0 to Pred(VUsedUnitCount) do
      begin
        { TODO : Check circular references }
        VModuleIntf := PressIDEInterface.FindModule(AUses.UsedUnit[I].UnitName);
        if Assigned(VModuleIntf) then
        begin
          Result[J] := ParseModule(VModuleIntf);
          Inc(J);
        end;
      end;
      SetLength(Result, J);
    end;
  end;

  procedure ReadInterfaceSection(AModule: TPressProjectModule;
    Reader: TPressPascalReader; ASection: TPressPascalInterfaceSection);
  var
    I: Integer;
  begin
    for I := 0 to Pred(ASection.ItemCount) do
      if ASection[I] is TPressPascalTypesDeclaration then
        ExtractClassDeclarations(
         AModule, Reader, TPressPascalTypesDeclaration(ASection[I]));
  end;

  procedure ReadImplementationSection(AModule: TPressProjectModule;
    Reader: TPressPascalReader; ASection: TPressPascalImplementationSection);
  var
    VProc: TPressPascalProcDeclaration;
    I: Integer;
  begin
    for I := 0 to Pred(ASection.ItemCount) do
      if ASection[I] is TPressPascalProcDeclaration then
      begin
        VProc := TPressPascalProcDeclaration(ASection[I]);
        if Assigned(VProc.Header) and Assigned(VProc.Body) and
         Assigned(VProc.Body.Block) then
        begin
          ExtractBODeclarations(AModule, Reader, VProc);
          ExtractMVPDeclarations(AModule, Reader, VProc);
        end;
      end else if (ASection[I] is TPressPascalTypesDeclaration) then
        ExtractClassDeclarations(
         AModule, Reader, TPressPascalTypesDeclaration(ASection[I]));
  end;

  procedure ReadInitializationSection(AModule: TPressProjectModule;
    Reader: TPressPascalReader; ASection: TPressPascalInitializationSection);
  begin
    if Assigned(ASection) then
      ExtractEnumDeclarations(AModule, Reader, ASection);
  end;

var
  VReader: TPressPascalReader;
  VUnit: TPressPascalUnit;
  VModule: TPressProjectModule;
  VIntfUses, VImplUses: TPressProjectModuleArray;
begin
  SetLength(VIntfUses, 0);
  SetLength(VImplUses, 0);
  VModule := Project.Modules.FindModule(AModuleIntf);
  if not Assigned(VModule) then
  begin
    VModule := Project.Modules.Add;
    VModule.ModuleIntf := AModuleIntf;
  end;
  if ParsedModules.IndexOf(AModuleIntf) = -1 then
  begin
    VModule.DisableChanges;
    try
      VReader := TPressPascalReader.Create(AModuleIntf.SourceCode);
      VUnit := TPressPascalUnit.Create(nil);
      try
        VUnit.Read(VReader);
        VIntfUses := ReadUnitList(VUnit.InterfaceSection.UsesDeclaration);
        VModule.IntfUses := VIntfUses;
        ReadInterfaceSection(VModule, VReader, VUnit.InterfaceSection);
        ParsedModules.Add(AModuleIntf);
        VImplUses := ReadUnitList(VUnit.ImplementationSection.UsesDeclaration);
        VModule.ImplUses := VImplUses;
        ReadImplementationSection(VModule, VReader, VUnit.ImplementationSection);
        ReadInitializationSection(VModule, VReader, VUnit.InitializationSection);
      finally
        VUnit.Free;
        VReader.Free;
      end;
    finally
      VModule.EnableChanges;
    end;
  end;
  Result := VModule;
end;

procedure TPressCodeUpdater.StoreProjectItem(AItem: TPressProjectItem);
var
  VUpdates: TPressCodeUpdates;
  VUpdate: TPressCodeUpdate;
  VModuleIntf: IPressIDEModule;
  I: Integer;
begin
  VUpdates := CreateCodeUpdates(AItem);
  try
    VUpdates.ProcessItem;
    if VUpdates.Count > 0 then
    begin
      VModuleIntf := AItem.Module.ModuleIntf;
      VModuleIntf.StartEdition;
      try
        for I := 0 to Pred(VUpdates.Count) do
        begin
          VUpdate := VUpdates[I];
          VModuleIntf.SetPosition(VUpdate.Position);
          if VUpdate.DeleteCount > 0 then
            VModuleIntf.DeleteText(VUpdate.DeleteCount);
          if VUpdate.InsertText <> '' then
            VModuleIntf.InsertText(VUpdate.InsertText);
        end;
        VModuleIntf.FinishEdition(True);
      except
        VModuleIntf.FinishEdition(False);
        raise;
      end;
    end;
  finally
    VUpdates.Free;
  end;
end;

end.
