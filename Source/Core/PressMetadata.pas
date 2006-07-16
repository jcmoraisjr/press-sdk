(*
  PressObjects, Metadata parser
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

unit PressMetadata;

interface

{$I Press.inc}

uses
  PressClasses,
  PressSubject;
  
type
  TPressCodeReader = class(TPressTextReader)
  end;

  TPressCodeObjectList = class;

  TPressCodeObjectClass = class of TPressCodeObject;

  { TPressCodeObject }

  TPressCodeObject = class(TObject)
  private
    FCodeObjects: TPressCodeObjectList;
    FOwner: TPressCodeObject;
    function GetCodeObjects: TPressCodeObjectList;
  protected
    function FindRule(Reader: TPressCodeReader; AClasses: array of TPressCodeObjectClass): TPressCodeObjectClass;
    class function InternalApply(Reader: TPressCodeReader): Boolean; virtual;
    procedure InternalRead(Reader: TPressCodeReader); virtual;
    property CodeObjects: TPressCodeObjectList read GetCodeObjects;
  public
    constructor Create(AOwner: TPressCodeObject);
    destructor Destroy; override;
    class function Apply(Reader: TPressCodeReader): Boolean;
    procedure Read(Reader: TPressCodeReader);
    property Owner: TPressCodeObject read FOwner;
  end;

  TPressCodeObjectIterator = class;

  TPressCodeObjectList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressCodeObject;
    procedure SetItems(AIndex: Integer; Value: TPressCodeObject);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressCodeObject): Integer;
    function CreateIterator: TPressCodeObjectIterator;
    function IndexOf(AObject: TPressCodeObject): Integer;
    procedure Insert(Index: Integer; AObject: TPressCodeObject);
    function Remove(AObject: TPressCodeObject): Integer;
    property Items[AIndex: Integer]: TPressCodeObject read GetItems write SetItems; default;
  end;

  TPressCodeObjectIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressCodeObject;
  public
    property CurrentItem: TPressCodeObject read GetCurrentItem;
  end;

  TPressCodeMetadata = class(TPressCodeObject)
  private
    FMetadata: TPressObjectMetadata;
  protected
    procedure InternalRead(Reader: TPressCodeReader); override;
  public
    property Metadata: TPressObjectMetadata read FMetadata;
  end;

  TPressCodeAttributeMetadata = class(TPressCodeObject)
  private
    FMetadata: TPressAttributeMetadata;
    function GetOwner: TPressCodeMetadata;
  protected
    procedure InternalRead(Reader: TPressCodeReader); override;
  public
    property Metadata: TPressAttributeMetadata read FMetadata;
    property Owner: TPressCodeMetadata read GetOwner;
  end;

  TPressCodeAttributeTypeMetadata = class(TPressCodeObject)
  private
    function GetOwner: TPressCodeAttributeMetadata;
  public
    property Owner: TPressCodeAttributeMetadata read GetOwner;
  end;

  TPressCodeStructureTypeMetadata = class(TPressCodeAttributeTypeMetadata)
  protected
    class function InternalApply(Reader: TPressCodeReader): Boolean; override;
    class function IsStructureType(const AAttributeName: string): Boolean; virtual;
    procedure InternalRead(Reader: TPressCodeReader); override;
  end;

  TPressCodeSizeableTypeMetadata = class(TPressCodeAttributeTypeMetadata)
  protected
    class function InternalApply(Reader: TPressCodeReader): Boolean; override;
    class function IsSizeableType(const AAttributeName: string): Boolean; virtual;
    procedure InternalRead(Reader: TPressCodeReader); override;
  end;

  TPressCodeEnumTypeMetadata = class(TPressCodeAttributeTypeMetadata)
  protected
    class function InternalApply(Reader: TPressCodeReader): Boolean; override;
    class function IsEnumType(const AAttributeName: string): Boolean; virtual;
    procedure InternalRead(Reader: TPressCodeReader); override;
  end;

  TPressCodeOtherTypeMetadata = class(TPressCodeAttributeTypeMetadata)
  protected
    class function InternalApply(Reader: TPressCodeReader): Boolean; override;
    class function IsOtherType(const AAttributeName: string): Boolean; virtual;
    procedure InternalRead(Reader: TPressCodeReader); override;
  end;

implementation

uses
  SysUtils,
  PressConsts,
  PressQuery;

