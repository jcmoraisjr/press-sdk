(*
  PressObjects, Query Classes
  Copyright (C) 2006-2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressQuery;

{$I Press.inc}

interface

uses
  PressSubject,
  PressAttributes;

type
  TPressQueryAttributeCategory = (
   acNone, acMatch,
   acStarting, acFinishing, acPartial,
   acGreaterThan, acGreaterEqualThan,
   acLesserThan, acLesserEqualThan);

  TPressQueryMetadata = class;

  TPressQueryAttributeMetadata = class(TPressAttributeMetadata)
  private
    FCategory: TPressQueryAttributeCategory;
    FDataName: string;
    FIncludeIfEmpty: Boolean;
  protected
    procedure SetName(const Value: string); override;
  public
    constructor Create(AOwner: TPressObjectMetadata); override;
  published
    property Category: TPressQueryAttributeCategory read FCategory write FCategory default acMatch;
    property DataName: string read FDataName write FDataName;
    property IncludeIfEmpty: Boolean read FIncludeIfEmpty write FIncludeIfEmpty default False;
  end;

  TPressQueryMetadata = class(TPressObjectMetadata)
  private
    FIncludeSubClasses: Boolean;
    FItemObjectClass: TPressObjectClass;
    FOrderFieldName: string;
    function GetItemObjectClass: TPressObjectClass;
    function GetItemObjectClassName: string;
    procedure SetItemObjectClass(Value: TPressObjectClass);
    procedure SetItemObjectClassName(const Value: string);
  protected
    function InternalAttributeMetadataClass: TPressAttributeMetadataClass; override;
  public
    property IncludeSubClasses: Boolean read FIncludeSubClasses;
    property ItemObjectClass: TPressObjectClass read GetItemObjectClass write SetItemObjectClass;
    property ItemObjectClassName: string read GetItemObjectClassName write SetItemObjectClassName;
    property OrderFieldName: string read FOrderFieldName;
  published
    property Any: Boolean read FIncludeSubClasses write FIncludeSubClasses default False;
    property Order: string read FOrderFieldName write FOrderFieldName;
  end;

  TPressQueryItems = class(TPressReferences)
  protected
    procedure InternalUnassignObject(AObject: TPressObject); override;
  end;

  TPressQueryClass = class of TPressQuery;

  TPressQueryIterator = TPressProxyIterator;

  TPressQuery = class(TPressObject)
  private
    FQueryItems: TPressReferences;
    FMatchEmptyAndNull: Boolean;
    function AttributeToSQL(AAttribute: TPressAttribute): string;
    function GetMetadata: TPressQueryMetadata;
    function GetObjects(AIndex: Integer): TPressObject;
    function GetOrderByClause: string;
    function GetWhereClause: string;
  protected
    procedure Initialize; override;
    function InternalAttributeAddress(const AAttributeName: string): PPressAttribute; override;
    function InternalBuildOrderByClause: string; virtual;
    function InternalBuildStatement(AAttribute: TPressAttribute): string; virtual;
    function InternalBuildWhereClause: string; virtual;
    procedure InternalUpdateReferenceList; virtual;
  public
    function Add(AObject: TPressObject): Integer;
    procedure Clear;
    function Count: Integer;
    class function ClassMetadata: TPressQueryMetadata;
    function CreateIterator: TPressQueryIterator;
    class function ObjectMetadataClass: TPressObjectMetadataClass; override;
    function Remove(AObject: TPressObject): Integer;
    function RemoveReference(AProxy: TPressProxy): Integer;
    procedure UpdateReferenceList;
    property MatchEmptyAndNull: Boolean read FMatchEmptyAndNull write FMatchEmptyAndNull;
    property Metadata: TPressQueryMetadata read GetMetadata;
    property Objects[AIndex: Integer]: TPressObject read GetObjects; default;
    property OrderByClause: string read GetOrderByClause;
    property WhereClause: string read GetWhereClause;
  end;

implementation

uses
  SysUtils,
  PressClasses,
  PressConsts,
  PressPersistence;

{ TPressQueryAttributeMetadata }

constructor TPressQueryAttributeMetadata.Create(
  AOwner: TPressObjectMetadata);
begin
  inherited Create(AOwner);
  FCategory := acNone;
  FIncludeIfEmpty := False;
end;

procedure TPressQueryAttributeMetadata.SetName(const Value: string);
begin
  inherited;
  if FDataName = '' then
    FDataName := Value;
end;

{ TPressQueryMetadata }

function TPressQueryMetadata.GetItemObjectClass: TPressObjectClass;
begin
  if not Assigned(FItemObjectClass) then
    raise EPressError.CreateFmt(SUnassignedItemObjectClass, [ClassName]);
  Result := FItemObjectClass;
end;

function TPressQueryMetadata.GetItemObjectClassName: string;
begin
  Result := ItemObjectClass.ClassName;
end;

function TPressQueryMetadata.InternalAttributeMetadataClass: TPressAttributeMetadataClass;
begin
  Result := TPressQueryAttributeMetadata;
end;

procedure TPressQueryMetadata.SetItemObjectClass(Value: TPressObjectClass);
var
  VAttributeMetadata: TPressAttributeMetadata;
  I: Integer;
begin
  if FItemObjectClass <> Value then
  begin
    I := AttributeMetadatas.IndexOfName(SPressQueryItemsString);
    if I = -1 then
    begin
      VAttributeMetadata := InternalAttributeMetadataClass.Create(Self);
      VAttributeMetadata.Name := SPressQueryItemsString;
      VAttributeMetadata.AttributeName := TPressQueryItems.AttributeName;
    end else
      VAttributeMetadata := AttributeMetadatas[I];
    VAttributeMetadata.ObjectClass := Value;
    FItemObjectClass := Value;
  end;
end;

procedure TPressQueryMetadata.SetItemObjectClassName(const Value: string);
begin
  if not Assigned(FItemObjectClass) or
   (FItemObjectClass.ClassName <> Value) then
    ItemObjectClass := Model.ClassByName(Value);
end;

{ TPressQueryItems }

procedure TPressQueryItems.InternalUnassignObject(AObject: TPressObject);
begin
  { TODO : Cache }
  AObject.Dispose;
  inherited;
end;

{ TPressQuery }

function TPressQuery.Add(AObject: TPressObject): Integer;
begin
  Result := FQueryItems.Add(AObject);
end;

function TPressQuery.AttributeToSQL(AAttribute: TPressAttribute): string;
begin
  case AAttribute.AttributeBaseType of
    attString:
      Result := AnsiQuotedStr(AAttribute.AsString, PressDefaultPersistence.StrQuote);
    attFloat, attCurrency:
      Result := StringReplace(AAttribute.AsString, ',', '.', [rfReplaceAll]);
    attDate:
      Result := AnsiQuotedStr(FormatDateTime('yyyy-mm-dd', AAttribute.AsDate), PressDefaultPersistence.StrQuote);
    attTime:
      Result := AnsiQuotedStr(FormatDateTime('hh:nn:ss', AAttribute.AsTime), PressDefaultPersistence.StrQuote);
    attDateTime:
      Result := AnsiQuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', AAttribute.AsDateTime), PressDefaultPersistence.StrQuote);
    attReference:
      { TODO : Valid only to IDs stored in string format }
      Result := AnsiQuotedStr(TPressReference(AAttribute).Value.PersistentId, PressDefaultPersistence.StrQuote);
    else
      Result := AAttribute.AsString;
  end;
end;

class function TPressQuery.ClassMetadata: TPressQueryMetadata;
begin
  Result := inherited ClassMetadata as TPressQueryMetadata;
end;

procedure TPressQuery.Clear;
begin
  FQueryItems.Clear;
end;

function TPressQuery.Count: Integer;
begin
  Result := FQueryItems.Count
end;

function TPressQuery.CreateIterator: TPressQueryIterator;
begin
  Result := FQueryItems.CreateIterator;
end;

function TPressQuery.GetMetadata: TPressQueryMetadata;
begin
  Result := inherited Metadata as TPressQueryMetadata;
end;

function TPressQuery.GetObjects(AIndex: Integer): TPressObject;
begin
  Result := FQueryItems[AIndex];
end;

function TPressQuery.GetOrderByClause: string;
begin
  Result := InternalBuildOrderByClause;
end;

function TPressQuery.GetWhereClause: string;
begin
  Result := InternalBuildWhereClause;
end;

procedure TPressQuery.Initialize;
begin
  inherited;
  FMatchEmptyAndNull := True;
end;

function TPressQuery.InternalAttributeAddress(
  const AAttributeName: string): PPressAttribute;
begin
  if SameText(AAttributeName, SPressQueryItemsString) then
    Result := Addr(FQueryItems)
  else
    Result := inherited InternalAttributeAddress(AAttributeName);
end;

function TPressQuery.InternalBuildOrderByClause: string;
begin
  { TODO : Removed PersistentName searching; implement path translation }
  Result := Metadata.OrderFieldName;
end;

function TPressQuery.InternalBuildStatement(
  AAttribute: TPressAttribute): string;
var
  VMetadata: TPressQueryAttributeMetadata;

  { TODO : Find DataName in the BO metadata - use the PersistentName }

  function FormatStringItem(const AMask: string): string;
  begin
    { TODO : Escape quotes into the AAttribute.AsString }
    Result := Format(AMask, [VMetadata.DataName,
     PressDefaultPersistence.StrQuote, AAttribute.AsString]);
  end;

  function FormatValueItem(const AMask: string): string;
  begin
    Result := Format(AMask, [VMetadata.DataName, AttributeToSQL(AAttribute)]);
  end;

  function IsEmptyStatement: string;
  begin
    Result := Format('%s = %s%1:s', [
     VMetadata.DataName, PressDefaultPersistence.StrQuote]);
  end;

  function IsNullStatement: string;
  begin
    Result := Format('%s is Null', [VMetadata.DataName]);
  end;

begin
  Result := '';
  if not (AAttribute.Metadata is TPressQueryAttributeMetadata) then
    Exit;
  VMetadata := TPressQueryAttributeMetadata(AAttribute.Metadata);
  if not AAttribute.IsEmpty or
   (not AAttribute.IsNull and not (AAttribute is TPressString)) then
    case VMetadata.Category of
      acMatch:
        Result := FormatValueItem('%s = %s');
      acStarting:
        Result := FormatStringItem('%s LIKE %s%%%s%1:s');
      acFinishing:
        Result := FormatStringItem('%s LIKE %s%s%%%1:s');
      acPartial:
        Result := FormatStringItem('%s LIKE %s%%%s%%%1:s');
      acGreaterThan:
        Result := FormatValueItem('%s > %s');
      acGreaterEqualThan:
        Result := FormatValueItem('%s >= %s');
      acLesserThan:
        Result := FormatValueItem('%s < %s');
      acLesserEqualThan:
        Result := FormatValueItem('%s <= %s');
    end
  else if VMetadata.IncludeIfEmpty then
    if AAttribute is TPressString then
      if MatchEmptyAndNull then
        Result := Format('(%s) or (%s)', [IsNullStatement, IsEmptyStatement])
      else if AAttribute.IsNull then
        Result := IsNullStatement
      else
        Result := IsEmptyStatement
    else
      Result := IsNullStatement;
end;

function TPressQuery.InternalBuildWhereClause: string;

  procedure ConcatStatements(
    const AStatementStr, AConnectorToken: string; var ABuffer: string);
  begin
    if AStatementStr <> '' then
      if ABuffer = '' then
        ABuffer := '(' + AStatementStr + ')'
      else
        ABuffer := ABuffer + ' ' + AConnectorToken + ' (' + AStatementStr + ')';
  end;

begin
  Result := '';
  with CreateAttributeIterator do
  try
    First;
    Next;  // skip Id and QueryItems attributes
    while NextItem do
      { TODO : Improve connector token storage }
      ConcatStatements(InternalBuildStatement(CurrentItem), 'and', Result);
  finally
    Free;
  end;
end;

procedure TPressQuery.InternalUpdateReferenceList;
begin
  FQueryItems.DisableChanges;
  try
    FQueryItems.AssignProxyList(PressDefaultPersistence.RetrieveProxyList(Self));
  finally
    FQueryItems.EnableChanges;
  end;
end;

class function TPressQuery.ObjectMetadataClass: TPressObjectMetadataClass;
begin
  Result := TPressQueryMetadata;
end;

function TPressQuery.Remove(AObject: TPressObject): Integer;
begin
  Result := FQueryItems.Remove(AObject);
end;

function TPressQuery.RemoveReference(AProxy: TPressProxy): Integer;
begin
  Result := FQueryItems.RemoveReference(AProxy);
end;

procedure TPressQuery.UpdateReferenceList;
begin
  InternalUpdateReferenceList;
end;

procedure RegisterClasses;
begin
  TPressQuery.RegisterClass;
end;

procedure RegisterAttributes;
begin
  TPressQueryItems.RegisterAttribute;
end;

initialization
  RegisterClasses;
  RegisterAttributes;

end.
