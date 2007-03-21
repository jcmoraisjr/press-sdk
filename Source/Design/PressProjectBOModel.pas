(*
  PressObjects, Project Explorer business object model
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressProjectBOModel;

{$I Press.inc}

interface

uses
  PressSubject,
  PressAttributes;

type
  TPressProjectExplorerNode = class;
  TPressProjectExplorerNodeParts = class;

  TPressProjectExplorer = class(TPressObject)
  private
    FPersistentClassesNode: TPressProjectExplorerNode;
    FQueryClassesNode: TPressProjectExplorerNode;
    FModelsNode: TPressProjectExplorerNode;
    FViewsNode: TPressProjectExplorerNode;
    FPresentersNode: TPressProjectExplorerNode;
    FCommandsNode: TPressProjectExplorerNode;
    FInteractorsNode: TPressProjectExplorerNode;
    FUserAttributesNode: TPressProjectExplorerNode;
    FUserEnumerationsNode: TPressProjectExplorerNode;
    FUserGeneratorsNode: TPressProjectExplorerNode;
    FFormsNode: TPressProjectExplorerNode;
    FFramesNode: TPressProjectExplorerNode;
    FUnknownClassesNode: TPressProjectExplorerNode;
  private
    FName: TPressString;
    FRootNodes: TPressProjectExplorerNodeParts;
    function GetName: string;
    procedure SetName(const Value: string);
  protected
    procedure Init; override;
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    class function InternalMetadataStr: string; override;
  public
    property CommandsNode: TPressProjectExplorerNode read FCommandsNode;
    property FormsNode: TPressProjectExplorerNode read FFormsNode;
    property FramesNode: TPressProjectExplorerNode read FFramesNode;
    property InteractorsNode: TPressProjectExplorerNode read FInteractorsNode;
    property ModelsNode: TPressProjectExplorerNode read FModelsNode;
    property PersistentClassesNode: TPressProjectExplorerNode read FPersistentClassesNode;
    property PresentersNode: TPressProjectExplorerNode read FPresentersNode;
    property QueryClassesNode: TPressProjectExplorerNode read FQueryClassesNode;
    property UnknownClassesNode: TPressProjectExplorerNode read FUnknownClassesNode;
    property UserAttributesNode: TPressProjectExplorerNode read FUserAttributesNode;
    property UserEnumerationsNode: TPressProjectExplorerNode read FUserEnumerationsNode;
    property UserGeneratorsNode: TPressProjectExplorerNode read FUserGeneratorsNode;
    property ViewsNode: TPressProjectExplorerNode read FViewsNode;
  public
    property RootNodes: TPressProjectExplorerNodeParts read FRootNodes;
  published
    property Name: string read GetName write SetName;
  end;

  PPressProjectExplorerNode = ^TPressProjectExplorerNode;

  TPressProjectExplorerNode = class(TPressObject)
  private
    FCaption: TPressString;
    FChildNodes: TPressProjectExplorerNodeParts;
    function GetCaption: string;
    procedure SetCaption(const Value: string);
  protected
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    class function InternalMetadataStr: string; override;
  public
    property ChildNodes: TPressProjectExplorerNodeParts read FChildNodes;
  published
    property Caption: string read GetCaption write SetCaption;
  end;

  TPressProjectExplorerNodeIterator = class;

  TPressProjectExplorerNodeParts = class(TPressParts)
  private
    function GetObjects(AIndex: Integer): TPressProjectExplorerNode;
    procedure SetObjects(AIndex: Integer; const Value: TPressProjectExplorerNode);
  protected
    function InternalCreateIterator: TPressItemsIterator; override;
  public
    function Add(AClass: TPressObjectClass = nil): TPressProjectExplorerNode; overload;
    function Add(AObject: TPressProjectExplorerNode): Integer; overload;
    class function AttributeName: string; override;
    function CreateIterator: TPressProjectExplorerNodeIterator;
    function IndexOf(AObject: TPressProjectExplorerNode): Integer;
    procedure Insert(AIndex: Integer; AObject: TPressProjectExplorerNode);
    function Remove(AObject: TPressProjectExplorerNode): Integer;
    class function ValidObjectClass: TPressObjectClass; override;
    property Objects[AIndex: Integer]: TPressProjectExplorerNode read GetObjects write SetObjects; default;
  end;

  TPressProjectExplorerNodeIterator = class(TPressItemsIterator)
  private
    function GetCurrentItem: TPressProjectExplorerNode;
  public
    property CurrentItem: TPressProjectExplorerNode read GetCurrentItem;
  end;

  TPressObjectAttributeEditorParts = class;
  TPressModuleEditor = class;

  TPressObjectClassEditor = class(TPressProjectExplorerNode)
  private
    FRuntimeMetadata: TPressObjectMetadata;
  private
    FObjectClassName: TPressString;
    FParentClass: TPressReference;
    FModule: TPressReference;
    FKeyName: TPressString;
    FAttributeList: TPressObjectAttributeEditorParts;
    function GetKeyName: string;
    function GetModule: TPressModuleEditor;
    function GetObjectClassName: string;
    function GetParentClass: TPressObjectClassEditor;
    procedure SetKeyName(const Value: string);
    procedure SetModule(Value: TPressModuleEditor);
    procedure SetObjectClassName(const Value: string);
    procedure SetParentClass(Value: TPressObjectClassEditor);
  protected
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    class function InternalMetadataStr: string; override;
  public
    property AttributeList: TPressObjectAttributeEditorParts read FAttributeList;
    property RuntimeMetadata: TPressObjectMetadata read FRuntimeMetadata write FRuntimeMetadata;
  published
    property KeyName: string read GetKeyName write SetKeyName;
    property Module: TPressModuleEditor read GetModule write SetModule;
    property ObjectClassName: string read GetObjectClassName write SetObjectClassName;
    property ParentClass: TPressObjectClassEditor read GetParentClass write SetParentClass;
  end;

  TPressAttributeRegistryEditor = class;

  TPressObjectAttributeEditor = class(TPressObject)
  private
    FRuntimeMetadata: TPressAttributeMetadata;
  private
    FName: TPressString;
    FAttributeType: TPressReference;
    FSize: TPressInteger;
    FContainerType: TPressReference;
    FDefaultValue: TPressString;
    FEditMask: TPressString;
    FIsPersistent: TPressBoolean;
    FPersistentName: TPressString;
    function GetAttributeType: TPressAttributeRegistryEditor;
    function GetContainerType: TPressObjectClassEditor;
    function GetDefaultValue: string;
    function GetEditMask: string;
    function GetIsPersistent: Boolean;
    function GetName: string;
    function GetPersistentName: string;
    function GetSize: Integer;
    procedure SetAttributeType(Value: TPressAttributeRegistryEditor);
    procedure SetContainerType(Value: TPressObjectClassEditor);
    procedure SetDefaultValue(const Value: string);
    procedure SetEditMask(const Value: string);
    procedure SetIsPersistent(Value: Boolean);
    procedure SetName(const Value: string);
    procedure SetPersistentName(const Value: string);
    procedure SetSize(Value: Integer);
  protected
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    class function InternalMetadataStr: string; override;
  public
    property RuntimeMetadata: TPressAttributeMetadata read FRuntimeMetadata write FRuntimeMetadata;
  published
    property AttributeType: TPressAttributeRegistryEditor read GetAttributeType write SetAttributeType;
    property ContainerType: TPressObjectClassEditor read GetContainerType write SetContainerType;
    property DefaultValue: string read GetDefaultValue write SetDefaultValue;
    property EditMask: string read GetEditMask write SetEditMask;
    property IsPersistent: Boolean read GetIsPersistent write SetIsPersistent;
    property Name: string read GetName write SetName;
    property PersistentName: string read GetPersistentName write SetPersistentName;
    property Size: Integer read GetSize write SetSize;
  end;

  TPressObjectAttributeEditorIterator = class;

  TPressObjectAttributeEditorParts = class(TPressParts)
  private
    function GetObjects(AIndex: Integer): TPressObjectAttributeEditor;
    procedure SetObjects(AIndex: Integer; Value: TPressObjectAttributeEditor);
  protected
    function InternalCreateIterator: TPressItemsIterator; override;
  public
    function Add: TPressObjectAttributeEditor; overload;
    function Add(AObject: TPressObjectAttributeEditor): Integer; overload;
    class function AttributeName: string; override;
    function CreateIterator: TPressObjectAttributeEditorIterator;
    function IndexOf(AObject: TPressObjectAttributeEditor): Integer;
    procedure Insert(AIndex: Integer; AObject: TPressObjectAttributeEditor);
    function Remove(AObject: TPressObjectAttributeEditor): Integer;
    class function ValidObjectClass: TPressObjectClass; override;
    property Objects[AIndex: Integer]: TPressObjectAttributeEditor read GetObjects write SetObjects; default;
  end;

  TPressObjectAttributeEditorIterator = class(TPressItemsIterator)
  private
    function GetCurrentItem: TPressObjectAttributeEditor;
  public
    property CurrentItem: TPressObjectAttributeEditor read GetCurrentItem;
  end;

  TPressAttributeRegistryEditor = class(TPressProjectExplorerNode)
  private
    FName: TPressString;
    function GetName: string;
    procedure SetName(const Value: string);
  protected
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    class function InternalMetadataStr: string; override;
  published
    property Name: string read GetName write SetName;
  end;

  TPressEnumerationRegistryEditor = class(TPressProjectExplorerNode)
  private
    FName: TPressString;
    function GetName: string;
    procedure SetName(const Value: string);
  protected
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    class function InternalMetadataStr: string; override;
  published
    property Name: string read GetName write SetName;
  end;

  TPressModuleEditor = class(TPressObject)
  private
    FName: TPressString;
    function GetName: string;
    procedure SetName(const Value: string);
  protected
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    class function InternalMetadataStr: string; override;
  published
    property Name: string read GetName write SetName;
  end;

implementation

uses
  SysUtils,
  PressDesignConsts;

{ TPressProjectExplorer }

function TPressProjectExplorer.GetName: string;
begin
  Result := FName.Value;
end;

procedure TPressProjectExplorer.Init;
begin
  inherited;
  { TODO : Improve }
  RootNodes.Add.Caption := SPressProjectBusinessClasses;
  with RootNodes[0].ChildNodes do
  begin
    Add(TPressObjectClassEditor).Caption := SPressProjectPersistentClasses;
    Add(TPressObjectClassEditor).Caption := SPressProjectQueryClasses;
    FPersistentClassesNode := Objects[0];
    FQueryClassesNode := Objects[1];
  end;
  RootNodes.Add.Caption := SPressProjectMVPClasses;
  with RootNodes[1].ChildNodes do
  begin
    Add.Caption := SPressProjectModels;
    Add.Caption := SPressProjectViews;
    Add.Caption := SPressProjectPresenters;
    Add.Caption := SPressProjectCommands;
    Add.Caption := SPressProjectInteractors;
    FModelsNode := Objects[0];
    FViewsNode := Objects[1];
    FPresentersNode := Objects[2];
    FCommandsNode := Objects[3];
    FInteractorsNode := Objects[4];
  end;
  RootNodes.Add.Caption := SPressProjectRegistries;
  with RootNodes[2].ChildNodes do
  begin
    Add.Caption := SPressProjectUserAttributes;
    Add.Caption := SPressProjectUserEnumerations;
    Add.Caption := SPressProjectUserOIDGenerators;
    FUserAttributesNode := Objects[0];
    FUserEnumerationsNode := Objects[1];
    FUserGeneratorsNode := Objects[2];
  end;
  RootNodes.Add.Caption := SPressProjectOtherClasses;
  with RootNodes[3].ChildNodes do
  begin
    Add.Caption := SPressProjectForms;
    Add.Caption := SPressProjectFrames;
    Add.Caption := SPressProjectUnknown;
    FFormsNode := Objects[0];
    FFramesNode := Objects[1];
    FUnknownClassesNode := Objects[2];
  end;
end;

function TPressProjectExplorer.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'Name') then
    Result := Addr(FName)
  else if SameText(AAttributeName, 'RootNodes') then
    Result := Addr(FRootNodes)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressProjectExplorer.InternalMetadataStr: string;
