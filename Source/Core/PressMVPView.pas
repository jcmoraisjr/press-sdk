(*
  PressObjects, MVP-View Classes
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

unit PressMVPView;

interface

{$I Press.inc}

uses
  Classes,
  Graphics,
  Controls,
  StdCtrls,
  ExtCtrls,
  Grids,
  Forms,
  PressCompatibility,
  PressClasses,
  PressSubject,
  PressMVP,
  PressMVPModel;

type
  { TPressEvent }

  TPressMVPViewEnterEvent = class(TPressMVPViewEvent)
  end;

  TPressMVPViewExitEvent = class(TPressMVPViewEvent)
  end;

  TPressMVPViewKeyboardEvent = class(TPressMVPViewEvent)
  protected
    {$IFNDEF PressLogKeyboardEvents}
    function AllowLog: Boolean; override;
    {$ENDIF}
  end;

  TPressMVPViewKeyPressEvent = class(TPressMVPViewKeyboardEvent)
  private
    FKey: ^Char;
    function GetKey: Char;
    procedure SetKey(const Value: Char);
  public
    constructor Create(AOwner: TObject; var AKey: Char);
    property Key: Char read GetKey write SetKey;
  end;

  TPressMVPViewKeyEvent = class(TPressMVPViewKeyboardEvent)
  private
    FKey: ^Word;
    FShift: TShiftState;
    function GetKey: Word;
    procedure SetKey(const Value: Word);
  public
    constructor Create(AOwner: TObject; var AKey: Word; AShift: TShiftState);
    property Key: Word read GetKey write SetKey;
    property Shift: TShiftState read FShift;
  end;

  TPressMVPViewKeyDownEvent = class(TPressMVPViewKeyEvent)
  end;

  TPressMVPViewKeyUpEvent = class(TPressMVPViewKeyEvent)
  end;

  TPressMVPViewDropDownEvent = class(TPressMVPViewEvent)
  end;

  TPressMVPListBoxView = class;
  TPressMVPGridView = class;

  {$IFDEF PressViewNotification}
  TPressMVPViewDrawItemEvent = class(TPressMVPViewEvent)
  private
    FCanvas: TCanvas;
    FItemIndex: Integer;
    FState: TOwnerDrawState;
    FRect: TRect;
    function GetOwner: TPressMVPListBoxView;
  public
    constructor Create(AOwner: TPressMVPListBoxView; ACanvas: TCanvas; AItemIndex: Integer; ARect: TRect; State: TOwnerDrawState);
    property Owner: TPressMVPListBoxView read GetOwner;
    property Canvas: TCanvas read FCanvas;
    property ItemIndex: Integer read FItemIndex;
    property Rect: TRect read FRect;
    property State: TOwnerDrawState read FState;
  end;

  TPressMVPViewDrawCellEvent = class(TPressMVPViewEvent)
  private
    FCanvas: TCanvas;
    FCol: Integer;
    FRect: TRect;
    FRow: Integer;
    FState: TGridDrawState;
    function GetOwner: TPressMVPGridView;
  public
    constructor Create(AOwner: TPressMVPGridView; ACanvas: TCanvas; ACol, ARow: Integer; ARect: TRect; State: TGridDrawState);
    property Owner: TPressMVPGridView read GetOwner;
    property Canvas: TCanvas read FCanvas;
    property Col: Integer read FCol;
    property Rect: TRect read FRect;
    property Row: Integer read FRow;
    property State: TGridDrawState read FState;
  end;

  TPressMVPViewSelectCellEvent = class(TPressMVPViewEvent)
  private
    FCanSelect: PBoolean;
    FCol: Integer;
    FRow: Integer;
    function GetCanSelect: Boolean;
    procedure SetCanSelect(const Value: Boolean);
  public
    constructor Create(AOwner: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    property CanSelect: Boolean read GetCanSelect write SetCanSelect;
    property CanSelectPtr: PBoolean read FCanSelect;
    property Col: Integer read FCol;
    property Row: Integer read FRow;
  end;
  {$ENDIF}

  TPressMVPViewFormEvent = class(TPressMVPViewEvent)
  end;

  TPressMVPViewCloseFormEvent = class(TPressMVPViewFormEvent)
  end;

  { TPressMVPView }

  TPressMVPAttributeView = class(TPressMVPView)
  protected
    function GetAsString: string; virtual;
    procedure InternalClear; virtual;
    procedure InternalUpdateModel(AAttribute: TPressAttribute); virtual;
    procedure InternalUpdateView(AAttribute: TPressAttribute); virtual;
    procedure SetSize(Value: Integer); virtual;
  public
    procedure Clear;
    procedure UpdateModel(AAttribute: TPressAttribute);
    procedure UpdateView(AAttribute: TPressAttribute);
    property AsString: string read GetAsString;
    property Size: Integer write SetSize;
  end;

  TPressMVPWinView = class(TPressMVPAttributeView)
  private
    FViewEnterEvent: TNotifyEvent;
    FViewExitEvent: TNotifyEvent;
    FViewKeyDownEvent: TKeyEvent;
    FViewKeyPressEvent: TKeyPressEvent;
    FViewKeyUpEvent: TKeyEvent;
  protected
    procedure ViewEnterEvent(Sender: TObject); virtual;
    procedure ViewExitEvent(Sender: TObject); virtual;
    procedure ViewKeyDownEvent(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
    procedure ViewKeyPressEvent(Sender: TObject; var Key: Char); virtual;
    procedure ViewKeyUpEvent(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
  protected
    procedure InitView; override;
  public
    procedure SelectNext; virtual;
    procedure SetFocus; virtual;
  end;

  TPressMVPEditView = class(TPressMVPWinView)
  private
    FChanged: Boolean;
    FViewChangeEvent: TNotifyEvent;
    function GetControl: TCustomEdit;
  protected
    procedure ViewChangeEvent(Sender: TObject); virtual;
    procedure ViewEnterEvent(Sender: TObject); override;
  protected
    function GetAsString: string; override;
    procedure InitView; override;
    procedure InternalClear; override;
    procedure InternalUpdateModel(AAttribute: TPressAttribute); override;
    procedure InternalUpdateView(AAttribute: TPressAttribute); override;
    procedure SetSize(Value: Integer); override;
  public
    class function Apply(AControl: TControl): Boolean; override;
    procedure SetFocus; override;
    property Changed: Boolean read FChanged;
    property Control: TCustomEdit read GetControl;
  end;

  TPressMVPDateTimeView = class(TPressMVPWinView)
  private
    function GetControl: TCustomCalendar;
  protected
    function GetAsString: string; override;
    procedure InternalClear; override;
    procedure InternalUpdateModel(AAttribute: TPressAttribute); override;
    procedure InternalUpdateView(AAttribute: TPressAttribute); override;
  public
    class function Apply(AControl: TControl): Boolean; override;
    property Control: TCustomCalendar read GetControl;
  end;

  TPressMVPCheckBoxView = class(TPressMVPWinView)
  private
    function GetControl: TCustomCheckBox;
  protected
    procedure InternalClear; override;
    procedure InternalUpdateModel(AAttribute: TPressAttribute); override;
    procedure InternalUpdateView(AAttribute: TPressAttribute); override;
  public
    class function Apply(AControl: TControl): Boolean; override;
    property Control: TCustomCheckBox read GetControl;
  end;

  TPressMVPItemView = class(TPressMVPWinView)
  protected
    procedure InternalAddReference(const ACaption: string; AReference: TPressObject); virtual; abstract;
    procedure InternalClearReferences; virtual; abstract;
    function InternalCurrentItem: Integer; virtual; abstract;
  public
    procedure AddReference(const ACaption: string; AReference: TPressObject);
    procedure ClearReferences;
    function CurrentItem: Integer;
  end;

  TPressMVPComboBoxView = class(TPressMVPItemView)
  { TODO : This view shouldn't be so smart }
  private
    FChanged: Boolean;
    FViewChangeEvent: TNotifyEvent;
    FViewDropDownEvent: TNotifyEvent;
    function GetComboStyle: TComboBoxStyle;
    function GetControl: TCustomComboBox;
    function GetDroppedDown: Boolean;
    procedure SetComboStyle(Value: TComboBoxStyle);
  protected
    procedure ViewChangeEvent(Sender: TObject); virtual;
    procedure ViewDropDownEvent(Sender: TObject); virtual;
    procedure ViewEnterEvent(Sender: TObject); override;
  protected
    function GetAsString: string; override;
    procedure InitView; override;
    procedure InternalAddReference(const ACaption: string; AReference: TPressObject); override;
    procedure InternalClear; override;
    procedure InternalClearReferences; override;
    function InternalCurrentItem: Integer; override;
    procedure InternalUpdateModel(AAttribute: TPressAttribute); override;
    procedure InternalUpdateView(AAttribute: TPressAttribute); override;
    procedure SetSize(Value: Integer); override;
  public
    class function Apply(AControl: TControl): Boolean; override;
    procedure SelectAll;
    procedure ShowReferences;
    property Changed: Boolean read FChanged;
    property ComboStyle: TComboBoxStyle read GetComboStyle write SetComboStyle;
    property Control: TCustomComboBox read GetControl;
    property DroppedDown: Boolean read GetDroppedDown;
  end;

  TPressMVPItemsView = class(TPressMVPWinView)
  private
    function GetRowCount: Integer;
    procedure SetRowCount(ARowCount: Integer);
  protected
    procedure InternalAlignColumns; virtual;
    function InternalCurrentItem: Integer; virtual; abstract;
    function InternalGetRowCount: Integer; virtual; abstract;
    procedure InternalSelectItem(AIndex: Integer); virtual; abstract;
    procedure InternalSetColumnCount(AColumnCount: Integer); virtual;
    procedure InternalSetColumnWidth(AColumn, AWidth: Integer); virtual;
    procedure InternalSetRowCount(ARowCount: Integer); virtual; abstract;
    procedure InternalUpdateView(AAttribute: TPressAttribute); override;
  public
    procedure AlignColumns;
    function CurrentItem: Integer;
    procedure SelectItem(AIndex: Integer);
    procedure SetColumnCount(AColumnCount: Integer);
    procedure SetColumnWidth(AColumn, AWidth: Integer);
    property RowCount: Integer read GetRowCount write SetRowCount;
  end;

  TPressDrawItemEvent = procedure(Sender: TPressMVPListBoxView;
   ACanvas: TCanvas; AIndex: Integer; ARect: TRect; State: TOwnerDrawState) of object;

  TPressMVPListBoxView = class(TPressMVPItemsView)
  private
    {$IFDEF PressViewDirectEvent}
    FOnDrawItem: TPressDrawItemEvent;
    {$ENDIF}
    FViewDrawItemEvent: TDrawItemEvent;
    procedure ViewDrawItemEvent(AControl: TWinControl; AIndex: Integer; ARect: TRect; State: TOwnerDrawState);
    function GetControl: TCustomListBox;
  protected
    procedure InitView; override;
    function InternalCurrentItem: Integer; override;
    function InternalGetRowCount: Integer; override;
    procedure InternalSelectItem(AIndex: Integer); override;
    procedure InternalSetRowCount(ARowCount: Integer); override;
  public
    class function Apply(AControl: TControl): Boolean; override;
    property Control: TCustomListBox read GetControl;
    {$IFDEF PressViewDirectEvent}
    property OnDrawItem: TPressDrawItemEvent read FOnDrawItem write FOnDrawItem;
    {$ENDIF}
  end;

  TPressDrawCellEvent = procedure(Sender: TPressMVPGridView; ACanvas: TCanvas;
   ACol, ARow: Longint; ARect: TRect; State: TGridDrawState) of object;

  TPressMVPGridView = class(TPressMVPItemsView)
  private
    {$IFDEF PressViewDirectEvent}
    FOnDrawCell: TPressDrawCellEvent;
    FOnSelectCell: TSelectCellEvent;
    {$ENDIF}
    FViewDrawCellEvent: TDrawCellEvent;
    FViewSelectCellEvent: TSelectCellEvent;
    function GetControl: TDrawGrid;
    procedure ViewDrawCellEvent(Sender: TObject; ACol, ARow: Longint; ARect: TRect; State: TGridDrawState);
    procedure ViewSelectCellEvent(Sender: TObject; ACol, ARow: Longint; var CanSelect: Boolean);
  protected
    procedure InitView; override;
    procedure InternalAlignColumns; override;
    function InternalCurrentItem: Integer; override;
    function InternalGetRowCount: Integer; override;
    procedure InternalSelectItem(AIndex: Integer); override;
    procedure InternalSetColumnCount(AColumnCount: Integer); override;
    procedure InternalSetColumnWidth(AColumn, AWidth: Integer); override;
    procedure InternalSetRowCount(ARowCount: Integer); override;
  public
    class function Apply(AControl: TControl): Boolean; override;
    property Control: TDrawGrid read GetControl;
    {$IFDEF PressViewDirectEvent}
    property OnDrawCell: TPressDrawCellEvent read FOnDrawCell write FOnDrawCell;
    property OnSelectCell: TSelectCellEvent read FOnSelectCell write FOnSelectCell;
    {$ENDIF}
  end;

  TPressMVPLabelView = class(TPressMVPAttributeView)
  private
    function GetControl: TCustomLabel;
  protected
    function GetAsString: string; override;
    procedure InternalUpdateModel(AAttribute: TPressAttribute); override;
    procedure InternalUpdateView(AAttribute: TPressAttribute); override;
  public
    class function Apply(AControl: TControl): Boolean; override;
    property Control: TCustomLabel read GetControl;
  end;

  TPressMVPPictureView = class(TPressMVPAttributeView)
  private
    function GetControl: TImage;
  protected
    procedure InternalUpdateModel(AAttribute: TPressAttribute); override;
    procedure InternalUpdateView(AAttribute: TPressAttribute); override;
  public
    class function Apply(AControl: TControl): Boolean; override;
    property Control: TImage read GetControl;
  end;

  TPressMVPCustomFormViewClass = class of TPressMVPCustomFormView;

  TPressMVPCustomFormView = class(TPressMVPView)
  end;

  TPressMVPFormView = class(TPressMVPCustomFormView)
  private
    FViewCloseEvent: TCloseEvent;
    procedure ViewCloseEvent(Sender: TObject; var Action: TCloseAction);
  private
    function GetControl: TCustomForm;
  protected
    procedure InitView; override;
  public
    class function Apply(AControl: TControl): Boolean; override;
    procedure Close;
    property Control: TCustomForm read GetControl;
  end;

  TPressMVPFrameView = class(TPressMVPCustomFormView)
  private
    function GetControl: TCustomFrame;
  public
    class function Apply(AControl: TControl): Boolean; override;
    property Control: TCustomFrame read GetControl;
  end;

implementation

uses
  PressConsts;

type
  TPressMVPViewWinControlFriend = class(TWinControl);
  TPressMVPViewCustomEditFriend = class(TCustomEdit);
  TPressMVPViewCustomCalendarFriend = class(TCustomCalendar);
  TPressMVPViewCustomCheckBoxFriend = class(TCustomCheckBox);
  TPressMVPViewCustomComboBoxFriend = class(TCustomComboBox);
  TPressMVPViewCustomListBoxFriend = class(TCustomListBox);
  TPressMVPViewCustomLabelFriend = class(TCustomLabel);
  TPressMVPViewCustomFormFriend = class(TCustomForm);

{ TPressMVPViewKeyboardEvent }

{$IFNDEF PressLogKeyboardEvents}
function TPressMVPViewKeyboardEvent.AllowLog: Boolean;
begin
  Result := False;
end;
{$ENDIF}

{ TPressMVPViewKeyPressEvent }

constructor TPressMVPViewKeyPressEvent.Create(AOwner: TObject; var AKey: Char);
begin
  inherited Create(AOwner);
  FKey := @AKey;
end;

function TPressMVPViewKeyPressEvent.GetKey: Char;
begin
  Result := FKey^;
end;

procedure TPressMVPViewKeyPressEvent.SetKey(const Value: Char);
begin
  FKey^ := Value;
end;

{ TPressMVPViewKeyEvent }

constructor TPressMVPViewKeyEvent.Create(
  AOwner: TObject; var AKey: Word; AShift: TShiftState);
begin
  inherited Create(AOwner);
  FKey := @AKey;
  FShift := AShift;
end;

function TPressMVPViewKeyEvent.GetKey: Word;
begin
  Result := FKey^;
end;

procedure TPressMVPViewKeyEvent.SetKey(const Value: Word);
begin
  FKey^ := Value;
end;

{$IFDEF PressViewNotification}

{ TPressMVPViewDrawItemEvent }

constructor TPressMVPViewDrawItemEvent.Create(
  AOwner: TPressMVPListBoxView; ACanvas: TCanvas;
  AItemIndex: Integer; ARect: TRect; State: TOwnerDrawState);
begin
  inherited Create(AOwner);
  FCanvas := ACanvas;
  FItemIndex := AItemIndex;
  FRect := ARect;
  FState := State;
end;

function TPressMVPViewDrawItemEvent.GetOwner: TPressMVPListBoxView;
begin
  Result := inherited Owner as TPressMVPListBoxView;
end;

{ TPressMVPViewDrawCellEvent }

constructor TPressMVPViewDrawCellEvent.Create(
  AOwner: TPressMVPGridView; ACanvas: TCanvas; ACol, ARow: Integer; ARect: TRect;
  State: TGridDrawState);
begin
  inherited Create(AOwner);
  FCanvas := ACanvas;
  FCol := ACol;
  FRow := ARow;
  FRect := ARect;
  FState := State;
end;

function TPressMVPViewDrawCellEvent.GetOwner: TPressMVPGridView;
begin
  Result := inherited Owner as TPressMVPGridView;
end;

{ TPressMVPViewSelectCellEvent }

constructor TPressMVPViewSelectCellEvent.Create(
  AOwner: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  inherited Create(AOwner);
  FCol := ACol;
  FRow := ARow;
  FCanSelect := @CanSelect;
end;

function TPressMVPViewSelectCellEvent.GetCanSelect: Boolean;
begin
  Result := FCanSelect^;
end;

procedure TPressMVPViewSelectCellEvent.SetCanSelect(const Value: Boolean);
begin
  FCanSelect^ := Value;
end;

{$ENDIF}

{ TPressMVPAttributeView }

procedure TPressMVPAttributeView.Clear;
begin
  InternalClear;
end;

function TPressMVPAttributeView.GetAsString: string;
begin
  Result := '';
end;

procedure TPressMVPAttributeView.InternalClear;
begin
end;

procedure TPressMVPAttributeView.InternalUpdateModel(AAttribute: TPressAttribute);
begin
end;

procedure TPressMVPAttributeView.InternalUpdateView(AAttribute: TPressAttribute);
begin
end;

procedure TPressMVPAttributeView.SetSize(Value: Integer);
begin
end;

procedure TPressMVPAttributeView.UpdateModel(AAttribute: TPressAttribute);
begin
  if Assigned(AAttribute) then
    InternalUpdateModel(AAttribute);
end;

procedure TPressMVPAttributeView.UpdateView(AAttribute: TPressAttribute);
begin
  InternalUpdateView(AAttribute);
end;

{ TPressMVPWinView }

procedure TPressMVPWinView.InitView;
begin
  inherited;
  with TPressMVPViewWinControlFriend(Control) do
  begin
    FViewEnterEvent := OnEnter;
    FViewExitEvent := OnExit;
    FViewKeyDownEvent := OnKeyDown;
    FViewKeyPressEvent := OnKeyPress;
    FViewKeyUpEvent := OnKeyUp;
    OnEnter := ViewEnterEvent;
    OnExit := ViewExitEvent;
    OnKeyDown := ViewKeyDownEvent;
    OnKeyPress := ViewKeyPressEvent;
    OnKeyUp := ViewKeyUpEvent;
  end;
end;

procedure TPressMVPWinView.SelectNext;
var
  VWinControl: TWinControl;
begin
  VWinControl := Control.Parent;
  if Assigned(VWinControl) then
  begin
    while Assigned(VWinControl.Parent) do
      VWinControl := VWinControl.Parent;
    TPressMVPViewWinControlFriend(VWinControl).SelectNext(
     Control as TWinControl, True, True);
  end;
end;

procedure TPressMVPWinView.SetFocus;
begin
  (Control as TWinControl).SetFocus;
end;

procedure TPressMVPWinView.ViewEnterEvent(Sender: TObject);
begin
  if EventsDisabled then
    Exit;
  TPressMVPViewEnterEvent.Create(Self).Notify;
  if Assigned(FViewEnterEvent) then
    FViewEnterEvent(Sender);
end;

procedure TPressMVPWinView.ViewExitEvent(Sender: TObject);
begin
  if EventsDisabled then
    Exit;
  TPressMVPViewExitEvent.Create(Self).Notify;
  if Assigned(FViewExitEvent) then
    FViewExitEvent(Sender);
end;

procedure TPressMVPWinView.ViewKeyDownEvent(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if EventsDisabled then
    Exit;
  TPressMVPViewKeyDownEvent.Create(Self, Key, Shift).Notify;
  if (Key <> 0) and Assigned(FViewKeyDownEvent) then
    FViewKeyDownEvent(Sender, Key, Shift);
end;

procedure TPressMVPWinView.ViewKeyPressEvent(Sender: TObject; var Key: Char);
begin
  if EventsDisabled then
    Exit;
  TPressMVPViewKeyPressEvent.Create(Self, Key).Notify;
  if (Key <> #0) and Assigned(FViewKeyPressEvent) then
    FViewKeyPressEvent(Sender, Key);
end;

procedure TPressMVPWinView.ViewKeyUpEvent(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if EventsDisabled then
    Exit;
  TPressMVPViewKeyUpEvent.Create(Self, Key, Shift).Notify;
  if (Key <> 0) and Assigned(FViewKeyUpEvent) then
    FViewKeyUpEvent(Sender, Key, Shift);
end;

{ TPressMVPEditView }

class function TPressMVPEditView.Apply(AControl: TControl): Boolean;
begin
  Result := AControl is TCustomEdit;
end;

function TPressMVPEditView.GetAsString: string;
begin
  Result := TPressMVPViewCustomEditFriend(Control).Text;
end;

function TPressMVPEditView.GetControl: TCustomEdit;
begin
  Result := inherited Control as TCustomEdit;
end;

procedure TPressMVPEditView.InitView;
begin
  inherited;
  with TPressMVPViewCustomEditFriend(Control) do
  begin
    FViewChangeEvent := OnChange;
    OnChange := ViewChangeEvent;
  end;
end;

procedure TPressMVPEditView.InternalClear;
begin
  TPressMVPViewCustomEditFriend(Control).Text := '';
end;

procedure TPressMVPEditView.InternalUpdateModel(AAttribute: TPressAttribute);
begin
  if Changed then
    AAttribute.AsString := TPressMVPViewCustomEditFriend(Control).Text;
end;

procedure TPressMVPEditView.InternalUpdateView(AAttribute: TPressAttribute);
begin
  if Assigned(AAttribute) then
    if Control.Focused then
    begin
      TPressMVPViewCustomEditFriend(Control).Text := AAttribute.AsString;
      Control.SelectAll;
    end else
      TPressMVPViewCustomEditFriend(Control).Text := AAttribute.DisplayText
  else
    TPressMVPViewCustomEditFriend(Control).Text := '';
end;

procedure TPressMVPEditView.SetFocus;
begin
  inherited;
  Control.SelectAll;
end;

procedure TPressMVPEditView.SetSize(Value: Integer);
begin
  TPressMVPViewCustomEditFriend(Control).MaxLength := Value;
end;

procedure TPressMVPEditView.ViewChangeEvent(Sender: TObject);
begin
  if EventsDisabled then
    Exit;
  FChanged := True;
  if Assigned(FViewChangeEvent) then
    FViewChangeEvent(Sender);
end;

procedure TPressMVPEditView.ViewEnterEvent(Sender: TObject);
begin
  inherited;
  FChanged := False;
end;

{ TPressMVPDateTimeView }

class function TPressMVPDateTimeView.Apply(AControl: TControl): Boolean;
begin
  Result := AControl is TCustomCalendar;
end;

function TPressMVPDateTimeView.GetAsString: string;
begin
  Result := TPressMVPViewCustomCalendarFriend(Control).Text;
end;

function TPressMVPDateTimeView.GetControl: TCustomCalendar;
begin
  Result := inherited Control as TCustomCalendar;
end;

procedure TPressMVPDateTimeView.InternalClear;
begin
  TPressMVPViewCustomCalendarFriend(Control).DateTime := 0;
end;

procedure TPressMVPDateTimeView.InternalUpdateModel(AAttribute: TPressAttribute);
begin
  AAttribute.AsDateTime := TPressMVPViewCustomCalendarFriend(Control).DateTime;
end;

procedure TPressMVPDateTimeView.InternalUpdateView(AAttribute: TPressAttribute);
begin
  if Assigned(AAttribute) then
    TPressMVPViewCustomCalendarFriend(Control).DateTime := AAttribute.AsDateTime;
  { TODO : else? }
end;

{ TPressMVPCheckBoxView }

class function TPressMVPCheckBoxView.Apply(AControl: TControl): Boolean;
begin
  Result := AControl is TCustomCheckBox;
end;

function TPressMVPCheckBoxView.GetControl: TCustomCheckBox;
begin
  Result := inherited Control as TCustomCheckBox;
end;

procedure TPressMVPCheckBoxView.InternalClear;
begin
  TPressMVPViewCustomCheckBoxFriend(Control).State := cbUnchecked;
end;

procedure TPressMVPCheckBoxView.InternalUpdateModel(AAttribute: TPressAttribute);
begin
  AAttribute.AsBoolean :=
   TPressMVPViewCustomCheckBoxFriend(Control).State = cbChecked;
end;

procedure TPressMVPCheckBoxView.InternalUpdateView(AAttribute: TPressAttribute);
begin
  if Assigned(AAttribute) and AAttribute.AsBoolean then
    TPressMVPViewCustomCheckBoxFriend(Control).State := cbChecked
  else
    TPressMVPViewCustomCheckBoxFriend(Control).State := cbUnchecked;
end;

{ TPressMVPItemView }

procedure TPressMVPItemView.AddReference(const ACaption: string; AReference: TPressObject);
begin
  InternalAddReference(ACaption, AReference);
  { TODO : Release instance before ClearReferences
    (like updating or destroying the visual control) } 
//  AReference.AddRef;
end;

procedure TPressMVPItemView.ClearReferences;
begin
  InternalClearReferences;
end;

function TPressMVPItemView.CurrentItem: Integer;
begin
  Result := InternalCurrentItem;
end;

{ TPressMVPComboBoxView }

class function TPressMVPComboBoxView.Apply(AControl: TControl): Boolean;
begin
  Result := AControl is TCustomComboBox;
end;

function TPressMVPComboBoxView.GetAsString: string;
begin
  Result := TPressMVPViewCustomComboBoxFriend(Control).Text;
end;

function TPressMVPComboBoxView.GetComboStyle: TComboBoxStyle;
begin
  Result := TPressMVPViewCustomComboBoxFriend(Control).Style;
end;

function TPressMVPComboBoxView.GetControl: TCustomComboBox;
begin
  Result := inherited Control as TCustomComboBox;
end;

function TPressMVPComboBoxView.GetDroppedDown: Boolean;
begin
  Result := Control.DroppedDown;
end;

procedure TPressMVPComboBoxView.InitView;
begin
  inherited;
  with TPressMVPViewCustomComboBoxFriend(Control) do
  begin
    FViewChangeEvent := OnChange;
    FViewDropDownEvent := OnDropDown;
    OnChange := ViewChangeEvent;
    OnDropDown := ViewDropDownEvent;
    Style := csDropDown;
  end;
end;

procedure TPressMVPComboBoxView.InternalAddReference(
  const ACaption: string; AReference: TPressObject);
begin
  Control.Items.AddObject(ACaption, AReference);
end;

procedure TPressMVPComboBoxView.InternalClear;
begin
  ClearReferences;
  TPressMVPViewCustomComboBoxFriend(Control).Text := '';
  FChanged := True;
end;

procedure TPressMVPComboBoxView.InternalClearReferences;
begin
  Control.Items.Clear;
end;

function TPressMVPComboBoxView.InternalCurrentItem: Integer;
begin
  Result := Control.ItemIndex;
end;

procedure TPressMVPComboBoxView.InternalUpdateModel(AAttribute: TPressAttribute);
var
  VObject: TPressObject;
begin
  if AAttribute is TPressReference then
  begin
    if AsString = '' then
      VObject := nil
    else if Control.ItemIndex >= 0 then
      VObject := Control.Items.Objects[Control.ItemIndex] as TPressObject
    else if Control.Items.Count = 1 then
      VObject := Control.Items.Objects[0] as TPressObject
    else
      VObject := nil;
    TPressReference(AAttribute).Value := VObject;
  end else if (AAttribute is TPressEnum) then
    if Control.ItemIndex = -1 then
      AAttribute.Clear
    else
      AAttribute.AsInteger := Control.ItemIndex;
end;

procedure TPressMVPComboBoxView.InternalUpdateView(AAttribute: TPressAttribute);
begin
  { TODO : Wrong aproach -- fix }
  if AAttribute is TPressEnum then
  begin
    if AAttribute.IsNull then
      Control.ItemIndex := -1
    else
      Control.ItemIndex := AAttribute.AsInteger;
  end else
  begin
    Control.Items.Clear;
    if Assigned(AAttribute) then
    begin
      TPressMVPViewCustomComboBoxFriend(Control).Text := AAttribute.DisplayText;
      Control.Items.AddObject(AAttribute.DisplayText, AAttribute.Owner);
      Control.ItemIndex := 0;
    end else
      TPressMVPViewCustomComboBoxFriend(Control).Text := '';
  end;
end;

procedure TPressMVPComboBoxView.SelectAll;
begin
  Control.SelectAll;
end;

procedure TPressMVPComboBoxView.SetComboStyle(Value: TComboBoxStyle);
begin
  TPressMVPViewCustomComboBoxFriend(Control).Style := Value;
end;

procedure TPressMVPComboBoxView.SetSize(Value: Integer);
begin
  TPressMVPViewCustomComboBoxFriend(Control).MaxLength := Value;
end;

procedure TPressMVPComboBoxView.ShowReferences;
begin
  DisableEvents;
  try
    Control.DroppedDown := False;
    Control.DroppedDown := True;
    Control.SelectAll;
  finally
    EnableEvents;
  end;
end;

procedure TPressMVPComboBoxView.ViewChangeEvent(Sender: TObject);
begin
  if EventsDisabled then
    Exit;
  FChanged := True;
  if Assigned(FViewChangeEvent) then
    FViewChangeEvent(Sender);
end;

procedure TPressMVPComboBoxView.ViewDropDownEvent(Sender: TObject);
begin
  if EventsDisabled then
    Exit;
  TPressMVPViewDropDownEvent.Create(Self).Notify;
  if Assigned(FViewDropDownEvent) then
    FViewDropDownEvent(Sender);
end;

procedure TPressMVPComboBoxView.ViewEnterEvent(Sender: TObject);
begin
  if EventsDisabled then
    Exit;
  inherited;
  FChanged := False;
end;

{ TPressMVPItemsView }

procedure TPressMVPItemsView.AlignColumns;
begin
  InternalAlignColumns;
end;

function TPressMVPItemsView.CurrentItem: Integer;
begin
  Result := InternalCurrentItem;
end;

function TPressMVPItemsView.GetRowCount: Integer;
begin
  Result := InternalGetRowCount;
end;

procedure TPressMVPItemsView.InternalAlignColumns;
begin
end;

procedure TPressMVPItemsView.InternalSetColumnCount(AColumnCount: Integer);
begin
end;

procedure TPressMVPItemsView.InternalSetColumnWidth(AColumn, AWidth: Integer);
begin
end;

procedure TPressMVPItemsView.InternalUpdateView(AAttribute: TPressAttribute);
begin
  Control.Invalidate;
end;

procedure TPressMVPItemsView.SelectItem(AIndex: Integer);
var
  VRowCount: Integer;
begin
  { TODO : Improve, moving RowCount check to presenter }
  VRowCount := RowCount;
  if AIndex = VRowCount then
    RowCount := VRowCount + 1;

  InternalSelectItem(AIndex);
end;

procedure TPressMVPItemsView.SetColumnCount(AColumnCount: Integer);
begin
  InternalSetColumnCount(AColumnCount);
end;

procedure TPressMVPItemsView.SetColumnWidth(AColumn, AWidth: Integer);
begin
  InternalSetColumnWidth(AColumn, AWidth);
end;

procedure TPressMVPItemsView.SetRowCount(ARowCount: Integer);
begin
  InternalSetRowCount(ARowCount);
end;

{ TPressMVPListBoxView }

class function TPressMVPListBoxView.Apply(AControl: TControl): Boolean;
begin
  Result := AControl is TCustomListBox;
end;

function TPressMVPListBoxView.GetControl: TCustomListBox;
begin
  Result := inherited Control as TCustomListBox;
end;

procedure TPressMVPListBoxView.InitView;
begin
  inherited;
  with TPressMVPViewCustomListBoxFriend(Control) do
  begin
    FViewDrawItemEvent := OnDrawItem;
    OnDrawItem := ViewDrawItemEvent;
    Style := lbOwnerDrawFixed;
    { TODO : Implement multi selection }
    //MultiSelect := True;
  end;
end;

function TPressMVPListBoxView.InternalCurrentItem: Integer;
begin
  Result := Control.ItemIndex;
end;

function TPressMVPListBoxView.InternalGetRowCount: Integer;
begin
  Result := Control.Items.Count;
end;

procedure TPressMVPListBoxView.InternalSelectItem(AIndex: Integer);
begin
  Control.ItemIndex := AIndex;
end;

procedure TPressMVPListBoxView.InternalSetRowCount(ARowCount: Integer);
var
  VStrings: TStrings;
begin
  VStrings := Control.Items;
  VStrings.BeginUpdate;
  try
    while VStrings.Count < ARowCount do
      VStrings.Add('');
    while VStrings.Count > ARowCount do
      VStrings.Delete(VStrings.Count - 1);
  finally
    VStrings.EndUpdate;
  end;
end;

procedure TPressMVPListBoxView.ViewDrawItemEvent(AControl: TWinControl;
  AIndex: Integer; ARect: TRect; State: TOwnerDrawState);
begin
  if EventsDisabled then
    Exit;
  {$IFDEF PressViewNotification}
  TPressMVPViewDrawItemEvent.Create(
   Self, Control.Canvas, AIndex, ARect, State).Notify;
  {$ENDIF}
  {$IFDEF PressViewDirectEvent}
  if Assigned(FOnDrawItem) then
    FOnDrawItem(Self, Control.Canvas, AIndex, ARect, State);
  {$ENDIF}
  if Assigned(FViewDrawItemEvent) then
    FViewDrawItemEvent(Control, AIndex, ARect, State);
end;

{ TPressMVPGridView }

class function TPressMVPGridView.Apply(AControl: TControl): Boolean;
begin
  Result := AControl is TDrawGrid;
end;

function TPressMVPGridView.GetControl: TDrawGrid;
begin
  Result := inherited Control as TDrawGrid;
end;

procedure TPressMVPGridView.InitView;
begin
  inherited;
  with Control do
  begin
    FViewDrawCellEvent := OnDrawCell;
    FViewSelectCellEvent := OnSelectCell;
    OnDrawCell := ViewDrawCellEvent;
    OnSelectCell := ViewSelectCellEvent;
    { TODO : Implement multi selection }
    Options := Options + [goColSizing, goRowSelect] - [goHorzLine, goRangeSelect];
    FixedCols := 1;
    FixedRows := 1;
    ColCount := 2;
    RowCount := 2;
    DefaultColWidth := 48;
    DefaultRowHeight := 16;
    ColWidths[0] := 24;
  end;
end;

procedure TPressMVPGridView.InternalAlignColumns;
var
  VControl: TDrawGrid;
  VColCount, VClientWidth, VTotalWidth, VDiff, VDelta: Integer;
  I: Integer;
begin
  VControl := Control;
  VColCount := VControl.ColCount;
  if VColCount < 2 then
    Exit;
  VClientWidth := VControl.ClientWidth;
  VTotalWidth := 0;
  for I := 0 to Pred(VColCount) do
    VTotalWidth := VTotalWidth + VControl.ColWidths[I];
  VDiff := VTotalWidth + VColCount - VClientWidth;
  I := 1;
  while VDiff > 0 do
  begin
    VDelta := VDiff div (VColCount - I);
    VControl.ColWidths[I] := VControl.ColWidths[I] - VDelta;
    VDiff := VDiff - VDelta;
    Inc(I);
  end;
end;

function TPressMVPGridView.InternalCurrentItem: Integer;
begin
  Result := Control.Row - 1;
end;

function TPressMVPGridView.InternalGetRowCount: Integer;
begin
  Result := Control.RowCount - 1;
end;

procedure TPressMVPGridView.InternalSelectItem(AIndex: Integer);
begin
  Control.Row := AIndex + 1;
end;

procedure TPressMVPGridView.InternalSetColumnCount(AColumnCount: Integer);
begin
  if AColumnCount > 0 then
    Control.ColCount := AColumnCount + 1
  else
    Control.ColCount := 2;
end;

procedure TPressMVPGridView.InternalSetColumnWidth(AColumn, AWidth: Integer);
begin
  Control.ColWidths[AColumn + 1] := AWidth;
end;

procedure TPressMVPGridView.InternalSetRowCount(ARowCount: Integer);
begin
  if ARowCount > 0 then
    Control.RowCount := ARowCount + 1
  else
    Control.RowCount := 2;
end;

procedure TPressMVPGridView.ViewDrawCellEvent(
  Sender: TObject; ACol, ARow: Integer;
  ARect: TRect; State: TGridDrawState);
begin
  if EventsDisabled then
    Exit;
  {$IFDEF PressViewNotification}
  TPressMVPViewDrawCellEvent.Create(
   Self, Control.Canvas, ACol - 1, ARow - 1, ARect, State).Notify;
  {$ENDIF}
  {$IFDEF PressViewDirectEvent}
  if Assigned(FOnDrawCell) then
    FOnDrawCell(Self, Control.Canvas, ACol - 1, ARow - 1, ARect, State);
  {$ENDIF}
  if Assigned(FViewDrawCellEvent) then
    FViewDrawCellEvent(Sender, ACol, ARow, ARect, State);
end;

procedure TPressMVPGridView.ViewSelectCellEvent(
  Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  if EventsDisabled then
    Exit;
  {$IFDEF PressViewNotification}
  TPressMVPViewSelectCellEvent.Create(
   Self, ACol - 1, ARow - 1, CanSelect).Notify;
  {$ENDIF}
  {$IFDEF PressViewDirectEvent}
  if Assigned(FOnSelectCell) then
    FOnSelectCell(Self, ACol - 1, ARow - 1, CanSelect);
  {$ENDIF}
  if Assigned(FViewSelectCellEvent) then
    FViewSelectCellEvent(Sender, ACol, ARow, CanSelect);
end;

{ TPressMVPLabelView }

class function TPressMVPLabelView.Apply(AControl: TControl): Boolean;
begin
  Result := AControl is TCustomLabel;
end;

function TPressMVPLabelView.GetControl: TCustomLabel;
begin
  Result := inherited Control as TCustomLabel;
end;

function TPressMVPLabelView.GetAsString: string;
begin
  Result := TPressMVPViewCustomLabelFriend(Control).Caption;
end;

procedure TPressMVPLabelView.InternalUpdateModel(AAttribute: TPressAttribute);
begin
  AAttribute.AsString := TPressMVPViewCustomLabelFriend(Control).Caption;
end;

procedure TPressMVPLabelView.InternalUpdateView(AAttribute: TPressAttribute);
begin
  if Assigned(AAttribute) then
    TPressMVPViewCustomLabelFriend(Control).Caption := AAttribute.DisplayText
  else
    TPressMVPViewCustomLabelFriend(Control).Caption := '';
end;

{ TPressMVPPictureView }

class function TPressMVPPictureView.Apply(AControl: TControl): Boolean;
begin
  Result := AControl is TImage;
end;

function TPressMVPPictureView.GetControl: TImage;
begin
  Result := inherited Control as TImage;
end;

procedure TPressMVPPictureView.InternalUpdateModel(AAttribute: TPressAttribute);
begin
end;

procedure TPressMVPPictureView.InternalUpdateView(AAttribute: TPressAttribute);
begin
  { TODO : Implement }
end;

{ TPressMVPFormView }

class function TPressMVPFormView.Apply(AControl: TControl): Boolean;
begin
  Result := AControl is TCustomForm;
end;

procedure TPressMVPFormView.Close;
begin
  Control.Close;
end;

function TPressMVPFormView.GetControl: TCustomForm;
begin
  Result := inherited Control as TCustomForm;
end;

procedure TPressMVPFormView.InitView;
begin
  inherited;
  with TPressMVPViewCustomFormFriend(Control) do
  begin
    FViewCloseEvent := OnClose;
    OnClose := ViewCloseEvent;
  end;
end;

procedure TPressMVPFormView.ViewCloseEvent(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(FViewCloseEvent) then
    FViewCloseEvent(Sender, Action);
  if Action = caFree then
    OwnsControl := False;
  { TODO : Check AV when Action = caFree due to queue notification }
  TPressMVPViewCloseFormEvent.Create(Self).Notify;
end;

{ TPressMVPFrameView }

class function TPressMVPFrameView.Apply(AControl: TControl): Boolean;
begin
  Result := AControl is TCustomFrame;
end;

function TPressMVPFrameView.GetControl: TCustomFrame;
begin
  Result := inherited Control as TCustomFrame;
end;

procedure RegisterViews;
begin
  TPressMVPEditView.RegisterView;
  TPressMVPDateTimeView.RegisterView;
  TPressMVPCheckBoxView.RegisterView;
  TPressMVPListBoxView.RegisterView;
  TPressMVPComboBoxView.RegisterView;
  TPressMVPGridView.RegisterView;
  TPressMVPLabelView.RegisterView;
  TPressMVPPictureView.RegisterView;
  TPressMVPFormView.RegisterView;
end;

initialization
  RegisterViews;

end.
