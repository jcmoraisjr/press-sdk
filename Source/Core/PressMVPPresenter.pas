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
  Controls,
  Forms,
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

  TPressMVPPresenterClass = class of TPressMVPPresenter;

  TPressMVPPresenter = class(TPressMVPObject)
  private
    FCommandMenu: TPressMVPCommandMenu;
    FInteractors: TPressMVPInteractorList;
    FModel: TPressMVPModel;
    FParent: TPressMVPFormPresenter;
    FView: TPressMVPView;
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
    procedure SetView(Value: TPressMVPView);
  protected
    procedure AfterInitInteractors; virtual;
    procedure BindCommand(ACommandClass: TPressMVPCommandClass; const AComponentName: ShortString); virtual;
    procedure InitPresenter; virtual;
    function InternalCreateCommandMenu: TPressMVPCommandMenu; virtual;
    property CommandMenu: TPressMVPCommandMenu read FCommandMenu write SetCommandMenu;
    property Interactors: TPressMVPInteractorList read GetInteractors;
  public
    constructor Create(AParent: TPressMVPFormPresenter; AModel: TPressMVPModel; AView: TPressMVPView); virtual;
    destructor Destroy; override;
    class function Apply(AModel: TPressMVPModel; AView: TPressMVPView): Boolean; virtual; abstract;
    { TODO : Remove this factory method }
    class function CreateFromControllers(AParent: TPressMVPFormPresenter; AModel: TPressMVPModel; AView: TPressMVPView): TPressMVPPresenter;
    class procedure RegisterPresenter;
    property Model: TPressMVPModel read FModel;
    property Parent: TPressMVPFormPresenter read FParent;
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

  TPressMVPValuePresenter = class(TPressMVPPresenter)
  private
    function GetModel: TPressMVPValueModel;
    function GetView: TPressMVPAttributeView;
  protected
    procedure InitPresenter; override;
  public
    class function Apply(AModel: TPressMVPModel; AView: TPressMVPView): Boolean; override;
    property Model: TPressMVPValueModel read GetModel;
    property View: TPressMVPAttributeView read GetView;
  end;

  TPressMVPPointerPresenter = class(TPressMVPPresenter)
  { TODO : Rename? }
  private
    function GetView: TPressMVPItemView;
  protected
    function InternalCreateIterator(const ASearchString: string): TPressIterator; virtual; abstract;
    function InternalCurrentItem(AIterator: TPressIterator): string; virtual; abstract;
  public
    function UpdateReferences(const ASearchString: string): Integer;
    property View: TPressMVPItemView read GetView;
  end;

  TPressMVPEnumPresenter = class(TPressMVPPointerPresenter)
  private
    function GetModel: TPressMVPEnumModel;
  protected
    function InternalCreateIterator(const ASearchString: string): TPressIterator; override;
    function InternalCurrentItem(AIterator: TPressIterator): string; override;
  public
    class function Apply(AModel: TPressMVPModel; AView: TPressMVPView): Boolean; override;
    property Model: TPressMVPEnumModel read GetModel;
  end;

  TPressMVPReferencePresenter = class(TPressMVPPointerPresenter)
  private
    function GetModel: TPressMVPReferenceModel;
  protected
    function InternalCreateIterator(const ASearchString: string): TPressIterator; override;
    function InternalCurrentItem(AIterator: TPressIterator): string; override;
  public
    class function Apply(AModel: TPressMVPModel; AView: TPressMVPView): Boolean; override;
    property Model: TPressMVPReferenceModel read GetModel;
  end;

  TPressMVPItemsPresenter = class(TPressMVPPresenter)
  private
    function GetModel: TPressMVPItemsModel;
    function GetView: TPressMVPItemsView;
  public
    class function Apply(AModel: TPressMVPModel; AView: TPressMVPView): Boolean; override;
    property Model: TPressMVPItemsModel read GetModel;
    property View: TPressMVPItemsView read GetView;
  end;

  TPressMVPFormPresenterType = (fpNew, fpExisting, fpQuery);
  TPressMVPFormPresenterTypes = set of TPressMVPFormPresenterType;

  TPressMVPFormPresenterClass = class of TPressMVPFormPresenter;

  TPressMVPFormPresenter = class(TPressMVPPresenter)
  private
    FAutoDestroy: Boolean;
    FSubPresenters: TPressMVPPresenterList;
    function GetModel: TPressMVPObjectModel;
    function GetSubPresenters: TPressMVPPresenterList;
    function GetView: TPressMVPFormView;
  protected
    function AttributeByName(const AAttributeName: ShortString): TPressAttribute;
    procedure BindCommand(ACommandClass: TPressMVPCommandClass; const AComponentName: ShortString); override;
    function CreateSubPresenter(const AAttributeName, AControlName: ShortString; const ADisplayNames: string = ''; AModelClass: TPressMVPModelClass = nil; AViewClass: TPressMVPViewClass = nil; APresenterClass: TPressMVPPresenterClass = nil): TPressMVPPresenter;
    procedure InitPresenter; override;
    function InternalCreateSubModel(ASubject: TPressSubject): TPressMVPModel; virtual;
    function InternalCreateSubPresenter(AModel: TPressMVPModel; AView: TPressMVPView): TPressMVPPresenter; virtual;
    function InternalCreateSubView(AControl: TControl): TPressMVPView; virtual;
    class function InternalModelClass: TPressMVPObjectModelClass; virtual;
    class function InternalViewClass: TPressMVPCustomFormViewClass; virtual;
    procedure Running; virtual;
    property SubPresenters: TPressMVPPresenterList read GetSubPresenters;
  public
    destructor Destroy; override;
    class function Apply(AModel: TPressMVPModel; AView: TPressMVPView): Boolean; override;
    function CreatePresenterIterator: TPressMVPPresenterIterator;
    procedure Refresh;
    class procedure RegisterFormPresenter(AObjectClass: TPressObjectClass; AFormClass: TFormClass; AFormPresenterTypes: TPressMVPFormPresenterTypes = [fpNew, fpExisting]; AModelClass: TPressMVPObjectModelClass = nil; AViewClass: TPressMVPCustomFormViewClass = nil);
    class function Run(AObject: TPressObject = nil; AIncluding: Boolean = False; AAutoDestroy: Boolean = True): TPressMVPFormPresenter; overload;
    class function Run(AParent: TPressMVPFormPresenter; AObject: TPressObject = nil; AIncluding: Boolean = False; AAutoDestroy: Boolean = True): TPressMVPFormPresenter; overload;
    property AutoDestroy: Boolean read FAutoDestroy;
    property Model: TPressMVPObjectModel read GetModel;
    property View: TPressMVPFormView read GetView;
  end;

  TPressMVPQueryPresenter = class(TPressMVPFormPresenter)
  private
    function GetModel: TPressMVPQueryModel;
  protected
    function CreateQueryItemsPresenter(const AControlName: ShortString; ADisplayNames: string = ''; AModelClass: TPressMVPModelClass = nil; AViewClass: TPressMVPViewClass = nil; APresenterClass: TPressMVPPresenterClass = nil): TPressMVPPresenter;
    function InternalQueryItemsDisplayNames: string; virtual;
    function InternalQueryItemsModelClass: TPressMVPModelClass; virtual;
    function InternalQueryItemsPresenterClass: TPressMVPPresenterClass; virtual;
    function InternalQueryItemsViewClass: TPressMVPViewClass; virtual;
  public
    class function Apply(AModel: TPressMVPModel; AView: TPressMVPView): Boolean; override;
    property Model: TPressMVPQueryModel read GetModel;
  end;

  TPressMVPMainFormPresenter = class(TPressMVPQueryPresenter)
  private
    FNotifier: TPressNotifier;
    procedure Notify(AEvent: TPressEvent);
  public
    constructor Create; reintroduce; virtual;
    destructor Destroy; override;
    class procedure Initialize;
    class procedure Run;
  end;

