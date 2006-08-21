(*
  PressObjects, MVP-Model Classes
  Copyright (C) 2006 Laserpress Ltda.

  http://www.pressobjects.org

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
*)

unit PressMVPModel;

interface

{$I Press.inc}

uses
  Classes,
  {$IFDEF D6+}Variants,{$ENDIF}
  PressClasses,
  PressNotifier,
  PressSubject,
  PressQuery,
  PressMVP;

type
  TPressMVPStructureModel = class;
  TPressMVPItemsModel = class;
  TPressMVPObjectModel = class;

  TPressMVPModelCreateFormEvent = class(TPressMVPModelEvent)
  end;

  TPressMVPModelCreateIncludeFormEvent = class(TPressMVPModelCreateFormEvent)
  end;

  TPressMVPModelCreatePresentFormEvent = class(TPressMVPModelCreateFormEvent)
  end;

  TPressMVPModelCreateSearchFormEvent = class(TPressMVPModelCreateFormEvent)
  end;

  TPressMVPModelUpdateSelectionEvent = class(TPressMVPModelEvent)
  end;

  TPressMVPModelCloseFormEvent = class(TPressMVPModelEvent)
  end;

  TPressMVPModelUpdateDataEvent = class(TPressMVPModelEvent)
  end;

  TPressMVPValueModel = class(TPressMVPModel)
  private
    function GetSubject: TPressValue;
    function GetValue: Variant;
    procedure SetValue(Value: Variant);
  public
    class function Apply: TPressSubjectClass; override;
    property Subject: TPressValue read GetSubject;
    property Value: Variant read GetValue write SetValue;
  end;

  TPressMVPDateModel = class(TPressMVPValueModel)
  protected
    procedure InitCommands; override;
  public
    class function Apply: TPressSubjectClass; override;
  end;

  TPressMVPPictureModel = class(TPressMVPValueModel)
  protected
    procedure InitCommands; override;
  public
    class function Apply: TPressSubjectClass; override;
  end;

  TPressMVPObjectSelection = class(TPressMVPSelection)
  private
    function GetObjects(Index: Integer): TPressObject;
  protected
    procedure InternalAssignObject(AObject: TObject); override;
    function InternalCreateIterator: TPressIterator; override;
    function InternalOwnsObjects: Boolean; override;
  public
    function CreateIterator: TPressObjectIterator;
    property Objects[Index: Integer]: TPressObject read GetObjects; default;
  end;

  TPressMVPStructureModel = class(TPressMVPModel)
  private
    function GetSelection: TPressMVPObjectSelection;
    function GetSubject: TPressStructure;
  protected
    function InternalCreateSelection: TPressMVPSelection; override;
  public
    property Selection: TPressMVPObjectSelection read GetSelection;
    property Subject: TPressStructure read GetSubject;
  end;

  TPressMVPReferenceQuery = class(TPressQuery)
    _Name: TPressString;
  private
    function GetName: string;
    procedure SetName(const Value: string);
  protected
    function InternalBuildWhereClause: string; override;
  published
    property Name: string read GetName write SetName;
  end;

  TPressMVPQueryModel = class;

  TPressMVPReferenceModel = class(TPressMVPStructureModel)
  private
    FMetadata: TPressQueryMetadata;
    FQuery: TPressMVPReferenceQuery;
    function GetMetadata: TPressQueryMetadata;
    function GetQuery: TPressMVPReferenceQuery;
    function GetSubject: TPressReference;
    function GetValue: TPressObject;
    procedure SetValue(Value: TPressObject);
  protected
    procedure InitCommands; override;
    procedure Notify(AEvent: TPressEvent); override;
    property Metadata: TPressQueryMetadata read GetMetadata;
  public
    constructor Create(AParent: TPressMVPModel; ASubject: TPressSubject); override;
    destructor Destroy; override;
    class function Apply: TPressSubjectClass; override;
    function CreateQueryIterator: TPressQueryIterator;
    procedure UpdateQuery(const ADisplayName, AQueryValue: string);
    property Query: TPressMVPReferenceQuery read GetQuery;
    property Subject: TPressReference read GetSubject;
    property Value: TPressObject read GetValue write SetValue;
  end;

  TPressMVPObjectList = class;

  TPressMVPObjectItem = class(TObject)
  private
    FAttributes: TPressAttributeList;
    FOwner: TPressMVPObjectList;
    FProxy: TPressProxy;
    function GetAttributes: TPressAttributeList;
    function GetDisplayText(ACol: Integer): string;
    function GetInstance: TPressObject;
  protected
    property Attributes: TPressAttributeList read GetAttributes;
  public
    constructor Create(AOwner: TPressMVPObjectList; AProxy: TPressProxy);
    destructor Destroy; override;
    function AddAttribute(AAttribute: TPressAttribute): Integer;
    procedure ClearAttributes;
    function HasAttributes: Boolean;
    property DisplayText[ACol: Integer]: string read GetDisplayText;
    property Instance: TPressObject read GetInstance;
    property Proxy: TPressProxy read FProxy;
  end;

  TPressMVPObjectIterator = class;

  TPressMVPObjectList = class(TPressList)
  { TODO : Implement column list }
  private
    FDisplayNameList: TStrings;
    FDisplayNames: string;
    procedure CreateAttributes(AObjectItem: TPressMVPObjectItem);
    function CreateObjectItem(AProxy: TPressProxy): TPressMVPObjectItem;
    function GetDisplayNameList: TStrings;
    function GetItems(AIndex: Integer): TPressMVPObjectItem;
    procedure ResetAttributes;
    procedure SetDisplayNames(const Value: string);
    procedure SetItems(AIndex: Integer; Value: TPressMVPObjectItem);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
    property DisplayNameList: TStrings read GetDisplayNameList;
  public
    destructor Destroy; override;
    function Add(AObject: TPressMVPObjectItem): Integer;
    function AddProxy(AProxy: TPressProxy): Integer;
    function CreateIterator: TPressMVPObjectIterator;
    function Extract(AObject: TPressMVPObjectItem): TPressMVPObjectItem;
    function IndexOf(AObject: TPressMVPObjectItem): Integer;
    function IndexOfInstance(AObject: TPressObject): Integer;
    function IndexOfProxy(AProxy: TPressProxy): Integer;
    procedure Insert(Index: Integer; AObject: TPressMVPObjectItem);
    procedure InsertProxy(Index: Integer; AProxy: TPressProxy);
    procedure Reindex;
    function Remove(AObject: TPressMVPObjectItem): Integer;
    function RemoveProxy(AProxy: TPressProxy): Integer;
    property DisplayNames: string read FDisplayNames write SetDisplayNames;
    property Items[AIndex: Integer]: TPressMVPObjectItem read GetItems write SetItems; default;
  end;

  TPressMVPObjectIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressMVPObjectItem;
  public
    property CurrentItem: TPressMVPObjectItem read GetCurrentItem;
  end;

  TPressMVPItemsModel = class(TPressMVPStructureModel)
  private
    FObjectList: TPressMVPObjectList;
    function GetDisplayNames: string;
    function GetObjectList: TPressMVPObjectList;
    function GetObjects(AIndex: Integer): TPressObject;
    function GetSubject: TPressItems;
    procedure ItemsChanged(AEvent: TPressItemsChangedEvent);
    procedure RebuildObjectList;
    procedure SetDisplayNames(const Value: string);
  protected
    procedure InitCommands; override;
    procedure InternalCreateAddCommands; virtual;
    procedure InternalCreateEditCommands; virtual;
    procedure InternalCreateRemoveCommands; virtual;
    procedure Notify(AEvent: TPressEvent); override;
    property ObjectList: TPressMVPObjectList read GetObjectList;
  public
    constructor Create(AParent: TPressMVPModel; ASubject: TPressSubject); override;
    destructor Destroy; override;
    function Count: Integer;
    function DisplayText(ACol, ARow: Integer): string;
    function IndexOf(AObject: TPressObject): Integer;
    procedure SelectIndex(AIndex: Integer);
    function TextAlignment(ACol: Integer): TAlignment;
    property DisplayNames: string read GetDisplayNames write SetDisplayNames;
    property Objects[AIndex: Integer]: TPressObject read GetObjects; default;
    property Subject: TPressItems read GetSubject;
  end;

  TPressMVPPartsModel = class(TPressMVPItemsModel)
  public
    class function Apply: TPressSubjectClass; override;
  end;

  TPressMVPReferencesModel = class(TPressMVPItemsModel)
  protected
    procedure InternalCreateAddCommands; override;
  public
    class function Apply: TPressSubjectClass; override;
  end;

  TPressMVPModelSelection = class(TPressMVPSelection)
  end;

  TPressMVPObjectModelClass = class of TPressMVPObjectModel;

  TPressMVPObjectModel = class(TPressMVPModel)
  private
    FHookedSubject: TPressStructure;
    FIsIncluding: Boolean;
    FObjectMemento: TPressObjectMemento;
    FSubModels: TPressMVPModelList;
    procedure AfterChangeHookedSubject;
    procedure BeforeChangeHookedSubject;
    function GetIsChanged: Boolean;
    function GetSelection: TPressMVPModelSelection;
    function GetSubject: TPressObject;
    function GetSubModels: TPressMVPModelList;
    procedure SetHookedSubject(Value: TPressStructure);
  protected
    procedure InitCommands; override;
    function InternalCreateSelection: TPressMVPSelection; override;
    procedure Notify(AEvent: TPressEvent); override;
    property SubModels: TPressMVPModelList read GetSubModels;
  public
    constructor Create(AParent: TPressMVPModel; ASubject: TPressSubject); override;
    destructor Destroy; override;
    class function Apply: TPressSubjectClass; override;
    function HasHookedSubject: Boolean;
    procedure RevertChanges;
    procedure UpdateData;
    property HookedSubject: TPressStructure read FHookedSubject write SetHookedSubject;
    property IsChanged: Boolean read GetIsChanged;
    property IsIncluding: Boolean read FIsIncluding write FIsIncluding;
    property Selection: TPressMVPModelSelection read GetSelection;
    property Subject: TPressObject read GetSubject;
  end;

  TPressMVPQueryModel = class(TPressMVPObjectModel)
  private
    function GetSubject: TPressQuery;
  protected
    procedure InitCommands; override;
  public
    class function Apply: TPressSubjectClass; override;
    procedure Clear;
    procedure Execute;
    property Subject: TPressQuery read GetSubject;
  end;