const
  { TODO : Organize }
  CClassName = 'Nome de classe';
  CObjectPropertyName = 'Propriedade de objeto';
  CQueryPropertyName = 'Propriedade da query';
  CAttributePropertyName = 'Propriedade de atributo';
  CQueryAttributePropertyName = 'Propriedade de atributo da query';
  CAttributeTypeName = 'Nome de atributo';
  CCategoryQueryAttributeName = 'Nome de categoria de atributo da query';

  CPersistentClassObjectProperty = 'PersistentName';
  CAllSubClassesQueryProperty = 'Any';
  COrderFieldNameQueryProperty = 'Order';
  CNameAttributeProperty = 'Name';
  CPersistentNameAttributeProperty = 'PersistentName';
  CEditMaskAttributeProperty = 'EditMask';
  CSizeAttributeProperty = 'Size';
  CCategoryQueryAttributeProperty = 'Category';
  CMatchCategoryName = 'Match';
  CStartingCategoryName = 'Starting';
  CFinishingCategoryName = 'Finishing';
  CPartialCategoryName = 'Partial';
  CGreaterThanCategoryName = 'Greater';
  CGreaterEqualThanCategoryName = 'GreaterEqual';
  CLesserThanCategoryName = 'Lesser';
  CLesserEqualThanCategoryName = 'LesserEqual';

{ TPressCodeObject }

class function TPressCodeObject.Apply(Reader: TPressCodeReader): Boolean;
var
  VPosition: TPressTextPos;
begin
  VPosition := Reader.Position;
  try
    Result := InternalApply(Reader);
  finally
    Reader.Position := VPosition;
  end;
end;

constructor TPressCodeObject.Create(AOwner: TPressCodeObject);
begin
  inherited Create;
  FOwner := AOwner;
  if Assigned(FOwner) then
    FOwner.CodeObjects.Add(Self);
end;

destructor TPressCodeObject.Destroy;
begin
  FCodeObjects.Free;
  if Assigned(FOwner) then
    FOwner.CodeObjects.Extract(Self);
  inherited;
end;

function TPressCodeObject.FindRule(Reader: TPressCodeReader;
  AClasses: array of TPressCodeObjectClass): TPressCodeObjectClass;
var
  I: Integer;
begin
  for I := Low(AClasses) to High(AClasses) do
  begin
    Result := AClasses[I];
    if Result.Apply(Reader) then
      Exit;
  end;
  Result := nil;
end;

function TPressCodeObject.GetCodeObjects: TPressCodeObjectList;
begin
  if not Assigned(FCodeObjects) then
    FCodeObjects := TPressCodeObjectList.Create(True);
  Result := FCodeObjects;
end;

class function TPressCodeObject.InternalApply(
  Reader: TPressCodeReader): Boolean;
begin
  Result := False;
end;

procedure TPressCodeObject.InternalRead(Reader: TPressCodeReader);
begin
end;

procedure TPressCodeObject.Read(Reader: TPressCodeReader);
begin
  InternalRead(Reader);
end;

{ TPressCodeObjectList }

function TPressCodeObjectList.Add(AObject: TPressCodeObject): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressCodeObjectList.CreateIterator: TPressCodeObjectIterator;
begin
  Result := TPressCodeObjectIterator.Create(Self);
end;

function TPressCodeObjectList.GetItems(AIndex: Integer): TPressCodeObject;
begin
  Result := inherited Items[AIndex] as TPressCodeObject;
end;

function TPressCodeObjectList.IndexOf(AObject: TPressCodeObject): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressCodeObjectList.Insert(
  Index: Integer; AObject: TPressCodeObject);
begin
  inherited Insert(Index, AObject);
end;

function TPressCodeObjectList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressCodeObjectList.Remove(AObject: TPressCodeObject): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressCodeObjectList.SetItems(
  AIndex: Integer; Value: TPressCodeObject);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressCodeObjectIterator }

function TPressCodeObjectIterator.GetCurrentItem: TPressCodeObject;
begin
  Result := inherited CurrentItem as TPressCodeObject;
end;

{ TPressCodeMetadata }

procedure TPressCodeMetadata.InternalRead(Reader: TPressCodeReader);
var
  Token: string;
  VObjClass: TPressObjectClass;
