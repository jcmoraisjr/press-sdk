(*
  PressObjects, Base MVP Classes
  Copyright (C) 2006-2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressMVP;

{$I Press.inc}

interface

uses
  Classes,
  Contnrs,
  Controls,
  Menus,
  PressClasses,
  PressNotifier,
  PressSubject,
  PressUser;

type
  EPressMVPError = class(EPressError);

  TPressMVPCommand = class;

  TPressMVPCommandComponent = class(TObject)
  private
    FCommand: TPressMVPCommand;
    FOnClickEvent: TNotifyEvent;
  protected
    procedure BindComponent; virtual; abstract;
    procedure ComponentClick(Sender: TObject);
    function GetEnabled: Boolean; virtual; abstract;
    function GetVisible: Boolean; virtual; abstract;
    procedure ReleaseComponent; virtual; abstract;
    procedure SetEnabled(Value: Boolean); virtual; abstract;
    procedure SetVisible(Value: Boolean); virtual; abstract;
    property OnClickEvent: TNotifyEvent read FOnClickEvent write FOnClickEvent;
  public
    constructor Create(ACommand: TPressMVPCommand);
    destructor Destroy; override;
    property Command: TPressMVPCommand read FCommand;
    property Enabled: Boolean read GetEnabled write SetEnabled;
    property Visible: Boolean read GetVisible write SetVisible;
  end;

  TPressMVPCommandMenuItem = class(TPressMVPCommandComponent)
  private
    FMenuItem: TMenuItem;
  protected
    procedure BindComponent; override;
    function GetEnabled: Boolean; override;
    function GetVisible: Boolean; override;
    procedure ReleaseComponent; override;
    procedure SetEnabled(Value: Boolean); override;
    procedure SetVisible(Value: Boolean); override;
  public
    constructor Create(ACommand: TPressMVPCommand; AMenuItem: TMenuItem);
  end;

  TPressMVPCommandControl = class(TPressMVPCommandComponent)
  private
    FControl: TControl;
  protected
    procedure BindComponent; override;
    function GetEnabled: Boolean; override;
    function GetVisible: Boolean; override;
    procedure ReleaseComponent; override;
    procedure SetEnabled(Value: Boolean); override;
    procedure SetVisible(Value: Boolean); override;
  public
    constructor Create(ACommand: TPressMVPCommand; AControl: TControl);
  end;

  TPressMVPCommandComponentIterator = class;

  TPressMVPCommandComponentList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressMVPCommandComponent;
    procedure SetEnabled(Value: Boolean);
    procedure SetItems(AIndex: Integer; Value: TPressMVPCommandComponent);
    procedure SetVisible(Value: Boolean);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressMVPCommandComponent): Integer;
    function CreateIterator: TPressMVPCommandComponentIterator;
    function Extract(AObject: TPressMVPCommandComponent): TPressMVPCommandComponent;
    function IndexOf(AObject: TPressMVPCommandComponent): Integer;
    procedure Insert(Index: Integer; AObject: TPressMVPCommandComponent);
    function Remove(AObject: TPressMVPCommandComponent): Integer;
    property Enabled: Boolean write SetEnabled;
    property Items[AIndex: Integer]: TPressMVPCommandComponent read GetItems write SetItems; default;
    property Visible: Boolean write SetVisible;
  end;

  TPressMVPCommandComponentIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressMVPCommandComponent;
  public
    property CurrentItem: TPressMVPCommandComponent read GetCurrentItem;
  end;

  TPressMVPCommandChangedEvent = class(TPressEvent)
  end;

  TPressMVPModel = class;
  TPressMVPCommandRegistry = class;

  TPressMVPCommandClass = class of TPressMVPCommand;

  TPressMVPCommand = class(TObject)
  private
    FCaption: string;
    FComponentList: TPressMVPCommandComponentList;
    FEnabled: Boolean;
    FExecutable: Boolean;
    FModel: TPressMVPModel;
    FNotifier: TPressNotifier;
    FShortCut: TShortCut;
    FVisible: Boolean;
    function CurrentUser: TPressUser;
    function GetComponentList: TPressMVPCommandComponentList;
    procedure Notify(AEvent: TPressEvent);
    procedure VerifyAccess;
    function VerifyEnabled: Boolean;
  protected
    function GetCaption: string; virtual;
    function GetShortCut: TShortCut; virtual;
    procedure InitNotifier; virtual;
    procedure InternalExecute; virtual; abstract;
    function InternalIsEnabled: Boolean; virtual;
    property ComponentList: TPressMVPCommandComponentList read GetComponentList;
    property Notifier: TPressNotifier read FNotifier;
  public
    constructor Create(AModel: TPressMVPModel; const ACaption: string = ''; AShortCut: TShortCut = 0); virtual;
    destructor Destroy; override;
    procedure AddComponent(AComponent: TComponent);
    class function Apply(AModel: TPressMVPModel): Boolean; virtual;
    procedure Execute;
    class function RegisterCommand: TPressMVPCommandRegistry;
    property Caption: string read GetCaption;
    property Enabled: Boolean read FEnabled;
    property Model: TPressMVPModel read FModel;
    property ShortCut: TShortCut read GetShortCut;
    property Visible: Boolean read FVisible;
  end;

  TPressMVPCommandIterator = class;

  TPressMVPCommandList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressMVPCommand;
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressMVPCommand): Integer;
    function CreateIterator: TPressMVPCommandIterator;
    function FindCommand(ACommandClass: TPressMVPCommandClass): TPressMVPCommand;
    function IndexOf(AObject: TPressMVPCommand): Integer;
    procedure Insert(Index: Integer; AObject: TPressMVPCommand);
    function Remove(AObject: TPressMVPCommand): Integer;
    property Items[AIndex: Integer]: TPressMVPCommand read GetItems; default;
  end;

  TPressMVPCommandIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressMVPCommand;
  public
    property CurrentItem: TPressMVPCommand read GetCurrentItem;
  end;

  TPressMVPCommandRegistry = class(TObject)
  private
    FAccessID: Integer;
    FAlwaysEnabled: Boolean;
    FCommandClass: TPressMVPCommandClass;
    FEnabledIfNoUser: Boolean;
  public
    constructor Create(ACommandClass: TPressMVPCommandClass);
    property AccessID: Integer read FAccessID write FAccessID;
    property AlwaysEnabled: Boolean read FAlwaysEnabled write FAlwaysEnabled;
    property CommandClass: TPressMVPCommandClass read FCommandClass;
    property EnabledIfNoUser: Boolean read FEnabledIfNoUser write FEnabledIfNoUser;
  end;

  TPressMVPCommandRegistryIterator = class;

  TPressMVPCommandRegistryList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressMVPCommandRegistry;
    procedure SetItems(AIndex: Integer; Value: TPressMVPCommandRegistry);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressMVPCommandRegistry): Integer;
    function CreateIterator: TPressMVPCommandRegistryIterator;
    function Extract(AObject: TPressMVPCommandRegistry): TPressMVPCommandRegistry;
    function IndexOf(AObject: TPressMVPCommandRegistry): Integer;
    function IndexOfCommand(ACommandClass: TPressMVPCommandClass): Integer;
    procedure Insert(AIndex: Integer; AObject: TPressMVPCommandRegistry);
    function Remove(AObject: TPressMVPCommandRegistry): Integer;
    property Items[AIndex: Integer]: TPressMVPCommandRegistry read GetItems write SetItems; default;
  end;

  TPressMVPCommandRegistryIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressMVPCommandRegistry;
  public
    property CurrentItem: TPressMVPCommandRegistry read GetCurrentItem;
  end;

  TPressMVPCommands = class(TObject)
  private
    FItems: TPressMVPCommandList;
    function GetCount: Integer;
    function GetItem(AIndex: Integer): TPressMVPCommand;
    function GetItems: TPressMVPCommandList;
  protected
    property Items: TPressMVPCommandList read GetItems;
  public
    destructor Destroy; override;
    function Add(ACommand: TPressMVPCommand): Integer;
    function FindCommand(ACommandClass: TPressMVPCommandClass): TPressMVPCommand;
    property Count: Integer read GetCount;
    property Item[AIndex: Integer]: TPressMVPCommand read GetItem; default;
  end;

  TPressMVPCommandMenu = class(TObject)
  protected
    procedure InternalAddItem(ACommand: TPressMVPCommand); virtual; abstract;
    procedure InternalAssignMenu(AControl: TControl); virtual; abstract;
    procedure InternalClearMenuItems; virtual; abstract;
  public
    procedure AssignCommands(ACommands: TPressMVPCommands);
    procedure AssignMenu(AControl: TControl);
    procedure UnassignCommands;
  end;

  TPressMVPObjectClass = class of TPressMVPObject;

  TPressMVPObject = class(TPersistent)
  private
    FDisableCount: Integer;
    FNotifierList: TObjectList;
    function GetEventsDisabled: Boolean;
  protected
    class procedure CheckClass(AApplyClass: Boolean);
  public
    destructor Destroy; override;
    procedure AddNotification(AEventClasses: array of TPressEventClass; AMethod: TPressNotificationEvent);
    procedure DisableEvents;
    procedure EnableEvents;
    property EventsDisabled: Boolean read GetEventsDisabled;
  end;

  TPressMVPSelectionChangedEvent = class(TPressEvent)
  end;

  TPressMVPSelection = class(TObject)
  private
    FFocus: TObject;
    FObjectList: TPressList;
    FStrongSelection: Boolean;
    FUpdatesPending: Boolean;
    FUpdatingCount: Integer;
    function DoAddObject(AObject: TObject): Integer;
    procedure DoNotify;
    function GetObjectList: TPressList;
    function GetObjects(AIndex: Integer): TObject;
    procedure SetFocus(Value: TObject);
    procedure SetStrongSelection(Value: Boolean);
  protected
    procedure InternalAssignObject(AObject: TObject); virtual;
    function InternalCreateIterator: TPressIterator; virtual;
    function InternalOwnsObjects: Boolean; virtual;
    property ObjectList: TPressList read GetObjectList;
  public
    destructor Destroy; override;
    function Add(AObject: TObject): Integer;
    procedure BeginUpdate;
    procedure Clear;
    function Count: Integer;
    function CreateIterator: TPressIterator;
    procedure EndUpdate;
    function HasStrongSelection(AObject: TObject): Boolean;
    function IndexOf(AObject: TObject): Integer;
    function IsSelected(AObject: TObject): Boolean;
    function Remove(AObject: TObject): Integer;
    procedure Select(AObject: TObject);
    property Focus: TObject read FFocus write SetFocus;
    property Objects[AIndex: Integer]: TObject read GetObjects; default;
    property StrongSelection: Boolean read FStrongSelection write SetStrongSelection;
  end;

  TPressMVPNullSelection = class(TPressMVPSelection)
  end;

  TPressMVPModelEvent = class(TPressEvent)
  protected
    {$IFNDEF PressLogModelEvents}
    function AllowLog: Boolean; override;
    {$ENDIF}
  end;

  TPressMVPChangeType = (ctSubject, ctDisplay);

  TPressMVPModelChangedEvent = class(TPressMVPModelEvent)
  private
    FChangeType: TPressMVPChangeType;
  public
    constructor Create(AOwner: TObject; AChangeType: TPressMVPChangeType);
    property ChangeType: TPressMVPChangeType read FChangeType;
  end;

  TPressMVPModelUpdateDataEvent = class(TPressMVPModelEvent)
  end;

  TPressMVPModelNotifyEvent =
   procedure(AChangeType: TPressMVPChangeType) of object;

  TPressMVPModelClass = class of TPressMVPModel;

  TPressMVPModel = class(TPressMVPObject)
  private
    FAccessChangeObjectID: Integer;
    FAccessNewObjectID: Integer;
    FAccessUser: TPressUser;
    FCommands: TPressMVPCommands;
    FNotifier: TPressNotifier;
    FOwnedCommands: TPressMVPCommandList;
    FParent: TPressMVPModel;
    FSelection: TPressMVPSelection;
    FSubject: TPressSubject;
    function GetCommands: TPressMVPCommands;
    function GetHasParent: Boolean;
    function GetHasSubject: Boolean;
    function GetNotifier: TPressNotifier;
    function GetOwnedCommands: TPressMVPCommandList;
    function GetSelection: TPressMVPSelection;
    function GetSubject: TPressSubject;
    procedure SetAccessChangeObjectID(Value: Integer);
    procedure SetAccessID(Value: Integer);
    procedure SetAccessNewObjectID(Value: Integer);
    procedure SetAccessUser(Value: TPressUser);
  protected
    procedure InitCommands; virtual;
    function InternalAccessID: Integer; virtual;
    function InternalAccessMode: TPressAccessMode; virtual;
    function InternalCreateSelection: TPressMVPSelection; virtual;
    function InternalIsIncluding: Boolean; virtual;
    procedure Notify(AEvent: TPressEvent); virtual;
    property Commands: TPressMVPCommands read GetCommands;
    property Notifier: TPressNotifier read GetNotifier;
    property OwnedCommands: TPressMVPCommandList read GetOwnedCommands;
  public
    constructor Create(AParent: TPressMVPModel; ASubject: TPressSubject); virtual;
    destructor Destroy; override;
    function AccessMode: TPressAccessMode;
    function AddCommand(ACommandClass: TPressMVPCommandClass): Integer;
    function AddCommandInstance(ACommand: TPressMVPCommand): Integer;
    procedure AddCommands(ACommandClasses: array of TPressMVPCommandClass);
    class function Apply(ASubject: TPressSubject): Boolean; virtual; abstract;
    procedure Changed(AChangeType: TPressMVPChangeType);
    { TODO : Remove this factory method }
    class function CreateFromSubject(AParent: TPressMVPModel; ASubject: TPressSubject): TPressMVPModel;
    function FindCommand(ACommandClass: TPressMVPCommandClass): TPressMVPCommand;
    function HasCommands: Boolean;
    function RegisterCommand(ACommandClass: TPressMVPCommandClass): TPressMVPCommand;
    class procedure RegisterModel;
    procedure UpdateData;
    property AccessChangeObjectID: Integer read FAccessChangeObjectID write SetAccessChangeObjectID;
    property AccessID: Integer write SetAccessID;
    property AccessNewObjectID: Integer read FAccessNewObjectID write SetAccessNewObjectID;
    property AccessUser: TPressUser read FAccessUser write SetAccessUser;
    property HasParent: Boolean read GetHasParent;
    property HasSubject: Boolean read GetHasSubject;
    property Parent: TPressMVPModel read FParent;
    property Selection: TPressMVPSelection read GetSelection;
    property Subject: TPressSubject read GetSubject;
  end;

