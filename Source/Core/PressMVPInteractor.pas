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
  Classes,
  Graphics,
  StdCtrls,
  Grids,
  PressCompatibility,
  PressNotifier,
  PressSubject,
  PressAttributes,
  PressMVP,
  PressMVPModel,
  PressMVPView,
  PressMVPPresenter;

type
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
    function GetModel: TPressMVPAttributeModel;
    function GetView: TPressMVPAttributeView;
  protected
    procedure DoUpdateModel;
    procedure InternalUpdateModel; virtual; abstract;
    procedure Notify(AEvent: TPressEvent); override;
  public
    property Model: TPressMVPAttributeModel read GetModel;
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

  TPressMVPDateTimeUpdaterInteractor = class(TPressMVPExitUpdaterInteractor)
  protected
    procedure InternalUpdateModel; override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPPointerUpdaterInteractor = class(TPressMVPExitUpdaterInteractor)
  private
    function GetOwner: TPressMVPPointerPresenter;
  protected
    procedure InitInteractor; override;
    procedure InternalAssignSubject(VIndex: Integer); virtual; abstract;
    function InternalReferenceCount: Integer; virtual; abstract;
    procedure InternalUpdateModel; override;
  public
    property Owner: TPressMVPPointerPresenter read GetOwner;
  end;

  TPressMVPEnumUpdaterInteractor = class(TPressMVPPointerUpdaterInteractor)
  private
    function GetOwner: TPressMVPEnumPresenter;
  protected
    procedure InternalAssignSubject(VIndex: Integer); override;
    function InternalReferenceCount: Integer; override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
    property Owner: TPressMVPEnumPresenter read GetOwner;
  end;

  TPressMVPReferenceUpdaterInteractor = class(TPressMVPPointerUpdaterInteractor)
  private
    function GetOwner: TPressMVPReferencePresenter;
  protected
    procedure InternalAssignSubject(VIndex: Integer); override;
    function InternalReferenceCount: Integer; override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
    property Owner: TPressMVPReferencePresenter read GetOwner;
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

  TPressMVPCustomDrawInteractor = class(TPressMVPInteractor)
  protected
    procedure DrawTextRect(ACanvas: TCanvas; ARect: TRect; AMargin: Integer; const AText: string; AAlignment: TAlignment);
  end;

  TPressMVPDrawItemInteractor = class(TPressMVPCustomDrawInteractor)
  private
    function GetOwner: TPressMVPReferencePresenter;
  public
    property Owner: TPressMVPReferencePresenter read GetOwner;
  end;

  TPressMVPDrawComboBoxInteractor = class(TPressMVPDrawItemInteractor)
  protected
    procedure DrawItem(Sender: TPressMVPView; ACanvas: TCanvas; AIndex: Integer; ARect: TRect; State: TOwnerDrawState); virtual;
    procedure InitInteractor; override;
    procedure Notify(AEvent: TPressEvent); override;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
  end;

  TPressMVPDrawItemsInteractor = class(TPressMVPCustomDrawInteractor)
  private
    procedure DrawSelection(ACanvas: TCanvas; ARect: TRect; AStrongSelection: Boolean);
  private
    function GetOwner: TPressMVPItemsPresenter;
  public
    property Owner: TPressMVPItemsPresenter read GetOwner;
  end;

  TPressMVPDrawListBoxInteractor = class(TPressMVPDrawItemsInteractor)
  protected
    procedure DrawItem(Sender: TPressMVPView; ACanvas: TCanvas; AIndex: Integer; ARect: TRect; State: TOwnerDrawState); virtual;
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
    procedure UpdateSelectedItem; virtual;
  public
    class function Apply(APresenter: TPressMVPPresenter): Boolean; override;
    property Owner: TPressMVPItemsPresenter read GetOwner;
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

implementation

uses
  SysUtils,
  Math,          
  PressConsts,
  PressMVPFactory,
  PressMVPCommand;

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
    if (VSelection.Focus is TPressMVPItemsModel) and
     (TPressMVPItemsModel(VSelection.Focus).Subject.Name = SPressQueryItemsString) then
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

  procedure UpdateData;
  begin
    VView.HideReferences;
    Owner.Model.UpdateData;
    VView.SelectAll;
  end;

begin
  VView := View;
  if VView.AsString = '' then
    inherited
  else if VView.IsChanged and (VView.AsInteger = -1) then
  begin
    case Owner.UpdateReferences(VView.AsString) of
      0: VView.SelectAll;
      1: UpdateData;
      else VView.ShowReferences;
    end;
  end else if VView.ReferencesVisible then
    UpdateData
  else
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
    if View.IsChanged then
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

function TPressMVPUpdaterInteractor.GetModel: TPressMVPAttributeModel;
begin
  Result := Owner.Model as TPressMVPAttributeModel;
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
  Model.Subject.AsString := View.AsString;
end;

{ TPressMVPDateTimeUpdaterInteractor }

class function TPressMVPDateTimeUpdaterInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := APresenter.View is TPressMVPDateTimeView;
end;