implementation

uses
  SysUtils,
  PressConsts,
  PressMVPCommand;

{ TPressMVPValueModel }

class function TPressMVPValueModel.Apply: TPressSubjectClass;
begin
  Result := TPressValue;
end;

function TPressMVPValueModel.GetSubject: TPressValue;
begin
  Result := inherited Subject as TPressValue;
end;

function TPressMVPValueModel.GetValue: Variant;
begin
  { TODO : RTTI }
  Result := Subject.AsVariant;
end;

procedure TPressMVPValueModel.SetValue(Value: Variant);
begin
  { TODO : RTTI }
  Subject.AsVariant := Value;
end;

{ TPressMVPDateModel }

class function TPressMVPDateModel.Apply: TPressSubjectClass;
begin
  { TODO : implement TPressSubjectClasses as result type
    Result := [TPressDate, TPressDateTime]; }
  Result := TPressDate;
end;

procedure TPressMVPDateModel.InitCommands;
begin
  inherited;
  AddCommand(TPressMVPTodayCommand);
end;

{ TPressMVPPictureModel }

class function TPressMVPPictureModel.Apply: TPressSubjectClass;
begin
  Result := TPressPicture;
end;

procedure TPressMVPPictureModel.InitCommands;
begin
  inherited;
  AddCommands([TPressMVPLoadPictureCommand, TPressMVPRemovePictureCommand]);