begin
  Result := 'TPressProjectExplorer (' +
   'Name: String;' +
   'RootNodes: ProjectExplorerNodeParts)';
end;

procedure TPressProjectExplorer.SetName(const Value: string);
begin
  FName.Value := Value;
end;

{ TPressProjectExplorerNode }

function TPressProjectExplorerNode.GetCaption: string;
begin
  Result := FCaption.Value;
end;

function TPressProjectExplorerNode.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'Caption') then
    Result := Addr(FCaption)
  else if SameText(AAttributeName, 'ChildNodes') then
    Result := Addr(FChildNodes)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressProjectExplorerNode.InternalMetadataStr: string;
begin
  Result := 'TPressProjectExplorerNode (' +
   'Caption: String;' +
   'ChildNodes: ProjectExplorerNodeParts)';
end;

procedure TPressProjectExplorerNode.SetCaption(const Value: string);
begin
  FCaption.Value := Value;
end;

{ TPressProjectExplorerNodeParts }

function TPressProjectExplorerNodeParts.Add(
  AClass: TPressObjectClass): TPressProjectExplorerNode;
begin
  Result := inherited Add(AClass) as TPressProjectExplorerNode;
end;

function TPressProjectExplorerNodeParts.Add(AObject: TPressProjectExplorerNode): Integer;
begin
  Result := inherited Add(AObject);