implementation

uses
  SysUtils,
  PressConsts,
  {$IFDEF PressLog}PressLog,{$ENDIF}
  PressApplication,
  PressMVPFactory,
  PressMVPCommand;

type
  TPressMVPControlFriend = class(TControl);

var
  _CommandRegistryList: IPressHolder; //TPressMVPCommandRegistryList;

function PressCommandRegistryList: TPressMVPCommandRegistryList;
begin
  if not Assigned(_CommandRegistryList) then
    _CommandRegistryList :=
     TPressHolder.Create(TPressMVPCommandRegistryList.Create(True));
  Result := TPressMVPCommandRegistryList(_CommandRegistryList.Instance);
end;

{ TPressMVPCommandComponent }

procedure TPressMVPCommandComponent.ComponentClick(Sender: TObject);
begin
  Command.Execute;
  if Assigned(FOnClickEvent) then
    FOnClickEvent(Sender);
end;

constructor TPressMVPCommandComponent.Create(ACommand: TPressMVPCommand);
begin
  inherited Create;
  { TODO : Assertion }
  FCommand := ACommand;
end;

destructor TPressMVPCommandComponent.Destroy;
begin
  ReleaseComponent;
  inherited;
end;

{ TPressMVPCommandMenuItem }

procedure TPressMVPCommandMenuItem.BindComponent;
begin
  if Assigned(FMenuItem) then
  begin
    OnClickEvent := FMenuItem.OnClick;
    FMenuItem.OnClick := {$IFDEF FPC}@{$ENDIF}ComponentClick;
    FMenuItem.Enabled := Command.Enabled;
    FMenuItem.Visible := Command.Visible;
  end;