end;

{ TPressMVPReferenceQuery }

function TPressMVPReferenceQuery.GetName: string;
begin
  Result := _Name.Value;
end;

function TPressMVPReferenceQuery.InternalBuildWhereClause: string;
begin
  if Name <> '' then
    Result := Format('%s LIKE "%%%s%%"',  { do not localize }
     [_Name.PersistentName, Name])
  else
    Result := '';
end;

procedure TPressMVPReferenceQuery.SetName(const Value: string);
begin
  _Name.Value := Value;
end;

{ TPressMVPObjectSelection }

function TPressMVPObjectSelection.CreateIterator: TPressObjectIterator;
begin
  Result := TPressObjectIterator.Create(ObjectList);
end;

function TPressMVPObjectSelection.GetObjects(Index: Integer): TPressObject;
begin
  Result := inherited Objects[Index] as TPressObject;
end;

procedure TPressMVPObjectSelection.InternalAssignObject(AObject: TObject);
begin
  if AObject is TPressObject then
    TPressObject(AObject).AddRef;
end;

function TPressMVPObjectSelection.InternalCreateIterator: TPressIterator;
begin
  Result := CreateIterator;
end;

function TPressMVPObjectSelection.InternalOwnsObjects: Boolean;
begin
  Result := True;
end;

