(*
  PressObjects, Event and Notification Classes
  Copyright (C) 2006-2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressNotifier;

{$DEFINE PressBaseUnit}
{$I Press.inc}

interface

uses
  PressClasses;

type
  TPressEventClass = class of TPressEvent;

  TPressEvent = class(TObject)
  private
    FOwner: TObject;
    {$IFDEF PressLogEvents}
    procedure DoLogEvent(Sender: TObject; const AMsg: string; const AParams: array of TObject);
    {$ENDIF}
  protected
    function AllowLog: Boolean; virtual;
    procedure InternalLogEvent(Sender: TObject; const AMsg: string; const AParams: array of TObject); virtual;
  public
    constructor Create(AOwner: TObject);
    procedure Notify(AReleaseEvent: Boolean = True);
    procedure QueueNotification;
    procedure Release;
    property Owner: TObject read FOwner;
  end;

  TPressEventIterator = class;

  TPressEventList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressEvent;
    procedure SetItems(AIndex: Integer; Value: TPressEvent);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressEvent): Integer;
    function CreateIterator: TPressEventIterator;
    function Extract(AObject: TPressEvent): TPressEvent;
    function IndexOf(AObject: TPressEvent): Integer;
    procedure Insert(Index: Integer; AObject: TPressEvent);
    function Remove(AObject: TPressEvent): Integer;
    property Items[AIndex: Integer]: TPressEvent read GetItems write SetItems; default;
  end;

  TPressEventIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressEvent;
  public
    property CurrentItem: TPressEvent read GetCurrentItem;
  end;

  TPressNotificationEvent = procedure(AEvent: TPressEvent) of object;

  TPressNotifier = class(TObject)
  private
    FDisableEventsCount: Integer;
    FNotificationEvent: TPressNotificationEvent;
    function GetEventsDisabled: Boolean;
  public
    constructor Create(ANotificationEvent: TPressNotificationEvent);
    destructor Destroy; override;
    procedure AddNotificationItem(AObservedObject: TObject; AClasses: array of TPressEventClass);
    procedure DisableEvents;
    procedure EnableEvents;
    procedure ProcessEvent(AEvent: TPressEvent);
    procedure RemoveNotificationItem(AObservedObject: TObject);
    property EventsDisabled: Boolean read GetEventsDisabled;
  end;

  TPressNotifierIterator = class;

  TPressNotifierList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressNotifier;
    procedure SetItems(AIndex: Integer; AValue: TPressNotifier);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressNotifier): Integer;
    function CreateIterator: TPressNotifierIterator;
    function IndexOf(AObject: TPressNotifier): Integer;
    procedure Insert(Index: Integer; AObject: TPressNotifier);
    function Remove(AObject: TPressNotifier): Integer;
    function UnassignNotifiers(ANotifier: TPressNotifier): Boolean;
    property Items[AIndex: Integer]: TPressNotifier read GetItems write SetItems; default;
  end;

  TPressNotifierIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressNotifier;
  public
    property CurrentItem: TPressNotifier read GetCurrentItem;
  end;

  TPressNotificationItem = class(TObject)
  private
    FNotifiers: TPressNotifierList;
    FObservedObject: TObject;
    function GetNotifiers: TPressNotifierList;
  public
    constructor Create(AObservedObject: TObject);
    destructor Destroy; override;
    property Notifiers: TPressNotifierList read GetNotifiers;
    property ObservedObject: TObject read FObservedObject;
  end;

  TPressNotificationIterator = class;

  TPressNotificationList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressNotificationItem;
    function GetObservedObjectItem(AObservedObject: TObject): TPressNotificationItem;
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressNotificationItem): Integer;
    procedure AddNotification(ANotifier: TPressNotifier; AObservedObject: TObject);
    function CreateIterator: TPressNotificationIterator;
    function IndexOf(AObject: TPressNotificationItem): Integer;
    procedure Insert(Index: Integer; AObject: TPressNotificationItem);
    function Remove(AObject: TPressNotificationItem): Integer;
    function RemoveNotification(ANotifier: TPressNotifier; AObservedObject: TObject): Boolean;
    property Items[AIndex: Integer]: TPressNotificationItem read GetItems; default;
    property ObservedObjectItem[AObservedObject: TObject]: TPressNotificationItem read GetObservedObjectItem;
  end;

  TPressNotificationIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressNotificationItem;
  public
    property CurrentItem: TPressNotificationItem read GetCurrentItem;
  end;

  TPressEventClassItem = class(TObject)
  private
    FEventClass: TPressEventClass;
    FNotifications: TPressNotificationList;
    function GetNotifications: TPressNotificationList;
  public
    constructor Create(AEventClass: TPressEventClass);
    destructor Destroy; override;
    property Notifications: TPressNotificationList read GetNotifications;
    property EventClass: TPressEventClass read FEventClass;
  end;

  TPressEventClassIterator = class;

  TPressEventClassList = class(TPressList)
  private
    FHasRemovedNotifiers: Boolean;
    function GetClassItem(AEventClass: TPressEventClass): TPressEventClassItem;
    function GetItems(AIndex: Integer): TPressEventClassItem;
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressEventClassItem): Integer;
    procedure AddNotification(ANotifier: TPressNotifier; AObservedObject: TObject; AEventClass: TPressEventClass);
    function CreateIterator: TPressEventClassIterator;
    function IndexOf(AObject: TPressEventClassItem): Integer;
    procedure Insert(Index: Integer; AObject: TPressEventClassItem);
    function Remove(AObject: TPressEventClassItem): Integer;
    procedure RemoveNotification(ANotifier: TPressNotifier; AObservedObject: TObject);
    property EventClassItem[AEventClass: TPressEventClass]: TPressEventClassItem read GetClassItem;
    property HasRemovedNotifiers: Boolean read FHasRemovedNotifiers;
    property Items[AIndex: Integer]: TPressEventClassItem read GetItems; default;
  end;

  TPressEventClassIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressEventClassItem;
  public
    property CurrentItem: TPressEventClassItem read GetCurrentItem;
  end;

  TPressNotifiers = class(TObject)
  private
    FEventClasses: TPressEventClassList;
    FLockShrinkListCount: Integer;
    function GetEventClasses: TPressEventClassList;
    procedure LockShrinkList;
    procedure ShrinkEventClasses;
    procedure UnlockShrinkList;
  protected
    property EventClasses: TPressEventClassList read GetEventClasses;
  public
    destructor Destroy; override;
    procedure NotifyEvent(AEvent: TPressEvent);
    procedure Subscribe(ANotifier: TPressNotifier; AObservedObject: TObject; AEventClass: TPressEventClass);
    procedure Unsubscribe(ANotifier: TPressNotifier; AObservedObject: TObject = nil);
  end;

