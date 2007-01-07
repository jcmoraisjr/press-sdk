(*
  PressObjects, Base Classes
  Copyright (C) 2006 Laserpress Ltda.

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
  Contnrs,
  PressCompatibility;

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

  PBoolean = ^Boolean;
  PComponent = ^TComponent;

  TChars = set of Char;

  TPressReader = class(TReader)
  end;

  TPressWriter = class(TWriter)
  end;

  TPressStreamableClass = class of TPressStreamable;

  TPressStreamable = class(TPersistent)
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
    FCurrentPos: TPressTextPos;
    FCurrentToken: string;
    FOwnsStream: Boolean;
    FSize: Integer;
    FStream: TStream;
    FTokenPos: TPressTextPos;
    function GetEof: Boolean;
    procedure SetCurrentPos(const Value: TPressTextPos);
  protected
    function InternalReadToken: string; virtual; abstract;
    procedure Reset;
    property Stream: TStream read FStream;
  public
    constructor Create(AStream: TStream; AOwnsStream: Boolean = False); overload;
    constructor Create(const AString: string); overload;
    destructor Destroy; override;
    procedure ErrorExpected(const AExpectedToken, AToken: string);
    procedure ErrorFmt(const AMsg: string; const AParams: array of const);
    procedure ErrorMsg(const AMsg: string);
    function NextChar: Char;
    function ReadChar(GoForward: Boolean = True): Char;
    procedure ReadMatch(const AToken: string);
    procedure ReadMatchEof;
    procedure ReadMatchText(const AToken: string);
    function ReadNextToken: string;
    function ReadToken: string;
    procedure SkipSpaces;
    procedure UnreadChar;
    procedure UnreadToken;
    property Eof: Boolean read GetEof;
    property Position: TPressTextPos read FCurrentPos write SetCurrentPos;
    property TokenPos: TPressTextPos read FTokenPos;
  end;

  TPressSingleton = class(TObject)
  protected
    procedure Finit; virtual;
    procedure Init; virtual;
  public
    constructor Instance;
    procedure Dispose;
    procedure FreeInstance; override;
    class function NewInstance: TObject; override;
  end;

  TPressSingletonIterator = class;

  TPressSingletonList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressSingleton;
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    destructor Destroy; override;
    function Add(AObject: TPressSingleton): Integer;
    function CreateIterator: TPressSingletonIterator;
    function IndexOf(AObject: TPressSingleton): Integer;
    function IndexOfClassName(const AClassName: ShortString): Integer;
    procedure Insert(Index: Integer; AObject: TPressSingleton);
    function Remove(AObject: TPressSingleton): Integer;
    property Items[AIndex: Integer]: TPressSingleton read GetItems; default;
  end;

  TPressSingletonIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressSingleton;
  public
    property CurrentItem: TPressSingleton read GetCurrentItem;
  end;

  TPressSingleObjects = class(TPressSingleton)
  private
    FObjectList: TObjectList;
    function GetObjectList: TObjectList;
  protected
    procedure Finit; override;
    property ObjectList: TObjectList read GetObjectList;
  public
    procedure RegisterObject(AObject: TObject);
  end;

procedure PressRegisterSingleObject(AObject: TObject);

implementation

uses
  PressConsts;

var
  _PressSingletons: TPressSingletonList;

procedure PressRegisterSingleObject(AObject: TObject);
begin
  TPressSingleObjects.Instance.RegisterObject(AObject);
end;

function PressSingletons: TPressSingletonList;
begin
  if not Assigned(_PressSingletons) then
    _PressSingletons := TPressSingletonList.Create(False);
  Result := _PressSingletons;
end;

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

{ TPressMVPStreamable }

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
  Result := inherited Extract(AObject);
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
begin
  inherited Create;
  FStream := AStream;
  FOwnsStream := AOwnsStream;
  Reset;
end;

constructor TPressTextReader.Create(const AString: string);
var
  VStream: TMemoryStream;
begin
  VStream := TMemoryStream.Create;
  if AString <> '' then
    VStream.Write(AString[1], Length(AString));
  Create(VStream, True);
end;

destructor TPressTextReader.Destroy;
begin
  if FOwnsStream then
    FStream.Free;
  inherited;
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
  Result := FCurrentPos.Position >= FSize;
end;

function TPressTextReader.NextChar: Char;
begin
  Result := ReadChar(False);
end;

function TPressTextReader.ReadChar(GoForward: Boolean): Char;
begin
  Result := #0;
  if Eof then
    ErrorMsg(SUnexpectedEof);
  FStream.Read(Result, SizeOf(Result));
  if GoForward then
  begin
    if Result = #10 then
    begin
      Inc(FCurrentPos.Line);
      FCurrentPos.Column := 1;
    end else if Result <> #13 then
      Inc(FCurrentPos.Column);
    Inc(FCurrentPos.Position);
  end else
    FStream.Position := FCurrentPos.Position;
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
  if not Eof then
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
    Stream.Position := FCurrentPos.Position;

    FCurrentToken := '';
  end else
  begin
    FTokenPos := Position;
    if not Eof then
    begin
      FCurrentToken := InternalReadToken;
      Result := FCurrentToken;
    end else
      Result := '';
  end;
end;

procedure TPressTextReader.Reset;
begin
  FSize := FStream.Size;
  FStream.Position := 0;
  FCurrentPos.Line := 1;
  FCurrentPos.Column := 1;
  FCurrentPos.Position := 0;
end;

procedure TPressTextReader.SetCurrentPos(const Value: TPressTextPos);
begin
  FCurrentPos := Value;
  FStream.Position := FCurrentPos.Position;
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

{ TPressSingleton }

procedure TPressSingleton.Dispose;
begin
  try
    Finit;
  finally
    inherited FreeInstance;
  end;
end;

procedure TPressSingleton.Finit;
begin
end;

procedure TPressSingleton.FreeInstance;
begin
  //inherited;
end;

procedure TPressSingleton.Init;
begin
end;

constructor TPressSingleton.Instance;
begin
  Create;
end;

class function TPressSingleton.NewInstance: TObject;
var
  VIndex: Integer;
begin
  VIndex := PressSingletons.IndexOfClassName(ClassName);
  if VIndex = -1 then
  begin
    VIndex := PressSingletons.Add(inherited NewInstance as TPressSingleton);
    PressSingletons[VIndex].Init;
  end;
  Result := PressSingletons[VIndex];
end;

{ TPressSingletonList }

function TPressSingletonList.Add(AObject: TPressSingleton): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressSingletonList.CreateIterator: TPressSingletonIterator;
begin
  Result := TPressSingletonIterator.Create(Self);
end;

destructor TPressSingletonList.Destroy;
begin
  with CreateIterator do
  try
    BeforeFirstItem;
    while NextItem do
      CurrentItem.Dispose;
  finally
    Free;
  end;
  inherited;
end;

function TPressSingletonList.GetItems(AIndex: Integer): TPressSingleton;
begin
  Result := inherited Items[AIndex] as TPressSingleton;
end;

function TPressSingletonList.IndexOf(AObject: TPressSingleton): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

function TPressSingletonList.IndexOfClassName(const AClassName: ShortString): Integer;
begin
  for Result := 0 to Pred(Count) do
    if Items[Result].ClassName = AClassName then
      Exit;
  Result := -1;
end;

procedure TPressSingletonList.Insert(Index: Integer; AObject: TPressSingleton);
begin
  inherited Insert(Index, AObject);
end;

function TPressSingletonList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressSingletonList.Remove(AObject: TPressSingleton): Integer;
begin
  Result := inherited Remove(AObject);
end;

{ TPressSingletonIterator }

function TPressSingletonIterator.GetCurrentItem: TPressSingleton;
begin
  Result := inherited CurrentItem as TPressSingleton;
end;

{ TPressSingleObjects }

procedure TPressSingleObjects.Finit;
var
  I: Integer;
begin
  inherited;
  if Assigned(FObjectList) then
  begin
    for I := Pred(FObjectList.Count) downto 0 do
      FObjectList[I].Free;
    FObjectList.Free;
  end;
end;

function TPressSingleObjects.GetObjectList: TObjectList;
begin
  if not Assigned(FObjectList) then
    FObjectList := TObjectList.Create(False);
  Result := FObjectList;
end;

procedure TPressSingleObjects.RegisterObject(AObject: TObject);
begin
  ObjectList.Add(AObject);
end;

initialization

finalization
  FreeAndNil(_PressSingletons);

end.
