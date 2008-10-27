(*
  PressObjects, MVP-Interactor Classes
  Copyright (C) 2006-2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressMVPInteractor;

{$I Press.inc}

interface

uses
  PressNotifier,
  PressSubject,
  PressAttributes,
  PressMVP,
  PressMVPModel,
  PressMVPView,
  PressMVPPresenter;

type
  TPressMVPNextControlInteractor = class(TPressMVPInteractor)
  private
    FWinView: IPressMVPWinView;
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
    FComboBoxView: IPressMVPComboBoxView;
  protected
    procedure DoPressEnter; override;
    procedure InitInteractor; override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPOpenComboInteractor = class(TPressMVPInteractor)
  private
    FItemView: IPressMVPItemView;
  protected
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
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
    FWinView: IPressMVPWinView;
  protected
    procedure DoUpdateModel;
    procedure InitInteractor; override;
    procedure InternalUpdateModel; virtual; abstract;
    procedure Notify(AEvent: TPressEvent); override;
  end;

  TPressMVPExitUpdaterInteractor = class(TPressMVPUpdaterInteractor)
  protected
    procedure InitInteractor; override;
  end;

  TPressMVPEditUpdaterInteractor = class(TPressMVPExitUpdaterInteractor)
  private
    FEditView: IPressMVPEditView;
  protected
    procedure InitInteractor; override;
    procedure InternalUpdateModel; override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPDateTimeUpdaterInteractor = class(TPressMVPExitUpdaterInteractor)
  private
    FDateTimeView: IPressMVPDateTimeView;
  protected
    procedure InitInteractor; override;
    procedure InternalUpdateModel; override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPPointerUpdaterInteractor = class(TPressMVPExitUpdaterInteractor)
  private
    FAttrView: IPressMVPAttributeView;
  protected
    procedure InitInteractor; override;
    procedure InternalAssignSubject(VIndex: Integer); virtual; abstract;
    function InternalReferenceCount: Integer; virtual; abstract;
    procedure InternalUpdateModel; override;
  end;

  TPressMVPEnumUpdaterInteractor = class(TPressMVPPointerUpdaterInteractor)
  protected
    procedure InternalAssignSubject(VIndex: Integer); override;
    function InternalReferenceCount: Integer; override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPReferenceUpdaterInteractor = class(TPressMVPPointerUpdaterInteractor)
  protected
    procedure InternalAssignSubject(VIndex: Integer); override;
    function InternalReferenceCount: Integer; override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPClickUpdaterInteractor = class(TPressMVPUpdaterInteractor)
  protected
    procedure InitInteractor; override;
  end;

  TPressMVPBooleanUpdaterInteractor = class(TPressMVPClickUpdaterInteractor)
  private
    FBooleanView: IPressMVPBooleanView;
  protected
    procedure InitInteractor; override;
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
  protected
    procedure InitInteractor; override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPNumericInteractor = class(TPressMVPEditableInteractor)
  private
    FAcceptDecimal: Boolean;
    FAcceptNegative: Boolean;
    FAttrView: IPressMVPAttributeView;
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

  TPressMVPCustomDrawInteractor = class(TPressMVPInteractor)
  protected
    procedure DrawTextRect(ACanvasHandle: TObject; ARect: TPressRect; AMargin: Integer; const AText: string; AAlignment: TPressAlignment);
  end;

  TPressMVPDrawItemInteractor = class(TPressMVPCustomDrawInteractor)
  private
    function GetOwner: TPressMVPReferencePresenter;
  public
    property Owner: TPressMVPReferencePresenter read GetOwner;
  end;

  TPressMVPDrawComboBoxInteractor = class(TPressMVPDrawItemInteractor)
  protected
    procedure DrawItem(ACanvasHandle: TObject; AIndex: Integer; ARect: TPressRect); virtual;
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPDrawItemsInteractor = class(TPressMVPCustomDrawInteractor)
  private
    procedure DrawSelection(ACanvasHandle: TObject; ARect: TPressRect; AStrongSelection: Boolean);
  private
    function GetOwner: TPressMVPItemsPresenter;
  public
    property Owner: TPressMVPItemsPresenter read GetOwner;
  end;

  TPressMVPDrawListBoxInteractor = class(TPressMVPDrawItemsInteractor)
  protected
    procedure DrawItem(ACanvasHandle: TObject; AIndex: Integer; ARect: TPressRect); virtual;
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPDrawGridInteractor = class(TPressMVPDrawItemsInteractor)
  private
    FGridView: IPressMVPGridView;
  protected
    procedure DrawCell(ACanvasHandle: TObject; ACol, ARow: Longint; ARect: TPressRect); virtual;
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPSelectItemInteractor = class(TPressMVPInteractor)
  private
    FItemsView: IPressMVPItemsView;
  protected
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
    procedure SelectItem(AIndex: Integer); virtual;
    procedure UpdateSelectedItem; virtual;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPSortItemsInteractor = class(TPressMVPInteractor)
  protected
    procedure ClickHeader(ACol: Integer); virtual;
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPCreateFormInteractor = class(TPressMVPInteractor)
  private
    function GetModel: TPressMVPStructureModel;
  protected
    procedure ExecuteFormPresenter(AEvent: TPressMVPModelCreateFormEvent; AFormPresenterType: TPressMVPFormPresenterType);
    function RunPresenter(APresenterIndex: Integer; AObject: TPressObject; AIncluding: Boolean): TPressMVPFormPresenter;
  public
    property Model: TPressMVPStructureModel read GetModel;
  end;

  TPressMVPCreateIncludeFormInteractor = class(TPressMVPCreateFormInteractor)
  private
    FAttrView: IPressMVPAttributeView;
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
    procedure ExecuteQueryPresenter(AEvent: TPressMVPModelCreateSearchFormEvent);
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPFormInteractor = class(TPressMVPInteractor)
  private
    function GetOwner: TPressMVPFormPresenter;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
    property Owner: TPressMVPFormPresenter read GetOwner;
  end;

  TPressMVPCleanupFormInteractor = class(TPressMVPFormInteractor)
  protected
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
  end;

  TPressMVPCloseFormInteractor = class(TPressMVPFormInteractor)
  protected
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
  end;

  TPressMVPFreePresenterInteractor = class(TPressMVPInteractor)
  protected
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

implementation

uses
  SysUtils,
  PressConsts,
  PressUtils,
  PressUser,
  PressMVPFactory,
  PressMVPWidget,
  PressMVPCommand;

{ TPressMVPNextControlInteractor }

class function TPressMVPNextControlInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := PressSupports(APresenter.View, IPressMVPWinView);
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
    if (VSelection.Focus is TPressMVPItemsModel) and
     (TPressMVPItemsModel(VSelection.Focus).Subject.Name = SPressQueryItemsString) then
      TPressMVPQueryModel(Owner.Model.Parent).Execute;
  end;

end;

procedure TPressMVPNextControlInteractor.DoSelectNextControl;
begin
  FWinView.SelectNext;
end;

procedure TPressMVPNextControlInteractor.InitInteractor;
begin
  inherited;
  PressAsIntf(Owner.View, IPressMVPWinView, FWinView);
  Notifier.AddNotificationItem(FWinView.Instance, [TPressMVPViewKeyPressEvent]);
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
   PressSupports(APresenter.View, IPressMVPComboBoxView);
end;

procedure TPressMVPUpdateComboInteractor.DoPressEnter;

  procedure UpdateData;
  begin
    FComboBoxView.HideReferences;
    Owner.Model.UpdateData;
    inherited;
  end;

begin
  if FComboBoxView.AsString = '' then
    inherited
  else if FComboBoxView.IsChanged and (FComboBoxView.AsInteger = -1) then
  begin
    case (Owner as TPressMVPPointerPresenter).UpdateReferences(FComboBoxView.AsString) of
      0: FComboBoxView.SelectAll;
      1: UpdateData;
      else FComboBoxView.ShowReferences;
    end;
  end else if FComboBoxView.ReferencesVisible then
    UpdateData
  else
    inherited;
end;

procedure TPressMVPUpdateComboInteractor.InitInteractor;
begin
  inherited;
  PressAsIntf(Owner.View, IPressMVPComboBoxView, FComboBoxView);
end;

{ TPressMVPOpenComboInteractor }

class function TPressMVPOpenComboInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := (APresenter is TPressMVPPointerPresenter) and
   PressSupports(APresenter.View, IPressMVPComboBoxView);
end;

procedure TPressMVPOpenComboInteractor.InitInteractor;
begin
  inherited;
  PressAsIntf(Owner.View, IPressMVPItemView, FItemView);
  Notifier.AddNotificationItem(FItemView.Instance, [TPressMVPViewDropDownEvent]);
end;

procedure TPressMVPOpenComboInteractor.Notify(AEvent: TPressEvent);
var
  VQueryString: string;
begin
  inherited;
  if AEvent is TPressMVPViewDropDownEvent then
  begin
    if FItemView.SelectedText = '' then
      VQueryString := FItemView.AsString
    else
      VQueryString := '';
    (Owner as TPressMVPPointerPresenter).UpdateReferences(VQueryString);
  end;
end;

{ TPressMVPChangeModelInteractor }

class function TPressMVPChangeModelInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := PressSupports(APresenter.View, IPressMVPWinView);
end;

procedure TPressMVPChangeModelInteractor.InitInteractor;
begin
  inherited;
  Notifier.AddNotificationItem(Owner.View.Instance,
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
    while Assigned(VObjectModel.OwnerModel) and
     (VObjectModel.OwnerModel.Parent is TPressMVPObjectModel) do
      VObjectModel := TPressMVPObjectModel(VObjectModel.OwnerModel.Parent);
    if AEvent is TPressMVPViewEnterEvent then
    begin
      VObjectModel.Selection.Select(Owner.Model);
      Owner.View.Update;
    end else
      VObjectModel.Selection.Clear;
  end;
end;

{ TPressMVPUpdaterInteractor }

procedure TPressMVPUpdaterInteractor.DoUpdateModel;
begin
  try
    { TODO : Test behavior with exceptions from ModelUpdate event }
    //try
    if Owner.View.IsChanged then
      InternalUpdateModel;
    //except
    //  on E: Exception do
    //    if (AEvent is TPressMVPViewExitEvent) or not (E is EPressError) then
    //      raise;
    //end;
    Owner.View.Update;
  except
    if Assigned(FWinView) then
    begin
      FWinView.DisableEvents;
      try
        FWinView.SetFocus;
      finally
        FWinView.EnableEvents;
      end;
    end;
    raise;
  end;
end;

procedure TPressMVPUpdaterInteractor.InitInteractor;
begin
  inherited;
  Supports(Owner.View, IPressMVPWinView, FWinView);
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
  Notifier.AddNotificationItem(Owner.View.Instance, [TPressMVPViewExitEvent]);
  Notifier.AddNotificationItem(Owner.Model, [TPressMVPModelUpdateDataEvent]);
end;

{ TPressMVPEditUpdaterInteractor }

class function TPressMVPEditUpdaterInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := PressSupports(APresenter.View, IPressMVPEditView);
end;

procedure TPressMVPEditUpdaterInteractor.InitInteractor;
begin
  inherited;
  PressAsIntf(Owner.View, IPressMVPEditView, FEditView);
end;

procedure TPressMVPEditUpdaterInteractor.InternalUpdateModel;
begin
  (Owner.Model.Subject as TPressAttribute).AsString := FEditView.AsString;
end;

{ TPressMVPDateTimeUpdaterInteractor }

class function TPressMVPDateTimeUpdaterInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := PressSupports(APresenter.View, IPressMVPDateTimeView);
end;

procedure TPressMVPDateTimeUpdaterInteractor.InitInteractor;
begin
  inherited;
  PressAsIntf(Owner.View, IPressMVPDateTimeView, FDateTimeView);
end;

procedure TPressMVPDateTimeUpdaterInteractor.InternalUpdateModel;
begin
  (Owner.Model.Subject as TPressAttribute).AsDateTime := FDateTimeView.AsDateTime;
end;

{ TPressMVPPointerUpdaterInteractor }

procedure TPressMVPPointerUpdaterInteractor.InitInteractor;
begin
  inherited;
  PressAsIntf(Owner.View, IPressMVPAttributeView, FAttrView);
  Notifier.AddNotificationItem(FAttrView.Instance, [TPressMVPViewSelectEvent]);
end;

procedure TPressMVPPointerUpdaterInteractor.InternalUpdateModel;
var
  VIndex: Integer;
begin
  if FAttrView.AsString = '' then
    (Owner.Model.Subject as TPressAttribute).Clear
  else
  begin
    VIndex := FAttrView.AsInteger;
    if (VIndex = -1) and (InternalReferenceCount = 1) then
      VIndex := 0;
    if VIndex >= 0 then
      InternalAssignSubject(VIndex);
  end;
end;

{ TPressMVPEnumUpdaterInteractor }

class function TPressMVPEnumUpdaterInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := (APresenter is TPressMVPEnumPresenter) and
   PressSupports(APresenter.View, IPressMVPItemView);
end;

procedure TPressMVPEnumUpdaterInteractor.InternalAssignSubject(VIndex: Integer);
var
  VModel: TPressMVPEnumModel;
begin
  VModel := Owner.Model as TPressMVPEnumModel;
  VModel.Subject.AsInteger := VModel.EnumOf(VIndex);
end;

function TPressMVPEnumUpdaterInteractor.InternalReferenceCount: Integer;
begin
  Result := (Owner.Model as TPressMVPEnumModel).EnumValueCount;
end;

{ TPressMVPReferenceUpdaterInteractor }

class function TPressMVPReferenceUpdaterInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := (APresenter is TPressMVPReferencePresenter) and
   PressSupports(APresenter.View, IPressMVPItemView);
end;

procedure TPressMVPReferenceUpdaterInteractor.InternalAssignSubject(
  VIndex: Integer);
var
  VModel: TPressMVPReferenceModel;
begin
  VModel := Owner.Model as TPressMVPReferenceModel;
  VModel.Subject.PubValue := VModel.ObjectOf(VIndex);
end;

function TPressMVPReferenceUpdaterInteractor.InternalReferenceCount: Integer;
begin
  Result := (Owner.Model as TPressMVPReferenceModel).Query.Count;
end;

{ TPressMVPClickUpdaterInteractor }

procedure TPressMVPClickUpdaterInteractor.InitInteractor;
begin
  inherited;
  Notifier.AddNotificationItem(Owner.View.Instance, [TPressMVPViewClickEvent]);
end;

{ TPressMVPBooleanUpdaterInteractor }

class function TPressMVPBooleanUpdaterInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := PressSupports(APresenter.View, IPressMVPBooleanView);
end;

procedure TPressMVPBooleanUpdaterInteractor.InitInteractor;
begin
  inherited;
  PressAsIntf(Owner.View, IPressMVPBooleanView, FBooleanView);
end;

procedure TPressMVPBooleanUpdaterInteractor.InternalUpdateModel;
begin
  if FBooleanView.IsClear then
    (Owner.Model.Subject as TPressAttribute).Clear
  else
    (Owner.Model.Subject as TPressAttribute).AsBoolean := FBooleanView.AsBoolean;
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
  Notifier.AddNotificationItem(Owner.View.Instance, [TPressMVPViewDblClickEvent]);
end;

procedure TPressMVPDblClickSelectableInteractor.Notify(AEvent: TPressEvent);
begin
  inherited;
  if not (Owner.Model is TPressMVPReferencesModel) or
   TPressMVPReferencesModel(Owner.Model).CanEditObject then
    FCommand.Execute;
end;

{ TPressMVPEditableInteractor }

class function TPressMVPEditableInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := APresenter is TPressMVPValuePresenter;
end;

procedure TPressMVPEditableInteractor.InitInteractor;
begin
  inherited;
  Notifier.AddNotificationItem(Owner.View.Instance, [TPressMVPViewKeyPressEvent]);
end;

{ TPressMVPNumericInteractor }

procedure TPressMVPNumericInteractor.InitInteractor;
begin
  inherited;
  PressAsIntf(Owner.View, IPressMVPAttributeView, FAttrView);
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
      if not AcceptDecimal or (Pos(DecimalSeparator, FAttrView.AsString) > 0) then
        VKey := #0;
    end else if VKey = '-' then
    begin
      { TODO : Fix "-" interaction }
      if not AcceptNegative or (Pos('-', FAttrView.AsString) > 0) then
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
   APresenter.Model.SubjectMetadata.Supports(TPressInteger);
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
   (APresenter.Model.SubjectMetadata.Supports(TPressFloat) or
   APresenter.Model.SubjectMetadata.Supports(TPressCurrency));
end;

{ TPressMVPDateTimeInteractor }

class function TPressMVPDateTimeInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := inherited Apply(APresenter) and
   APresenter.Model.SubjectMetadata.Supports(TPressDateTime);
end;

procedure TPressMVPDateTimeInteractor.Notify(AEvent: TPressEvent);
begin
  inherited;
  { TODO : Implement }
end;

{ TPressMVPCustomDrawInteractor }

procedure TPressMVPCustomDrawInteractor.DrawTextRect(ACanvasHandle: TObject;
  ARect: TPressRect; AMargin: Integer; const AText: string; AAlignment: TPressAlignment);
var
  VTop: Integer;
  VLeft: Integer;
begin
  VTop := (ARect.Top + ARect.Bottom - PressWidget.TextHeight(ACanvasHandle, AText)) div 2;
  case AAlignment of
    alLeft:
      VLeft := ARect.Left + AMargin;
    alRight:
      VLeft := ARect.Right - PressWidget.TextWidth(ACanvasHandle, AText) - AMargin - 1;
    else {alCenter}
      VLeft := (ARect.Left + ARect.Right - PressWidget.TextWidth(ACanvasHandle, AText)) div 2;
  end;
  PressWidget.TextRect(ACanvasHandle, ARect, VLeft, VTop, PressEncodeString(AText));
end;

{ TPressMVPDrawItemInteractor }

function TPressMVPDrawItemInteractor.GetOwner: TPressMVPReferencePresenter;
begin
  Result := inherited Owner as TPressMVPReferencePresenter;
end;

{ TPressMVPDrawComboBoxInteractor }

class function TPressMVPDrawComboBoxInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := APresenter is TPressMVPReferencePresenter;
end;

procedure TPressMVPDrawComboBoxInteractor.DrawItem(
  ACanvasHandle: TObject; AIndex: Integer; ARect: TPressRect);
begin
  DrawTextRect(ACanvasHandle, ARect, 2,
   Owner.Model.DisplayText(0, AIndex), Owner.Model.TextAlignment(0));
end;

procedure TPressMVPDrawComboBoxInteractor.InitInteractor;
begin
  inherited;
  Notifier.AddNotificationItem(Owner.View.Instance, [TPressMVPViewDrawItemEvent]);
end;

procedure TPressMVPDrawComboBoxInteractor.Notify(AEvent: TPressEvent);
begin
  inherited;
  if AEvent is TPressMVPViewDrawItemEvent then
    with TPressMVPViewDrawItemEvent(AEvent) do
      DrawItem(CanvasHandle, ItemIndex, Rect);
end;

{ TPressMVPDrawItemsInteractor }

procedure TPressMVPDrawItemsInteractor.DrawSelection(
  ACanvasHandle: TObject; ARect: TPressRect; AStrongSelection: Boolean);
const
  CPointSize = 4;
var
  VLeft, VTop: Integer;
begin
  VLeft := ARect.Left + 1;
  VTop := (ARect.Top + ARect.Bottom - CPointSize) div 2;
  PressWidget.Draw(
   ACanvasHandle, shEllipse,
   VLeft, VTop, VLeft + CPointSize, VTop + CPointSize, AStrongSelection);
end;

function TPressMVPDrawItemsInteractor.GetOwner: TPressMVPItemsPresenter;
begin
  Result := inherited Owner as TPressMVPItemsPresenter;
end;

{ TPressMVPDrawListBoxInteractor }

class function TPressMVPDrawListBoxInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := PressSupports(APresenter.View, IPressMVPListBoxView);
end;

procedure TPressMVPDrawListBoxInteractor.DrawItem(
  ACanvasHandle: TObject; AIndex: Integer; ARect: TPressRect);
var
  VModel: TPressMVPItemsModel;
begin
  VModel := Owner.Model;
  // A vcl's listbox event occurs between an item is removed and
  // the listbox size is adjusted
  if AIndex >= VModel.Count then
    Exit;
  DrawTextRect(ACanvasHandle, ARect, 8,
   VModel.DisplayText(0, AIndex), VModel.TextAlignment(0));
  if VModel.Selection.IsSelected(VModel[AIndex]) then
    DrawSelection(ACanvasHandle, ARect,
     VModel.Selection.HasStrongSelection(VModel[AIndex]));
  ARect.Left := ARect.Left + 12;
end;

procedure TPressMVPDrawListBoxInteractor.InitInteractor;
begin
  inherited;
  Notifier.AddNotificationItem(Owner.View.Instance, [TPressMVPViewDrawItemEvent]);
end;

procedure TPressMVPDrawListBoxInteractor.Notify(AEvent: TPressEvent);
begin
  inherited;
  if AEvent is TPressMVPViewDrawItemEvent then
    with TPressMVPViewDrawItemEvent(AEvent) do
      DrawItem(CanvasHandle, ItemIndex, Rect);
end;

{ TPressMVPDrawGridInteractor }

class function TPressMVPDrawGridInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := PressSupports(APresenter.View, IPressMVPGridView);
end;

procedure TPressMVPDrawGridInteractor.DrawCell(ACanvasHandle: TObject;
  ACol, ARow: Integer; ARect: TPressRect);
var
  VModel: TPressMVPItemsModel;
  VAlignment: TPressAlignment;
  VText: string;
begin
  VModel := Owner.Model;
  if ACol = -1 then
  begin
    if (ARow = -1) or (VModel.Count = 0) then
      VText := ''
    else
      VText := IntToStr(VModel.ItemNumber(ARow));
    VAlignment := alRight;
  end else if ARow = -1 then
    with VModel.ColumnData[ACol] do
    begin
      if FGridView.AccessMode <> amInvisible then
        VText := HeaderCaption
      else
        VText := '';
      VAlignment := HeaderAlignment;
    end
  else
  begin
    if (FGridView.AccessMode <> amInvisible) and (ARow < VModel.Count) then
      VText := VModel.DisplayText(ACol, ARow)
    else
      VText := '';
    VAlignment := VModel.TextAlignment(ACol);
  end;
  DrawTextRect(ACanvasHandle, ARect, 2, VText, VAlignment);
  if (ACol = -1) and (ARow >= 0) and (ARow < VModel.Count) and
   VModel.Selection.IsSelected(VModel[ARow]) then
    DrawSelection(ACanvasHandle, ARect,
     VModel.Selection.HasStrongSelection(VModel[ARow]));
end;

procedure TPressMVPDrawGridInteractor.InitInteractor;
begin
  inherited;
  PressAsIntf(Owner.View, IPressMVPGridView, FGridView);
  Notifier.AddNotificationItem(FGridView.Instance, [TPressMVPViewDrawCellEvent]);
end;

procedure TPressMVPDrawGridInteractor.Notify(AEvent: TPressEvent);
begin
  inherited;
  if AEvent is TPressMVPViewDrawCellEvent then
    with TPressMVPViewDrawCellEvent(AEvent) do
      DrawCell(CanvasHandle, Col, Row, Rect);
end;

{ TPressMVPSelectItemInteractor }

class function TPressMVPSelectItemInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := PressSupports(APresenter.View, IPressMVPItemsView);
end;

procedure TPressMVPSelectItemInteractor.InitInteractor;
begin
  inherited;
  PressAsIntf(Owner.View, IPressMVPItemsView, FItemsView);
  Notifier.AddNotificationItem(
   Owner.Model.Selection, [TPressMVPSelectionChangedEvent]);
  Notifier.AddNotificationItem(
   FItemsView.Instance, [TPressMVPViewClickEvent]);
end;

procedure TPressMVPSelectItemInteractor.Notify(AEvent: TPressEvent);
begin
  inherited;
  if AEvent is TPressMVPSelectionChangedEvent then
  begin
    UpdateSelectedItem;
    FItemsView.Update;
  end else if AEvent is TPressMVPViewClickEvent then
    SelectItem(FItemsView.CurrentItem);
end;

procedure TPressMVPSelectItemInteractor.SelectItem(AIndex: Integer);
var
  VModel: TPressMVPItemsModel;
begin
  VModel := Owner.Model as TPressMVPItemsModel;
  if VModel.Count > 0 then
  begin
    Notifier.DisableEvents;
    try
      VModel.Selection.Focus := VModel[AIndex];
    finally
      Notifier.EnableEvents;
    end;
    Owner.View.Update;
  end;
end;

procedure TPressMVPSelectItemInteractor.UpdateSelectedItem;
var
  VModel: TPressMVPItemsModel;
  VCurrentItem: Integer;
  VIndex: Integer;
begin
  VModel := Owner.Model as TPressMVPItemsModel;
  VCurrentItem := FItemsView.CurrentItem;
  Notifier.DisableEvents;
  try
    if VCurrentItem < VModel.Count then
      if (VCurrentItem = -1) or
       (VModel[VCurrentItem] <> VModel.Selection.Focus) then
        VIndex := VModel.IndexOf(VModel.Selection.Focus)
      else
        VIndex := -1
    else
      VIndex := Pred(VModel.Count);
    if VIndex >= 0 then
      FItemsView.SelectItem(VIndex);
  finally
    Notifier.EnableEvents;
  end;
end;

{ TPressMVPSortItemsInteractor }

class function TPressMVPSortItemsInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := (APresenter.Model is TPressMVPItemsModel) and
   PressSupports(APresenter.View, IPressMVPGridView);
end;

procedure TPressMVPSortItemsInteractor.ClickHeader(ACol: Integer);
begin
  (Owner.Model as TPressMVPItemsModel).Reindex(ACol);
end;

procedure TPressMVPSortItemsInteractor.InitInteractor;
begin
  inherited;
  Notifier.AddNotificationItem(Owner.View.Instance, [TPressMVPViewClickHeaderEvent]);
end;

procedure TPressMVPSortItemsInteractor.Notify(AEvent: TPressEvent);
begin
  inherited;
  if AEvent is TPressMVPViewClickHeaderEvent then
    ClickHeader(TPressMVPViewClickHeaderEvent(AEvent).Col);
end;

{ TPressMVPCreateFormInteractor }

procedure TPressMVPCreateFormInteractor.ExecuteFormPresenter(
  AEvent: TPressMVPModelCreateFormEvent;
  AFormPresenterType: TPressMVPFormPresenterType);
var
  VPresenterIndex: Integer;
  VObject: TPressObject;
begin
  VObject := AEvent.TargetObject;
  if not Assigned(VObject) and (Model.Selection.Count = 1) then
    VObject := Model.Selection[0];
  if Assigned(VObject) then
  begin
    VPresenterIndex := PressDefaultMVPFactory.Forms.IndexOfObjectClass(
     VObject.ClassType, AFormPresenterType);
    if VPresenterIndex >= 0 then
      AEvent.PresenterHandle :=
       RunPresenter(VPresenterIndex, VObject, AFormPresenterType = fpNew);
  end;
end;

function TPressMVPCreateFormInteractor.GetModel: TPressMVPStructureModel;
begin
  Result := Owner.Model as TPressMVPStructureModel;
end;

function TPressMVPCreateFormInteractor.RunPresenter(APresenterIndex: Integer;
  AObject: TPressObject; AIncluding: Boolean): TPressMVPFormPresenter;
var
  VModel: TPressMVPStructureModel;
  VFormPresenter: TPressMVPFormPresenter;
  VSubPresenter: TPressMVPPresenter;
  VPresenterIndex: Integer;
begin
  VModel := Model;
  if not Assigned(AObject) or not AObject.IsOwned or
   (AObject is VModel.SubjectMetadata.ObjectClass) then
  begin
    Result := PressDefaultMVPFactory.Forms[APresenterIndex].
     PresenterClass.Run(Owner.Parent, AObject, AIncluding);
    Result.Model.AssignOwnerModel(VModel);
  end else
  begin
    Result := nil;
    VFormPresenter := nil;
    VPresenterIndex := PressDefaultMVPFactory.Forms.IndexOfObjectClass(
     AObject.Owner.ClassType, fpExisting);
    if VPresenterIndex >= 0 then
      VFormPresenter := RunPresenter(VPresenterIndex, AObject.Owner, False);
    if Assigned(VFormPresenter) then
    begin
      VSubPresenter :=
       VFormPresenter.FindSubPresenterBySubjectName(AObject.OwnerAttribute.Name);
      if Assigned(VSubPresenter) then
      begin
        VSubPresenter.Model.Selection.Select(AObject);
        with TPressMVPModelCreatePresentFormEvent.Create(VSubPresenter.Model) do
        try
          Notify(False);
          Result := PresenterHandle as TPressMVPFormPresenter;
        finally
          Free;
        end;
      end;
    end;
  end;
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
  PressAsIntf(Owner.View, IPressMVPAttributeView, FAttrView);
  Notifier.AddNotificationItem(Owner.Model,
   [TPressMVPModelCreateIncludeFormEvent]);
end;

procedure TPressMVPCreateIncludeFormInteractor.Notify(AEvent: TPressEvent);
var
  VObject: TPressObject;
  VAttribute: TPressAttribute;
  VModel: TPressMVPStructureModel;
begin
  inherited;
  if AEvent is TPressMVPModelCreateIncludeFormEvent then
  begin
    VObject := TPressMVPModelCreateIncludeFormEvent(AEvent).TargetObject;
    if Assigned(VObject) then
    begin
      VModel := Model;
      VAttribute := VObject.FindAttribute(VModel.DisplayNames);
      if VAttribute is TPressString then
        VAttribute.AsString := FAttrView.AsString;
      VModel.Subject.AssignObject(VObject);
    end;
    ExecuteFormPresenter(TPressMVPModelCreateIncludeFormEvent(AEvent), fpNew);
  end;
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
  if AEvent is TPressMVPModelCreatePresentFormEvent then
    ExecuteFormPresenter(TPressMVPModelCreatePresentFormEvent(AEvent), fpExisting);
end;

{ TPressMVPCreateSearchFormInteractor }

class function TPressMVPCreateSearchFormInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := APresenter.Model is TPressMVPReferencesModel;
end;

procedure TPressMVPCreateSearchFormInteractor.ExecuteQueryPresenter(
  AEvent: TPressMVPModelCreateSearchFormEvent);
var
  VPresenterIndex: Integer;
begin
  VPresenterIndex := PressDefaultMVPFactory.Forms.IndexOfQueryItemObject(
   Model.Subject.ObjectClass, fpQuery);
  if VPresenterIndex >= 0 then
    AEvent.PresenterHandle := RunPresenter(VPresenterIndex, nil, False);
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
  if AEvent is TPressMVPModelCreateSearchFormEvent then
    ExecuteQueryPresenter(TPressMVPModelCreateSearchFormEvent(AEvent));
end;

{ TPressMVPFormInteractor }

class function TPressMVPFormInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := (APresenter is TPressMVPFormPresenter) and
   not (APresenter is TPressMVPMainFormPresenter);
end;

function TPressMVPFormInteractor.GetOwner: TPressMVPFormPresenter;
begin
  Result := inherited Owner as TPressMVPFormPresenter;
end;

{ TPressMVPCleanupFormInteractor }

procedure TPressMVPCleanupFormInteractor.InitInteractor;
begin
  inherited;
  Notifier.AddNotificationItem(Owner.Model, [TPressMVPModelCleanupFormEvent]);
end;

procedure TPressMVPCleanupFormInteractor.Notify(AEvent: TPressEvent);
var
  VModel: TPressMVPObjectModel;
begin
  inherited;
  VModel := Owner.Model;
  VModel.Subject := (VModel.Subject.OwnerAttribute as TPressItems).Add;
  Owner.FormView.ResetForm;
end;

{ TPressMVPCloseFormInteractor }

procedure TPressMVPCloseFormInteractor.InitInteractor;
begin
  inherited;
  Notifier.AddNotificationItem(Owner.View.Instance, [TPressMVPViewCloseFormEvent]);
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

initialization
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
  TPressMVPDrawComboBoxInteractor.RegisterInteractor;
  TPressMVPDrawListBoxInteractor.RegisterInteractor;
  TPressMVPDrawGridInteractor.RegisterInteractor;
  TPressMVPSelectItemInteractor.RegisterInteractor;
  TPressMVPSortItemsInteractor.RegisterInteractor;
  TPressMVPCreateIncludeFormInteractor.RegisterInteractor;
  TPressMVPCreatePresentFormInteractor.RegisterInteractor;
  TPressMVPCreateSearchFormInteractor.RegisterInteractor;
  TPressMVPCleanupFormInteractor.RegisterInteractor;
  TPressMVPCloseFormInteractor.RegisterInteractor;
  TPressMVPFreePresenterInteractor.RegisterInteractor;

end.