{ TPressMVPStructureModel }

function TPressMVPStructureModel.GetSelection: TPressMVPObjectSelection;
begin
  Result := inherited Selection as TPressMVPObjectSelection;
end;

function TPressMVPStructureModel.GetSubject: TPressStructure;
begin
  Result := inherited Subject as TPressStructure;
end;

function TPressMVPStructureModel.InternalCreateSelection: TPressMVPSelection;
begin
  Result := TPressMVPObjectSelection.Create;
end;

{ TPressMVPReferenceModel }

class function TPressMVPReferenceModel.Apply: TPressSubjectClass;
begin
  Result := TPressReference;
end;

constructor TPressMVPReferenceModel.Create(
  AParent: TPressMVPModel; ASubject: TPressSubject);
begin
  inherited Create(AParent, ASubject);
  if HasSubject then
    Selection.SelectObject(Subject.Value);
end;

function TPressMVPReferenceModel.CreateQueryIterator: TPressQueryIterator;
begin
  Result := Query.CreateIterator;
end;

destructor TPressMVPReferenceModel.Destroy;
begin
  PressUnregisterMetadata(FMetadata);
  FQuery.Free;
  inherited;
end;

function TPressMVPReferenceModel.GetMetadata: TPressQueryMetadata;
const
  { TODO : Fix Metadata parser - "Any:" }
  CQueryMetadata = '%s(%s) Any: Order: Name; Name: String;';
begin
  if not Assigned(FMetadata) then
    FMetadata := PressRegisterMetadata(Format(
     CQueryMetadata, [TPressMVPReferenceQuery.ClassName,
     Subject.ObjectClass.ClassMetadata.PersistentName])) as TPressQueryMetadata;
  Result := FMetadata;
end;

function TPressMVPReferenceModel.GetQuery: TPressMVPReferenceQuery;
begin
  if not Assigned(FQuery) then
    FQuery := TPressMVPReferenceQuery.Create(Metadata);
  Result := FQuery;
end;

function TPressMVPReferenceModel.GetSubject: TPressReference;
begin
  Result := inherited Subject as TPressReference;
end;

function TPressMVPReferenceModel.GetValue: TPressObject;
begin
  { TODO : RTTI }
  Result := Subject.Value;
end;

procedure TPressMVPReferenceModel.InitCommands;
begin
  inherited;
  AddCommands([TPressMVPIncludeObjectCommand, TPressMVPEditItemCommand]);
end;

procedure TPressMVPReferenceModel.Notify(AEvent: TPressEvent);
begin
  inherited;
  if (AEvent is TPressAttributeChangedEvent) and HasSubject then
    Selection.SelectObject(Subject.Value);
end;

procedure TPressMVPReferenceModel.SetValue(Value: TPressObject);
begin
  { TODO : RTTI }
  Subject.Value := Value;
end;

procedure TPressMVPReferenceModel.UpdateQuery(
  const ADisplayName, AQueryValue: string);
begin
  Query._Name.Metadata.PersistentName := ADisplayName;
  Query.Name := AQueryValue;
  Query.UpdateReferenceList;