end;

constructor TPressMVPCommandMenuItem.Create(
  ACommand: TPressMVPCommand; AMenuItem: TMenuItem);
begin
  inherited Create(ACommand);
  FMenuItem := AMenuItem;
  BindComponent;
end;

function TPressMVPCommandMenuItem.GetEnabled: Boolean;
begin
  Result := Assigned(FMenuItem) and FMenuItem.Enabled;
end;

function TPressMVPCommandMenuItem.GetVisible: Boolean;
begin
  Result := Assigned(FMenuItem) and FMenuItem.Visible;
end;

procedure TPressMVPCommandMenuItem.ReleaseComponent;
begin
  if Assigned(FMenuItem) then
  begin
    FMenuItem.OnClick := OnClickEvent;
    FMenuItem := nil;
    OnClickEvent := nil;
  end;
end;

procedure TPressMVPCommandMenuItem.SetEnabled(Value: Boolean);
begin
  if Assigned(FMenuItem) then
    FMenuItem.Enabled := Value;
end;

procedure TPressMVPCommandMenuItem.SetVisible(Value: Boolean);
begin
  if Assigned(FMenuItem) then
    FMenuItem.Visible := Value;
end;

{ TPressMVPCommandControl }

procedure TPressMVPCommandControl.BindComponent;
begin
  if Assigned(FControl) then
  begin
    OnClickEvent := TPressMVPControlFriend(FControl).OnClick;
    TPressMVPControlFriend(FControl).OnClick :=
     {$IFDEF FPC}@{$ENDIF}ComponentClick;
    FControl.Enabled := Command.Enabled;
    FControl.Visible := Command.Visible;
  end;
