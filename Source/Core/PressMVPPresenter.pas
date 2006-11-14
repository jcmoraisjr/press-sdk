(*
  PressObjects, MVP-Presenter Classes
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

unit PressMVPPresenter;

interface

{$I Press.inc}

uses
  Classes,
  Controls,
  StdCtrls,
  Graphics,
  Grids,
  Forms,
  PressCompatibility,
  PressClasses,
  PressSubject,
  PressNotifier,
  PressMVP,
  PressMVPModel,
  PressMVPView;

type
  TPressMVPPresenter = class;
  TPressMVPValuePresenter = class;
  TPressMVPPointerPresenter = class;
  TPressMVPEnumPresenter = class;
  TPressMVPReferencePresenter = class;
  TPressMVPItemsPresenter = class;
  TPressMVPFormPresenter = class;

  TPressMVPFormPresenterType =
   (fpInclude, fpPresent, fpIncludePresent, fpRegister);

  { TPressMVPInteractors }

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

  TPressMVPNextControlInteractor = class(TPressMVPInteractor)
  protected
    procedure DoSelectNextControl; virtual;
    procedure DoPressEnter; virtual;
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPUpdateComboInteractor = class(TPressMVPNextControlInteractor)
  private
    function GetOwner: TPressMVPPointerPresenter;
    function GetView: TPressMVPComboBoxView;
  protected
    procedure DoPressEnter; override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
    property Owner: TPressMVPPointerPresenter read GetOwner;
    property View: TPressMVPComboBoxView read GetView;
  end;

  TPressMVPOpenComboInteractor = class(TPressMVPInteractor)
  private
    function GetOwner: TPressMVPPointerPresenter;
  protected
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
    property Owner: TPressMVPPointerPresenter read GetOwner;
  end;

  TPressMVPChangeModelInteractor = class(TPressMVPInteractor)
  protected
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPUpdaterInteractor = class(TPressMVPInteractor)
  private
    function GetSubject: TPressAttribute;
    function GetView: TPressMVPAttributeView;
  protected
    procedure DoUpdateModel;
    procedure InternalUpdateModel; virtual; abstract;
    procedure Notify(AEvent: TPressEvent); override;
  public
    property Subject: TPressAttribute read GetSubject;
    property View: TPressMVPAttributeView read GetView;
  end;

  TPressMVPExitUpdaterInteractor = class(TPressMVPUpdaterInteractor)
  protected
    procedure InitInteractor; override;
  end;

  TPressMVPEditUpdaterInteractor = class(TPressMVPExitUpdaterInteractor)
  protected
    procedure InternalUpdateModel; override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPEnumUpdaterInteractor = class(TPressMVPExitUpdaterInteractor)
  private
    function GetOwner: TPressMVPEnumPresenter;
  protected
    procedure InternalUpdateModel; override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
    property Owner: TPressMVPEnumPresenter read GetOwner;
  end;

  TPressMVPDateTimeUpdaterInteractor = class(TPressMVPExitUpdaterInteractor)
  protected
    procedure InternalUpdateModel; override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPReferenceUpdaterInteractor = class(TPressMVPExitUpdaterInteractor)
  private
    function GetOwner: TPressMVPReferencePresenter;
    function GetSubject: TPressReference;
  protected
    procedure InternalUpdateModel; override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
    property Owner: TPressMVPReferencePresenter read GetOwner;
    property Subject: TPressReference read GetSubject;
  end;

  TPressMVPClickUpdaterInteractor = class(TPressMVPUpdaterInteractor)
  protected
    procedure InitInteractor; override;
  end;

  TPressMVPBooleanUpdaterInteractor = class(TPressMVPClickUpdaterInteractor)
  protected
    procedure InternalUpdateModel; override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPDblClickSelectableInteractor = class(TPressMVPInteractor)
  private
    FCommand: TPressMVPCommand;
  protected
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPEditableInteractor = class(TPressMVPInteractor)
  private
    function GetOwner: TPressMVPValuePresenter;
  protected
    procedure InitInteractor; override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
    property Owner: TPressMVPValuePresenter read GetOwner;
  end;

  TPressMVPNumericInteractor = class(TPressMVPEditableInteractor)
  private
    FAcceptDecimal: Boolean;
    FAcceptNegative: Boolean;
  protected
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
    property AcceptDecimal: Boolean read FAcceptDecimal write FAcceptDecimal;
    property AcceptNegative: Boolean read FAcceptNegative write FAcceptNegative;
  end;

  TPressMVPIntegerInteractor = class(TPressMVPNumericInteractor)
  protected
    procedure InitInteractor; override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPFloatInteractor = class(TPressMVPNumericInteractor)
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPDateTimeInteractor = class(TPressMVPEditableInteractor)
  protected
    procedure Notify(AEvent: TPressEvent); override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPDrawItemsInteractor = class(TPressMVPInteractor)
  private
    function GetOwner: TPressMVPItemsPresenter;
  protected
    procedure DrawTextRect(ACanvas: TCanvas; ARect: TRect; const AText: string; AAlignment: TAlignment);
  public
    property Owner: TPressMVPItemsPresenter read GetOwner;
  end;

  TPressMVPDrawListBoxInteractor = class(TPressMVPDrawItemsInteractor)
  protected
    procedure DrawItem(Sender: TPressMVPListBoxView; ACanvas: TCanvas; AIndex: Integer; ARect: TRect; State: TOwnerDrawState); virtual;
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPDrawGridInteractor = class(TPressMVPDrawItemsInteractor)
  protected
    procedure DrawCell(Sender: TPressMVPGridView; ACanvas: TCanvas; ACol, ARow: Longint; ARect: TRect; State: TGridDrawState); virtual;
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPSelectItemInteractor = class(TPressMVPInteractor)
  private
    function GetOwner: TPressMVPItemsPresenter;
  protected
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
    procedure SelectItem(AIndex: Integer); virtual;
  public
    property Owner: TPressMVPItemsPresenter read GetOwner;
  end;

  TPressMVPSelectListBoxInteractor = class(TPressMVPSelectItemInteractor)
  protected
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPSelectGridInteractor = class(TPressMVPSelectItemInteractor)
  private
    procedure SelectCell(Sender: TObject; ACol, ARow: Longint; var CanSelect: Boolean);
  protected
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPCreateFormInteractor = class(TPressMVPInteractor)
  private
    function GetModel: TPressMVPStructureModel;
  protected
    procedure ExecuteFormPresenter(AFormPresenterType: TPressMVPFormPresenterType);
    procedure RunPresenter(APresenterIndex: Integer; AObject: TPressObject; AIncluding: Boolean);
  public
    property Model: TPressMVPStructureModel read GetModel;
  end;

  TPressMVPCreateIncludeFormInteractor = class(TPressMVPCreateFormInteractor)
  protected
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPCreatePresentFormInteractor = class(TPressMVPCreateFormInteractor)
  protected
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPCreateSearchFormInteractor = class(TPressMVPCreateFormInteractor)
  protected
    procedure ExecuteQueryPresenter;
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPCloseFormInteractor = class(TPressMVPInteractor)
  private
    function GetOwner: TPressMVPFormPresenter;
  protected
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
    property Owner: TPressMVPFormPresenter read GetOwner;
  end;

  TPressMVPFreePresenterInteractor = class(TPressMVPInteractor)
  protected
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  { TPressMVPPresenters }

  TPressMVPFreePresenterEvent = class(TPressEvent)
  end;

  TPressMVPPresenterList = class;

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
    function InternalUpdateReferences(const ASearchString: string): Integer; virtual; abstract;
  public
    function UpdateReferences(const ASearchString: string): Integer;
    property View: TPressMVPItemView read GetView;
  end;

  TPressMVPEnumPresenter = class(TPressMVPPointerPresenter)
  private
    function GetModel: TPressMVPEnumModel;
  protected
    procedure InitPresenter; override;
    function InternalUpdateReferences(const ASearchString: string): Integer; override;
  public
    class function Apply(AModel: TPressMVPModel; AView: TPressMVPView): Boolean; override;
    property Model: TPressMVPEnumModel read GetModel;
  end;

  TPressMVPReferencePresenter = class(TPressMVPPointerPresenter)
  private
    function GetModel: TPressMVPReferenceModel;
  protected
    function InternalUpdateReferences(const ASearchString: string): Integer; override;
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
    function CreateSubPresenter(const AAttributeName, AControlName: ShortString; AModelClass: TPressMVPModelClass = nil; AViewClass: TPressMVPViewClass = nil; APresenterClass: TPressMVPPresenterClass = nil): TPressMVPPresenter; overload;
    function CreateSubPresenter(const AAttributeName, AControlName: ShortString; const ADisplayNames: string; AModelClass: TPressMVPModelClass = nil; AViewClass: TPressMVPViewClass = nil; APresenterClass: TPressMVPPresenterClass = nil): TPressMVPPresenter; overload;
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
    procedure Refresh;
    class procedure RegisterFormPresenter(AObjectClass: TPressObjectClass; AFormClass: TFormClass; AFormPresenterType: TPressMVPFormPresenterType = fpIncludePresent);
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

  TPressMVPRegisteredForm = class(TObject)
  private
    FFormClass: TFormClass;
    FFormPresenterType: TPressMVPFormPresenterType;
    FObjectClass: TPressObjectClass;
    FPresenterClass: TPressMVPFormPresenterClass;
  public
    constructor Create(APresenterClass: TPressMVPFormPresenterClass; AObjectClass: TPressObjectClass; AFormClass: TFormClass; AFormPresenterType: TPressMVPFormPresenterType);
    property FormClass: TFormClass read FFormClass;
    property FormPresenterType: TPressMVPFormPresenterType read FFormPresenterType;
    property ObjectClass: TPressObjectClass read FObjectClass;
    property PresenterClass: TPressMVPFormPresenterClass read FPresenterClass;
  end;

  TPressMVPRegisteredFormIterator = class;

  TPressMVPRegisteredFormList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressMVPRegisteredForm;
    procedure SetItems(AIndex: Integer; const Value: TPressMVPRegisteredForm);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressMVPRegisteredForm): Integer;
    function CreateIterator: TPressMVPRegisteredFormIterator;
    function IndexOf(AObject: TPressMVPRegisteredForm): Integer;
    function IndexOfObjectClass(AObjectClass: TPressObjectClass; AFormPresenterType: TPressMVPFormPresenterType): Integer;
    function IndexOfPresenterClass(APresenterClass: TPressMVPFormPresenterClass): Integer;
    function IndexOfQueryItemObject(AObjectClass: TPressObjectClass; AFormPresenterType: TPressMVPFormPresenterType): Integer;
    procedure Insert(Index: Integer; AObject: TPressMVPRegisteredForm);
    function Remove(AObject: TPressMVPRegisteredForm): Integer;
    property Items[AIndex: Integer]: TPressMVPRegisteredForm read GetItems write SetItems; default;
  end;

  TPressMVPRegisteredFormIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressMVPRegisteredForm;
  public
    property CurrentItem: TPressMVPRegisteredForm read GetCurrentItem;
  end;

