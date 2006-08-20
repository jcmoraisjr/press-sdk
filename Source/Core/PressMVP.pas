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

interface

{$I Press.inc}

uses
  Classes,
  Controls,
  Menus,
  PressClasses,
  PressNotifier,
  PressSubject;

type
  EPressMVPError = class(EPressError);

  TPressMVPModel = class;
  TPressMVPView = class;
  TPressMVPPresenter = class;
  TPressMVPCommand = class;

  TPressMVPCommandComponent = class(TObject)
  private
    FCommand: TPressMVPCommand;
    FOnClickEvent: TNotifyEvent;
  protected
    procedure BindComponent; virtual; abstract;
    procedure ComponentClick(Sender: TObject);
    function GetEnabled: Boolean; virtual; abstract;
    procedure ReleaseComponent; virtual; abstract;
    procedure SetEnabled(Value: Boolean); virtual; abstract;
    property OnClickEvent: TNotifyEvent read FOnClickEvent write FOnClickEvent;
  public
    constructor Create(ACommand: TPressMVPCommand);
    destructor Destroy; override;
    property Command: TPressMVPCommand read FCommand;
    property Enabled: Boolean read GetEnabled write SetEnabled;
  end;

  TPressMVPCommandMenuItem = class(TPressMVPCommandComponent)
  private
    FMenuItem: TMenuItem;
  protected
    procedure BindComponent; override;
    function GetEnabled: Boolean; override;
    procedure ReleaseComponent; override;
    procedure SetEnabled(Value: Boolean); override;
  public
    constructor Create(ACommand: TPressMVPCommand; AMenuItem: TMenuItem);
  end;

  TPressMVPCommandControl = class(TPressMVPCommandComponent)
  private
    FControl: TControl;
  protected
    procedure BindComponent; override;
    function GetEnabled: Boolean; override;
    procedure ReleaseComponent; override;
    procedure SetEnabled(Value: Boolean); override;
  public
    constructor Create(ACommand: TPressMVPCommand; AControl: TControl);
  end;

  TPressMVPCommandComponentIterator = class;

  TPressMVPCommandComponentList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressMVPCommandComponent;
    procedure SetEnabled(Value: Boolean);
    procedure SetItems(AIndex: Integer; Value: TPressMVPCommandComponent);
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
  end;

  TPressMVPCommandComponentIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressMVPCommandComponent;
  public
    property CurrentItem: TPressMVPCommandComponent read GetCurrentItem;
  end;

  TPressMVPCommandChangedEvent = class(TPressEvent)
  end;

  TPressMVPCommandClass = class of TPressMVPCommand;

  TPressMVPCommand = class(TObject)
  private
    FCaption: string;
    FComponentList: TPressMVPCommandComponentList;
    FEnabled: Boolean;
    FModel: TPressMVPModel;
    FNotifier: TPressNotifier;
    FShortCut: TShortCut;
    function GetComponentList: TPressMVPCommandComponentList;
    procedure Notify(AEvent: TPressEvent);
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
    property Caption: string read GetCaption;
    property Enabled: Boolean read FEnabled;
    property Model: TPressMVPModel read FModel;
    property ShortCut: TShortCut read GetShortCut;
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

  TPressMVPInteractorClass = class of TPressMVPInteractor;

  TPressMVPInteractor = class(TObject)
  private
    FNotifier: TPressNotifier;
    FOwner: TPressMVPPresenter;
    function GetNotifier: TPressNotifier;
  protected
    procedure InitInteractor; virtual;
    procedure Notify(AEvent: TPressEvent); virtual;
    property Notifier: TPressNotifier read GetNotifier;
  public
    constructor Create(AOwner: TPressMVPPresenter); virtual;
    destructor Destroy; override;
    class procedure RegisterInteractor;
    class function Apply(APresenter: TPressMVPPresenter): Boolean; virtual; abstract;
    property Owner: TPressMVPPresenter read FOwner;
  end;

  TPressMVPInteractorIterator = class;

  TPressMVPInteractorList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressMVPInteractor;
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressMVPInteractor): Integer;
    function CreateIterator: TPressMVPInteractorIterator;
    function IndexOf(AObject: TPressMVPInteractor): Integer;
    procedure Insert(Index: Integer; AObject: TPressMVPInteractor);
    function Remove(AObject: TPressMVPInteractor): Integer;
    property Items[AIndex: Integer]: TPressMVPInteractor read GetItems; default;
  end;

  TPressMVPInteractorIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressMVPInteractor;
  public
    property CurrentItem: TPressMVPInteractor read GetCurrentItem;
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

  TPressMVPModelNotifyEvent = procedure(Sender: TPressMVPModel) of object;

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
  protected
    procedure InitCommands; virtual;
    function InternalCreateSelection: TPressMVPSelection; virtual;
    procedure Notify(AEvent: TPressEvent); virtual;
    property Commands: TPressMVPCommands read GetCommands;
    property Notifier: TPressNotifier read GetNotifier;
    property OwnedCommands: TPressMVPCommandList read GetOwnedCommands;
  public
    constructor Create(AParent: TPressMVPModel; ASubject: TPressSubject); virtual;
    destructor Destroy; override;
    function AddCommand(ACommandClass: TPressMVPCommandClass): Integer;
    procedure AddCommands(ACommandClasses: array of TPressMVPCommandClass);
    class function Apply: TPressSubjectClass; virtual; abstract;
    procedure Changed;
    { TODO : Remove this factory method }
    class function CreateFromSubject(AParent: TPressMVPModel; ASubject: TPressSubject): TPressMVPModel;
    function FindCommand(ACommandClass: TPressMVPCommandClass): TPressMVPCommand;
    function HasCommands: Boolean;
    function RegisterCommand(ACommandClass: TPressMVPCommandClass): TPressMVPCommand;
    class procedure RegisterModel;
    property HasParent: Boolean read GetHasParent;
    property HasSubject: Boolean read GetHasSubject;
    property Parent: TPressMVPModel read FParent;
    property Selection: TPressMVPSelection read GetSelection;
    property Subject: TPressSubject read FSubject;
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

  TPressMVPViewEvent = class(TPressEvent)
  protected
    {$IFNDEF PressLogViewEvents}
    function AllowLog: Boolean; override;
    {$ENDIF}
  end;

  TPressMVPViewClickEvent = class(TPressMVPViewEvent)
  end;

  TPressMVPViewDblClickEvent = class(TPressMVPViewEvent)
  end;

  TPressMVPViewClass = class of TPressMVPView;

  TPressMVPView = class(TPressMVPObject)
  private
    FControl: TControl;
    FOwnsControl: Boolean;
    FPresenter: TPressMVPPresenter;
    FViewClickEvent: TNotifyEvent;
    FViewDblClickEvent: TNotifyEvent;
  protected
    procedure ViewClickEvent(Sender: TObject); virtual;
    procedure ViewDblClickEvent(Sender: TObject); virtual;
  protected
    procedure InitView; virtual;
    { TODO : rename - use a pattern (here and in the Subject unit,
      structure classes) }
    procedure ModelChanged(Sender: TPressMVPModel); virtual;
  public
    constructor Create(AControl: TControl; AOwnsControl: Boolean = False); virtual;
    destructor Destroy; override;
    class function Apply(AControl: TControl): Boolean; virtual; abstract;
    { TODO : Remove this factory method }
    class function CreateFromControl(AControl: TControl; AOwnsControl: Boolean = False): TPressMVPView;
    class procedure RegisterView;
    property Control: TControl read FControl;
    property OwnsControl: Boolean read FOwnsControl write FOwnsControl;
    property Presenter: TPressMVPPresenter read FPresenter;
  end;

  TPressMVPFreePresenterEvent = class(TPressEvent)
  end;

  TPressMVPPresenterList = class;

  TPressMVPPresenterClass = class of TPressMVPPresenter;

  TPressMVPPresenter = class(TPressMVPObject)
  private
    FCommandMenu: TPressMVPCommandMenu;
    FInteractors: TPressMVPInteractorList;
    FModel: TPressMVPModel;
    FParent: TPressMVPPresenter;
    FSubPresenters: TPressMVPPresenterList;
    FView: TPressMVPView;
    procedure AfterChangeCommandMenu;
    procedure AfterChangeModel;
    procedure AfterChangeView;
    procedure BeforeChangeCommandMenu;
    procedure BeforeChangeModel;
    procedure BeforeChangeView;
    procedure DoInitPresenter;
    procedure DoInitInteractors;
    function GetInteractors: TPressMVPInteractorList;
    function GetSubPresenter(AIndex: Integer): TPressMVPPresenter;
    function GetSubPresenters: TPressMVPPresenterList;
    procedure SetCommandMenu(Value: TPressMVPCommandMenu);
    procedure SetModel(Value: TPressMVPModel);
    procedure SetView(Value: TPressMVPView);
  protected
    procedure AfterInitInteractors; virtual;
    procedure BindCommand(ACommandClass: TPressMVPCommandClass; const AComponentName: ShortString);
    function ComponentByName(const AComponentName: ShortString): TComponent;
    function ControlByName(const AControlName: ShortString): TControl;
    procedure InitPresenter; virtual;
    function InternalCreateCommandMenu: TPressMVPCommandMenu; virtual;
    function InternalCreateSubModel(ASubject: TPressSubject): TPressMVPModel; virtual;
    function InternalCreateSubPresenter(AModel: TPressMVPModel; AView: TPressMVPView): TPressMVPPresenter; virtual;
    function InternalCreateSubView(AControl: TControl): TPressMVPView; virtual;
    function InternalFindComponent(const AComponentName: string): TComponent; virtual;
    procedure InternalUpdateModel; virtual; abstract;
    procedure InternalUpdateView; virtual; abstract;
    property CommandMenu: TPressMVPCommandMenu read FCommandMenu write SetCommandMenu;
    property Interactors: TPressMVPInteractorList read GetInteractors;
    property SubPresenters: TPressMVPPresenterList read GetSubPresenters;
  public
    constructor Create(AOwner: TPressMVPPresenter; AModel: TPressMVPModel; AView: TPressMVPView); virtual;
    destructor Destroy; override;
    procedure AddSubPresenter(APresenter: TPressMVPPresenter);
    class function Apply(AModel: TPressMVPModel; AView: TPressMVPView): Boolean; virtual; abstract;
    { TODO : Remove this factory method }
    class function CreateFromControllers(AOwner: TPressMVPPresenter; AModel: TPressMVPModel; AView: TPressMVPView): TPressMVPPresenter;
    procedure Refresh;
    class procedure RegisterPresenter;
    function SubPresenterCount: Integer;
    procedure UpdateModel;
    procedure UpdateView;
    property Model: TPressMVPModel read FModel;
    property Parent: TPressMVPPresenter read FParent;
    property SubPresenter[AIndex: Integer]: TPressMVPPresenter read GetSubPresenter;
    property View: TPressMVPView read FView;
  end;

  TPressMVPPresenterIterator = class;

  TPressMVPPresenterList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressMVPPresenter;
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressMVPPresenter): Integer;
    function CreateIterator: TPressMVPPresenterIterator;
    function IndexOf(AObject: TPressMVPPresenter): Integer;
    procedure Insert(Index: Integer; AObject: TPressMVPPresenter);
    function Remove(AObject: TPressMVPPresenter): Integer;
    property Items[AIndex: Integer]: TPressMVPPresenter read GetItems; default;
  end;

  TPressMVPPresenterIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressMVPPresenter;
  public
    property CurrentItem: TPressMVPPresenter read GetCurrentItem;
  end;