end;

constructor TPressMVPCommandControl.Create(ACommand: TPressMVPCommand;
  AControl: TControl);
begin
  inherited Create(ACommand);
  FControl := AControl;
  BindComponent;
end;

function TPressMVPCommandControl.GetEnabled: Boolean;
begin
  Result := Assigned(FControl) and FControl.Enabled;
end;

function TPressMVPCommandControl.GetVisible: Boolean;
begin
  Result := Assigned(FControl) and FControl.Visible;
end;

procedure TPressMVPCommandControl.ReleaseComponent;
begin
  if Assigned(FControl) then
  begin
    TPressMVPControlFriend(FControl).OnClick := OnClickEvent;
    FControl := nil;
    OnClickEvent := nil;
  end;
end;

procedure TPressMVPCommandControl.SetEnabled(Value: Boolean);
begin
  if Assigned(FControl) then
    FControl.Enabled := Value;
end;

procedure TPressMVPCommandControl.SetVisible(Value: Boolean);
begin
  if Assigned(FControl) then
    FControl.Visible := Value;
end;

{ TPressMVPCommandComponentList }

function TPressMVPCommandComponentList.Add(
  AObject: TPressMVPCommandComponent): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressMVPCommandComponentList.CreateIterator: TPressMVPCommandComponentIterator;
begin
  Result := TPressMVPCommandComponentIterator.Create(Self);
end;

function TPressMVPCommandComponentList.Extract(
  AObject: TPressMVPCommandComponent): TPressMVPCommandComponent;
begin
  Result := inherited Extract(AObject) as TPressMVPCommandComponent;
end;

function TPressMVPCommandComponentList.GetItems(
  AIndex: Integer): TPressMVPCommandComponent;
begin
  Result := inherited Items[AIndex] as TPressMVPCommandComponent;
end;

function TPressMVPCommandComponentList.IndexOf(
  AObject: TPressMVPCommandComponent): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressMVPCommandComponentList.Insert(Index: Integer;
  AObject: TPressMVPCommandComponent);
begin
  inherited Insert(Index, AObject);
end;

function TPressMVPCommandComponentList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressMVPCommandComponentList.Remove(
  AObject: TPressMVPCommandComponent): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressMVPCommandComponentList.SetEnabled(Value: Boolean);
begin
  with CreateIterator do
  try
    BeforeFirstItem;
    while NextItem do
      CurrentItem.Enabled := Value;
  finally
    Free;
  end;
end;

procedure TPressMVPCommandComponentList.SetItems(
  AIndex: Integer; Value: TPressMVPCommandComponent);
begin
  inherited Items[AIndex] := Value;
end;

procedure TPressMVPCommandComponentList.SetVisible(Value: Boolean);
begin
  with CreateIterator do
  try
    BeforeFirstItem;
    while NextItem do
      CurrentItem.Visible := Value;
  finally
    Free;
  end;
end;

{ TPressMVPCommandComponentIterator }

function TPressMVPCommandComponentIterator.GetCurrentItem: TPressMVPCommandComponent;
begin
  Result := inherited CurrentItem as TPressMVPCommandComponent;
end;

{ TPressMVPCommand }

procedure TPressMVPCommand.AddComponent(AComponent: TComponent);
var
  VCommandComponent: TPressMVPCommandComponent;
begin
  { TODO : Assertion }
  if AComponent is TMenuItem then
    VCommandComponent := TPressMVPCommandMenuItem.Create(Self, TMenuItem(AComponent))
  else if AComponent is TControl then
    VCommandComponent := TPressMVPCommandControl.Create(Self, TControl(AComponent))
  else
    raise EPressMVPError.CreateFmt(SUnsupportedComponent,
     [AComponent.ClassName]);
  ComponentList.Add(VCommandComponent);
end;

class function TPressMVPCommand.Apply(AModel: TPressMVPModel): Boolean;
begin
  Result := True;
end;

constructor TPressMVPCommand.Create(
  AModel: TPressMVPModel; const ACaption: string; AShortCut: TShortCut);