implementation

uses
  SysUtils,
  Math,
  PressApplication,
  {$IFDEF PressLog}PressLog,{$ENDIF}
  PressConsts,
  PressQuery,
  PressMVPFactory,
  PressMVPCommand;

type
  TPressMVPPresenterModelFriend = class(TPressMVPModel);
  TPressMVPPresenterViewFriend = class(TPressMVPView);

var
  _PressMVPMainPresenter: TPressMVPMainFormPresenter;
  _PressMVPRegisteredForms: TPressMVPRegisteredFormList;

function PressMainPresenter: TPressMVPMainFormPresenter;
begin
  if not Assigned(_PressMVPMainPresenter) then
    raise EPressMVPError.Create(SUnassignedMainPresenter);
  Result := _PressMVPMainPresenter;
end;

function PressMVPRegisteredForms: TPressMVPRegisteredFormList;
begin
  if not Assigned(_PressMVPRegisteredForms) then
  begin
    _PressMVPRegisteredForms := TPressMVPRegisteredFormList.Create(True);
    PressRegisterSingleObject(_PressMVPRegisteredForms);
  end;
  Result := _PressMVPRegisteredForms;
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

{ TPressMVPNextControlInteractor }

class function TPressMVPNextControlInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := APresenter.View is TPressMVPWinView;
end;