implementation

uses
  SysUtils,
  Classes,
  PressApplication,
  {$IFDEF PressLog}PressLog,{$ENDIF}
  PressConsts,
  PressMVPFactory,
  PressMVPCommand,
  PressMVPInteractor;  // initializing default interactors

type
  TPressMVPPresenterModelFriend = class(TPressMVPModel);
  TPressMVPPresenterViewFriend = class(TPressMVPView);

var
  _PressMVPMainPresenter: TPressMVPMainFormPresenter;

function PressMainPresenter: TPressMVPMainFormPresenter;
begin
  if not Assigned(_PressMVPMainPresenter) then
    raise EPressMVPError.Create(SUnassignedMainPresenter);
  Result := _PressMVPMainPresenter;
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
      FCommandMenu.AssignMenu(FView.Control);
    if Assigned(FModel) then
      FCommandMenu.AssignCommands(
       TPressMVPPresenterModelFriend(FModel).Commands);
  end;
end;

procedure TPressMVPPresenter.AfterChangeModel;
begin
  if Assigned(FModel) then
  begin
    if Assigned(FView) then
    begin
      TPressMVPPresenterViewFriend(FView).SetModel(FModel);
      TPressMVPPresenterModelFriend(FModel).SetChangeEvent(
       TPressMVPPresenterViewFriend(FView).ModelChanged);
      FModel.Changed(ctDisplay);
    end;
    if Assigned(FCommandMenu) then
      FCommandMenu.AssignCommands(
       TPressMVPPresenterModelFriend(FModel).Commands);
  end;
