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
  PressNotifier,
  PressUser,
  PressMVP;

type
  TPressRect = record
    Left, Top, Right, Bottom: Integer;
  end;

  TPressShapeType = (shRectangle, shEllipse);

  { TPressMVPViewEvent }

  TPressMVPViewEvent = class(TPressEvent)
  protected
    {$IFNDEF PressLogViewEvents}
    function AllowLog: Boolean; override;
    {$ENDIF}
  end;

  TPressMVPViewClickEvent = class(TPressMVPViewEvent)
  end;

  TPressMVPViewDblClickEvent = class(TPressMVPViewEvent)
  end;

(*
  { TODO : Implement }

  TPressMVPViewMouseEvent = class(TPressMVPViewEvent)
  private
    FMouseButton: TMouseButton;
    FShiftState: TShiftState;
    FX: Integer;
    FY: Integer;
  public
    constructor Create(AOwner: TObject; AMouseButton: TMouseButton; AShiftState: TShiftState; AX, AY: Integer);
    property MouseButton: TMouseButton read FMouseButton;
    property ShiftState: TShiftState read FShiftState;
    property X: Integer read FX;
    property Y: Integer read FY;
  end;

  TPressMVPViewMouseDownEvent = class(TPressMVPViewMouseEvent)
  end;

  TPressMVPViewMouseUpEvent = class(TPressMVPViewMouseEvent)
  end;
*)

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

  TPressMVPViewSelectEvent = class(TPressMVPViewEvent)
  end;

  TPressMVPViewDrawItemEvent = class(TPressMVPViewEvent)
  private
    FCanvasHandle: TObject;
    FItemIndex: Integer;
    FRect: TPressRect;
  public
    constructor Create(AOwner: TObject; ACanvasHandle: TObject; AItemIndex: Integer; ARect: TPressRect);
    property CanvasHandle: TObject read FCanvasHandle;
    property ItemIndex: Integer read FItemIndex;
    property Rect: TPressRect read FRect;
  end;

  TPressMVPViewDrawCellEvent = class(TPressMVPViewEvent)
  private
    FCanvasHandle: TObject;
    FCol: Integer;
    FRect: TPressRect;
    FRow: Integer;
  public
    constructor Create(AOwner: TObject; ACanvasHandle: TObject; ACol, ARow: Integer; ARect: TPressRect{; State: TGridDrawState});
    property CanvasHandle: TObject read FCanvasHandle;
    property Col: Integer read FCol;
    property Rect: TPressRect read FRect;
    property Row: Integer read FRow;
  end;

  TPressMVPViewClickHeaderEvent = class(TPressMVPViewEvent)
  private
    FCol: Integer;
  public
    constructor Create(AOwner: TObject);
    property Col: Integer read FCol;
  end;

  TPressMVPViewClickCellEvent = class(TPressMVPViewEvent)
  private
    FCol: Integer;
    FRow: Integer;
  public
    constructor Create(AOwner: TObject);
    property Col: Integer read FCol;
    property Row: Integer read FRow;
  end;

  TPressMVPViewFormEvent = class(TPressMVPViewEvent)
  end;

  TPressMVPViewCloseFormEvent = class(TPressMVPViewFormEvent)
  end;

  IPressMVPBaseView = interface(IPressMVPObject)
  ['{BD52DAAE-EF86-47A0-B591-53024F0736B5}']
    function GetHandle: TObject;
    property Handle: TObject read GetHandle;
  end;

  IPressMVPView = interface(IPressMVPBaseView)
  ['{F975801E-32A0-4242-9943-11EB5A5D551F}']
    function AccessError(const ADataType: string): EPressMVPError;
    function GetAccessMode: TPressAccessMode;
    function GetEnabled: Boolean;
    function GetIsChanged: Boolean;
    function GetReadOnly: Boolean;
    function GetText: string;
    function GetVisible: Boolean;
    procedure SetAccessMode(Value: TPressAccessMode);
    procedure SetModel(AModel: TPressMVPModel);
    procedure SetReadOnly(Value: Boolean);
    procedure SetText(const Value: string);
    procedure SetVisible(Value: Boolean);
    procedure Update;
    property AccessMode: TPressAccessMode read GetAccessMode write SetAccessMode;
    property Enabled: Boolean read GetEnabled;
    property IsChanged: Boolean read GetIsChanged;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly;
    property Text: string read GetText write SetText;
    property Visible: Boolean read GetVisible write SetVisible;
  end;

  IPressMVPAttributeView = interface(IPressMVPView)
  ['{DDC41086-5263-4DD4-912A-5A37AF19A7D7}']
    procedure Clear;
    function GetAsBoolean: Boolean;
    function GetAsDateTime: TDateTime;
    function GetAsInteger: Integer;
    function GetAsString: string;
    function GetIsClear: Boolean;
    procedure SetSize(Value: Integer);
    property AsBoolean: Boolean read GetAsBoolean;
    property AsDateTime: TDateTime read GetAsDateTime;
    property AsInteger: Integer read GetAsInteger;
    property AsString: string read GetAsString;
    property IsClear: Boolean read GetIsClear;
    property Size: Integer write SetSize;
  end;

  IPressMVPWinView = interface(IPressMVPAttributeView)
  ['{19A408D3-7A3E-45ED-8E85-E729983BA05D}']
    function Focused: Boolean;
    procedure SelectNext;
    procedure SetFocus;
  end;

  IPressMVPEditView = interface(IPressMVPWinView)
  ['{14F49736-6CE1-41D9-BBD7-307ADEDFCC4D}']
    function GetSelectedText: string;
    property SelectedText: string read GetSelectedText;
  end;

  IPressMVPDateTimeView = interface(IPressMVPWinView)
  ['{EAA17B8D-43D4-43A5-8B45-D1EC7709AB72}']
  end;

  IPressMVPBooleanView = interface(IPressMVPWinView)
  ['{58E7C9D0-BEF6-4388-B410-23F24314C769}']
  end;

  IPressMVPCheckBoxView = interface(IPressMVPBooleanView)
  ['{0E7A51E2-16E5-4236-A945-E94CBF1B09F0}']
  end;

  IPressMVPItemView = interface(IPressMVPWinView)
  ['{5FEB1007-8A9B-464A-8FDD-66D7B298911F}']
    function GetReferencesVisible: Boolean;
    function GetSelectedText: string;
    procedure AddReference(const ACaption: string);
    procedure AssignReferences(AItems: TStrings);
    procedure ClearReferences;
    property ReferencesVisible: Boolean read GetReferencesVisible;
    property SelectedText: string read GetSelectedText;
  end;

  IPressMVPComboBoxView = interface(IPressMVPItemView)
  ['{79AADC39-AE08-47A1-BC2F-E57E0579A02D}']
    procedure HideReferences;
    procedure SelectAll;
    procedure ShowReferences;
  end;

  IPressMVPItemsView = interface(IPressMVPWinView)
  ['{815259A4-885D-43F3-B1BD-F8AE41D24552}']
    function CurrentItem: Integer;
    procedure SelectItem(AIndex: Integer);
  end;

  IPressMVPListBoxView = interface(IPressMVPItemsView)
  ['{828260F5-696F-4DC1-AB41-6CFC3846D20C}']
  end;

  IPressMVPGridView = interface(IPressMVPItemsView)
  ['{FFA3C130-4D0C-41A2-A1C6-98FFD91DFE6E}']
    procedure AlignColumns;
  end;

  IPressMVPCustomFormView = interface(IPressMVPView)
  ['{31405E15-E086-4997-A2A0-BE96A986FF15}']
    function ComponentByName(const AComponentName: ShortString): TObject;
  end;

  IPressMVPFormView = interface(IPressMVPCustomFormView)
  ['{254033B2-A5D7-436A-BF2D-83835040F8CE}']
    procedure Close;
    procedure ResetForm;
    procedure Show(AModal: Boolean = False);
  end;

  TPressMVPBaseViewClass = class of TPressMVPBaseView;

  TPressMVPBaseView = class(TPressMVPObject, IPressMVPBaseView)
  private
    FControl: TObject;
    FOwnsControl: Boolean;
  protected
    procedure Finit; override;
    function GetHandle: TObject;
    procedure InitView; virtual;
    procedure ReleaseControl; virtual;
  public
    constructor Create(AControl: TObject; AOwnsControl: Boolean);
    class function Apply(AControl: TObject): Boolean; virtual; abstract;
    class procedure RegisterView;
    property Control: TObject read FControl;
    property Handle: TObject read FControl;
  end;

