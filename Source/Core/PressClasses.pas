(*
  PressObjects, Base Classes
  Copyright (C) 2006-2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressClasses;

{$DEFINE PressBaseUnit}
{$I Press.inc}

interface

uses
  SysUtils,
  Classes,
  SyncObjs;

type
  EPressError = class(Exception);

  EPressConversionError = class(EPressError);

  TPressTextPos = record
    Line, Column: Integer;
    Position: Integer;
  end;

  EPressParseError = class(EPressError)
  private
    FLine: Integer;
    FColumn: Integer;
  public
    constructor Create(APosition: TPressTextPos; const AMsg: string);
    constructor CreateFmt(APosition: TPressTextPos; const AMsg: string; const AParams: array of const);
    property Line: Integer read FLine;
    property Column: Integer read FColumn;
  end;

  PComponent = ^TComponent;

  TChars = set of Char;
  TPressStringArray = array of string;

  TPressReader = class(TReader)
  end;

  TPressWriter = class(TWriter)
  end;

{$ifdef d5down}
  IInterface = IUnknown;
{$endif}

  TPressManagedObject = class(TPersistent, IInterface)
  private
{$ifdef PressMultiThread}
    FCriticalSection: TCriticalSection;
{$endif}
    FRefCount: Integer;
  protected
    procedure Finit; virtual;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
    destructor Destroy; reintroduce;
    function AddRef: Integer; virtual;
    procedure AfterConstruction; override;
    procedure FreeInstance; override;
    procedure Lock;
    class function NewInstance: TObject; override;
    function Release: Integer; virtual;
    procedure Unlock;
    property RefCount: Integer read FRefCount;
  end;

  IPressHolder = interface(IInterface)
  ['{ADF93AAB-E963-462F-ACE7-D56CCF582C2D}']
    function GetInstance: TObject;
    property Instance: TObject read GetInstance;
  end;

  TPressHolder = class(TPressManagedObject, IPressHolder)
  private
    FInstance: TObject;
    function GetInstance: TObject;
  protected
    procedure Finit; override;
  public
    constructor Create(AInstance: TObject);
    procedure AfterConstruction; override;
    property Instance: TObject read FInstance;
  end;

  TPressStreamableClass = class of TPressStreamable;

  TPressStreamable = class(TPressManagedObject)
  public
    class function CreateInstance(Arg: Pointer): TPressStreamable; virtual;
    procedure ReadObject(Reader: TPressReader); virtual;
    procedure WriteObject(Writer: TPressWriter); virtual;
  end;

  TPressCustomIterator = class;

  TPressCustomList = class(TList)
  protected
    function InternalCreateIterator: TPressCustomIterator; virtual;
  public
    function CreateIterator: TPressCustomIterator;
  end;

  TPressCustomIterator = class(TObject)
  private
    FOwner: TPressCustomList;
    FPosition: Integer;
    function GetCurrentItem: Pointer;
  public
    constructor Create(AOwner: TPressCustomList);
    function BeforeFirstItem: Boolean;
    function Count: Integer;
    procedure First;
    function FirstItem: Boolean;
    function IsDone: Boolean;
    procedure Next;
    function NextItem: Boolean;
    property CurrentItem: Pointer read GetCurrentItem;
    property CurrentPosition: Integer read FPosition;
  end;

  TPressList = class(TPressCustomList)
  { TODO : Need Extract and Remove methods? }
  private
    FOwnsObjects: Boolean;
    function GetItems(AIndex: Integer): TObject;
    procedure SetItems(AIndex: Integer; Value: TObject);
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
    // Override the following method into the decendants,
    // calling the reintroduced CreateIterator (public section)
    (*
    function InternalCreateIterator: TPressCustomIterator; override;
    *)
  public
    constructor Create(AOwnsObjects: Boolean);
    { TODO : Include the Extract, First and Last methods
      into *all* TPressCustomList decendants }
    { TODO : Change Index to AIndex into *all* TPressCustomList decendants }
    function Extract(AObject: TObject): TObject;
    function First: TObject;
    function Last: TObject;
    property OwnsObjects: Boolean read FOwnsObjects write FOwnsObjects;
    property Items[AIndex: Integer]: TObject read GetItems write SetItems; default;
    // Reintroduce the following methods and the property into the decendants,
    // changing the class type
    (*
    function Add(AObject: TObject): Integer;
    function CreateIterator: TPressIterator;
    function Extract(AObject: TObject): TObject;
    function First: TObject;
    function IndexOf(AObject: TObject): Integer;
    procedure Insert(AIndex: Integer; AObject: TObject);
    function Last: TObject;
    function Remove(AObject: TObject): Integer;
    property Items[AIndex: Integer]: TObject read GetItems write SetItems; default;
    *)
  end;

  TPressIterator = class(TPressCustomIterator)
  private
    function GetCurrentItem: TObject;
  public
    property CurrentItem: TObject read GetCurrentItem;
    // Reintroduce the following property, changing the result type
    (*
    property CurrentItem: TObject read GetCurrentItem;
    *)
  end;

  TPressClassIterator = class;

  TPressClassList = class(TPressCustomList)
  protected
    // Override the following method into the decendants,
    // calling the reintroduced CreateIterator (public section)
    (*
    function InternalCreateIterator: TPressCustomIterator; override;
    *)
  public
    // Reintroduce the following methods and the property into the decendants,
    // changing the class pointer type
    (*
    function Add(AClass: TClass): Integer;
    function CreateIterator: TPressClassIterator;
    function Extract(AClass: TClass): TClass;
    function First: TClass;
    function IndexOf(AClass: TClass): Integer;
    procedure Insert(AIndex: Integer; AClass: TClass);
    function Last: TClass;
    function Remove(AClass: TClass): Integer;
    property Items[AIndex: Integer]: TClass read GetItems write SetItems; default;
    *)
  end;

  TPressClassIterator = class(TPressCustomIterator)
  public
    // Reintroduce the following property, changing the result type
    (*
    property CurrentItem: TObject read GetCurrentItem;
    *)
  end;

  TPressInterfaceIterator = class;

  TPressInterfaceList = class(TPressCustomList)
  { TODO : Test, finish, improve }
  private
    function GetItems(AIndex: Integer): IInterface;
    procedure SetItems(AIndex: Integer; const Value: IInterface);
  protected
    // Override the following method into the decendants,
    // calling the reintroduced CreateIterator (below)
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    // Reintroduce the following methods and the property into the decendants,
    // changing the interface type
    function Add(AInterface: IInterface): Integer;
    function CreateIterator: TPressInterfaceIterator;
    function IndexOf(AInterface: IInterface): Integer;
    procedure Insert(Index: Integer; AInterface: IInterface);
    function Remove(AInterface: IInterface): Integer;
    property Items[AIndex: Integer]: IInterface read GetItems write SetItems; default;
  end;

  TPressInterfaceIterator = class(TPressCustomIterator)
  private
    function GetCurrentItem: IInterface;
  public
    // Reintroduce the following property, changing the result type
    property CurrentItem: IInterface read GetCurrentItem;
  end;

  TPressTextReader = class(TObject)
  { TODO : Refactor class -- move Token implementation to the ParserReader }
  private
    FBuffer: string;
    FBufferBasePos: Integer;
    FCurrentPos: TPressTextPos;
    FCurrentToken: string;
    FSize: Integer;
    FTokenPos: TPressTextPos;
    function GetEof: Boolean;
  protected
    procedure InitReader; virtual;
    function InternalReadToken: string; virtual; abstract;
  public
    constructor Create(AStream: TStream; AOwnsStream: Boolean = False); overload;
    constructor Create(const AString: string); overload;
    procedure ErrorExpected(const AExpectedToken, AToken: string);
    procedure ErrorFmt(const AMsg: string; const AParams: array of const);
    procedure ErrorMsg(const AMsg: string);
    function NextChar: Char;
    function ReadChar(GoForward: Boolean = True): Char;
    function ReadChars(ACount: Integer): string;
    procedure ReadMatch(const AToken: string);
    procedure ReadMatchEof;
    procedure ReadMatchText(const AToken: string);
    function ReadNextToken: string;
    function ReadToken: string;
    procedure SkipSpaces;
    procedure UnreadChar;
    procedure UnreadToken;
    property Eof: Boolean read GetEof;
    property Position: TPressTextPos read FCurrentPos write FCurrentPos;
    property TokenPos: TPressTextPos read FTokenPos;
  end;

implementation

uses
{$IFDEF BORLAND_CG}
  Windows,
{$ENDIF}
  Math,
  PressConsts;

{ EPressParseError }

constructor EPressParseError.Create(
  APosition: TPressTextPos; const AMsg: string);
begin
  inherited Create(AMsg);
  FLine := APosition.Line;
  FColumn := APosition.Column;
end;

constructor EPressParseError.CreateFmt(APosition: TPressTextPos;
  const AMsg: string; const AParams: array of const);
begin
  inherited CreateFmt(AMsg, AParams);
  FLine := APosition.Line;
  FColumn := APosition.Column;
end;

{ TPressManagedObject }

function TPressManagedObject.AddRef: Integer;
begin
  Result := InterLockedIncrement(FRefCount);
end;

procedure TPressManagedObject.AfterConstruction;
begin
  inherited;
{$IFDEF PressReleaseManagedObjects}
  DecLock(FRefCount);
{$ENDIF PressReleaseManagedObjects}
end;

destructor TPressManagedObject.Destroy;
begin
end;

procedure TPressManagedObject.Finit;
begin
{$ifdef PressMultiThread}
  FreeAndNil(FCriticalSection);
{$endif}
end;

procedure TPressManagedObject.FreeInstance;
begin
  Release;
  if FRefCount = 0 then
    try
      Finit;
    finally
      inherited;
    end;
end;

procedure TPressManagedObject.Lock;
begin
{$ifdef PressMultiThread}
  FCriticalSection.Acquire;
{$endif}
end;

class function TPressManagedObject.NewInstance: TObject;
begin
  Result := inherited NewInstance;
  with TPressManagedObject(Result) do
  begin
    FRefCount := 1;
{$ifdef PressMultiThread}
    FCriticalSection := TCriticalSection.Create;
{$endif}
  end;
end;

function TPressManagedObject.QueryInterface(
  const IID: TGUID; out Obj): HResult; stdcall;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := HResult($80004002);  // E_NOINTERFACE
end;

function TPressManagedObject.Release: Integer;
begin
  Result := InterLockedDecrement(FRefCount);
  if FRefCount < 0 then
    raise EPressError.CreateFmt(SCannotReleaseInstance, [ClassName]);
end;

procedure TPressManagedObject.Unlock;
begin
{$ifdef PressMultiThread}
  FCriticalSection.Release;
{$endif}
end;

function TPressManagedObject._AddRef: Integer; stdcall;
begin
  Result := AddRef;
end;

function TPressManagedObject._Release: Integer; stdcall;
begin
  Result := Release;
  if Result = 0 then
    try
      Finit;
    finally
      inherited FreeInstance;
    end;
end;

{ TPressHolder }

procedure TPressHolder.AfterConstruction;
begin
  inherited;
{$IFNDEF PressReleaseManagedObjects}
  InterLockedDecrement(FRefCount);  // friend class
{$ENDIF PressReleaseManagedObjects}
end;

constructor TPressHolder.Create(AInstance: TObject);
begin
  inherited Create;
  FInstance := AInstance;
end;

procedure TPressHolder.Finit;
begin
  FreeAndNil(FInstance);
  inherited;
end;

function TPressHolder.GetInstance: TObject;
begin
  Result := FInstance;
end;

{ TPressStreamable }

class function TPressStreamable.CreateInstance(Arg: Pointer): TPressStreamable;
begin
  Result := Create;
end;

procedure TPressStreamable.ReadObject(Reader: TPressReader);
begin
end;

procedure TPressStreamable.WriteObject(Writer: TPressWriter);
begin
end;

{ TPressCustomList }

function TPressCustomList.CreateIterator: TPressCustomIterator;
begin
  Result := InternalCreateIterator;
end;

function TPressCustomList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := TPressIterator.Create(Self);
end;

{ TPressList }

constructor TPressList.Create(AOwnsObjects: Boolean);
begin
  inherited Create;
  FOwnsObjects := AOwnsObjects;
end;

function TPressList.Extract(AObject: TObject): TObject;
begin
  Result := TObject(inherited Extract(AObject));
end;

function TPressList.First: TObject;
begin
  Result := TObject(inherited First);
end;

function TPressList.GetItems(AIndex: Integer): TObject;
begin
  Result := TObject(inherited Items[AIndex]);
end;

function TPressList.Last: TObject;
begin
  Result := TObject(inherited Last);
end;

procedure TPressList.Notify(Ptr: Pointer; Action: TListNotification);
begin
  inherited;
  if (Action = lnDeleted) and FOwnsObjects then
    TObject(Ptr).Free;
end;

procedure TPressList.SetItems(AIndex: Integer; Value: TObject);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressInterfaceList }

function TPressInterfaceList.Add(AInterface: IInterface): Integer;
begin
  Result := inherited Add(Pointer(AInterface));
end;

function TPressInterfaceList.CreateIterator: TPressInterfaceIterator;
begin
  Result := InternalCreateIterator as TPressInterfaceIterator;
end;

function TPressInterfaceList.GetItems(AIndex: Integer): IInterface;
begin
  Result := IInterface(inherited Items[AIndex]);
end;

function TPressInterfaceList.IndexOf(AInterface: IInterface): Integer;
begin
  Result := inherited IndexOf(Pointer(AInterface));
end;

procedure TPressInterfaceList.Insert(Index: Integer; AInterface: IInterface);
begin
  inherited Insert(Index, Pointer(AInterface));
end;

function TPressInterfaceList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := TPressInterfaceIterator.Create(Self);
end;

function TPressInterfaceList.Remove(AInterface: IInterface): Integer;
begin
  Result := inherited Remove(Pointer(AInterface));
end;

procedure TPressInterfaceList.SetItems(AIndex: Integer; const Value: IInterface);
begin
  inherited Items[AIndex] := Pointer(Value);
end;

{ TPressCustomIterator }

function TPressCustomIterator.BeforeFirstItem: Boolean;
begin
  FPosition := -1;
  Result := not IsDone;