end;

procedure TPressMVPPresenter.AfterChangeView;
begin
  if Assigned(FView) then
  begin
    if Assigned(FCommandMenu) then
      FCommandMenu.AssignMenu(FView.Control);
    if Assigned(FModel) then
    begin
      TPressMVPPresenterViewFriend(FView).SetModel(FModel);
      TPressMVPPresenterModelFriend(FModel).SetChangeEvent(
       TPressMVPPresenterViewFriend(FView).ModelChanged);
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
    begin
      TPressMVPPresenterModelFriend(FModel).SetChangeEvent(nil);
      TPressMVPPresenterViewFriend(FView).SetModel(nil);
    end;
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
    begin
      TPressMVPPresenterModelFriend(FModel).SetChangeEvent(nil);
      TPressMVPPresenterViewFriend(FView).SetModel(nil);
    end;
    FreeAndNil(FView);
  end;
end;

procedure TPressMVPPresenter.BindCommand(
  ACommandClass: TPressMVPCommandClass; const AComponentName: ShortString);
var
  VComponent: TComponent;
begin
  if not Assigned(FParent) then
    Exit;
  VComponent := FParent.View.ComponentByName(AComponentName);
  if not Assigned(ACommandClass) then
    ACommandClass := TPressMVPNullCommand;
  Model.RegisterCommand(ACommandClass).AddComponent(VComponent);
end;

constructor TPressMVPPresenter.Create(
  AParent: TPressMVPFormPresenter; AModel: TPressMVPModel; AView: TPressMVPView);
begin
  CheckClass(Apply(AModel, AView));
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
end;

class function TPressMVPPresenter.CreateFromControllers(
  AParent: TPressMVPFormPresenter;
  AModel: TPressMVPModel; AView: TPressMVPView): TPressMVPPresenter;
begin
  Result :=
   PressDefaultMVPFactory.MVPPresenterFactory(AParent, AModel, AView);
end;

destructor TPressMVPPresenter.Destroy;
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

function TPressMVPPresenter.GetInteractors: TPressMVPInteractorList;
begin
  if not Assigned(FInteractors) then
    FInteractors := TPressMVPInteractorList.Create(True);
  Result := FInteractors;
end;

procedure TPressMVPPresenter.InitPresenter;
begin
end;

function TPressMVPPresenter.InternalCreateCommandMenu: TPressMVPCommandMenu;
begin
  Result := TPressMVPPopupCommandMenu.Create;
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

procedure TPressMVPPresenter.SetView(Value: TPressMVPView);
begin
  if FView <> Value then
  begin
    BeforeChangeView;
    FView := Value;
    AfterChangeView;
  end;
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

{ TPressMVPValuePresenter }

class function TPressMVPValuePresenter.Apply(AModel: TPressMVPModel;
  AView: TPressMVPView): Boolean;
begin
  { TODO : Improve factory - asap! }
  Result := (AModel is TPressMVPValueModel) and
   (AView is TPressMVPAttributeView) and
   not (AView is TPressMVPItemView);
end;

function TPressMVPValuePresenter.GetModel: TPressMVPValueModel;
begin
  Result := inherited Model as TPressMVPValueModel;
end;

function TPressMVPValuePresenter.GetView: TPressMVPAttributeView;
begin
  Result := inherited View as TPressMVPAttributeView;
end;

procedure TPressMVPValuePresenter.InitPresenter;
begin
  inherited;
  if Model.HasSubject then
    View.Size := Model.Subject.Metadata.Size;
end;

{ TPressMVPPointerPresenter }

function TPressMVPPointerPresenter.GetView: TPressMVPItemView;
begin
  Result := inherited View as TPressMVPItemView;
end;

function TPressMVPPointerPresenter.UpdateReferences(
  const ASearchString: string): Integer;
var
  VIterator: TPressIterator;