procedure PressProcessEventQueue;

implementation

uses
  SysUtils
  {$IFDEF PressLog}, PressLog{$ENDIF}
  ;

var
  _Notifiers: IPressHolder; //TPressNotifiers;
  _EventQueue: IPressHolder; //TPressEventList;

function PressNotifiers: TPressNotifiers;
begin
  if not Assigned(_Notifiers) then
    _Notifiers := TPressHolder.Create(TPressNotifiers.Create);
  Result := TPressNotifiers(_Notifiers.Instance);
end;

function PressEventQueue: TPressEventList;
begin
  if not Assigned(_EventQueue) then
    _EventQueue := TPressHolder.Create(TPressEventList.Create(False));
  Result := TPressEventList(_EventQueue.Instance);
end;

procedure PressProcessEventQueue;
var
  VEventQueue: TPressEventList;
  VEvent: TPressEvent;
begin
  if Assigned(_EventQueue) then
  begin
    VEventQueue := PressEventQueue;
    while VEventQueue.Count > 0 do
    begin
      VEvent := VEventQueue[0];
      VEventQueue.Extract(VEvent);
      VEvent.Notify;
    end;
  end;
end;

{ TPressEvent }

function TPressEvent.AllowLog: Boolean;
begin
  Result := True;
end;

constructor TPressEvent.Create(AOwner: TObject);
begin
  inherited Create;
  FOwner := AOwner;
  {$IFDEF PressLogEvents}DoLogEvent(Self, 'Event Started', [FOwner]);{$ENDIF}
end;

{$IFDEF PressLogEvents}
procedure TPressEvent.DoLogEvent(
  Sender: TObject; const AMsg: string; const AParams: array of TObject);
begin
  InternalLogEvent(Sender, AMsg, AParams);
end;
{$ENDIF}

procedure TPressEvent.InternalLogEvent(
  Sender: TObject; const AMsg: string; const AParams: array of TObject);