end;

class function TPressProjectExplorerNodeParts.AttributeName: string;
begin
  Result := 'ProjectExplorerNodeParts';
end;

function TPressProjectExplorerNodeParts.CreateIterator: TPressProjectExplorerNodeIterator;
begin
  Result := TPressProjectExplorerNodeIterator.Create(ProxyList);
end;

function TPressProjectExplorerNodeParts.GetObjects(
  AIndex: Integer): TPressProjectExplorerNode;
begin
  Result := inherited Objects[AIndex] as TPressProjectExplorerNode;
end;

function TPressProjectExplorerNodeParts.IndexOf(
  AObject: TPressProjectExplorerNode): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressProjectExplorerNodeParts.Insert(AIndex: Integer;
  AObject: TPressProjectExplorerNode);
begin
  inherited Insert(AIndex, AObject);
end;

function TPressProjectExplorerNodeParts.InternalCreateIterator: TPressItemsIterator;
begin
  Result := CreateIterator;
end;

function TPressProjectExplorerNodeParts.Remove(
  AObject: TPressProjectExplorerNode): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressProjectExplorerNodeParts.SetObjects(AIndex: Integer;
  const Value: TPressProjectExplorerNode);
begin
  inherited Objects[AIndex] := Value;
end;

class function TPressProjectExplorerNodeParts.ValidObjectClass: TPressObjectClass;
begin
  Result := TPressProjectExplorerNode;