begin
  View.ClearReferences;
  VIterator := InternalCreateIterator(ASearchString);
  with VIterator do
  try
    Result := Count;
    BeforeFirstItem;
    while NextItem do
      View.AddReference(InternalCurrentItem(VIterator));
  finally
    Free;
  end;
end;

{ TPressMVPEnumPresenter }

class function TPressMVPEnumPresenter.Apply(AModel: TPressMVPModel;
  AView: TPressMVPView): Boolean;
begin
  Result := (AModel is TPressMVPEnumModel) and
   (AView is TPressMVPItemView);
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
  AView: TPressMVPView): Boolean;
begin
  Result := (AModel is TPressMVPReferenceModel) and
   (AView is TPressMVPItemView);
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
  AView: TPressMVPView): Boolean;
begin
  Result := (AModel is TPressMVPItemsModel) and (AView is TPressMVPItemsView);
end;

function TPressMVPItemsPresenter.GetModel: TPressMVPItemsModel;
begin
  Result := inherited Model as TPressMVPItemsModel;
end;

function TPressMVPItemsPresenter.GetView: TPressMVPItemsView;
begin
  Result := inherited View as TPressMVPItemsView;
end;

{ TPressMVPFormPresenter }

class function TPressMVPFormPresenter.Apply(
  AModel: TPressMVPModel; AView: TPressMVPView): Boolean;
begin
  Result := (AModel is TPressMVPObjectModel) and
   not (AModel is TPressMVPQueryModel) and (AView is TPressMVPFormView);
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

procedure TPressMVPFormPresenter.BindCommand(
  ACommandClass: TPressMVPCommandClass; const AComponentName: ShortString);
var
  VComponent: TComponent;
begin
  VComponent := View.ComponentByName(AComponentName);
  if not Assigned(ACommandClass) then
    ACommandClass := TPressMVPNullCommand;
  Model.RegisterCommand(ACommandClass).AddComponent(VComponent);
end;

function TPressMVPFormPresenter.CreatePresenterIterator: TPressMVPPresenterIterator;
begin
  Result := SubPresenters.CreateIterator;
end;

function TPressMVPFormPresenter.CreateSubPresenter(
  const AAttributeName, AControlName: ShortString;
  const ADisplayNames: string;
  AModelClass: TPressMVPModelClass;
  AViewClass: TPressMVPViewClass;
  APresenterClass: TPressMVPPresenterClass): TPressMVPPresenter;
var
  VAttribute: TPressAttribute;
  VControl: TControl;
  VModel: TPressMVPModel;
  VView: TPressMVPView;
begin
  VAttribute := AttributeByName(AAttributeName);
  VControl := View.ControlByName(AControlName);
  if Assigned(AModelClass) then
    VModel := AModelClass.Create(Model, VAttribute)
  else
    VModel := InternalCreateSubModel(VAttribute);
  if VModel is TPressMVPStructureModel then
    TPressMVPStructureModel(VModel).AssignDisplayNames(ADisplayNames)
  else if ADisplayNames <> '' then
  begin
    VModel.Free;
    VAttribute := VModel.Subject as TPressAttribute;
    raise EPressMVPError.CreateFmt(SUnsupportedDisplayNames,
     [VAttribute.ClassName, VAttribute.Owner.ClassName, VAttribute.Name]);
  end;
  if Assigned(AViewClass) then
    VView := AViewClass.Create(VControl)
  else
    VView := InternalCreateSubView(VControl);
  if Assigned(APresenterClass) then
    Result := APresenterClass.Create(Self, VModel, VView)
  else
    Result := InternalCreateSubPresenter(VModel, VView);
  { TODO : Fix leakages when exception raises. }
  { Note - if FModel and FView fields of the presenter was assigned,
    the compiler will destroy these instances }
end;

destructor TPressMVPFormPresenter.Destroy;
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

function TPressMVPFormPresenter.GetView: TPressMVPFormView;
begin
  Result := inherited View as TPressMVPFormView;
end;

procedure TPressMVPFormPresenter.InitPresenter;
begin
  inherited;
  FAutoDestroy := True;
end;

function TPressMVPFormPresenter.InternalCreateSubModel(
  ASubject: TPressSubject): TPressMVPModel;
begin
  Result := TPressMVPModel.CreateFromSubject(Model, ASubject);
end;

function TPressMVPFormPresenter.InternalCreateSubPresenter(
  AModel: TPressMVPModel; AView: TPressMVPView): TPressMVPPresenter;
begin
  Result := TPressMVPPresenter.CreateFromControllers(Self, AModel, AView);