implementation

uses
  SysUtils,
  Contnrs,
  PressConsts,
  {$IFDEF PressLog}PressLog,{$ENDIF}
  PressMVPCommand;

type
  TPressMVPFactory = class(TPressSingleton)
  private
    function ChooseConcreteClass(ATargetClass, ACandidateClass1, ACandidateClass2: TClass): Integer;
  public
    function MVPModelFactory(AParent: TPressMVPModel; ASubject: TPressSubject): TPressMVPModel;
    function MVPViewFactory(AControl: TControl; AOwnsControl: Boolean = False): TPressMVPView;
    function MVPPresenterFactory(AOwner: TPressMVPPresenter; AModel: TPressMVPModel; AView: TPressMVPView): TPressMVPPresenter; overload;
  end;

  TPressMVPControlFriend = class(TControl);

var
  _PressRegisteredModels: TClassList;
  _PressRegisteredViews: TClassList;
  _PressRegisteredPresenters: TClassList;
  _PressRegisteredInteractors: TClassList;

function PressRegisteredModels: TClassList;
begin
  if not Assigned(_PressRegisteredModels) then
  begin
    _PressRegisteredModels := TClassList.Create;
    PressRegisterSingleObject(_PressRegisteredModels);
  end;
  Result := _PressRegisteredModels;
