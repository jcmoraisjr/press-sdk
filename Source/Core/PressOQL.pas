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
  PressClasses,
  PressParser,
  PressSubject;

type
  TPressOQLReader = class(TPressParserReader)
  protected
    function InternalCreateBigSymbolsArray: TPressStringArray; override;
  end;

  TPressOQLObject = class(TPressParserObject)
  end;

  TPressOQLStatement = class(TPressOQLObject)
  private
    FModel: TPressModel;
  public
    constructor Create(AOwner: TPressParserObject; AModel: TPressModel = nil); reintroduce;
    property Model: TPressModel read FModel;
  end;

  TPressOQLTableReference = class(TObject)
  private
    FAliasName: string;
    FAttributeMetadata: TPressAttributeMetadata;
    FFieldName: string;
    FReferencedAliasName: string;
    FReferencedFieldName: string;
    FTableName: string;
    function GetAsString: string;
  public
    constructor Create(AAttributeMetadata: TPressAttributeMetadata; const ATableAliasPrefix, AReferencedAlias: string; AId: Integer);
    property AliasName: string read FAliasName;
    property AsString: string read GetAsString;
    property AttributeMetadata: TPressAttributeMetadata read FAttributeMetadata;
    property FieldName: string read FFieldName;
    property ReferencedAliasName: string read FReferencedAliasName;
    property ReferencedFieldName: string read FReferencedFieldName;
    property TableName: string read FTableName;
  end;

  TPressOQLTableReferences = class(TObject)
  private
    FList: TObjectList;
    FTableAliasPrefix: string;
    function GetAsString: string;
    function GetList: TObjectList;
  protected
    property List: TObjectList read GetList;
  public
    constructor Create(const ATableAliasPrefix: string);
    destructor Destroy; override;
    function TableReference(const AReferencedAlias: string; AAttributeMetadata: TPressAttributeMetadata): string;
    property AsString: string read GetAsString;    
  end;

  TPressOQLWhereClause = class;
  TPressOQLOrderByClause = class;

  TPressOQLSelectStatement = class(TPressOQLStatement)
  private
    FAny: Boolean;
    FMetadata: TPressObjectMetadata;
    FObjectClassName: string;
    FOrderByClause: TPressOQLOrderByClause;
    FTableReferences: TPressOQLTableReferences;
    FWhereClause: TPressOQLWhereClause;
    function BuildFieldNames: string;
    function BuildTableNames: string;
    function GetAsSQL: string;
    function GetTableAlias: string;
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    destructor Destroy; override;
    function TableReference(const AReferencedAlias: string; AAttributeMetadata: TPressAttributeMetadata): string;
    property AsSQL: string read GetAsSQL;
    property Metadata: TPressObjectMetadata read FMetadata;
    property ObjectClassName: string read FObjectClassName;
    property TableAlias: string read GetTableAlias;
  end;

  TPressOQLSelectObject = class(TPressOQLObject)
  private
    FSelect: TPressOQLSelectStatement;
  protected
    function InternalCreateObject(AClass: TPressParserClass): TPressParserObject; override;
  public
    constructor Create(AOwner: TPressParserObject); override;
    property Select: TPressOQLSelectStatement read FSelect;
  end;

  TPressOQLExpression = class(TPressOQLSelectObject)
  protected
    function GetAsString: string; virtual; abstract;
  public
    property AsString: string read GetAsString;
  end;

  TPressOQLFormula = class(TPressOQLExpression)
  protected
    function GetAsString: string; override;
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    property AsString: string read GetAsString;
  end;

  TPressOQLFormulaItem = class(TPressOQLExpression)
  private
    FNextOperator: string;
    FSign: string;
  protected
    function GetAsString: string; override;
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    function InternalAsString: string; virtual; abstract;
    procedure InternalRead(Reader: TPressParserReader); override;
    procedure InternalReadValue(Reader: TPressParserReader); virtual; abstract;
    class function IsSign(const AStr: string): Boolean;
    class function IsValueOperator(const AStr: string): Boolean;
  public
    property AsString: string read GetAsString;
    property NextOperator: string read FNextOperator;
  end;

  TPressOQLLiteral = class(TPressOQLFormulaItem)
  private
    FLiteral: string;
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    function InternalAsString: string; override;
    procedure InternalReadValue(Reader: TPressParserReader); override;
    class function IsLiteral(const AStr: string): Boolean;
  end;

  TPressOQLAttributeValue = class;

  TPressOQLAttribute = class(TPressOQLFormulaItem)
  private
    FValue: TPressOQLAttributeValue;
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    function InternalAsString: string; override;
    function InternalFinishReading(Reader: TPressParserReader; const ATableAlias: string; AAttribute: TPressAttributeMetadata): TPressOQLAttributeValue; virtual; abstract;
    function InternalReadItems(Reader: TPressParserReader; const ATableAlias: string; AAttribute: TPressAttributeMetadata): TPressOQLAttributeValue; virtual; abstract;
    procedure InternalReadValue(Reader: TPressParserReader); override;
  end;

  TPressOQLPlainAttribute = class(TPressOQLAttribute)
  protected
    function InternalFinishReading(Reader: TPressParserReader; const ATableAlias: string; AAttribute: TPressAttributeMetadata): TPressOQLAttributeValue; override;
    function InternalReadItems(Reader: TPressParserReader; const ATableAlias: string; AAttribute: TPressAttributeMetadata): TPressOQLAttributeValue; override;
  end;

  TPressOQLContainerAttribute = class(TPressOQLAttribute)
  protected
    function InternalFinishReading(Reader: TPressParserReader; const ATableAlias: string; AAttribute: TPressAttributeMetadata): TPressOQLAttributeValue; override;
    function InternalReadItems(Reader: TPressParserReader; const ATableAlias: string; AAttribute: TPressAttributeMetadata): TPressOQLAttributeValue; override;
  end;

  TPressOQLAttributeValue = class(TPressOQLSelectObject)
  private
    FMetadata: TPressAttributeMetadata;
    FTableAlias: string;
  protected
    function GetAsString: string; virtual; abstract;
  public
    property AsString: string read GetAsString;
    property Metadata: TPressAttributeMetadata read FMetadata write FMetadata;
    property TableAlias: string read FTableAlias write FTableAlias;
  end;

  TPressOQLPlainAttributeValue = class(TPressOQLAttributeValue)
  protected
    function GetAsString: string; override;
  end;

  TPressOQLContainerValue = class(TPressOQLAttributeValue)
  protected
    function BuildFieldNames: string; virtual; abstract;
    function BuildTableNames: string; virtual; abstract;
    function BuildWhereClause: string; virtual;
    function GetAsString: string; override;
  end;

  TPressOQLContainerAttributeValue = class(TPressOQLContainerValue)
  protected
    function BuildFieldNames: string; override;
    function BuildTableNames: string; override;
  end;

  TPressOQLContainerCalcValue = class(TPressOQLContainerValue)
  private
    FAttributeMetadata: TPressAttributeMetadata;
    FFunctionName: string;
    FObjectMetadata: TPressObjectMetadata;
    function GetObjectMetadata: TPressObjectMetadata;
  protected
    function BuildFieldNames: string; override;
    function BuildTableNames: string; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    property ObjectMetadata: TPressObjectMetadata read GetObjectMetadata;
  end;

  TPressOQLClause = class(TPressOQLSelectObject)
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

  TPressOQLWhereExpressions = class(TPressOQLSelectObject)
  private
    function GetAsString: string;
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    property AsString: string read GetAsString;
  end;

  TPressOQLWhereExpression = class(TPressOQLSelectObject)
  private
    FNextOperator: string;
    function GetAsString: string;
  protected
    function InternalAsString: string; virtual; abstract;
    procedure InternalRead(Reader: TPressParserReader); override;
    procedure InternalReadExpression(Reader: TPressParserReader); virtual; abstract;
  public
    property NextOperator: string read FNextOperator write FNextOperator;
    property AsString: string read GetAsString;
  end;

  TPressOQLWhereDirectExpression = class(TPressOQLWhereExpression)
  private
    FLeftExpression: TPressOQLExpression;
    FNot: Boolean;
    FOperator: string;
    FRightExpression: TPressOQLExpression;
  protected
    function InternalAsString: string; override;
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalReadExpression(Reader: TPressParserReader); override;
  end;

  TPressOQLWhereBracketExpression = class(TPressOQLWhereExpression)
  private
    FExpressions: TPressOQLWhereExpressions;
  protected
    function InternalAsString: string; override;
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalReadExpression(Reader: TPressParserReader); override;
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

  TPressOQLOrderByElement = class(TPressOQLSelectObject)
  private
    { TODO : Include the fields in the select clause }
    FValue: TPressOQLPlainAttribute;
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
  PressCompatibility,
  PressAttributes;