end;

function TPressCustomIterator.Count: Integer;
begin
  Result := FOwner.Count;
end;

constructor TPressCustomIterator.Create(AOwner: TPressCustomList);
begin
  inherited Create;
  FOwner := AOwner;
  First;
end;

procedure TPressCustomIterator.First;
begin
  FPosition := 0;
end;

function TPressCustomIterator.FirstItem: Boolean;
begin
  First;
  Result := not IsDone;
end;

function TPressCustomIterator.GetCurrentItem: Pointer;
begin
  Result := FOwner[FPosition];
end;

function TPressCustomIterator.IsDone: Boolean;
begin
  Result := FPosition >= FOwner.Count;
end;

procedure TPressCustomIterator.Next;
begin
  Inc(FPosition);
end;

function TPressCustomIterator.NextItem: Boolean;
begin
  Next;
  Result := not IsDone;
end;

{ TPressIterator }

function TPressIterator.GetCurrentItem: TObject;
begin
  Result := TObject(inherited CurrentItem);
end;

{ TPressInterfaceIterator }

function TPressInterfaceIterator.GetCurrentItem: IInterface;
begin
  Result := IInterface(inherited CurrentItem);
end;

{ TPressTextReader }

constructor TPressTextReader.Create(AStream: TStream; AOwnsStream: Boolean);
var
  VBuffer: string;
  VSize: Integer;