end;

{ TPressMVPObjectItem }

function TPressMVPObjectItem.AddAttribute(
  AAttribute: TPressAttribute): Integer;
begin
  Result := Attributes.Add(AAttribute);
  if Assigned(AAttribute) then
    AAttribute.AddRef;
end;

procedure TPressMVPObjectItem.ClearAttributes;
begin
  FreeAndNil(FAttributes);
end;

constructor TPressMVPObjectItem.Create(
  AOwner: TPressMVPObjectList; AProxy: TPressProxy);
begin
  inherited Create;
  FOwner := AOwner;
  FProxy := AProxy;
  FProxy.AddRef;
end;

destructor TPressMVPObjectItem.Destroy;
begin
  FProxy.Free;
  FAttributes.Free;
  inherited;
end;

function TPressMVPObjectItem.GetAttributes: TPressAttributeList;
begin
  if not Assigned(FAttributes) then
    FAttributes := TPressAttributeList.Create(True);
  Result := FAttributes;
end;

function TPressMVPObjectItem.GetDisplayText(ACol: Integer): string;
begin
  if Assigned(Attributes[ACol]) then
    Result := Attributes[ACol].DisplayText
  else
    Result := '';
end;

function TPressMVPObjectItem.GetInstance: TPressObject;
begin
  Result := Proxy.Instance;
end;

function TPressMVPObjectItem.HasAttributes: Boolean;
begin
  Result := Assigned(FAttributes);
end;

{ TPressMVPObjectList }

function TPressMVPObjectList.Add(AObject: TPressMVPObjectItem): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressMVPObjectList.AddProxy(AProxy: TPressProxy): Integer;
var
  VObjItem: TPressMVPObjectItem;
begin
  VObjItem := CreateObjectItem(AProxy);
  try
    Result := Add(VObjItem);
  except
    VObjItem.Free;
    raise;
  end;
end;

procedure TPressMVPObjectList.CreateAttributes(
  AObjectItem: TPressMVPObjectItem);
var
  VAttr: TPressAttribute;
  I: Integer;
begin
  for I := 0 to Pred(DisplayNameList.Count) do
  begin
    VAttr := AObjectItem.Instance.FindPathAttribute(DisplayNameList[I]);
    AObjectItem.AddAttribute(VAttr);
  end;
end;

function TPressMVPObjectList.CreateIterator: TPressMVPObjectIterator;
begin
  Result := TPressMVPObjectIterator.Create(Self);
end;

function TPressMVPObjectList.CreateObjectItem(
  AProxy: TPressProxy): TPressMVPObjectItem;
begin
  Result := TPressMVPObjectItem.Create(Self, AProxy);
end;

destructor TPressMVPObjectList.Destroy;
begin
  FDisplayNameList.Free;
  inherited;
end;

function TPressMVPObjectList.Extract(
  AObject: TPressMVPObjectItem): TPressMVPObjectItem;
begin
  Result := inherited Extract(AObject) as TPressMVPObjectItem;
end;

function TPressMVPObjectList.GetDisplayNameList: TStrings;
begin
  if not Assigned(FDisplayNameList) then
    FDisplayNameList := TStringList.Create;
  Result := FDisplayNameList;
end;

function TPressMVPObjectList.GetItems(
  AIndex: Integer): TPressMVPObjectItem;
begin
  Result := inherited Items[AIndex] as TPressMVPObjectItem;
  if not Result.HasAttributes then
    CreateAttributes(Result);
end;

function TPressMVPObjectList.IndexOf(
  AObject: TPressMVPObjectItem): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

function TPressMVPObjectList.IndexOfInstance(
  AObject: TPressObject): Integer;
begin
  for Result := 0 to Pred(Count) do
    with Items[Result].Proxy do
      if HasInstance and (Instance = AObject) then
        Exit;
  Result := -1;
end;

function TPressMVPObjectList.IndexOfProxy(AProxy: TPressProxy): Integer;
begin
  for Result := 0 to Pred(Count) do
    if Items[Result].Proxy = AProxy then
      Exit;
  Result := -1;
end;