end;

function TPressMVPFormPresenter.InternalCreateSubView(
  AControl: TControl): TPressMVPView;
begin
  Result := TPressMVPView.CreateFromControl(AControl);
end;

class function TPressMVPFormPresenter.InternalModelClass: TPressMVPObjectModelClass;
begin
  Result := nil;
end;

class function TPressMVPFormPresenter.InternalViewClass: TPressMVPCustomFormViewClass;
begin
  Result := nil;
end;

procedure TPressMVPFormPresenter.Refresh;
begin
  with SubPresenters.CreateIterator do
  try
    BeforeFirstItem;
    while NextItem do
      CurrentItem.View.Update;
  finally
    Free;
  end;
end;

class procedure TPressMVPFormPresenter.RegisterFormPresenter(
  AObjectClass: TPressObjectClass; AFormClass: TFormClass;
  AFormPresenterTypes: TPressMVPFormPresenterTypes;
  AModelClass: TPressMVPObjectModelClass;
  AViewClass: TPressMVPCustomFormViewClass);
begin
  PressDefaultMVPFactory.RegisterForm(Self, AObjectClass, AFormClass,
   AFormPresenterTypes, AModelClass, AViewClass);
end;

class function TPressMVPFormPresenter.Run(
  AObject: TPressObject; AIncluding: Boolean;
  AAutoDestroy: Boolean): TPressMVPFormPresenter;
begin
  Result := Run(PressMainPresenter, AObject, AIncluding, AAutoDestroy);
end;

class function TPressMVPFormPresenter.Run(
  AParent: TPressMVPFormPresenter; AObject: TPressObject; AIncluding: Boolean;
  AAutoDestroy: Boolean): TPressMVPFormPresenter;
var
  VModelClass: TPressMVPObjectModelClass;
  VModel: TPressMVPObjectModel;
  VViewClass: TPressMVPCustomFormViewClass;
  VView: TPressMVPCustomFormView;
  VFormClass: TFormClass;
  VObjectClass: TPressObjectClass;
  VIndex: Integer;
  VObjectIsMissing: Boolean;
  VRegForms: TPressMVPRegisteredFormList;
begin
  VRegForms := PressDefaultMVPFactory.Forms;
  VIndex := VRegForms.IndexOfPresenterClass(Self);
  if VIndex >= 0 then
  begin
    VFormClass := VRegForms[VIndex].FormClass;
    VObjectClass := VRegForms[VIndex].ObjectClass;
    VModelClass := VRegForms[VIndex].ModelClass;
    VViewClass := VRegForms[VIndex].ViewClass;
  end else
    raise EPressError.CreateFmt(SClassNotFound, [ClassName]);
  VObjectIsMissing := not Assigned(AObject);
  if VObjectIsMissing then
  begin
    AObject := VObjectClass.Create;
    AIncluding := True;
  end;

  if not Assigned(AParent) then
    AParent := PressMainPresenter;

  { TODO : Catch memory leakage when an exception is raised }
  if not Assigned(VModelClass) then
    VModelClass := InternalModelClass;
  if Assigned(VModelClass) then
    VModel := VModelClass.Create(AParent.Model, AObject)
  else
    VModel := TPressMVPModel.CreateFromSubject(
     AParent.Model, AObject) as TPressMVPObjectModel;
  VModel.IsIncluding := AIncluding;
  VModel.AccessUser := PressUserData.User;
  if VObjectIsMissing then
    AObject.Release;

  if not Assigned(VViewClass) then
    VViewClass := InternalViewClass;
  if Assigned(VViewClass) then
    VView := VViewClass.Create(VFormClass.Create(nil), True)
  else
    VView := TPressMVPView.CreateFromControl(
     VFormClass.Create(nil), True) as TPressMVPCustomFormView;

  Result := Create(AParent, VModel, VView);
  Result.FAutoDestroy := AAutoDestroy;
  Result.Refresh;
  Result.View.Control.Show;
  Result.Running;
end;

procedure TPressMVPFormPresenter.Running;
begin
end;

{ TPressMVPQueryPresenter }

class function TPressMVPQueryPresenter.Apply(
  AModel: TPressMVPModel; AView: TPressMVPView): Boolean;
begin
  Result := (AModel is TPressMVPQueryModel) and (AView is TPressMVPFormView);
end;