end;

function PressRegisteredViews: TClassList;
begin
  if not Assigned(_PressRegisteredViews) then
  begin
    _PressRegisteredViews := TClassList.Create;
    PressRegisterSingleObject(_PressRegisteredViews);
  end;
  Result := _PressRegisteredViews;
end;

function PressRegisteredPresenters: TClassList;
begin
  if not Assigned(_PressRegisteredPresenters) then
  begin
    _PressRegisteredPresenters := TClassList.Create;
    PressRegisterSingleObject(_PressRegisteredPresenters);
  end;
  Result := _PressRegisteredPresenters;
end;

function PressRegisteredInteractors: TClassList;
begin
  if not Assigned(_PressRegisteredInteractors) then
  begin
    _PressRegisteredInteractors := TClassList.Create;
    PressRegisterSingleObject(_PressRegisteredInteractors);
  end;
  Result := _PressRegisteredInteractors;
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

{ TPressMVPCommandControl }

procedure TPressMVPCommandControl.BindComponent;
begin
  if Assigned(FControl) then
  begin
    OnClickEvent := TPressMVPControlFriend(FControl).OnClick;
    TPressMVPControlFriend(FControl).OnClick := ComponentClick;
    FControl.Enabled := Command.Enabled;
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
  FEnabled := InternalIsEnabled;
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
  if Model.Subject is TPressObject then
    Notifier.AddNotificationItem(Model.Subject, [TPressObjectChangedEvent]);