{ TPressOQLReader }

function TPressOQLReader.InternalCreateBigSymbolsArray: TPressStringArray;
begin
  SetLength(Result, 3);
  Result[0] := '<=';
  Result[1] := '>=';
  Result[2] := '<>';
end;

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
  const ATableAliasPrefix, AReferencedAlias: string; AId: Integer);
var
  VObjectMetadata: TPressObjectMetadata;
begin
  inherited Create;
  FAttributeMetadata := AAttributeMetadata;
  FAliasName := ATableAliasPrefix + IntToStr(AId);
  if FAttributeMetadata.AttributeClass.InheritsFrom(TPressValue) then
  begin
    VObjectMetadata := FAttributeMetadata.Owner;
    FReferencedFieldName := FAttributeMetadata.Owner.IdMetadata.PersistentName;
  end else
  begin
    VObjectMetadata := FAttributeMetadata.ObjectClass.ClassMetadata;
    FReferencedFieldName := FAttributeMetadata.PersistentName;
  end;
  FFieldName := VObjectMetadata.IdMetadata.PersistentName;
  FReferencedAliasName := AReferencedAlias;
  FTableName := VObjectMetadata.PersistentName;
end;

function TPressOQLTableReference.GetAsString: string;
begin
  Result := Format('left outer join %s %s on %s.%s = %1:s.%4:s', [
   TableName, AliasName, ReferencedAliasName, ReferencedFieldName, FieldName]);
