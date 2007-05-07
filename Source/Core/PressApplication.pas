(*
  PressObjects, Application Context Classes
  Copyright (C) 2006-2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressApplication;

{$DEFINE PressBaseUnit}
{$I Press.inc}

interface

uses
  Forms,
  PressCompatibility,
  PressClasses,
  PressNotifier;

const
  CPressDataAccessServicesBase  = $0100;
  CPressUserServicesBase        = $0200;
  CPressReportServicesBase      = $0300;
  CPressMVPServicesBase         = $0400;

  CPressUserDefinedServicesBase = $8000;

type
  TPressApplicationEvent = class(TPressEvent)
  end;

  TPressApplicationInitEvent = class(TPressApplicationEvent)
  end;

  TPressApplicationRunningEvent = class(TPressApplicationEvent)
  end;

  TPressApplicationDoneEvent = class(TPressApplicationEvent)
  end;

  TPressServiceType = type Word;

  TPressRegistry = class;

  TPressServiceClass = class of TPressService;

  TPressService = class(TObject, IInterface)
  private
    FRegistry: TPressRegistry;
    function GetIsDefault: Boolean;
    procedure SetIsDefault(Value: Boolean);
  protected
    procedure DoneService; virtual;
    procedure InitService; virtual;
    procedure InternalIsDefaultChanged; virtual;
    class function InternalServiceType: TPressServiceType; virtual; abstract;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    class procedure RegisterService(AIsDefault: Boolean = False);
    property IsDefault: Boolean read GetIsDefault write SetIsDefault;
    property Registry: TPressRegistry read FRegistry;
  end;

  TPressServiceClassIterator = class;

  TPressServiceClassList = class(TPressClassList)
  private
    function GetItems(AIndex: Integer): TPressServiceClass;
    procedure SetItems(AIndex: Integer; Value: TPressServiceClass);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AClass: TPressServiceClass): Integer;
    function CreateIterator: TPressServiceClassIterator;
    function Extract(AClass: TPressServiceClass): TPressServiceClass;
    function First: TPressServiceClass;
    function IndexOf(AClass: TPressServiceClass): Integer;
    procedure Insert(AIndex: Integer; AClass: TPressServiceClass);
    function Last: TPressServiceClass;
    function Remove(AClass: TPressServiceClass): Integer;
    property Items[AIndex: Integer]: TPressServiceClass read GetItems write SetItems; default;
  end;

  TPressServiceClassIterator = class(TPressClassIterator)
  private
    function GetCurrentItem: TPressServiceClass;
  public
    property CurrentItem: TPressServiceClass read GetCurrentItem;
  end;

  TPressServiceIterator = class;

  TPressServiceList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressService;
    procedure SetItems(AIndex: Integer; Value: TPressService);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressService): Integer;
    function CreateIterator: TPressServiceIterator;
    function Extract(AObject: TPressService): TPressService;
    function First: TPressService;
    function IndexOf(AObject: TPressService): Integer;
    procedure Insert(AIndex: Integer; AObject: TPressService);
    function Last: TPressService;
    function Remove(AObject: TPressService): Integer;
    property Items[AIndex: Integer]: TPressService read GetItems write SetItems; default;
  end;

  TPressServiceIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressService;
  public
    property CurrentItem: TPressService read GetCurrentItem;
  end;

  TPressRegistryClass = class of TPressRegistry;

  TPressRegistry = class(TObject)
  private
    FDefaultService: TPressService;
    FDefaultServiceClass: TPressServiceClass;
    FServiceClasses: TPressServiceClassList;
    FServices: TPressServiceList;
    FServiceType: TPressServiceType;
    function GetDefaultService: TPressService;
    function GetDefaultServiceClass: TPressServiceClass;
    function GetServiceTypeName: string;
    procedure SetDefaultService(Value: TPressService);
    procedure SetDefaultServiceClass(Value: TPressServiceClass);
  protected
    property ServiceClasses: TPressServiceClassList read FServiceClasses;
    property Services: TPressServiceList read FServices;
  public
    constructor Create(AServiceType: TPressServiceType);
    destructor Destroy; override;
    function CreateService(ADefaultServiceClass: TPressServiceClass): TPressService;
    procedure DoneServices;
    procedure ExtractService(AService: TPressService);
    function HasDefaultService: Boolean;
    function HasDefaultServiceClass: Boolean;
    procedure InsertService(AService: TPressService);
    procedure RegisterService(AServiceClass: TPressServiceClass; AIsDefault: Boolean);
    property DefaultService: TPressService read GetDefaultService write SetDefaultService;
    property DefaultServiceClass: TPressServiceClass read GetDefaultServiceClass write SetDefaultServiceClass;
    property ServiceType: TPressServiceType read FServiceType;
    property ServiceTypeName: string read GetServiceTypeName;
  end;

  TPressRegistryIterator = class;

  TPressRegistryList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressRegistry;
    function GetRegistries(AServiceType: TPressServiceType): TPressRegistry;
    procedure SetItems(AIndex: Integer; Value: TPressRegistry);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressRegistry): Integer;
    function CreateIterator: TPressRegistryIterator;
    function Extract(AObject: TPressRegistry): TPressRegistry;
    function First: TPressRegistry;
    function IndexOf(AObject: TPressRegistry): Integer;
    function IndexOfServiceType(AServiceType: TPressServiceType): Integer;
    procedure Insert(Index: Integer; AObject: TPressRegistry);
    function Last: TPressRegistry;
    function Remove(AObject: TPressRegistry): Integer;
    property Items[AIndex: Integer]: TPressRegistry read GetItems write SetItems; default;
    property Registries[AServiceType: TPressServiceType]: TPressRegistry read GetRegistries;
  end;

  TPressRegistryIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressRegistry;
  public
    property CurrentItem: TPressRegistry read GetCurrentItem;
  end;

  TPressApplication = class(TObject)
  private
    FNotifier: TPressNotifier;
    FOnIdle: TIdleEvent;
    FRegistries: TPressRegistryList;
    FRunning: Boolean;
    procedure ApplicationIdle(Sender: TObject; var Done: Boolean);
    procedure DoneApplication;
    function GetRegistry(AServiceType: TPressServiceType): TPressRegistry;
    procedure InitApplication;
    procedure Notify(AEvent: TPressEvent);
  protected
    property Registries: TPressRegistryList read FRegistries;
  public
    constructor Create;
    destructor Destroy; override;
    function CreateDefaultService(AServiceType: TPressServiceType): TPressService;
    function CreateService(ADefaultServiceClass: TPressServiceClass): TPressService;
    function DefaultService(AServiceType: TPressServiceType): TPressService; overload;
    function DefaultService(ADefaultServiceClass: TPressServiceClass): TPressService; overload;
    function DefaultServiceClass(AServiceType: TPressServiceType): TPressServiceClass;
    procedure RegisterService(AServiceType: TPressServiceType; AServiceClass: TPressServiceClass; AIsDefault: Boolean);
    procedure Run;
    procedure Finalize;
    property Registry[AServiceType: TPressServiceType]: TPressRegistry read GetRegistry;
    property Running: Boolean read FRunning;
  end;

