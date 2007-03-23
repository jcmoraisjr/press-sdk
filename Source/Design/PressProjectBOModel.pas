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
  TPressProjectItem = class;
  TPressProjectItemParts = class;

  TPressProject = class(TPressObject)
  private
    FRootPersistentClasses: TPressProjectItem;
    FRootQueryClasses: TPressProjectItem;
    FRootModels: TPressProjectItem;
    FRootViews: TPressProjectItem;
    FRootPresenters: TPressProjectItem;
    FRootCommands: TPressProjectItem;
    FRootInteractors: TPressProjectItem;
    FRootUserAttributes: TPressProjectItem;
    FRootUserEnumerations: TPressProjectItem;
    FRootUserGenerators: TPressProjectItem;
    FRootForms: TPressProjectItem;
    FRootFrames: TPressProjectItem;
    FRootUnknownClasses: TPressProjectItem;
  private
    FName: TPressString;
    FRootItems: TPressProjectItemParts;
    function GetName: string;
    procedure SetName(const Value: string);
  protected
    procedure Init; override;
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    class function InternalMetadataStr: string; override;
  public
    property RootCommands: TPressProjectItem read FRootCommands;
    property RootForms: TPressProjectItem read FRootForms;
    property RootFrames: TPressProjectItem read FRootFrames;
    property RootInteractors: TPressProjectItem read FRootInteractors;
    property RootModels: TPressProjectItem read FRootModels;
    property RootPersistentClasses: TPressProjectItem read FRootPersistentClasses;
    property RootPresenters: TPressProjectItem read FRootPresenters;
    property RootQueryClasses: TPressProjectItem read FRootQueryClasses;
    property RootUnknownClasses: TPressProjectItem read FRootUnknownClasses;
    property RootUserAttributes: TPressProjectItem read FRootUserAttributes;
    property RootUserEnumerations: TPressProjectItem read FRootUserEnumerations;
    property RootUserGenerators: TPressProjectItem read FRootUserGenerators;
    property RootViews: TPressProjectItem read FRootViews;
  public
    property RootItems: TPressProjectItemParts read FRootItems;
  published
    property Name: string read GetName write SetName;
  end;

  TPressProjectItem = class(TPressObject)
  private
    FCaption: TPressString;
    FChildNodes: TPressProjectItemParts;
    function GetCaption: string;
    procedure SetCaption(const Value: string);
  protected
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    class function InternalMetadataStr: string; override;
  public
    property ChildNodes: TPressProjectItemParts read FChildNodes;
  published
    property Caption: string read GetCaption write SetCaption;
  end;

  TPressProjectItemIterator = class;

  TPressProjectItemParts = class(TPressParts)
  private
    function GetObjects(AIndex: Integer): TPressProjectItem;
    procedure SetObjects(AIndex: Integer; const Value: TPressProjectItem);
  protected
    function InternalCreateIterator: TPressItemsIterator; override;
  public
    function Add(AClass: TPressObjectClass = nil): TPressProjectItem; overload;
    function Add(AObject: TPressProjectItem): Integer; overload;
    class function AttributeName: string; override;
    function CreateIterator: TPressProjectItemIterator;
    function IndexOf(AObject: TPressProjectItem): Integer;
    procedure Insert(AIndex: Integer; AObject: TPressProjectItem);
    function Remove(AObject: TPressProjectItem): Integer;
    class function ValidObjectClass: TPressObjectClass; override;
    property Objects[AIndex: Integer]: TPressProjectItem read GetObjects write SetObjects; default;
  end;

  TPressProjectItemIterator = class(TPressItemsIterator)
  private
    function GetCurrentItem: TPressProjectItem;
  public
    property CurrentItem: TPressProjectItem read GetCurrentItem;
  end;

  TPressAttributeMetadataRegistryParts = class;
  TPressProjectModule = class;

  TPressObjectMetadataRegistry = class(TPressProjectItem)
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

  TPressAttributeTypeRegistry = class(TPressProjectItem)
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

  TPressEnumerationRegistry = class(TPressProjectItem)
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

{ TPressProject }

function TPressProject.GetName: string;
begin
  Result := FName.Value;
end;