begin
  VSize := AStream.Size;
  SetLength(VBuffer, VSize);
  AStream.Read(VBuffer[1], VSize);
  if AOwnsStream then
    AStream.Free;
  Create(VBuffer);
end;

constructor TPressTextReader.Create(const AString: string);
begin
  inherited Create;
  InitReader;
  FBufferBasePos := 1;
  FBuffer := AString;
  FSize := Length(FBuffer);
  FCurrentPos.Line := 1;
  FCurrentPos.Column := 1;
  FCurrentPos.Position := FBufferBasePos;
  FTokenPos := FCurrentPos;
end;

procedure TPressTextReader.ErrorExpected(const AExpectedToken, AToken: string);
var
  VToken: string;
begin
  if AToken = '' then
    VToken := SPressEofMsg
  else
    VToken := AToken;
  raise EPressParseError.CreateFmt(TokenPos, STokenExpected, [AExpectedToken, VToken]);
end;

procedure TPressTextReader.ErrorFmt(
  const AMsg: string; const AParams: array of const);
begin
  raise EPressParseError.CreateFmt(TokenPos, AMsg, AParams);
end;

procedure TPressTextReader.ErrorMsg(const AMsg: string);
begin
  ErrorFmt(AMsg, []);
end;

function TPressTextReader.GetEof: Boolean;
begin
  Result := FCurrentPos.Position >= FSize + FBufferBasePos;