end;

function TPressMVPCommand.InternalIsEnabled: Boolean;
begin
  Result := True;
end;

procedure TPressMVPCommand.Notify(AEvent: TPressEvent);
begin
  if FEnabled <> InternalIsEnabled then
  begin
    FEnabled := not FEnabled;
    ComponentList.Enabled := FEnabled;
    TPressMVPCommandChangedEvent.Create(Self).Notify;
  end;
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

{ TPressMVPInteractor }

constructor TPressMVPInteractor.Create(AOwner: TPressMVPPresenter);
begin
  inherited Create;
  FOwner := AOwner;
  InitInteractor;
end;

destructor TPressMVPInteractor.Destroy;
begin
  FNotifier.Free;
  inherited;
end;

function TPressMVPInteractor.GetNotifier: TPressNotifier;
begin
  if not Assigned(FNotifier) then
    FNotifier := TPressNotifier.Create(Notify);
  Result := FNotifier;
end;

procedure TPressMVPInteractor.InitInteractor;
begin
end;

procedure TPressMVPInteractor.Notify(AEvent: TPressEvent);
begin
end;

class procedure TPressMVPInteractor.RegisterInteractor;
begin
  PressRegisteredInteractors.Add(Self);
end;

{ TPressMVPInteractorList }

function TPressMVPInteractorList.Add(AObject: TPressMVPInteractor): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressMVPInteractorList.CreateIterator: TPressMVPInteractorIterator;
begin
  Result := TPressMVPInteractorIterator.Create(Self);
end;

function TPressMVPInteractorList.GetItems(AIndex: Integer): TPressMVPInteractor;
begin
  Result := inherited Items[AIndex] as TPressMVPInteractor;
end;

function TPressMVPInteractorList.IndexOf(AObject: TPressMVPInteractor): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressMVPInteractorList.Insert(Index: Integer; AObject: TPressMVPInteractor);
begin
  inherited Insert(Index, AObject);
end;

function TPressMVPInteractorList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressMVPInteractorList.Remove(AObject: TPressMVPInteractor): Integer;
begin
  Result := inherited Remove(AObject);
end;

{ TPressMVPInteractorIterator }

function TPressMVPInteractorIterator.GetCurrentItem: TPressMVPInteractor;
begin
  Result := inherited CurrentItem as TPressMVPInteractor;
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
  Result := TPressIterator.Create(FObjectList);
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

procedure TPressMVPModel.AddCommands(
  ACommandClasses: array of TPressMVPCommandClass);
var
  I: Integer;
begin
  for I := Low(ACommandClasses) to High(ACommandClasses) do
    AddCommand(ACommandClasses[I]);
end;

procedure TPressMVPModel.Changed;
begin
  if not EventsDisabled and Assigned(FOnChange) then
    FOnChange(Self);
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
  Result := TPressMVPFactory.Instance.MVPModelFactory(AParent, ASubject);
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
    Changed;
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
  PressRegisteredModels.Add(Self);
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

{ TPressMVPViewEvent }

{$IFNDEF PressLogViewEvents}
function TPressMVPViewEvent.AllowLog: Boolean;
begin
  Result := False;
end;
{$ENDIF}

{ TPressMVPView }

