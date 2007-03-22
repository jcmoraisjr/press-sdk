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
  TPressProjectExplorerItem = class;
  TPressProjectExplorerItemParts = class;

  TPressProjectExplorer = class(TPressObject)
  private
    FPersistentClassesNode: TPressProjectExplorerItem;
    FQueryClassesNode: TPressProjectExplorerItem;
    FModelsNode: TPressProjectExplorerItem;
    FViewsNode: TPressProjectExplorerItem;
    FPresentersNode: TPressProjectExplorerItem;
    FCommandsNode: TPressProjectExplorerItem;
    FInteractorsNode: TPressProjectExplorerItem;
    FUserAttributesNode: TPressProjectExplorerItem;
    FUserEnumerationsNode: TPressProjectExplorerItem;
    FUserGeneratorsNode: TPressProjectExplorerItem;
    FFormsNode: TPressProjectExplorerItem;
    FFramesNode: TPressProjectExplorerItem;
    FUnknownClassesNode: TPressProjectExplorerItem;
  private
    FName: TPressString;
    FRootNodes: TPressProjectExplorerItemParts;
    function GetName: string;
    procedure SetName(const Value: string);
  protected
    procedure Init; override;
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    class function InternalMetadataStr: string; override;
  public
    property CommandsNode: TPressProjectExplorerItem read FCommandsNode;
    property FormsNode: TPressProjectExplorerItem read FFormsNode;
    property FramesNode: TPressProjectExplorerItem read FFramesNode;
    property InteractorsNode: TPressProjectExplorerItem read FInteractorsNode;
    property ModelsNode: TPressProjectExplorerItem read FModelsNode;
    property PersistentClassesNode: TPressProjectExplorerItem read FPersistentClassesNode;
    property PresentersNode: TPressProjectExplorerItem read FPresentersNode;
    property QueryClassesNode: TPressProjectExplorerItem read FQueryClassesNode;
    property UnknownClassesNode: TPressProjectExplorerItem read FUnknownClassesNode;
    property UserAttributesNode: TPressProjectExplorerItem read FUserAttributesNode;
    property UserEnumerationsNode: TPressProjectExplorerItem read FUserEnumerationsNode;
    property UserGeneratorsNode: TPressProjectExplorerItem read FUserGeneratorsNode;
    property ViewsNode: TPressProjectExplorerItem read FViewsNode;
  public
    property RootNodes: TPressProjectExplorerItemParts read FRootNodes;
  published
    property Name: string read GetName write SetName;
  end;

  TPressProjectExplorerItem = class(TPressObject)
  private
    FCaption: TPressString;
    FChildNodes: TPressProjectExplorerItemParts;
    function GetCaption: string;
    procedure SetCaption(const Value: string);
  protected
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    class function InternalMetadataStr: string; override;
  public
    property ChildNodes: TPressProjectExplorerItemParts read FChildNodes;
  published
    property Caption: string read GetCaption write SetCaption;
  end;

  TPressProjectExplorerItemIterator = class;

  TPressProjectExplorerItemParts = class(TPressParts)
  private
    function GetObjects(AIndex: Integer): TPressProjectExplorerItem;
    procedure SetObjects(AIndex: Integer; const Value: TPressProjectExplorerItem);
  protected
    function InternalCreateIterator: TPressItemsIterator; override;
  public
    function Add(AClass: TPressObjectClass = nil): TPressProjectExplorerItem; overload;
    function Add(AObject: TPressProjectExplorerItem): Integer; overload;
    class function AttributeName: string; override;
    function CreateIterator: TPressProjectExplorerItemIterator;
    function IndexOf(AObject: TPressProjectExplorerItem): Integer;
    procedure Insert(AIndex: Integer; AObject: TPressProjectExplorerItem);
    function Remove(AObject: TPressProjectExplorerItem): Integer;
    class function ValidObjectClass: TPressObjectClass; override;
    property Objects[AIndex: Integer]: TPressProjectExplorerItem read GetObjects write SetObjects; default;
  end;

  TPressProjectExplorerItemIterator = class(TPressItemsIterator)
  private
    function GetCurrentItem: TPressProjectExplorerItem;
  public
    property CurrentItem: TPressProjectExplorerItem read GetCurrentItem;
  end;

  TPressAttributeMetadataRegistryParts = class;
  TPressProjectModule = class;

  TPressObjectMetadataRegistry = class(TPressProjectExplorerItem)
  private
    FRuntimeMetadata: TPressObjectMetadata;
  private
    FObjectClassName: TPressString;
    FParentClass: TPressReference;
    FModule: TPressReference;
    FKeyName: TPressString;
    FAttributeList: TPressAttributeMetadataRegistryParts;
    function GetKeyName: string;
    function GetModule: TPressProjectModule;
    function GetObjectClassName: string;
    function GetParentClass: TPressObjectMetadataRegistry;
    procedure SetKeyName(const Value: string);
    procedure SetModule(Value: TPressProjectModule);
    procedure SetObjectClassName(const Value: string);
    procedure SetParentClass(Value: TPressObjectMetadataRegistry);
  protected
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    class function InternalMetadataStr: string; override;
  public
    property AttributeList: TPressAttributeMetadataRegistryParts read FAttributeList;
    property RuntimeMetadata: TPressObjectMetadata read FRuntimeMetadata write FRuntimeMetadata;
  published
    property KeyName: string read GetKeyName write SetKeyName;
    property Module: TPressProjectModule read GetModule write SetModule;
    property ObjectClassName: string read GetObjectClassName write SetObjectClassName;
    property ParentClass: TPressObjectMetadataRegistry read GetParentClass write SetParentClass;
  end;

  TPressAttributeTypeRegistry = class;

  TPressAttributeMetadataRegistry = class(TPressObject)
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
    function GetAttributeType: TPressAttributeTypeRegistry;
    function GetContainerType: TPressObjectMetadataRegistry;
    function GetDefaultValue: string;
    function GetEditMask: string;
    function GetIsPersistent: Boolean;
    function GetName: string;
    function GetPersistentName: string;
    function GetSize: Integer;
    procedure SetAttributeType(Value: TPressAttributeTypeRegistry);
    procedure SetContainerType(Value: TPressObjectMetadataRegistry);
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
    property AttributeType: TPressAttributeTypeRegistry read GetAttributeType write SetAttributeType;
    property ContainerType: TPressObjectMetadataRegistry read GetContainerType write SetContainerType;
    property DefaultValue: string read GetDefaultValue write SetDefaultValue;
    property EditMask: string read GetEditMask write SetEditMask;
    property IsPersistent: Boolean read GetIsPersistent write SetIsPersistent;
    property Name: string read GetName write SetName;
    property PersistentName: string read GetPersistentName write SetPersistentName;
    property Size: Integer read GetSize write SetSize;
  end;

  TPressAttributeMetadataRegistryIterator = class;

  TPressAttributeMetadataRegistryParts = class(TPressParts)
  private
    function GetObjects(AIndex: Integer): TPressAttributeMetadataRegistry;
    procedure SetObjects(AIndex: Integer; Value: TPressAttributeMetadataRegistry);
  protected
    function InternalCreateIterator: TPressItemsIterator; override;
  public
    function Add: TPressAttributeMetadataRegistry; overload;
    function Add(AObject: TPressAttributeMetadataRegistry): Integer; overload;
    class function AttributeName: string; override;
    function CreateIterator: TPressAttributeMetadataRegistryIterator;
    function IndexOf(AObject: TPressAttributeMetadataRegistry): Integer;
    procedure Insert(AIndex: Integer; AObject: TPressAttributeMetadataRegistry);
    function Remove(AObject: TPressAttributeMetadataRegistry): Integer;
    class function ValidObjectClass: TPressObjectClass; override;
    property Objects[AIndex: Integer]: TPressAttributeMetadataRegistry read GetObjects write SetObjects; default;
  end;

  TPressAttributeMetadataRegistryIterator = class(TPressItemsIterator)
  private
    function GetCurrentItem: TPressAttributeMetadataRegistry;
  public
    property CurrentItem: TPressAttributeMetadataRegistry read GetCurrentItem;
  end;

  TPressAttributeTypeRegistry = class(TPressProjectExplorerItem)
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

  TPressEnumerationRegistry = class(TPressProjectExplorerItem)
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

  TPressProjectModule = class(TPressObject)
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
    Add(TPressObjectMetadataRegistry).Caption := SPressProjectPersistentClasses;
    Add(TPressObjectMetadataRegistry).Caption := SPressProjectQueryClasses;
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