begin
  {$IFDEF PressLogEvents}
  if AllowLog then
    PressLogMsg(Sender, AMsg, AParams);
  {$ENDIF}
end;

procedure TPressEvent.Notify(AReleaseEvent: Boolean);
begin
  try
    {$IFDEF PressLogEvents}DoLogEvent(Self, 'Notifying Event', [FOwner]);{$ENDIF}
    PressNotifiers.NotifyEvent(Self);
    {$IFDEF PressLogEvents}DoLogEvent(Self, 'Event Notified', [FOwner]);{$ENDIF}
  finally
    if AReleaseEvent then
      Free;
  end;
end;

procedure TPressEvent.QueueNotification;
begin
  {$IFDEF PressLogEvents}DoLogEvent(Self, 'Queueing Event', [FOwner]);{$ENDIF}
  PressEventQueue.Add(Self);
end;

procedure TPressEvent.Release;
begin
  {$IFDEF PressLogEvents}DoLogEvent(Self, 'Releasing Event', [FOwner]);{$ENDIF}
  Free;
end;

{ TPressEventList }

function TPressEventList.Add(AObject: TPressEvent): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressEventList.CreateIterator: TPressEventIterator;
begin
  Result := TPressEventIterator.Create(Self);
end;

function TPressEventList.Extract(AObject: TPressEvent): TPressEvent;
begin
  Result := inherited Extract(AObject) as TPressEvent;
end;

function TPressEventList.GetItems(AIndex: Integer): TPressEvent;
begin
  Result := inherited Items[AIndex] as TPressEvent;
end;

function TPressEventList.IndexOf(AObject: TPressEvent): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressEventList.Insert(Index: Integer; AObject: TPressEvent);
begin
  inherited Insert(Index, AObject);
end;

function TPressEventList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressEventList.Remove(AObject: TPressEvent): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressEventList.SetItems(AIndex: Integer; Value: TPressEvent);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressEventIterator }

function TPressEventIterator.GetCurrentItem: TPressEvent;
begin
  Result := inherited CurrentItem as TPressEvent;
end;

{ TPressNotifier }

procedure TPressNotifier.AddNotificationItem(AObservedObject: TObject;
  AClasses: array of TPressEventClass);
var
  I: Integer;
begin
  with PressNotifiers do
    for I := Low(AClasses) to High(AClasses) do
      Subscribe(Self, AObservedObject, AClasses[I]);
end;

constructor TPressNotifier.Create(ANotificationEvent: TPressNotificationEvent);
begin
  inherited Create;
  FNotificationEvent := ANotificationEvent;
end;

destructor TPressNotifier.Destroy;
begin
  PressNotifiers.Unsubscribe(Self);
  inherited;
end;

procedure TPressNotifier.DisableEvents;
begin
  Inc(FDisableEventsCount);
end;

procedure TPressNotifier.EnableEvents;
begin
  if FDisableEventsCount > 0 then
    Dec(FDisableEventsCount);
end;

function TPressNotifier.GetEventsDisabled: Boolean;
begin
  Result := FDisableEventsCount > 0;
end;

procedure TPressNotifier.ProcessEvent(AEvent: TPressEvent);
begin
  if not EventsDisabled and Assigned(FNotificationEvent) then
    FNotificationEvent(AEvent);
end;

procedure TPressNotifier.RemoveNotificationItem(AObservedObject: TObject);
begin
  PressNotifiers.Unsubscribe(Self, AObservedObject);
end;

{ TPressNotifierList }

function TPressNotifierList.Add(AObject: TPressNotifier): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressNotifierList.CreateIterator: TPressNotifierIterator;
begin
  Result := TPressNotifierIterator.Create(Self);
end;

function TPressNotifierList.GetItems(AIndex: Integer): TPressNotifier;
begin
  Result := inherited Items[AIndex] as TPressNotifier;
end;

function TPressNotifierList.IndexOf(AObject: TPressNotifier): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressNotifierList.Insert(Index: Integer; AObject: TPressNotifier);
begin
  inherited Insert(Index, AObject);
end;

function TPressNotifierList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressNotifierList.Remove(AObject: TPressNotifier): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressNotifierList.SetItems(
  AIndex: Integer; AValue: TPressNotifier);
begin
  inherited Items[AIndex] := AValue;