function PressApp: TPressApplication;

implementation

uses
  SysUtils,
  {$IFDEF PressLog}PressLog,{$ENDIF}
  PressConsts;

var
  _PressApp: TPressApplication;

function PressApp: TPressApplication;
begin
  Result := _PressApp;
end;

{ TPressService }

constructor TPressService.Create;
begin
  inherited Create;
  FRegistry := PressApp.Registry[InternalServiceType];
  Registry.InsertService(Self);
  InitService;
end;

destructor TPressService.Destroy;
begin
  IsDefault := False;
  Registry.ExtractService(Self);
  inherited;
end;

procedure TPressService.DoneService;
begin
end;

function TPressService.GetIsDefault: Boolean;
begin
  Result := Registry.FDefaultService = Self;  // friend class
end;

procedure TPressService.InitService;
begin
end;

procedure TPressService.InternalIsDefaultChanged;
begin
end;

function TPressService.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then Result := 0 else Result := HResult($80004002);
end;

class procedure TPressService.RegisterService(AIsDefault: Boolean);
begin
  PressApp.RegisterService(InternalServiceType, Self, AIsDefault);
end;

procedure TPressService.SetIsDefault(Value: Boolean);
begin
  if IsDefault xor Value then
    if Value then
      Registry.DefaultService := Self
    else
      Registry.DefaultService := nil;