begin
  if not Assigned(AModel) then
    raise EPressMVPError.Create(SUnassignedModel);
  if not Apply(AModel) then
    raise EPressMVPError.CreateFmt(SUnsupportedModel,
     [AModel.ClassName, ClassName]);
  inherited Create;
  FModel := AModel;
  FCaption := ACaption;
  FShortCut := AShortCut;
  VerifyAccess;
  FEnabled := VerifyEnabled;
  FNotifier := TPressNotifier.Create({$IFDEF FPC}@{$ENDIF}Notify);
  InitNotifier;
end;

function TPressMVPCommand.CurrentUser: TPressUser;
begin
  if PressUserData.HasUser then
    Result := PressUserData.CurrentUser
  else
    Result := nil;
end;

destructor TPressMVPCommand.Destroy;
begin
  FComponentList.Free;
  FNotifier.Free;
  inherited;
end;

procedure TPressMVPCommand.Execute;
begin
  InternalExecute;
end;

function TPressMVPCommand.GetCaption: string;
begin
  if FCaption = '' then
    Result := Format('<%s>', [ClassName])
  else
    Result := FCaption;
end;

function TPressMVPCommand.GetComponentList: TPressMVPCommandComponentList;
begin
  if not Assigned(FComponentList) then
    FComponentList := TPressMVPCommandComponentList.Create(True);
  Result := FComponentList;
end;

function TPressMVPCommand.GetShortCut: TShortCut;
begin
  Result := FShortCut;
end;

procedure TPressMVPCommand.InitNotifier;
begin
  Notifier.AddNotificationItem(
   Model.Selection, [TPressMVPSelectionChangedEvent]);
  if Model.HasSubject and (Model.Subject is TPressObject) then
    Notifier.AddNotificationItem(Model.Subject, [TPressObjectChangedEvent]);
  Notifier.AddNotificationItem(nil, [TPressUserEvent]);
end;

function TPressMVPCommand.InternalIsEnabled: Boolean;
begin
  Result := True;
end;

procedure TPressMVPCommand.Notify(AEvent: TPressEvent);
var
  VOldVisible: Boolean;
begin
  VOldVisible := FVisible;
  if AEvent is TPressUserEvent then
    VerifyAccess;
  if FEnabled <> VerifyEnabled then
  begin
    FEnabled := not FEnabled;
    ComponentList.Enabled := FEnabled;
    TPressMVPCommandChangedEvent.Create(Self).Notify;
  end;
  if FVisible <> VOldVisible then
    ComponentList.Visible := FVisible;
end;

class function TPressMVPCommand.RegisterCommand: TPressMVPCommandRegistry;
begin
  Result := TPressMVPCommandRegistry.Create(Self);
  try
    PressCommandRegistryList.Add(Result);
  except
    Result.Free;
    raise;
  end;
end;

procedure TPressMVPCommand.VerifyAccess;
var
  VAccessMode: TPressAccessMode;
  VCommandReg: TPressMVPCommandRegistry;
  VIndex: Integer;
begin
  VIndex :=
   PressCommandRegistryList.IndexOfCommand(TPressMVPCommandClass(ClassType));
  if VIndex <> -1 then
    VCommandReg := PressCommandRegistryList[VIndex]
  else
    VCommandReg := nil;
  if PressUserData.HasUser then
  begin
    if Assigned(VCommandReg) and not VCommandReg.AlwaysEnabled and
     (VCommandReg.AccessID <> -1) then
      VAccessMode := CurrentUser.AccessMode(VCommandReg.AccessID)
    else
      VAccessMode := amWritable;
  end else if Assigned(VCommandReg) and
   (VCommandReg.AlwaysEnabled or VCommandReg.EnabledIfNoUser) then
    VAccessMode := amWritable
  else
    VAccessMode := amVisible;
  FVisible := VAccessMode <> amInvisible;
  FExecutable := VAccessMode = amWritable;
end;

function TPressMVPCommand.VerifyEnabled: Boolean;
begin
  Result := FVisible and FExecutable and InternalIsEnabled;
end;

{ TPressMVPCommandList }

function TPressMVPCommandList.Add(AObject: TPressMVPCommand): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressMVPCommandList.CreateIterator: TPressMVPCommandIterator;
begin
  Result := TPressMVPCommandIterator.Create(Self);
end;

function TPressMVPCommandList.FindCommand(
  ACommandClass: TPressMVPCommandClass): TPressMVPCommand;
var
  I: Integer;
begin
  for I := 0 to Pred(Count) do
  begin
    Result := Items[I];
    if Assigned(Result) and (Result.ClassType = ACommandClass) then
      Exit;
  end;
  Result := nil;
end;

function TPressMVPCommandList.GetItems(AIndex: Integer): TPressMVPCommand;
begin
  Result := inherited Items[AIndex] as TPressMVPCommand;
end;

function TPressMVPCommandList.IndexOf(AObject: TPressMVPCommand): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressMVPCommandList.Insert(Index: Integer; AObject: TPressMVPCommand);
begin
  inherited Insert(Index, AObject);
end;

function TPressMVPCommandList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressMVPCommandList.Remove(AObject: TPressMVPCommand): Integer;
begin
  Result := inherited Remove(AObject);
end;

{ TPressMVPCommandIterator }

function TPressMVPCommandIterator.GetCurrentItem: TPressMVPCommand;
begin
  Result := inherited CurrentItem as TPressMVPCommand;
end;

{ TPressMVPCommandRegistry }