implementation

uses
  SysUtils,
  PressConsts,
  PressPicture,
  PressMVPFactory;

{ TPressMVPViewEvent }

{$IFNDEF PressLogViewEvents}
function TPressMVPViewEvent.AllowLog: Boolean;
begin
  Result := False;
end;
{$ENDIF}

{ TPressMVPViewMouseEvent }

(*
constructor TPressMVPViewMouseEvent.Create(AOwner: TObject;
  AMouseButton: TMouseButton; AShiftState: TShiftState; AX, AY: Integer);
begin
  inherited Create(AOwner);
  FMouseButton := AMouseButton;
  FShiftState := AShiftState;
  FX := AX;
  FY := AY;
end;
*)

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

{ TPressMVPViewDrawItemEvent }

constructor TPressMVPViewDrawItemEvent.Create(
  AOwner: TObject; ACanvasHandle: TObject;
  AItemIndex: Integer; ARect: TPressRect{; State: TOwnerDrawState});
begin
  inherited Create(AOwner);
  FCanvasHandle := ACanvasHandle;
  FItemIndex := AItemIndex;
  FRect := ARect;
  //FState := State;
end;

{ TPressMVPViewDrawCellEvent }

constructor TPressMVPViewDrawCellEvent.Create(AOwner: TObject;
  ACanvasHandle: TObject; ACol, ARow: Integer; ARect: TPressRect);
