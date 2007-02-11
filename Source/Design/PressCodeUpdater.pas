(*
  PressObjects, Code Updater
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
  PressClasses,
  PressPascal,
  PressIDEIntf;

type
  TPressClassDeclarationList = class;

  TPressClassDeclaration = class(TObject)
  private
    FDisplayName: string;
    FMetadata: string;
    FModule: IPressIDEModule;
    FName: string;
    FParent: TPressClassDeclaration;
    FSubClasses: TPressClassDeclarationList;
    procedure SetParent(AValue: TPressClassDeclaration);
  public
    constructor Create(AModule: IPressIDEModule; AName: string; AParent: TPressClassDeclaration);
    destructor Destroy; override;
    property DisplayName: string read FDisplayName;
    property Metadata: string read FMetadata;
    property Name: string read FName;
    property Parent: TPressClassDeclaration read FParent write SetParent;
    property SubClasses: TPressClassDeclarationList read FSubClasses;
  end;

  TPressClassDeclarationIterator = class;

  TPressClassDeclarationList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressClassDeclaration;
    procedure SetItems(AIndex: Integer; const Value: TPressClassDeclaration);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressClassDeclaration): Integer;
    function CreateIterator: TPressClassDeclarationIterator;
    function Extract(AObject: TPressClassDeclaration): TPressClassDeclaration;
    function FindClass(AClassName: string): TPressClassDeclaration;
    function FindClassByDisplayName(ADisplayName: string): TPressClassDeclaration;
    function First: TPressClassDeclaration;
    function IndexOf(AObject: TPressClassDeclaration): Integer;
    procedure Insert(AIndex: Integer; AObject: TPressClassDeclaration);
    function Last: TPressClassDeclaration;
    function Remove(AObject: TPressClassDeclaration): Integer;
    property Items[AIndex: Integer]: TPressClassDeclaration read GetItems write SetItems; default;
  end;

  TPressClassDeclarationIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressClassDeclaration;
  public
    property CurrentItem: TPressClassDeclaration read GetCurrentItem;
  end;

  TPressClassType = (ctBusiness, ctMVP);

  TPressClassTypes = set of TPressClassType;

  TPressCodeUpdater = class(TObject)
  private
    FClasses: TPressClassDeclarationList;
    FEnumMetadatas: TStrings;
    procedure ExtractBODeclarations(Reader: TPressPascalReader; AProc: TPressPascalProcDeclaration);
    procedure ExtractClassDeclarations(AModule: IPressIDEModule; Reader: TPressPascalReader; ATypes: TPressPascalTypesDeclaration);
    procedure ExtractMVPDeclarations(Reader: TPressPascalReader; AProc: TPressPascalProcDeclaration);
  protected
    function ModuleImplements(AModule: IPressIDEModule; AClassTypes: TPressClassTypes): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ParseBusinessClasses;
    procedure ParseModule(AModule: IPressIDEModule; AClassTypes: TPressClassTypes = [ctBusiness, ctMVP]);
    procedure ParseMVPClasses;
    procedure ParseProject(AClassTypes: TPressClassTypes);
    property Classes: TPressClassDeclarationList read FClasses;
    property EnumMetadatas: TStrings read FEnumMetadatas;
  end;

implementation

uses
  SysUtils,
  PressConsts,
  PressDesignConsts;

{ TPressClassDeclaration }

constructor TPressClassDeclaration.Create(AModule: IPressIDEModule;
  AName: string; AParent: TPressClassDeclaration);
begin
  inherited Create;
  FModule := AModule;
  FName := AName;
  FDisplayName := AName;
  FParent := AParent;
  FSubClasses := TPressClassDeclarationList.Create(True);
  Parent := AParent;
end;

destructor TPressClassDeclaration.Destroy;
begin
  FSubClasses.Free;
  inherited;
end;

procedure TPressClassDeclaration.SetParent(AValue: TPressClassDeclaration);
begin
  if Assigned(FParent) then
    FParent.SubClasses.Extract(Self);
  if Assigned(AValue) then
    AValue.SubClasses.Add(Self);
  FParent := AValue;
end;

{ TPressClassDeclarationList }

function TPressClassDeclarationList.Add(
  AObject: TPressClassDeclaration): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressClassDeclarationList.CreateIterator: TPressClassDeclarationIterator;
begin
  Result := TPressClassDeclarationIterator.Create(Self);
end;

function TPressClassDeclarationList.Extract(
  AObject: TPressClassDeclaration): TPressClassDeclaration;
begin
  Result := inherited Extract(AObject) as TPressClassDeclaration;
end;

function TPressClassDeclarationList.FindClass(
  AClassName: string): TPressClassDeclaration;
var
  I: Integer;
begin
  for I := 0 to Pred(Count) do
  begin
    Result := Items[I];
    if SameText(Result.Name, AClassName) then
      Exit;
    Result := Result.SubClasses.FindClass(AClassName);
    if Assigned(Result) then
      Exit;
  end;
  Result := nil;