end;

function TPressService._AddRef: Integer;
begin
  Result := 1;
end;

function TPressService._Release: Integer;
begin
  Result := 1;
end;

{ TPressServiceClassList }

function TPressServiceClassList.Add(AClass: TPressServiceClass): Integer;
begin
  Result := inherited Add(AClass);
end;

function TPressServiceClassList.CreateIterator: TPressServiceClassIterator;
begin
  Result := TPressServiceClassIterator.Create(Self);
end;

function TPressServiceClassList.Extract(
  AClass: TPressServiceClass): TPressServiceClass;
begin
  Result := TPressServiceClass(inherited Extract(AClass));
end;

function TPressServiceClassList.First: TPressServiceClass;
begin
  Result := TPressServiceClass(inherited First);
end;

function TPressServiceClassList.GetItems(AIndex: Integer): TPressServiceClass;
begin
  Result := TPressServiceClass(inherited Items[AIndex]);
end;

function TPressServiceClassList.IndexOf(AClass: TPressServiceClass): Integer;
begin
  Result := inherited IndexOf(AClass);
end;

procedure TPressServiceClassList.Insert(
  AIndex: Integer; AClass: TPressServiceClass);
begin
  inherited Insert(AIndex, AClass);
end;

function TPressServiceClassList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressServiceClassList.Last: TPressServiceClass;
begin
  Result := TPressServiceClass(inherited Last);
end;

function TPressServiceClassList.Remove(AClass: TPressServiceClass): Integer;
begin
  Result := inherited Remove(AClass);
end;

procedure TPressServiceClassList.SetItems(
  AIndex: Integer; Value: TPressServiceClass);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressServiceClassIterator }

function TPressServiceClassIterator.GetCurrentItem: TPressServiceClass;
begin
  Result := TPressServiceClass(inherited CurrentItem);
end;

{ TPressServiceList }

function TPressServiceList.Add(AObject: TPressService): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressServiceList.CreateIterator: TPressServiceIterator;
begin
  Result := TPressServiceIterator.Create(Self);
end;

function TPressServiceList.Extract(AObject: TPressService): TPressService;
begin
  Result := inherited Extract(AObject) as TPressService;
end;

function TPressServiceList.First: TPressService;
begin
  Result := inherited First as TPressService;
end;

function TPressServiceList.GetItems(AIndex: Integer): TPressService;
begin
  Result := inherited Items[AIndex] as TPressService;
end;

function TPressServiceList.IndexOf(AObject: TPressService): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressServiceList.Insert(AIndex: Integer; AObject: TPressService);
begin
  inherited Insert(AIndex, AObject);
end;

function TPressServiceList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressServiceList.Last: TPressService;
begin
  Result := inherited Last as TPressService;
end;

function TPressServiceList.Remove(AObject: TPressService): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressServiceList.SetItems(AIndex: Integer; Value: TPressService);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressServiceIterator }

function TPressServiceIterator.GetCurrentItem: TPressService;
begin
  Result := inherited CurrentItem as TPressService;
end;

{ TPressRegistry }

constructor TPressRegistry.Create(AServiceType: TPressServiceType);
begin
  inherited Create;
  FServiceType := AServiceType;
  FServiceClasses := TPressServiceClassList.Create;
  FServices := TPressServiceList.Create(True);
end;

function TPressRegistry.CreateService(
  ADefaultServiceClass: TPressServiceClass): TPressService;
begin
  if HasDefaultServiceClass then
    Result := DefaultServiceClass.Create
  else
    Result := ADefaultServiceClass.Create;
end;