end;

{ TPressProjectExplorerNodeIterator }

function TPressProjectExplorerNodeIterator.GetCurrentItem: TPressProjectExplorerNode;
begin
  Result := inherited CurrentItem as TPressProjectExplorerNode;
end;

{ TPressObjectClassEditor }

function TPressObjectClassEditor.GetKeyName: string;
begin
  Result := FKeyName.Value;
end;

function TPressObjectClassEditor.GetModule: TPressModuleEditor;
begin
  Result := FModule.Value as TPressModuleEditor;
end;

function TPressObjectClassEditor.GetObjectClassName: string;
begin
  Result := FObjectClassName.Value;
end;

function TPressObjectClassEditor.GetParentClass: TPressObjectClassEditor;
begin
  Result := FParentClass.Value as TPressObjectClassEditor;
end;

function TPressObjectClassEditor.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'ObjectClassName') then
    Result := Addr(FObjectClassName)
  else if SameText(AAttributeName, 'ParentClass') then
    Result := Addr(FParentClass)
  else if SameText(AAttributeName, 'Module') then
    Result := Addr(FModule)
  else if SameText(AAttributeName, 'AttributeList') then
    Result := Addr(FAttributeList)
  else if SameText(AAttributeName, 'KeyName') then
    Result := Addr(FKeyName)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressObjectClassEditor.InternalMetadataStr: string;
begin
  Result := 'TPressObjectClassEditor (' +
   'ChildNodes: ProjectExplorerNodeParts(TPressObjectClassEditor);' +
   'ObjectClassName: String;' +
   'ParentClass: Reference(TPressObjectClassEditor);' +
   'Module: Reference(TPressModuleEditor);' +
   'KeyName: String;' +
   'AttributeList: ObjectAttributeEditorParts)';