procedure TPressMVPDateTimeUpdaterInteractor.InternalUpdateModel;
begin
  Model.Subject.AsDateTime := (View as TPressMVPDateTimeView).AsDateTime;
end;

{ TPressMVPPointerUpdaterInteractor }

function TPressMVPPointerUpdaterInteractor.GetOwner: TPressMVPPointerPresenter;
begin
  Result := inherited Owner as TPressMVPPointerPresenter;
end;

procedure TPressMVPPointerUpdaterInteractor.InitInteractor;
begin
  inherited;
  Notifier.AddNotificationItem(Owner.View, [TPressMVPViewClickEvent]);
end;

procedure TPressMVPPointerUpdaterInteractor.InternalUpdateModel;
var
  VIndex: Integer;
begin
  if Owner.View.ReferencesVisible then
    Exit;
  if View.AsString = '' then
    Model.Subject.Clear
  else
  begin
    VIndex := View.AsInteger;
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
  Result := APresenter is TPressMVPEnumPresenter and
   (APresenter.View is TPressMVPItemView);
end;

function TPressMVPEnumUpdaterInteractor.GetOwner: TPressMVPEnumPresenter;
begin
  Result := inherited Owner as TPressMVPEnumPresenter;
end;

procedure TPressMVPEnumUpdaterInteractor.InternalAssignSubject(
  VIndex: Integer);
begin
  Model.Subject.AsInteger := Owner.Model.EnumOf(VIndex);
end;

function TPressMVPEnumUpdaterInteractor.InternalReferenceCount: Integer;
begin
  Result := Owner.Model.EnumValueCount;
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

procedure TPressMVPReferenceUpdaterInteractor.InternalAssignSubject(
  VIndex: Integer);
begin
  (Model.Subject as TPressReference).PubValue := Owner.Model.ObjectOf(VIndex);
end;

function TPressMVPReferenceUpdaterInteractor.InternalReferenceCount: Integer;
begin
  Result := Owner.Model.Query.Count;
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
    Model.Subject.Clear
  else
    Model.Subject.AsBoolean := View.AsBoolean;
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

{ TPressMVPCustomDrawInteractor }

procedure TPressMVPCustomDrawInteractor.DrawTextRect(ACanvas: TCanvas;
  ARect: TRect; AMargin: Integer; const AText: string; AAlignment: TAlignment);
var
  VTop: Integer;
  VLeft: Integer;
begin
  VTop := (ARect.Top + ARect.Bottom - ACanvas.TextHeight(AText)) div 2;
  case AAlignment of
    taLeftJustify:
      VLeft := ARect.Left + AMargin;
    taRightJustify:
      VLeft := ARect.Right - ACanvas.TextWidth(AText) - AMargin - 1;
    else {taCenter}
      VLeft := (ARect.Left + ARect.Right - ACanvas.TextWidth(AText)) div 2;
  end;
  ACanvas.TextRect(ARect, VLeft, VTop, AText);
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
  Sender: TPressMVPView; ACanvas: TCanvas; AIndex: Integer;
  ARect: TRect; State: TOwnerDrawState);
begin
  DrawTextRect(ACanvas, ARect, 2,
   Owner.Model.DisplayText(0, AIndex), Owner.Model.TextAlignment(0));
end;

procedure TPressMVPDrawComboBoxInteractor.InitInteractor;
begin
  inherited;
  {$IFDEF PressViewNotification}
  Notifier.AddNotificationItem(Owner.View, [TPressMVPViewDrawItemEvent]);
  {$ELSE}{$IFDEF PressViewDirectEvent}
  (Owner.View as TPressMVPComboBoxView).OnDrawItem := DrawItem;
  {$ENDIF}{$ENDIF}
end;

procedure TPressMVPDrawComboBoxInteractor.Notify(AEvent: TPressEvent);
begin
  inherited;
  {$IFDEF PressViewNotification}
  if AEvent is TPressMVPViewDrawItemEvent then
    with TPressMVPViewDrawItemEvent(AEvent) do
      DrawItem(Owner, Canvas, ItemIndex, Rect, State);
  {$ENDIF}
end;

{ TPressMVPDrawItemsInteractor }

procedure TPressMVPDrawItemsInteractor.DrawSelection(
  ACanvas: TCanvas; ARect: TRect; AStrongSelection: Boolean);
const
  CPointSize = 4;
var
  VPointPos: TRect;
begin
  { TODO : Save and restore Brush and Pen status }
  ACanvas.Pen.Color := ACanvas.Font.Color;
  if AStrongSelection then
    ACanvas.Brush.Color := ACanvas.Font.Color;
  VPointPos.Left := ARect.Left + 1;
  VPointPos.Top := (ARect.Top + ARect.Bottom - CPointSize) div 2;
  VPointPos.Right := VPointPos.Left + CPointSize;
  VPointPos.Bottom := VPointPos.Top + CPointSize;
  ACanvas.Ellipse(VPointPos);
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
  Sender: TPressMVPView; ACanvas: TCanvas; AIndex: Integer;
  ARect: TRect; State: TOwnerDrawState);