destructor TPressRegistry.Destroy;
begin
  FServiceClasses.Free;
  FServices.Free;
  inherited;
end;

procedure TPressRegistry.DoneServices;
begin
  with Services.CreateIterator do
  try
    BeforeFirstItem;
    while NextItem do
      CurrentItem.DoneService;
  finally
    Free;
  end;
end;

procedure TPressRegistry.ExtractService(AService: TPressService);
begin
  Services.Extract(AService);
end;

function TPressRegistry.GetDefaultService: TPressService;
begin
  if not Assigned(FDefaultService) then
    if Services.Count > 0 then
      FDefaultService := Services.Last
    else
      FDefaultService := DefaultServiceClass.Create;
  Result := FDefaultService;
end;

function TPressRegistry.GetDefaultServiceClass: TPressServiceClass;
begin
  if not Assigned(FDefaultServiceClass) then
    if ServiceClasses.Count > 0 then
      FDefaultServiceClass := ServiceClasses.Last
    else
      raise EPressError.CreateFmt(SUnassignedServiceType, [ServiceTypeName]);
  Result := FDefaultServiceClass;
end;

function TPressRegistry.GetServiceTypeName: string;
begin
  { TODO : Implement }
  Result := Format('#%.4x', [FServiceType]);
end;

function TPressRegistry.HasDefaultService: Boolean;
begin
  Result := Assigned(FDefaultService) or (Services.Count > 0) or
   Assigned(FDefaultServiceClass) or (ServiceClasses.Count > 0);
end;

function TPressRegistry.HasDefaultServiceClass: Boolean;
begin
  Result := Assigned(FDefaultServiceClass) or (ServiceClasses.Count > 0);
end;

procedure TPressRegistry.InsertService(AService: TPressService);
begin
  Services.Add(AService);
  if not Assigned(FDefaultService) then
    DefaultService := AService;
end;

procedure TPressRegistry.RegisterService(
  AServiceClass: TPressServiceClass; AIsDefault: Boolean);
begin
  ServiceClasses.Add(AServiceClass);
  if AIsDefault or not Assigned(FDefaultServiceClass) then
    FDefaultServiceClass := AServiceClass;
end;

procedure TPressRegistry.SetDefaultService(Value: TPressService);
var
  VOldDefaultService: TPressService;
begin
  if FDefaultService <> Value then
  begin
    VOldDefaultService := FDefaultService;
    FDefaultService := Value;
    if Assigned(VOldDefaultService) then
      VOldDefaultService.InternalIsDefaultChanged;  // friend class
    if Assigned(FDefaultService) then
      FDefaultService.InternalIsDefaultChanged;  // friend class
  end;
end;

procedure TPressRegistry.SetDefaultServiceClass(Value: TPressServiceClass);
begin
  FDefaultServiceClass := Value;
end;

{ TPressRegistryList }

function TPressRegistryList.Add(AObject: TPressRegistry): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressRegistryList.CreateIterator: TPressRegistryIterator;
begin
  Result := TPressRegistryIterator.Create(Self);
end;

function TPressRegistryList.Extract(AObject: TPressRegistry): TPressRegistry;
begin
  Result := inherited Extract(AObject) as TPressRegistry;
end;

function TPressRegistryList.First: TPressRegistry;
begin
  Result := inherited First as TPressRegistry;
end;

function TPressRegistryList.GetItems(AIndex: Integer): TPressRegistry;
begin
  Result := inherited Items[AIndex] as TPressRegistry;
end;

function TPressRegistryList.GetRegistries(
  AServiceType: TPressServiceType): TPressRegistry;
var
  VIndex: Integer;
begin
  VIndex := IndexOfServiceType(AServiceType);
  if VIndex = -1 then
    VIndex := Add(TPressRegistry.Create(AServiceType));
  Result := Items[VIndex];
end;

function TPressRegistryList.IndexOf(AObject: TPressRegistry): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

function TPressRegistryList.IndexOfServiceType(
  AServiceType: TPressServiceType): Integer;
begin
  for Result := 0 to Pred(Count) do
    if Items[Result].ServiceType = AServiceType then
      Exit;
  Result := -1;