end;

procedure TPressObjectClassEditor.SetKeyName(const Value: string);
begin
  FKeyName.Value := Value;
end;

procedure TPressObjectClassEditor.SetModule(Value: TPressModuleEditor);
begin
  FModule.Value := Value;
end;

procedure TPressObjectClassEditor.SetObjectClassName(const Value: string);
begin
  FObjectClassName.Value := Value;
end;

procedure TPressObjectClassEditor.SetParentClass(
  Value: TPressObjectClassEditor);
begin
  FParentClass.Value := Value;
end;

{ TPressObjectAttributeEditor }

function TPressObjectAttributeEditor.GetAttributeType: TPressAttributeRegistryEditor;
begin
  Result := FAttributeType.Value as TPressAttributeRegistryEditor;
end;

function TPressObjectAttributeEditor.GetContainerType: TPressObjectClassEditor;
begin
  Result := FContainerType.Value as TPressObjectClassEditor;
end;

function TPressObjectAttributeEditor.GetDefaultValue: string;
begin
  Result := FDefaultValue.Value;
end;

function TPressObjectAttributeEditor.GetEditMask: string;
begin
  Result := FEditMask.Value;
end;

function TPressObjectAttributeEditor.GetIsPersistent: Boolean;
begin
  Result := FIsPersistent.Value;
end;

function TPressObjectAttributeEditor.GetName: string;
begin
  Result := FName.Value;
end;

function TPressObjectAttributeEditor.GetPersistentName: string;
begin
  Result := FPersistentName.Value;
end;

function TPressObjectAttributeEditor.GetSize: Integer;
begin
  Result := FSize.Value;
end;

function TPressObjectAttributeEditor.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'Name') then
    Result := Addr(FName)
  else if SameText(AAttributeName, 'AttributeType') then
    Result := Addr(FAttributeType)
  else if SameText(AAttributeName, 'Size') then
    Result := Addr(FSize)
  else if SameText(AAttributeName, 'ContainerType') then
    Result := Addr(FContainerType)
  else if SameText(AAttributeName, 'DefaultValue') then
    Result := Addr(FDefaultValue)
  else if SameText(AAttributeName, 'EditMask') then
    Result := Addr(FEditMask)
  else if SameText(AAttributeName, 'IsPersistent') then
    Result := Addr(FIsPersistent)
  else if SameText(AAttributeName, 'PersistentName') then
    Result := Addr(FPersistentName)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressObjectAttributeEditor.InternalMetadataStr: string;
begin
  Result := 'TPressObjectAttributeEditor (' +
   'Name: String;' +
   'AttributeType: Reference(TPressAttributeRegistryEditor);' +
   'Size: Integer;' +
   'ContainerType: Reference(TPressObjectClassEditor);' +
   'DefaultValue: String;' +
   'EditMask: String;' +
   'IsPersistent: Boolean;' +
   'PersistentName: String)';
end;

procedure TPressObjectAttributeEditor.SetAttributeType(
  Value: TPressAttributeRegistryEditor);
begin
  FAttributeType.Value := Value;
end;

procedure TPressObjectAttributeEditor.SetContainerType(
  Value: TPressObjectClassEditor);
begin
  FContainerType.Value := Value;
end;

procedure TPressObjectAttributeEditor.SetDefaultValue(const Value: string);
begin
  FDefaultValue.Value := Value;
end;

procedure TPressObjectAttributeEditor.SetEditMask(const Value: string);
begin
  FEditMask.Value := Value;
end;

procedure TPressObjectAttributeEditor.SetIsPersistent(Value: Boolean);
begin
  FIsPersistent.Value := Value;
end;

procedure TPressObjectAttributeEditor.SetName(const Value: string);
begin
  FName.Value := Value;
end;

procedure TPressObjectAttributeEditor.SetPersistentName(const Value: string);
begin
  FPersistentName.Value := Value;
end;

procedure TPressObjectAttributeEditor.SetSize(Value: Integer);
begin
  FSize.Value := Value;
end;

{ TPressObjectAttributeEditorParts }

function TPressObjectAttributeEditorParts.Add: TPressObjectAttributeEditor;
begin
  Result := inherited Add as TPressObjectAttributeEditor;