{ TPressProjectExplorerItem }

function TPressProjectExplorerItem.GetCaption: string;
begin
  Result := FCaption.Value;
end;

function TPressProjectExplorerItem.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'Caption') then
    Result := Addr(FCaption)
  else if SameText(AAttributeName, 'ChildNodes') then
    Result := Addr(FChildNodes)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressProjectExplorerItem.InternalMetadataStr: string;
begin
  Result := 'TPressProjectExplorerItem (' +
   'Caption: String;' +
   'ChildNodes: ProjectExplorerNodeParts)';
end;

procedure TPressProjectExplorerItem.SetCaption(const Value: string);
begin
  FCaption.Value := Value;
end;

{ TPressProjectExplorerItemParts }

function TPressProjectExplorerItemParts.Add(
  AClass: TPressObjectClass): TPressProjectExplorerItem;
begin
  Result := inherited Add(AClass) as TPressProjectExplorerItem;
end;

function TPressProjectExplorerItemParts.Add(AObject: TPressProjectExplorerItem): Integer;
begin
  Result := inherited Add(AObject);
end;

class function TPressProjectExplorerItemParts.AttributeName: string;
begin
  Result := 'ProjectExplorerNodeParts';
end;

function TPressProjectExplorerItemParts.CreateIterator: TPressProjectExplorerItemIterator;
begin
  Result := TPressProjectExplorerItemIterator.Create(ProxyList);