begin
  inherited Create(AOwner);
  FCanvasHandle := ACanvasHandle;
  FCol := ACol;
  FRow := ARow;
  FRect := ARect;
end;

{ TPressMVPViewClickHeaderEvent }

(*
constructor TPressMVPViewClickHeaderEvent.Create(AOwner: TObject;
  AButton: TMouseButton; AShiftState: TShiftState; ACol: Integer);
begin
  inherited Create(AOwner);
  FButton := AButton;
  FShiftState := AShiftState;
  FCol := ACol;
end;
*)

constructor TPressMVPViewClickHeaderEvent.Create(AOwner: TObject);
begin
  inherited Create(AOwner);
end;

{ TPressMVPViewClickCellEvent }

(*
constructor TPressMVPViewClickCellEvent.Create(AOwner: TObject;
  AButton: TMouseButton; AShiftState: TShiftState; ACol, ARow: Integer);
begin
  inherited Create(AOwner);
  FButton := AButton;
  FShiftState := AShiftState;
  FCol := ACol;
  FRow := ARow;
end;
*)

constructor TPressMVPViewClickCellEvent.Create(AOwner: TObject);
begin
  inherited Create(AOwner);
end;

{ TPressMVPBaseView }

constructor TPressMVPBaseView.Create(AControl: TObject; AOwnsControl: Boolean);
begin
  CheckClass(Apply(AControl));
  inherited Create;
  FControl := AControl;
  FOwnsControl := AOwnsControl;
  InitView;
end;

procedure TPressMVPBaseView.Finit;
begin
  if Assigned(FControl) then
    if FOwnsControl then
      FControl.Free
    else
      ReleaseControl;
  inherited;
end;

function TPressMVPBaseView.GetHandle: TObject;
begin
  Result := FControl;
end;

procedure TPressMVPBaseView.InitView;
begin
end;

class procedure TPressMVPBaseView.RegisterView;
begin
  PressDefaultMVPFactory.RegisterView(Self);
end;

procedure TPressMVPBaseView.ReleaseControl;
begin
  FOwnsControl := False;
  FControl := nil;
end;

end.