constructor TPressMVPCommandRegistry.Create(
  ACommandClass: TPressMVPCommandClass);
begin
  inherited Create;
  FCommandClass := ACommandClass;
  FAccessID := -1;
end;

{ TPressMVPCommandRegistryList }

function TPressMVPCommandRegistryList.Add(
  AObject: TPressMVPCommandRegistry): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressMVPCommandRegistryList.CreateIterator: TPressMVPCommandRegistryIterator;
begin
  Result := TPressMVPCommandRegistryIterator.Create(Self);
end;

function TPressMVPCommandRegistryList.Extract(
  AObject: TPressMVPCommandRegistry): TPressMVPCommandRegistry;
begin
  Result := inherited Extract(AObject) as TPressMVPCommandRegistry;
end;

function TPressMVPCommandRegistryList.GetItems(
  AIndex: Integer): TPressMVPCommandRegistry;
begin
  Result := inherited Items[AIndex] as TPressMVPCommandRegistry;
end;

function TPressMVPCommandRegistryList.IndexOf(
  AObject: TPressMVPCommandRegistry): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

function TPressMVPCommandRegistryList.IndexOfCommand(
  ACommandClass: TPressMVPCommandClass): Integer;
begin
  if ACommandClass <> TPressMVPCommand then
  begin
    for Result := 0 to Pred(Count) do
      if ACommandClass = Items[Result].CommandClass then
        Exit;
    Result := IndexOfCommand(TPressMVPCommandClass(ACommandClass.ClassParent));
  end else
    Result := -1;
end;

procedure TPressMVPCommandRegistryList.Insert(
  AIndex: Integer; AObject: TPressMVPCommandRegistry);
begin
  inherited Insert(AIndex, AObject);
end;

function TPressMVPCommandRegistryList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressMVPCommandRegistryList.Remove(
  AObject: TPressMVPCommandRegistry): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressMVPCommandRegistryList.SetItems(
  AIndex: Integer; Value: TPressMVPCommandRegistry);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressMVPCommandRegistryIterator }

function TPressMVPCommandRegistryIterator.GetCurrentItem: TPressMVPCommandRegistry;
begin
  Result := inherited CurrentItem as TPressMVPCommandRegistry;
end;

{ TPressMVPCommands }

function TPressMVPCommands.Add(ACommand: TPressMVPCommand): Integer;
begin
  Result := Items.Add(ACommand);
end;

destructor TPressMVPCommands.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TPressMVPCommands.FindCommand(
  ACommandClass: TPressMVPCommandClass): TPressMVPCommand;
var
  I: Integer;
begin
  for I := 0 to Pred(Count) do
  begin
    Result := Items[I];
    if Assigned(Result) and (Result.ClassType = ACommandClass) then
      Exit;
  end;
  Result := nil;
end;

function TPressMVPCommands.GetCount: Integer;
begin
  if Assigned(FItems) then
    Result := FItems.Count
  else
    Result := 0;
end;

function TPressMVPCommands.GetItem(AIndex: Integer): TPressMVPCommand;
begin
  Result := Items[AIndex];
end;

function TPressMVPCommands.GetItems: TPressMVPCommandList;
begin
  if not Assigned(FItems) then
    FItems := TPressMVPCommandList.Create(True);
  Result := FItems;
end;

{ TPressMVPCommandMenu }

procedure TPressMVPCommandMenu.AssignCommands(ACommands: TPressMVPCommands);
var
  I: Integer;
begin
  UnassignCommands;
  for I := 0 to Pred(ACommands.Count) do
    InternalAddItem(ACommands[I]);
end;

procedure TPressMVPCommandMenu.AssignMenu(AControl: TControl);
begin
  InternalAssignMenu(AControl);
end;

procedure TPressMVPCommandMenu.UnassignCommands;
begin
  InternalClearMenuItems;
end;

{ TPressMVPObject }

procedure TPressMVPObject.AddNotification(
  AEventClasses: array of TPressEventClass; AMethod: TPressNotificationEvent);
var
  VNotifier: TPressNotifier;
begin
  VNotifier := TPressNotifier.Create(AMethod);
  try
    VNotifier.AddNotificationItem(Self, AEventClasses);
    if not Assigned(FNotifierList) then
      FNotifierList := TObjectList.Create(True);
    FNotifierList.Add(VNotifier);
  except
    VNotifier.Free;
    raise;
  end;
end;

class procedure TPressMVPObject.CheckClass(AApplyClass: Boolean);
begin
  { TODO : Change error message, including the ClassName of the parameters }
  if not AApplyClass then
    raise EPressMVPError.CreateFmt(SUnexpectedMVPClassParam, [ClassName]);
end;

destructor TPressMVPObject.Destroy;
begin
  FNotifierList.Free;
  inherited;
end;

procedure TPressMVPObject.DisableEvents;
begin
  Inc(FDisableCount);
end;

procedure TPressMVPObject.EnableEvents;
begin
  if FDisableCount > 0 then
    Dec(FDisableCount);
end;

function TPressMVPObject.GetEventsDisabled: Boolean;
begin
  Result := FDisableCount > 0;
end;

{ TPressMVPSelection }

function TPressMVPSelection.Add(AObject: TObject): Integer;
begin
  if Assigned(AObject) then
  begin
    Result := ObjectList.IndexOf(AObject);
    if Result = -1 then
    begin
      Result := DoAddObject(AObject);
      DoNotify;
    end else if AObject = FFocus then
      StrongSelection := True;
  end else
    Result := -1;
end;

procedure TPressMVPSelection.BeginUpdate;
begin
  Inc(FUpdatingCount);
