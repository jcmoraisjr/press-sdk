(*
  PressObjects, Base MVP Classes
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

unit PressMVP;

{$I Press.inc}

interface

uses
  Classes,
  Controls,
  Menus,
  PressClasses,
  PressNotifier,
  PressSubject;

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
  TPressMVPRegisteredCommand = class;

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
    constructor Create(AModel: TPressMVPModel); virtual;
    destructor Destroy; override;
    procedure AddComponent(AComponent: TComponent);
    class function Apply(AModel: TPressMVPModel): Boolean; virtual;
    procedure Execute;
    class function RegisterCommand: TPressMVPRegisteredCommand;
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

  TPressMVPRegisteredCommand = class(TObject)
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

  TPressMVPRegisteredCommandIterator = class;

  TPressMVPRegisteredCommandList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressMVPRegisteredCommand;
    procedure SetItems(AIndex: Integer; Value: TPressMVPRegisteredCommand);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressMVPRegisteredCommand): Integer;
    function CreateIterator: TPressMVPRegisteredCommandIterator;
    function Extract(AObject: TPressMVPRegisteredCommand): TPressMVPRegisteredCommand;
    function IndexOf(AObject: TPressMVPRegisteredCommand): Integer;
    function IndexOfCommand(ACommandClass: TPressMVPCommandClass): Integer;
    procedure Insert(AIndex: Integer; AObject: TPressMVPRegisteredCommand);
    function Remove(AObject: TPressMVPRegisteredCommand): Integer;
    property Items[AIndex: Integer]: TPressMVPRegisteredCommand read GetItems write SetItems; default;
  end;

  TPressMVPRegisteredCommandIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressMVPRegisteredCommand;
  public
    property CurrentItem: TPressMVPRegisteredCommand read GetCurrentItem;
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

  TPressMVPObject = class(TPressStreamable)
  private
    FDisableCount: Integer;
    function GetEventsDisabled: Boolean;
  protected
    class procedure CheckClass(AApplyClass: Boolean);
  public
    procedure DisableEvents;
    procedure EnableEvents;
    property EventsDisabled: Boolean read GetEventsDisabled;
  end;

  TPressMVPSelectionChangedEvent = class(TPressEvent)
  end;

  TPressMVPSelection = class(TObject)
  private
    FObjectList: TPressList;
    function GetObjectList: TPressList;
    function GetObjects(Index: Integer): TObject;
  protected
    procedure InternalAssignObject(AObject: TObject); virtual;
    function InternalCreateIterator: TPressIterator; virtual;
    function InternalOwnsObjects: Boolean; virtual;
    property ObjectList: TPressList read GetObjectList;
  public
    destructor Destroy; override;
    procedure AddObject(AObject: TObject);
    procedure Clear;
    function Count: Integer;
    function CreateIterator: TPressIterator;
    procedure RemoveObject(AObject: TObject);
    procedure SelectObject(AObject: TObject);
    property Objects[Index: Integer]: TObject read GetObjects; default;
  end;

  TPressMVPNullSelection = class(TPressMVPSelection)
  end;

  TPressMVPModelEvent = class(TPressEvent)
  protected
    {$IFNDEF PressLogModelEvents}
    function AllowLog: Boolean; override;
    {$ENDIF}
  end;

  TPressMVPModelUpdateDataEvent = class(TPressMVPModelEvent)
  end;

  TPressMVPChangeType = (ctSubject, ctDisplay);

  TPressMVPModelNotifyEvent =
   procedure(AChangeType: TPressMVPChangeType) of object;

  TPressMVPModelClass = class of TPressMVPModel;

  TPressMVPModel = class(TPressMVPObject)
  private
    FCommands: TPressMVPCommands;
    FNotifier: TPressNotifier;
    FOnChange: TPressMVPModelNotifyEvent;
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
  protected
    procedure DoChanged(AChangeType: TPressMVPChangeType);
    procedure InitCommands; virtual;
    function InternalCreateSelection: TPressMVPSelection; virtual;
    procedure Notify(AEvent: TPressEvent); virtual;
    procedure SetChangeEvent(Value: TPressMVPModelNotifyEvent);
    property Commands: TPressMVPCommands read GetCommands;
    property Notifier: TPressNotifier read GetNotifier;
    property OwnedCommands: TPressMVPCommandList read GetOwnedCommands;
  public
    constructor Create(AParent: TPressMVPModel; ASubject: TPressSubject); virtual;
    destructor Destroy; override;
    function AddCommand(ACommandClass: TPressMVPCommandClass): Integer;
    function AddCommandInstance(ACommand: TPressMVPCommand): Integer;
    procedure AddCommands(ACommandClasses: array of TPressMVPCommandClass);
    class function Apply: TPressSubjectClass; virtual; abstract;
    { TODO : Remove this factory method }
    class function CreateFromSubject(AParent: TPressMVPModel; ASubject: TPressSubject): TPressMVPModel;
    function FindCommand(ACommandClass: TPressMVPCommandClass): TPressMVPCommand;
    function HasCommands: Boolean;
    function RegisterCommand(ACommandClass: TPressMVPCommandClass): TPressMVPCommand;
    class procedure RegisterModel;
    procedure UpdateData;
    property HasParent: Boolean read GetHasParent;
    property HasSubject: Boolean read GetHasSubject;
    property Parent: TPressMVPModel read FParent;
    property Selection: TPressMVPSelection read GetSelection;
    property Subject: TPressSubject read GetSubject;
  end;

  TPressMVPModelIterator = class;

  TPressMVPModelList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressMVPModel;
    procedure SetItems(AIndex: Integer; Value: TPressMVPModel);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressMVPModel): Integer;
    function CreateIterator: TPressMVPModelIterator;
    function Extract(AObject: TPressMVPModel): TObject;
    function IndexOf(AObject: TPressMVPModel): Integer;
    procedure Insert(Index: Integer; AObject: TPressMVPModel);
    function Remove(AObject: TPressMVPModel): Integer;
    property Items[AIndex: Integer]: TPressMVPModel read GetItems write SetItems; default;
  end;

  TPressMVPModelIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressMVPModel;
  public
    property CurrentItem: TPressMVPModel read GetCurrentItem;
  end;

