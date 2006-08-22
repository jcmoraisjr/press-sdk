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
  public
    constructor Create(AOwner: TPressQueryMetadata);
  published
    property Category: TPressQueryAttributeCategory read FCategory write FCategory;
  end;

  TPressQueryMetadata = class(TPressObjectMetadata)
  private
    FIncludeSubClasses: Boolean;
    FItemObjectClassName: string;
    FOrderFieldName: string;
  published
    property IncludeSubClasses: Boolean read FIncludeSubClasses write FIncludeSubClasses default True;
    property ItemObjectClassName: string read FItemObjectClassName write FItemObjectClassName;
    property OrderFieldName: string read FOrderFieldName write FOrderFieldName;
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
  public
    function Add(AObject: TPressObject): Integer;
    procedure Clear;
    function Count: Integer;
    class function ClassMetadata: TPressQueryMetadata;
    function CreateIterator: TPressQueryIterator;
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
  PressPersistence;

{ TPressQueryAttributeMetadata }

constructor TPressQueryAttributeMetadata.Create(
  AOwner: TPressQueryMetadata);
begin
  inherited Create(AOwner);
  FCategory := acMatch;
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
      Result := AnsiQuotedStr(AAttribute.AsString, PressPersistenceBroker.StrQuote);
    attFloat, attCurrency:
      Result := StringReplace(AAttribute.AsString, ',', '.', [rfReplaceAll]);
    attDate:
      Result := AnsiQuotedStr(FormatDateTime('yyyy-mm-dd', AAttribute.AsDate), PressPersistenceBroker.StrQuote);
    attTime:
      Result := AnsiQuotedStr(FormatDateTime('hh:nn:ss', AAttribute.AsTime), PressPersistenceBroker.StrQuote);
    attDateTime:
      Result := AnsiQuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', AAttribute.AsDateTime), PressPersistenceBroker.StrQuote);
    attReference:
      { TODO : Valid only to IDs stored in string format }
      Result := AnsiQuotedStr(TPressReference(AAttribute).Value.PersistentId, PressPersistenceBroker.StrQuote);
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
     PressPersistenceBroker.StrQuote, AAttribute.AsString], AResult);
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
      if not CurrentItem.IsEmpty and
       (CurrentItem.Metadata is TPressQueryAttributeMetadata) then
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

function TPressQuery.Remove(AObject: TPressObject): Integer;
begin
  Result := _QueryItems.Remove(AObject);
end;

procedure TPressQuery.UpdateReferenceList;
begin
  _QueryItems.DisableChanges;
  try
    _QueryItems.AssignProxyList(PressPersistenceBroker.RetrieveProxyList(Self));
  finally
    _QueryItems.EnableChanges;
  end;
end;

procedure RegisterClasses;
begin
  TPressQuery.RegisterClass;
end;

initialization
  RegisterClasses;

end.