var
  VModel: TPressMVPItemsModel;
begin
  VModel := Owner.Model;
  // A vcl's listbox event occurs between an item is removed and
  // the listbox size is adjusted
  if AIndex >= VModel.Count then
    Exit;
  DrawTextRect(ACanvas, ARect, 8,
   VModel.DisplayText(0, AIndex), VModel.TextAlignment(0));
  if VModel.Selection.IsSelected(VModel[AIndex]) then
    DrawSelection(ACanvas, ARect,
     VModel.Selection.HasStrongSelection(VModel[AIndex]));
  ARect.Left := ARect.Left + 12;
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
  VModel: TPressMVPItemsModel;
  VAlignment: TAlignment;
  VText: string;
begin
  VModel := Owner.Model;
  if ACol = -1 then
  begin
    if (ARow = -1) or (VModel.Count = 0) then
      VText := ''
    else
      VText := InttoStr(VModel.ItemNumber(ARow));
    VAlignment := taRightJustify;
  end else if ARow = -1 then
    with VModel.ColumnData[ACol] do
    begin
      VText := HeaderCaption;
      VAlignment := HeaderAlignment;
    end
  else
  begin
    if ARow < VModel.Count then
      VText := VModel.DisplayText(ACol, ARow)
    else
      VText := '';
    VAlignment := VModel.TextAlignment(ACol);
  end;
  DrawTextRect(ACanvas, ARect, 2, VText, VAlignment);
  if (ACol = -1) and (ARow >= 0) and (ARow < VModel.Count) and
   VModel.Selection.IsSelected(VModel[ARow]) then
    DrawSelection(ACanvas, ARect,
     VModel.Selection.HasStrongSelection(VModel[ARow]));
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

class function TPressMVPSelectItemInteractor.Apply(
  APresenter: TPressMVPPresenter): Boolean;
begin
  Result := APresenter.View is TPressMVPItemsView;
end;

function TPressMVPSelectItemInteractor.GetOwner: TPressMVPItemsPresenter;
begin
  Result := inherited Owner as TPressMVPItemsPresenter;
end;

procedure TPressMVPSelectItemInteractor.InitInteractor;
begin
  inherited;
  Notifier.AddNotificationItem(
   Owner.Model.Selection, [TPressMVPSelectionChangedEvent]);
  Notifier.AddNotificationItem(
   Owner.View, [TPressMVPViewClickEvent]);
end;

procedure TPressMVPSelectItemInteractor.Notify(AEvent: TPressEvent);
begin
  inherited;
  if AEvent is TPressMVPSelectionChangedEvent then
  begin
    UpdateSelectedItem;
    Owner.View.Update;
  end else if AEvent is TPressMVPViewClickEvent then
    SelectItem(Owner.View.CurrentItem);
end;

procedure TPressMVPSelectItemInteractor.SelectItem(AIndex: Integer);
begin
  if Owner.Model.Count > 0 then
  begin
    Notifier.DisableEvents;
    try
      Owner.Model.Selection.Focus := Owner.Model[AIndex];
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
  VModel := Owner.Model;
  VCurrentItem := Owner.View.CurrentItem;
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
      Owner.View.SelectItem(VIndex);
  finally
    Notifier.EnableEvents;
  end;
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
    VPresenterIndex := PressDefaultMVPFactory.Forms.IndexOfObjectClass(
     VObject.ClassType, AFormPresenterType);
    if VPresenterIndex >= 0 then
      RunPresenter(VPresenterIndex, VObject, AFormPresenterType = fpInclude);
  end;
end;

function TPressMVPCreateFormInteractor.GetModel: TPressMVPStructureModel;
begin
  Result := Owner.Model as TPressMVPStructureModel;
end;

procedure TPressMVPCreateFormInteractor.RunPresenter(
  APresenterIndex: Integer; AObject: TPressObject; AIncluding: Boolean);
var
  VPresenter: TPressMVPFormPresenter;
begin
  VPresenter := PressDefaultMVPFactory.Forms[APresenterIndex].
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
  VPresenterIndex := PressDefaultMVPFactory.Forms.IndexOfQueryItemObject(
   Model.Subject.ObjectClass, fpInclude);
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
  TPressMVPDrawComboBoxInteractor.RegisterInteractor;
  TPressMVPDrawListBoxInteractor.RegisterInteractor;
  TPressMVPDrawGridInteractor.RegisterInteractor;
  TPressMVPSelectItemInteractor.RegisterInteractor;
  TPressMVPCreateIncludeFormInteractor.RegisterInteractor;
  TPressMVPCreatePresentFormInteractor.RegisterInteractor;
  TPressMVPCreateSearchFormInteractor.RegisterInteractor;
  TPressMVPCloseFormInteractor.RegisterInteractor;
  TPressMVPFreePresenterInteractor.RegisterInteractor;
end;

initialization
  RegisterInteractors;

end.