end;

procedure TPressTextReader.InitReader;
begin
end;

function TPressTextReader.NextChar: Char;
begin
  Result := ReadChar(False);
end;

function TPressTextReader.ReadChar(GoForward: Boolean): Char;
begin
  if Eof then
    ErrorMsg(SUnexpectedEof);
  Result := FBuffer[FCurrentPos.Position];
  if GoForward then
  begin
    if Result = #10 then
    begin
      Inc(FCurrentPos.Line);
      FCurrentPos.Column := 1;
    end else if Result <> #13 then
      Inc(FCurrentPos.Column);
    Inc(FCurrentPos.Position);
  end;
end;

function TPressTextReader.ReadChars(ACount: Integer): string;
var
  VCount, I: Integer;
begin
  VCount := Min(ACount, FSize - FCurrentPos.Position + FBufferBasePos);
  SetLength(Result, VCount);
  for I := 1 to VCount do
    Result[I] := ReadChar;
end;

procedure TPressTextReader.ReadMatch(const AToken: string);
var
  Token: string;
begin
  Token := ReadToken;
  if Token <> AToken then
    ErrorExpected(AToken, Token);
end;

procedure TPressTextReader.ReadMatchEof;
begin
  SkipSpaces;
  if ReadNextToken <> '' then
    ErrorExpected(SPressEofMsg, ReadNextToken);
end;

procedure TPressTextReader.ReadMatchText(const AToken: string);
var
  Token: string;
begin
  Token := ReadToken;
  if not SameText(Token, AToken) then
    ErrorExpected(AToken, Token);
end;

function TPressTextReader.ReadNextToken: string;
begin
  Result := ReadToken;
  UnreadToken;
end;

function TPressTextReader.ReadToken: string;
begin
  SkipSpaces;
  if (FCurrentToken <> '') and (FTokenPos.Position = FCurrentPos.Position) then
  begin
    Result := FCurrentToken;

    { TODO : Improve }
    Inc(FCurrentPos.Position, Length(FCurrentToken));
    Inc(FCurrentPos.Column, Length(FCurrentToken));

    FCurrentToken := '';
  end else
  begin
    FTokenPos := Position;
    if not Eof then
      FCurrentToken := InternalReadToken
    else
      FCurrentToken := '';
    Result := FCurrentToken;
  end;
end;

procedure TPressTextReader.SkipSpaces;
begin
  if not Eof then
  begin
    while ReadChar in [' ', #0, #9, #10, #13] do
      if Eof then
        Exit;
    UnreadChar;
  end;
end;

procedure TPressTextReader.UnreadChar;
var
  VPos: TPressTextPos;
begin
  VPos := Position;
  Dec(VPos.Position);
  if VPos.Column > 1 then
    Dec(VPos.Column);
  Position := VPos;
end;

procedure TPressTextReader.UnreadToken;
begin
  Position := TokenPos;
end;

end.