constructor TPressMVPView.Create(AControl: TControl; AOwnsControl: Boolean);
begin
  CheckClass(Apply(AControl));
  inherited Create;
  FControl := AControl;
  FOwnsControl := AOwnsControl;
  InitView;
end;

class function TPressMVPView.CreateFromControl(AControl: TControl;
  AOwnsControl: Boolean): TPressMVPView;
begin
  Result := TPressMVPFactory.Instance.MVPViewFactory(AControl, AOwnsControl);
end;

destructor TPressMVPView.Destroy;
begin
  if FOwnsControl then
    FControl.Free;
  inherited;
end;

procedure TPressMVPView.InitView;
begin
  with TPressMVPControlFriend(Control) do
  begin
    FViewClickEvent := OnClick;
    FViewDblClickEvent := OnDblClick;
    OnClick := ViewClickEvent;
    OnDblClick := ViewDblClickEvent;
  end;
end;

procedure TPressMVPView.ModelChanged(Sender: TPressMVPModel);
begin
  Presenter.UpdateView;
end;

class procedure TPressMVPView.RegisterView;
begin
  PressRegisteredViews.Add(Self);
end;

procedure TPressMVPView.ViewClickEvent(Sender: TObject);
begin
  if EventsDisabled then
    Exit;
  TPressMVPViewClickEvent.Create(Self).Notify;
  if Assigned(FViewClickEvent) then
    FViewClickEvent(Sender);
end;

procedure TPressMVPView.ViewDblClickEvent(Sender: TObject);
begin
  if EventsDisabled then
    Exit;
  TPressMVPViewDblClickEvent.Create(Self).Notify;
  if Assigned(FViewDblClickEvent) then
    FViewDblClickEvent(Sender);
end;

{ TPressMVPPresenter }

procedure TPressMVPPresenter.AddSubPresenter(APresenter: TPressMVPPresenter);
begin
  APresenter.FParent := Self;
  SubPresenters.Add(APresenter);
end;

procedure TPressMVPPresenter.AfterChangeCommandMenu;
begin
  if Assigned(FCommandMenu) then
  begin
    if Assigned(FView) then
      FCommandMenu.AssignMenu(FView.Control);
    if Assigned(FModel) then
      FCommandMenu.AssignCommands(FModel.Commands);
  end;
end;

procedure TPressMVPPresenter.AfterChangeModel;
begin
  if Assigned(FModel) then
  begin
    if Assigned(FView) then
      FModel.FOnChange := FView.ModelChanged;  // friend class
    if Assigned(FCommandMenu) then
      FCommandMenu.AssignCommands(FModel.Commands);
  end;
end;

procedure TPressMVPPresenter.AfterChangeView;
begin
  if Assigned(FView) then
  begin
    if Assigned(FCommandMenu) then
      FCommandMenu.AssignMenu(FView.Control);
    if Assigned(FModel) then
      FModel.FOnChange := FView.ModelChanged;  // friend class
  end;
end;

procedure TPressMVPPresenter.AfterInitInteractors;
begin
end;

procedure TPressMVPPresenter.BeforeChangeCommandMenu;
begin
  if Assigned(FCommandMenu) then
  begin
    if Assigned(FView) then
      FCommandMenu.AssignMenu(nil);
    if Assigned(FModel) then
      FCommandMenu.UnassignCommands;
  end;
end;

procedure TPressMVPPresenter.BeforeChangeModel;
begin
  if Assigned(FModel) then
  begin
    if Assigned(FView) then
      FModel.FOnChange := nil;  // friend class
    if Assigned(FCommandMenu) then
      FCommandMenu.UnassignCommands;
    FreeAndNil(FModel);
  end;
end;

procedure TPressMVPPresenter.BeforeChangeView;
begin
  if Assigned(FView) then
  begin
    if Assigned(FCommandMenu) then
      FCommandMenu.AssignMenu(nil);
    if Assigned(FModel) then
      FModel.FOnChange := nil;  // friend class
    FreeAndNil(FView);
  end;
end;

procedure TPressMVPPresenter.BindCommand(
  ACommandClass: TPressMVPCommandClass; const AComponentName: ShortString);
var
  VComponent: TComponent;
begin
  VComponent := ComponentByName(AComponentName);
  if not Assigned(ACommandClass) then
    ACommandClass := TPressMVPNullCommand;
  Model.RegisterCommand(ACommandClass).AddComponent(VComponent);
end;

function TPressMVPPresenter.ComponentByName(
  const AComponentName: ShortString): TComponent;