begin
  inherited;
  Token := Reader.ReadIdentifier;
  VObjClass := PressFindObjectClass(Token);
  if not Assigned(VObjClass) then
    Reader.ErrorExpected(CClassName, Token);

  if VObjClass.InheritsFrom(TPressQuery) then
    FMetadata := TPressQueryMetadata.Create(VObjClass)
  else
    FMetadata := TPressObjectMetadata.Create(VObjClass);
  { TODO : Improve this approach }
  if VObjClass.ClassParent = TPressQuery then
  begin
    Reader.ReadMatch('(');
    Token := Reader.ReadIdentifier;
    TPressQueryMetadata(FMetadata).ItemObjectClassName := Token;
    Reader.ReadMatch(')');
    with TPressAttributeMetadata.Create(FMetadata) do
    begin
      Name := SPressQueryItemsString;
      AttributeName := TPressReferences.AttributeName;
      ObjectClassName := Token;
    end;
  end;

  Token := Reader.ReadToken;
  while Token <> ';' do
  begin
    Reader.ReadMatch(':');
    if SameText(CPersistentClassObjectProperty, Token) then
      FMetadata.PersistentName := Reader.ReadIdentifier
    else if FMetadata is TPressQueryMetadata then
    { TODO : Improve }
    begin
      if SameText(COrderFieldNameQueryProperty, Token) then
        TPressQueryMetadata(FMetadata).OrderFieldName := Reader.ReadIdentifier
      else if SameText(CAllSubClassesQueryProperty, Token) then
        TPressQueryMetadata(FMetadata).IncludeSubClasses := True
      else
        Reader.ErrorExpected(CQueryPropertyName, Token);
    end else
      Reader.ErrorExpected(CObjectPropertyName, Token);
    Token := Reader.ReadToken;
  end;

  TPressCodeAttributeMetadata.Create(Self).Read(Reader);
end;

{ TPressCodeAttributeMetadata }

function TPressCodeAttributeMetadata.GetOwner: TPressCodeMetadata;
begin
  Result := inherited Owner as TPressCodeMetadata;
end;

procedure TPressCodeAttributeMetadata.InternalRead(Reader: TPressCodeReader);
var
  Token: string;
  VRuleClass: TPressCodeObjectClass;
begin
  inherited;
  Token := Reader.ReadToken;
  while Token <> ';' do
  begin
    { TODO : Improve }
    if Owner.Metadata is TPressQueryMetadata then
      FMetadata := TPressQueryAttributeMetadata.Create(TPressQueryMetadata(Owner.Metadata))
    else
      FMetadata := TPressAttributeMetadata.Create(Owner.Metadata);
    FMetadata.Name := Token;
    Reader.ReadMatch(':');

    VRuleClass := FindRule(Reader, [TPressCodeStructureTypeMetadata,
     TPressCodeSizeableTypeMetadata, TPressCodeEnumTypeMetadata,
     TPressCodeOtherTypeMetadata]);
    if Assigned(VRuleClass) then
      VRuleClass.Create(Self).Read(Reader)
    else
      Reader.ErrorExpected(CAttributeTypeName, Reader.ReadToken);

    Token := Reader.ReadToken;
    while Token <> ';' do
    begin
      Reader.ReadMatch(':');
      if SameText(CEditMaskAttributeProperty, Token) then
        FMetadata.EditMask := Reader.ReadToken
      else if SameText(CNameAttributeProperty, Token) then
        FMetadata.Name := Reader.ReadToken
      else if SameText(CPersistentNameAttributeProperty, Token) then
        FMetadata.PersistentName := Reader.ReadToken
      else if SameText(CSizeAttributeProperty, Token) then
        FMetadata.Size := Reader.ReadInteger
      else if FMetadata is TPressQueryAttributeMetadata then
      begin
        if SameText(CCategoryQueryAttributeProperty, Token) then
        begin
          Token := Reader.ReadToken;
          if SameText(CMatchCategoryName, Token) then
            TPressQueryAttributeMetadata(FMetadata).Category := acMatch
          else if SameText(CStartingCategoryName, Token) then
            TPressQueryAttributeMetadata(FMetadata).Category := acStarting
          else if SameText(CFinishingCategoryName, Token) then
            TPressQueryAttributeMetadata(FMetadata).Category := acFinishing
          else if SameText(CPartialCategoryName, Token) then
            TPressQueryAttributeMetadata(FMetadata).Category := acPartial
          else if SameText(CGreaterThanCategoryName, Token) then
            TPressQueryAttributeMetadata(FMetadata).Category := acGreaterThan
          else if SameText(CGreaterEqualThanCategoryName, Token) then
            TPressQueryAttributeMetadata(FMetadata).Category := acGreaterEqualThan
          else if SameText(CLesserThanCategoryName, Token) then
            TPressQueryAttributeMetadata(FMetadata).Category := acLesserThan
          else if SameText(CLesserEqualThanCategoryName, Token) then
            TPressQueryAttributeMetadata(FMetadata).Category := acLesserEqualThan
          else
            Reader.ErrorExpected(CCategoryQueryAttributeName, Token);
        end else
          Reader.ErrorExpected(CQueryAttributePropertyName, Token);
      end else
        Reader.ErrorExpected(CAttributePropertyName, Token);
      Token := Reader.ReadToken;
    end;

    if not Reader.Eof then
      Token := Reader.ReadToken;
  end;
