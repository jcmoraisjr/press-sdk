(*
  PressObjects, Query Classes
  Copyright (C) 2006 Laserpress Ltda.

  http://www.pressobjects.org

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
*)

unit PressQuery;

{$I Press.inc}

interface

uses
  PressSubject;

type
  TPressQueryAttributeCategory = (acMatch,
   acStarting, acFinishing, acPartial,
   acGreaterThan, acGreaterEqualThan,
   acLesserThan, acLesserEqualThan);

  TPressQueryMetadata = class;

  TPressQueryAttributeMetadata = class(TPressAttributeMetadata)
  private
    FCategory: TPressQueryAttributeCategory;
    FIncludeIfEmpty: Boolean;
  public
    constructor Create(AOwner: TPressObjectMetadata); override;
  published
    property Category: TPressQueryAttributeCategory read FCategory write FCategory default acMatch;
    property IncludeIfEmpty: Boolean read FIncludeIfEmpty write FIncludeIfEmpty default False;
  end;

  TPressQueryMetadata = class(TPressObjectMetadata)
  private
    FIncludeSubClasses: Boolean;
    FItemObjectClass: TPressObjectClass;
    FOrderFieldName: string;
    function GetItemObjectClassName: string;
    procedure SetItemObjectClass(Value: TPressObjectClass);
    procedure SetItemObjectClassName(const Value: string);
  protected
    function InternalAttributeMetadataClass: TPressAttributeMetadataClass; override;
  public
    property IncludeSubClasses: Boolean read FIncludeSubClasses;
    property ItemObjectClass: TPressObjectClass read FItemObjectClass write SetItemObjectClass;
    property ItemObjectClassName: string read GetItemObjectClassName write SetItemObjectClassName;
    property OrderFieldName: string read FOrderFieldName;
  published
    property Any: Boolean read FIncludeSubClasses write FIncludeSubClasses default False;
    property Order: string read FOrderFieldName write FOrderFieldName;
  end;

  TPressQueryClass = class of TPressQuery;

  TPressQueryIterator = TPressProxyIterator;

  TPressQuery = class(TPressObject)
    _QueryItems: TPressReferences;
  private
    function AttributeToSQL(AAttribute: TPressAttribute): string;
    function GetMetadata: TPressQueryMetadata;
    function GetObjects(AIndex: Integer): TPressObject;
    function GetOrderByClause: string;
    function GetWhereClause: string;
  protected
    function InternalBuildOrderByClause: string; virtual;
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
    procedure UpdateReferenceList;
    property Metadata: TPressQueryMetadata read GetMetadata;
    property Objects[AIndex: Integer]: TPressObject read GetObjects; default;
    property OrderByClause: string read GetOrderByClause;
    property WhereClause: string read GetWhereClause;
  end;

implementation

uses
  SysUtils,
  PressConsts,
  PressPersistence;

{ TPressQueryAttributeMetadata }

constructor TPressQueryAttributeMetadata.Create(
  AOwner: TPressObjectMetadata);
begin
  inherited Create(AOwner);
  FCategory := acMatch;
end;

{ TPressQueryMetadata }

function TPressQueryMetadata.GetItemObjectClassName: string;
begin
  if Assigned(FItemObjectClass) then
    Result := FItemObjectClass.ClassName
  else
    Result := '';
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
      VAttributeMetadata.AttributeName := TPressReferences.AttributeName;
    end else
      VAttributeMetadata := AttributeMetadatas[I];
    VAttributeMetadata.ObjectClass := Value;
    FItemObjectClass := Value;
  end;
end;

procedure TPressQueryMetadata.SetItemObjectClassName(const Value: string);
begin
  if ItemObjectClassName <> Value then
    ItemObjectClass := PressObjectClassByName(Value);
end;

{ TPressQuery }

function TPressQuery.Add(AObject: TPressObject): Integer;
begin
  Result := _QueryItems.Add(AObject);
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
  _QueryItems.Clear;
end;

function TPressQuery.Count: Integer;
begin
  Result := _QueryItems.Count