function TPressMVPQueryPresenter.CreateQueryItemsPresenter(
  const AControlName: ShortString; ADisplayNames: string;
  AModelClass: TPressMVPModelClass;
  AViewClass: TPressMVPViewClass;
  APresenterClass: TPressMVPPresenterClass): TPressMVPPresenter;
begin
  if ADisplayNames = '' then
    ADisplayNames := InternalQueryItemsDisplayNames;
  if not Assigned(AModelClass) then
    AModelClass := InternalQueryItemsModelClass;
  if not Assigned(AViewClass) then
    AViewClass := InternalQueryItemsViewClass;
  if not Assigned(APresenterClass) then
    APresenterClass := InternalQueryItemsPresenterClass;
  Result := CreateSubPresenter(
   SPressQueryItemsString, AControlName, ADisplayNames,
   AModelClass, AViewClass, APresenterClass);
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

function TPressMVPQueryPresenter.InternalQueryItemsViewClass: TPressMVPViewClass;
begin
  Result := nil;
end;

{ TPressMVPMainFormPresenter }

constructor TPressMVPMainFormPresenter.Create;
var
  VModelClass: TPressMVPObjectModelClass;
  VModel: TPressMVPObjectModel;
  VViewClass: TPressMVPCustomFormViewClass;
  VView: TPressMVPCustomFormView;
  VSubject: TPressObject;
  VIndex: Integer;
  VRegForms: TPressMVPRegisteredFormList;
begin
  if not Assigned(Application) or not Assigned(Application.MainForm) then
    raise EPressError.Create(SUnassignedMainForm);

  VSubject := nil;
  VModelClass := nil;
  VViewClass := nil;

  VRegForms := PressDefaultMVPFactory.Forms;
  VIndex := VRegForms.IndexOfPresenterClass(
   TPressMVPFormPresenterClass(ClassType));
  if VIndex >= 0 then
  begin
    if Assigned(VRegForms[VIndex].ObjectClass) then
      VSubject := VRegForms[VIndex].ObjectClass.Create;
    VModelClass := VRegForms[VIndex].ModelClass;
    VViewClass := VRegForms[VIndex].ViewClass;
  end;

  if not Assigned(VModelClass) then
    VModelClass := InternalModelClass;
  if not Assigned(VModelClass) then
    VModelClass := TPressMVPQueryModel;
  VModel := VModelClass.Create(nil, VSubject);
  if Assigned(VSubject) then
    VSubject.Release;

  if not Assigned(VViewClass) then
    VViewClass := InternalViewClass;
  if Assigned(VViewClass) then
    VView := VViewClass.Create(Application.MainForm)
  else
    VView :=
     TPressMVPView.CreateFromControl(Application.MainForm) as TPressMVPCustomFormView;

  inherited Create(nil, VModel, VView);
  FNotifier := TPressNotifier.Create(Notify);
  FNotifier.AddNotificationItem(PressApp, [TPressApplicationEvent]);
end;

destructor TPressMVPMainFormPresenter.Destroy;
begin
  FNotifier.Free;
  inherited;
end;

class procedure TPressMVPMainFormPresenter.Initialize;
var
  VIndex: Integer;
  VRef: TForm;
  VRegForms: TPressMVPRegisteredFormList;
begin
  if not Assigned(Application.MainForm) then
  begin
    VRegForms := PressDefaultMVPFactory.Forms;
    VIndex := VRegForms.IndexOfPresenterClass(Self);
    if VIndex >= 0 then
      Application.CreateForm(VRegForms[VIndex].FormClass, VRef)
    else
      raise EPressError.CreateFmt(SClassNotFound, [ClassName]);
  end;
  _PressMVPMainPresenter.Free;
  _PressMVPMainPresenter := Create;
end;

procedure TPressMVPMainFormPresenter.Notify(AEvent: TPressEvent);
begin
  if AEvent is TPressApplicationRunningEvent then
    Running
  else if AEvent is TPressApplicationDoneEvent then
    Free;
end;

class procedure TPressMVPMainFormPresenter.Run;
begin
  if not Assigned(_PressMVPMainPresenter) then
    Initialize;
  PressApp.Run;
end;

procedure RegisterPresenters;
begin
  TPressMVPValuePresenter.RegisterPresenter;
  TPressMVPEnumPresenter.RegisterPresenter;
  TPressMVPReferencePresenter.RegisterPresenter;
  TPressMVPItemsPresenter.RegisterPresenter;
  TPressMVPFormPresenter.RegisterPresenter;
  TPressMVPQueryPresenter.RegisterPresenter;
end;

initialization
  RegisterPresenters;

end.