implementation

uses
  SysUtils,
  PressConsts,
  {$IFDEF PressLog}PressLog,{$ENDIF}
  PressUser,
  PressPersistence,
  PressMVPFactory,
  PressMVPCommand;

type
  TPressMVPControlFriend = class(TControl);

var
  _PressRegisteredCommands: TPressMVPRegisteredCommandList;

function PressRegisteredCommands: TPressMVPRegisteredCommandList;
begin
  if not Assigned(_PressRegisteredCommands) then
  begin
    _PressRegisteredCommands := TPressMVPRegisteredCommandList.Create(True);
    PressRegisterSingleObject(_PressRegisteredCommands);
  end;
  Result := _PressRegisteredCommands;
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
    FMenuItem.OnClick := ComponentClick;
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
    TPressMVPControlFriend(FControl).OnClick := ComponentClick;
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

constructor TPressMVPCommand.Create(AModel: TPressMVPModel);
begin
  if not Assigned(AModel) then
    raise EPressMVPError.Create(SUnassignedModel);
  if not Apply(AModel) then
    raise EPressMVPError.CreateFmt(SUnsupportedModel,
     [AModel.ClassName, ClassName]);
  inherited Create;
  FModel := AModel;
  VerifyAccess;
  FEnabled := VerifyEnabled;
  FNotifier := TPressNotifier.Create(Notify);
  InitNotifier;
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
  Notifier.AddNotificationItem(
   PressDefaultPersistence, [TPressPersistenceEvent]);
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
  if AEvent is TPressPersistenceEvent then
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

