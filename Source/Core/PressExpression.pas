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
    function ParseRightOperands(Reader: TPressParserReader; var ALeftItem: TPressExpressionItem): PPressExpressionValue;
    function ReadCurrentOperand(Reader: TPressParserReader): TPressExpressionItem;
  protected
    function GetVarValue: Variant;
    function InternalParse(Reader: TPressParserReader): TPressExpressionItem; virtual;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    destructor Destroy; override;
    procedure ParseExpression(Reader: TPressParserReader);
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
    procedure InternalReadElement(Reader: TPressParserReader); virtual;
  public
    property NextOperation: TPressExpressionOperation read FNextOperation;
    property Res: PPressExpressionValue read FRes write FRes;
  end;

  TPressExpressionBracket = class(TPressExpressionItem)
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalReadElement(Reader: TPressParserReader); override;
  end;

  TPressExpressionLiteral = class(TPressExpressionItem)
  private
    FLiteral: TPressExpressionValue;
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalReadElement(Reader: TPressParserReader); override;
  end;

  TPressExpressionVariable = class(TPressExpressionItem)
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalReadElement(Reader: TPressParserReader); override;
  end;

  TPressExpressionOperation = class(TPressExpressionObject)
  private
    FRes: PPressExpressionValue;
    FVal1: PPressExpressionValue;
    FVal2: PPressExpressionValue;
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    class function InternalOperatorToken: string; virtual; abstract;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    constructor Create(AOwner: TPressParserObject); override;
    destructor Destroy; override;
    function Priority: Byte; virtual; abstract;
    procedure VarCalc; virtual; abstract;
    property Res: PPressExpressionValue read FRes write FRes;
    property Val1: PPressExpressionValue read FVal1 write FVal1;
    property Val2: PPressExpressionValue read FVal2 write FVal2;
  end;

  TPressExpressionAdd = class(TPressExpressionOperation)
  protected
    class function InternalOperatorToken: string; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    function Priority: Byte; override;
    procedure VarCalc; override;
  end;

  TPressExpressionSubtract = class(TPressExpressionOperation)
  protected
    class function InternalOperatorToken: string; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    function Priority: Byte; override;
    procedure VarCalc; override;
  end;

  TPressExpressionMultiply = class(TPressExpressionOperation)
  protected
    class function InternalOperatorToken: string; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    function Priority: Byte; override;
    procedure VarCalc; override;
  end;

  TPressExpressionDivide = class(TPressExpressionOperation)
  protected
    class function InternalOperatorToken: string; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    function Priority: Byte; override;
    procedure VarCalc; override;
  end;

  TPressExpressionIntDiv = class(TPressExpressionOperation)
  protected
    class function InternalOperatorToken: string; override;
    procedure InternalRead(Reader: TPressParserReader); override;
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

function TPressExpression.InternalParse(
  Reader: TPressParserReader): TPressExpressionItem;
begin
  Result := nil;
end;

procedure TPressExpression.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  ParseExpression(Reader);
  Reader.ReadMatchEof;
end;

procedure TPressExpression.ParseExpression(Reader: TPressParserReader);
var
  VItem: TPressExpressionItem;
begin
  VItem := ReadCurrentOperand(Reader);
  FRes := ParseRightOperands(Reader, VItem)
end;

function TPressExpression.ParseRightOperands(Reader: TPressParserReader;
  var ALeftItem: TPressExpressionItem): PPressExpressionValue;
var
  VRightItem: TPressExpressionItem;
  VCurrentOp, VNextOp: TPressExpressionOperation;
  VLeftOperand: PPressExpressionValue;
begin
  VLeftOperand := ALeftItem.Res;
  VCurrentOp := ALeftItem.NextOperation;
  while Assigned(VCurrentOp) do
  begin
    VRightItem := ReadCurrentOperand(Reader);
    VNextOp := VRightItem.NextOperation;
    VCurrentOp.Val1 := VLeftOperand;
    if Assigned(VNextOp) and (VCurrentOp.Priority < VNextOp.Priority) then
      VCurrentOp.Val2 := ParseRightOperands(Reader, VRightItem)
    else
      VCurrentOp.Val2 := VRightItem.Res;
    VLeftOperand := VCurrentOp.Res;
    Operations.Add(VCurrentOp);
    ALeftItem := VRightItem;
    VCurrentOp := ALeftItem.NextOperation;
  end;
  Result := VLeftOperand;
end;

function TPressExpression.ReadCurrentOperand(
  Reader: TPressParserReader): TPressExpressionItem;