end;

{ TPressOQLTableReferences }

constructor TPressOQLTableReferences.Create(
  const ATableAliasPrefix: string);
begin
  inherited Create;
  FTableAliasPrefix := ATableAliasPrefix;
end;

destructor TPressOQLTableReferences.Destroy;
begin
  FList.Free;
  inherited;
end;

function TPressOQLTableReferences.GetAsString: string;
var
  I: Integer;
begin
  Result := '';
  if Assigned(FList) then
    for I := 0 to Pred(FList.Count) do
      Result := Result + (FList[I] as TPressOQLTableReference).AsString;
end;

function TPressOQLTableReferences.GetList: TObjectList;
begin
  if not Assigned(FList) then
    FList := TObjectList.Create(True);
  Result := FList;
end;

function TPressOQLTableReferences.TableReference(
  const AReferencedAlias: string;
  AAttributeMetadata: TPressAttributeMetadata): string;

  function FindReference: TPressOQLTableReference;
  var
    I: Integer;
  begin
    for I := 0 to Pred(List.Count) do
    begin
      Result := List[I] as TPressOQLTableReference;
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
    VReference := TPressOQLTableReference.Create(AAttributeMetadata,
     FTableAliasPrefix, AReferencedAlias, Succ(List.Count));
    List.Add(VReference);
  end;
  Result := VReference.AliasName;
end;

{ TPressOQLSelectStatement }

function TPressOQLSelectStatement.BuildFieldNames: string;
begin
  Result := Format('%s.%s', [
   TableAlias,
   FMetadata.IdMetadata.PersistentName]);
  if FMetadata.ClassIdName <> '' then
    Result := Format('%s, %s.%s', [
     Result,
     TableAlias,
     FMetadata.ClassIdName]);
end;

function TPressOQLSelectStatement.BuildTableNames: string;
begin
  Result := FMetadata.PersistentName + ' ' +TableAlias;
  if Assigned(FTableReferences) then
    Result := Result + ' ' + FTableReferences.AsString;
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
      Result := Result + ' ' + FWhereClause.AsString;
    if Assigned(FOrderByClause) then
      Result := Result + ' ' + FOrderByClause.AsString;
  end else
    Result := '';
end;

