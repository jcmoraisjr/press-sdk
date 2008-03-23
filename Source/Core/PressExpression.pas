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

  TPressExpressionOperationClass = class of TPressExpressionOperation;

  TPressExpressionOperation = class(TPressExpressionObject)
  private
    FRes: TPressExpressionValue;
    FVal1: PPressExpressionValue;
    FVal2: PPressExpressionValue;
    function GetRes: PPressExpressionValue;
  protected
    class function InternalOperatorToken: string; virtual; abstract;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    function Priority: Byte; virtual; abstract;
    class function Token: string;
    procedure VarCalc; virtual; abstract;
    property Res: PPressExpressionValue read GetRes;
    property Val1: PPressExpressionValue read FVal1 write FVal1;
    property Val2: PPressExpressionValue read FVal2 write FVal2;
  end;

implementation

uses
  SysUtils,
  PressConsts,
  PressExpressionLib;

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
var
  VOperationClass: TPressExpressionOperationClass;
begin
  VOperationClass :=
   PressExpressionLibrary.FindOperationClass(Reader.ReadNextToken);
  if Assigned(VOperationClass) then
    Result := TPressExpressionOperation(Parse(Reader, [VOperationClass]))
  else
    Result := nil;
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
  VVarParser.Variable := VVar;
  VVarParser.Read(Reader);
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

procedure TPressExpressionOperation.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  Reader.ReadMatchText(InternalOperatorToken);
end;

class function TPressExpressionOperation.Token: string;
begin
  Result := InternalOperatorToken;
end;

end.
