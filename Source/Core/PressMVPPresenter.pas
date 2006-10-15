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
  TPressMVPValuePresenter = class;
  TPressMVPItemPresenter = class;
  TPressMVPItemsPresenter = class;
  TPressMVPFormPresenter = class;

  TPressMVPFormPresenterType = (fpInclude, fpPresent, fpIncludePresent, fpRegister);

  { TPressMVPInteractors }

  TPressMVPNextControlInteractor = class(TPressMVPInteractor)
  protected
    procedure DoPressEnter; virtual;
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPUpdateComboInteractor = class(TPressMVPNextControlInteractor)
  private
    function GetOwner: TPressMVPItemPresenter;
    function GetView: TPressMVPComboBoxView;
  protected
    procedure DoPressEnter; override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
    property Owner: TPressMVPItemPresenter read GetOwner;
    property View: TPressMVPComboBoxView read GetView;
  end;

  TPressMVPOpenComboInteractor = class(TPressMVPInteractor)
  private
    function GetOwner: TPressMVPItemPresenter;
  protected
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
    property Owner: TPressMVPItemPresenter read GetOwner;
  end;

  TPressMVPChangeModelInteractor = class(TPressMVPInteractor)
  protected
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPExitUpdatableInteractor = class(TPressMVPInteractor)
  protected
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPClickUpdatableInteractor = class(TPressMVPInteractor)
  protected
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
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
    procedure ExecuteObjectPresenter(AFormPresenterType: TPressMVPFormPresenterType);
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

  TPressMVPValuePresenter = class(TPressMVPPresenter)
  private
    function GetModel: TPressMVPValueModel;
    function GetView: TPressMVPAttributeView;
  protected
    procedure InitPresenter; override;
    procedure InternalUpdateModel; override;
    procedure InternalUpdateView; override;
  public
    class function Apply(AModel: TPressMVPModel; AView: TPressMVPView): Boolean; override;
    property Model: TPressMVPValueModel read GetModel;
    property View: TPressMVPAttributeView read GetView;
  end;

  TPressMVPItemPresenter = class(TPressMVPPresenter)
  private
    FDisplayNames: string;
    FDisplayNameList: TStrings;
    function DisplayValueAttribute: TPressValue;
    function GetDisplayNameList: TStrings;
    function GetModel: TPressMVPReferenceModel;
    function GetView: TPressMVPItemView;
    procedure SetDisplayNames(const Value: string);
  protected
    procedure InitPresenter; override;
    procedure InternalUpdateModel; override;
    procedure InternalUpdateView; override;
    property DisplayNameList: TStrings read GetDisplayNameList;
  public
    destructor Destroy; override;
    class function Apply(AModel: TPressMVPModel; AView: TPressMVPView): Boolean; override;
    procedure UpdateReferences(const ASearchString: string);
    property DisplayNames: string read FDisplayNames write SetDisplayNames;
    property Model: TPressMVPReferenceModel read GetModel;
    property View: TPressMVPItemView read GetView;
  end;

  TPressMVPItemsPresenter = class(TPressMVPPresenter)
  private
    FDisplayNames: string;
    FDisplayNameList: TStrings;
    function GetDisplayNameList: TStrings;
    function GetModel: TPressMVPItemsModel;
    function GetView: TPressMVPItemsView;
    procedure ParseDisplayNameList;
    procedure SetDisplayNames(const Value: string);
  protected
    procedure InternalUpdateModel; override;
    procedure InternalUpdateView; override;
    property DisplayNameList: TStrings read GetDisplayNameList;
  public
    destructor Destroy; override;
    class function Apply(AModel: TPressMVPModel; AView: TPressMVPView): Boolean; override;
    function DisplayHeader(ACol: Integer): string;
    function HeaderAlignment(ACol: Integer): TAlignment;
    property DisplayNames: string read FDisplayNames write SetDisplayNames;
    property Model: TPressMVPItemsModel read GetModel;
    property View: TPressMVPItemsView read GetView;
  end;

  TPressMVPFormPresenterClass = class of TPressMVPFormPresenter;

  TPressMVPFormPresenter = class(TPressMVPPresenter)
  private
    FAutoDestroy: Boolean;
    function GetModel: TPressMVPObjectModel;
    function GetView: TPressMVPFormView;
  protected
    function AttributeByName(const AAttributeName: ShortString): TPressAttribute;
    function CreateSubPresenter(const AAttributeName, AControlName: ShortString; AModelClass: TPressMVPModelClass = nil; AViewClass: TPressMVPViewClass = nil; APresenterClass: TPressMVPPresenterClass = nil): TPressMVPPresenter; overload;
    function CreateSubPresenter(const AAttributeName, AControlName: ShortString; const ADisplayNames: string; AModelClass: TPressMVPModelClass = nil; AViewClass: TPressMVPViewClass = nil; APresenterClass: TPressMVPPresenterClass = nil): TPressMVPPresenter; overload;
    procedure InitPresenter; override;
    function InternalFindComponent(const AComponentName: string): TComponent; override;
    class function InternalModelClass: TPressMVPObjectModelClass; virtual;
    class function InternalViewClass: TPressMVPCustomFormViewClass; virtual;
    procedure InternalUpdateModel; override;
    procedure InternalUpdateView; override;
    procedure Running; virtual;
  public
    class function Apply(AModel: TPressMVPModel; AView: TPressMVPView): Boolean; override;
    class procedure RegisterFormPresenter(AObjectClass: TPressObjectClass; AFormClass: TFormClass; AFormPresenterType: TPressMVPFormPresenterType = fpIncludePresent);
    class function Run(AObject: TPressObject = nil; AIncluding: Boolean = False; AAutoDestroy: Boolean = True): TPressMVPFormPresenter; overload;
    class function Run(AOwner: TPressMVPPresenter; AObject: TPressObject = nil; AIncluding: Boolean = False; AAutoDestroy: Boolean = True): TPressMVPFormPresenter; overload;
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
    FOnIdle: TIdleEvent;
    FAppRunning: Boolean;
  protected
    procedure Idle(Sender: TObject; var Done: Boolean);
    procedure InitPresenter; override;
  public
    constructor Create; reintroduce; virtual;
    class procedure Run;
    procedure ShutDown;
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
  {$IFDEF PressLog}PressLog,{$ENDIF}
  PressConsts,
  PressQuery,
  PressMVPCommand;

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
  if Owner.View is TPressMVPWinView then
    TPressMVPWinView(Owner.View).SelectNext;

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
  Result := (APresenter is TPressMVPItemPresenter) and
   (APresenter.View is TPressMVPComboBoxView);