begin
  Result := TPressExpressionItem(Parse(Reader, [TPressExpressionBracket,
   TPressExpressionLiteral, TPressExpressionVariable]));
  if not Assigned(Result) then
  begin
    Result := InternalParse(Reader);
    if not Assigned(Result) then
      Reader.ErrorExpected(SPressIdentifierMsg, Reader.ReadToken);
  end;
end;

{ TPressExpressionItem }

procedure TPressExpressionItem.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  InternalReadElement(Reader);
  FNextOperation := TPressExpressionOperation(Parse(Reader, [
   TPressExpressionAdd, TPressExpressionSubtract, TPressExpressionMultiply,
   TPressExpressionDivide, TPressExpressionIntDiv]));
end;

procedure TPressExpressionItem.InternalReadElement(Reader: TPressParserReader);
begin
end;

{ TPressExpressionBracket }

class function TPressExpressionBracket.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := Reader.ReadToken = '(';
end;

procedure TPressExpressionBracket.InternalReadElement(
  Reader: TPressParserReader);
var
  VOwner: TPressExpression;
begin
  inherited;
  VOwner := Owner as TPressExpression;
  Reader.ReadMatch('(');
  VOwner.ParseExpression(Reader);
  Reader.ReadMatch(')');
  Res := VOwner.Res;
end;

{ TPressExpressionLiteral }

class function TPressExpressionLiteral.InternalApply(
  Reader: TPressParserReader): Boolean;
var
  Token: string;
begin
  Token := Reader.ReadToken;
  Result := (Token <> '') and (Token[1] in ['''', '"', '+', '-', '0'..'9']);
end;

procedure TPressExpressionLiteral.InternalReadElement(
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

{ TPressExpressionVariable }

class function TPressExpressionVariable.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  { TODO : Implement }
  Result := False;  // VarExists(Reader.ReadToken);
end;

procedure TPressExpressionVariable.InternalReadElement(
  Reader: TPressParserReader);
begin
  inherited;
  { TODO : Implement }
end;

{ TPressExpressionOperation }

constructor TPressExpressionOperation.Create(AOwner: TPressParserObject);
begin
  inherited Create(AOwner);
  New(FRes);
end;

destructor TPressExpressionOperation.Destroy;
begin
  Dispose(FRes);
  inherited;
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

{ TPressExpressionAdd }

class function TPressExpressionAdd.InternalOperatorToken: string;
begin
  Result := '+';
end;

procedure TPressExpressionAdd.InternalRead(Reader: TPressParserReader);
begin
  inherited;
end;

function TPressExpressionAdd.Priority: Byte;
begin
  Result := 1;
end;

procedure TPressExpressionAdd.VarCalc;
begin
  Res^ := FVal1^ + FVal2^;
end;

{ TPressExpressionSubtract }

class function TPressExpressionSubtract.InternalOperatorToken: string;
begin
  Result := '-';
end;

procedure TPressExpressionSubtract.InternalRead(Reader: TPressParserReader);
begin
  inherited;
end;

function TPressExpressionSubtract.Priority: Byte;
begin
  Result := 1;
end;

procedure TPressExpressionSubtract.VarCalc;
begin
  Res^ := FVal1^ - FVal2^;
end;

{ TPressExpressionMultiply }

class function TPressExpressionMultiply.InternalOperatorToken: string;
begin
  Result := '*';
end;

procedure TPressExpressionMultiply.InternalRead(Reader: TPressParserReader);
begin
  inherited;
end;

function TPressExpressionMultiply.Priority: Byte;
begin
  Result := 2;
end;

procedure TPressExpressionMultiply.VarCalc;
begin
  Res^ := FVal1^ * FVal2^;
end;

{ TPressExpressionDivide }

class function TPressExpressionDivide.InternalOperatorToken: string;
begin
  Result := '/';
end;

procedure TPressExpressionDivide.InternalRead(Reader: TPressParserReader);
begin
  inherited;
end;

function TPressExpressionDivide.Priority: Byte;
begin
  Result := 2;
end;

procedure TPressExpressionDivide.VarCalc;
begin
  Res^ := FVal1^ / FVal2^;
end;

{ TPressExpressionIntDiv }

class function TPressExpressionIntDiv.InternalOperatorToken: string;
begin
  Result := 'div';
end;

procedure TPressExpressionIntDiv.InternalRead(Reader: TPressParserReader);
begin
  inherited;
end;

function TPressExpressionIntDiv.Priority: Byte;
begin
  Result := 2;
end;

procedure TPressExpressionIntDiv.VarCalc;
begin
  Res^ := FVal1^ div FVal2^;
end;

end.