procedure TPressProject.Init;
begin
  inherited;
  { TODO : Improve }
  RootItems.Add.Caption := SPressProjectBusinessClasses;
  with RootItems[0].ChildNodes do
  begin
    Add(TPressObjectMetadataRegistry).Caption := SPressProjectPersistentClasses;
    Add(TPressObjectMetadataRegistry).Caption := SPressProjectQueryClasses;
    FRootPersistentClasses := Objects[0];
    FRootQueryClasses := Objects[1];
  end;
  RootItems.Add.Caption := SPressProjectMVPClasses;
  with RootItems[1].ChildNodes do
  begin
    Add.Caption := SPressProjectModels;
    Add.Caption := SPressProjectViews;
    Add.Caption := SPressProjectPresenters;
    Add.Caption := SPressProjectCommands;
    Add.Caption := SPressProjectInteractors;
    FRootModels := Objects[0];
    FRootViews := Objects[1];
    FRootPresenters := Objects[2];
    FRootCommands := Objects[3];
    FRootInteractors := Objects[4];
  end;
  RootItems.Add.Caption := SPressProjectRegistries;
  with RootItems[2].ChildNodes do
  begin
    Add.Caption := SPressProjectUserAttributes;
    Add.Caption := SPressProjectUserEnumerations;
    Add.Caption := SPressProjectUserOIDGenerators;
    FRootUserAttributes := Objects[0];
    FRootUserEnumerations := Objects[1];
    FRootUserGenerators := Objects[2];
  end;
  RootItems.Add.Caption := SPressProjectOtherClasses;
  with RootItems[3].ChildNodes do
  begin
    Add.Caption := SPressProjectForms;
    Add.Caption := SPressProjectFrames;
    Add.Caption := SPressProjectUnknown;
    FRootForms := Objects[0];
    FRootFrames := Objects[1];
    FRootUnknownClasses := Objects[2];
  end;
end;

function TPressProject.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'Name') then
    Result := Addr(FName)
  else if SameText(AAttributeName, 'RootItems') then
    Result := Addr(FRootItems)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressProject.InternalMetadataStr: string;
begin
  Result := 'TPressProject (' +
   'Name: String;' +
   'RootItems: PressProjectItemParts)';
end;

procedure TPressProject.SetName(const Value: string);
begin
  FName.Value := Value;
end;

{ TPressProjectItem }

function TPressProjectItem.GetCaption: string;
begin
  Result := FCaption.Value;
end;

function TPressProjectItem.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, 'Caption') then
    Result := Addr(FCaption)
  else if SameText(AAttributeName, 'ChildNodes') then
    Result := Addr(FChildNodes)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

class function TPressProjectItem.InternalMetadataStr: string;
begin
  Result := 'TPressProjectItem (' +
   'Caption: String;' +
   'ChildNodes: PressProjectItemParts)';
end;

procedure TPressProjectItem.SetCaption(const Value: string);
begin
  FCaption.Value := Value;
end;

{ TPressProjectItemParts }

function TPressProjectItemParts.Add(
  AClass: TPressObjectClass): TPressProjectItem;
begin
  Result := inherited Add(AClass) as TPressProjectItem;
end;

function TPressProjectItemParts.Add(AObject: TPressProjectItem): Integer;
begin
  Result := inherited Add(AObject);
end;

class function TPressProjectItemParts.AttributeName: string;
begin
  Result := 'PressProjectItemParts';
end;

function TPressProjectItemParts.CreateIterator: TPressProjectItemIterator;
begin
  Result := TPressProjectItemIterator.Create(ProxyList);
end;

function TPressProjectItemParts.GetObjects(
  AIndex: Integer): TPressProjectItem;
begin
  Result := inherited Objects[AIndex] as TPressProjectItem;
end;

function TPressProjectItemParts.IndexOf(
  AObject: TPressProjectItem): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressProjectItemParts.Insert(AIndex: Integer;
  AObject: TPressProjectItem);
begin
  inherited Insert(AIndex, AObject);
end;

function TPressProjectItemParts.InternalCreateIterator: TPressItemsIterator;
begin
  Result := CreateIterator;
end;

function TPressProjectItemParts.Remove(
  AObject: TPressProjectItem): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressProjectItemParts.SetObjects(AIndex: Integer;
  const Value: TPressProjectItem);
begin
  inherited Objects[AIndex] := Value;
end;

class function TPressProjectItemParts.ValidObjectClass: TPressObjectClass;
begin
  Result := TPressProjectItem;
end;

{ TPressProjectItemIterator }

function TPressProjectItemIterator.GetCurrentItem: TPressProjectItem;
begin
  Result := inherited CurrentItem as TPressProjectItem;
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
   'ChildNodes: PressProjectItemParts(TPressObjectMetadataRegistry);' +
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
   'ChildNodes: PressProjectItemParts(TPressAttributeTypeRegistry);' +
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
   'ChildNodes: PressProjectItemParts(TPressEnumerationRegistry);' +
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
  TPressProject.RegisterClass;
  TPressProjectItem.RegisterClass;
  TPressObjectMetadataRegistry.RegisterClass;
  TPressAttributeMetadataRegistry.RegisterClass;
  TPressAttributeTypeRegistry.RegisterClass;
  TPressEnumerationRegistry.RegisterClass;
  TPressProjectModule.RegisterClass;
end;

procedure RegisterAttributes;
begin
  TPressProjectItemParts.RegisterAttribute;
  TPressAttributeMetadataRegistryParts.RegisterAttribute;
end;

initialization
  RegisterClasses;
  RegisterAttributes;

end.