end;

{ TPressCodeAttributeTypeMetadata }

function TPressCodeAttributeTypeMetadata.GetOwner: TPressCodeAttributeMetadata;
begin
  Result := inherited Owner as TPressCodeAttributeMetadata;
end;

{ TPressCodeStructureTypeMetadata }

class function TPressCodeStructureTypeMetadata.InternalApply(
  Reader: TPressCodeReader): Boolean;
begin
  Result := IsStructureType(Reader.ReadToken);
end;

procedure TPressCodeStructureTypeMetadata.InternalRead(
  Reader: TPressCodeReader);
begin
  inherited;
  Owner.Metadata.AttributeName := Reader.ReadToken;
  Reader.ReadMatch('(');
  Owner.Metadata.ObjectClassName := Reader.ReadToken;
  Reader.ReadMatch(')');
end;

class function TPressCodeStructureTypeMetadata.IsStructureType(
  const AAttributeName: string): Boolean;
const
  CStructureTypeCount = 4;
  CStructureTypes: array[0..CStructureTypeCount-1] of string =
   ('Part', 'Reference', 'Parts', 'References');
var
  I: Integer;
begin
  for I := 0 to Pred(CStructureTypeCount) do
  begin
    Result := SameText(AAttributeName, CStructureTypes[I]);
    if Result then
      Exit;
  end;
end;

{ TPressCodeSizeableTypeMetadata }

class function TPressCodeSizeableTypeMetadata.InternalApply(
  Reader: TPressCodeReader): Boolean;
begin
  Result := IsSizeableType(Reader.ReadToken);
end;

procedure TPressCodeSizeableTypeMetadata.InternalRead(
  Reader: TPressCodeReader);
var
  Token: string;
begin
  inherited;
  Owner.Metadata.AttributeName := Reader.ReadToken;
  Token := Reader.ReadToken;
  if Token = '(' then
  begin
    Owner.Metadata.Size := Reader.ReadInteger;
    Reader.ReadMatch(')');
  end else
    Reader.UnreadToken;
end;

class function TPressCodeSizeableTypeMetadata.IsSizeableType(
  const AAttributeName: string): Boolean;
const
  CSizeableTypeCount = 1;
  CSizeableTypes: array[0..CSizeableTypeCount-1] of string =
   ('String');
var
  I: Integer;
begin
  for I := 0 to Pred(CSizeableTypeCount) do
  begin
    Result := SameText(AAttributeName, CSizeableTypes[I]);
    if Result then
      Exit;
  end;
end;

{ TPressCodeEnumTypeMetadata }

class function TPressCodeEnumTypeMetadata.InternalApply(
  Reader: TPressCodeReader): Boolean;
begin
  Result := IsEnumType(Reader.ReadToken);
end;

procedure TPressCodeEnumTypeMetadata.InternalRead(
  Reader: TPressCodeReader);
var
  Token: string;
begin
  inherited;
  Owner.Metadata.AttributeName := Reader.ReadToken;
  Token := Reader.ReadToken;
  if Token = '(' then
  begin
    Owner.Metadata.EnumMetadata :=
     PressEnumMetadataByName(Reader.ReadIdentifier);
    Reader.ReadMatch(')');
  end else
    Reader.UnreadToken;
end;

class function TPressCodeEnumTypeMetadata.IsEnumType(
  const AAttributeName: string): Boolean;
begin
  Result := SameText(AAttributeName, 'Enum');
end;

{ TPressCodeOtherTypeMetadata }

class function TPressCodeOtherTypeMetadata.InternalApply(
  Reader: TPressCodeReader): Boolean;
begin
  Result := IsOtherType(Reader.ReadToken);
end;

procedure TPressCodeOtherTypeMetadata.InternalRead(
  Reader: TPressCodeReader);
begin
  inherited;
  Owner.Metadata.AttributeName := Reader.ReadToken;
end;

class function TPressCodeOtherTypeMetadata.IsOtherType(
  const AAttributeName: string): Boolean;
begin
  Result :=
   not TPressCodeStructureTypeMetadata.IsStructureType(AAttributeName) and
   not TPressCodeSizeableTypeMetadata.IsSizeableType(AAttributeName) and
   not TPressCodeEnumTypeMetadata.IsEnumType(AAttributeName) and
   (PressFindAttributeClass(AAttributeName) <> nil);
end;

end.