end;

function TPressClassDeclarationList.FindClassByDisplayName(
  ADisplayName: string): TPressClassDeclaration;
var
  I: Integer;
begin
  for I := 0 to Pred(Count) do
  begin
    Result := Items[I];
    if SameText(Result.DisplayName, ADisplayName) then
      Exit;
    Result := Result.SubClasses.FindClassByDisplayName(ADisplayName);
    if Assigned(Result) then
      Exit;
  end;
  Result := nil;
end;

function TPressClassDeclarationList.First: TPressClassDeclaration;
begin
  Result := inherited First as TPressClassDeclaration;
end;

function TPressClassDeclarationList.GetItems(
  AIndex: Integer): TPressClassDeclaration;
begin
  Result := inherited Items[AIndex] as TPressClassDeclaration;
end;

function TPressClassDeclarationList.IndexOf(
  AObject: TPressClassDeclaration): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressClassDeclarationList.Insert(
  AIndex: Integer; AObject: TPressClassDeclaration);
begin
  inherited Insert(AIndex, AObject);
end;

function TPressClassDeclarationList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressClassDeclarationList.Last: TPressClassDeclaration;
begin
  Result := inherited Last as TPressClassDeclaration;
end;

function TPressClassDeclarationList.Remove(
  AObject: TPressClassDeclaration): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressClassDeclarationList.SetItems(
  AIndex: Integer; const Value: TPressClassDeclaration);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressClassDeclarationIterator }

function TPressClassDeclarationIterator.GetCurrentItem: TPressClassDeclaration;
begin
  Result := inherited CurrentItem as TPressClassDeclaration;
end;

{ TPressCodeUpdater }

constructor TPressCodeUpdater.Create;
begin
  inherited Create;
  FClasses := TPressClassDeclarationList.Create(True);
  FEnumMetadatas := TStringList.Create;
end;

destructor TPressCodeUpdater.Destroy;
begin
  FEnumMetadatas.Free;
  FClasses.Free;
  inherited;
end;

procedure TPressCodeUpdater.ExtractBODeclarations(
  Reader: TPressPascalReader; AProc: TPressPascalProcDeclaration);

  function ExtractResultString(ABlock: TPressPascalBlockStatement): string;
  var
    VLastStatement: TPressPascalStatement;
  begin
    VLastStatement := ABlock[Pred(ABlock.ItemCount)] as TPressPascalStatement;
    if VLastStatement is TPressPascalPlainStatement then
    begin
      Reader.Position := VLastStatement.StartPos;
      if SameText(Reader.ReadToken, SPressResultStr) and
       (Reader.ReadToken = ':=') then
        Result := Reader.ReadConcatString;
    end;
  end;

  procedure ExtractBOMetadata(
    AClass: TPressClassDeclaration; ABlock: TPressPascalBlockStatement);

    function ExtractClassTypeName(AMetadata: string): string;
    var
      I, J: Integer;
    begin
      I := 1;
      while (Length(AMetadata) >= I) and (AMetadata[I] = ' ') do
        Inc(I);
      J := I;
      while (Length(AMetadata) >= J) and
       (Upcase(AMetadata[J]) in ['A'..'Z', '_']) do
        Inc(J);
      Result := Copy(AMetadata, I, J - I);
    end;

  var
    VMetadata: string;
    VClassTypeName: string;
  begin
    VMetadata := ExtractResultString(ABlock);
    VClassTypeName := AProc.Header.ClassTypeName;
    if (VMetadata <> '') and
     not SameText(ExtractClassTypeName(VMetadata), VClassTypeName) then
      raise EPressError.CreateFmt(
       SClassNameAndMetadataMismatch, [VClassTypeName]);
    AClass.FMetadata := VMetadata;  // friend class
  end;

  procedure ExtractAttributeName(
    AClassDecl: TPressClassDeclaration; ABlock: TPressPascalBlockStatement);
  var
    VAttrName: string;
  begin
    VAttrName := ExtractResultString(ABlock);

    { TODO : Work around while the parser does not read statements like if }
    if VAttrName <> '' then

      AClassDecl.FDisplayName := VAttrName;  // friend class
  end;

  procedure CheckEnumRegistration(AStatement: TPressPascalPlainStatement);
  begin
    Reader.Position := AStatement.StartPos;
    if (Reader.ReadToken <> '') and (Reader.ReadToken = '.') and
     SameText(Reader.ReadToken, SPressRegisterEnumMethodName) and
     (Reader.ReadToken = '(') and SameText(Reader.ReadToken, 'typeinfo') and
     (Reader.ReadToken = '(') and (Reader.ReadToken <> '') and
     (Reader.ReadToken = ')') and (Reader.ReadToken = ',') then
      EnumMetadatas.Add(Reader.ReadUnquotedString);
  end;

