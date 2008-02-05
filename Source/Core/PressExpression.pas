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
  Variant,
{$endif}
  Contnrs,
  PressParser;

type
  TPressExpressionValue = Variant;
  PPressExpressionValue = ^TPressExpressionValue;

  TPressExpressionReader = class(TPressParserReader)
  end;

  TPressExpressionObject = class(TPressParserObject)
  end;

  TPressExpressionItem = class;
  TPressExpressionItemClass = class of TPressExpressionItem;
  TPressExpressionOperation = class;

  TPressExpression = class(TPressExpressionObject)
  private
    FOperations: TObjectList;
    FRes: PPressExpressionValue;
    function GetOperations: TObjectList;
    function GetVarValue: Variant;
    function ParseItem(Reader: TPressParserReader): TPressExpressionItem;
    function ParseRightOperands(Reader: TPressParserReader; var ALeftItem: TPressExpressionItem; ADepth: Integer): PPressExpressionValue;
  protected
    function InternalParseOperand(Reader: TPressParserReader): TPressExpressionItem; virtual;
    function InternalParseOperation(Reader: TPressParserReader): TPressExpressionOperation; virtual;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    destructor Destroy; override;
    function ParseExpression(Reader: TPressParserReader): PPressExpressionValue;
    property Operations: TObjectList read GetOperations;
    property Res: PPressExpressionValue read FRes;
    property VarValue: Variant read GetVarValue;
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

  TPressExpressionVariableItem = class(TPressExpressionItem)
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
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

implementation

uses
  SysUtils,
  PressClasses,
  PressConsts;

{ TPressExpression }

destructor TPressExpression.Destroy;
begin
  FOperations.Free;
  inherited;
end;

function TPressExpression.GetOperations: TObjectList;
begin
  if not Assigned(FOperations) then
    FOperations := TObjectList.Create(False);
  Result := FOperations;
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
  Result := TPressExpressionItem(Parse(Reader, [TPressExpressionBracketItem,
   TPressExpressionLiteralItem, TPressExpressionVariableItem]));
end;

function TPressExpression.InternalParseOperation(
  Reader: TPressParserReader): TPressExpressionOperation;
begin
  Result := TPressExpressionOperation(Parse(Reader, [
   TPressExpressionAddOperation, TPressExpressionSubtractOperation,
   TPressExpressionMultiplyOperation, TPressExpressionDivideOperation,
   TPressExpressionIntDivOperation]));
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

{ TPressExpressionVariableItem }

class function TPressExpressionVariableItem.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  { TODO : Implement }
  Result := False;  // VarExists(Reader.ReadToken);
end;

procedure TPressExpressionVariableItem.InternalRead(
  Reader: TPressParserReader);
begin
  inherited;
  { TODO : Implement }
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
  Result := 1;
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
  Result := 1;
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
  Result := 2;
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
  Result := 2;
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
  Result := 2;
end;

procedure TPressExpressionIntDivOperation.VarCalc;
begin
  Res^ := FVal1^ div FVal2^;
end;

end.