end;

function TPressObjectAttributeEditorParts.Add(
  AObject: TPressObjectAttributeEditor): Integer;
begin
  Result := inherited Add(AObject);
end;

class function TPressObjectAttributeEditorParts.AttributeName: string;
begin
  Result := 'ObjectAttributeEditorParts';
end;

function TPressObjectAttributeEditorParts.CreateIterator: TPressObjectAttributeEditorIterator;
begin
  Result := TPressObjectAttributeEditorIterator.Create(ProxyList);
end;

function TPressObjectAttributeEditorParts.GetObjects(
  AIndex: Integer): TPressObjectAttributeEditor;
begin
  Result := inherited Objects[AIndex] as TPressObjectAttributeEditor;
end;

function TPressObjectAttributeEditorParts.IndexOf(
  AObject: TPressObjectAttributeEditor): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressObjectAttributeEditorParts.Insert(AIndex: Integer;
  AObject: TPressObjectAttributeEditor);
begin
  inherited Insert(AIndex, AObject);
end;

function TPressObjectAttributeEditorParts.InternalCreateIterator: TPressItemsIterator;
begin
  Result := CreateIterator;
end;

function TPressObjectAttributeEditorParts.Remove(
  AObject: TPressObjectAttributeEditor): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressObjectAttributeEditorParts.SetObjects(
  AIndex: Integer; Value: TPressObjectAttributeEditor);
begin
  inherited Objects[AIndex] := Value;
end;

class function TPressObjectAttributeEditorParts.ValidObjectClass: TPressObjectClass;
begin
  Result := TPressObjectAttributeEditor;
end;

{ TPressObjectAttributeEditorIterator }

function TPressObjectAttributeEditorIterator.GetCurrentItem: TPressObjectAttributeEditor;
begin
  Result := inherited CurrentItem as TPressObjectAttributeEditor;
end;

{ TPressAttributeRegistryEditor }

function TPressAttributeRegistryEditor.GetName: string;
begin
  Result := FName.Value;
end;

function TPressAttributeRegistryEditor.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'Name') then
    Result := Addr(FName)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressAttributeRegistryEditor.InternalMetadataStr: string;
begin
  Result := 'TPressAttributeRegistryEditor (' +
   'ChildNodes: ProjectExplorerNodeParts(TPressAttributeRegistryEditor);' +
   'Name: String)';
end;

procedure TPressAttributeRegistryEditor.SetName(const Value: string);
begin
  FName.Value := Value;
end;

{ TPressEnumerationRegistryEditor }

function TPressEnumerationRegistryEditor.GetName: string;
begin
  Result := FName.Value;
end;

function TPressEnumerationRegistryEditor.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'Name') then
    Result := Addr(FName)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressEnumerationRegistryEditor.InternalMetadataStr: string;
begin
  Result := 'TPressEnumerationRegistryEditor (' +
   'ChildNodes: ProjectExplorerNodeParts(TPressEnumerationRegistryEditor);' +
   'Name: String)';
end;

procedure TPressEnumerationRegistryEditor.SetName(const Value: string);
begin
  FName.Value := Value;
end;

{ TPressModuleEditor }

function TPressModuleEditor.GetName: string;
begin
  Result := FName.Value;
end;

function TPressModuleEditor.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'Name') then
    Result := Addr(FName)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressModuleEditor.InternalMetadataStr: string;
begin
  Result := 'TPressModuleEditor (' +
   'Name: String)';
end;

procedure TPressModuleEditor.SetName(const Value: string);
begin
  FName.Value := Value;
end;

procedure RegisterClasses;
begin
  TPressProjectExplorer.RegisterClass;
  TPressProjectExplorerNode.RegisterClass;
  TPressObjectClassEditor.RegisterClass;
  TPressObjectAttributeEditor.RegisterClass;
  TPressAttributeRegistryEditor.RegisterClass;
  TPressEnumerationRegistryEditor.RegisterClass;
  TPressModuleEditor.RegisterClass;
end;

procedure RegisterAttributes;
begin
  TPressProjectExplorerNodeParts.RegisterAttribute;
  TPressObjectAttributeEditorParts.RegisterAttribute;
end;

initialization
  RegisterClasses;
  RegisterAttributes;

end.