end;

procedure TPressRegistryList.Insert(Index: Integer; AObject: TPressRegistry);
begin
  inherited Insert(Index, AObject);
end;

function TPressRegistryList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressRegistryList.Last: TPressRegistry;
begin
  Result := inherited Last as TPressRegistry;
end;

function TPressRegistryList.Remove(AObject: TPressRegistry): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressRegistryList.SetItems(AIndex: Integer; Value: TPressRegistry);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressRegistryIterator }

function TPressRegistryIterator.GetCurrentItem: TPressRegistry;
begin
  Result := inherited CurrentItem as TPressRegistry;
end;

{ TPressApplication }

procedure TPressApplication.ApplicationIdle(Sender: TObject; var Done: Boolean);
begin
  {$IFDEF PressLogIdle}PressLogMsg(Self, 'Idle', [Sender]);{$ENDIF}
  PressProcessEventQueue;
  if Assigned(FOnIdle) then
    FOnIdle(Sender, Done);
end;

constructor TPressApplication.Create;
begin
  inherited Create;
  FNotifier := TPressNotifier.Create(Notify);
  FNotifier.AddNotificationItem(Self, [TPressApplicationRunningEvent]);
  FRegistries := TPressRegistryList.Create(True);
end;

function TPressApplication.CreateDefaultService(
  AServiceType: TPressServiceType): TPressService;
begin
  Result := DefaultServiceClass(AServiceType).Create;
end;

function TPressApplication.CreateService(
  ADefaultServiceClass: TPressServiceClass): TPressService;
begin
  Result := Registry[ADefaultServiceClass.InternalServiceType].
   CreateService(ADefaultServiceClass);
end;

function TPressApplication.DefaultService(
  AServiceType: TPressServiceType): TPressService;
begin
  Result := Registry[AServiceType].DefaultService;
end;

function TPressApplication.DefaultService(
  ADefaultServiceClass: TPressServiceClass): TPressService;
begin
  with Registry[ADefaultServiceClass.InternalServiceType] do
  begin
    if not HasDefaultService then
      RegisterService(ADefaultServiceClass, True);
    Result := DefaultService;
  end;
end;

function TPressApplication.DefaultServiceClass(
  AServiceType: TPressServiceType): TPressServiceClass;
begin
  Result := Registry[AServiceType].DefaultServiceClass;
end;

destructor TPressApplication.Destroy;
begin
  FRegistries.Free;
  FNotifier.Free;
  inherited;
end;

procedure TPressApplication.DoneApplication;

  procedure DoneAllServices;
  var
    I: Integer;
  begin
    for I := 0 to Pred(Registries.Count) do
      Registries[I].DoneServices;
  end;

begin
  FRunning := False;
  TPressApplicationDoneEvent.Create(Self).Notify;
  DoneAllServices;
  Application.OnIdle := FOnIdle;
end;

procedure TPressApplication.Finalize;
begin
  Application.MainForm.Close;
end;

function TPressApplication.GetRegistry(
  AServiceType: TPressServiceType): TPressRegistry;
begin
  Result := Registries.Registries[AServiceType];
end;

procedure TPressApplication.InitApplication;
begin
  FOnIdle := Application.OnIdle;
  Application.OnIdle := ApplicationIdle;
  TPressApplicationInitEvent.Create(Self).Notify;
  TPressApplicationRunningEvent.Create(Self).QueueNotification;
end;

procedure TPressApplication.Notify(AEvent: TPressEvent);
begin
  FRunning := True;
end;

procedure TPressApplication.RegisterService(AServiceType: TPressServiceType;
  AServiceClass: TPressServiceClass; AIsDefault: Boolean);
begin
  Registry[AServiceType].RegisterService(AServiceClass, AIsDefault);
end;

procedure TPressApplication.Run;
begin
  InitApplication;
  try
    Application.Run;
  finally
    DoneApplication;
  end;
end;

initialization
  _PressApp := TPressApplication.Create;

finalization
  _PressApp.Free;

end.