end;

function TPressNotifierList.UnassignNotifiers(
  ANotifier: TPressNotifier): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Pred(Count) do
    if Items[I] = ANotifier then
    begin
      Items[I] := nil;
      Result := True;
    end;
end;

{ TPressNotifierIterator }

function TPressNotifierIterator.GetCurrentItem: TPressNotifier;
begin
  Result := inherited CurrentItem as TPressNotifier;
end;

{ TPressNotificationItem }

constructor TPressNotificationItem.Create(AObservedObject: TObject);
begin
  inherited Create;
  FObservedObject := AObservedObject;
end;

destructor TPressNotificationItem.Destroy;
begin
  FNotifiers.Free;
  inherited;
end;

function TPressNotificationItem.GetNotifiers: TPressNotifierList;
begin
  if not Assigned(FNotifiers) then
    FNotifiers := TPressNotifierList.Create(False);
  Result := FNotifiers;
end;

{ TPressNotificationList }

function TPressNotificationList.Add(AObject: TPressNotificationItem): Integer;
begin
  Result := inherited Add(AObject);
end;

procedure TPressNotificationList.AddNotification(ANotifier: TPressNotifier;
  AObservedObject: TObject);
begin
  ObservedObjectItem[AObservedObject].Notifiers.Add(ANotifier);
end;

function TPressNotificationList.CreateIterator: TPressNotificationIterator;
begin
  Result := TPressNotificationIterator.Create(Self);
end;

function TPressNotificationList.GetItems(
  AIndex: Integer): TPressNotificationItem;
begin
  Result := inherited Items[AIndex] as TPressNotificationItem;
end;

function TPressNotificationList.GetObservedObjectItem(
  AObservedObject: TObject): TPressNotificationItem;
var
  I: Integer;
begin
  for I := 0 to Pred(Count) do
  begin
    Result := Items[I];
    if Result.ObservedObject = AObservedObject then
      Exit;
  end;
  Result := TPressNotificationItem.Create(AObservedObject);
  Add(Result);
end;

function TPressNotificationList.IndexOf(
  AObject: TPressNotificationItem): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressNotificationList.Insert(Index: Integer;
  AObject: TPressNotificationItem);
begin
  inherited Insert(Index, AObject);
end;

function TPressNotificationList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressNotificationList.Remove(
  AObject: TPressNotificationItem): Integer;
begin
  Result := inherited Remove(AObject);
end;

function TPressNotificationList.RemoveNotification(
  ANotifier: TPressNotifier; AObservedObject: TObject): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Pred(Count) do
    with Items[I] do
      if not Assigned(AObservedObject) or (ObservedObject = AObservedObject) then
        if Notifiers.UnassignNotifiers(ANotifier) then
          Result := True;
end;

{ TPressNotificationIterator }

function TPressNotificationIterator.GetCurrentItem: TPressNotificationItem;
begin
  Result := inherited CurrentItem as TPressNotificationItem;
end;

{ TPressEventClassItem }

constructor TPressEventClassItem.Create(AEventClass: TPressEventClass);
begin
  inherited Create;
  FEventClass := AEventClass;
end;

destructor TPressEventClassItem.Destroy;
begin
  FNotifications.Free;
  inherited;
end;

function TPressEventClassItem.GetNotifications: TPressNotificationList;
begin
  if not Assigned(FNotifications) then
    FNotifications := TPressNotificationList.Create(True);
  Result := FNotifications;
end;

{ TPressEventClassList }

function TPressEventClassList.Add(AObject: TPressEventClassItem): Integer;
begin
  Result := inherited Add(AObject);
end;

procedure TPressEventClassList.AddNotification(ANotifier: TPressNotifier;
  AObservedObject: TObject; AEventClass: TPressEventClass);
begin
  EventClassItem[AEventClass].
   Notifications.AddNotification(ANotifier, AObservedObject);
end;

function TPressEventClassList.CreateIterator: TPressEventClassIterator;
begin
  Result := TPressEventClassIterator.Create(Self);
end;

function TPressEventClassList.GetClassItem(
  AEventClass: TPressEventClass): TPressEventClassItem;
var
  I: Integer;
begin
  for I := 0 to Pred(Count) do
  begin
    Result := Items[I];
    if Result.EventClass = AEventClass then
      Exit;
  end;
  Result := TPressEventClassItem.Create(AEventClass);
  Add(Result);