end;

procedure TPressMVPUpdateComboInteractor.DoPressEnter;
begin
  if (Owner.View.AsString = '') or
   (View.DroppedDown and (View.CurrentItem >= 0)) then
    inherited
  else if View.Changed then
  begin
    Owner.UpdateReferences(Owner.View.AsString);
    case Owner.Model.Query.Count of
      0: View.SelectAll;
      1: inherited;
      else View.ShowReferences;
    end;
  end else
    inherited;
end;

function TPressMVPUpdateComboInteractor.GetOwner: TPressMVPItemPresenter;
begin
  Result := inherited Owner as TPressMVPItemPresenter;
end;

function TPressMVPUpdateComboInteractor.GetView: TPressMVPComboBoxView;
begin
  Result := inherited Owner.View as TPressMVPComboBoxView;
end;

{ TPressMVPOpenComboInteractor }

class function TPressMVPOpenComboInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := APresenter is TPressMVPItemPresenter;
end;

function TPressMVPOpenComboInteractor.GetOwner: TPressMVPItemPresenter;
begin
  Result := inherited Owner as TPressMVPItemPresenter;
end;

procedure TPressMVPOpenComboInteractor.InitInteractor;
begin
  inherited;
  Notifier.AddNotificationItem(Owner.View, [TPressMVPViewDropDownEvent]);
end;

procedure TPressMVPOpenComboInteractor.Notify(AEvent: TPressEvent);
begin
  inherited;
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
  VPresenter: TPressMVPPresenter;
  VObjectModel: TPressMVPObjectModel;
begin
  inherited;
  if (AEvent is TPressMVPViewEnterEvent) or
   (AEvent is TPressMVPViewExitEvent) then
  begin
    VPresenter := Owner;
    while Assigned(VPresenter) and not (VPresenter is TPressMVPFormPresenter) do
      VPresenter := VPresenter.Parent;
    { TODO : "ParentForm: TPressMVPFormPresenter" property }
    if VPresenter is TPressMVPFormPresenter then
    begin
      VObjectModel := TPressMVPFormPresenter(VPresenter).Model;
      if AEvent is TPressMVPViewEnterEvent then
      begin
        VObjectModel.Selection.SelectObject(Owner.Model);
        Owner.UpdateView;
      end else
        VObjectModel.Selection.SelectObject(nil);
    end;
  end;
end;

{ TPressMVPExitUpdatableInteractor }

class function TPressMVPExitUpdatableInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := (APresenter is TPressMVPValuePresenter) or
   (APresenter is TPressMVPItemPresenter);
end;

procedure TPressMVPExitUpdatableInteractor.InitInteractor;
begin
  inherited;
  Notifier.AddNotificationItem(Owner.View, [TPressMVPViewExitEvent]);
  Notifier.AddNotificationItem(Owner.Model, [TPressMVPModelUpdateDataEvent]);
end;

procedure TPressMVPExitUpdatableInteractor.Notify(AEvent: TPressEvent);
begin
  inherited;
  try
    try
      Owner.UpdateModel;
    except
      on E: Exception do
        if (AEvent is TPressMVPViewExitEvent) or not (E is EPressError) then
          raise;
    end;
    Owner.UpdateView;
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

{ TPressMVPClickUpdatableInteractor }

class function TPressMVPClickUpdatableInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := APresenter.View is TPressMVPCheckBoxView;
end;

procedure TPressMVPClickUpdatableInteractor.InitInteractor;
begin
  inherited;
  Notifier.AddNotificationItem(Owner.View, [TPressMVPViewClickEvent]);
end;

procedure TPressMVPClickUpdatableInteractor.Notify(AEvent: TPressEvent);
begin
  inherited;
  Owner.UpdateModel;
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
  begin
    VText := Owner.DisplayHeader(ACol);
    VAlignment := Owner.HeaderAlignment(ACol);
  end else
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