function TPressOQLSelectStatement.GetTableAlias: string;
begin
  Result := SPressTableAliasPrefix + '0';
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
  FObjectClassName := FMetadata.ObjectClassName;
  FWhereClause := TPressOQLWhereClause(Parse(Reader, [TPressOQLWhereClause]));
  FOrderByClause :=
   TPressOQLOrderByClause(Parse(Reader, [TPressOQLOrderByClause]));
  Reader.ReadMatchEof;
end;

function TPressOQLSelectStatement.TableReference(
  const AReferencedAlias: string;
  AAttributeMetadata: TPressAttributeMetadata): string;
begin
  if not Assigned(FTableReferences) then
    FTableReferences := TPressOQLTableReferences.Create(SPressTableAliasPrefix);
  Result :=
   FTableReferences.TableReference(AReferencedAlias, AAttributeMetadata);
end;

{ TPressOQLSelectObject }

constructor TPressOQLSelectObject.Create(AOwner: TPressParserObject);
begin
  inherited Create(AOwner);
  if AOwner is TPressOQLSelectStatement then
    FSelect := TPressOQLSelectStatement(AOwner);
end;

function TPressOQLSelectObject.InternalCreateObject(
  AClass: TPressParserClass): TPressParserObject;
begin
  Result := inherited InternalCreateObject(AClass);
  if Result is TPressOQLSelectObject then
    TPressOQLSelectObject(Result).FSelect := Select;
end;

{ TPressOQLFormula }

function TPressOQLFormula.GetAsString: string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Pred(ItemCount) do
    Result := Result + (Items[I] as TPressOQLFormulaItem).AsString;
end;

class function TPressOQLFormula.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := TPressOQLLiteral.Apply(Reader) or
   TPressOQLPlainAttribute.Apply(Reader);
end;

procedure TPressOQLFormula.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  repeat
  until TPressOQLFormulaItem(Parse(Reader, [
   TPressOQLLiteral, TPressOQLPlainAttribute],
   Self, True, SPressAttributeNameMsg)).NextOperator = '';
end;

{ TPressOQLFormulaItem }

function TPressOQLFormulaItem.GetAsString: string;
begin
  Result := FSign + InternalAsString;
  if FNextOperator <> '' then
    Result := Result + ' ' + FNextOperator + ' ';
end;

class function TPressOQLFormulaItem.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := IsSign(Reader.ReadToken);
end;

procedure TPressOQLFormulaItem.InternalRead(Reader: TPressParserReader);
var
  Token: string;
begin
  inherited;
  Token := Reader.ReadToken;
  if IsSign(Token) then
    FSign := Token
  else
    Reader.UnreadToken;
  InternalReadValue(Reader);
  Token := Reader.ReadToken;
  if IsValueOperator(Token) then
    FNextOperator := Token
  else
    Reader.UnreadToken;
end;

class function TPressOQLFormulaItem.IsSign(const AStr: string): Boolean;
begin
  Result := (AStr <> '') and (AStr[1] in ['+', '-']);
end;

class function TPressOQLFormulaItem.IsValueOperator(
  const AStr: string): Boolean;
begin
  { TODO : Improve }
  Result := (AStr = '+') or (AStr = '-') or (AStr = '*') or (AStr = '/');
end;

{ TPressOQLLiteral }

class function TPressOQLLiteral.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := IsLiteral(Reader.ReadNextToken) or inherited InternalApply(Reader);
end;

function TPressOQLLiteral.InternalAsString: string;
begin
  Result := FLiteral;
end;

procedure TPressOQLLiteral.InternalReadValue(Reader: TPressParserReader);
const
  { TODO : read quote char from the database broker }
  CQuote = '''';
var
  Token: string;
begin
  Token := Reader.ReadToken;
  if (Token <> '') and (Token[1] in ['''', '"']) and (Token[1] <> CQuote) then
    FLiteral := AnsiQuotedStr(UnquotedStr(Token), CQuote)
  else
    FLiteral := Token;
end;