end;

function TPressProjectExplorerItemParts.GetObjects(
  AIndex: Integer): TPressProjectExplorerItem;
begin
  Result := inherited Objects[AIndex] as TPressProjectExplorerItem;
end;

function TPressProjectExplorerItemParts.IndexOf(
  AObject: TPressProjectExplorerItem): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressProjectExplorerItemParts.Insert(AIndex: Integer;
  AObject: TPressProjectExplorerItem);
begin
  inherited Insert(AIndex, AObject);
end;

function TPressProjectExplorerItemParts.InternalCreateIterator: TPressItemsIterator;
begin
  Result := CreateIterator;
end;

function TPressProjectExplorerItemParts.Remove(
  AObject: TPressProjectExplorerItem): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressProjectExplorerItemParts.SetObjects(AIndex: Integer;
  const Value: TPressProjectExplorerItem);
begin
  inherited Objects[AIndex] := Value;
end;

class function TPressProjectExplorerItemParts.ValidObjectClass: TPressObjectClass;
begin
  Result := TPressProjectExplorerItem;
end;

{ TPressProjectExplorerItemIterator }

function TPressProjectExplorerItemIterator.GetCurrentItem: TPressProjectExplorerItem;
begin
  Result := inherited CurrentItem as TPressProjectExplorerItem;
end;

{ TPressObjectMetadataRegistry }

function TPressObjectMetadataRegistry.GetKeyName: string;
begin
  Result := FKeyName.Value;
end;

function TPressObjectMetadataRegistry.GetModule: TPressProjectModule;
begin
  Result := FModule.Value as TPressProjectModule;
end;

function TPressObjectMetadataRegistry.GetObjectClassName: string;
begin
  Result := FObjectClassName.Value;
end;

function TPressObjectMetadataRegistry.GetParentClass: TPressObjectMetadataRegistry;
begin
  Result := FParentClass.Value as TPressObjectMetadataRegistry;
end;