procedure TPressMVPCreateFormInteractor.ExecuteObjectPresenter(
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
  ExecuteObjectPresenter(fpInclude);
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
  ExecuteObjectPresenter(fpPresent);
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
  Result := APresenter is TPressMVPFormPresenter;
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
    with TPressMVPFreePresenterEvent.Create(Owner) do
      if Owner is TPressMVPMainFormPresenter then
        Notify
      else
        QueueNotification;
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

{ TPressMVPValuePresenter }

class function TPressMVPValuePresenter.Apply(AModel: TPressMVPModel;
  AView: TPressMVPView): Boolean;
begin
  Result := (AModel is TPressMVPValueModel) and
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

  { TODO : Just a work around -- need to fix this approach }
  if (Model.Subject is TPressEnum) and (View is TPressMVPComboBoxView) then
  begin
    TPressMVPComboBoxView(View).ComboStyle := csDropDownList;
    TPressMVPComboBoxView(View).Control.Items.Assign(
     Model.Subject.Metadata.EnumMetadata.Items);
  end;
end;

procedure TPressMVPValuePresenter.InternalUpdateModel;
begin
  View.UpdateModel(Model.Subject);
end;

procedure TPressMVPValuePresenter.InternalUpdateView;
begin
  View.UpdateView(Model.Subject);
end;

{ TPressMVPItemPresenter }

class function TPressMVPItemPresenter.Apply(AModel: TPressMVPModel;
  AView: TPressMVPView): Boolean;
begin
  Result := (AModel is TPressMVPReferenceModel) and (AView is TPressMVPItemView);
end;

destructor TPressMVPItemPresenter.Destroy;
begin
  FDisplayNameList.Free;
  inherited;
end;

function TPressMVPItemPresenter.DisplayValueAttribute: TPressValue;
var
  VSubject: TPressObject;
  VAttributeName: string;
  VAttribute: TPressAttribute;
begin
  if DisplayNameList.Count = 0 then
    raise EPressMVPError.CreateFmt(SDisplayNameMissing,
     [View.Control.ClassName, View.Control.Name]);

  VSubject := Model.Subject.Value;
  VAttributeName := DisplayNameList[0];
  if Assigned(VSubject) then
    VAttribute := VSubject.FindPathAttribute(VAttributeName)
  else
    { TODO : Check AttributeName into metadata }
    VAttribute := nil;

  if Assigned(VSubject) and not Assigned(VAttribute) then
    raise EPressMVPError.CreateFmt(SAttributeNotFound,
     [VSubject.ClassName, VAttributeName]);

  if Assigned(VAttribute) and not (VAttribute is TPressValue) then
    raise EPressMVPError.CreateFmt(SInvalidAttributeType,
     [VAttributeName, VAttribute.ClassName]);

  Result := TPressValue(VAttribute);
end;

function TPressMVPItemPresenter.GetDisplayNameList: TStrings;
begin
  if not Assigned(FDisplayNameList) then
    FDisplayNameList := TStringList.Create;
  Result := FDisplayNameList;
end;

function TPressMVPItemPresenter.GetModel: TPressMVPReferenceModel;
begin
  Result := inherited Model as TPressMVPReferenceModel;
end;

function TPressMVPItemPresenter.GetView: TPressMVPItemView;
begin
  Result := inherited View as TPressMVPItemView;
end;

procedure TPressMVPItemPresenter.InitPresenter;
begin
  inherited;
  { TODO : Set View.Size }
end;

procedure TPressMVPItemPresenter.InternalUpdateModel;
begin
  View.UpdateModel(Model.Subject);
end;

procedure TPressMVPItemPresenter.InternalUpdateView;
begin
  View.UpdateView(DisplayValueAttribute);
end;

procedure TPressMVPItemPresenter.SetDisplayNames(const Value: string);
begin
  if FDisplayNames <> Value then
  begin
    FDisplayNames := Value;
    DisplayNameList.Text := StringReplace(
     Value, SPressFieldDelimiter, SPressLineBreak, [rfReplaceAll]);
    { TODO : Check if the attributes exist }
  end;
end;

procedure TPressMVPItemPresenter.UpdateReferences(const ASearchString: string);
var
  VCaption: string;
  VObject: TPressObject;
  VDisplayName: string;
begin
  if DisplayNameList.Count > 0 then
    VDisplayName := DisplayNameList[0]
  else
    raise EPressError.CreateFmt(SDisplayNameMissing,
     [View.Control.ClassName, View.Control.Name]);
  { TODO : VDisplayName need to be the persistent name
    Look for the persistent name into the metadata }
  Model.UpdateQuery(VDisplayName, ASearchString);
  View.ClearReferences;
  if Model.Query.Count > SPressMaxItemCount then
    View.AddReference(Format(SItemCountOverflow, [Model.Query.Count]), nil)
  else
    with Model.CreateQueryIterator do
      try
        while not IsDone do
        begin
          VObject := CurrentItem.Instance;
          VCaption := VObject.AttributeByName(VDisplayName).DisplayText;
          View.AddReference(VCaption, VObject);
          Next;
        end;
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

destructor TPressMVPItemsPresenter.Destroy;
begin
  FDisplayNameList.Free;
  inherited;
end;

function TPressMVPItemsPresenter.DisplayHeader(ACol: Integer): string;
begin
  { TODO : read from metadata or via CreateSubPresenter parameter }
  if FDisplayNames <> '' then
    Result := Format('- %d -', [ACol + 1])
  else
    Result := '';
end;

function TPressMVPItemsPresenter.GetDisplayNameList: TStrings;
begin
  if not Assigned(FDisplayNameList) then
    FDisplayNameList := TStringList.Create;
  Result := FDisplayNameList;
end;

function TPressMVPItemsPresenter.GetModel: TPressMVPItemsModel;
begin
  Result := inherited Model as TPressMVPItemsModel;
end;

function TPressMVPItemsPresenter.GetView: TPressMVPItemsView;
begin
  Result := inherited View as TPressMVPItemsView;
end;

function TPressMVPItemsPresenter.HeaderAlignment(ACol: Integer): TAlignment;
begin
  { TODO : Improve }
  Result := taCenter;
end;

procedure TPressMVPItemsPresenter.InternalUpdateModel;
begin
end;

procedure TPressMVPItemsPresenter.InternalUpdateView;
begin
  View.RowCount := Model.Count;
  View.UpdateView(Model.Subject);
end;

procedure TPressMVPItemsPresenter.ParseDisplayNameList;
var
  VPos1, VPos2: Integer;
  VName: string;
  VWidth: Integer;
  I: Integer;
begin
  View.SetColumnCount(DisplayNameList.Count);
  for I := 0 to Pred(DisplayNameList.Count) do
  begin
    VName := DisplayNameList[I];
    VWidth := 64;
    VPos1 := Pos(SPressBrackets[1], VName);
    if VPos1 > 0 then
    begin
      VPos2 := Pos(SPressBrackets[2], VName);
      if VPos2 > VPos1 then
      begin
        try
          VWidth := StrtoInt(Copy(VName, VPos1 + 1, VPos2 - VPos1 - 1));
        except
          on E: EConvertError do
            VWidth := 64;
          else
            raise;
        end;
        if VWidth < 16 then
          VWidth := 16;
        DisplayNameList[I] := Copy(VName, 1, VPos1 - 1);
      end;
    end;
    View.SetColumnWidth(I, VWidth);
  end;
  View.AlignColumns;
end;

procedure TPressMVPItemsPresenter.SetDisplayNames(const Value: string);
begin
  if FDisplayNames <> Value then
  begin
    FDisplayNames := Value;
    DisplayNameList.Text := StringReplace(
     Value, SPressFieldDelimiter, SPressLineBreak, [rfReplaceAll]);
    ParseDisplayNameList;
    { TODO : Check if the attributes exist }
    Model.DisplayNames := DisplayNameList.Text;
  end;
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
  VControl := ControlByName(AControlName);
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
  if Result is TPressMVPItemPresenter then
    TPressMVPItemPresenter(Result).DisplayNames := ADisplayNames
  else if Result is TPressMVPItemsPresenter then
    TPressMVPItemsPresenter(Result).DisplayNames := ADisplayNames
  else if ADisplayNames <> '' then
  begin
    VAttribute := Result.Model.Subject as TPressAttribute;
    raise EPressMVPError.CreateFmt(SUnsupportedDisplayName,
     [VAttribute.ClassName, VAttribute.Owner.ClassName, VAttribute.Name]);
  end;
end;

function TPressMVPFormPresenter.GetModel: TPressMVPObjectModel;
begin
  Result := inherited Model as TPressMVPObjectModel;
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

function TPressMVPFormPresenter.InternalFindComponent(
  const AComponentName: string): TComponent;
var
  VComponent: PComponent;
begin
  VComponent := View.Control.FieldAddress(AComponentName);
  if Assigned(VComponent) then
    Result := VComponent^
  else
    Result := nil;
end;

class function TPressMVPFormPresenter.InternalModelClass: TPressMVPObjectModelClass;
begin
  Result := nil;
end;

procedure TPressMVPFormPresenter.InternalUpdateModel;
begin
end;

procedure TPressMVPFormPresenter.InternalUpdateView;
begin
end;

class function TPressMVPFormPresenter.InternalViewClass: TPressMVPCustomFormViewClass;
begin
  Result := nil;
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
  AOwner: TPressMVPPresenter; AObject: TPressObject; AIncluding: Boolean;
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
    VModel := VModelClass.Create(AOwner.Model, AObject)
  else
    VModel := TPressMVPModel.CreateFromSubject(
     AOwner.Model, AObject) as TPressMVPObjectModel;
  VModel.IsIncluding := AIncluding;
  if VObjectIsMissing then
    AObject.Release;

  VViewClass := InternalViewClass;
  if Assigned(VViewClass) then
    VView := VViewClass.Create(VFormClass.Create(nil), True)
  else
    VView := TPressMVPView.CreateFromControl(
     VFormClass.Create(nil), True) as TPressMVPCustomFormView;

  if not Assigned(AOwner) then
    AOwner := PressMainPresenter;
  Result := Create(AOwner, VModel, VView);
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
end;

procedure TPressMVPMainFormPresenter.Idle(
  Sender: TObject; var Done: Boolean);
begin
  {$IFDEF PressLogIdle}PressLogMsg(Self, 'Idle', [Sender]);{$ENDIF}
  if not FAppRunning then
  begin
    FAppRunning := True;
    Running;
  end;
  PressProcessEventQueue;
  if Assigned(FOnIdle) then
    FOnIdle(Sender, Done);
end;

procedure TPressMVPMainFormPresenter.InitPresenter;
begin
  inherited;
  FAutoDestroy := False;
  FOnIdle := Application.OnIdle;
  Application.OnIdle := Idle;
end;

class procedure TPressMVPMainFormPresenter.Run;
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
  try
    Application.Run;
  finally
    _PressMVPMainPresenter.Free;
  end;
end;

procedure TPressMVPMainFormPresenter.ShutDown;
begin
  { TODO : Finalize instances }
  Application.Terminate;
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
    Result := (ARegForm.ObjectClass.InheritsFrom(TPressQuery)) and
     (ARegForm.FormPresenterType in [AFormPresenterType, fpIncludePresent]) and
     (TPressQueryClass(ARegForm.ObjectClass).ClassMetadata.ItemObjectClassName =
      AObjectClass.ClassName);
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
  TPressMVPExitUpdatableInteractor.RegisterInteractor;
  TPressMVPClickUpdatableInteractor.RegisterInteractor;
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
  TPressMVPItemsPresenter.RegisterPresenter;
  TPressMVPItemPresenter.RegisterPresenter;
  TPressMVPFormPresenter.RegisterPresenter;
  TPressMVPQueryPresenter.RegisterPresenter;
end;

initialization
  RegisterInteractors;
  RegisterPresenters;

end.
