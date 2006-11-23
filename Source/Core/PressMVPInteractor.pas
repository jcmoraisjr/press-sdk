(*
  PressObjects, MVP-Interactor Classes
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
    VPresenterIndex := PressDefaultMVPFactory.Forms.IndexOfObjectClass(
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

initialization
  RegisterInteractors;

end.