procedure TPressMVPObjectList.Insert(Index: Integer;
  AObject: TPressMVPObjectItem);
begin
  inherited Insert(Index, AObject);
end;

procedure TPressMVPObjectList.InsertProxy(
  Index: Integer; AProxy: TPressProxy);
var
  VObjItem: TPressMVPObjectItem;
begin
  VObjItem := CreateObjectItem(AProxy);
  try
    Insert(Index, VObjItem);
  except
    VObjItem.Free;
    raise;
  end;
end;

function TPressMVPObjectList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

procedure TPressMVPObjectList.Reindex;
begin
  { TODO : Implement }
end;

function TPressMVPObjectList.Remove(AObject: TPressMVPObjectItem): Integer;
begin
  Result := inherited Remove(AObject);
end;

function TPressMVPObjectList.RemoveProxy(AProxy: TPressProxy): Integer;
begin
  Result := IndexOfProxy(AProxy);
  if Result >= 0 then
    Delete(Result);
end;

procedure TPressMVPObjectList.ResetAttributes;
begin
  with CreateIterator do
  try
    BeforeFirstItem;
    while NextItem do
      CurrentItem.ClearAttributes;
  finally
    Free;
  end;
end;

procedure TPressMVPObjectList.SetDisplayNames(const Value: string);
begin
  if FDisplayNames <> Value then
  begin
    FDisplayNames := Value;
    DisplayNameList.Text := Value;
    ResetAttributes;
  end;
end;

procedure TPressMVPObjectList.SetItems(
  AIndex: Integer; Value: TPressMVPObjectItem);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressMVPObjectIterator }

function TPressMVPObjectIterator.GetCurrentItem: TPressMVPObjectItem;
begin
  Result := inherited CurrentItem as TPressMVPObjectItem;
end;

{ TPressMVPItemsModel }

function TPressMVPItemsModel.Count: Integer;
begin
  if Assigned(FObjectList) then
    Result := FObjectList.Count
  else
    Result := 0;
end;

constructor TPressMVPItemsModel.Create(
  AParent: TPressMVPModel; ASubject: TPressSubject);
begin
  inherited Create(AParent, ASubject);
  RebuildObjectList;
end;

destructor TPressMVPItemsModel.Destroy;
begin
  FObjectList.Free;
  inherited;
end;

function TPressMVPItemsModel.DisplayText(ACol, ARow: Integer): string;
begin
  if ARow < ObjectList.Count then
    Result := ObjectList[ARow].DisplayText[ACol];
end;

function TPressMVPItemsModel.GetDisplayNames: string;
begin
  Result := ObjectList.DisplayNames;
end;

function TPressMVPItemsModel.GetObjectList: TPressMVPObjectList;
begin
  if not Assigned(FObjectList) then
    FObjectList := TPressMVPObjectList.Create(True);
  Result := FObjectList;
end;

function TPressMVPItemsModel.GetObjects(AIndex: Integer): TPressObject;
begin
  Result := ObjectList[AIndex].Instance;
end;

function TPressMVPItemsModel.GetSubject: TPressItems;
begin
  Result := inherited Subject as TPressItems;
end;

function TPressMVPItemsModel.IndexOf(AObject: TPressObject): Integer;
begin
  Result := ObjectList.IndexOfInstance(AObject);
end;

procedure TPressMVPItemsModel.InitCommands;
begin
  inherited;
  InternalCreateAddCommands;
  InternalCreateEditCommands;
  InternalCreateRemoveCommands;
end;

procedure TPressMVPItemsModel.InternalCreateAddCommands;
begin
  AddCommand(TPressMVPAddItemsCommand);
end;

procedure TPressMVPItemsModel.InternalCreateEditCommands;
begin
  AddCommand(TPressMVPEditItemCommand);
end;

procedure TPressMVPItemsModel.InternalCreateRemoveCommands;
begin
  AddCommand(TPressMVPRemoveItemsCommand);
end;

