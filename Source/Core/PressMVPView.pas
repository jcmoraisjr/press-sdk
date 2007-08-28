(*
  PressObjects, MVP-View Classes
  Copyright (C) 2006-2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressMVPView;

{$I Press.inc}

interface

uses
  Classes,
  Graphics,
  Controls,
  StdCtrls,
  ExtCtrls,
  Grids,
  Forms,
  PressCompatibility,
  PressNotifier,
  PressSubject,
  PressUser,
  PressMVP,
  PressMVPModel;

type
  { TPressMVPViewEvent }

  TPressMVPView = class;

  TPressMVPViewEvent = class(TPressEvent)
  private
    function GetOwner: TPressMVPView;
  protected
    {$IFNDEF PressLogViewEvents}
    function AllowLog: Boolean; override;
    {$ENDIF}
  public
    constructor Create(AOwner: TPressMVPView);
    property Owner: TPressMVPView read GetOwner;
  end;

  TPressMVPViewClickEvent = class(TPressMVPViewEvent)
  end;

  TPressMVPViewDblClickEvent = class(TPressMVPViewEvent)
  end;

  TPressMVPViewMouseEvent = class(TPressMVPViewEvent)
  private
    FMouseButton: TMouseButton;
    FShiftState: TShiftState;
    FX: Integer;
    FY: Integer;
  public
    constructor Create(AOwner: TPressMVPView; AMouseButton: TMouseButton; AShiftState: TShiftState; AX, AY: Integer);
    property MouseButton: TMouseButton read FMouseButton;
    property ShiftState: TShiftState read FShiftState;
    property X: Integer read FX;
    property Y: Integer read FY;
  end;

  TPressMVPViewMouseDownEvent = class(TPressMVPViewMouseEvent)
  end;

  TPressMVPViewMouseUpEvent = class(TPressMVPViewMouseEvent)
  end;

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
    constructor Create(AOwner: TPressMVPView; var AKey: Char);
    property Key: Char read GetKey write SetKey;
  end;

  TPressMVPViewKeyEvent = class(TPressMVPViewKeyboardEvent)
  private
    FKey: ^Word;
    FShift: TShiftState;
    function GetKey: Word;
    procedure SetKey(const Value: Word);
  public
    constructor Create(AOwner: TPressMVPView; var AKey: Word; AShift: TShiftState);
    property Key: Word read GetKey write SetKey;
    property Shift: TShiftState read FShift;
  end;

  TPressMVPViewKeyDownEvent = class(TPressMVPViewKeyEvent)
  end;

  TPressMVPViewKeyUpEvent = class(TPressMVPViewKeyEvent)
  end;

  TPressMVPViewDropDownEvent = class(TPressMVPViewEvent)
  end;

  TPressMVPViewSelectEvent = class(TPressMVPViewEvent)
  end;

  TPressMVPGridView = class;

  {$IFDEF PressViewNotification}
  TPressMVPViewDrawItemEvent = class(TPressMVPViewEvent)
  private
    FCanvas: TCanvas;
    FItemIndex: Integer;
    FState: TOwnerDrawState;
    FRect: TRect;
    function GetOwner: TPressMVPView;
  public
    constructor Create(AOwner: TPressMVPView; ACanvas: TCanvas; AItemIndex: Integer; ARect: TRect; State: TOwnerDrawState);
    property Canvas: TCanvas read FCanvas;
    property ItemIndex: Integer read FItemIndex;
    property Owner: TPressMVPView read GetOwner;
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

  TPressMVPViewClickHeaderEvent = class(TPressMVPViewEvent)
  private
    FButton: TMouseButton;
    FCol: Integer;
    FShiftState: TShiftState;
  public
    constructor Create(AOwner: TPressMVPView; AButton: TMouseButton; AShiftState: TShiftState; ACol: Integer);
    property Button: TMouseButton read FButton;
    property Col: Integer read FCol;
    property ShiftState: TShiftState read FShiftState;
  end;

  TPressMVPViewClickCellEvent = class(TPressMVPViewEvent)
  private
    FButton: TMouseButton;
    FCol: Integer;
    FRow: Integer;
    FShiftState: TShiftState;
  public
    constructor Create(AOwner: TPressMVPView; AButton: TMouseButton; AShiftState: TShiftState; ACol, ARow: Integer);
    property Button: TMouseButton read FButton;
    property Col: Integer read FCol;
    property Row: Integer read FRow;
    property ShiftState: TShiftState read FShiftState;
  end;
  {$ENDIF}

  TPressMVPViewFormEvent = class(TPressMVPViewEvent)
  end;

  TPressMVPViewCloseFormEvent = class(TPressMVPViewFormEvent)
  end;

  { TPressMVPView }

  TPressMVPViewClass = class of TPressMVPView;

  TPressMVPView = class(TPressMVPObject)
  private
    FAccessMode: TPressAccessMode;
    FControl: TControl;
    FIsChanged: Boolean;
    FModel: TPressMVPModel;
    FNotifier: TPressNotifier;
    FOwnsControl: Boolean;
    FViewClickEvent: TNotifyEvent;
    FViewDblClickEvent: TNotifyEvent;
    FViewMouseDownEvent: TMouseEvent;
    FViewMouseUpEvent: TMouseEvent;
    function GetModel: TPressMVPModel;
    function GetReadOnly: Boolean;
    procedure SetAccessMode(Value: TPressAccessMode);
    procedure SetReadOnly(Value: Boolean);
  protected
    procedure ViewClickEvent(Sender: TObject); virtual;
    procedure ViewDblClickEvent(Sender: TObject); virtual;
    procedure ViewMouseDownEvent(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure ViewMouseUpEvent(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
  protected
    procedure Changed;
    procedure InitView; virtual;
    procedure InternalAccessModeUpdated; virtual;
    procedure InternalReset; virtual;
    procedure InternalUpdate; virtual;
    procedure ModelChanged(AChangeType: TPressMVPChangeType); virtual;
    procedure Notify(AEvent: TPressEvent);
    procedure ReleaseControl; virtual;
    procedure SetModel(Value: TPressMVPModel);
    procedure Unchanged;
    property Model: TPressMVPModel read GetModel;
  public
    constructor Create(AControl: TControl; AOwnsControl: Boolean = False);
    destructor Destroy; override;
    class function Apply(AControl: TControl): Boolean; virtual; abstract;
    { TODO : Remove this factory method }
    class function CreateFromControl(AControl: TControl; AOwnsControl: Boolean = False): TPressMVPView;
    class procedure RegisterView;
    procedure Update;
    property AccessMode: TPressAccessMode read FAccessMode write SetAccessMode;
    property Control: TControl read FControl;
    property IsChanged: Boolean read FIsChanged;
    property OwnsControl: Boolean read FOwnsControl write FOwnsControl;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly;
  end;

  TPressMVPAttributeView = class(TPressMVPView)
  private
    function AccessError(const ADataType: string): EPressMVPError;
    function GetModel: TPressMVPAttributeModel;
  protected
    function GetAsBoolean: Boolean; virtual;
    function GetAsDateTime: TDateTime; virtual;
    function GetAsInteger: Integer; virtual;
    function GetAsString: string; virtual;
    function GetIsClear: Boolean; virtual;
    procedure InternalClear; virtual;
    procedure SetSize(Value: Integer); virtual;
  public
    destructor Destroy; override;
    procedure Clear;
    property AsBoolean: Boolean read GetAsBoolean;
    property AsDateTime: TDateTime read GetAsDateTime;
    property AsInteger: Integer read GetAsInteger;
    property AsString: string read GetAsString;
    property IsClear: Boolean read GetIsClear;
    property Model: TPressMVPAttributeModel read GetModel;
    property Size: Integer write SetSize;
  end;

  TPressMVPWinView = class(TPressMVPAttributeView)
  private
    FViewEnterEvent: TNotifyEvent;
    FViewExitEvent: TNotifyEvent;
    FViewKeyDownEvent: TKeyEvent;
    FViewKeyPressEvent: TKeyPressEvent;
    FViewKeyUpEvent: TKeyEvent;
  private
    procedure UpdateRelatedLabel;
  protected
    procedure ViewEnterEvent(Sender: TObject); virtual;
    procedure ViewExitEvent(Sender: TObject); virtual;
    procedure ViewKeyDownEvent(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
    procedure ViewKeyPressEvent(Sender: TObject; var Key: Char); virtual;
    procedure ViewKeyUpEvent(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
  protected
    procedure InitView; override;
    procedure InternalAccessModeUpdated; override;
    procedure ReleaseControl; override;
  public
    procedure SelectNext; virtual;
    procedure SetFocus;
  end;

  TPressMVPEditView = class(TPressMVPWinView)
  private
    FViewChangeEvent: TNotifyEvent;
    function GetControl: TCustomEdit;
    function GetSelectedText: string;
  protected
    procedure ViewChangeEvent(Sender: TObject); virtual;
    procedure ViewEnterEvent(Sender: TObject); override;
  protected
    function GetAsString: string; override;
    function GetIsClear: Boolean; override;
    procedure InitView; override;
    procedure InternalClear; override;
    procedure InternalUpdate; override;
    procedure ReleaseControl; override;
    procedure SetSize(Value: Integer); override;
  public
    class function Apply(AControl: TControl): Boolean; override;
    property Control: TCustomEdit read GetControl;
    property SelectedText: string read GetSelectedText;
  end;

  TPressMVPDateTimeView = class(TPressMVPWinView)
  private
    function GetControl: TCustomCalendar;
  protected
    procedure ViewClickEvent(Sender: TObject); override;
  protected
    function GetAsDateTime: TDateTime; override;
    function GetAsString: string; override;
    function GetIsClear: Boolean; override;
    procedure InternalClear; override;
    procedure InternalUpdate; override;
  public
    class function Apply(AControl: TControl): Boolean; override;
    property Control: TCustomCalendar read GetControl;
  end;

  TPressMVPBooleanView = class(TPressMVPWinView)
  protected
    procedure ViewClickEvent(Sender: TObject); override;
  end;

  TPressMVPCheckBoxView = class(TPressMVPBooleanView)
  private
    function GetControl: TCustomCheckBox;
  protected
    function GetAsBoolean: Boolean; override;
    function GetIsClear: Boolean; override;
    procedure InternalClear; override;
    procedure InternalUpdate; override;
  public
    class function Apply(AControl: TControl): Boolean; override;
    property Control: TCustomCheckBox read GetControl;
  end;

  TPressDrawItemEvent = procedure(Sender: TPressMVPView;
   ACanvas: TCanvas; AIndex: Integer; ARect: TRect; State: TOwnerDrawState) of object;

  TPressMVPItemView = class(TPressMVPWinView)
  protected
    procedure ViewEnterEvent(Sender: TObject); override;
    procedure ViewExitEvent(Sender: TObject); override;
  protected
    function GetReferencesVisible: Boolean; virtual;
    function GetSelectedText: string; virtual;
    procedure InternalAddReference(const ACaption: string); virtual; abstract;
    procedure InternalClearReferences; virtual; abstract;
  public
    procedure AddReference(const ACaption: string);
    procedure AssignReferences(AItems: TStrings);
    procedure ClearReferences;
    property ReferencesVisible: Boolean read GetReferencesVisible;
    property SelectedText: string read GetSelectedText;
  end;

  TPressMVPComboBoxView = class(TPressMVPItemView)
  private
    {$IFDEF PressViewDirectEvent}
    FOnDrawItem: TPressDrawItemEvent;
    {$ENDIF}
    FViewChangeEvent: TNotifyEvent;
    FViewDrawItemEvent: TDrawItemEvent;
    FViewDropDownEvent: TNotifyEvent;
    {$IFDEF FPC}
    FViewSelectEvent: TNotifyEvent;
    {$ENDIF}
    function GetControl: TCustomComboBox;
  protected
    procedure ViewChangeEvent(Sender: TObject); virtual;
    {$IFNDEF FPC}
    procedure ViewClickEvent(Sender: TObject); override;
    {$ENDIF}
    procedure ViewDrawItemEvent(AControl: TWinControl; AIndex: Integer; ARect: TRect; AState: TOwnerDrawState); virtual;
    procedure ViewDropDownEvent(Sender: TObject); virtual;
    {$IFDEF FPC}
    procedure ViewSelectEvent(Sender: TObject); virtual;
    {$ENDIF}
  protected
    function GetAsInteger: Integer; override;
    function GetAsString: string; override;
    function GetIsClear: Boolean; override;
    function GetReferencesVisible: Boolean; override;
    function GetSelectedText: string; override;
    procedure InitView; override;
    procedure InternalAddReference(const ACaption: string); override;
    procedure InternalClear; override;
    procedure InternalClearReferences; override;
    procedure InternalUpdate; override;
    procedure ReleaseControl; override;
    procedure SetSize(Value: Integer); override;
  public
    class function Apply(AControl: TControl): Boolean; override;
    procedure HideReferences;
    procedure SelectAll;
    procedure ShowReferences;
    property Control: TCustomComboBox read GetControl;
    {$IFDEF PressViewDirectEvent}
    property OnDrawItem: TPressDrawItemEvent read FOnDrawItem write FOnDrawItem;
    {$ENDIF}
  end;

  TPressMVPItemsView = class(TPressMVPWinView)
  private
    function GetModel: TPressMVPItemsModel;
    function GetRowCount: Integer;
    procedure SetRowCount(ARowCount: Integer);
  protected
    function InternalCurrentItem: Integer; virtual; abstract;
    function InternalGetRowCount: Integer; virtual; abstract;
    procedure InternalSelectItem(AIndex: Integer); virtual; abstract;
    procedure InternalSetColumnCount(AColumnCount: Integer); virtual;
    procedure InternalSetColumnWidth(AColumn, AWidth: Integer); virtual;
    procedure InternalSetRowCount(ARowCount: Integer); virtual; abstract;
    procedure InternalUpdate; override;
    property RowCount: Integer read GetRowCount write SetRowCount;
  public
    function CurrentItem: Integer;
    procedure SelectItem(AIndex: Integer);
    property Model: TPressMVPItemsModel read GetModel;
  end;

  TPressMVPListBoxView = class(TPressMVPItemsView)
  private
    {$IFDEF PressViewDirectEvent}
    FOnDrawItem: TPressDrawItemEvent;
    {$ENDIF}
    FViewDrawItemEvent: TDrawItemEvent;
    procedure ViewDrawItemEvent(AControl: TWinControl; AIndex: Integer; ARect: TRect; AState: TOwnerDrawState); virtual;
    function GetControl: TCustomListBox;
  protected
    procedure InitView; override;
    function InternalCurrentItem: Integer; override;
    function InternalGetRowCount: Integer; override;
    procedure InternalSelectItem(AIndex: Integer); override;
    procedure InternalSetRowCount(ARowCount: Integer); override;
    procedure ReleaseControl; override;
  public
    class function Apply(AControl: TControl): Boolean; override;
    property Control: TCustomListBox read GetControl;
    {$IFDEF PressViewDirectEvent}
    property OnDrawItem: TPressDrawItemEvent read FOnDrawItem write FOnDrawItem;
    {$ENDIF}
  end;

  TPressClickCellEvent = procedure(AOwner: TPressMVPView;
   AButton: TMouseButton; AShiftState: TShiftState; ACol, ARow: Integer) of object;

  TPressClickHeaderEvent = procedure(AOwner: TPressMVPView;
   AButton: TMouseButton; AShiftState: TShiftState; ACol: Integer) of object;

  TPressDrawCellEvent = procedure(Sender: TPressMVPGridView; ACanvas: TCanvas;
   ACol, ARow: Longint; ARect: TRect; State: TGridDrawState) of object;

  TPressMVPGridView = class(TPressMVPItemsView)
  private
    {$IFDEF PressViewDirectEvent}
    FOnClickCell: TPressClickCellEvent;
    FOnClickHeader: TPressClickHeaderEvent;
    FOnDrawCell: TPressDrawCellEvent;
    {$ENDIF}
    FViewDrawCellEvent: TDrawCellEvent;
    function GetControl: TCustomDrawGrid;
  protected
    procedure ViewDrawCellEvent(Sender: TObject; ACol, ARow: Longint; ARect: TRect; State: TGridDrawState); virtual;
    procedure ViewMouseUpEvent(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  protected
    procedure InitView; override;
    procedure InternalAlignColumns; virtual;
    function InternalCurrentItem: Integer; override;
    function InternalGetRowCount: Integer; override;
    procedure InternalReset; override;
    procedure InternalSelectItem(AIndex: Integer); override;
    procedure InternalSetColumnCount(AColumnCount: Integer); override;
    procedure InternalSetColumnWidth(AColumn, AWidth: Integer); override;
    procedure InternalSetRowCount(ARowCount: Integer); override;
    procedure ReleaseControl; override;
  public
    procedure AlignColumns;
    class function Apply(AControl: TControl): Boolean; override;
    property Control: TCustomDrawGrid read GetControl;
    {$IFDEF PressViewDirectEvent}
    property OnClickCell: TPressClickCellEvent read FOnClickCell write FOnClickCell;
    property OnClickHeader: TPressClickHeaderEvent read FOnClickHeader write FOnClickHeader;
    property OnDrawCell: TPressDrawCellEvent read FOnDrawCell write FOnDrawCell;
    {$ENDIF}
  end;

  TPressMVPCaptionView = class(TPressMVPAttributeView)
  protected
    function GetAsString: string; override;
    procedure InternalUpdate; override;
  end;

  TPressMVPLabelView = class(TPressMVPCaptionView)
  public
    class function Apply(AControl: TControl): Boolean; override;
  end;

  TPressMVPPanelView = class(TPressMVPCaptionView)
  public
    class function Apply(AControl: TControl): Boolean; override;
  end;

  TPressMVPPictureView = class(TPressMVPAttributeView)
  private
    function GetControl: TImage;
  protected
    procedure InternalUpdate; override;
  public
    class function Apply(AControl: TControl): Boolean; override;
    property Control: TImage read GetControl;
  end;

  TPressMVPCustomFormViewClass = class of TPressMVPCustomFormView;

  TPressMVPCustomFormView = class(TPressMVPView)
  public
    function ComponentByName(const AComponentName: ShortString): TComponent;
    function ControlByName(const AControlName: ShortString): TControl;
  end;

  TPressMVPFormView = class(TPressMVPCustomFormView)
  private
    FViewCloseEvent: TCloseEvent;
    function GetControl: TCustomForm;
  protected
    procedure ViewCloseEvent(Sender: TObject; var Action: TCloseAction); virtual;
  protected
    procedure InitView; override;
    procedure ReleaseControl; override;
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
  SysUtils,
  PressConsts,
  PressAttributes,
  PressMVPFactory;

type
  { Friend classes }

  TPressMVPViewControlFriend = class(TControl);
  TPressMVPViewWinControlFriend = class(TWinControl);
  TPressMVPViewCustomEditFriend = class(TCustomEdit);
  TPressMVPViewCustomCalendarFriend = class(TCustomCalendar);
  TPressMVPViewCustomCheckBoxFriend = class(TCustomCheckBox);
  TPressMVPViewCustomComboBoxFriend = class(TCustomComboBox);
  TPressMVPViewCustomListBoxFriend = class(TCustomListBox);
  TPressMVPViewCustomLabelFriend = class(TCustomLabel);
  TPressMVPViewCustomFormFriend = class(TCustomForm);

{ TPressMVPViewEvent }

{$IFNDEF PressLogViewEvents}
function TPressMVPViewEvent.AllowLog: Boolean;
begin
  Result := False;
end;
{$ENDIF}

constructor TPressMVPViewEvent.Create(AOwner: TPressMVPView);
begin
  inherited Create(AOwner);
end;

function TPressMVPViewEvent.GetOwner: TPressMVPView;
begin
  Result := inherited Owner as TPressMVPView;
end;

{ TPressMVPViewMouseEvent }

constructor TPressMVPViewMouseEvent.Create(AOwner: TPressMVPView;
  AMouseButton: TMouseButton; AShiftState: TShiftState; AX, AY: Integer);
begin
  inherited Create(AOwner);
  FMouseButton := AMouseButton;
  FShiftState := AShiftState;
  FX := AX;
  FY := AY;
end;

{ TPressMVPViewKeyboardEvent }

{$IFNDEF PressLogKeyboardEvents}
function TPressMVPViewKeyboardEvent.AllowLog: Boolean;
begin
  Result := False;
end;
{$ENDIF}

{ TPressMVPViewKeyPressEvent }

constructor TPressMVPViewKeyPressEvent.Create(AOwner: TPressMVPView; var AKey: Char);
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
  AOwner: TPressMVPView; var AKey: Word; AShift: TShiftState);
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
  AOwner: TPressMVPView; ACanvas: TCanvas;
  AItemIndex: Integer; ARect: TRect; State: TOwnerDrawState);
begin
  inherited Create(AOwner);
  FCanvas := ACanvas;
  FItemIndex := AItemIndex;
  FRect := ARect;
  FState := State;
end;

function TPressMVPViewDrawItemEvent.GetOwner: TPressMVPView;
begin
  Result := inherited Owner as TPressMVPView;
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

{ TPressMVPViewClickHeaderEvent }

constructor TPressMVPViewClickHeaderEvent.Create(AOwner: TPressMVPView;
  AButton: TMouseButton; AShiftState: TShiftState; ACol: Integer);
begin
  inherited Create(AOwner);
  FButton := AButton;
  FShiftState := AShiftState;
  FCol := ACol;
end;

{ TPressMVPViewClickCellEvent }

constructor TPressMVPViewClickCellEvent.Create(AOwner: TPressMVPView;
  AButton: TMouseButton; AShiftState: TShiftState; ACol, ARow: Integer);
begin
  inherited Create(AOwner);
  FButton := AButton;
  FShiftState := AShiftState;
  FCol := ACol;
  FRow := ARow;
end;

{$ENDIF}

{ TPressMVPView }

procedure TPressMVPView.Changed;
begin
  FIsChanged := True;
end;

constructor TPressMVPView.Create(AControl: TControl; AOwnsControl: Boolean);
begin
  CheckClass(Apply(AControl));
  inherited Create;
  FControl := AControl;
  FOwnsControl := AOwnsControl;
  FNotifier := TPressNotifier.Create({$IFDEF FPC}@{$ENDIF}Notify);
  InitView;
end;

class function TPressMVPView.CreateFromControl(AControl: TControl;
  AOwnsControl: Boolean): TPressMVPView;
begin
  Result := PressDefaultMVPFactory.MVPViewFactory(AControl, AOwnsControl);
end;

destructor TPressMVPView.Destroy;
begin
  FNotifier.Free;
  if FOwnsControl then
    FControl.Free;
  inherited;
end;

function TPressMVPView.GetModel: TPressMVPModel;
begin
  if not Assigned(FModel) then
    raise EPressMVPError.Create(SUnassignedModel);
  Result := FModel;
end;

function TPressMVPView.GetReadOnly: Boolean;
begin
  Result := AccessMode <> amWritable;
end;

procedure TPressMVPView.InitView;
begin
  FAccessMode := amWritable;
  with TPressMVPViewControlFriend(Control) do
  begin
    FViewClickEvent := OnClick;
    FViewDblClickEvent := OnDblClick;
    FViewMouseDownEvent := OnMouseDown;
    FViewMouseUpEvent := OnMouseUp;
    OnClick := {$IFDEF FPC}@{$ENDIF}ViewClickEvent;
    OnDblClick := {$IFDEF FPC}@{$ENDIF}ViewDblClickEvent;
    OnMouseDown := {$IFDEF FPC}@{$ENDIF}ViewMouseDownEvent;
    OnMouseUp := {$IFDEF FPC}@{$ENDIF}ViewMouseUpEvent;
  end;
end;

procedure TPressMVPView.InternalAccessModeUpdated;
begin
  InternalUpdate;
end;

procedure TPressMVPView.InternalReset;
begin
  AccessMode := Model.AccessMode;
  InternalUpdate;
end;

procedure TPressMVPView.InternalUpdate;
begin
end;

procedure TPressMVPView.ModelChanged(AChangeType: TPressMVPChangeType);
begin
  case AChangeType of
    ctSubject: InternalUpdate;
    ctDisplay: InternalReset;
  end;
end;

procedure TPressMVPView.Notify(AEvent: TPressEvent);
begin
  if AEvent is TPressMVPModelChangedEvent then
    ModelChanged(TPressMVPModelChangedEvent(AEvent).ChangeType);
end;

class procedure TPressMVPView.RegisterView;
begin
  PressDefaultMVPFactory.RegisterView(Self);
end;

procedure TPressMVPView.ReleaseControl;
begin
  with TPressMVPViewControlFriend(Control) do
  begin
    OnClick := FViewClickEvent;
    OnDblClick := FViewDblClickEvent;
    OnMouseDown := FViewMouseDownEvent;
    OnMouseUp := FViewMouseUpEvent;
  end;
  FControl := nil;
end;

procedure TPressMVPView.SetAccessMode(Value: TPressAccessMode);
begin
  if FAccessMode <> Value then
  begin
    FAccessMode := Value;
    InternalAccessModeUpdated;
  end;
end;

procedure TPressMVPView.SetModel(Value: TPressMVPModel);
begin
  if FModel <> Value then
  begin
    if Assigned(FModel) then
      FNotifier.RemoveNotificationItem(FModel);
    FModel := Value;
    if Assigned(FModel) then
      FNotifier.AddNotificationItem(FModel, [TPressMVPModelChangedEvent]);
  end;
end;

procedure TPressMVPView.SetReadOnly(Value: Boolean);
begin
  if Value then
    AccessMode := amVisible
  else
    AccessMode := amWritable;
end;

procedure TPressMVPView.Unchanged;
begin
  FIsChanged := False;
end;

procedure TPressMVPView.Update;
begin
  InternalUpdate;
end;

procedure TPressMVPView.ViewClickEvent(Sender: TObject);
begin
  if EventsDisabled then
    Exit;
  TPressMVPViewClickEvent.Create(Self).Notify;
  if Assigned(FViewClickEvent) then
    FViewClickEvent(Sender);
end;

procedure TPressMVPView.ViewDblClickEvent(Sender: TObject);
begin
  if EventsDisabled then
    Exit;
  TPressMVPViewDblClickEvent.Create(Self).Notify;
  if Assigned(FViewDblClickEvent) then
    FViewDblClickEvent(Sender);
end;

procedure TPressMVPView.ViewMouseDownEvent(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if EventsDisabled then
    Exit;
  TPressMVPViewMouseDownEvent.Create(Self, Button, Shift, X, Y).Notify;
  if Assigned(FViewMouseDownEvent) then
    FViewMouseDownEvent(Sender, Button, Shift, X, Y);
end;

procedure TPressMVPView.ViewMouseUpEvent(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if EventsDisabled then
    Exit;
  TPressMVPViewMouseUpEvent.Create(Self, Button, Shift, X, Y).Notify;
  if Assigned(FViewMouseUpEvent) then
    FViewMouseUpEvent(Sender, Button, Shift, X, Y);
end;

{ TPressMVPAttributeView }

function TPressMVPAttributeView.AccessError(
  const ADataType: string): EPressMVPError;
begin
  Result := EPressMVPError.CreateFmt(SViewAccessError,
   [ClassName, Control.Name, ADataType]);
end;

procedure TPressMVPAttributeView.Clear;
begin
  InternalClear;
end;

destructor TPressMVPAttributeView.Destroy;
begin
  if Assigned(FControl) and not OwnsControl then
    ReleaseControl;
  inherited;
end;

function TPressMVPAttributeView.GetAsBoolean: Boolean;
begin
  raise AccessError('Boolean');
end;

function TPressMVPAttributeView.GetAsDateTime: TDateTime;
begin
  raise AccessError('DateTime');
end;

function TPressMVPAttributeView.GetAsInteger: Integer;
begin
  raise AccessError('Integer');
end;

function TPressMVPAttributeView.GetAsString: string;
begin
  raise AccessError('String');
end;

function TPressMVPAttributeView.GetIsClear: Boolean;
begin
  Result := False;
end;

function TPressMVPAttributeView.GetModel: TPressMVPAttributeModel;
begin
  Result := inherited Model as TPressMVPAttributeModel;
end;

procedure TPressMVPAttributeView.InternalClear;
begin
end;

procedure TPressMVPAttributeView.SetSize(Value: Integer);
begin
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
    OnEnter := {$IFDEF FPC}@{$ENDIF}ViewEnterEvent;
    OnExit := {$IFDEF FPC}@{$ENDIF}ViewExitEvent;
    OnKeyDown := {$IFDEF FPC}@{$ENDIF}ViewKeyDownEvent;
    OnKeyPress := {$IFDEF FPC}@{$ENDIF}ViewKeyPressEvent;
    OnKeyUp := {$IFDEF FPC}@{$ENDIF}ViewKeyUpEvent;
  end;
end;

procedure TPressMVPWinView.InternalAccessModeUpdated;
begin
  inherited;
  UpdateRelatedLabel;
end;

procedure TPressMVPWinView.ReleaseControl;
begin
  with TPressMVPViewWinControlFriend(Control) do
  begin
    OnEnter := FViewEnterEvent;
    OnExit := FViewExitEvent;
    OnKeyDown := FViewKeyDownEvent;
    OnKeyPress := FViewKeyPressEvent;
    OnKeyUp := FViewKeyUpEvent;
  end;
  inherited;
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

procedure TPressMVPWinView.UpdateRelatedLabel;
var
  VOwner: TComponent;
  VLabel: TCustomLabel;
  I: Integer;
begin
  VOwner := Control.Owner;
  if Assigned(VOwner) then
    for I := 0 to Pred(VOwner.ComponentCount) do
      if (VOwner.Components[I] is TCustomLabel) then
      begin
        VLabel := TCustomLabel(VOwner.Components[I]);
        if TPressMVPViewCustomLabelFriend(VLabel).FocusControl = Control then
        begin
          VLabel.Enabled := AccessMode = amWritable;
          Exit;
        end;
      end;
end;

procedure TPressMVPWinView.ViewEnterEvent(Sender: TObject);
begin
  if EventsDisabled then
    Exit;
  Unchanged;
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

function TPressMVPEditView.GetIsClear: Boolean;
begin
  Result := Control.Text = '';
end;

function TPressMVPEditView.GetSelectedText: string;
begin
  Result := Control.SelText;
end;

procedure TPressMVPEditView.InitView;
begin
  inherited;
  with TPressMVPViewCustomEditFriend(Control) do
  begin
    FViewChangeEvent := OnChange;
    OnChange := {$IFDEF FPC}@{$ENDIF}ViewChangeEvent;
  end;
end;

procedure TPressMVPEditView.InternalClear;
begin
  TPressMVPViewCustomEditFriend(Control).Text := '';
end;

procedure TPressMVPEditView.InternalUpdate;
begin
  inherited;
  if AccessMode = amInvisible then
    TPressMVPViewCustomEditFriend(Control).Text := ''
  else
    TPressMVPViewCustomEditFriend(Control).Text := Model.AsString;
  Control.Enabled := AccessMode = amWritable;
  Unchanged;
end;

procedure TPressMVPEditView.ReleaseControl;
begin
  with TPressMVPViewCustomEditFriend(Control) do
  begin
    OnChange := FViewChangeEvent;
  end;
  inherited;
end;

procedure TPressMVPEditView.SetSize(Value: Integer);
begin
  TPressMVPViewCustomEditFriend(Control).MaxLength := Value;
end;

procedure TPressMVPEditView.ViewChangeEvent(Sender: TObject);
begin
  if EventsDisabled then
    Exit;
  Changed;
  if Assigned(FViewChangeEvent) then
    FViewChangeEvent(Sender);
end;

procedure TPressMVPEditView.ViewEnterEvent(Sender: TObject);
begin
  inherited;
  Control.SelectAll;
end;

{ TPressMVPDateTimeView }

class function TPressMVPDateTimeView.Apply(AControl: TControl): Boolean;
begin
  Result := AControl is TCustomCalendar;
end;

function TPressMVPDateTimeView.GetAsDateTime: TDateTime;
begin
  Result := TPressMVPViewCustomCalendarFriend(Control).DateTime;
end;

function TPressMVPDateTimeView.GetAsString: string;
begin
  Result := TPressMVPViewCustomCalendarFriend(Control).Text;
end;

function TPressMVPDateTimeView.GetControl: TCustomCalendar;
begin
  Result := inherited Control as TCustomCalendar;
end;

function TPressMVPDateTimeView.GetIsClear: Boolean;
begin
  Result := TPressMVPViewCustomCalendarFriend(Control).DateTime = 0;
end;

procedure TPressMVPDateTimeView.InternalClear;
begin
  TPressMVPViewCustomCalendarFriend(Control).DateTime := 0;
end;

procedure TPressMVPDateTimeView.InternalUpdate;
begin
  inherited;
  if AccessMode = amInvisible then
    TPressMVPViewCustomCalendarFriend(Control).DateTime := 0
  else
    TPressMVPViewCustomCalendarFriend(Control).DateTime :=
     Model.Subject.AsDateTime;
  Control.Enabled := AccessMode = amWritable;
  Unchanged;
end;

procedure TPressMVPDateTimeView.ViewClickEvent(Sender: TObject);
begin
  if EventsDisabled then
    Exit;
  Changed;
  inherited;
end;

{ TPressMVPBooleanView }

procedure TPressMVPBooleanView.ViewClickEvent(Sender: TObject);
begin
  if EventsDisabled then
    Exit;
  Changed;
  inherited;
end;

{ TPressMVPCheckBoxView }

class function TPressMVPCheckBoxView.Apply(AControl: TControl): Boolean;
begin
  Result := AControl is TCustomCheckBox;
end;

function TPressMVPCheckBoxView.GetAsBoolean: Boolean;
begin
  Result := TPressMVPViewCustomCheckBoxFriend(Control).Checked;
end;

function TPressMVPCheckBoxView.GetControl: TCustomCheckBox;
begin
  Result := inherited Control as TCustomCheckBox;
end;

function TPressMVPCheckBoxView.GetIsClear: Boolean;
begin
  Result := TPressMVPViewCustomCheckBoxFriend(Control).State = cbGrayed;
end;

procedure TPressMVPCheckBoxView.InternalClear;
begin
  TPressMVPViewCustomCheckBoxFriend(Control).State := cbUnchecked;
end;

procedure TPressMVPCheckBoxView.InternalUpdate;
var
  VAttribute: TPressAttribute;
begin
  inherited;
  VAttribute := Model.Subject;
  { TODO : Implement invisibility }
  if VAttribute.IsNull then
    TPressMVPViewCustomCheckBoxFriend(Control).State := cbGrayed
  else if VAttribute.AsBoolean then
    TPressMVPViewCustomCheckBoxFriend(Control).State := cbChecked
  else
    TPressMVPViewCustomCheckBoxFriend(Control).State := cbUnchecked;
  Control.Enabled := AccessMode = amWritable;
  Unchanged;
end;

{ TPressMVPItemView }

procedure TPressMVPItemView.AddReference(const ACaption: string);
begin
  InternalAddReference(ACaption);
end;

procedure TPressMVPItemView.AssignReferences(AItems: TStrings);
var
  I: Integer;
begin
  InternalClearReferences;
  for I := 0 to Pred(AItems.Count) do
    InternalAddReference(AItems[I]);
end;

procedure TPressMVPItemView.ClearReferences;
begin
  InternalClearReferences;
end;

function TPressMVPItemView.GetReferencesVisible: Boolean;
begin
  Result := False;
end;

function TPressMVPItemView.GetSelectedText: string;
begin
  Result := '';
end;

procedure TPressMVPItemView.ViewEnterEvent(Sender: TObject);
begin
  InternalClearReferences;
  inherited;
end;

procedure TPressMVPItemView.ViewExitEvent(Sender: TObject);
begin
  InternalClearReferences;
  inherited;
end;

{ TPressMVPComboBoxView }

class function TPressMVPComboBoxView.Apply(AControl: TControl): Boolean;
begin
  Result := AControl is TCustomComboBox;
end;

function TPressMVPComboBoxView.GetAsInteger: Integer;
begin
  if Control.Items.Count = 0 then
    Result := -1
  else
    Result := Control.ItemIndex;
end;

function TPressMVPComboBoxView.GetAsString: string;
begin
  Result := TPressMVPViewCustomComboBoxFriend(Control).Text;
end;

function TPressMVPComboBoxView.GetControl: TCustomComboBox;
begin
  Result := inherited Control as TCustomComboBox;
end;

function TPressMVPComboBoxView.GetIsClear: Boolean;
begin
  Result := AsString = '';
end;

function TPressMVPComboBoxView.GetReferencesVisible: Boolean;
begin
  Result := Control.DroppedDown;
end;

function TPressMVPComboBoxView.GetSelectedText: string;
begin
  Result := Control.SelText;
end;

procedure TPressMVPComboBoxView.HideReferences;
begin
  Control.DroppedDown := False;
end;

procedure TPressMVPComboBoxView.InitView;
begin
  inherited;
  with TPressMVPViewCustomComboBoxFriend(Control) do
  begin
    FViewChangeEvent := OnChange;
    FViewDrawItemEvent := OnDrawItem;
    FViewDropDownEvent := OnDropDown;
    {$IFDEF FPC}
    FViewSelectEvent := OnSelect;
    {$ENDIF}
    OnChange := {$IFDEF FPC}@{$ENDIF}ViewChangeEvent;
    OnDrawItem := {$IFDEF FPC}@{$ENDIF}ViewDrawItemEvent;
    OnDropDown := {$IFDEF FPC}@{$ENDIF}ViewDropDownEvent;
    {$IFDEF FPC}
    OnSelect := {$IFDEF FPC}@{$ENDIF}ViewSelectEvent;
    {$ENDIF}
  end;
end;

procedure TPressMVPComboBoxView.InternalAddReference(const ACaption: string);
begin
  Control.Items.Add(ACaption);
end;

procedure TPressMVPComboBoxView.InternalClear;
begin
  ClearReferences;
  TPressMVPViewCustomComboBoxFriend(Control).Text := '';
  Changed;
end;

procedure TPressMVPComboBoxView.InternalClearReferences;
begin
  Control.Items.Clear;
end;

procedure TPressMVPComboBoxView.InternalUpdate;
begin
  inherited;
  if AccessMode = amInvisible then
    TPressMVPViewCustomComboBoxFriend(Control).Text := ''
  else
    TPressMVPViewCustomComboBoxFriend(Control).Text := Model.AsString;
  Control.Enabled := AccessMode = amWritable;
  Unchanged;
end;

procedure TPressMVPComboBoxView.ReleaseControl;
begin
  with TPressMVPViewCustomComboBoxFriend(Control) do
  begin
    OnChange := FViewChangeEvent;
    OnDrawItem := FViewDrawItemEvent;
    OnDropDown := FViewDropDownEvent;
  end;
  inherited;
end;

procedure TPressMVPComboBoxView.SelectAll;
begin
  Control.SelectAll;
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
  Changed;
  if Assigned(FViewChangeEvent) then
    FViewChangeEvent(Sender);
end;

{$IFNDEF FPC}
procedure TPressMVPComboBoxView.ViewClickEvent(Sender: TObject);
begin
  if EventsDisabled then
    Exit;
  Changed;
  TPressMVPViewSelectEvent.Create(Self).Notify;
  inherited;
end;
{$ENDIF}

procedure TPressMVPComboBoxView.ViewDrawItemEvent(AControl: TWinControl;
  AIndex: Integer; ARect: TRect; AState: TOwnerDrawState);
begin
  if EventsDisabled then
    Exit;
  {$IFDEF PressViewNotification}
  TPressMVPViewDrawItemEvent.Create(
   Self, Control.Canvas, AIndex, ARect, AState).Notify;
  {$ENDIF}
  {$IFDEF PressViewDirectEvent}
  if Assigned(FOnDrawItem) then
    FOnDrawItem(Self, Control.Canvas, AIndex, ARect, AState);
  {$ENDIF}
  if Assigned(FViewDrawItemEvent) then
    FViewDrawItemEvent(Control, AIndex, ARect, AState);
end;

procedure TPressMVPComboBoxView.ViewDropDownEvent(Sender: TObject);
begin
  if EventsDisabled then
    Exit;
  TPressMVPViewDropDownEvent.Create(Self).Notify;
  if Assigned(FViewDropDownEvent) then
    FViewDropDownEvent(Sender);
end;

{$IFDEF FPC}
procedure TPressMVPComboBoxView.ViewSelectEvent(Sender: TObject);
begin
  if EventsDisabled then
    Exit;
  Changed;
  TPressMVPViewSelectEvent.Create(Self).Notify;
  if Assigned(FViewSelectEvent) then
    FViewSelectEvent(Sender);
end;
{$ENDIF}

{ TPressMVPItemsView }

function TPressMVPItemsView.CurrentItem: Integer;
begin
  Result := InternalCurrentItem;
end;

function TPressMVPItemsView.GetModel: TPressMVPItemsModel;
begin
  Result := inherited Model as TPressMVPItemsModel;
end;

function TPressMVPItemsView.GetRowCount: Integer;
begin
  Result := InternalGetRowCount;
end;

procedure TPressMVPItemsView.InternalSetColumnCount(AColumnCount: Integer);
begin
end;

procedure TPressMVPItemsView.InternalSetColumnWidth(AColumn, AWidth: Integer);
begin
end;

procedure TPressMVPItemsView.InternalUpdate;
begin
  inherited;
  RowCount := Model.Count;
  Control.Enabled := AccessMode = amWritable;
  { TODO : Improve }
  Control.Invalidate;
end;

procedure TPressMVPItemsView.SelectItem(AIndex: Integer);
var
  VRowCount: Integer;
begin
  { TODO : Improve }
  VRowCount := RowCount;
  if AIndex = VRowCount then
    RowCount := VRowCount + 1;
  InternalSelectItem(AIndex);
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
    OnDrawItem := {$IFDEF FPC}@{$ENDIF}ViewDrawItemEvent;
    Style := lbOwnerDrawFixed;
    { TODO : Implement multi selection }
    MultiSelect := False; //True;
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

procedure TPressMVPListBoxView.ReleaseControl;
begin
  with TPressMVPViewCustomListBoxFriend(Control) do
  begin
    OnDrawItem := FViewDrawItemEvent;
  end;
  inherited;
end;

procedure TPressMVPListBoxView.ViewDrawItemEvent(AControl: TWinControl;
  AIndex: Integer; ARect: TRect; AState: TOwnerDrawState);
begin
  if EventsDisabled then
    Exit;
  {$IFDEF PressViewNotification}
  TPressMVPViewDrawItemEvent.Create(
   Self, Control.Canvas, AIndex, ARect, AState).Notify;
  {$ENDIF}
  {$IFDEF PressViewDirectEvent}
  if Assigned(FOnDrawItem) then
    FOnDrawItem(Self, Control.Canvas, AIndex, ARect, AState);
  {$ENDIF}
  if Assigned(FViewDrawItemEvent) then
    FViewDrawItemEvent(Control, AIndex, ARect, AState);
end;

{ TPressMVPGridView }

procedure TPressMVPGridView.AlignColumns;
begin
  InternalAlignColumns;
end;

class function TPressMVPGridView.Apply(AControl: TControl): Boolean;
begin
  Result := AControl is TCustomDrawGrid;
end;

function TPressMVPGridView.GetControl: TCustomDrawGrid;
begin
  Result := inherited Control as TCustomDrawGrid;
end;

procedure TPressMVPGridView.InitView;
begin
  inherited;
  with Control do
  begin
    FViewDrawCellEvent := OnDrawCell;
    OnDrawCell := {$IFDEF FPC}@{$ENDIF}ViewDrawCellEvent;
    Options := Options +
     [goColSizing, goRowSelect] - [goHorzLine, goRangeSelect];
  end;
end;

procedure TPressMVPGridView.InternalAlignColumns;
var
  VControl: TCustomDrawGrid;
  VColCount, VClientWidth, VTotalWidth, VWidth, VDiff, VDelta: Integer;
  I: Integer;
begin
  VControl := Control;
  VColCount := VControl.ColCount;
  if VColCount < 2 then
    Exit;
  VClientWidth := VControl.ClientWidth - VControl.ColWidths[0] - VColCount;
  VTotalWidth := 0;
  for I := 1 to Pred(VColCount) do
    VTotalWidth := VTotalWidth + VControl.ColWidths[I];
  VDiff := VTotalWidth - VClientWidth;
  for I := 1 to Pred(VColCount) do
  begin
    VWidth := VControl.ColWidths[I];
    VDelta := Round(VDiff * VWidth / VTotalWidth);
    VControl.ColWidths[I] := VWidth - VDelta;
    VTotalWidth := VTotalWidth - VWidth;
    VDiff := VDiff - VDelta;
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

procedure TPressMVPGridView.InternalReset;
var
  VColumnData: TPressMVPColumnData;
  I: Integer;
begin
  with Control do
  begin
    DefaultRowHeight := 16;
    VColumnData := Model.ColumnData;
    ColCount := VColumnData.ColumnCount + 1;
    for I := 0 to Pred(VColumnData.ColumnCount) do
      ColWidths[I + 1] := VColumnData[I].Width;
    if ColCount > 1 then
    begin
      ColWidths[0] := 26;
      FixedCols := 1;
    end;
    if RowCount < 2 then
      RowCount := 2;
    FixedRows := 1;
    AlignColumns;
  end;
  inherited;
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

procedure TPressMVPGridView.ReleaseControl;
begin
  with Control do
  begin
    OnDrawCell := FViewDrawCellEvent;
  end;
  inherited;
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

procedure TPressMVPGridView.ViewMouseUpEvent(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  VCol, VRow: Integer;
begin
  if EventsDisabled then
    Exit;
  inherited;
  Control.MouseToCell(X, Y, VCol, VRow);
  Dec(VCol);
  Dec(VRow);
  if VRow < 0 then
  begin
    {$IFDEF PressViewNotification}
    TPressMVPViewClickHeaderEvent.Create(Self, Button, Shift, VCol).Notify;
    {$ENDIF}
    {$IFDEF PressViewDirectEvent}
    if Assigned(FOnClickHeader) then
      FOnClickHeader(Self, Button, Shift, VCol);
    {$ENDIF}
  end else
  begin
    {$IFDEF PressViewNotification}
    TPressMVPViewClickCellEvent.Create(Self, Button, Shift, VCol, VRow).Notify;
    {$ENDIF}
    {$IFDEF PressViewDirectEvent}
    if Assigned(FOnClickCell) then
      FOnClickCell(Self, Button, Shift, VCol, VRow);
    {$ENDIF}
  end;
end;

{ TPressMVPCaptionView }

function TPressMVPCaptionView.GetAsString: string;
begin
  Result := TPressMVPViewControlFriend(Control).Caption;
end;

procedure TPressMVPCaptionView.InternalUpdate;
begin
  inherited;
  if AccessMode = amInvisible then
    TPressMVPViewControlFriend(Control).Caption := ''
  else
    TPressMVPViewControlFriend(Control).Caption := Model.AsString;
end;

{ TPressMVPLabelView }

class function TPressMVPLabelView.Apply(AControl: TControl): Boolean;
begin
  Result := AControl is TCustomLabel;
end;

{ TPressMVPPanelView }

class function TPressMVPPanelView.Apply(AControl: TControl): Boolean;
begin
  Result := AControl is TCustomPanel;
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

procedure TPressMVPPictureView.InternalUpdate;
var
  VSubject: TPressAttribute;
begin
  inherited;
  VSubject := Model.Subject;
  if VSubject is TPressPicture then
    TPressPicture(VSubject).AssignToPicture(Control.Picture);
end;

{ TPressMVPCustomFormView }

function TPressMVPCustomFormView.ComponentByName(
  const AComponentName: ShortString): TComponent;
begin
  Result := Control.FindComponent(AComponentName);
  if not Assigned(Result) then
    raise EPressMVPError.CreateFmt(SComponentNotFound,
     [Control.Name, AComponentName]);
end;

function TPressMVPCustomFormView.ControlByName(
  const AControlName: ShortString): TControl;
var
  VComponent: TComponent;
begin
  VComponent := ComponentByName(AControlName);
  if not (VComponent is TControl) then
    raise EPressMVPError.CreateFmt(SComponentIsNotAControl, [AControlName]);
  Result := TControl(VComponent);
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
    OnClose := {$IFDEF FPC}@{$ENDIF}ViewCloseEvent;
  end;
end;

procedure TPressMVPFormView.ReleaseControl;
begin
  with TPressMVPViewCustomFormFriend(Control) do
  begin
    OnClose := FViewCloseEvent;
  end;
  inherited;
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
  TPressMVPPanelView.RegisterView;
  TPressMVPPictureView.RegisterView;
  TPressMVPFormView.RegisterView;
end;

initialization
  RegisterViews;

end.