end;

procedure TPressMVPSelection.Clear;
begin
  if Assigned(FObjectList) then
  begin
    FObjectList.Clear;
    FFocus := nil;
    FStrongSelection := False;
    DoNotify;
  end;
end;

function TPressMVPSelection.Count: Integer;
begin
  if Assigned(FObjectList) then
    Result := FObjectList.Count
  else
    Result := 0;
end;

function TPressMVPSelection.CreateIterator: TPressIterator;
begin
  Result := InternalCreateIterator;
end;

destructor TPressMVPSelection.Destroy;
begin
  FObjectList.Free;
  inherited;
end;

function TPressMVPSelection.DoAddObject(AObject: TObject): Integer;
begin
  Result := ObjectList.Add(AObject);
  InternalAssignObject(AObject);
end;

procedure TPressMVPSelection.DoNotify;
begin
  if FUpdatingCount = 0 then
  begin
    TPressMVPSelectionChangedEvent.Create(Self).Notify;
    FUpdatesPending := False;
  end else
    FUpdatesPending := True;
end;

procedure TPressMVPSelection.EndUpdate;
begin
  Dec(FUpdatingCount);
  if (FUpdatingCount = 0) and FUpdatesPending then
    DoNotify;
end;

function TPressMVPSelection.GetObjectList: TPressList;
begin
  if not Assigned(FObjectList) then
    FObjectList := TPressObjectList.Create(InternalOwnsObjects);
  Result := FObjectList;
end;

function TPressMVPSelection.GetObjects(AIndex: Integer): TObject;
begin
  Result := ObjectList[AIndex];
end;

function TPressMVPSelection.HasStrongSelection(AObject: TObject): Boolean;
begin
  if AObject = Focus then
    Result := StrongSelection
  else
    Result := IndexOf(AObject) <> -1;
end;

function TPressMVPSelection.IndexOf(AObject: TObject): Integer;
begin
  if Assigned(FObjectList) then
    Result := FObjectList.IndexOf(AObject)
  else
    Result := -1;
end;

procedure TPressMVPSelection.InternalAssignObject(AObject: TObject);
begin
end;

function TPressMVPSelection.InternalCreateIterator: TPressIterator;
begin
  Result := TPressIterator.Create(ObjectList);
end;

function TPressMVPSelection.InternalOwnsObjects: Boolean;
begin
  Result := False;
end;

function TPressMVPSelection.IsSelected(AObject: TObject): Boolean;
begin
  Result := IndexOf(AObject) <> -1;
end;

function TPressMVPSelection.Remove(AObject: TObject): Integer;
begin
  if Assigned(FObjectList) then
  begin
    Result := FObjectList.IndexOf(AObject);
    if Result >= 0 then
    begin
      if FObjectList[Result] = FFocus then
        FStrongSelection := False
      else
        FObjectList.Delete(Result);
      DoNotify;
    end;
  end else
    Result := -1;
end;

procedure TPressMVPSelection.Select(AObject: TObject);
begin
  Clear;
  Focus := AObject;
end;

procedure TPressMVPSelection.SetFocus(Value: TObject);
begin
  if FFocus <> Value then
  begin
    BeginUpdate;
    try
      if not StrongSelection then
        ObjectList.Remove(FFocus);
      FStrongSelection := IndexOf(Value) <> -1;
      if Assigned(Value) and not StrongSelection then
        DoAddObject(Value);
      FFocus := Value;
      DoNotify;
    finally
      EndUpdate;
    end;
  end;
end;

procedure TPressMVPSelection.SetStrongSelection(Value: Boolean);
begin
  if FStrongSelection <> Value then
  begin
    FStrongSelection := Value;
    DoNotify;
  end;
end;

{ TPressMVPModelEvent }

{$IFNDEF PressLogModelEvents}
function TPressMVPModelEvent.AllowLog: Boolean;
begin
  Result := False;
end;
{$ENDIF}

{ TPressMVPModelChangedEvent }

constructor TPressMVPModelChangedEvent.Create(AOwner: TObject;
  AChangeType: TPressMVPChangeType);
begin
  inherited Create(AOwner);
  FChangeType := AChangeType;
end;

{ TPressMVPModel }

function TPressMVPModel.AccessMode: TPressAccessMode;
begin
  Result := InternalAccessMode;
end;

function TPressMVPModel.AddCommand(
  ACommandClass: TPressMVPCommandClass): Integer;
var
  VCommand: TPressMVPCommand;
begin
  if Assigned(ACommandClass) then
  begin
    VCommand := ACommandClass.Create(Self);
    try
      Result := Commands.Add(VCommand);
    except
      VCommand.Free;
      raise;
    end;
  end else
    Result := Commands.Add(nil);
end;

function TPressMVPModel.AddCommandInstance(
  ACommand: TPressMVPCommand): Integer;
begin
  Result := Commands.Add(ACommand);
end;

procedure TPressMVPModel.AddCommands(
  ACommandClasses: array of TPressMVPCommandClass);
var
  I: Integer;
begin
  for I := Low(ACommandClasses) to High(ACommandClasses) do
    AddCommand(ACommandClasses[I]);
end;

procedure TPressMVPModel.Changed(AChangeType: TPressMVPChangeType);
begin
  if not EventsDisabled then
    TPressMVPModelChangedEvent.Create(Self, AChangeType).Notify;
end;

constructor TPressMVPModel.Create(
  AParent: TPressMVPModel; ASubject: TPressSubject);