procedure TPressMVPItemsModel.ItemsChanged(
  AEvent: TPressItemsChangedEvent);

  procedure AddItem;
  begin
    ObjectList.AddProxy(AEvent.Proxy);
    if AEvent.Proxy.HasInstance then
      Selection.SelectObject(AEvent.Proxy.Instance);
  end;

  procedure InsertItem;
  begin
    { TODO : Verify the correct index (when sorted) }
    ObjectList.InsertProxy(AEvent.Index, AEvent.Proxy);
  end;

  procedure ModifyItem;
  var
    VIndex: Integer;
  begin
    VIndex := ObjectList.IndexOfProxy(AEvent.Proxy);
    if VIndex >= 0 then
      ObjectList[VIndex].ClearAttributes;
  end;

  procedure RemoveItem;
  begin
    ObjectList.RemoveProxy(AEvent.Proxy);
    if AEvent.Proxy.HasInstance then
      Selection.RemoveObject(AEvent.Proxy.Instance);
    if Selection.Count = 0 then
      TPressMVPModelUpdateSelectionEvent.Create(Self).Notify;
  end;

  procedure ClearItems;
  begin
    ObjectList.Clear;
    Selection.SelectObject(nil);
  end;

begin
  case AEvent.EventType of
    ietAdd:
      AddItem;
    ietInsert:
      InsertItem;
    ietModify, ietNotify:
      ModifyItem;
    ietRemove:
      RemoveItem;
    ietClear:
      ClearItems;
    ietRebuild:
      RebuildObjectList;
  end;
  if AEvent.EventType <> ietNotify then
    Changed;
end;

procedure TPressMVPItemsModel.Notify(AEvent: TPressEvent);
begin
  if AEvent is TPressItemsChangedEvent then
    ItemsChanged(TPressItemsChangedEvent(AEvent))
  else
    inherited;
end;

procedure TPressMVPItemsModel.RebuildObjectList;
var
  I: Integer;
begin
  ObjectList.Clear;
  for I := 0 to Pred(Subject.Count) do
    ObjectList.AddProxy(Subject.Proxies[I]);
  ObjectList.Reindex;
  if ObjectList.Count > 0 then
    Selection.SelectObject(ObjectList[0].Instance)
  else
    Selection.SelectObject(nil);
end;

procedure TPressMVPItemsModel.SelectIndex(AIndex: Integer);
begin
  Selection.SelectObject(ObjectList[AIndex].Instance);
end;

procedure TPressMVPItemsModel.SetDisplayNames(const Value: string);
begin
  ObjectList.DisplayNames := Value;
end;

function TPressMVPItemsModel.TextAlignment(ACol: Integer): TAlignment;
begin
  Result := taLeftJustify;
end;

{ TPressMVPPartsModel }

class function TPressMVPPartsModel.Apply: TPressSubjectClass;
begin
  Result := TPressParts;
end;

{ TPressMVPReferencesModel }

class function TPressMVPReferencesModel.Apply: TPressSubjectClass;
begin
  Result := TPressReferences;
end;

procedure TPressMVPReferencesModel.InternalCreateAddCommands;
begin
  if HasSubject and (Subject.Owner is TPressQuery) and
   (Subject.Name = SPressQueryItemsString) then
    inherited
   else
    AddCommand(TPressMVPAddReferencesCommand)
end;

{ TPressMVPObjectModel }

procedure TPressMVPObjectModel.AfterChangeHookedSubject;
begin
  if Assigned(FHookedSubject) then
  begin
    FHookedSubject.AddRef;
    Notifier.AddNotificationItem(FHookedSubject,
     [TPressStructureUnassignObjectEvent]);
  end;
end;

class function TPressMVPObjectModel.Apply: TPressSubjectClass;
begin
  Result := TPressObject;
end;

procedure TPressMVPObjectModel.BeforeChangeHookedSubject;
begin
  if Assigned(FHookedSubject) then
  begin
    Notifier.RemoveNotificationItem(FHookedSubject);
    FreeAndNil(FHookedSubject);
  end;
end;

constructor TPressMVPObjectModel.Create(
  AParent: TPressMVPModel; ASubject: TPressSubject);
begin
  inherited Create(AParent, ASubject);
  if Assigned(ASubject) then
    FObjectMemento := (ASubject as TPressObject).CreateMemento;
