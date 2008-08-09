(*
  PressObjects, MVP-Presenter Classes
  Copyright (C) 2006-2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressMVPPresenter;

{$I Press.inc}

interface

uses
  PressClasses,
  PressNotifier,
  PressSubject,
  PressUser,
  PressMVP,
  PressMVPModel,
  PressMVPView;

type
  TPressMVPPresenter = class;

  TPressMVPInteractorClass = class of TPressMVPInteractor;
  TPressMVPInteractorClasses = array of TPressMVPInteractorClass;

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

  TPressMVPFreePresenterEvent = class(TPressEvent)
  end;

  TPressMVPFormPresenter = class;
  TPressMVPFormPresenterClass = class of TPressMVPFormPresenter;

  TPressMVPPresenterClass = class of TPressMVPPresenter;

  TPressMVPPresenter = class(TPressMVPObject)
  private
    FCommandMenu: TPressMVPCommandMenu;
    FInteractors: TPressMVPInteractorList;
    FIsInitializing: Boolean;
    FModel: TPressMVPModel;
    FParent: TPressMVPFormPresenter;
    FParentView: IPressMVPFormView;
    FView: IPressMVPView;
    procedure AfterChangeCommandMenu;
    procedure AfterChangeModel;
    procedure AfterChangeView;
    procedure BeforeChangeCommandMenu;
    procedure BeforeChangeModel;
    procedure BeforeChangeView;
    procedure DoInitInteractors;
    procedure DoInitPresenter;
    function GetInteractors: TPressMVPInteractorList;
    procedure SetCommandMenu(Value: TPressMVPCommandMenu);
    procedure SetModel(Value: TPressMVPModel);
    procedure SetView(const Value: IPressMVPView);
    procedure UpdateCommandMenu;
  protected
    procedure AfterInitInteractors; virtual;
    procedure Finit; override;
    procedure InitPresenter; virtual;
    function InternalCreateCommandMenu: TPressMVPCommandMenu; virtual;
    property CommandMenu: TPressMVPCommandMenu read FCommandMenu write SetCommandMenu;
    property Interactors: TPressMVPInteractorList read GetInteractors;
  public
    constructor Create(AParent: TPressMVPFormPresenter; AModel: TPressMVPModel; const AView: IPressMVPView); virtual;
    class function Apply(AModel: TPressMVPModel; const AView: IPressMVPView): Boolean; virtual; abstract;
    function BindCommand(ACommandClass: TPressMVPCommandClass; const AComponentName: ShortString): TPressMVPCommand; virtual;
    function BindPresenter(APresenterClass: TPressMVPFormPresenterClass; const AComponentName: ShortString): TPressMVPCommand; virtual;
    class procedure RegisterPresenter;
    property Model: TPressMVPModel read FModel;
    property Parent: TPressMVPFormPresenter read FParent;
    property View: IPressMVPView read FView;
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

  TPressMVPNullPresenter = class(TPressMVPPresenter)
  public
    class function Apply(AModel: TPressMVPModel; const AView: IPressMVPView): Boolean; override;
  end;

  TPressMVPRunPresenterCommand = class(TPressMVPCommand)
  private
    FPresenterClass: TPressMVPFormPresenterClass;
  protected
    procedure InternalExecute; override;
    function InternalIsEnabled: Boolean; override;
  public
    constructor Create(AModel: TPressMVPModel; APresenterClass: TPressMVPFormPresenterClass); reintroduce;
  end;

  TPressMVPValuePresenter = class(TPressMVPPresenter)
  private
    function GetModel: TPressMVPValueModel;
  protected
    procedure InitPresenter; override;
  public
    class function Apply(AModel: TPressMVPModel; const AView: IPressMVPView): Boolean; override;
    property Model: TPressMVPValueModel read GetModel;
  end;

  TPressMVPPointerPresenter = class(TPressMVPPresenter)
  private
    FItemView: IPressMVPItemView;
  protected
    procedure InitPresenter; override;
    function InternalCreateIterator(const ASearchString: string): TPressIterator; virtual; abstract;
    function InternalCurrentItem(AIterator: TPressIterator): string; virtual; abstract;
  public
    function UpdateReferences(const ASearchString: string): Integer;
  end;

  TPressMVPEnumPresenter = class(TPressMVPPointerPresenter)
  private
    function GetModel: TPressMVPEnumModel;
  protected
    function InternalCreateIterator(const ASearchString: string): TPressIterator; override;
    function InternalCurrentItem(AIterator: TPressIterator): string; override;
  public
    class function Apply(AModel: TPressMVPModel; const AView: IPressMVPView): Boolean; override;
    property Model: TPressMVPEnumModel read GetModel;
  end;

  TPressMVPReferencePresenter = class(TPressMVPPointerPresenter)
  private
    function GetModel: TPressMVPReferenceModel;
  protected
    function InternalCreateIterator(const ASearchString: string): TPressIterator; override;
    function InternalCurrentItem(AIterator: TPressIterator): string; override;
  public
    class function Apply(AModel: TPressMVPModel; const AView: IPressMVPView): Boolean; override;
    property Model: TPressMVPReferenceModel read GetModel;
  end;

  TPressMVPItemsPresenter = class(TPressMVPPresenter)
  private
    function GetModel: TPressMVPItemsModel;
  public
    class function Apply(AModel: TPressMVPModel; const AView: IPressMVPView): Boolean; override;
    property Model: TPressMVPItemsModel read GetModel;
  end;

  TPressMVPFormPresenterType = (fpNew, fpExisting, fpQuery);
  TPressMVPFormPresenterTypes = set of TPressMVPFormPresenterType;

  TPressMVPFormPresenter = class(TPressMVPPresenter)
  private
    FAutoDestroy: Boolean;
    FSubPresenters: TPressMVPPresenterList;
    FFormView: IPressMVPFormView;
    function GetModel: TPressMVPObjectModel;
    function GetSubPresenters: TPressMVPPresenterList;
  protected
    class procedure AssignAccessor(AFormHandle: TObject; const AAccessorName: ShortString; AInstance: Pointer);
    function AttributeByName(const AAttributeName: ShortString): TPressAttribute;
    function CreateSubPresenter(const AAttributeName, AControlName: ShortString; const ADisplayNames: string = ''; AModelClass: TPressMVPModelClass = nil; APresenterClass: TPressMVPPresenterClass = nil): TPressMVPPresenter;
    procedure Finit; override;
    procedure InitPresenter; override;
    function InternalCreateSubModel(ASubject: TPressSubject): TPressMVPModel; virtual;
    function InternalCreateSubPresenter(AModel: TPressMVPModel; const AView: IPressMVPView): TPressMVPPresenter; virtual;
    class function InternalModelClass: TPressMVPObjectModelClass; virtual;
    procedure Running; virtual;
    property SubPresenters: TPressMVPPresenterList read GetSubPresenters;
  public
    class function Apply(AModel: TPressMVPModel; const AView: IPressMVPView): Boolean; override;
    function BindCommand(ACommandClass: TPressMVPCommandClass; const AComponentName: ShortString): TPressMVPCommand; override;
    function BindPresenter(APresenterClass: TPressMVPFormPresenterClass; const AComponentName: ShortString): TPressMVPCommand; override;
    function CreatePresenterIterator: TPressMVPPresenterIterator;
    procedure Refresh;
    class procedure RegisterBO(AObjectClass: TPressObjectClass; AFormPresenterTypes: TPressMVPFormPresenterTypes = [fpNew, fpExisting]; AModelClass: TPressMVPObjectModelClass = nil);
    class function Run(AObject: TPressObject = nil; AIncluding: Boolean = False; AAutoDestroy: Boolean = True): TPressMVPFormPresenter; overload;
    class function Run(AParent: TPressMVPFormPresenter; AObject: TPressObject = nil; AIncluding: Boolean = False; AAutoDestroy: Boolean = True): TPressMVPFormPresenter; overload;
    property AutoDestroy: Boolean read FAutoDestroy;
    property Model: TPressMVPObjectModel read GetModel;
  end;

  TPressMVPQueryPresenter = class(TPressMVPFormPresenter)
  private
    function GetModel: TPressMVPQueryModel;
  protected
    function CreateQueryItemsPresenter(const AControlName: ShortString; ADisplayNames: string = ''; AModelClass: TPressMVPModelClass = nil; APresenterClass: TPressMVPPresenterClass = nil): TPressMVPPresenter;
    function InternalQueryItemsDisplayNames: string; virtual;
    function InternalQueryItemsModelClass: TPressMVPModelClass; virtual;
    function InternalQueryItemsPresenterClass: TPressMVPPresenterClass; virtual;
  public
    class function Apply(AModel: TPressMVPModel; const AView: IPressMVPView): Boolean; override;
    property Model: TPressMVPQueryModel read GetModel;
  end;

  TPressMVPMainFormPresenter = class(TPressMVPQueryPresenter)
  private
    FNotifier: TPressNotifier;
    procedure Notify(AEvent: TPressEvent);
  protected
    procedure Finit; override;
  public
    constructor Create; reintroduce; virtual;
    class function Apply(AModel: TPressMVPModel; const AView: IPressMVPView): Boolean; override;
    class procedure Initialize;
    class procedure Run;
  end;

implementation

uses
  SysUtils,
  PressApplication,
  {$IFDEF PressLog}PressLog,{$ENDIF}
  PressConsts,
  PressUtils,
  PressMVPWidget,
  PressMVPFactory,
  PressMVPCommand,
  PressMVPInteractor;  // initializing default interactors

type
  TPressMVPPresenterModelFriend = class(TPressMVPModel);

var
  _PressMVPMainPresenter: TPressMVPMainFormPresenter;

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
    FNotifier := TPressNotifier.Create({$IFDEF FPC}@{$ENDIF}Notify);
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
  PressDefaultMVPFactory.RegisterInteractor(Self);
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

{ TPressMVPPresenter }

procedure TPressMVPPresenter.AfterChangeCommandMenu;
begin
  if Assigned(FCommandMenu) then
  begin
    if Assigned(FView) then
      FCommandMenu.AssignMenu(FView.Handle);
    if not FIsInitializing then
      UpdateCommandMenu;
  end;
end;

procedure TPressMVPPresenter.AfterChangeModel;
begin
  if Assigned(FModel) then
  begin
    if Assigned(FView) then
    begin
      FView.SetModel(FModel);
      FModel.Changed(ctDisplay);
    end;
    if not FIsInitializing then
      UpdateCommandMenu;
  end;
end;

procedure TPressMVPPresenter.AfterChangeView;
begin
  if Assigned(FView) then
  begin
    if Assigned(FCommandMenu) then
      FCommandMenu.AssignMenu(FView.Handle);
    if Assigned(FModel) then
    begin
      FView.SetModel(FModel);
      FModel.Changed(ctDisplay);
    end;
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
      FView.SetModel(nil);
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
      FView.SetModel(nil);
    FView := nil;
  end;
end;

function TPressMVPPresenter.BindCommand(ACommandClass: TPressMVPCommandClass;
  const AComponentName: ShortString): TPressMVPCommand;
var
  VComponent: TObject;
begin
  if not Assigned(FParentView) then
    raise EPressMVPError.CreateFmt(SUnassignedPresenterParent, [ClassName]);
  VComponent := FParentView.ComponentByName(AComponentName);
  if not Assigned(ACommandClass) then
    ACommandClass := TPressMVPNullCommand;
  Result := Model.RegisterCommand(ACommandClass);
  Result.AddComponent(VComponent);
end;

function TPressMVPPresenter.BindPresenter(
  APresenterClass: TPressMVPFormPresenterClass;
  const AComponentName: ShortString): TPressMVPCommand;
var
  VComponent: TObject;
begin
  if not Assigned(FParentView) then
    raise EPressMVPError.CreateFmt(SUnassignedPresenterParent, [ClassName]);
  VComponent := FParentView.ComponentByName(AComponentName);
  Result := TPressMVPRunPresenterCommand.Create(Model, APresenterClass);
  Model.AddCommandInstance(Result);
  Result.AddComponent(VComponent);
  Result.EnabledIfNoUser := True;
end;

constructor TPressMVPPresenter.Create(AParent: TPressMVPFormPresenter;
  AModel: TPressMVPModel; const AView: IPressMVPView);
begin
  CheckClass(Apply(AModel, AView));
  FIsInitializing := True;
  inherited Create;
  FParent := AParent;
  if Assigned(FParent) then
    FParent.SubPresenters.Add(Self);
  SetModel(AModel);
  SetView(AView);
  if Model.HasCommands then
    CommandMenu := InternalCreateCommandMenu;
  DoInitInteractors;
  DoInitPresenter;
  FIsInitializing := False;
end;

procedure TPressMVPPresenter.DoInitInteractors;
var
  VClasses: TPressMVPInteractorClasses;
  I: Integer;
begin
  VClasses := PressDefaultMVPFactory.MVPInteractorFactory(Self);
  for I := Low(VClasses) to High(VClasses) do
    Interactors.Add(VClasses[I].Create(Self));
  AfterInitInteractors;
end;

procedure TPressMVPPresenter.DoInitPresenter;
begin
  InitPresenter;
end;

procedure TPressMVPPresenter.Finit;
begin
  { TODO : Avoid events (specially View events) when destroying MVP objects
    Create CanNotify property or Destroying status }
  if Assigned(FParent) then
    FParent.SubPresenters.Extract(Self);
  BeforeChangeCommandMenu;
  BeforeChangeModel;
  BeforeChangeView;
  FCommandMenu.Free;
  FInteractors.Free;
  inherited;
end;

function TPressMVPPresenter.GetInteractors: TPressMVPInteractorList;
begin
  if not Assigned(FInteractors) then
    FInteractors := TPressMVPInteractorList.Create(True);
  Result := FInteractors;
end;

procedure TPressMVPPresenter.InitPresenter;
begin
  if Assigned(FParent) then
    PressAsIntf(FParent.View, IPressMVPFormView, FParentView);
end;

function TPressMVPPresenter.InternalCreateCommandMenu: TPressMVPCommandMenu;
begin
  Result := PressWidget.CreateCommandMenu;
end;

class procedure TPressMVPPresenter.RegisterPresenter;
begin
  PressDefaultMVPFactory.RegisterPresenter(Self);
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

procedure TPressMVPPresenter.SetView(const Value: IPressMVPView);
begin
  if FView <> Value then
  begin
    BeforeChangeView;
    FView := Value;
    AfterChangeView;
  end;
end;

procedure TPressMVPPresenter.UpdateCommandMenu;
begin
  if Assigned(FModel) and Assigned(FCommandMenu) then
    FCommandMenu.AssignCommands(TPressMVPPresenterModelFriend(FModel).Commands);
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

{ TPressMVPNullPresenter }

class function TPressMVPNullPresenter.Apply(AModel: TPressMVPModel;
  const AView: IPressMVPView): Boolean;
begin
  Result := AModel is TPressMVPNullModel;
end;

{ TPressMVPRunPresenterCommand }

constructor TPressMVPRunPresenterCommand.Create(AModel: TPressMVPModel;
  APresenterClass: TPressMVPFormPresenterClass);
begin
  inherited Create(AModel);
  FPresenterClass := APresenterClass;
end;

procedure TPressMVPRunPresenterCommand.InternalExecute;
begin
  inherited;
  if Assigned(FPresenterClass) then
    FPresenterClass.Run;
end;

function TPressMVPRunPresenterCommand.InternalIsEnabled: Boolean;
begin
  Result := Assigned(FPresenterClass);
end;

{ TPressMVPValuePresenter }

class function TPressMVPValuePresenter.Apply(AModel: TPressMVPModel;
  const AView: IPressMVPView): Boolean;
begin
  { TODO : Improve factory - asap! }
  Result := (AModel is TPressMVPValueModel) and
   PressSupports(AView,  IPressMVPAttributeView) and
   not PressSupports(AView, IPressMVPItemView);
end;

function TPressMVPValuePresenter.GetModel: TPressMVPValueModel;
begin
  Result := inherited Model as TPressMVPValueModel;
end;

procedure TPressMVPValuePresenter.InitPresenter;
var
  VView: IPressMVPAttributeView;
begin
  inherited;
  if Model.HasSubject and Supports(View, IPressMVPAttributeView, VView) then
    VView.Size := Model.Subject.Metadata.Size;
end;

{ TPressMVPPointerPresenter }

procedure TPressMVPPointerPresenter.InitPresenter;
begin
  inherited;
  PressAsIntf(View, IPressMVPItemView, FItemView);
end;

function TPressMVPPointerPresenter.UpdateReferences(
  const ASearchString: string): Integer;
var
  VIterator: TPressIterator;
begin
  FItemView.ClearReferences;
  VIterator := InternalCreateIterator(ASearchString);
  with VIterator do
  try
    Result := Count;
    BeforeFirstItem;
    while NextItem do
      FItemView.AddReference(InternalCurrentItem(VIterator));
  finally
    Free;
  end;
end;

{ TPressMVPEnumPresenter }

class function TPressMVPEnumPresenter.Apply(AModel: TPressMVPModel;
  const AView: IPressMVPView): Boolean;
begin
  Result := (AModel is TPressMVPEnumModel) and
   PressSupports(AView, IPressMVPItemView);
end;

function TPressMVPEnumPresenter.GetModel: TPressMVPEnumModel;
begin
  Result := inherited Model as TPressMVPEnumModel;
end;

function TPressMVPEnumPresenter.InternalCreateIterator(
  const ASearchString: string): TPressIterator;
begin
  Result := Model.CreateEnumValueIterator(ASearchString);
end;

function TPressMVPEnumPresenter.InternalCurrentItem(
  AIterator: TPressIterator): string;
begin
  Result := (AIterator as TPressMVPEnumValueIterator).CurrentItem.EnumName;
end;

{ TPressMVPReferencePresenter }

class function TPressMVPReferencePresenter.Apply(AModel: TPressMVPModel;
  const AView: IPressMVPView): Boolean;
begin
  Result := (AModel is TPressMVPReferenceModel) and
   PressSupports(AView, IPressMVPItemView);
end;

function TPressMVPReferencePresenter.GetModel: TPressMVPReferenceModel;
begin
  Result := inherited Model as TPressMVPReferenceModel;
end;

function TPressMVPReferencePresenter.InternalCreateIterator(
  const ASearchString: string): TPressIterator;
begin
  Result := Model.CreateQueryIterator(ASearchString);
end;

function TPressMVPReferencePresenter.InternalCurrentItem(
  AIterator: TPressIterator): string;
begin
  Result := Model.DisplayText(0, AIterator.CurrentPosition);
end;

{ TPressMVPItemsPresenter }

class function TPressMVPItemsPresenter.Apply(AModel: TPressMVPModel;
  const AView: IPressMVPView): Boolean;
begin
  Result := (AModel is TPressMVPItemsModel) and
   PressSupports(AView, IPressMVPItemsView);
end;

function TPressMVPItemsPresenter.GetModel: TPressMVPItemsModel;
begin
  Result := inherited Model as TPressMVPItemsModel;
end;

{ TPressMVPFormPresenter }

class function TPressMVPFormPresenter.Apply(
  AModel: TPressMVPModel; const AView: IPressMVPView): Boolean;
begin
  Result := (AModel is TPressMVPObjectModel) and
   not (AModel is TPressMVPQueryModel) and
   PressSupports(AView, IPressMVPFormView);
end;

class procedure TPressMVPFormPresenter.AssignAccessor(
  AFormHandle: TObject; const AAccessorName: ShortString; AInstance: Pointer);
var
  VAccessor: Pointer;
begin
  VAccessor := AFormHandle.FieldAddress(AAccessorName);
  if Assigned(VAccessor) then
    Pointer(VAccessor^) := AInstance;
end;

function TPressMVPFormPresenter.AttributeByName(
  const AAttributeName: ShortString): TPressAttribute;
begin
  if Model.Subject is TPressObject then
    Result := TPressObject(Model.Subject).FindPathAttribute(AAttributeName)
  else
    Result := nil;
  if not Assigned(Result) then
    raise EPressError.CreateFmt(SAttributeNotFound,
     [Model.Subject.ClassName, AAttributeName]);
end;

function TPressMVPFormPresenter.BindCommand(
  ACommandClass: TPressMVPCommandClass;
  const AComponentName: ShortString): TPressMVPCommand;
var
  VComponent: TObject;
begin
  VComponent := FFormView.ComponentByName(AComponentName);
  if not Assigned(ACommandClass) then
    ACommandClass := TPressMVPNullCommand;
  Result := Model.RegisterCommand(ACommandClass);
  Result.AddComponent(VComponent);
end;

function TPressMVPFormPresenter.BindPresenter(
  APresenterClass: TPressMVPFormPresenterClass;
  const AComponentName: ShortString): TPressMVPCommand;
var
  VComponent: TObject;
begin
  VComponent := FFormView.ComponentByName(AComponentName);
  Result := TPressMVPRunPresenterCommand.Create(Model, APresenterClass);
  Model.AddCommandInstance(Result);
  Result.AddComponent(VComponent);
  Result.EnabledIfNoUser := True;
end;

function TPressMVPFormPresenter.CreatePresenterIterator: TPressMVPPresenterIterator;
begin
  Result := SubPresenters.CreateIterator;
end;

function TPressMVPFormPresenter.CreateSubPresenter(
  const AAttributeName, AControlName: ShortString;
  const ADisplayNames: string;
  AModelClass: TPressMVPModelClass;
  APresenterClass: TPressMVPPresenterClass): TPressMVPPresenter;
var
  VAttribute: TPressAttribute;
  VComponent: TObject;
  VModel: TPressMVPModel;
  VView: IPressMVPView;
begin
  if AAttributeName <> '' then
    VAttribute := AttributeByName(AAttributeName)
  else
    VAttribute := nil;
  VComponent := FFormView.ComponentByName(AControlName);
  if Assigned(AModelClass) then
    VModel := AModelClass.Create(Model, VAttribute)
  else
    VModel := InternalCreateSubModel(VAttribute);
  if VModel is TPressMVPStructureModel then
    TPressMVPStructureModel(VModel).DisplayNames := ADisplayNames
  else if ADisplayNames <> '' then
  begin
    VAttribute := VModel.Subject as TPressAttribute;
    VModel.Free;
    raise EPressMVPError.CreateFmt(SUnsupportedDisplayNames,
     [VAttribute.ClassName, VAttribute.Owner.ClassName, VAttribute.Name]);
  end;
  VView := PressDefaultMVPFactory.MVPViewFactory(VComponent, False);
  if Assigned(APresenterClass) then
    Result := APresenterClass.Create(Self, VModel, VView)
  else
    Result := InternalCreateSubPresenter(VModel, VView);
  { TODO : Fix leakages when exception raises. }
  { Note - if FModel and FView fields of the presenter was assigned,
    the compiler will destroy these instances }
end;

procedure TPressMVPFormPresenter.Finit;
begin
  FSubPresenters.Free;
  inherited;
end;

function TPressMVPFormPresenter.GetModel: TPressMVPObjectModel;
begin
  Result := inherited Model as TPressMVPObjectModel;
end;

function TPressMVPFormPresenter.GetSubPresenters: TPressMVPPresenterList;
begin
  if not Assigned(FSubPresenters) then
    FSubPresenters := TPressMVPPresenterList.Create(True);
  Result := FSubPresenters;
end;

procedure TPressMVPFormPresenter.InitPresenter;
begin
  inherited;
  PressAsIntf(View, IPressMVPFormView, FFormView);
  FAutoDestroy := True;
end;

function TPressMVPFormPresenter.InternalCreateSubModel(
  ASubject: TPressSubject): TPressMVPModel;
begin
  Result := PressDefaultMVPFactory.MVPModelFactory(Model, ASubject);
end;

function TPressMVPFormPresenter.InternalCreateSubPresenter(
  AModel: TPressMVPModel; const AView: IPressMVPView): TPressMVPPresenter;
begin
  Result := PressDefaultMVPFactory.MVPPresenterFactory(Self, AModel, AView);
end;

class function TPressMVPFormPresenter.InternalModelClass: TPressMVPObjectModelClass;
begin
  Result := nil;
end;

procedure TPressMVPFormPresenter.Refresh;
var
  VPresenter: TPressMVPPresenter;
  I: Integer;
begin
  UpdateCommandMenu;
  for I := 0 to Pred(SubPresenters.Count) do
  begin
    VPresenter := SubPresenters[I];
    VPresenter.UpdateCommandMenu;
    VPresenter.View.Update;
  end;
end;

class procedure TPressMVPFormPresenter.RegisterBO(
  AObjectClass: TPressObjectClass;
  AFormPresenterTypes: TPressMVPFormPresenterTypes;
  AModelClass: TPressMVPObjectModelClass);
begin
  PressDefaultMVPFactory.RegisterBO(Self, AObjectClass, AFormPresenterTypes,
   AModelClass);
end;

class function TPressMVPFormPresenter.Run(
  AObject: TPressObject; AIncluding: Boolean;
  AAutoDestroy: Boolean): TPressMVPFormPresenter;
begin
  Result := Run(_PressMVPMainPresenter, AObject, AIncluding, AAutoDestroy);
end;

class function TPressMVPFormPresenter.Run(
  AParent: TPressMVPFormPresenter; AObject: TPressObject; AIncluding: Boolean;
  AAutoDestroy: Boolean): TPressMVPFormPresenter;
var
  VModelClass: TPressMVPObjectModelClass;
  VModel: TPressMVPObjectModel;
  VParentModel: TPressMVPObjectModel;
  VView: IPressMVPFormView;
  VFormClass: TClass;
  VForm: TObject;
  VObjectClass: TPressObjectClass;
  VIndex: Integer;
  VObjectIsMissing: Boolean;
  VRegForms: TPressMVPRegisteredFormList;
begin
  VRegForms := PressDefaultMVPFactory.Forms;
  VIndex := VRegForms.IndexOfPresenterClass(Self);
  if VIndex >= 0 then
    VFormClass := VRegForms[VIndex].FormClass
  else
    VFormClass := nil;
  if not Assigned(VFormClass) then
    raise EPressMVPError.CreateFmt(SUnassignedPresenterForm, [ClassName]);

  VObjectClass := VRegForms[VIndex].ObjectClass;
  VModelClass := VRegForms[VIndex].ModelClass;
  VObjectIsMissing := not Assigned(AObject);
  if VObjectIsMissing then
  begin
    AObject := VObjectClass.Create;
    AIncluding := True;
  end;

  if not Assigned(AParent) then
    AParent := _PressMVPMainPresenter;

  { TODO : Catch memory leakage when an exception is raised }
  if not Assigned(VModelClass) then
    VModelClass := InternalModelClass;
  if Assigned(AParent) then
    VParentModel := AParent.Model
  else
    VParentModel := nil;
  if Assigned(VModelClass) then
    VModel := VModelClass.Create(VParentModel, AObject)
  else
    VModel := PressDefaultMVPFactory.MVPModelFactory(
     VParentModel, AObject) as TPressMVPObjectModel;
  VModel.IsIncluding := AIncluding;
  VModel.User := PressUserData.User;
  if VObjectIsMissing then
    AObject.Release
  else if VModel.Session.IsPersistent(AObject) then
    VModel.Session.Load(AObject, True, False);
  VForm := PressWidget.CreateForm(VFormClass);
  PressAsIntf(
   PressDefaultMVPFactory.MVPViewFactory(VForm, True),
   IPressMVPFormView, VView);
  Result := Create(AParent, VModel, VView);
  AssignAccessor(VForm, SPressModelAccessorName, VModel);
  if VModel.HasSubject then
    AssignAccessor(VForm, SPressSubjectAccessorName, VModel.Subject);
  AssignAccessor(VForm, SPressPresenterAccessorName, Result);
  Result.FAutoDestroy := AAutoDestroy;
  Result.Refresh;
  PressWidget.ShowForm(VForm, False);
  Result.Running;
end;

procedure TPressMVPFormPresenter.Running;
begin
end;

{ TPressMVPQueryPresenter }

class function TPressMVPQueryPresenter.Apply(
  AModel: TPressMVPModel; const AView: IPressMVPView): Boolean;
begin
  Result := (AModel is TPressMVPQueryModel) and
   PressSupports(AView, IPressMVPFormView);
end;

function TPressMVPQueryPresenter.CreateQueryItemsPresenter(
  const AControlName: ShortString; ADisplayNames: string;
  AModelClass: TPressMVPModelClass;
  APresenterClass: TPressMVPPresenterClass): TPressMVPPresenter;
begin
  if ADisplayNames = '' then
    ADisplayNames := InternalQueryItemsDisplayNames;
  if not Assigned(AModelClass) then
    AModelClass := InternalQueryItemsModelClass;
  if not Assigned(APresenterClass) then
    APresenterClass := InternalQueryItemsPresenterClass;
  Result := CreateSubPresenter(
   SPressQueryItemsString, AControlName, ADisplayNames,
   AModelClass, APresenterClass);
end;

function TPressMVPQueryPresenter.GetModel: TPressMVPQueryModel;
begin
  Result := inherited Model as TPressMVPQueryModel;
end;

function TPressMVPQueryPresenter.InternalQueryItemsDisplayNames: string;
begin
  Result := '';
end;

function TPressMVPQueryPresenter.InternalQueryItemsModelClass: TPressMVPModelClass;
begin
  Result := nil;
end;

function TPressMVPQueryPresenter.InternalQueryItemsPresenterClass: TPressMVPPresenterClass;
begin
  Result := nil;
end;

{ TPressMVPMainFormPresenter }

class function TPressMVPMainFormPresenter.Apply(AModel: TPressMVPModel;
  const AView: IPressMVPView): Boolean;
begin
  Result := True;
end;

constructor TPressMVPMainFormPresenter.Create;
var
  VModelClass: TPressMVPObjectModelClass;
  VModel: TPressMVPObjectModel;
  VView: IPressMVPFormView;
  VSubject: TPressObject;
  VMainForm: TObject;
  VIndex: Integer;
  VRegForms: TPressMVPRegisteredFormList;
begin
  VMainForm := PressApp.MainForm;
  VSubject := nil;
  VModelClass := nil;

  VRegForms := PressDefaultMVPFactory.Forms;
  VIndex := VRegForms.IndexOfPresenterClass(
   TPressMVPFormPresenterClass(ClassType));
  if VIndex >= 0 then
  begin
    if Assigned(VRegForms[VIndex].ObjectClass) then
      VSubject := VRegForms[VIndex].ObjectClass.Create;
    VModelClass := VRegForms[VIndex].ModelClass;
  end;

  if not Assigned(VModelClass) then
    VModelClass := InternalModelClass;
  if not Assigned(VModelClass) then
    if VSubject is TPressQuery then
      VModelClass := TPressMVPQueryModel
    else
      VModelClass := TPressMVPObjectModel;
  VModel := VModelClass.Create(nil, VSubject);
  if Assigned(VSubject) then
    VSubject.Release;
  PressAsIntf(
   PressDefaultMVPFactory.MVPViewFactory(VMainForm),
   IPressMVPFormView, VView);
  inherited Create(nil, VModel, VView);
  AssignAccessor(VMainForm, SPressPresenterAccessorName, Self);
  AssignAccessor(VMainForm, SPressModelAccessorName, VModel);
  if Assigned(VSubject) then
    AssignAccessor(VMainForm, SPressSubjectAccessorName, VSubject);
  FNotifier := TPressNotifier.Create({$IFDEF FPC}@{$ENDIF}Notify);
  FNotifier.AddNotificationItem(PressApp, [TPressApplicationEvent]);
end;

procedure TPressMVPMainFormPresenter.Finit;
begin
  FNotifier.Free;
  inherited;
end;

class procedure TPressMVPMainFormPresenter.Initialize;
var
  VIndex: Integer;
  VRegForms: TPressMVPRegisteredFormList;
begin
  if not PressApp.HasMainForm then
  begin
    VRegForms := PressDefaultMVPFactory.Forms;
    VIndex := VRegForms.IndexOfPresenterClass(Self);
    if VIndex >= 0 then
      PressWidget.CreateForm(VRegForms[VIndex].FormClass)
    else
      raise EPressError.CreateFmt(SClassNotFound, [ClassName]);
  end;
  _PressMVPMainPresenter.Free;
  PressApp.InitApplication;
  _PressMVPMainPresenter := Create;
end;

procedure TPressMVPMainFormPresenter.Notify(AEvent: TPressEvent);
begin
  if AEvent is TPressApplicationRunningEvent then
    Running
  else if AEvent is TPressApplicationDoneEvent then
  begin
    _PressMVPMainPresenter := nil;
    Free;
  end;
end;

class procedure TPressMVPMainFormPresenter.Run;
begin
  if not Assigned(_PressMVPMainPresenter) then
    Initialize;
  _PressMVPMainPresenter.Refresh;
  PressApp.Run;
end;

initialization
  TPressMVPNullPresenter.RegisterPresenter;
  TPressMVPValuePresenter.RegisterPresenter;
  TPressMVPEnumPresenter.RegisterPresenter;
  TPressMVPReferencePresenter.RegisterPresenter;
  TPressMVPItemsPresenter.RegisterPresenter;
  TPressMVPFormPresenter.RegisterPresenter;
  TPressMVPQueryPresenter.RegisterPresenter;

finalization
  FreeAndNil(_PressMVPMainPresenter);

end.
