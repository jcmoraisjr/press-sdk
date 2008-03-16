(*
  PressObjects, Expression Parser Classes
  Copyright (C) 2008 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressExpression;

{$I Press.inc}

interface

uses
{$ifndef d5down}
  Variants,
{$endif}
  Contnrs,
  PressClasses,
  PressParser;

type
  TPressExpressionValue = Variant;
  PPressExpressionValue = ^TPressExpressionValue;

  TPressExpressionReader = class(TPressParserReader)
  protected
    function InternalCreateBigSymbolsArray: TPressStringArray; override;
  end;

  TPressExpressionObject = class(TPressParserObject)
  end;

  TPressExpressionVar = class;
  TPressExpressionVarList = class;
  TPressExpressionItem = class;
  TPressExpressionItemClass = class of TPressExpressionItem;
  TPressExpressionOperation = class;

  TPressExpression = class(TPressExpressionObject)
  private
    FOperations: TObjectList;
    FRes: PPressExpressionValue;
    FVars: TPressExpressionVarList;
    function GetOperations: TObjectList;
    function GetVars: TPressExpressionVarList;
    function GetVarValue: Variant;
    function ParseItem(Reader: TPressParserReader): TPressExpressionItem;
    function ParseRightOperands(Reader: TPressParserReader; var ALeftItem: TPressExpressionItem; ADepth: Integer): PPressExpressionValue;
    function ParseVar(Reader: TPressParserReader): TPressExpressionItem;
  protected
    function InternalParseOperand(Reader: TPressParserReader): TPressExpressionItem; virtual;
    function InternalParseOperation(Reader: TPressParserReader): TPressExpressionOperation; virtual;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    destructor Destroy; override;
    function ParseExpression(Reader: TPressParserReader): PPressExpressionValue;
    property Operations: TObjectList read GetOperations;
    property Res: PPressExpressionValue read FRes;
    property Vars: TPressExpressionVarList read GetVars;
    property VarValue: Variant read GetVarValue;
  end;

  TPressExpressionVar = class(TObject)
  private
    FName: string;
    FValue: TPressExpressionValue;
    function GetValuePtr: PPressExpressionValue;
  public
    constructor Create(const AName: string);
    property Name: string read FName;
    property Value: TPressExpressionValue read FValue write FValue;
    property ValuePtr: PPressExpressionValue read GetValuePtr;
  end;

  TPressExpressionVarList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressExpressionVar;
    function GetVariable(const AVarName: string): TPressExpressionValue;
    procedure SetItems(AIndex: Integer; Value: TPressExpressionVar);
    procedure SetVariable(const AVarName: string; Value: TPressExpressionValue);
  public
    function IndexOf(const AVarName: string): Integer;
    function FindVar(const AVarName: string): TPressExpressionVar;
    function VarByName(const AVarName: string): TpressExpressionVar;
    property Items[AIndex: Integer]: TPressExpressionVar read GetItems write SetItems;
    property Variable[const AVarName: string]: TPressExpressionValue read GetVariable write SetVariable; default;
  end;

  TPressExpressionItem = class(TPressExpressionObject)
  private
    FNextOperation: TPressExpressionOperation;
    FRes: PPressExpressionValue;
  protected
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    property NextOperation: TPressExpressionOperation read FNextOperation;
    property Res: PPressExpressionValue read FRes write FRes;
  end;

  TPressExpressionBracketItem = class(TPressExpressionItem)
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  end;

  TPressExpressionLiteralItem = class(TPressExpressionItem)
  private
    FLiteral: TPressExpressionValue;
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  end;

  TPressExpressionVarItem = class(TPressExpressionItem)
  private
    FVariable: TPressExpressionVar;
  protected
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    property Variable: TPressExpressionVar read FVariable write FVariable;
  end;

  TPressExpressionOperation = class(TPressExpressionObject)
  private
    FRes: TPressExpressionValue;
    FVal1: PPressExpressionValue;
    FVal2: PPressExpressionValue;
    function GetRes: PPressExpressionValue;
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    class function InternalOperatorToken: string; virtual; abstract;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    function Priority: Byte; virtual; abstract;
    procedure VarCalc; virtual; abstract;
    property Res: PPressExpressionValue read GetRes;
    property Val1: PPressExpressionValue read FVal1 write FVal1;
    property Val2: PPressExpressionValue read FVal2 write FVal2;
  end;

  TPressExpressionAddOperation = class(TPressExpressionOperation)
  protected
    class function InternalOperatorToken: string; override;
  public
    function Priority: Byte; override;
    procedure VarCalc; override;
  end;

  TPressExpressionSubtractOperation = class(TPressExpressionOperation)
  protected
    class function InternalOperatorToken: string; override;
  public
    function Priority: Byte; override;
    procedure VarCalc; override;
  end;

  TPressExpressionMultiplyOperation = class(TPressExpressionOperation)
  protected
    class function InternalOperatorToken: string; override;
  public
    function Priority: Byte; override;
    procedure VarCalc; override;
  end;

  TPressExpressionDivideOperation = class(TPressExpressionOperation)
  protected
    class function InternalOperatorToken: string; override;
  public
    function Priority: Byte; override;
    procedure VarCalc; override;
  end;

  TPressExpressionIntDivOperation = class(TPressExpressionOperation)
  protected
    class function InternalOperatorToken: string; override;
  public
    function Priority: Byte; override;
    procedure VarCalc; override;
  end;

  TPressExpressionGreaterThanOperation = class(TPressExpressionOperation)
  protected
    class function InternalOperatorToken: string; override;
  public
    function Priority: Byte; override;
    procedure VarCalc; override;
  end;

  TPressExpressionLesserThanOperation = class(TPressExpressionOperation)
  protected
    class function InternalOperatorToken: string; override;
  public
    function Priority: Byte; override;
    procedure VarCalc; override;
  end;

  TPressExpressionGreaterThanOrEqualOperation = class(TPressExpressionOperation)
  protected
    class function InternalOperatorToken: string; override;
  public
    function Priority: Byte; override;
    procedure VarCalc; override;
  end;

  TPressExpressionLesserThanOrEqualOperation = class(TPressExpressionOperation)
  protected
    class function InternalOperatorToken: string; override;
  public
    function Priority: Byte; override;
    procedure VarCalc; override;
  end;

  TPressExpressionEqualOperation = class(TPressExpressionOperation)
  protected
    class function InternalOperatorToken: string; override;
  public
    function Priority: Byte; override;
    procedure VarCalc; override;
  end;

  TPressExpressionDiffOperation = class(TPressExpressionOperation)
  protected
    class function InternalOperatorToken: string; override;
  public
    function Priority: Byte; override;
    procedure VarCalc; override;
  end;

  TPressExpressionAndOperation = class(TPressExpressionOperation)
  protected
    class function InternalOperatorToken: string; override;
  public
    function Priority: Byte; override;
    procedure VarCalc; override;
  end;

  TPressExpressionOrOperation = class(TPressExpressionOperation)
  protected
    class function InternalOperatorToken: string; override;
  public
    function Priority: Byte; override;
    procedure VarCalc; override;
  end;

  TPressExpressionXorOperation = class(TPressExpressionOperation)
  protected
    class function InternalOperatorToken: string; override;
  public
    function Priority: Byte; override;
    procedure VarCalc; override;
  end;

implementation

uses
  SysUtils,
  PressConsts;

{ TPressExpressionReader }

function TPressExpressionReader.InternalCreateBigSymbolsArray: TPressStringArray;
begin
  SetLength(Result, 3);
  Result[0] := '<=';
  Result[1] := '>=';
  Result[2] := '<>';
end;

{ TPressExpression }

destructor TPressExpression.Destroy;
begin
  FVars.Free;
  FOperations.Free;
  inherited;
end;

function TPressExpression.GetOperations: TObjectList;
begin
  if not Assigned(FOperations) then
    FOperations := TObjectList.Create(False);
  Result := FOperations;
end;

function TPressExpression.GetVars: TPressExpressionVarList;
begin
  if not Assigned(FVars) then
    FVars := TPressExpressionVarList.Create(True);
  Result := FVars;
end;

function TPressExpression.GetVarValue: Variant;
var
  I: Integer;
begin
  if Assigned(FRes) then
  begin
    if Assigned(FOperations) then
      for I := 0 to Pred(FOperations.Count) do
        TPressExpressionOperation(FOperations[I]).VarCalc;
    Result := FRes^;
  end else
    Result := varEmpty;
end;

function TPressExpression.InternalParseOperand(
  Reader: TPressParserReader): TPressExpressionItem;
begin
  Result := TPressExpressionItem(Parse(Reader, [
   TPressExpressionBracketItem, TPressExpressionLiteralItem]));
  if not Assigned(Result) then
    Result := ParseVar(Reader);
end;

function TPressExpression.InternalParseOperation(
  Reader: TPressParserReader): TPressExpressionOperation;
begin
  Result := TPressExpressionOperation(Parse(Reader, [
   TPressExpressionAddOperation, TPressExpressionSubtractOperation,
   TPressExpressionMultiplyOperation, TPressExpressionDivideOperation,
   TPressExpressionIntDivOperation,
   TPressExpressionGreaterThanOperation, TPressExpressionGreaterThanOrEqualOperation,
   TPressExpressionLesserThanOperation, TPressExpressionLesserThanOrEqualOperation,
   TPressExpressionEqualOperation, TPressExpressionDiffOperation,
   TPressExpressionAndOperation, TPressExpressionOrOperation,
   TPressExpressionXorOperation]));
end;

procedure TPressExpression.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  ParseExpression(Reader);
  Reader.ReadMatchEof;
end;

function TPressExpression.ParseExpression(
  Reader: TPressParserReader): PPressExpressionValue;
var
  VItem: TPressExpressionItem;
begin
  VItem := ParseItem(Reader);
  FRes := ParseRightOperands(Reader, VItem, 0);
  Result := FRes;
end;

function TPressExpression.ParseItem(
  Reader: TPressParserReader): TPressExpressionItem;
begin
  Result := InternalParseOperand(Reader);
  if not Assigned(Result) then
    Reader.ErrorExpected(SPressIdentifierMsg, Reader.ReadToken);
  Result.FNextOperation := InternalParseOperation(Reader);
end;

function TPressExpression.ParseRightOperands(Reader: TPressParserReader;
  var ALeftItem: TPressExpressionItem; ADepth: Integer): PPressExpressionValue;
var
  VRightItem: TPressExpressionItem;
  VCurrentOp, VNextOp: TPressExpressionOperation;
  VLeftOperand: PPressExpressionValue;
begin
  VLeftOperand := ALeftItem.Res;
  VCurrentOp := ALeftItem.NextOperation;
  while Assigned(VCurrentOp) do
  begin
    VRightItem := ParseItem(Reader);
    VNextOp := VRightItem.NextOperation;
    VCurrentOp.Val1 := VLeftOperand;
    if Assigned(VNextOp) and (VCurrentOp.Priority < VNextOp.Priority) then
      VCurrentOp.Val2 := ParseRightOperands(Reader, VRightItem, Succ(ADepth))
    else
      VCurrentOp.Val2 := VRightItem.Res;
    VLeftOperand := VCurrentOp.Res;
    Operations.Add(VCurrentOp);
    ALeftItem := VRightItem;
    if (ADepth = 0) or (Assigned(ALeftItem.NextOperation) and
     (VCurrentOp.Priority = ALeftItem.NextOperation.Priority)) then
      VCurrentOp := ALeftItem.NextOperation
    else
      VCurrentOp := nil;
  end;
  Result := VLeftOperand;
end;

function TPressExpression.ParseVar(
  Reader: TPressParserReader): TPressExpressionItem;
var
  VVar: TPressExpressionVar;
  VVarParser: TPressExpressionVarItem;
begin
  Result := nil;
  VVar := Vars.FindVar(Reader.ReadNextToken);
  if not Assigned(VVar) then
    Exit;
  VVarParser := TPressExpressionVarItem.Create(Self);
  try
    VVarParser.Variable := VVar;
    VVarParser.Read(Reader);
  except
    VVarParser.Free;
    raise;
  end;
  Result := VVarParser;
end;

{ TPressExpressionVar }

constructor TPressExpressionVar.Create(const AName: string);
begin
  if not IsValidIdent(AName) then
    raise EPressError.CreateFmt(SInvalidIdentifier, [AName]);
  inherited Create;
  FName := AName;
end;

function TPressExpressionVar.GetValuePtr: PPressExpressionValue;
begin
  Result := @FValue;
end;

{ TPressExpressionVarList }

function TPressExpressionVarList.FindVar(
  const AVarName: string): TPressExpressionVar;
var
  VIndex: Integer;
begin
  VIndex := IndexOf(AVarName);
  if VIndex >= 0 then
    Result := Items[VIndex]
  else
    Result := nil;
end;

function TPressExpressionVarList.GetItems(AIndex: Integer): TPressExpressionVar;
begin
  Result := inherited Items[AIndex] as TPressExpressionVar;
end;

function TPressExpressionVarList.GetVariable(
  const AVarName: string): TPressExpressionValue;
begin
  Result := VarByName(AVarName).Value;
end;

function TPressExpressionVarList.IndexOf(const AVarName: string): Integer;
begin
  for Result := 0 to Pred(Count) do
    if SameText(AVarName, Items[Result].Name) then
      Exit;
  Result := -1;
end;

procedure TPressExpressionVarList.SetItems(
  AIndex: Integer; Value: TPressExpressionVar);
begin
  inherited Items[AIndex] := Value;
end;

procedure TPressExpressionVarList.SetVariable(
  const AVarName: string; Value: TPressExpressionValue);
begin
  VarByName(AVarName).Value := Value;
end;

function TPressExpressionVarList.VarByName(
  const AVarName: string): TpressExpressionVar;
begin
  Result := FindVar(AVarName);
  if not Assigned(Result) then
    Result := Items[inherited Add(TPressExpressionVar.Create(AVarName))];
end;

{ TPressExpressionItem }

procedure TPressExpressionItem.InternalRead(Reader: TPressParserReader);
begin
  inherited;
end;

{ TPressExpressionBracketItem }

class function TPressExpressionBracketItem.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := Reader.ReadToken = '(';
end;

procedure TPressExpressionBracketItem.InternalRead(
  Reader: TPressParserReader);
begin
  inherited;
  Reader.ReadMatch('(');
  Res := (Owner as TPressExpression).ParseExpression(Reader);
  Reader.ReadMatch(')');
end;

{ TPressExpressionLiteralItem }

class function TPressExpressionLiteralItem.InternalApply(
  Reader: TPressParserReader): Boolean;
var
  Token: string;
begin
  Token := Reader.ReadToken;
  Result := (Token <> '') and (Token[1] in ['''', '"', '+', '-', '0'..'9']);
end;

procedure TPressExpressionLiteralItem.InternalRead(
  Reader: TPressParserReader);

  function AsFloat(const AStr: string): Double;
  var
    VErr: Integer;
  begin
    Val(AStr, Result, VErr);
    if VErr <> 0 then
      Reader.ErrorExpected(SPressNumberValueMsg, AStr);
  end;

var
  Token: string;
begin
  inherited;
  Token := Reader.ReadNextToken;
  if (Token <> '') and (Token[1] in ['''', '"']) then
    FLiteral := Reader.ReadUnquotedString
  else if Pos('.', Token) > 0 then
    FLiteral := AsFloat(Reader.ReadNumber)
  else
    FLiteral := Reader.ReadInteger;
  Res := @FLiteral;
end;

{ TPressExpressionVarItem }

procedure TPressExpressionVarItem.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  Reader.ReadMatchText(Variable.Name);
  Res := Variable.ValuePtr;
end;

{ TPressExpressionOperation }

function TPressExpressionOperation.GetRes: PPressExpressionValue;
begin
  Result := @FRes;
end;

class function TPressExpressionOperation.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := Reader.ReadToken = InternalOperatorToken;
end;

procedure TPressExpressionOperation.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  Reader.ReadMatch(InternalOperatorToken);
end;

{ TPressExpressionAddOperation }

class function TPressExpressionAddOperation.InternalOperatorToken: string;
begin
  Result := '+';
end;

function TPressExpressionAddOperation.Priority: Byte;
begin
  Result := 10;
end;

procedure TPressExpressionAddOperation.VarCalc;
begin
  Res^ := FVal1^ + FVal2^;
end;

{ TPressExpressionSubtractOperation }

class function TPressExpressionSubtractOperation.InternalOperatorToken: string;
begin
  Result := '-';
end;

function TPressExpressionSubtractOperation.Priority: Byte;
begin
  Result := 10;
end;

procedure TPressExpressionSubtractOperation.VarCalc;
begin
  Res^ := FVal1^ - FVal2^;
end;

{ TPressExpressionMultiplyOperation }

class function TPressExpressionMultiplyOperation.InternalOperatorToken: string;
begin
  Result := '*';
end;

function TPressExpressionMultiplyOperation.Priority: Byte;
begin
  Result := 15;
end;

procedure TPressExpressionMultiplyOperation.VarCalc;
begin
  Res^ := FVal1^ * FVal2^;
end;

{ TPressExpressionDivideOperation }

class function TPressExpressionDivideOperation.InternalOperatorToken: string;
begin
  Result := '/';
end;

function TPressExpressionDivideOperation.Priority: Byte;
begin
  Result := 15;
end;

procedure TPressExpressionDivideOperation.VarCalc;
begin
  Res^ := FVal1^ / FVal2^;
end;

{ TPressExpressionIntDivOperation }

class function TPressExpressionIntDivOperation.InternalOperatorToken: string;
begin
  Result := 'div';
end;

function TPressExpressionIntDivOperation.Priority: Byte;
begin
  Result := 15;
end;

procedure TPressExpressionIntDivOperation.VarCalc;
begin
  Res^ := FVal1^ div FVal2^;
end;

{ TPressExpressionGreaterThanOperation }

class function TPressExpressionGreaterThanOperation.InternalOperatorToken: string;
begin
  Result := '>';
end;

function TPressExpressionGreaterThanOperation.Priority: Byte;
begin
  Result := 5;
end;

procedure TPressExpressionGreaterThanOperation.VarCalc;
begin
  Res^ := Val1^ > Val2^;
end;

{ TPressExpressionLesserThanOperation }

class function TPressExpressionLesserThanOperation.InternalOperatorToken: string;
begin
  Result := '<';
end;

function TPressExpressionLesserThanOperation.Priority: Byte;
begin
  Result := 5;
end;

procedure TPressExpressionLesserThanOperation.VarCalc;
begin
  Res^ := Val1^ < Val2^;
end;

{ TPressExpressionGreaterThanOrEqualOperation }

class function TPressExpressionGreaterThanOrEqualOperation.InternalOperatorToken: string;
begin
  Result := '>=';
end;

function TPressExpressionGreaterThanOrEqualOperation.Priority: Byte;
begin
  Result := 5;
end;

procedure TPressExpressionGreaterThanOrEqualOperation.VarCalc;
begin
  Res^ := Val1^ >= Val2^;
end;

{ TPressExpressionLesserThanOrEqualOperation }

class function TPressExpressionLesserThanOrEqualOperation.InternalOperatorToken: string;
begin
  Result := '<=';
end;

function TPressExpressionLesserThanOrEqualOperation.Priority: Byte;
begin
  Result := 5;
end;

procedure TPressExpressionLesserThanOrEqualOperation.VarCalc;
begin
  Res^ := Val1^ <= Val2^;
end;

{ TPressExpressionEqualOperation }

class function TPressExpressionEqualOperation.InternalOperatorToken: string;
begin
  Result := '=';
end;

function TPressExpressionEqualOperation.Priority: Byte;
begin
  Result := 5;
end;

procedure TPressExpressionEqualOperation.VarCalc;
begin
  Res^ := Val1^ = Val2^;
end;

{ TPressExpressionDiffOperation }

class function TPressExpressionDiffOperation.InternalOperatorToken: string;
begin
  Result := '<>';
end;

function TPressExpressionDiffOperation.Priority: Byte;
begin
  Result := 5;
end;

procedure TPressExpressionDiffOperation.VarCalc;
begin
  Res^ := Val1^ <> Val2^;
end;

{ TPressExpressionAndOperation }

class function TPressExpressionAndOperation.InternalOperatorToken: string;
begin
  Result := 'and';
end;

function TPressExpressionAndOperation.Priority: Byte;
begin
  Result := 15;
end;

procedure TPressExpressionAndOperation.VarCalc;
begin
  Res^ := Val1^ and Val2^;
end;

{ TPressExpressionOrOperation }

class function TPressExpressionOrOperation.InternalOperatorToken: string;
begin
  Result := 'or';
end;

function TPressExpressionOrOperation.Priority: Byte;
begin
  Result := 10;
end;

procedure TPressExpressionOrOperation.VarCalc;
begin
  Res^ := Val1^ or Val2^;
end;

{ TPressExpressionXorOperation }

class function TPressExpressionXorOperation.InternalOperatorToken: string;
begin
  Result := 'xor';
end;

function TPressExpressionXorOperation.Priority: Byte;
begin
  Result := 10;
end;

procedure TPressExpressionXorOperation.VarCalc;
begin
  Res^ := Val1^ xor Val2^;
end;

end.
