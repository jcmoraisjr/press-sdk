(*
  PressObjects, Expression Library Classes
  Copyright (C) 2008 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressExpressionLib;

{$I Press.inc}

interface

uses
  Classes,
  PressExpression;

type
  TPressExpressionLibrary = class(TObject)
  private
    FOperations: TStringList;
  public
    destructor Destroy; override;
    function FindOperationClass(const AOperationToken: string): TPressExpressionOperationClass;
    procedure RegisterOperations(AOperations: array of TPressExpressionOperationClass);
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

  TPressExpressionPowerOperation = class(TPressExpressionOperation)
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

function PressExpressionLibrary: TPressExpressionLibrary;

implementation

uses
  Math;

var
  _ExpressionLibrary: TPressExpressionLibrary;

function PressExpressionLibrary: TPressExpressionLibrary;
begin
  if not Assigned(_ExpressionLibrary) then
    _ExpressionLibrary := TPressExpressionLibrary.Create;
  Result := _ExpressionLibrary;
end;

{ TPressExpressionLibrary }

destructor TPressExpressionLibrary.Destroy;
begin
  FOperations.Free;
  inherited;
end;

function TPressExpressionLibrary.FindOperationClass(
  const AOperationToken: string): TPressExpressionOperationClass;
var
  VIndex: Integer;
begin
  if Assigned(FOperations) and FOperations.Find(AOperationToken, VIndex) then
    Result := TPressExpressionOperationClass(FOperations.Objects[VIndex])
  else
    Result := nil;
end;

procedure TPressExpressionLibrary.RegisterOperations(
  AOperations: array of TPressExpressionOperationClass);
var
  I: Integer;
begin
  if not Assigned(FOperations) then
  begin
    FOperations := TStringList.Create;
    FOperations.Sorted := True;
  end;
  for I := 0 to Pred(Length(AOperations)) do
    FOperations.AddObject(AOperations[I].Token, TObject(AOperations[I]));
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
  Res^ := Val1^ + Val2^;
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
  Res^ := Val1^ - Val2^;
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
  Res^ := Val1^ * Val2^;
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
  Res^ := Val1^ / Val2^;
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
  Res^ := Val1^ div Val2^;
end;

{ TPressExpressionPowerOperation }

class function TPressExpressionPowerOperation.InternalOperatorToken: string;
begin
  Result := '^';
end;

function TPressExpressionPowerOperation.Priority: Byte;
begin
  Result := 20;
end;

procedure TPressExpressionPowerOperation.VarCalc;
begin
  Res^ := Power(Val1^, Val2^);
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

initialization
  PressExpressionLibrary.RegisterOperations([
   TPressExpressionAddOperation,
   TPressExpressionSubtractOperation,
   TPressExpressionMultiplyOperation,
   TPressExpressionDivideOperation,
   TPressExpressionIntDivOperation,
   TPressExpressionPowerOperation,
   TPressExpressionGreaterThanOperation,
   TPressExpressionGreaterThanOrEqualOperation,
   TPressExpressionLesserThanOperation,
   TPressExpressionLesserThanOrEqualOperation,
   TPressExpressionEqualOperation,
   TPressExpressionDiffOperation,
   TPressExpressionAndOperation,
   TPressExpressionOrOperation,
   TPressExpressionXorOperation]);

finalization
  _ExpressionLibrary.Free;

end.