procedure TPressMVPNextControlInteractor.DoPressEnter;
var
  VSelection: TPressMVPSelection;
begin
  DoSelectNextControl;

  { TODO : Specific behavior implemented here in order to include into
    all NextControlInteractor decendants, instead creating another
    Keyboard interactor --listening and changing-- the same event and Key }
  if Owner.Model.Parent is TPressMVPQueryModel then
  begin
    VSelection := Owner.Model.Parent.Selection;
    if (VSelection.Count > 0) and (VSelection[0] is TPressMVPItemsModel) and
     (TPressMVPItemsModel(VSelection[0]).Subject.Name = SPressQueryItemsString) then
      TPressMVPQueryModel(Owner.Model.Parent).Execute;
  end;

end;

procedure TPressMVPNextControlInteractor.DoSelectNextControl;
begin
  if Owner.View is TPressMVPWinView then
    TPressMVPWinView(Owner.View).SelectNext;
end;

procedure TPressMVPNextControlInteractor.InitInteractor;
begin
  inherited;
  Notifier.AddNotificationItem(Owner.View, [TPressMVPViewKeyPressEvent]);
end;

procedure TPressMVPNextControlInteractor.Notify(AEvent: TPressEvent);
begin
  inherited;
  if (AEvent is TPressMVPViewKeyPressEvent) and
   (TPressMVPViewKeyPressEvent(AEvent).Key = #13) then
  begin
    DoPressEnter;
    TPressMVPViewKeyPressEvent(AEvent).Key := #0;
  end;
end;

{ TPressMVPUpdateComboInteractor }

class function TPressMVPUpdateComboInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := (APresenter is TPressMVPPointerPresenter) and
   (APresenter.View is TPressMVPComboBoxView);
end;

procedure TPressMVPUpdateComboInteractor.DoPressEnter;
var
  VView: TPressMVPComboBoxView;
begin
  VView := View;
  if (VView.AsString = '') or
   (VView.ReferencesVisible and (VView.AsInteger >= 0)) then
    inherited
  else if VView.Changed then
  begin
    case Owner.UpdateReferences(VView.AsString) of
      0: VView.SelectAll;
      1: inherited;
      else VView.ShowReferences;
    end;
  end else
    inherited;
end;

function TPressMVPUpdateComboInteractor.GetOwner: TPressMVPPointerPresenter;
begin
  Result := inherited Owner as TPressMVPPointerPresenter;
end;

function TPressMVPUpdateComboInteractor.GetView: TPressMVPComboBoxView;
begin
  Result := inherited Owner.View as TPressMVPComboBoxView;
end;

{ TPressMVPOpenComboInteractor }

class function TPressMVPOpenComboInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := (APresenter is TPressMVPPointerPresenter) and
   (APresenter.View is TPressMVPComboBoxView);
end;

function TPressMVPOpenComboInteractor.GetOwner: TPressMVPPointerPresenter;
begin
  Result := inherited Owner as TPressMVPPointerPresenter;
end;

procedure TPressMVPOpenComboInteractor.InitInteractor;
begin
  inherited;
  Notifier.AddNotificationItem(Owner.View, [TPressMVPViewDropDownEvent]);
end;

procedure TPressMVPOpenComboInteractor.Notify(AEvent: TPressEvent);
begin
  inherited;
  if AEvent is TPressMVPViewDropDownEvent then
    Owner.UpdateReferences('');
end;

{ TPressMVPChangeModelInteractor }

class function TPressMVPChangeModelInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := APresenter.View is TPressMVPWinView;
end;

procedure TPressMVPChangeModelInteractor.InitInteractor;
begin
  inherited;
  Notifier.AddNotificationItem(Owner.View,
   [TPressMVPViewEnterEvent, TPressMVPViewExitEvent]);
end;

procedure TPressMVPChangeModelInteractor.Notify(AEvent: TPressEvent);
var
  VObjectModel: TPressMVPObjectModel;
begin
  inherited;
  if (AEvent is TPressMVPViewEnterEvent) or
   (AEvent is TPressMVPViewExitEvent) then
  begin
    VObjectModel := Owner.Parent.Model;
    if AEvent is TPressMVPViewEnterEvent then
    begin
      VObjectModel.Selection.SelectObject(Owner.Model);
      Owner.View.Update;
    end else
      VObjectModel.Selection.SelectObject(nil);
  end;
end;

{ TPressMVPUpdaterInteractor }

procedure TPressMVPUpdaterInteractor.DoUpdateModel;
begin
  try
    { TODO : Test behavior with exceptions from ModelUpdate event }
    //try
      InternalUpdateModel;
    //except
    //  on E: Exception do
    //    if (AEvent is TPressMVPViewExitEvent) or not (E is EPressError) then
    //      raise;
    //end;
    Owner.View.Update;
  except
    if Owner.View is TPressMVPWinView then
    begin
      Owner.View.DisableEvents;
      try
        TPressMVPWinView(Owner.View).SetFocus;
      finally
        Owner.View.EnableEvents;
      end;
    end;
    raise;
  end;
end;

function TPressMVPUpdaterInteractor.GetSubject: TPressAttribute;
begin
  Result := Owner.Model.Subject as TPressAttribute;
end;

function TPressMVPUpdaterInteractor.GetView: TPressMVPAttributeView;
begin
  Result := Owner.View as TPressMVPAttributeView;
end;

procedure TPressMVPUpdaterInteractor.Notify(AEvent: TPressEvent);
begin
  inherited;
  {$IFDEF PressLogMVP}PressLogMsg(Self, 'Updating Model');{$ENDIF}
  DoUpdateModel;
end;

{ TPressMVPExitUpdaterInteractor }

procedure TPressMVPExitUpdaterInteractor.InitInteractor;
begin
  inherited;
  Notifier.AddNotificationItem(Owner.View, [TPressMVPViewExitEvent]);
  Notifier.AddNotificationItem(Owner.Model, [TPressMVPModelUpdateDataEvent]);
end;

{ TPressMVPEditUpdaterInteractor }

class function TPressMVPEditUpdaterInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := APresenter.View is TPressMVPEditView;
end;

procedure TPressMVPEditUpdaterInteractor.InternalUpdateModel;
begin
  Subject.AsString := View.AsString;
end;

{ TPressMVPEnumUpdaterInteractor }

class function TPressMVPEnumUpdaterInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := APresenter is TPressMVPEnumPresenter and
   (APresenter.View is TPressMVPItemView);
end;

function TPressMVPEnumUpdaterInteractor.GetOwner: TPressMVPEnumPresenter;
begin
  Result := inherited Owner as TPressMVPEnumPresenter;
end;

procedure TPressMVPEnumUpdaterInteractor.InternalUpdateModel;
var
  VIndex: Integer;
  VModel: TPressMVPEnumModel;
begin
  VModel := Owner.Model;
  if (View.AsString = '') or (View.AsInteger >= VModel.EnumValueCount) then
    Subject.Clear
  else
  begin
    VIndex := View.AsInteger;
    if (VIndex = -1) and (VModel.EnumValueCount = 1) then
      VIndex := 0;
    if VIndex >= 0 then
      Subject.AsInteger := VModel.EnumOf(VIndex);
  end;
end;

{ TPressMVPDateTimeUpdaterInteractor }

class function TPressMVPDateTimeUpdaterInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := APresenter.View is TPressMVPDateTimeView;
end;

procedure TPressMVPDateTimeUpdaterInteractor.InternalUpdateModel;
begin
  Subject.AsDateTime := (View as TPressMVPDateTimeView).AsDateTime;
end;

{ TPressMVPReferenceUpdaterInteractor }

class function TPressMVPReferenceUpdaterInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := APresenter is TPressMVPReferencePresenter and
   (APresenter.View is TPressMVPItemView);
end;

function TPressMVPReferenceUpdaterInteractor.GetOwner: TPressMVPReferencePresenter;
begin
  Result := inherited Owner as TPressMVPReferencePresenter;
end;

function TPressMVPReferenceUpdaterInteractor.GetSubject: TPressReference;
begin
  Result := inherited Subject as TPressReference;
end;

procedure TPressMVPReferenceUpdaterInteractor.InternalUpdateModel;
var
  VIndex: Integer;
  VModel: TPressMVPReferenceModel;
begin
  VModel := Owner.Model;
  if (View.AsString = '') or (View.AsInteger >= VModel.Query.Count) then
    Subject.Value := nil
  else
  begin
    VIndex := View.AsInteger;
    if (VIndex = -1) and (VModel.Query.Count = 1) then
      VIndex := 0;
    if VIndex >= 0 then
      Subject.Value := VModel.ObjectOf(VIndex);
  end;
end;

{ TPressMVPClickUpdaterInteractor }

procedure TPressMVPClickUpdaterInteractor.InitInteractor;
begin
  inherited;
  Notifier.AddNotificationItem(Owner.View, [TPressMVPViewClickEvent]);
end;

{ TPressMVPBooleanUpdaterInteractor }

class function TPressMVPBooleanUpdaterInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := APresenter.View is TPressMVPBooleanView;
end;

procedure TPressMVPBooleanUpdaterInteractor.InternalUpdateModel;
begin
  if View.IsClear then
    Subject.Clear
  else
    Subject.AsBoolean := View.AsBoolean;
end;

{ TPressMVPDblClickSelectableInteractor }

class function TPressMVPDblClickSelectableInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := APresenter is TPressMVPItemsPresenter;
end;

procedure TPressMVPDblClickSelectableInteractor.InitInteractor;
begin
  inherited;
  FCommand := Owner.Model.FindCommand(TPressMVPAssignSelectionCommand);
  if not Assigned(FCommand) then
    FCommand := Owner.Model.RegisterCommand(TPressMVPEditItemCommand);
  Notifier.AddNotificationItem(Owner.View, [TPressMVPViewDblClickEvent]);
end;

procedure TPressMVPDblClickSelectableInteractor.Notify(AEvent: TPressEvent);
begin
  inherited;
  FCommand.Execute;
end;

{ TPressMVPEditableInteractor }

class function TPressMVPEditableInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := APresenter is TPressMVPValuePresenter;
end;

function TPressMVPEditableInteractor.GetOwner: TPressMVPValuePresenter;
begin
  Result := inherited Owner as TPressMVPValuePresenter;
end;

procedure TPressMVPEditableInteractor.InitInteractor;
begin
  inherited;
  Notifier.AddNotificationItem(Owner.View, [TPressMVPViewKeyPressEvent]);
end;

{ TPressMVPNumericInteractor }

procedure TPressMVPNumericInteractor.InitInteractor;
begin
  inherited;
  AcceptDecimal := True;
  AcceptNegative := True;
end;

procedure TPressMVPNumericInteractor.Notify(AEvent: TPressEvent);
var
  VKey: Char;
begin
  inherited;
  if AEvent is TPressMVPViewKeyPressEvent then
  begin
    VKey := TPressMVPViewKeyPressEvent(AEvent).Key;
    if VKey = DecimalSeparator then
    begin
      if not AcceptDecimal or (Pos(DecimalSeparator, Owner.View.AsString) > 0) then
        VKey := #0;
    end else if VKey = '-' then
    begin
      { TODO : Fix "-" interaction }
      if not AcceptNegative or (Pos('-', Owner.View.AsString) > 0) then
        VKey := #0;
    end else if not (VKey in [#8, '0'..'9']) then
      VKey := #0;
    TPressMVPViewKeyPressEvent(AEvent).Key := VKey;
  end;
end;

{ TPressMVPIntegerInteractor }

class function TPressMVPIntegerInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := inherited Apply(APresenter) and
   (APresenter.Model.Subject is TPressInteger);
end;

procedure TPressMVPIntegerInteractor.InitInteractor;
begin
  inherited;
  AcceptDecimal := False;
end;

{ TPressMVPFloatInteractor }

class function TPressMVPFloatInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := inherited Apply(APresenter) and
   ((APresenter.Model.Subject is TPressFloat) or
   (APresenter.Model.Subject is TPressCurrency));
end;

{ TPressMVPDateTimeInteractor }

class function TPressMVPDateTimeInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := inherited Apply(APresenter) and
   (APresenter.Model.Subject is TPressDateTime);
end;

procedure TPressMVPDateTimeInteractor.Notify(AEvent: TPressEvent);
begin
  inherited;
  { TODO : Implement }
end;

{ TPressMVPDrawItemsInteractor }

procedure TPressMVPDrawItemsInteractor.DrawTextRect(
  ACanvas: TCanvas; ARect: TRect; const AText: string; AAlignment: TAlignment);
var
  VTop: Integer;
  VLeft: Integer;
begin
  VTop := ARect.Top + 1;
  case AAlignment of
    taLeftJustify:
      VLeft := ARect.Left + 2;
    taRightJustify:
      VLeft := ARect.Right - ACanvas.TextWidth(AText) - 2;
    else {taCenter}
      VLeft := (ARect.Left + ARect.Right - ACanvas.TextWidth(AText)) div 2;
  end;
  ACanvas.TextRect(ARect, VLeft, VTop, AText);
end;

function TPressMVPDrawItemsInteractor.GetOwner: TPressMVPItemsPresenter;
begin
  Result := inherited Owner as TPressMVPItemsPresenter;
end;

{ TPressMVPDrawListBoxInteractor }

class function TPressMVPDrawListBoxInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := APresenter.View is TPressMVPListBoxView;
end;

procedure TPressMVPDrawListBoxInteractor.DrawItem(
  Sender: TPressMVPListBoxView; ACanvas: TCanvas; AIndex: Integer;
  ARect: TRect; State: TOwnerDrawState);
begin
  DrawTextRect(ACanvas, ARect,
   Owner.Model.DisplayText(0, AIndex), Owner.Model.TextAlignment(0));
end;

procedure TPressMVPDrawListBoxInteractor.InitInteractor;
begin
  inherited;
  {$IFDEF PressViewNotification}
  Notifier.AddNotificationItem(Owner.View, [TPressMVPViewDrawItemEvent]);
  {$ELSE}{$IFDEF PressViewDirectEvent}
  (Owner.View as TPressMVPListBoxView).OnDrawItem := DrawItem;
  {$ENDIF}{$ENDIF}
end;

procedure TPressMVPDrawListBoxInteractor.Notify(AEvent: TPressEvent);
begin
  inherited;
  {$IFDEF PressViewNotification}
  if AEvent is TPressMVPViewDrawItemEvent then
    with TPressMVPViewDrawItemEvent(AEvent) do
      DrawItem(Owner, Canvas, ItemIndex, Rect, State);
  {$ENDIF}
end;

{ TPressMVPDrawGridInteractor }

class function TPressMVPDrawGridInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := APresenter.View is TPressMVPGridView;
end;

procedure TPressMVPDrawGridInteractor.DrawCell(
  Sender: TPressMVPGridView; ACanvas: TCanvas;
  ACol, ARow: Integer; ARect: TRect; State: TGridDrawState);
var
  VAlignment: TAlignment;
  VText: string;
begin
  if ACol = -1 then
  begin
    if (ARow = -1) or (Owner.Model.Count = 0) then
      VText := ''
    else
      VText := InttoStr(ARow + 1);
    VAlignment := taRightJustify;
  end else if ARow = -1 then
    with Owner.Model.ColumnData[ACol] do
    begin
      VText := HeaderCaption;
      VAlignment := HeaderAlignment;
    end
  else
  begin
    VText := Owner.Model.DisplayText(ACol, ARow);
    VAlignment := Owner.Model.TextAlignment(ACol);
  end;
  DrawTextRect(ACanvas, ARect, VText, VAlignment);
end;

procedure TPressMVPDrawGridInteractor.InitInteractor;
begin
  inherited;
  {$IFDEF PressViewNotification}
  Notifier.AddNotificationItem(Owner.View, [TPressMVPViewDrawCellEvent]);
  {$ELSE}{$IFDEF PressViewDirectEvent}
  (Owner.View as TPressMVPGridView).OnDrawCell := DrawCell;
  {$ENDIF}{$ENDIF}
end;

procedure TPressMVPDrawGridInteractor.Notify(AEvent: TPressEvent);
begin
  inherited;
  {$IFDEF PressViewNotification}
  if AEvent is TPressMVPViewDrawCellEvent then
    with TPressMVPViewDrawCellEvent(AEvent) do
      DrawCell(Owner, Canvas, Col, Row, Rect, State);
  {$ENDIF}
end;

{ TPressMVPSelectItemInteractor }

function TPressMVPSelectItemInteractor.GetOwner: TPressMVPItemsPresenter;
begin
  Result := inherited Owner as TPressMVPItemsPresenter;
end;

procedure TPressMVPSelectItemInteractor.InitInteractor;
begin
  inherited;
  Notifier.AddNotificationItem(Owner.Model.Selection,
   [TPressMVPSelectionChangedEvent]);
  Notifier.AddNotificationItem(Owner.Model,
   [TPressMVPModelUpdateSelectionEvent]);
end;

procedure TPressMVPSelectItemInteractor.Notify(AEvent: TPressEvent);
begin
  inherited;
  if AEvent is TPressMVPSelectionChangedEvent then
  begin
    Notifier.DisableEvents;
    try
      with Owner.Model.Selection.CreateIterator do
      try
        BeforeFirstItem;
        while NextItem do
          { TODO : SelectItem method clear the selection }
          { TODO : The selection is updated before the View, so this
            assignment might raise 'index out of bounds' exception }
          Owner.View.SelectItem(Owner.Model.IndexOf(CurrentItem));
      finally
        Free;
      end;
    finally
      Notifier.EnableEvents;
    end
  end else if AEvent is TPressMVPModelUpdateSelectionEvent then
    SelectItem(Min(Owner.View.CurrentItem, Owner.Model.Count-1));
end;

procedure TPressMVPSelectItemInteractor.SelectItem(AIndex: Integer);
begin
  if Owner.Model.Count = 0 then
    Exit;
  Notifier.DisableEvents;
  try
    Owner.Model.SelectIndex(AIndex);
  finally
    Notifier.EnableEvents;
  end;
end;

{ TPressMVPSelectListBoxInteractor }

class function TPressMVPSelectListBoxInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := APresenter.View is TPressMVPListBoxView;
end;

procedure TPressMVPSelectListBoxInteractor.InitInteractor;
begin
  inherited;
  Notifier.AddNotificationItem(Owner.View, [TPressMVPViewClickEvent]);
end;

procedure TPressMVPSelectListBoxInteractor.Notify(AEvent: TPressEvent);
begin
  inherited;
  if AEvent is TPressMVPViewClickEvent then
    SelectItem(Owner.View.CurrentItem);
end;

{ TPressMVPSelectGridInteractor }

class function TPressMVPSelectGridInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := APresenter.View is TPressMVPGridView;
end;

procedure TPressMVPSelectGridInteractor.InitInteractor;
begin
  inherited;
  {$IFDEF PressViewNotification}
  Notifier.AddNotificationItem(Owner.View, [TPressMVPViewSelectCellEvent]);
  {$ELSE}{$IFDEF PressViewDirectEvent}
  (Owner.View as TPressMVPGridView).OnSelectCell := SelectCell;
  {$ENDIF}{$ENDIF}
end;

procedure TPressMVPSelectGridInteractor.Notify(AEvent: TPressEvent);
begin
  inherited;
  {$IFDEF PressViewNotification}
  if AEvent is TPressMVPViewSelectCellEvent then
    with TPressMVPViewSelectCellEvent(AEvent) do
      SelectCell(Owner, Col, Row, CanSelectPtr^)
  {$ENDIF}
end;

procedure TPressMVPSelectGridInteractor.SelectCell(
  Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  SelectItem(ARow);
end;

{ TPressMVPCreateFormInteractor }

procedure TPressMVPCreateFormInteractor.ExecuteFormPresenter(
  AFormPresenterType: TPressMVPFormPresenterType);
var
  VPresenterIndex: Integer;
  VObject: TPressObject;
begin
  if Model.Selection.Count = 1 then
  begin
    VObject := Model.Selection[0];
    VPresenterIndex := PressMVPRegisteredForms.IndexOfObjectClass(
     VObject.ClassType, AFormPresenterType);
    if VPresenterIndex >= 0 then
      RunPresenter(VPresenterIndex, VObject, AFormPresenterType = fpInclude);
  end;
end;

function TPressMVPCreateFormInteractor.GetModel: TPressMVPStructureModel;
begin
  Result := Owner.Model as TPRessMVPStructureModel;
end;

procedure TPressMVPCreateFormInteractor.RunPresenter(
  APresenterIndex: Integer; AObject: TPressObject; AIncluding: Boolean);
var
  VPresenter: TPressMVPFormPresenter;
begin
  VPresenter := PressMVPRegisteredForms[APresenterIndex].
   PresenterClass.Run(Owner.Parent, AObject, AIncluding);
  VPresenter.Model.HookedSubject := Model.Subject;
end;

{ TPressMVPCreateIncludeFormInteractor }

class function TPressMVPCreateIncludeFormInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := APresenter.Model is TPressMVPStructureModel;
end;

procedure TPressMVPCreateIncludeFormInteractor.InitInteractor;
begin
  inherited;
  Notifier.AddNotificationItem(Owner.Model,
   [TPressMVPModelCreateIncludeFormEvent]);
end;

procedure TPressMVPCreateIncludeFormInteractor.Notify(AEvent: TPressEvent);
begin
  inherited;
  ExecuteFormPresenter(fpInclude);
end;

{ TPressMVPCreatePresentFormInteractor }

class function TPressMVPCreatePresentFormInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := APresenter.Model is TPressMVPStructureModel;
end;

procedure TPressMVPCreatePresentFormInteractor.InitInteractor;
begin
  inherited;
  Notifier.AddNotificationItem(Owner.Model,
   [TPressMVPModelCreatePresentFormEvent]);
end;

procedure TPressMVPCreatePresentFormInteractor.Notify(AEvent: TPressEvent);
begin
  inherited;
  TPressMVPModelUpdateDataEvent.Create(Owner.Model).Notify;
  ExecuteFormPresenter(fpPresent);
end;

{ TPressMVPCreateSearchFormInteractor }

class function TPressMVPCreateSearchFormInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := APresenter.Model is TPressMVPReferencesModel;
end;

procedure TPressMVPCreateSearchFormInteractor.ExecuteQueryPresenter;
var
  VPresenterIndex: Integer;
begin
  VPresenterIndex :=
   PressMVPRegisteredForms.IndexOfQueryItemObject(Model.Subject.ObjectClass, fpInclude);
  if VPresenterIndex >= 0 then
    RunPresenter(VPresenterIndex, nil, False);
end;

procedure TPressMVPCreateSearchFormInteractor.InitInteractor;
begin
  inherited;
  Notifier.AddNotificationItem(Owner.Model,
   [TPressMVPModelCreateSearchFormEvent]);
end;

procedure TPressMVPCreateSearchFormInteractor.Notify(AEvent: TPressEvent);
begin
  inherited;
  ExecuteQueryPresenter;
end;

{ TPressMVPCloseFormInteractor }

class function TPressMVPCloseFormInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := (APresenter is TPressMVPFormPresenter) and
   not (APresenter is TPressMVPMainFormPresenter);
end;

function TPressMVPCloseFormInteractor.GetOwner: TPressMVPFormPresenter;
begin
  Result := inherited Owner as TPressMVPFormPresenter;
end;

procedure TPressMVPCloseFormInteractor.InitInteractor;
begin
  inherited;
  Notifier.AddNotificationItem(Owner.View, [TPressMVPViewCloseFormEvent]);
  Notifier.AddNotificationItem(Owner.Model, [TPressMVPModelCloseFormEvent]);
end;

procedure TPressMVPCloseFormInteractor.Notify(AEvent: TPressEvent);
begin
  inherited;
  if Owner.AutoDestroy or not (AEvent is TPressMVPViewCloseFormEvent) then
    TPressMVPFreePresenterEvent.Create(Owner).QueueNotification;
end;

{ TPressMVPFreePresenterInteractor }

class function TPressMVPFreePresenterInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := APresenter is TPressMVPFormPresenter;
end;

procedure TPressMVPFreePresenterInteractor.InitInteractor;
begin
  inherited;
  Notifier.AddNotificationItem(Owner, [TPressMVPFreePresenterEvent]);
end;

procedure TPressMVPFreePresenterInteractor.Notify(AEvent: TPressEvent);
begin
  inherited;
  Owner.Free;
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
begin
  //if Assigned(FParent) then
  //  FParent.BindCommand(ACommandClass, AComponentName);
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
  { TODO : Improve }
  Result := (AModel.ClassType = TPressMVPValueModel) and
   (AView is TPressMVPAttributeView);
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
begin
  Result := InternalUpdateReferences(ASearchString);
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

procedure TPressMVPEnumPresenter.InitPresenter;
begin
  inherited;
  //View.AssignReferences(Model.Subject.Metadata.EnumMetadata.Items);
end;

function TPressMVPEnumPresenter.InternalUpdateReferences(
  const ASearchString: string): Integer;
begin
  View.ClearReferences;
  with Model.CreateEnumValueIterator(ASearchString) do
  try
    Result := Count;
    BeforeFirstItem;
    while NextItem do
      View.AddReference(CurrentItem.EnumName);
  finally
    Free;
  end;
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

function TPressMVPReferencePresenter.InternalUpdateReferences(
  const ASearchString: string): Integer;
begin
  View.ClearReferences;
  with Model.CreateQueryIterator(ASearchString) do
  try
    Result := Count;
    BeforeFirstItem;
    while NextItem do
      View.AddReference(
       Model.ReferencedValue(CurrentItem.Instance).DisplayText);
  finally
    Free;
  end;
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

function TPressMVPFormPresenter.CreateSubPresenter(
  const AAttributeName, AControlName: ShortString;
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

function TPressMVPFormPresenter.CreateSubPresenter(
  const AAttributeName, AControlName: ShortString;
  const ADisplayNames: string;
  AModelClass: TPressMVPModelClass;
  AViewClass: TPressMVPViewClass;
  APresenterClass: TPressMVPPresenterClass): TPressMVPPresenter;
var
  VAttribute: TPressAttribute;
begin
  Result := CreateSubPresenter(
   AAttributeName, AControlName, AModelClass, AViewClass, APresenterClass);
  if Result.Model is TPressMVPStructureModel then
    TPressMVPStructureModel(Result.Model).AssignDisplayNames(ADisplayNames)
  else if ADisplayNames <> '' then
  begin
    VAttribute := Result.Model.Subject as TPressAttribute;
    raise EPressMVPError.CreateFmt(SUnsupportedDisplayName,
     [VAttribute.ClassName, VAttribute.Owner.ClassName, VAttribute.Name]);
  end;
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
  AFormPresenterType: TPressMVPFormPresenterType);
begin
  PressMVPRegisteredForms.Add(
   TPressMVPRegisteredForm.Create(
   Self, AObjectClass, AFormClass, AFormPresenterType));
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
begin
  VIndex := PressMVPRegisteredForms.IndexOfPresenterClass(Self);
  if VIndex >= 0 then
  begin
    VFormClass := PressMVPRegisteredForms[VIndex].FormClass;
    VObjectClass := PressMVPRegisteredForms[VIndex].ObjectClass;
  end else
    raise EPressError.CreateFmt(SClassNotFound, [ClassName]);
  VObjectIsMissing := not Assigned(AObject);
  if VObjectIsMissing then
  begin
    AObject := VObjectClass.Create;
    AIncluding := True;
  end;

  { TODO : Catch memory leakage when an exception is raised }
  VModelClass := InternalModelClass;
  if Assigned(VModelClass) then
    VModel := VModelClass.Create(AParent.Model, AObject)
  else
    VModel := TPressMVPModel.CreateFromSubject(
     AParent.Model, AObject) as TPressMVPObjectModel;
  VModel.IsIncluding := AIncluding;
  if VObjectIsMissing then
    AObject.Release;

  VViewClass := InternalViewClass;
  if Assigned(VViewClass) then
    VView := VViewClass.Create(VFormClass.Create(nil), True)
  else
    VView := TPressMVPView.CreateFromControl(
     VFormClass.Create(nil), True) as TPressMVPCustomFormView;

  if not Assigned(AParent) then
    AParent := PressMainPresenter;
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
  VModelClass: TPressMVPModelClass;
  VModel: TPressMVPModel;
  VView: TPressMVPView;
  VSubject: TPressObject;
  VIndex: Integer;
begin
  if not Assigned(Application) or not Assigned(Application.MainForm) then
    raise EPressError.Create(SUnassignedMainForm);
  VModelClass := InternalModelClass;
  if not Assigned(VModelClass) then
    VModelClass := TPressMVPQueryModel;

  VSubject := nil;
  VIndex := PressMVPRegisteredForms.IndexOfPresenterClass(
   TPressMVPFormPresenterClass(ClassType));
  if VIndex >= 0 then
    with PressMVPRegisteredForms[VIndex] do
      if Assigned(ObjectClass) then
        VSubject := ObjectClass.Create;

  VModel := VModelClass.Create(nil, VSubject);
  if Assigned(VSubject) then
    VSubject.Release;
  VView := TPressMVPView.CreateFromControl(Application.MainForm);
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
begin
  if not Assigned(Application.MainForm) then
  begin
    VIndex := PressMVPRegisteredForms.IndexOfPresenterClass(Self);
    if VIndex >= 0 then
      Application.CreateForm(PressMVPRegisteredForms[VIndex].FormClass, VRef)
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

{ TPressMVPRegisteredForm }

constructor TPressMVPRegisteredForm.Create(
  APresenterClass: TPressMVPFormPresenterClass;
  AObjectClass: TPressObjectClass; AFormClass: TFormClass;
  AFormPresenterType: TPressMVPFormPresenterType);
begin
  inherited Create;
  FPresenterClass := APresenterClass;
  FObjectClass := AObjectClass;
  FFormClass := AFormClass;
  FFormPresenterType := AFormPresenterType;
end;

{ TPressMVPRegisteredFormList }

function TPressMVPRegisteredFormList.Add(
  AObject: TPressMVPRegisteredForm): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressMVPRegisteredFormList.CreateIterator: TPressMVPRegisteredFormIterator;
begin
  Result := TPressMVPRegisteredFormIterator.Create(Self);
end;

function TPressMVPRegisteredFormList.GetItems(
  AIndex: Integer): TPressMVPRegisteredForm;
begin
  Result := inherited Items[AIndex] as TPressMVPRegisteredForm;
end;

function TPressMVPRegisteredFormList.IndexOf(
  AObject: TPressMVPRegisteredForm): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

function TPressMVPRegisteredFormList.IndexOfObjectClass(
  AObjectClass: TPressObjectClass;
  AFormPresenterType: TPressMVPFormPresenterType): Integer;
begin
  for Result := 0 to Pred(Count) do
    with Items[Result] do
      if (ObjectClass = AObjectClass) and
       (FormPresenterType in [AFormPresenterType, fpIncludePresent]) then
        Exit;
  { TODO : Notify ambiguous presenter class }
  Result := -1;
end;

function TPressMVPRegisteredFormList.IndexOfPresenterClass(
  APresenterClass: TPressMVPFormPresenterClass): Integer;
begin
  for Result := 0 to Pred(Count) do
    if Items[Result].PresenterClass = APresenterClass then
      Exit;
  Result := -1;
end;

function TPressMVPRegisteredFormList.IndexOfQueryItemObject(
  AObjectClass: TPressObjectClass;
  AFormPresenterType: TPressMVPFormPresenterType): Integer;

  function Match(ARegForm: TPressMVPRegisteredForm): Boolean;
  begin
    Result := Assigned(ARegForm.ObjectClass) and
     (ARegForm.ObjectClass.InheritsFrom(TPressQuery)) and
     (ARegForm.FormPresenterType in [AFormPresenterType, fpIncludePresent]) and
     (TPressQueryClass(ARegForm.ObjectClass).ClassMetadata.ItemObjectClass =
      AObjectClass);
  end;

begin
  for Result := 0 to Pred(Count) do
    if Match(Items[Result]) then
      Exit;
  Result := -1;
end;

procedure TPressMVPRegisteredFormList.Insert(Index: Integer;
  AObject: TPressMVPRegisteredForm);
begin
  inherited Insert(Index, AObject);
end;

function TPressMVPRegisteredFormList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressMVPRegisteredFormList.Remove(
  AObject: TPressMVPRegisteredForm): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressMVPRegisteredFormList.SetItems(AIndex: Integer;
  const Value: TPressMVPRegisteredForm);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressMVPRegisteredFormIterator }

function TPressMVPRegisteredFormIterator.GetCurrentItem: TPressMVPRegisteredForm;
begin
  Result := inherited CurrentItem as TPressMVPRegisteredForm;
end;

procedure RegisterInteractors;
begin
  TPressMVPNextControlInteractor.RegisterInteractor;
  TPressMVPUpdateComboInteractor.RegisterInteractor;
  TPressMVPOpenComboInteractor.RegisterInteractor;
  TPressMVPChangeModelInteractor.RegisterInteractor;
  TPressMVPEditUpdaterInteractor.RegisterInteractor;
  TPressMVPEnumUpdaterInteractor.RegisterInteractor;
  TPressMVPDateTimeUpdaterInteractor.RegisterInteractor;
  TPressMVPReferenceUpdaterInteractor.RegisterInteractor;
  TPressMVPBooleanUpdaterInteractor.RegisterInteractor;
  TPressMVPDblClickSelectableInteractor.RegisterInteractor;
  TPressMVPEditableInteractor.RegisterInteractor;
  TPressMVPIntegerInteractor.RegisterInteractor;
  TPressMVPFloatInteractor.RegisterInteractor;
  TPressMVPDateTimeInteractor.RegisterInteractor;
  TPressMVPDrawListBoxInteractor.RegisterInteractor;
  TPressMVPDrawGridInteractor.RegisterInteractor;
  TPressMVPSelectListBoxInteractor.RegisterInteractor;
  TPressMVPSelectGridInteractor.RegisterInteractor;
  TPressMVPCreateIncludeFormInteractor.RegisterInteractor;
  TPressMVPCreatePresentFormInteractor.RegisterInteractor;
  TPressMVPCreateSearchFormInteractor.RegisterInteractor;
  TPressMVPCloseFormInteractor.RegisterInteractor;
  TPressMVPFreePresenterInteractor.RegisterInteractor;
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
  RegisterInteractors;
  RegisterPresenters;

end.