end;

function TPressEventClassList.GetItems(AIndex: Integer): TPressEventClassItem;
begin
  Result := inherited Items[AIndex] as TPressEventClassItem;
end;

function TPressEventClassList.IndexOf(AObject: TPressEventClassItem): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressEventClassList.Insert(
  Index: Integer; AObject: TPressEventClassItem);
begin
  inherited Insert(Index, AObject);
end;

function TPressEventClassList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressEventClassList.Remove(AObject: TPressEventClassItem): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressEventClassList.RemoveNotification(ANotifier: TPressNotifier;
  AObservedObject: TObject);
var
  I: Integer;
begin
  for I := 0 to Pred(Count) do
    if Items[I].Notifications.RemoveNotification(ANotifier, AObservedObject) then
      FHasRemovedNotifiers := True;
end;

{ TPressEventClassIterator }

function TPressEventClassIterator.GetCurrentItem: TPressEventClassItem;
begin
  Result := inherited CurrentItem as TPressEventClassItem;
end;

{ TPressNotifiers }

destructor TPressNotifiers.Destroy;
begin
  FEventClasses.Free;
  inherited;
end;

function TPressNotifiers.GetEventClasses: TPressEventClassList;
begin
  if not Assigned(FEventClasses) then
    FEventClasses := TPressEventClassList.Create(True);
  Result := FEventClasses;
end;

procedure TPressNotifiers.LockShrinkList;
begin
  Inc(FLockShrinkListCount);
end;

procedure TPressNotifiers.NotifyEvent(AEvent: TPressEvent);
var
  I, J, K: Integer;
  VEventClasses: TPressEventClassList;
  VEventClass: TPressEventClassItem;
  VNotifications: TPressNotificationList;
  VNotification: TPressNotificationItem;
  VNotifiers: TPressNotifierList;
  VNotifier: TPressNotifier;
begin
  LockShrinkList;
  try
    VEventClasses := EventClasses;
    for I := 0 to Pred(VEventClasses.Count) do
    begin
      VEventClass := VEventClasses[I];
      if AEvent is VEventClass.EventClass then
      begin
        VNotifications := VEventClass.Notifications;
        for J := 0 to Pred(VNotifications.Count) do
        begin
          VNotification := VNotifications[J];
          if not Assigned(VNotification.ObservedObject) or
           (VNotification.ObservedObject = AEvent.Owner) then
          begin
            VNotifiers := VNotification.Notifiers;
            for K := 0 to Pred(VNotifiers.Count) do
            begin
              VNotifier := VNotifiers[K];
              if Assigned(VNotifier) then
                VNotifier.ProcessEvent(AEvent);
            end;
          end;
        end;
      end;
    end;
  finally
    UnlockShrinkList;
  end;
end;

procedure TPressNotifiers.ShrinkEventClasses;
var
  VEventClasses: TPressEventClassList;
  VNotifications: TPressNotificationList;
  VNotifiers: TPressNotifierList;
  I, J: Integer;
begin
  VEventClasses := EventClasses;
  if VEventClasses.HasRemovedNotifiers then
  begin
    for I := Pred(VEventClasses.Count) downto 0 do
    begin
      VNotifications := VEventClasses[I].Notifications;
      for J := Pred(VNotifications.Count) downto 0 do
      begin
        VNotifiers := VNotifications[J].Notifiers;
        VNotifiers.Pack;
        if VNotifiers.Count = 0 then
          VNotifications.Delete(J);
      end;
      if VNotifications.Count = 0 then
        VEventClasses.Delete(I);
    end;
    VEventClasses.FHasRemovedNotifiers := False;  // friend class
  end;
end;

procedure TPressNotifiers.Subscribe(
  ANotifier: TPressNotifier; AObservedObject: TObject;
  AEventClass: TPressEventClass);
begin
  EventClasses.AddNotification(ANotifier, AObservedObject, AEventClass);
end;

procedure TPressNotifiers.UnlockShrinkList;
begin
  Dec(FLockShrinkListCount);
  if FLockShrinkListCount = 0 then
    ShrinkEventClasses;
end;

procedure TPressNotifiers.Unsubscribe(
  ANotifier: TPressNotifier; AObservedObject: TObject);
begin
  EventClasses.RemoveNotification(ANotifier, AObservedObject);
end;

end.