begin
  Result := InternalFindComponent(AComponentName);
  if not Assigned(Result) then
    raise EPressMVPError.CreateFmt(SComponentNotFound,
     [View.Control.ClassName, AComponentName]);
end;

function TPressMVPPresenter.ControlByName(
  const AControlName: ShortString): TControl;
var
  VComponent: TComponent;
begin
  VComponent := ComponentByName(AControlName);
  if not (VComponent is TControl) then
    raise EPressMVPError.CreateFmt(SComponentIsNotAControl,
     [View.Control.ClassName, AControlName]);
  Result := TControl(VComponent);
end;

constructor TPressMVPPresenter.Create(
  AOwner: TPressMVPPresenter; AModel: TPressMVPModel; AView: TPressMVPView);
begin
  CheckClass(Apply(AModel, AView));
  inherited Create;
  if Assigned(AOwner) then
    AOwner.AddSubPresenter(Self);
  SetModel(AModel);
  SetView(AView);
  View.FPresenter := Self;  // friend class
  if Model.HasCommands then
    CommandMenu := InternalCreateCommandMenu;
  DoInitPresenter;
  DoInitInteractors;
end;

class function TPressMVPPresenter.CreateFromControllers(
  AOwner: TPressMVPPresenter;
  AModel: TPressMVPModel; AView: TPressMVPView): TPressMVPPresenter;
begin
  Result :=
   TPressMVPFactory.Instance.MVPPresenterFactory(AOwner, AModel, AView);
end;

destructor TPressMVPPresenter.Destroy;
begin
  { TODO : Avoid events (specially View events) when destroying MVP objects
    Create CanNotify property or Destroying status }
  if Assigned(FParent) then
    FParent.SubPresenters.Extract(Self);
  FSubPresenters.Free;
  BeforeChangeCommandMenu;
  BeforeChangeModel;
  BeforeChangeView;
  FCommandMenu.Free;
  FInteractors.Free;
  inherited;
end;

procedure TPressMVPPresenter.DoInitInteractors;

  function ExistSubClasses(AClass: TPressMVPInteractorClass): Boolean;
  var
    I: Integer;
  begin
    for I := 0 to Pred(Interactors.Count) do
    begin
      Result := Interactors[I].InheritsFrom(AClass);
      if Result then
        Exit;
    end;
    Result := False;
  end;

  procedure RemoveSuperClasses(AClass: TPressMVPInteractorClass);
  var
    I: Integer;
  begin
    for I := Pred(Interactors.Count) downto 0 do
      if AClass.InheritsFrom(Interactors[I].ClassType) then
        Interactors.Delete(I);
  end;

var
  VInteractorClass: TPressMVPInteractorClass;
  I: Integer;
begin
  for I := 0 to Pred(PressRegisteredInteractors.Count) do
  begin
    VInteractorClass := TPressMVPInteractorClass(PressRegisteredInteractors[I]);
    if VInteractorClass.Apply(Self) and not ExistSubClasses(VInteractorClass) then
    begin
      RemoveSuperClasses(VInteractorClass);
      Interactors.Add(VInteractorClass.Create(Self));
    end;
  end;
  AfterInitInteractors;
end;

procedure TPressMVPPresenter.DoInitPresenter;
begin
  InitPresenter;
end;

function TPressMVPPresenter.GetInteractors: TPressMVPInteractorList;
begin
  if not Assigned(FInteractors) then
    FInteractors := TPressMVPInteractorList.Create(True);
  Result := FInteractors;
end;

function TPressMVPPresenter.GetSubPresenter(AIndex: Integer): TPressMVPPresenter;
begin
  Result := SubPresenters[AIndex];
end;

function TPressMVPPresenter.GetSubPresenters: TPressMVPPresenterList;
begin
  if not Assigned(FSubPresenters) then
    FSubPresenters := TPressMVPPresenterList.Create(True);
  Result := FSubPresenters;
end;

procedure TPressMVPPresenter.InitPresenter;
begin
end;

function TPressMVPPresenter.InternalCreateCommandMenu: TPressMVPCommandMenu;
begin
  Result := TPressMVPPopupCommandMenu.Create;
end;

function TPressMVPPresenter.InternalCreateSubModel(ASubject: TPressSubject): TPressMVPModel;
begin
  Result := TPressMVPModel.CreateFromSubject(Model, ASubject);
end;

function TPressMVPPresenter.InternalCreateSubPresenter(
  AModel: TPressMVPModel; AView: TPressMVPView): TPressMVPPresenter;