begin
  CheckClass(not Assigned(ASubject) or Apply(ASubject));
  inherited Create;
  FParent := AParent;
  FSubject := ASubject;
  FAccessChangeObjectID := -1;
  FAccessNewObjectID := -1;
  if HasSubject then
  begin
    FSubject.AddRef;
    Notifier.AddNotificationItem(FSubject, [TPressSubjectEvent]);
    InitCommands;
  end;
end;

class function TPressMVPModel.CreateFromSubject(
  AParent: TPressMVPModel; ASubject: TPressSubject): TPressMVPModel;
begin
  Result := PressDefaultMVPFactory.MVPModelFactory(AParent, ASubject);
end;

destructor TPressMVPModel.Destroy;
begin
  FNotifier.Free;
  FCommands.Free;
  FAccessUser.Free;
  FSubject.Free;
  FSelection.Free;
  FOwnedCommands.Free;
  inherited;
end;

function TPressMVPModel.FindCommand(
  ACommandClass: TPressMVPCommandClass): TPressMVPCommand;
begin
  if Assigned(FCommands) then
    Result := FCommands.FindCommand(ACommandClass)
  else
    Result := nil;
  if not Assigned(Result) then
    Result := OwnedCommands.FindCommand(ACommandClass);
end;

function TPressMVPModel.GetCommands: TPressMVPCommands;
begin
  if not Assigned(FCommands) then
    FCommands := TPressMVPCommands.Create;
  Result := FCommands;
end;

function TPressMVPModel.GetHasParent: Boolean;
begin
  Result := Assigned(FParent);
end;

function TPressMVPModel.GetHasSubject: Boolean;
begin
  Result := Assigned(FSubject);
end;

function TPressMVPModel.GetNotifier: TPressNotifier;
begin
  if not Assigned(FNotifier) then
    FNotifier := TPressNotifier.Create({$IFDEF FPC}@{$ENDIF}Notify);
  Result := FNotifier;
end;

function TPressMVPModel.GetOwnedCommands: TPressMVPCommandList;
begin
  if not Assigned(FOwnedCommands) then
    FOwnedCommands := TPressMVPCommandList.Create(True);
  Result := FOwnedCommands;
end;

function TPressMVPModel.GetSelection: TPressMVPSelection;
begin
  if not Assigned(FSelection) then
    FSelection := InternalCreateSelection;
  Result := FSelection;
end;

function TPressMVPModel.GetSubject: TPressSubject;
begin
  if not Assigned(FSubject) then
    raise EPressMVPError.Create(SUnassignedSubject);
  Result := FSubject;
end;

function TPressMVPModel.HasCommands: Boolean;
begin
  Result := Assigned(FCommands) and (FCommands.Count > 0);
end;

procedure TPressMVPModel.InitCommands;
begin
end;

function TPressMVPModel.InternalAccessID: Integer;
begin
  if InternalIsIncluding then
    Result := FAccessNewObjectID
  else
    Result := FAccessChangeObjectID;
end;

function TPressMVPModel.InternalAccessMode: TPressAccessMode;
var
  VUser: TPressUser;
  VAccessID: Integer;
begin
  VUser := AccessUser;
  VAccessID := InternalAccessID;
  if HasParent and (not Assigned(VUser) or (VAccessID = -1)) then
  begin
    if not Assigned(VUser) then
      VUser := Parent.AccessUser;
    if VAccessID = -1 then
      VAccessID := Parent.InternalAccessID;
  end;
  if Assigned(VUser) then
    Result := VUser.AccessMode(VAccessID)
  else if VAccessID = -1 then
    Result := amWritable
  else
    Result := amInvisible;
end;

function TPressMVPModel.InternalCreateSelection: TPressMVPSelection;
begin
  Result := TPressMVPNullSelection.Create;
end;

function TPressMVPModel.InternalIsIncluding: Boolean;
begin
  if HasParent then
    Result := Parent.InternalIsIncluding
  else
    Result := True;
end;

procedure TPressMVPModel.Notify(AEvent: TPressEvent);
begin
  if AEvent is TPressSubjectChangedEvent then
    Changed(ctSubject);
end;

function TPressMVPModel.RegisterCommand(
  ACommandClass: TPressMVPCommandClass): TPressMVPCommand;
begin
  Result := FindCommand(ACommandClass);
  if not Assigned(Result) then
  begin
    Result := ACommandClass.Create(Self);
    OwnedCommands.Add(Result);
  end;
end;

class procedure TPressMVPModel.RegisterModel;
begin
  PressDefaultMVPFactory.RegisterModel(Self);
end;

procedure TPressMVPModel.SetAccessChangeObjectID(Value: Integer);
begin
  if FAccessChangeObjectID <> Value then
  begin
    FAccessChangeObjectID := Value;
    Changed(ctDisplay);
  end;
end;

procedure TPressMVPModel.SetAccessID(Value: Integer);
begin
  { TODO : Improve notification }
  AccessNewObjectID := Value;
  AccessChangeObjectID := Value;
end;

procedure TPressMVPModel.SetAccessNewObjectID(Value: Integer);
begin
  if FAccessNewObjectID <> Value then
  begin
    FAccessNewObjectID := Value;
    Changed(ctDisplay);
  end;
end;

procedure TPressMVPModel.SetAccessUser(Value: TPressUser);
begin
  if FAccessUser <> Value then
  begin
    FAccessUser.Free;
    FAccessUser := Value;
    FAccessUser.AddRef;
    Changed(ctDisplay);
  end;
end;

procedure TPressMVPModel.UpdateData;
begin
  TPressMVPModelUpdateDataEvent.Create(Self).Notify;
end;

end.