class function TPressMVPCommand.RegisterCommand: TPressMVPRegisteredCommand;
begin
  Result := TPressMVPRegisteredCommand.Create(Self);
  try
    PressRegisteredCommands.Add(Result);
  except
    Result.Free;
    raise;
  end;
end;

procedure TPressMVPCommand.VerifyAccess;
var
  VAccessMode: TPressAccessMode;
  VCommandReg: TPressMVPRegisteredCommand;
  VIndex: Integer;
begin
  VIndex :=
   PressRegisteredCommands.IndexOfCommand(TPressMVPCommandClass(ClassType));
  if VIndex <> -1 then
    VCommandReg := PressRegisteredCommands[VIndex]
  else
    VCommandReg := nil;
  if PressDefaultPersistence.HasUser then
  begin
    if Assigned(VCommandReg) and not VCommandReg.AlwaysEnabled and
     (VCommandReg.AccessID <> -1) then
      VAccessMode :=
       PressDefaultPersistence.CurrentUser.AccessMode(VCommandReg.AccessID)
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

{ TPressMVPRegisteredCommand }

constructor TPressMVPRegisteredCommand.Create(
  ACommandClass: TPressMVPCommandClass);
begin
  inherited Create;
  FCommandClass := ACommandClass;
  FAccessID := -1;
end;

{ TPressMVPRegisteredCommandList }

function TPressMVPRegisteredCommandList.Add(
  AObject: TPressMVPRegisteredCommand): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressMVPRegisteredCommandList.CreateIterator: TPressMVPRegisteredCommandIterator;
begin
  Result := TPressMVPRegisteredCommandIterator.Create(Self);
end;

function TPressMVPRegisteredCommandList.Extract(
  AObject: TPressMVPRegisteredCommand): TPressMVPRegisteredCommand;
begin
  Result := inherited Extract(AObject) as TPressMVPRegisteredCommand;
end;

function TPressMVPRegisteredCommandList.GetItems(
  AIndex: Integer): TPressMVPRegisteredCommand;
begin
  Result := inherited Items[AIndex] as TPressMVPRegisteredCommand;
end;

function TPressMVPRegisteredCommandList.IndexOf(
  AObject: TPressMVPRegisteredCommand): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

function TPressMVPRegisteredCommandList.IndexOfCommand(
  ACommandClass: TPressMVPCommandClass): Integer;
begin
  for Result := 0 to Pred(Count) do
    if ACommandClass.InheritsFrom(Items[Result].CommandClass) then
      Exit;
  Result := -1;
end;

procedure TPressMVPRegisteredCommandList.Insert(
  AIndex: Integer; AObject: TPressMVPRegisteredCommand);
begin
  inherited Insert(AIndex, AObject);
end;

function TPressMVPRegisteredCommandList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressMVPRegisteredCommandList.Remove(
  AObject: TPressMVPRegisteredCommand): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressMVPRegisteredCommandList.SetItems(
  AIndex: Integer; Value: TPressMVPRegisteredCommand);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressMVPRegisteredCommandIterator }

function TPressMVPRegisteredCommandIterator.GetCurrentItem: TPressMVPRegisteredCommand;
begin
  Result := inherited CurrentItem as TPressMVPRegisteredCommand;
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

class procedure TPressMVPObject.CheckClass(AApplyClass: Boolean);
begin
  { TODO : Change error message, including the ClassName of the parameters }
  if not AApplyClass then
    raise EPressMVPError.CreateFmt(SUnexpectedMVPClassParam, [ClassName]);
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

procedure TPressMVPSelection.AddObject(AObject: TObject);
begin
  if Assigned(AObject) then
    with TPressMVPSelectionChangedEvent.Create(Self) do
    try
      ObjectList.Add(AObject);
      InternalAssignObject(AObject);
    finally
      Notify;
    end;
end;

procedure TPressMVPSelection.Clear;
begin
  if Assigned(FObjectList) then
    with TPressMVPSelectionChangedEvent.Create(Self) do
    try
      FObjectList.Clear;
    finally
      Notify;
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

