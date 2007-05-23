(*
  PressObjects, Object Query Language Parser
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressOQL;

{$I Press.inc}

interface

uses
  Contnrs,
  PressParser,
  PressSubject;

type
  TPressOQLReader = class(TPressParserReader)
  end;

  TPressOQLObject = class(TPressParserObject)
  end;

  TPressOQLStatement = class(TPressOQLObject)
  private
    FModel: TPressModel;
  public
    constructor Create(AOwner: TPressParserObject; AModel: TPressModel = nil);
    property Model: TPressModel read FModel;
  end;

  TPressOQLTableReference = class(TObject)
  private
    FAliasName: string;
    FAttributeMetadata: TPressAttributeMetadata;
    FFieldName: string;
    FOwnerAliasName: string;
    FOwnerFieldName: string;
    FTableName: string;
  public
    constructor Create(AAttributeMetadata: TPressAttributeMetadata; const AOwnerAlias: string; AId: Integer);
    property AliasName: string read FAliasName;
    property AttributeMetadata: TPressAttributeMetadata read FAttributeMetadata;
    property FieldName: string read FFieldName;
    property OwnerAliasName: string read FOwnerAliasName;
    property OwnerFieldName: string read FOwnerFieldName;
    property TableName: string read FTableName;
  end;

  TPressOQLWhereClause = class;
  TPressOQLOrderByClause = class;

  TPressOQLSelectStatement = class(TPressOQLStatement)
  private
    FAny: Boolean;
    FMetadata: TPressObjectMetadata;
    FOrderByClause: TPressOQLOrderByClause;
    FTableReferences: TObjectList;
    FWhereClause: TPressOQLWhereClause;
    function BuildFieldNames: string;
    function BuildTableNames: string;
    function GetAsSQL: string;
    function GetTableAlias: string;
    function GetTableReferences: TObjectList;
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
    property TableReferences: TObjectList read GetTableReferences;
  public
    destructor Destroy; override;
    function TableReference(const AOwnerAlias: string; AAttributeMetadata: TPressAttributeMetadata): string;
    property AsSQL: string read GetAsSQL;
    property Metadata: TPressObjectMetadata read FMetadata;
    property TableAlias: string read GetTableAlias;
  end;

  TPressOQLValue = class(TPressOQLObject)
  private
    FStatement: string;
  protected
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    property Statement: string read FStatement;
  end;

  TPressOQLClause = class(TPressOQLObject)
  end;

  TPressOQLWhereExpressions = class;

  TPressOQLWhereClause = class(TPressOQLClause)
  private
    FExpressions: TPressOQLWhereExpressions;
    function GetAsString: string;
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    property AsString: string read GetAsString;
  end;

  TPressOQLWhereExpressions = class(TPressOQLObject)
  private
    FExpressions: string;
    function BuildExpressions: string;
    function GetAsString: string;
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    property AsString: string read GetAsString;
  end;

  TPressOQLWhereExpression = class(TPressOQLObject)
  private
    FConnectorToken: string;
    function GetAsString: string;
  protected
    function InternalAsString: string; virtual; abstract;
  public
    property ConnectorToken: string read FConnectorToken write FConnectorToken;
    property AsString: string read GetAsString;
  end;

  TPressOQLWhereSimpleExpression = class(TPressOQLWhereExpression)
  private
    FLeftValue: TPressOQLValue;
    FNot: Boolean;
    FOperator: string;
    FRightValue: TPressOQLValue;
  protected
    function InternalAsString: string; override;
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  end;

  TPressOQLWhereBracketExpression = class(TPressOQLWhereExpression)
  private
    FExpressions: TPressOQLWhereExpressions;
  protected
    function InternalAsString: string; override;
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  end;

  TPressOQLOrderByClause = class(TPressOQLClause)
  private
    function GetAsString: string;
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    property AsString: string read GetAsString;
  end;

  TPressOQLOrderByElement = class(TPressOQLObject)
  private
    { TODO : Include the fields in the select clause }
    FValue: TPressOQLValue;
    FDesc: Boolean;
    function GetAsString: string;
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    property AsString: string read GetAsString;
  end;

implementation

uses
  SysUtils,
  PressConsts,
  PressAttributes;

{ TPressOQLStatement }

constructor TPressOQLStatement.Create(
  AOwner: TPressParserObject; AModel: TPressModel);
begin
  inherited Create(AOwner);
  if not Assigned(FModel) then
    FModel := PressModel
  else
    FModel := AModel;
end;

{ TPressOQLTableReference }

constructor TPressOQLTableReference.Create(
  AAttributeMetadata: TPressAttributeMetadata;
  const AOwnerAlias: string; AId: Integer);
var
  VObjectMetadata: TPressObjectMetadata;
begin
  inherited Create;
  FAttributeMetadata := AAttributeMetadata;
  FAliasName := SPressTableAliasPrefix + InttoStr(AId);
  VObjectMetadata := FAttributeMetadata.ObjectClass.ClassMetadata;
  FFieldName := VObjectMetadata.IdMetadata.PersistentName;
  FOwnerAliasName := AOwnerAlias;
  FOwnerFieldName := FAttributeMetadata.PersistentName;
  FTableName := VObjectMetadata.PersistentName;
end;

{ TPressOQLSelectStatement }

function TPressOQLSelectStatement.BuildFieldNames: string;
begin
  Result := Format('%s.%s, %0:s.%2:s', [
   TableAlias,
   FMetadata.IdMetadata.PersistentName,
   FMetadata.ClassIdName]);
end;

function TPressOQLSelectStatement.BuildTableNames: string;
var
  VReference: TPressOQLTableReference;
  I: Integer;
begin
  Result := FMetadata.PersistentName + ' ' +TableAlias;
  for I := 0 to Pred(TableReferences.Count) do
  begin
    VReference := TableReferences[I] as TPressOQLTableReference;
    Result := Format('%s left outer join %s %s on %s.%s = %2:s.%5:s', [
     Result,
     VReference.TableName,
     VReference.AliasName,
     VReference.OwnerAliasName,
     VReference.OwnerFieldName,
     VReference.FieldName]);
  end;
end;

destructor TPressOQLSelectStatement.Destroy;
begin
  FTableReferences.Free;
  inherited;
end;

function TPressOQLSelectStatement.GetAsSQL: string;
begin
  if Assigned(FMetadata) then
  begin
    Result := Format('select %s from %s', [
     BuildFieldNames, BuildTableNames]);
    if Assigned(FWhereClause) then
      Result := Result + ' where ' + FWhereClause.AsString;
    if Assigned(FOrderByClause) then
      Result := Result + ' order by ' + FOrderByClause.AsString;
  end else
    Result := '';
end;

function TPressOQLSelectStatement.GetTableAlias: string;
begin
  Result := SPressTableAliasPrefix + '0';
end;

function TPressOQLSelectStatement.GetTableReferences: TObjectList;
begin
  if not Assigned(FTableReferences) then
    FTableReferences := TObjectList.Create(True);
  Result := FTableReferences;
end;

class function TPressOQLSelectStatement.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := Reader.ReadToken = 'select';
end;

procedure TPressOQLSelectStatement.InternalRead(Reader: TPressParserReader);
var
  Token: string;
begin
  inherited;
  Reader.ReadMatch('select');
  Reader.ReadMatch('*');
  Reader.ReadMatch('from');
  Token := Reader.ReadIdentifier;
  FAny := SameText(Token, 'any');
  if FAny then
    Token := Reader.ReadIdentifier;
  FMetadata := Model.FindMetadata(Token);
  if not Assigned(FMetadata) then
    Reader.ErrorFmt(SClassNotFound, [Token]);
  FWhereClause := TPressOQLWhereClause(Parse(Reader, [TPressOQLWhereClause]));
  FOrderByClause :=
   TPressOQLOrderByClause(Parse(Reader, [TPressOQLOrderByClause]));
  Reader.ReadMatchEof;
end;

function TPressOQLSelectStatement.TableReference(const AOwnerAlias: string;
  AAttributeMetadata: TPressAttributeMetadata): string;

  function FindReference: TPressOQLTableReference;
  var
    I: Integer;
  begin
    for I := 0 to Pred(TableReferences.Count) do
    begin
      Result := TableReferences[I] as TPressOQLTableReference;
      if Result.AttributeMetadata = AAttributeMetadata then
        Exit;
    end;
    Result := nil;
  end;

var
  VReference: TPressOQLTableReference;
begin
  VReference := FindReference;
  if not Assigned(VReference) then
  begin
    VReference := TPressOQLTableReference.Create(
     AAttributeMetadata, AOwnerAlias, Succ(TableReferences.Count));
    TableReferences.Add(VReference);
  end;
  Result := VReference.AliasName;
end;

{ TPressOQLValue }

procedure TPressOQLValue.InternalRead(Reader: TPressParserReader);
var
  VSelect: TPressOQLSelectStatement;
  VMetadata: TPressObjectMetadata;
  VAttribute: TPressAttributeMetadata;
  VTableAlias: string;
  VIndex: Integer;
  Token: string;
begin
  inherited;
  Token := Reader.ReadToken;
  if (Length(Token) > 0) and IsValidIdent(Token[1]) then
  begin
    VSelect := (Owner.Owner as TPressOQLSelectStatement);
    VMetadata := VSelect.Metadata;
    VTableAlias := VSelect.TableAlias;
    repeat
      VIndex := VMetadata.Map.IndexOfName(Token);
      if VIndex = -1 then
        Reader.ErrorExpected(SPressAttributeNameMsg, Token);
      VAttribute := VMetadata.Map[VIndex];
      Token := Reader.ReadToken;
      if Token <> '.' then
        Break;
      if not VAttribute.AttributeClass.InheritsFrom(TPressItem) then
        Reader.ErrorFmt(SAttributeIsNotItem, [
         VMetadata.ObjectClassName, VAttribute.Name]);
      VTableAlias := VSelect.TableReference(VTableAlias, VAttribute);
      VMetadata := VAttribute.ObjectClass.ClassMetadata;
      Token := Reader.ReadToken;
    until False;
    Reader.UnreadToken;
    if VAttribute.AttributeClass.InheritsFrom(TPressItems) then
      Reader.ErrorFmt(SUnsupportedAttribute, [
       VMetadata.ObjectClassName, VAttribute.Name]);
    FStatement := VTableAlias + '.' + VAttribute.PersistentName;
  end else
    FStatement := Token;
end;

{ TPressOQLWhereClause }

function TPressOQLWhereClause.GetAsString: string;
begin
  if Assigned(FExpressions) then
    Result := FExpressions.AsString
  else
    Result := '';
end;

class function TPressOQLWhereClause.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := Reader.ReadToken = 'where';
end;

procedure TPressOQLWhereClause.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  Reader.ReadMatch('where');
  FExpressions :=
   TPressOQLWhereExpressions(Parse(Reader, [TPressOQLWhereExpressions]));
end;

{ TPressOQLWhereExpressions }

function TPressOQLWhereExpressions.BuildExpressions: string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Pred(ItemCount) do
    Result := Result + (Items[I] as TPressOQLWhereExpression).AsString;
end;

function TPressOQLWhereExpressions.GetAsString: string;
begin
  if FExpressions = '' then
    FExpressions := BuildExpressions;
  Result := FExpressions;
end;

class function TPressOQLWhereExpressions.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := TPressOQLWhereBracketExpression.Apply(Reader) or
   TPressOQLWhereSimpleExpression.Apply(Reader);
end;

procedure TPressOQLWhereExpressions.InternalRead(Reader: TPressParserReader);
var
  VExpression: TPressOQLWhereExpression;
  Token: string;
begin
  inherited;
  repeat
    VExpression := TPressOQLWhereExpression(Parse(Reader, [
     TPressOQLWhereBracketExpression, TPressOQLWhereSimpleExpression],
     Owner, True, 'expression'));
    Token := Reader.ReadToken;
    if SameText(Token, 'and') or SameText(Token, 'or') then
      VExpression.ConnectorToken := Token
    else
      Reader.UnreadToken;
  until VExpression.ConnectorToken = '';
end;

{ TPressOQLWhereExpression }

function TPressOQLWhereExpression.GetAsString: string;
begin
  Result := InternalAsString;
  if (Result <> '') and (FConnectorToken <> '') then
    Result := Result + ' ' + FConnectorToken + ' ';
end;

{ TPressOQLWhereSimpleExpression }

class function TPressOQLWhereSimpleExpression.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := Reader.ReadToken <> ')';
  { TODO : not IsReservedWord(Token) and not IsSymbol(Token) }
end;

function TPressOQLWhereSimpleExpression.InternalAsString: string;
const
  CNotString: array[Boolean] of string = ('', 'not ');
begin
  if Assigned(FLeftValue) and Assigned(FRightValue) then
  begin
    Result := Format('%s%s %s %s', [
     CNotString[FNot],
     FLeftValue.Statement,
     FOperator,
     FRightValue.Statement]);
  end else
    Result := '';
end;

procedure TPressOQLWhereSimpleExpression.InternalRead(
  Reader: TPressParserReader);
var
  Token: string;
begin
  inherited;
  Token := Reader.ReadToken;
  FNot := SameText(Token, 'not');
  if not FNot then
    Reader.UnreadToken;
  FLeftValue :=
   TPressOQLValue(Parse(Reader, [TPressOQLValue],
   Owner, True, 'statement'));
  { TODO : Validate operator }
  FOperator := Reader.ReadToken;
  FRightValue :=
   TPressOQLValue(Parse(Reader, [TPressOQLValue],
   Owner, True, 'statement'));
end;

{ TPressOQLWhereBracketExpression }

class function TPressOQLWhereBracketExpression.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := Reader.ReadToken = '(';
end;

function TPressOQLWhereBracketExpression.InternalAsString: string;
begin
  if Assigned(FExpressions) then
    Result := '(' + FExpressions.AsString + ')'
  else
    Result := '';
end;

procedure TPressOQLWhereBracketExpression.InternalRead(
  Reader: TPressParserReader);
begin
  inherited;
  Reader.ReadMatch('(');
  FExpressions := TPressOQLWhereExpressions(
   Parse(Reader, [TPressOQLWhereExpressions], Owner));
  Reader.ReadMatch(')');
end;

{ TPressOQLOrderByClause }

function TPressOQLOrderByClause.GetAsString: string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Pred(ItemCount) do
    Result := Result + (Items[I] as TPressOQLOrderByElement).AsString + ', ';
  SetLength(Result, Length(Result) - 2);
end;

class function TPressOQLOrderByClause.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := SameText(Reader.ReadToken, 'order') and
   SameText(Reader.ReadToken, 'by');
end;

procedure TPressOQLOrderByClause.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  Reader.ReadMatch('order');
  Reader.ReadMatch('by');
  repeat
    Parse(Reader, [TPressOQLOrderByElement], Self, True, 'attribute name');
  until Reader.ReadToken <> ',';
  Reader.UnreadToken;
end;

{ TPressOQLOrderByElement }

function TPressOQLOrderByElement.GetAsString: string;
begin
  if Assigned(FValue) then
  begin
    Result := FValue.Statement;
    if FDesc then
      Result := Result + ' desc';
  end else
    Result := '';
end;

class function TPressOQLOrderByElement.InternalApply(
  Reader: TPressParserReader): Boolean;
var
  Token: string;
begin
  Token := Reader.ReadToken;
  Result := (Length(Token) > 0) and IsValidIdent(Token[1]);
end;

procedure TPressOQLOrderByElement.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  FValue := TPressOQLValue(Parse(Reader, [TPressOQLValue], Owner));
  if Assigned(FValue) then
  begin
    FDesc := SameText(Reader.ReadToken, 'desc');
    if not FDesc then
      Reader.UnreadToken;
  end;
end;

end.
