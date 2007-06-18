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

  TPressRuntimeObject = class(TPressObject)
  end;

  TPressRuntimeQuery = class(TPressQuery)
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
    function GetBOModel: TPressRuntimeBOModel;
    function GetCodeUpdater: TPressCodeUpdater;
    function GetMVPModel: TPressRuntimeMVPModel;
    function GetProject: TPressProject;
  protected
    property BOModel: TPressRuntimeBOModel read GetBOModel;
    property MVPModel: TPressRuntimeMVPModel read GetMVPModel;
  public
    property CodeUpdater: TPressCodeUpdater read GetCodeUpdater;
    destructor Destroy; override;
    procedure ParseProject;
    property Project: TPressProject read GetProject;
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
    VClass := TPressProjectClass(Project.RootUserAttributes.ChildItems.FindItem(
     AAttributeName, TPressProjectClass));
    if Assigned(VClass) then
    begin
      while Assigned(VClass.ParentClass) do
        VClass := VClass.ParentClass;
      if SameText(VClass.Name, TPressParts.ClassName) then
        Result := TPressRuntimeParts
      else if SameText(VClass.Name, TPressReferences.ClassName) then
        Result := TPressRuntimeReferences
      else
        Result := PressModel.FindAttributeClass(VClass.Name);
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
      if SameText(VClass.Name, TPressObject.ClassName) then
        Result := TPressRuntimeObject
      else if SameText(VClass.Name, TPressQuery.ClassName) then
        Result := TPressRuntimeQuery
      else
        Result := PressModel.FindClass(VClass.Name);
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
      Result := MetadataByName(VClass.ParentClass.Name)
    else
      Result := PressModel.ClassByName(VClass.ParentClass.Name).ClassMetadata
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

destructor TPressFacade.Destroy;
begin
  FCodeUpdater.Free;
  FMVPModel.Free;
  FBOModel.Free;
  FProject.Free;
  inherited;
end;

function TPressFacade.GetBOModel: TPressRuntimeBOModel;
begin
  if not Assigned(FBOModel) then
    FBOModel := TPressRuntimeBOModel.Create(Project);
  Result := FBOModel;
end;

function TPressFacade.GetCodeUpdater: TPressCodeUpdater;
begin
  if not Assigned(FCodeUpdater) then
    FCodeUpdater := TPressCodeUpdater.Create(Project);
  Result := FCodeUpdater;
end;

function TPressFacade.GetMVPModel: TPressRuntimeMVPModel;
begin
  if not Assigned(FMVPModel) then
    FMVPModel := TPressRuntimeMVPModel.Create(Project);
  Result := FMVPModel;
end;

function TPressFacade.GetProject: TPressProject;
begin
  if not Assigned(FProject) then
    FProject := TPressProject.Create;
  Result := FProject;
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
  var
    VRegistry: TPressObjectMetadataRegistry;
    I: Integer;
  begin
    for I := 0 to Pred(AClasses.Count) do
    begin
      VRegistry := AClasses[I] as TPressObjectMetadataRegistry;
      VRegistry.RuntimeMetadata :=
       BOModel.RegisterMetadata(VRegistry.MetadataStr);
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
