(*
  PressObjects, Façade and Runtime declarations
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressFacade;

{$I Press.inc}

interface

uses
  Classes,
  PressSubject,
  PressAttributes,
  PressProjectModel,
  PressCodeUpdater;

type
  TPressRuntimeEnum = (reRuntime);

  TPressRuntimeAttributeMetadata = class(TPressAttributeMetadata)
  private
    FRealAttributeName: string;
    FRealObjectClassName: string;
  public
    function GetAttributeName: string; override;
    function GetObjectClassName: string; override;
    procedure SetAttributeName(const Value: string); override;
    procedure SetObjectClassName(const Value: string); override;
  end;

  TPressRuntimeQueryAttributeMetadata = class(TPressQueryAttributeMetadata)
  private
    FRealAttributeName: string;
    FRealObjectClassName: string;
  public
    function GetAttributeName: string; override;
    function GetObjectClassName: string; override;
    procedure SetAttributeName(const Value: string); override;
    procedure SetObjectClassName(const Value: string); override;
  end;

  TPressRuntimeObjectMetadata = class(TPressObjectMetadata)
  public
    function InternalAttributeMetadataClass: TPressAttributeMetadataClass; override;
  end;

  TPressRuntimeQueryMetadata = class(TPressQueryMetadata)
  public
    function InternalAttributeMetadataClass: TPressAttributeMetadataClass; override;
  end;

  TPressRuntimeObject = class(TPressObject)
  public
    class function ObjectMetadataClass: TPressObjectMetadataClass; override;
  end;

  TPressRuntimeQuery = class(TPressQuery)
  public
    class function ObjectMetadataClass: TPressObjectMetadataClass; override;
  end;

  TPressRuntimeParts = class(TPressParts)
  public
    class function ValidObjectClass: TPressObjectClass; override;
  end;

  TPressRuntimeReferences = class(TPressReferences)
  public
    class function ValidObjectClass: TPressObjectClass; override;
  end;

  TPressRuntimeBOModel = class(TPressModel)
  private
    FProject: TPressProject;
  protected
    function InternalFindAttribute(const AAttributeName: string): TPressAttributeClass; override;
    function InternalFindClass(const AClassName: string): TPressObjectClass; override;
    function InternalParentMetadataOf(AMetadata: TPressObjectMetadata): TPressObjectMetadata; override;
    property Project: TPressProject read FProject;
  public
    constructor Create(AProject: TPressProject); reintroduce;
    procedure ClearMetadatas;
  end;

  TPressRuntimeMVPModel = class(TObject)
  { TODO : Implement core MVPModel and MVPMetadata }
  private
    FProject: TPressProject;
  protected
    property Project: TPressProject read FProject;
  public
    constructor Create(AProject: TPressProject); reintroduce;
  end;

  TPressFacade = class(TObject)
  private
    FBOModel: TPressRuntimeBOModel;
    FCodeUpdater: TPressCodeUpdater;
    FMVPModel: TPressRuntimeMVPModel;
    FProject: TPressProject;
  protected
    property BOModel: TPressRuntimeBOModel read FBOModel;
    property MVPModel: TPressRuntimeMVPModel read FMVPModel;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ParseProject;
    property CodeUpdater: TPressCodeUpdater read FCodeUpdater;
    property Project: TPressProject read FProject;
  end;

function PressDesignFacade: TPressFacade;

implementation

uses
  SysUtils,
  PressIDEIntf;

var
  _PressDesignFacade: TPressFacade;

function PressDesignFacade: TPressFacade;
begin
  Result := _PressDesignFacade;
end;

{ TPressRuntimeAttributeMetadata }

function TPressRuntimeAttributeMetadata.GetAttributeName: string;
begin
  Result := FRealAttributeName;
end;

function TPressRuntimeAttributeMetadata.GetObjectClassName: string;
begin
  Result := FRealObjectClassName;
end;

procedure TPressRuntimeAttributeMetadata.SetAttributeName(const Value: string);
begin
  inherited;
  FRealAttributeName := Value;
end;

procedure TPressRuntimeAttributeMetadata.SetObjectClassName(
  const Value: string);
begin
  inherited;
  FRealObjectClassName := Value;
end;

{ TPressRuntimeQueryAttributeMetadata }

function TPressRuntimeQueryAttributeMetadata.GetAttributeName: string;
begin
  Result := FRealAttributeName;
end;

function TPressRuntimeQueryAttributeMetadata.GetObjectClassName: string;
begin
  Result := FRealObjectClassName;
end;

procedure TPressRuntimeQueryAttributeMetadata.SetAttributeName(
  const Value: string);
begin
  inherited;
  FRealAttributeName := Value;
end;

procedure TPressRuntimeQueryAttributeMetadata.SetObjectClassName(
  const Value: string);
begin
  inherited;
  FRealObjectClassName := Value;
end;

{ TPressRuntimeObjectMetadata }

function TPressRuntimeObjectMetadata.InternalAttributeMetadataClass: TPressAttributeMetadataClass;
begin
  Result := TPressRuntimeAttributeMetadata;
end;

{ TPressRuntimeQueryMetadata }

function TPressRuntimeQueryMetadata.InternalAttributeMetadataClass: TPressAttributeMetadataClass;
begin
  Result := TPressRuntimeQueryAttributeMetadata;
end;

{ TPressRuntimeObject }

class function TPressRuntimeObject.ObjectMetadataClass: TPressObjectMetadataClass;
begin
  Result := TPressRuntimeObjectMetadata;
end;

{ TPressRuntimeQuery }

class function TPressRuntimeQuery.ObjectMetadataClass: TPressObjectMetadataClass;
begin
  Result := TPressRuntimeQueryMetadata;
end;

{ TPressRuntimeParts }

class function TPressRuntimeParts.ValidObjectClass: TPressObjectClass;
begin
  Result := TPressRuntimeObject;
end;

{ TPressRuntimeReferences }

class function TPressRuntimeReferences.ValidObjectClass: TPressObjectClass;
begin
  Result := TPressRuntimeObject;
end;

{ TPressRuntimeBOModel }

procedure TPressRuntimeBOModel.ClearMetadatas;
begin
  Metadatas.Clear;
  EnumMetadatas.Clear;
end;

constructor TPressRuntimeBOModel.Create(AProject: TPressProject);
begin
  inherited Create;
  FProject := AProject;
end;

function TPressRuntimeBOModel.InternalFindAttribute(
  const AAttributeName: string): TPressAttributeClass;
var
  VClass: TPressProjectClass;
begin
  Result := PressModel.FindAttribute(AAttributeName);
  if not Assigned(Result) then
  begin
    VClass := TPressProjectClass(
     Project.RootUserAttributes.ChildItems.FindItem(
     AAttributeName, TPressProjectClass));
    if Assigned(VClass) then
    begin
      while Assigned(VClass.ParentClass) do
        VClass := VClass.ParentClass;
      if SameText(VClass.ObjectClassName, TPressParts.ClassName) then
        Result := TPressRuntimeParts
      else if SameText(VClass.ObjectClassName, TPressReferences.ClassName) then
        Result := TPressRuntimeReferences
      else
        Result := PressModel.FindAttributeClass(VClass.ObjectClassName);
    end;
  end;
end;

function TPressRuntimeBOModel.InternalFindClass(
  const AClassName: string): TPressObjectClass;
var
  VClass: TPressProjectClass;
begin
  Result := PressModel.FindClass(AClassName);
  if not Assigned(Result) then
  begin
    VClass := TPressProjectClass(
     Project.RootBusinessClasses.ChildItems.FindItem(
     AClassName, TPressProjectClass));
    if Assigned(VClass) then
    begin
      while Assigned(VClass.ParentClass) do
        VClass := VClass.ParentClass;
      if SameText(VClass.ObjectClassName, TPressObject.ClassName) then
        Result := TPressRuntimeObject
      else if SameText(VClass.ObjectClassName, TPressQuery.ClassName) then
        Result := TPressRuntimeQuery
      else
        Result := PressModel.FindClass(VClass.ObjectClassName);
    end;
  end;
end;

function TPressRuntimeBOModel.InternalParentMetadataOf(
  AMetadata: TPressObjectMetadata): TPressObjectMetadata;
var
  VClass: TPressProjectClass;
begin
  VClass := TPressProjectClass(Project.RootBusinessClasses.ChildItems.FindItem(
   AMetadata.ObjectClassName, TPressProjectClass));
  if Assigned(VClass) and Assigned(VClass.ParentClass) then
    if Assigned(VClass.ParentClass.ParentClass) then
      Result := MetadataByName(VClass.ParentClass.ObjectClassName)
    else
      Result := PressModel.ClassByName(
       VClass.ParentClass.ObjectClassName).ClassMetadata
  else
    Result := PressModel.ParentMetadataOf(AMetadata);
end;

{ TPressRuntimeMVPModel }

constructor TPressRuntimeMVPModel.Create(AProject: TPressProject);
begin
  inherited Create;
  FProject := AProject;
end;

{ TPressFacade }

constructor TPressFacade.Create;
begin
  inherited Create;
  FProject := TPressProject.Create;
  FBOModel := TPressRuntimeBOModel.Create(FProject);
  FMVPModel := TPressRuntimeMVPModel.Create(FProject);
  FCodeUpdater := TPressCodeUpdater.Create(FProject);
end;

destructor TPressFacade.Destroy;
begin
  FCodeUpdater.Free;
  FMVPModel.Free;
  FBOModel.Free;
  FProject.Free;
  inherited;
end;

procedure TPressFacade.ParseProject;

  procedure AddEnums(AEnums: TPressProjectItemReferences);
  var
    I: Integer;
  begin
    for I := 0 to Pred(AEnums.Count) do
      BOModel.RegisterEnumMetadata(
       TypeInfo(TPressRuntimeEnum), AEnums[I].Name);
  end;

  procedure AddClasses(AClasses: TPressProjectClassReferences);

    procedure AddObjectMetadata(
      VReg: TPressObjectMetadataRegistry; VMeta: TPressObjectMetadata);
    begin
      { TODO : Fix parent class assignment }
      VReg.RuntimeMetadata := VMeta;
      VReg.KeyName := VMeta.KeyName;
      VReg.ObjectClassName := VMeta.ObjectClassName;
      VReg.IsPersistent := VMeta.IsPersistent;
      VReg.PersistentName := VMeta.PersistentName;
    end;

    procedure AddValueAttributeMetadata(
      VReg: TPressAttributeMetadataRegistry; VMeta: TPressAttributeMetadata);
    var
      VType: TPressAttributeTypeRegistry;
    begin
      VReg.RuntimeMetadata := VMeta;
      VReg.Name := VMeta.Name;
      VType := TPressAttributeTypeRegistry(
       Project.PressAttributeRegistry.FindItem(
       VMeta.AttributeName, TPressAttributeTypeRegistry));
      if not Assigned(VType) then
        VType := TPressAttributeTypeRegistry(
         Project.RootUserAttributes.ChildItems.FindItem(
         VMeta.AttributeName, TPressAttributeTypeRegistry));
      VReg.AttributeType := VType;
      VReg.DefaultValue.Value := VMeta.DefaultValue;
      VReg.EditMask.Value := VMeta.EditMask;
      VReg.IsPersistent.Value := VMeta.IsPersistent;
    end;

    procedure AddStructureAttributeMetadata(
      VReg: TPressAttributeMetadataRegistry; VMeta: TPressAttributeMetadata);
    begin
      { TODO : Get Container type from customized items attributes }
      VReg.ContainerType := TPressObjectMetadataRegistry(
       Project.RootPersistentClasses.ChildItems.FindItem(
       VMeta.ObjectClassName,
       TPressObjectMetadataRegistry));
    end;

    procedure AddItemsAttributeMetadata(
      VReg: TPressAttributeMetadataRegistry; VMeta: TPressAttributeMetadata);
    begin
      VReg.PersistentName.Value := VMeta.PersistentName;
      VReg.PersLinkChildName.Value := VMeta.PersLinkChildName;
      VReg.PersLinkIdName.Value := VMeta.PersLinkIdName;
      VReg.PersLinkName.Value := VMeta.PersLinkName;
      VReg.PersLinkParentName.Value := VMeta.PersLinkParentName;
      VReg.PersLinkPosName.Value := VMeta.PersLinkPosName;
      VReg.Size := VMeta.Size;
    end;

  var
    VRegistry: TPressObjectMetadataRegistry;
    VMetadata: TPressObjectMetadata;
    VAttributeMetadata: TPressAttributeMetadata;
    VAttributeRegistry: TPressAttributeMetadataRegistry;
    I, J: Integer;
  begin
    for I := 0 to Pred(AClasses.Count) do
    begin
      VRegistry := AClasses[I] as TPressObjectMetadataRegistry;
      VRegistry.DisableChanges;
      try
        VMetadata := BOModel.RegisterMetadata(VRegistry.MetadataStr);
        AddObjectMetadata(VRegistry, VMetadata);
        for J := 0 to Pred(VMetadata.AttributeMetadatas.Count) do
        begin
          VAttributeMetadata := VMetadata.AttributeMetadatas[J];
          VAttributeRegistry := VRegistry.AttributeList.Add;
          AddValueAttributeMetadata(VAttributeRegistry, VAttributeMetadata);
          if VAttributeMetadata.AttributeClass.InheritsFrom(TPressStructure) then
            AddStructureAttributeMetadata(VAttributeRegistry, VAttributeMetadata);
          if VAttributeMetadata.AttributeClass.InheritsFrom(TPressItems) then
            AddItemsAttributeMetadata(VAttributeRegistry, VAttributeMetadata);
        end;
      finally
        VRegistry.EnableChanges;
      end;
      AddClasses(VRegistry.ChildItems);
    end;
  end;

var
  VModuleNames: TStrings;
  VModuleIntf: IPressIDEModule;
  I: Integer;
begin
  BOModel.ClearMetadatas;
  CodeUpdater.ClearProjectModules;
  Project.DisableChanges;
  VModuleNames := TStringList.Create;
  try
    PressIDEInterface.ProjectModuleNames(VModuleNames);
    for I := 0 to Pred(VModuleNames.Count) do
    begin
      VModuleIntf := PressIDEInterface.FindModule(VModuleNames[I]);
      if Assigned(VModuleIntf) then
        CodeUpdater.ParseModule(VModuleIntf);
    end;
    AddEnums(Project.RootUserEnumerations.ChildItems);
    AddClasses(Project.RootBusinessClasses.ChildItems);
  finally
    VModuleNames.Free;
    Project.EnableChanges;
  end;
end;

initialization
  _PressDesignFacade := TPressFacade.Create;

finalization
  _PressDesignFacade.Free;

end.