begin
  Result := TPressMVPPresenter.CreateFromControllers(Self, AModel, AView);
end;

function TPressMVPPresenter.InternalCreateSubView(AControl: TControl): TPressMVPView;
begin
  Result := TPressMVPView.CreateFromControl(AControl);
end;

function TPressMVPPresenter.InternalFindComponent(
  const AComponentName: string): TComponent;
begin
  if Assigned(FParent) then
    Result := FParent.InternalFindComponent(AComponentName)
  else
    Result := nil;
end;

procedure TPressMVPPresenter.Refresh;
begin
  UpdateView;
  with SubPresenters.CreateIterator do
  try
    BeforeFirstItem;
    while NextItem do
      CurrentItem.UpdateView;
  finally
    Free;
  end;
end;

class procedure TPressMVPPresenter.RegisterPresenter;
begin
  PressRegisteredPresenters.Add(Self);
end;

procedure TPressMVPPresenter.SetCommandMenu(Value: TPressMVPCommandMenu);
begin
  if FCommandMenu <> Value then
  begin
    BeforeChangeCommandMenu;
    FCommandMenu := Value;
    AfterChangeCommandMenu;
  end;
end;

procedure TPressMVPPresenter.SetModel(Value: TPressMVPModel);
begin
  if FModel <> Value then
  begin
    BeforeChangeModel;
    FModel := Value;
    AfterChangeModel;
  end;
end;

procedure TPressMVPPresenter.SetView(Value: TPressMVPView);
begin
  if FView <> Value then
  begin
    BeforeChangeView;
    FView := Value;
    AfterChangeView;
  end;
end;

function TPressMVPPresenter.SubPresenterCount: Integer;
begin
  if Assigned(FSubPresenters) then
    Result := FSubPresenters.Count
  else
    Result := 0;
end;

procedure TPressMVPPresenter.UpdateModel;
begin
  {$IFDEF PressLogMVP}PressLogMsg(Self, 'Updating Model');{$ENDIF}
  InternalUpdateModel;
  with SubPresenters.CreateIterator do
  try
    BeforeFirstItem;
    while NextItem do
      CurrentItem.UpdateModel;
  finally
    Free;
  end;
end;

procedure TPressMVPPresenter.UpdateView;
begin
  {$IFDEF PressLogMVP}PressLogMsg(Self, 'Updating View ', [View.Control]);{$ENDIF}
  InternalUpdateView;
end;

{ TPressMVPPresenterList }

function TPressMVPPresenterList.Add(AObject: TPressMVPPresenter): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressMVPPresenterList.CreateIterator: TPressMVPPresenterIterator;
begin
  Result := TPressMVPPresenterIterator.Create(Self);
end;

function TPressMVPPresenterList.GetItems(AIndex: Integer): TPressMVPPresenter;
begin
  Result := inherited Items[AIndex] as TPressMVPPresenter;
end;

function TPressMVPPresenterList.IndexOf(AObject: TPressMVPPresenter): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressMVPPresenterList.Insert(Index: Integer; AObject: TPressMVPPresenter);
begin
  inherited Insert(Index, AObject);
end;

function TPressMVPPresenterList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressMVPPresenterList.Remove(AObject: TPressMVPPresenter): Integer;
begin
  Result := inherited Remove(AObject);
end;

{ TPressMVPPresenterIterator }

function TPressMVPPresenterIterator.GetCurrentItem: TPressMVPPresenter;
begin
  Result := inherited CurrentItem as TPressMVPPresenter;
end;

{ TPressMVPFactory }

function TPressMVPFactory.ChooseConcreteClass(
  ATargetClass, ACandidateClass1, ACandidateClass2: TClass): Integer;

  function InheritanceLevel(AClass: TClass): Integer;
  begin
    Result := 0;
    while Assigned(AClass) do
    begin
      Inc(Result);
      AClass := AClass.ClassParent;
    end;
  end;

var
  VLevel1, VLevel2: Integer;