var
  VBlock: TPressPascalBlockStatement;
  VClass: TPressClassDeclaration;
  VClassMethodName: string;
  I: Integer;
begin
  VBlock := AProc.Body.Block;
  VClass := Classes.FindClass(AProc.Header.ClassTypeName);
  if Assigned(VClass) then
  begin
    VClassMethodName := AProc.Header.ClassMethodName;
    if SameText(VClassMethodName, SPressMetadataMethodName) then
      ExtractBOMetadata(VClass, VBlock)
    else if SameText(VClassMethodName, SPressAttributeNameMethodName) then
      ExtractAttributeName(VClass, VBlock);
  end;
  for I := 0 to Pred(VBlock.ItemCount) do
    if VBlock[I] is TPressPascalPlainStatement then
      CheckEnumRegistration(TPressPascalPlainStatement(VBlock[I]));
end;

procedure TPressCodeUpdater.ExtractClassDeclarations(AModule: IPressIDEModule;
  Reader: TPressPascalReader; ATypes: TPressPascalTypesDeclaration);
var
  VClassDecl: TPressPascalClassType;
  VClass, VParentClass: TPressClassDeclaration;
  I: Integer;
begin
  for I := 0 to Pred(ATypes.ItemCount) do
    if ATypes[I] is TPressPascalClassType then
    begin
      VClassDecl := TPressPascalClassType(ATypes[I]);
      VParentClass := Classes.FindClass(VClassDecl.ParentName);
      if not Assigned(VParentClass) then
      begin
        VParentClass :=
         TPressClassDeclaration.Create(AModule, VClassDecl.ParentName, nil);
        Classes.Add(VParentClass);
      end;
      VClass := Classes.FindClass(VClassDecl.Name);
      if Assigned(VClass) then
      begin
        Classes.Extract(VClass);
        VClass.Parent := VParentClass;
      end else
        TPressClassDeclaration.Create(AModule, VClassDecl.Name, VParentClass);
    end;
end;

procedure TPressCodeUpdater.ExtractMVPDeclarations(
  Reader: TPressPascalReader; AProc: TPressPascalProcDeclaration);
begin
  { TODO : Implement }
end;

function TPressCodeUpdater.ModuleImplements(AModule: IPressIDEModule;
  AClassTypes: TPressClassTypes): Boolean;
begin
  { TODO : Implement }
  Result := True;
end;

procedure TPressCodeUpdater.ParseBusinessClasses;
begin
  ParseProject([ctBusiness]);
end;

procedure TPressCodeUpdater.ParseModule(
  AModule: IPressIDEModule; AClassTypes: TPressClassTypes);

  procedure ReadInterfaceSection(
    Reader: TPressPascalReader; ASection: TPressPascalInterfaceSection);
  var
    I: Integer;
  begin
    for I := 0 to Pred(ASection.ItemCount) do
      if ASection[I] is TPressPascalTypesDeclaration then
        ExtractClassDeclarations(
         AModule, Reader, TPressPascalTypesDeclaration(ASection[I]));
  end;

  procedure ReadImplementationSection(
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
          if ctBusiness in AClassTypes then
            ExtractBODeclarations(Reader, VProc);
          if ctMVP in AClassTypes then
            ExtractMVPDeclarations(Reader, VProc);
        end;
      end else if (ASection[I] is TPressPascalTypesDeclaration) then
        ExtractClassDeclarations(
         AModule, Reader, TPressPascalTypesDeclaration(ASection[I]));
  end;

var
  VReader: TPressPascalReader;
  VUnit: TPressPascalUnit;
begin
  VReader := TPressPascalReader.Create(AModule.SourceCode);
  VUnit := TPressPascalUnit.Create(nil);
  try
    VUnit.Read(VReader);
    ReadInterfaceSection(VReader, VUnit.InterfaceSection);
    ReadImplementationSection(VReader, VUnit.ImplementationSection);
  finally
    VUnit.Free;
    VReader.Free;
  end;
end;

procedure TPressCodeUpdater.ParseMVPClasses;
begin
  ParseProject([ctMVP]);
end;

procedure TPressCodeUpdater.ParseProject(AClassTypes: TPressClassTypes);
var
  VModuleNames: TStrings;
  VModule: IPressIDEModule;
  I: Integer;
begin
  if ctBusiness in AClassTypes then
  begin
    Classes.Clear;
    EnumMetadatas.Clear;
  end;
  VModuleNames := TStringList.Create;
  try
    PressIDEInterface.ProjectModuleNames(VModuleNames);
    for I := 0 to Pred(VModuleNames.Count) do
    begin
      VModule := PressIDEInterface.ProjectModuleByName(VModuleNames[I]);
      if ModuleImplements(VModule, AClassTypes) then
        ParseModule(VModule, AClassTypes);
    end;
  finally
    VModuleNames.Free;
  end;
end;

end.