function TPressObjectMetadataRegistry.InternalAttributeAddress(
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

class function TPressObjectMetadataRegistry.InternalMetadataStr: string;
begin
  Result := 'TPressObjectMetadataRegistry (' +
   'ChildNodes: ProjectExplorerNodeParts(TPressObjectMetadataRegistry);' +
   'ObjectClassName: String;' +
   'ParentClass: Reference(TPressObjectMetadataRegistry);' +
   'Module: Reference(TPressProjectModule);' +
   'KeyName: String;' +
   'AttributeList: ObjectAttributeEditorParts)';
end;

procedure TPressObjectMetadataRegistry.SetKeyName(const Value: string);
begin
  FKeyName.Value := Value;
end;

procedure TPressObjectMetadataRegistry.SetModule(Value: TPressProjectModule);
begin
  FModule.Value := Value;
end;

procedure TPressObjectMetadataRegistry.SetObjectClassName(const Value: string);
begin
  FObjectClassName.Value := Value;
end;

procedure TPressObjectMetadataRegistry.SetParentClass(
  Value: TPressObjectMetadataRegistry);
begin
  FParentClass.Value := Value;
end;

{ TPressAttributeMetadataRegistry }

function TPressAttributeMetadataRegistry.GetAttributeType: TPressAttributeTypeRegistry;
begin
  Result := FAttributeType.Value as TPressAttributeTypeRegistry;
end;

function TPressAttributeMetadataRegistry.GetContainerType: TPressObjectMetadataRegistry;
begin
  Result := FContainerType.Value as TPressObjectMetadataRegistry;
end;

function TPressAttributeMetadataRegistry.GetDefaultValue: string;
begin
  Result := FDefaultValue.Value;
end;

function TPressAttributeMetadataRegistry.GetEditMask: string;
begin
  Result := FEditMask.Value;
end;

function TPressAttributeMetadataRegistry.GetIsPersistent: Boolean;
begin
  Result := FIsPersistent.Value;
end;

function TPressAttributeMetadataRegistry.GetName: string;
begin
  Result := FName.Value;
end;

function TPressAttributeMetadataRegistry.GetPersistentName: string;
begin
  Result := FPersistentName.Value;
end;

function TPressAttributeMetadataRegistry.GetSize: Integer;
begin
  Result := FSize.Value;
end;

function TPressAttributeMetadataRegistry.InternalAttributeAddress(
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

class function TPressAttributeMetadataRegistry.InternalMetadataStr: string;
begin
  Result := 'TPressAttributeMetadataRegistry (' +
   'Name: String;' +
   'AttributeType: Reference(TPressAttributeTypeRegistry);' +
   'Size: Integer;' +
   'ContainerType: Reference(TPressObjectMetadataRegistry);' +
   'DefaultValue: String;' +
   'EditMask: String;' +
   'IsPersistent: Boolean;' +
   'PersistentName: String)';
end;

procedure TPressAttributeMetadataRegistry.SetAttributeType(
  Value: TPressAttributeTypeRegistry);
begin
  FAttributeType.Value := Value;
end;

procedure TPressAttributeMetadataRegistry.SetContainerType(
  Value: TPressObjectMetadataRegistry);
begin
  FContainerType.Value := Value;
end;

procedure TPressAttributeMetadataRegistry.SetDefaultValue(const Value: string);
begin
  FDefaultValue.Value := Value;
end;

procedure TPressAttributeMetadataRegistry.SetEditMask(const Value: string);
begin
  FEditMask.Value := Value;
end;

procedure TPressAttributeMetadataRegistry.SetIsPersistent(Value: Boolean);
begin
  FIsPersistent.Value := Value;
end;

procedure TPressAttributeMetadataRegistry.SetName(const Value: string);
begin
  FName.Value := Value;
end;

procedure TPressAttributeMetadataRegistry.SetPersistentName(const Value: string);
begin
  FPersistentName.Value := Value;
end;

procedure TPressAttributeMetadataRegistry.SetSize(Value: Integer);
begin
  FSize.Value := Value;
end;

{ TPressAttributeMetadataRegistryParts }

function TPressAttributeMetadataRegistryParts.Add: TPressAttributeMetadataRegistry;
begin
  Result := inherited Add as TPressAttributeMetadataRegistry;
end;

function TPressAttributeMetadataRegistryParts.Add(
  AObject: TPressAttributeMetadataRegistry): Integer;
begin
  Result := inherited Add(AObject);
end;

class function TPressAttributeMetadataRegistryParts.AttributeName: string;
begin
  Result := 'ObjectAttributeEditorParts';
end;

function TPressAttributeMetadataRegistryParts.CreateIterator: TPressAttributeMetadataRegistryIterator;
begin
  Result := TPressAttributeMetadataRegistryIterator.Create(ProxyList);
end;

function TPressAttributeMetadataRegistryParts.GetObjects(
  AIndex: Integer): TPressAttributeMetadataRegistry;
begin
  Result := inherited Objects[AIndex] as TPressAttributeMetadataRegistry;
end;

function TPressAttributeMetadataRegistryParts.IndexOf(
  AObject: TPressAttributeMetadataRegistry): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressAttributeMetadataRegistryParts.Insert(AIndex: Integer;
  AObject: TPressAttributeMetadataRegistry);
begin
  inherited Insert(AIndex, AObject);
end;

function TPressAttributeMetadataRegistryParts.InternalCreateIterator: TPressItemsIterator;
begin
  Result := CreateIterator;
end;

function TPressAttributeMetadataRegistryParts.Remove(
  AObject: TPressAttributeMetadataRegistry): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressAttributeMetadataRegistryParts.SetObjects(
  AIndex: Integer; Value: TPressAttributeMetadataRegistry);
begin
  inherited Objects[AIndex] := Value;
end;

class function TPressAttributeMetadataRegistryParts.ValidObjectClass: TPressObjectClass;
begin
  Result := TPressAttributeMetadataRegistry;
end;

{ TPressAttributeMetadataRegistryIterator }

function TPressAttributeMetadataRegistryIterator.GetCurrentItem: TPressAttributeMetadataRegistry;
begin
  Result := inherited CurrentItem as TPressAttributeMetadataRegistry;
end;

{ TPressAttributeTypeRegistry }

function TPressAttributeTypeRegistry.GetName: string;
begin
  Result := FName.Value;
end;

function TPressAttributeTypeRegistry.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'Name') then
    Result := Addr(FName)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressAttributeTypeRegistry.InternalMetadataStr: string;
begin
  Result := 'TPressAttributeTypeRegistry (' +
   'ChildNodes: ProjectExplorerNodeParts(TPressAttributeTypeRegistry);' +
   'Name: String)';
end;

procedure TPressAttributeTypeRegistry.SetName(const Value: string);
begin
  FName.Value := Value;
end;

{ TPressEnumerationRegistry }

function TPressEnumerationRegistry.GetName: string;
begin
  Result := FName.Value;
end;

function TPressEnumerationRegistry.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'Name') then
    Result := Addr(FName)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressEnumerationRegistry.InternalMetadataStr: string;