function TPressMVPSelection.GetObjectList: TPressList;
begin
  if not Assigned(FObjectList) then
    FObjectList := TPressObjectList.Create(InternalOwnsObjects);
  Result := FObjectList;
end;

function TPressMVPSelection.GetObjects(Index: Integer): TObject;
begin
  Result := ObjectList[Index];
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

procedure TPressMVPSelection.RemoveObject(AObject: TObject);
var
  VIndex: Integer;
begin
  if Assigned(FObjectList) then
  begin
    VIndex := 0;
    with TPressMVPSelectionChangedEvent.Create(Self) do
    try
      VIndex := FObjectList.Remove(AObject);
    finally
      if VIndex >= 0 then
        Notify
      else
        Release;
    end;
  end;
end;

procedure TPressMVPSelection.SelectObject(AObject: TObject);
var
  VObject: TObject;
begin
  if Assigned(AObject) then
    with TPressMVPSelectionChangedEvent.Create(Self) do
    begin
      VObject := ObjectList.Extract(AObject);
      ObjectList.Clear;
      ObjectList.Add(AObject);
      if not Assigned(VObject) then
        InternalAssignObject(AObject);
      Notify;
    end
  else
    Clear;
end;

{ TPressMVPModelEvent }

{$IFNDEF PressLogModelEvents}
function TPressMVPModelEvent.AllowLog: Boolean;
begin
  Result := False;
end;
{$ENDIF}

{ TPressMVPModel }

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

constructor TPressMVPModel.Create(
  AParent: TPressMVPModel; ASubject: TPressSubject);
begin
  CheckClass(not Assigned(ASubject) or (ASubject.InheritsFrom(Apply)));
  inherited Create;
  FParent := AParent;
  FSubject := ASubject;
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
  FSubject.Free;
  FSelection.Free;
  FOwnedCommands.Free;
  inherited;
end;

procedure TPressMVPModel.DoChanged(AChangeType: TPressMVPChangeType);
begin
  if not EventsDisabled and Assigned(FOnChange) then
    FOnChange(AChangeType);
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
    FNotifier := TPressNotifier.Create(Notify);
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

function TPressMVPModel.InternalCreateSelection: TPressMVPSelection;
begin
  Result := TPressMVPNullSelection.Create;
end;

procedure TPressMVPModel.Notify(AEvent: TPressEvent);
begin
  if AEvent is TPressSubjectChangedEvent then
    DoChanged(ctSubject);
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

procedure TPressMVPModel.SetChangeEvent(Value: TPressMVPModelNotifyEvent);
begin
  FOnChange := Value;
end;

procedure TPressMVPModel.UpdateData;
begin
  TPressMVPModelUpdateDataEvent.Create(Self).Notify;
end;

{ TPressMVPModelList }

function TPressMVPModelList.Add(AObject: TPressMVPModel): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressMVPModelList.CreateIterator: TPressMVPModelIterator;
begin
  Result := TPressMVPModelIterator.Create(Self);
end;

function TPressMVPModelList.Extract(AObject: TPressMVPModel): TObject;
begin
  Result := inherited Extract(AObject) as TPressMVPModel;
end;

function TPressMVPModelList.GetItems(AIndex: Integer): TPressMVPModel;
begin
  Result := inherited Items[AIndex] as TPressMVPModel;
end;

function TPressMVPModelList.IndexOf(AObject: TPressMVPModel): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressMVPModelList.Insert(
  Index: Integer; AObject: TPressMVPModel);
begin
  inherited Insert(Index, AObject);
end;

function TPressMVPModelList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressMVPModelList.Remove(AObject: TPressMVPModel): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressMVPModelList.SetItems(
  AIndex: Integer; Value: TPressMVPModel);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressMVPModelIterator }

function TPressMVPModelIterator.GetCurrentItem: TPressMVPModel;
begin
  Result := inherited CurrentItem as TPressMVPModel;
end;

end.
