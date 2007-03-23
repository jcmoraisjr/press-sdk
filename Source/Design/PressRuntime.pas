(*
  PressObjects, Runtime classes implementation for design time packages
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressRuntime;

{$I Press.inc}

interface

uses
  Classes,
  PressSubject,
  PressAttributes,
  PressProjectBOModel,
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
    FClasses: TPressClassDeclarationList;
  protected
    function InternalFindAttribute(const AAttributeName: string): TPressAttributeClass; override;
    function InternalFindClass(const AClassName: string): TPressObjectClass; override;
    function InternalParentMetadataOf(AMetadata: TPressObjectMetadata): TPressObjectMetadata; override;
    property Classes: TPressClassDeclarationList read FClasses;
  public
    constructor Create(AClasses: TPressClassDeclarationList); reintroduce;
    procedure ClearMetadatas;
  end;

  TPressRuntimeMVPModel = class(TObject)
  { TODO : Implement core MVPModel and MVPMetadata }
  private
    FClasses: TPressClassDeclarationList;
  public
    constructor Create(AClasses: TPressClassDeclarationList); reintroduce;
  end;

  TPressRuntimeClasses = class(TObject)
  private
    FBOModel: TPressRuntimeBOModel;
    FClasses: TPressClassDeclarationList;
    FCodeUpdater: TPressCodeUpdater;
    FMVPModel: TPressRuntimeMVPModel;
    FProject: TPressProject;
    procedure CreateBOMetadata(AClass: TPressClassDeclaration);
    procedure CreateMVPMetadata(AClass: TPressClassDeclaration);
    procedure CreateProjectNodesFromClasses;
    procedure CreateProjectNodesFromRegistries;
    function GetBOModel: TPressRuntimeBOModel;
    function GetClasses: TPressClassDeclarationList;
    function GetCodeUpdater: TPressCodeUpdater;
    function GetMVPModel: TPressRuntimeMVPModel;
    function GetProject: TPressProject;
  protected
    property BOModel: TPressRuntimeBOModel read GetBOModel;
    property Classes: TPressClassDeclarationList read GetClasses;
    property CodeUpdater: TPressCodeUpdater read GetCodeUpdater;
    property MVPModel: TPressRuntimeMVPModel read GetMVPModel;
  public
    destructor Destroy; override;
    procedure ReadBusinessClasses;
    procedure ReadMVPClasses;
    procedure WriteBusinessClasses;
    procedure WriteMVPClasses;
    property Project: TPressProject read GetProject;
  end;

function PressRuntimeClasses: TPressRuntimeClasses;

implementation

uses
  SysUtils;

var
  _PressRuntimeClasses: TPressRuntimeClasses;

function PressRuntimeClasses: TPressRuntimeClasses;
begin
  Result := _PressRuntimeClasses;
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

constructor TPressRuntimeBOModel.Create(AClasses: TPressClassDeclarationList);
begin
  inherited Create;
  FClasses := AClasses;
end;

function TPressRuntimeBOModel.InternalFindAttribute(
  const AAttributeName: string): TPressAttributeClass;
var
  VClass: TPressClassDeclaration;
begin
  Result := PressModel.FindAttribute(AAttributeName);
  if not Assigned(Result) then
  begin
    VClass := Classes.FindClassByDisplayName(AAttributeName);
    if Assigned(VClass) then
    begin
      while Assigned(VClass.Parent) do
        VClass := VClass.Parent;
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
  VClass: TPressClassDeclaration;
begin
  Result := PressModel.FindClass(AClassName);
  if not Assigned(Result) then
  begin
    VClass := Classes.FindClass(AClassName);
    if Assigned(VClass) then
    begin
      while Assigned(VClass.Parent) do
        VClass := VClass.Parent;
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
  VClass: TPressClassDeclaration;
begin
  VClass := Classes.FindClass(AMetadata.ObjectClassName);
  if Assigned(VClass) and Assigned(VClass.Parent) then
    if Assigned(VClass.Parent.Parent) then
      Result := MetadataByName(VClass.Parent.Name)
    else
      Result := PressModel.ClassByName(VClass.Parent.Name).ClassMetadata
  else
    Result := PressModel.ParentMetadataOf(AMetadata);
end;

{ TPressRuntimeMVPModel }

constructor TPressRuntimeMVPModel.Create(AClasses: TPressClassDeclarationList);
begin
  inherited Create;
  FClasses := AClasses;
end;

{ TPressRuntimeClasses }

procedure TPressRuntimeClasses.CreateBOMetadata(
  AClass: TPressClassDeclaration);
var
  VMetadata: string;
begin
  VMetadata := AClass.Metadata;
  if VMetadata = '' then
    VMetadata := AClass.Name;
  BOModel.RegisterMetadata(VMetadata);
end;

procedure TPressRuntimeClasses.CreateMVPMetadata(
  AClass: TPressClassDeclaration);
begin
  { TODO : Implement }
end;

procedure TPressRuntimeClasses.CreateProjectNodesFromClasses;
type
  TPressClassRegistryProc = procedure(AClass: TPressClassDeclaration) of object;

  function IsPress(const AClassName, APreffix, ASuffix: string): Boolean;
  begin
    Result :=
     SameText(Copy(AClassName, 1, 6 + Length(APreffix)), 'TPress' + APreffix) and
     SameText(Copy(AClassName, Length(AClassName) - Length(ASuffix) + 1,
     Length(ASuffix)), ASuffix);
  end;

  function FindParentOfBO(const AClassName: string;
    var AParentNode: TPressProjectItem): Boolean;
  var
    VClass: TPressObjectClass;
  begin
    VClass := PressModel.FindClass(AClassName);
    if Assigned(VClass) then
      if VClass.InheritsFrom(TPressQuery) then
        AParentNode := Project.RootQueryClasses
      else
        AParentNode := Project.RootPersistentClasses
    else
      AParentNode := nil;
    Result := Assigned(AParentNode);
  end;

  function FindParentOfMVP(const AClassName: string;
    var AParentNode: TPressProjectItem): Boolean;

    function IsMVP(AClassName, ASuffix: string): Boolean;
    begin
      Result := IsPress(AClassName, 'MVP', ASuffix);
    end;

  begin
    if IsMVP(AClassName, 'Model') then
      AParentNode := Project.RootModels
    else if IsMVP(AClassName, 'View') then
      AParentNode := Project.RootViews
    else if IsMVP(AClassName, 'Presenter') then
      AParentNode := Project.RootPresenters
    else if IsMVP(AClassName, 'Command') then
      AParentNode := Project.RootCommands
    else if IsMVP(AClassName, 'Interactor') then
      AParentNode := Project.RootInteractors
    else
      AParentNode := nil;
    Result := Assigned(AParentNode);
  end;

  procedure CreateNodes(
    AParentNode: TPressProjectItem;
    AClass: TPressClassDeclaration;
    AProc: TPressClassRegistryProc = nil;
    AIncludeRootClass: Boolean = False);
  var
    VSubClasses: TPressClassDeclarationList;
    VNode: TPressProjectItem;
    I: Integer;
  begin
    if AIncludeRootClass then
    begin
      AParentNode := AParentNode.ChildNodes.Add;
      AParentNode.Caption := AClass.DisplayName;
    end;
    VSubClasses := AClass.SubClasses;
    for I := 0 to Pred(VSubClasses.Count) do
    begin
      if Assigned(AProc) then
        AProc(VSubClasses[I]);
      VNode := AParentNode.ChildNodes.Add;
      VNode.Caption := VSubClasses[I].DisplayName;
      CreateNodes(VNode, VSubClasses[I], AProc, False);
    end;
  end;

var
  VClassDeclaration: TPressClassDeclaration;
  VClassName: string;
  VParentNode: TPressProjectItem;
  I: Integer;
begin
  for I := 0 to Pred(CodeUpdater.Classes.Count) do
  begin
    VClassDeclaration := CodeUpdater.Classes[I];
    VClassName := VClassDeclaration.Name;
    if FindParentOfBO(VClassName, VParentNode) then
      CreateNodes(VParentNode, VClassDeclaration, CreateBOMetadata)
    else if Assigned(PressModel.FindAttributeClass(VClassName)) then
      CreateNodes(Project.RootUserAttributes, VClassDeclaration)
    else if SameText(VClassName, 'TPressOIDGenerator') then
      CreateNodes(Project.RootUserGenerators, VClassDeclaration)
    else if SameText(VClassName, 'TForm') then
      CreateNodes(Project.RootForms, VClassDeclaration)
    else if SameText(VClassName, 'TFrame') then
      CreateNodes(Project.RootFrames, VClassDeclaration)
    else if FindParentOfMVP(VClassName, VParentNode) then
      CreateNodes(VParentNode, VClassDeclaration, CreateMVPMetadata)
    else
      CreateNodes(Project.RootUnknownClasses, VClassDeclaration, nil, True);
  end;
end;

procedure TPressRuntimeClasses.CreateProjectNodesFromRegistries;

  procedure CreateEnumNodes;

    procedure CreateEnumMetadata(AEnumName: string);
    begin
      BOModel.RegisterEnumMetadata(
       TypeInfo(TPressRuntimeEnum), AEnumName);
    end;

  var
    VEnumName: string;
    I: Integer;
  begin
    for I := 0 to Pred(CodeUpdater.EnumMetadatas.Count) do
    begin
      VEnumName := CodeUpdater.EnumMetadatas[I];
      CreateEnumMetadata(VEnumName);
      Project.RootUserEnumerations.ChildNodes.Add.Caption := VEnumName;
    end;
  end;

begin
  CreateEnumNodes;
end;

destructor TPressRuntimeClasses.Destroy;
begin
  FProject.Free;
  FBOModel.Free;
  FMVPModel.Free;
  FCodeUpdater.Free;
  inherited;
end;

function TPressRuntimeClasses.GetBOModel: TPressRuntimeBOModel;
begin
  if not Assigned(FBOModel) then
    FBOModel := TPressRuntimeBOModel.Create(Classes);
  Result := FBOModel;
end;

function TPressRuntimeClasses.GetClasses: TPressClassDeclarationList;
begin
  if not Assigned(FClasses) then
    FClasses := CodeUpdater.Classes;
  Result := FClasses;
end;

function TPressRuntimeClasses.GetCodeUpdater: TPressCodeUpdater;
begin
  if not Assigned(FCodeUpdater) then
    FCodeUpdater := TPressCodeUpdater.Create;
  Result := FCodeUpdater;
end;

function TPressRuntimeClasses.GetMVPModel: TPressRuntimeMVPModel;
begin
  if not Assigned(FMVPModel) then
    FMVPModel := TPressRuntimeMVPModel.Create(Classes);
  Result := FMVPModel;
end;

function TPressRuntimeClasses.GetProject: TPressProject;
begin
  if not Assigned(FProject) then
    FProject := TPressProject.Create;
  Result := FProject;
end;

procedure TPressRuntimeClasses.ReadBusinessClasses;
begin
  CodeUpdater.ParseBusinessClasses;
  BOModel.ClearMetadatas;
  FreeAndNil(FProject);
  CreateProjectNodesFromRegistries;
  CreateProjectNodesFromClasses;
end;

procedure TPressRuntimeClasses.ReadMVPClasses;
begin
  { TODO : Implement }
end;

procedure TPressRuntimeClasses.WriteBusinessClasses;
begin
  { TODO : Implement }
end;

procedure TPressRuntimeClasses.WriteMVPClasses;
begin
  { TODO : Implement }
end;

initialization
  _PressRuntimeClasses := TPressRuntimeClasses.Create;

finalization
  _PressRuntimeClasses.Free;

end.