begin
  { TODO : Return a class or a boolean instead an Integer }
  if not Assigned(ATargetClass) then
    raise EPressMVPError.Create(SUnassignedTargetClass)
  else if not Assigned(ACandidateClass1) and not Assigned(ACandidateClass2) then
    raise EPressMVPError.Create(SUnassignedCandidateClasses)
  else if Assigned(ACandidateClass1) and not ATargetClass.InheritsFrom(ACandidateClass1) then
    raise EPressMVPError.CreateFmt(SNonRelatedClasses,
     [ATargetClass.ClassName, ACandidateClass1.ClassName])
  else if Assigned(ACandidateClass2) and not ATargetClass.InheritsFrom(ACandidateClass2) then
    raise EPressMVPError.CreateFmt(SNonRelatedClasses,
     [ATargetClass.ClassName, ACandidateClass2.ClassName])
  else if not Assigned(ACandidateClass1) then
    Result := 2
  else if not Assigned(ACandidateClass2) then
    Result := 1
  else
  begin
    VLevel1 := InheritanceLevel(ACandidateClass1);
    VLevel2 := InheritanceLevel(ACandidateClass2);
    if VLevel1 > VLevel2 then
      Result := 1
    else if VLevel2 > VLevel1 then
      Result := 2
    else
      raise EPressMVPError.CreateFmt(SAmbiguousConcreteClass,
       [ACandidateClass1.ClassName, ACandidateClass2.ClassName,
       ATargetClass.ClassName]);
  end;
end;

function TPressMVPFactory.MVPModelFactory(AParent: TPressMVPModel; ASubject: TPressSubject): TPressMVPModel;
var
  VModelClass, VCandidateClass: TPressMVPModelClass;
  I: Integer;
begin
  if Assigned(ASubject) then
  begin
    VCandidateClass := nil;
    for I := 0 to Pred(PressRegisteredModels.Count) do
    begin
      VModelClass := TPressMVPModelClass(PressRegisteredModels[I]);
      if ASubject.InheritsFrom(VModelClass.Apply) and
       (not Assigned(VCandidateClass) or (ChooseConcreteClass(
       ASubject.ClassType, VCandidateClass.Apply, VModelClass.Apply) = 2)) then
        VCandidateClass := VModelClass;
    end;
    if not Assigned(VCandidateClass) then
      raise EPressMVPError.CreateFmt(SUnsupportedObject,
       [TPressMVPModel.ClassName, ASubject.ClassName]);
  end else
    raise EPressMVPError.Create(SUnassignedSubject);
  Result := VCandidateClass.Create(AParent, ASubject);
end;

function TPressMVPFactory.MVPPresenterFactory(
  AOwner: TPressMVPPresenter;
  AModel: TPressMVPModel; AView: TPressMVPView): TPressMVPPresenter;
var
  VPresenterClass, VCandidateClass: TPressMVPPresenterClass;
  I: Integer;
begin
  VCandidateClass := nil;
  for I := 0 to Pred(PressRegisteredPresenters.Count) do
  begin
    VPresenterClass := TPressMVPPresenterClass(PressRegisteredPresenters[I]);
    if VPresenterClass.Apply(AModel, AView) then
    begin
      if Assigned(VCandidateClass) then
        raise EPressMVPError.CreateFmt(SAmbiguousConcreteClass,
         [VCandidateClass.ClassName, VPresenterClass.ClassName,
         TPressMVPPresenter.ClassName, AModel.ClassName + ', ' + AView.ClassName]);
      VCandidateClass := VPresenterClass;
    end;
  end;
  if not Assigned(VCandidateClass) then
    raise EPressMVPError.CreateFmt(SUnsupportedObject,
     [TPressMVPPresenter.ClassName, AModel.ClassName + ', ' + AView.ClassName]);
  Result := VCandidateClass.Create(AOwner, AModel, AView);
end;

function TPressMVPFactory.MVPViewFactory(AControl: TControl;
  AOwnsControl: Boolean): TPressMVPView;
var
  VViewClass, VCandidateClass: TPressMVPViewClass;
  I: Integer;
begin
  VCandidateClass := nil;
  for I := 0 to Pred(PressRegisteredViews.Count) do
  begin
    VViewClass := TPressMVPViewClass(PressRegisteredViews[I]);
    if VViewClass.Apply(AControl) then
    begin
      if Assigned(VCandidateClass) then
        raise EPressMVPError.CreateFmt(SAmbiguousConcreteClass,
         [VCandidateClass.ClassName, VViewClass.ClassName,
         AControl.ClassName, AControl.Name]);
      VCandidateClass := VViewClass;
    end;
  end;
  if not Assigned(VCandidateClass) then
    raise EPressMVPError.CreateFmt(SUnsupportedControl,
     [AControl.ClassName, AControl.Name]);
  Result := VCandidateClass.Create(AControl, AOwnsControl);
end;

end.
