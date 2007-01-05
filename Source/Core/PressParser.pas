(*
  PressObjects, Base Parser Classes
  Copyright (C) 2006 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressParser;

{$I Press.inc}

interface

uses
  PressClasses;

type
  TPressParserReader = class(TPressTextReader)
  private
    procedure CheckEof(const AErrorMsg: string);
  protected
    procedure InternalCheckComment(var AToken: string); virtual;
    function InternalReadIdentifier: string;
    function InternalReadNumber: string;
    function InternalReadString: string;
    function InternalReadSymbol: string; virtual;
    function InternalReadToken: string; override;
    function IsIdentifierChar(Ch: Char; First: Boolean): Boolean;
    function IsNumericChar(Ch: Char; First: Boolean): Boolean;
    function IsStringDelimiter(Ch: Char): Boolean;
  public
    function ReadBoolean: Boolean;
    function ReadIdentifier: string;
    function ReadInteger: Integer;
    function ReadNext(const AToken: string; AInclude: Boolean): string; overload;
    function ReadNext(const ATokens: array of string; AInclude: Boolean): string; overload;
    function ReadNumber: string;
    function ReadPath: string;
    function ReadString: string;
    function ReadUnquotedString: string;
  end;

  TPressParserList = class;

  PPressParserObject = ^TPressParserObject;
  TPressParserClass = class of TPressParserObject;

  TPressParserObject = class(TObject)
  private
    FItemList: TPressParserList;
    FOwner: TPressParserObject;
    function GetItemList: TPressParserList;
    function GetItems(AIndex: Integer): TPressParserObject;
  protected
    function FindRule(Reader: TPressParserReader; AClasses: array of TPressParserClass): TPressParserClass;
    class function InternalApply(Reader: TPressParserReader): Boolean; virtual;
    procedure InternalRead(Reader: TPressParserReader); virtual;
    function Parse(Reader: TPressParserReader; AParserClasses: array of TPressParserClass; AOwner: TPressParserObject = nil; ANecessary: Boolean = False; const AErrorExpectedMsg: string = ''): TPressParserObject;
    property ItemList: TPressParserList read GetItemList;
  public
    constructor Create(AOwner: TPressParserObject);
    destructor Destroy; override;
    class function Apply(Reader: TPressParserReader): Boolean;
    function ItemCount: Integer;
    procedure Read(Reader: TPressParserReader);
    property Items[AIndex: Integer]: TPressParserObject read GetItems; default;
    property Owner: TPressParserObject read FOwner;
  end;

  TPressParserIterator = class;

  TPressParserList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressParserObject;
    procedure SetItems(AIndex: Integer; Value: TPressParserObject);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressParserObject): Integer;
    function CreateIterator: TPressParserIterator;
    function IndexOf(AObject: TPressParserObject): Integer;
    procedure Insert(Index: Integer; AObject: TPressParserObject);
    function Remove(AObject: TPressParserObject): Integer;
    property Items[AIndex: Integer]: TPressParserObject read GetItems write SetItems; default;
  end;

  TPressParserIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressParserObject;
  public
    property CurrentItem: TPressParserObject read GetCurrentItem;
  end;

implementation

uses
  SysUtils,
  PressConsts;

{ TPressParserReader }

procedure TPressParserReader.CheckEof(const AErrorMsg: string);
begin
  SkipSpaces;
  if Eof then
    ErrorExpected(AErrorMsg, '');
end;

procedure TPressParserReader.InternalCheckComment(var AToken: string);
begin
end;

function TPressParserReader.InternalReadIdentifier: string;
var
  Ch: Char;
  VIdent: ShortString;
  VLen: Byte;
begin
  VLen := 0;
  Ch := ReadChar;
  repeat
    Inc(VLen);
    if VLen = Pred(High(VLen)) then
      ErrorMsg(STokenLengthOutOfBounds);
    VIdent[VLen] := Ch;
    if Eof then
    begin
      VIdent[0] := Char(VLen);
      Result := VIdent;
      Exit;
    end;
    Ch := ReadChar;
  until not IsIdentifierChar(Ch, False);
  UnreadChar;
  VIdent[0] := Char(VLen);
  Result := VIdent;
end;

function TPressParserReader.InternalReadNumber: string;
var
  Ch: Char;
  VNumStr: ShortString;
  VLen: Byte;
begin
  { TODO : 1.5.6 will result as a Number }
  VLen := 0;
  Ch := ReadChar;
  repeat
    Inc(VLen);
    if VLen = Pred(High(VLen)) then
      ErrorMsg(STokenLengthOutOfBounds);
    VNumStr[VLen] := Ch;
    if Eof then
    begin
      VNumStr[0] := Char(VLen);
      Result := VNumStr;
      Exit;
    end;
    Ch := ReadChar;
  until not IsNumericChar(Ch, False);
  UnreadChar;
  VNumStr[0] := Char(VLen);
  Result := VNumStr;
