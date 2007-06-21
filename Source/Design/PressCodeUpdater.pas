(*
  PressObjects, Code Updater Class
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
  PressPascal,
  PressIDEIntf,
  PressProjectModel;

type
  TPressCodeUpdater = class(TObject)
  private
    FParsedModules: TInterfaceList;
    FProject: TPressProject;
  protected
    procedure ExtractBODeclarations(AModule: TPressProjectModule; Reader: TPressPascalReader; AProc: TPressPascalProcDeclaration);
    procedure ExtractClassDeclarations(AModule: TPressProjectModule; Reader: TPressPascalReader; ATypes: TPressPascalTypesDeclaration);
    procedure ExtractMVPDeclarations(AModule: TPressProjectModule; Reader: TPressPascalReader; AProc: TPressPascalProcDeclaration);
    property ParsedModules: TInterfaceList read FParsedModules;
    property Project: TPressProject read FProject;
  public
    constructor Create(AProject: TPressProject);
    destructor Destroy; override;
    procedure ClearProjectModules;
    function ParseModule(AModuleIntf: IPressIDEModule): TPressProjectModule;
  end;

implementation

uses
  SysUtils,
  PressClasses,
  PressConsts,
  PressSubject,
  PressDesignConsts;

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
      raise EPressError.CreateFmt(
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
  VBlock: TPressPascalBlockStatement;
  VProjectClass: TPressProjectItem;
  VClassMethodName: string;
  I: Integer;
begin
  VBlock := AProc.Body.Block;
  VProjectClass := AModule.FindClass(AProc.Header.ClassTypeName);
  if Assigned(VProjectClass) then
  begin
    VClassMethodName := AProc.Header.ClassMethodName;
    if (VProjectClass is TPressObjectMetadataRegistry) and
     SameText(VClassMethodName, SPressMetadataMethodName) then
      ExtractBOMetadata(TPressObjectMetadataRegistry(VProjectClass), VBlock)
    else if (VProjectClass is TPressAttributeTypeRegistry) and
     SameText(VClassMethodName, SPressAttributeNameMethodName) then
      ExtractAttributeName(TPressAttributeTypeRegistry(VProjectClass), VBlock);
  end;

  { TODO : Improve }
  for I := 0 to Pred(VBlock.ItemCount) do
    if VBlock[I] is TPressPascalPlainStatement then
      CheckEnumRegistration(TPressPascalPlainStatement(VBlock[I]));

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
      VClass := VParentClass.ChildItems.Add as TPressProjectClass;
      VClass.ObjectClassName := VClassDecl.Name;
      VClass.ParentClass := VParentClass;
      AModule.Items.Add(VClass);
    end;
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
    finally
      VUnit.Free;
      VReader.Free;
    end;
  end;
  Result := VModule;
end;

end.