end;

function TPressQuery.CreateIterator: TPressQueryIterator;
begin
  Result := _QueryItems.CreateIterator;
end;

function TPressQuery.GetMetadata: TPressQueryMetadata;
begin
  Result := inherited Metadata as TPressQueryMetadata;
end;

function TPressQuery.GetObjects(AIndex: Integer): TPressObject;
begin
  Result := _QueryItems[AIndex];
end;

function TPressQuery.GetOrderByClause: string;
begin
  Result := InternalBuildOrderByClause;
end;

function TPressQuery.GetWhereClause: string;
begin
  Result := InternalBuildWhereClause;
end;

function TPressQuery.InternalBuildOrderByClause: string;
var
  VAttribute: TPressAttribute;
begin
  Result := Metadata.OrderFieldName;
  VAttribute := FindAttribute(Result);
  if Assigned(VAttribute) then
    Result := VAttribute.PersistentName;
end;

function TPressQuery.InternalBuildWhereClause: string;

  procedure ReadItem(
    const AFilterMask: string; const AParams: array of const;
    var AResult: string);
  begin
    if AResult <> '' then
      AResult := AResult + ' AND ';
    AResult := AResult + Format(AFilterMask, AParams);
  end;

  procedure ReadStringItem(
    const AFilterMask: string; AAttribute: TPressAttribute;
    var AResult: string);
  begin
    { TODO : Escape quotes into AsString, via AnsiQuotedStr }
    ReadItem(AFilterMask, [AAttribute.PersistentName,
     PressDefaultPersistence.StrQuote, AAttribute.AsString], AResult);
  end;

  procedure ReadValueItem(
    const AFilterMask: string; AAttribute: TPressAttribute;
    var AResult: string);
  begin
    ReadItem(AFilterMask,
     [AAttribute.PersistentName, AttributeToSQL(AAttribute)], AResult);
  end;

begin
  Result := '';
  with CreateAttributeIterator do
  try
    First;
    Next;  // skip Id and QueryItems attributes
    while NextItem do
      if (CurrentItem.Metadata is TPressQueryAttributeMetadata) and
       (TPressQueryAttributeMetadata(CurrentItem.Metadata).IncludeIfEmpty or
       not CurrentItem.IsEmpty) then
        case TPressQueryAttributeMetadata(CurrentItem.Metadata).Category of
          acMatch:
            ReadValueItem('%s = %s', CurrentItem, Result);
          acStarting:
            ReadStringItem('%s LIKE %s%%%s%1:s', CurrentItem, Result);
          acFinishing:
            ReadStringItem('%s LIKE %s%s%%%1:s', CurrentItem, Result);
          acPartial:
            ReadStringItem('%s LIKE %s%%%s%%%1:s', CurrentItem, Result);
          acGreaterThan:
            ReadValueItem('%s > %s', CurrentItem, Result);
          acGreaterEqualThan:
            ReadValueItem('%s >= %s', CurrentItem, Result);
          acLesserThan:
            ReadValueItem('%s < %s', CurrentItem, Result);
          acLesserEqualThan:
            ReadValueItem('%s <= %s', CurrentItem, Result);
        end;
  finally
    Free;
  end;
end;

procedure TPressQuery.InternalUpdateReferenceList;
begin
  _QueryItems.DisableChanges;
  try
    _QueryItems.AssignProxyList(PressDefaultPersistence.RetrieveProxyList(Self));
  finally
    _QueryItems.EnableChanges;
  end;
end;

class function TPressQuery.ObjectMetadataClass: TPressObjectMetadataClass;
begin
  Result := TPressQueryMetadata;
end;

function TPressQuery.Remove(AObject: TPressObject): Integer;
begin
  Result := _QueryItems.Remove(AObject);
end;

procedure TPressQuery.UpdateReferenceList;
begin
  InternalUpdateReferenceList;
end;

procedure RegisterClasses;
begin
  TPressQuery.RegisterClass;
end;

initialization
  RegisterClasses;

end.