end;

function TPressParserReader.InternalReadString: string;

  procedure SafeInc(var AVar: Byte);
  begin
    Inc(AVar);
    if AVar = Pred(High(AVar)) then
      ErrorMsg(SStringLengthOutOfBounds);
  end;

var
  Ch, Delimiter: Char;
  VStr: ShortString;
  VLen: Byte;
begin
  Delimiter := ReadChar;
  VStr[1] := Delimiter;
  VLen := 1;
  while True do
  begin
    Ch := ReadChar;
    if Ch in [#10, #13] then
      ErrorExpected(SPressStringDelimiterMsg, SPressLineBreakMsg);
    SafeInc(VLen);
    VStr[VLen] := Ch;
    if Ch = Delimiter then
    begin
      Ch := ReadChar;
      if Ch <> Delimiter then
      begin
        UnreadChar;
        Break;
      end else
      begin
        SafeInc(VLen);
        VStr[VLen] := Ch;
      end;
    end;
  end;
  VStr[0] := Char(VLen);
  Result := VStr;
end;

function TPressParserReader.InternalReadSymbol: string;
begin
  Result := ReadChar;
end;

function TPressParserReader.InternalReadToken: string;
var
  Ch: Char;
begin
  Result := '';
  Ch := ReadChar;
  if Eof then
    Result := Ch
  else
  begin
    UnreadChar;
    if IsStringDelimiter(Ch) then
      Result := InternalReadString
    else if IsNumericChar(Ch, True) then
      Result := InternalReadNumber
    else if IsIdentifierChar(Ch, True) then
      Result := InternalReadIdentifier
    else
      Result := InternalReadSymbol;
    InternalCheckComment(Result);
  end;
end;

function TPressParserReader.IsIdentifierChar(Ch: Char; First: Boolean): Boolean;
begin
  Result :=
   (Ch in ['A'..'Z', 'a'..'z', '_']) or (not First and (Ch in ['0'..'9']));
end;

function TPressParserReader.IsNumericChar(Ch: Char; First: Boolean): Boolean;
begin
  Result := (Ch in ['0'..'9', '.']) or (First and (Ch in ['-']));
end;

function TPressParserReader.IsStringDelimiter(Ch: Char): Boolean;
begin
  Result := Ch in ['''', '"'];
end;

function TPressParserReader.ReadBoolean: Boolean;
var
  Token: string;
begin
  Token := ReadToken;
  Result := False;
  if SameText(Token, SPressTrueString) then
    Result := True
  else if not SameText(Token, SPressFalseString) then
    ErrorExpected(SPressBooleanValueMsg, Token);
end;

function TPressParserReader.ReadIdentifier: string;
begin
  CheckEof(SPressIdentifierMsg);
  Result := ReadToken;
  if not IsIdentifierChar(Result[1], True) then
    ErrorExpected(SPressIdentifierMsg, Result);
end;

function TPressParserReader.ReadInteger: Integer;
var
  Token: string;
begin
  Token := ReadToken;
  if Token = '' then
    ErrorExpected(SPressIntegerValueMsg, '');
  try
    Result := StrtoInt(Token);
  except
    on E: EConvertError do
    begin
      Result := 0;
      ErrorExpected(SPressIntegerValueMsg, Token);
    end else
      raise;
  end;
end;

function TPressParserReader.ReadNext(const ATokens: array of string;
  AInclude: Boolean): string;

  function MatchToken(const AToken: string): Boolean;
  var
    I: Integer;
  begin
    Result := True;
    for I := Low(ATokens) to High(ATokens) do
      if SameText(ATokens[I], AToken) then
        Exit;
    Result := False;
  end;

var
  Token: string;
  VOldPos, VNewPos: TPressTextPos;
  VSize, VRealSize: Integer;
begin
  VOldPos := Position;
  repeat
    Token := ReadToken;
    if Token = '' then
    begin
      Position := VOldPos;
      ErrorFmt(SUnexpectedEof, []);
    end;
  until MatchToken(Token);
  if not AInclude then
    UnreadToken;
  VNewPos := Position;
  VSize := VNewPos.Position - VOldPos.Position;
  SetLength(Result, VSize);
  Position := VOldPos;
  VRealSize := Stream.Read(Result[1], VSize);
  SetLength(Result, VRealSize);
  Position := VNewPos;
end;

function TPressParserReader.ReadNext(const AToken: string;
  AInclude: Boolean): string;
begin
  Result := ReadNext([AToken], AInclude);
end;

function TPressParserReader.ReadNumber: string;
begin
  CheckEof(SPressNumberValueMsg);
  Result := ReadToken;
  if not IsNumericChar(Result[1], True) then
    ErrorExpected(SPressNumberValueMsg, Result);
end;

function TPressParserReader.ReadPath: string;
var
  VPos: TPressTextPos;
  Ch: Char;
begin
  Result := ReadIdentifier;
  VPos := Position;
  Ch := ReadChar;
  while (Ch = '.') and IsIdentifierChar(NextChar, True) do
  begin
    Result := Result + '.' + ReadIdentifier;
    VPos := Position;
    Ch := ReadChar;
  end;
  Position := VPos;
end;

function TPressParserReader.ReadString: string;
begin
  CheckEof(SPressStringValueMsg);
  Result := ReadToken;
  if (Length(Result) < 2) or (Result[1] <> Result[Length(Result)]) or
   not IsStringDelimiter(Result[1]) then
    ErrorExpected(SPressStringValueMsg, Result);
end;

function TPressParserReader.ReadUnquotedString: string;
var
  VStr: string;
  VPStr: PChar;
begin
  VStr := ReadString;
  VPStr := PChar(VStr);
  Result := AnsiExtractQuotedStr(VPStr, VStr[1]);
end;

{ TPressParserObject }

class function TPressParserObject.Apply(Reader: TPressParserReader): Boolean;
var
  VPosition: TPressTextPos;
begin
  VPosition := Reader.Position;
  try
    Result := InternalApply(Reader);
  finally
    Reader.Position := VPosition;
  end;
end;

constructor TPressParserObject.Create(AOwner: TPressParserObject);
begin
  inherited Create;
  FOwner := AOwner;
  if Assigned(FOwner) then
    FOwner.ItemList.Add(Self);
end;

destructor TPressParserObject.Destroy;
begin
  if Assigned(FOwner) then
    FOwner.ItemList.Extract(Self);
  FItemList.Free;
  inherited;
end;

function TPressParserObject.FindRule(Reader: TPressParserReader;
  AClasses: array of TPressParserClass): TPressParserClass;
var
  I: Integer;
begin
  for I := Low(AClasses) to High(AClasses) do
  begin
    Result := AClasses[I];
    if Assigned(Result) and Result.Apply(Reader) then
      Exit;
  end;
  Result := nil;
end;

function TPressParserObject.GetItemList: TPressParserList;
begin
  if not Assigned(FItemList) then
    FItemList := TPressParserList.Create(True);
  Result := FItemList;
end;

function TPressParserObject.GetItems(AIndex: Integer): TPressParserObject;
begin
  Result := ItemList[AIndex];
end;

class function TPressParserObject.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := True;
end;

procedure TPressParserObject.InternalRead(Reader: TPressParserReader);
begin
end;

function TPressParserObject.ItemCount: Integer;
begin
  if Assigned(FItemList) then
    Result := FItemList.Count
  else
    Result := 0;
end;

function TPressParserObject.Parse(
  Reader: TPressParserReader;
  AParserClasses: array of TPressParserClass;
  AOwner: TPressParserObject;
  ANecessary: Boolean;
  const AErrorExpectedMsg: string): TPressParserObject;
var
  VRule: TPressParserClass;
begin
  VRule := FindRule(Reader, AParserClasses);
  if Assigned(VRule) then
  begin
    if not Assigned(AOwner) then
      AOwner := Self;
    Result := VRule.Create(AOwner);
    Result.Read(Reader);
  end else
  begin
    Result := nil;
    if ANecessary then
      Reader.ErrorExpected(AErrorExpectedMsg, Reader.ReadToken);
  end;
end;

procedure TPressParserObject.Read(Reader: TPressParserReader);
begin
  InternalRead(Reader);
end;

{ TPressParserList }

function TPressParserList.Add(AObject: TPressParserObject): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressParserList.CreateIterator: TPressParserIterator;
begin
  Result := TPressParserIterator.Create(Self);
end;

function TPressParserList.GetItems(AIndex: Integer): TPressParserObject;
begin
  Result := inherited Items[AIndex] as TPressParserObject;
end;

function TPressParserList.IndexOf(AObject: TPressParserObject): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressParserList.Insert(
  Index: Integer; AObject: TPressParserObject);
begin
  inherited Insert(Index, AObject);
end;

function TPressParserList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressParserList.Remove(AObject: TPressParserObject): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressParserList.SetItems(
  AIndex: Integer; Value: TPressParserObject);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressParserIterator }

function TPressParserIterator.GetCurrentItem: TPressParserObject;
begin
  Result := inherited CurrentItem as TPressParserObject;
end;

end.