begin
  Result := 'TPressEnumerationRegistry (' +
   'ChildNodes: ProjectExplorerNodeParts(TPressEnumerationRegistry);' +
   'Name: String)';
end;

procedure TPressEnumerationRegistry.SetName(const Value: string);
begin
  FName.Value := Value;
end;

{ TPressProjectModule }

function TPressProjectModule.GetName: string;
begin
  Result := FName.Value;
end;

function TPressProjectModule.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'Name') then
    Result := Addr(FName)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressProjectModule.InternalMetadataStr: string;
begin
  Result := 'TPressProjectModule (' +
   'Name: String)';
end;

procedure TPressProjectModule.SetName(const Value: string);
begin
  FName.Value := Value;
end;

procedure RegisterClasses;
begin
  TPressProjectExplorer.RegisterClass;
  TPressProjectExplorerItem.RegisterClass;
  TPressObjectMetadataRegistry.RegisterClass;
  TPressAttributeMetadataRegistry.RegisterClass;
  TPressAttributeTypeRegistry.RegisterClass;
  TPressEnumerationRegistry.RegisterClass;
  TPressProjectModule.RegisterClass;
end;

procedure RegisterAttributes;
begin
  TPressProjectExplorerItemParts.RegisterAttribute;
  TPressAttributeMetadataRegistryParts.RegisterAttribute;
end;

initialization
  RegisterClasses;
  RegisterAttributes;

end.