class function TPressOQLLiteral.IsLiteral(const AStr: string): Boolean;
begin
  Result := (AStr <> '') and (AStr[1] in ['0'..'9', '''', '"']); 
end;

{ TPressOQLAttribute }

class function TPressOQLAttribute.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := IsValidIdent(Reader.ReadNextToken) or
   inherited InternalApply(Reader);
end;

function TPressOQLAttribute.InternalAsString: string;
begin
  if Assigned(FValue) then
    Result := FValue.AsString
  else
    Result := '';
end;

procedure TPressOQLAttribute.InternalReadValue(Reader: TPressParserReader);
var
  VSelect: TPressOQLSelectStatement;
  VMetadata: TPressObjectMetadata;
  VAttribute: TPressAttributeMetadata;
  VTableAlias: string;
  VIndex: Integer;
  Token: string;
begin
  Token := Reader.ReadIdentifier;
  VSelect := Select;
  VMetadata := VSelect.Metadata;
  VTableAlias := VSelect.TableAlias;
  repeat
    VIndex := VMetadata.Map.IndexOfName(Token);
    if VIndex = -1 then
      Reader.ErrorExpected(SPressAttributeNameMsg, Token);
    VAttribute := VMetadata.Map[VIndex];
    if VAttribute.Owner <> VMetadata then
    begin
      VTableAlias := VSelect.TableReference(VTableAlias, VAttribute);
      VMetadata := VAttribute.Owner;
    end;
    Token := Reader.ReadToken;
    if Token = '.' then
    begin
      if VAttribute.AttributeClass.InheritsFrom(TPressItem) then
      begin
        VTableAlias := VSelect.TableReference(VTableAlias, VAttribute);
        VMetadata := VAttribute.ObjectClass.ClassMetadata;
        Token := Reader.ReadIdentifier;
      end else if VAttribute.AttributeClass.InheritsFrom(TPressItems) then
      begin
        FValue := InternalReadItems(Reader, VTableAlias, VAttribute);
        Exit;
      end else
        Reader.ErrorFmt(SUnsupportedAttribute, [
         VMetadata.ObjectClassName, VAttribute.Name]);
    end else
    begin
      Reader.UnreadToken;
      FValue := InternalFinishReading(Reader, VTableAlias, VAttribute);
      Exit;
    end;
  until False;
end;

{ TPressOQLPlainAttribute }

function TPressOQLPlainAttribute.InternalFinishReading(
  Reader: TPressParserReader; const ATableAlias: string;
  AAttribute: TPressAttributeMetadata): TPressOQLAttributeValue;
begin
  if AAttribute.AttributeClass.InheritsFrom(TPressItems) then
    Reader.ErrorFmt(SUnsupportedAttribute, [
     AAttribute.Owner.ClassName, AAttribute.Name]);
  Result := TPressOQLPlainAttributeValue.Create(Self);
  Result.TableAlias := ATableAlias;
  Result.Metadata := AAttribute;
  Result.Read(Reader);
end;

function TPressOQLPlainAttribute.InternalReadItems(
  Reader: TPressParserReader; const ATableAlias: string;
  AAttribute: TPressAttributeMetadata): TPressOQLAttributeValue;
begin
  Result := TPressOQLContainerCalcValue.Create(Self);
  Result.TableAlias := ATableAlias;
  Result.Metadata := AAttribute;
  Result.Read(Reader);
end;

{ TPressOQLContainerAttribute }

function TPressOQLContainerAttribute.InternalFinishReading(
  Reader: TPressParserReader; const ATableAlias: string;
  AAttribute: TPressAttributeMetadata): TPressOQLAttributeValue;
begin
  if not AAttribute.AttributeClass.InheritsFrom(TPressItems) then
    Reader.ErrorFmt(SUnsupportedAttribute, [
     AAttribute.Owner.ClassName, AAttribute.Name]);
  Result := TPressOQLContainerAttributeValue.Create(Self);
  Result.TableAlias := ATableAlias;
  Result.Metadata := AAttribute;
  Result.Read(Reader);
end;

function TPressOQLContainerAttribute.InternalReadItems(
  Reader: TPressParserReader; const ATableAlias: string;
  AAttribute: TPressAttributeMetadata): TPressOQLAttributeValue;
begin
  Result := nil;
  Reader.ErrorMsg(SCannotUseAggregateFunctionHere);
end;

{ TPressOQLPlainAttributeValue }

function TPressOQLPlainAttributeValue.GetAsString: string;
begin
  if (TableAlias <> '') and Assigned(Metadata) then
    Result := TableAlias + '.' + Metadata.PersistentName
  else
    Result := '';
end;

{ TPressOQLContainerValue }

function TPressOQLContainerValue.BuildWhereClause: string;
begin
  { TODO : Use table alias name improvement }
  if Assigned(Metadata) then
    Result := Format('ts2.%s = %s.%s', [
     Metadata.PersLinkParentName,
     TableAlias,
     Metadata.Owner.IdMetadata.PersistentName])
  else
    Result := '';
end;

function TPressOQLContainerValue.GetAsString: string;
begin
  Result := Format('(select %s from %s where %s)', [
   BuildFieldNames,
   BuildTableNames,
   BuildWhereClause]);
end;

{ TPressOQLContainerAttributeValue }

function TPressOQLContainerAttributeValue.BuildFieldNames: string;
begin
  if Assigned(Metadata) then
    Result := Format('ts2.%s', [Metadata.PersLinkChildName])
  else
    Result := '';
end;

function TPressOQLContainerAttributeValue.BuildTableNames: string;
begin
  if Assigned(Metadata) then
    Result := Format('%s ts2', [Metadata.PersLinkName])
  else
    Result := '';
end;

{ TPressOQLContainerCalcValue }

function TPressOQLContainerCalcValue.BuildFieldNames: string;
begin
  if Assigned(FAttributeMetadata) then
    Result := FFunctionName + '(' + FAttributeMetadata.PersistentName + ')'
  else
    Result := FFunctionName + '(*)';
end;

function TPressOQLContainerCalcValue.BuildTableNames: string;
begin
  { TODO : Improve table alias names }
  { TODO : Improve for owned objects that doesn't use link table
    (future implementation) }
  if Assigned(Metadata) then
    Result := Format('%s ts1 inner join %s ts2 on ts1.%s = ts2.%s', [
     ObjectMetadata.PersistentName,
     Metadata.PersLinkName,
     ObjectMetadata.IdMetadata.PersistentName,
     Metadata.PersLinkChildName])
  else
    Result := '';
end;

function TPressOQLContainerCalcValue.GetObjectMetadata: TPressObjectMetadata;
begin
  if not Assigned(FObjectMetadata) then
  { TODO : Validate Metadata }
    FObjectMetadata := Metadata.ObjectClass.ClassMetadata;
  Result := FObjectMetadata;
end;

procedure TPressOQLContainerCalcValue.InternalRead(Reader: TPressParserReader);
var
  VIndex: Integer;
  Token: string;
begin
  inherited;
  { TODO : Implement support for more than one attribute }
  { TODO : Implement support for path }
  FFunctionName := Reader.ReadIdentifier;
  Token := Reader.ReadToken;
  if Token = '(' then
  begin
    Token := Reader.ReadIdentifier;
    VIndex := ObjectMetadata.Map.IndexOfName(Token);
    if VIndex = -1 then
      Reader.ErrorExpected(SPressAttributeNameMsg, Token);
    FAttributeMetadata := ObjectMetadata.Map[VIndex];
    if not FAttributeMetadata.AttributeClass.InheritsFrom(TPressValue) then
      Reader.ErrorFmt(SUnsupportedAttribute, [
       ObjectMetadata.ObjectClassName, FAttributeMetadata.Name]);
    Reader.ReadMatch(')');
  end else
  begin
    Reader.UnreadToken;
    FAttributeMetadata := nil;
  end;
end;

{ TPressOQLWhereClause }

function TPressOQLWhereClause.GetAsString: string;
begin
  if Assigned(FExpressions) then
    Result := 'where ' + FExpressions.AsString
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

function TPressOQLWhereExpressions.GetAsString: string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Pred(ItemCount) do
    Result := Result + (Items[I] as TPressOQLWhereExpression).AsString;
end;

class function TPressOQLWhereExpressions.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := TPressOQLWhereBracketExpression.Apply(Reader) or
   TPressOQLWhereDirectExpression.Apply(Reader);
end;

procedure TPressOQLWhereExpressions.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  repeat
  until TPressOQLWhereExpression(Parse(Reader, [
   TPressOQLWhereBracketExpression, TPressOQLWhereDirectExpression],
   Self, True, SPressExpressionMsg)).NextOperator = '';
end;

{ TPressOQLWhereExpression }

function TPressOQLWhereExpression.GetAsString: string;
begin
  Result := InternalAsString;
  if (Result <> '') and (FNextOperator <> '') then
    Result := Result + ' ' + FNextOperator + ' ';
end;

procedure TPressOQLWhereExpression.InternalRead(
  Reader: TPressParserReader);
var
  Token: string;
begin
  inherited;
  InternalReadExpression(Reader);
  Token := Reader.ReadToken;
  if SameText(Token, 'and') or SameText(Token, 'or') then
    FNextOperator := Token
  else
    Reader.UnreadToken;
end;

{ TPressOQLWhereDirectExpression }

class function TPressOQLWhereDirectExpression.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := Reader.ReadToken <> ')';
  { TODO : not IsReservedWord(Token) and not IsSymbol(Token) }
end;

function TPressOQLWhereDirectExpression.InternalAsString: string;
const
  CNotString: array[Boolean] of string = ('', 'not ');
begin
  if Assigned(FLeftExpression) and Assigned(FRightExpression) then
  begin
    Result := Format('%s%s %s %s', [
     CNotString[FNot],
     FLeftExpression.AsString,
     FOperator,
     FRightExpression.AsString]);
  end else
    Result := '';
end;

procedure TPressOQLWhereDirectExpression.InternalReadExpression(
  Reader: TPressParserReader);
var
  VExpressionClass: TPressParserClass;
  Token: string;
begin
  Token := Reader.ReadToken;
  FNot := SameText(Token, 'not');
  if not FNot then
    Reader.UnreadToken;
  FLeftExpression :=
   TPressOQLExpression(Parse(Reader, [TPressOQLFormula],
   Self, True, SPressExpressionMsg));
  { TODO : Validate operator (>, >=, <, <=, =, <>, in) }
  FOperator := Reader.ReadToken;
  if SameText(FOperator, 'in') then
    VExpressionClass := TPressOQLContainerAttribute
  else
    VExpressionClass := TPressOQLFormula;
  FRightExpression :=
   TPressOQLExpression(Parse(Reader, [VExpressionClass],
   Self, True, SPressExpressionMsg));
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

procedure TPressOQLWhereBracketExpression.InternalReadExpression(
  Reader: TPressParserReader);
begin
  Reader.ReadMatch('(');
  FExpressions := TPressOQLWhereExpressions(
   Parse(Reader, [TPressOQLWhereExpressions]));
  Reader.ReadMatch(')');
end;

{ TPressOQLOrderByClause }

function TPressOQLOrderByClause.GetAsString: string;
var
  I: Integer;
begin
  if ItemCount > 0 then
  begin
    Result := 'order by ';
    for I := 0 to Pred(ItemCount) do
      Result := Result + (Items[I] as TPressOQLOrderByElement).AsString + ', ';
    SetLength(Result, Length(Result) - 2);
  end;
end;

class function TPressOQLOrderByClause.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := SameText(Reader.ReadToken, 'order');
end;

procedure TPressOQLOrderByClause.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  Reader.ReadMatch('order');
  Reader.ReadMatch('by');
  repeat
    Parse(Reader, [TPressOQLOrderByElement], Self, True, SPressAttributeNameMsg);
  until Reader.ReadToken <> ',';
  Reader.UnreadToken;
end;

{ TPressOQLOrderByElement }

function TPressOQLOrderByElement.GetAsString: string;
begin
  if Assigned(FValue) then
  begin
    Result := FValue.AsString;
    if FDesc then
      Result := Result + ' desc';
  end else
    Result := '';
end;

class function TPressOQLOrderByElement.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := IsValidIdent(Reader.ReadToken);
end;

procedure TPressOQLOrderByElement.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  { TODO : TPressOQLPlainAttribute is a formula item, refactor }
  FValue := TPressOQLPlainAttribute(Parse(Reader, [TPressOQLPlainAttribute]));
  if Assigned(FValue) then
  begin
    FDesc := SameText(Reader.ReadToken, 'desc');
    if not FDesc then
      Reader.UnreadToken;
  end;
end;

end.