end;

destructor TPressMVPObjectModel.Destroy;
begin
  FHookedSubject.Free;
  FSubModels.Free;
  FObjectMemento.Free;
  inherited;
end;

function TPressMVPObjectModel.GetIsChanged: Boolean;
begin
  Result := Assigned(FObjectMemento) and FObjectMemento.SubjectChanged;
end;

function TPressMVPObjectModel.GetSelection: TPressMVPModelSelection;
begin
  Result := inherited Selection as TPressMVPModelSelection;
end;

function TPressMVPObjectModel.GetSubject: TPressObject;
begin
  Result := inherited Subject as TPressObject;
  if not Assigned(Result) then
    raise EPressMVPError.Create(SUnassignedSubject);
end;

function TPressMVPObjectModel.GetSubModels: TPressMVPModelList;
begin
  if not Assigned(FSubModels) then
    FSubModels := TPressMVPModelList.Create(True);
  Result := FSubModels;
end;

function TPressMVPObjectModel.HasHookedSubject: Boolean;
begin
  Result := Assigned(FHookedSubject);
end;

procedure TPressMVPObjectModel.InitCommands;
begin
  inherited;
  AddCommands([TPressMVPSaveObjectCommand, TPressMVPCancelObjectCommand]);
end;

function TPressMVPObjectModel.InternalCreateSelection: TPressMVPSelection;
begin
  Result := TPressMVPModelSelection.Create;
end;

procedure TPressMVPObjectModel.Notify(AEvent: TPressEvent);
begin
  inherited;
  if (AEvent is TPressStructureUnassignObjectEvent) and
   (TPressStructureUnassignObjectEvent(AEvent).UnassignedObject = Subject) then
    TPressMVPModelCloseFormEvent.Create(Self).Notify;
end;

procedure TPressMVPObjectModel.RevertChanges;
begin
  if Assigned(FObjectMemento) then
    FObjectMemento.Restore;
end;

procedure TPressMVPObjectModel.SetHookedSubject(Value: TPressStructure);
begin
  BeforeChangeHookedSubject;
  FHookedSubject := Value;
  AfterChangeHookedSubject;
end;

procedure TPressMVPObjectModel.UpdateData;
begin
  with Selection.CreateIterator do
  try
    BeforeFirstItem;
    while NextItem do
      TPressMVPModelUpdateDataEvent.Create(CurrentItem).Notify;
  finally
    Free;
  end;
end;

{ TPressMVPQueryModel }

class function TPressMVPQueryModel.Apply: TPressSubjectClass;
begin
  Result := TPressQuery;
end;

procedure TPressMVPQueryModel.Clear;
begin
  Subject.Clear;
end;

procedure TPressMVPQueryModel.Execute;
begin
  Subject.UpdateReferenceList;
end;

function TPressMVPQueryModel.GetSubject: TPressQuery;
begin
  Result := inherited Subject as TPressQuery;
  if not Assigned(Result) then
    raise EPressMVPError.Create(SUnassignedSubject);
end;

procedure TPressMVPQueryModel.InitCommands;
begin
  //inherited;
  { TODO : inherited Save can persist all changed objects }
  AddCommand(TPressMVPExecuteQueryCommand);
end;

procedure RegisterModels;
begin
  TPressMVPValueModel.RegisterModel;
  TPressMVPDateModel.RegisterModel;
  TPressMVPPictureModel.RegisterModel;
  TPressMVPReferenceModel.RegisterModel;
  TPressMVPPartsModel.RegisterModel;
  TPressMVPReferencesModel.RegisterModel;
  TPressMVPObjectModel.RegisterModel;
  TPressMVPQueryModel.RegisterModel;
end;

procedure RegisterClasses;
begin
  TPressMVPReferenceQuery.RegisterClass;
end;

procedure RegisterMetadatas;
begin
  PressRegisterMetadata(
   'TPressMVPReferenceQuery(TPressObject);;');
end;

initialization
  RegisterModels;
  RegisterClasses;
  RegisterMetadatas;

end.
