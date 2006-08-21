(*
  PressObjects, Persistence Broker Class
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

unit PressPersistence;

interface

{$I Press.inc}

uses
  PressSubject,
  PressQuery;

type
  TPressOIDGeneratorsClass = class of TPressOIDGenerators;

  TPressOIDGenerators = class(TPressQuery)
  protected
    function InternalGenerateOID(AObjectClass: TPressObjectClass): string; virtual; abstract;
    procedure InternalReleaseOID(AObjectClass: TPressObjectClass; const AOID: string); virtual;
  public
    function GenerateOID(AObjectClass: TPressObjectClass): string;
    procedure ReleaseOID(AObjectClass: TPressObjectClass; const AOID: string);
  end;

  TPressSimpleOIDGenerators = class(TPressOIDGenerators)
  protected
    function InternalGenerateOID(AObjectClass: TPressObjectClass): string; override;
  end;

  TPressPersistenceBrokerClass = class of TPressPersistenceBroker;

  TPressPersistenceBroker = class(TObject)
  private
    function GetIsDefault: Boolean;
    procedure SetIsDefault(Value: Boolean);
  protected
    function GetIdentifierQuotes: string; virtual;
    function GetStrQuote: Char; virtual;
    procedure InitPersistenceBroker; virtual;
    procedure InternalDispose(AObject: TPressObject); virtual; abstract;
    procedure InternalConnect; virtual;
    function InternalOIDGeneratorsClass: TPressOIDGeneratorsClass; virtual;
    function InternalRetrieve(const AClass, AId: string): TPressObject; virtual; abstract;
    function InternalRetrieveProxyList(AQuery: TPressQuery): TPressProxyList; virtual; abstract;
    procedure InternalStore(AObject: TPressObject); virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Connect;
    procedure Dispose(const AClass, AId: string); overload;
    procedure Dispose(AObject: TPressObject); overload;
    procedure Dispose(AProxy: TPressProxy); overload;
    class procedure RegisterPersistence;
    function Retrieve(const AClass, AId: string): TPressObject;
    function RetrieveProxyList(AQuery: TPressQuery): TPressProxyList;
    procedure Store(AObject: TPressObject);
    property IdentifierQuotes: string read GetIdentifierQuotes;
    property IsDefault: Boolean read GetIsDefault write SetIsDefault;
    property StrQuote: Char read GetStrQuote;
  end;

function PressPersistenceBroker: TPressPersistenceBroker;

implementation

uses
  SysUtils,
  Contnrs,
  ActiveX,
  ComObj,
  PressClasses,
  PressConsts
  {$IFDEF PressLog},PressLog{$ENDIF};

var
  _PressRegisteredPersistenceBrokers: TClassList;
  _PressDefaultPersistenceBroker: TPressPersistenceBroker;

function PressRegisteredPersistenceBrokers: TClassList;
begin
  if not Assigned(_PressRegisteredPersistenceBrokers) then
  begin
    _PressRegisteredPersistenceBrokers := TClassList.Create;
    PressRegisterSingleObject(_PressRegisteredPersistenceBrokers);
  end;
  Result := _PressRegisteredPersistenceBrokers;
end;

{ Global routines }

function PressPersistenceBroker: TPressPersistenceBroker;
begin
  if not Assigned(_PressDefaultPersistenceBroker) then
  begin
    if not Assigned(_PressRegisteredPersistenceBrokers) or
     (_PressRegisteredPersistenceBrokers.Count < 1) then
      raise EPressError.Create(SUnassignedPersistenceBroker);
    PressRegisterSingleObject(TPressPersistenceBrokerClass(_PressRegisteredPersistenceBrokers[_PressRegisteredPersistenceBrokers.Count-1]).Create);
  end;
  Result := _PressDefaultPersistenceBroker;
end;

{ TPressOIDGenerators }

function TPressOIDGenerators.GenerateOID(
  AObjectClass: TPressObjectClass): string;
begin
  Result := InternalGenerateOID(AObjectClass);
end;

procedure TPressOIDGenerators.InternalReleaseOID(
  AObjectClass: TPressObjectClass; const AOID: string);
begin
end;

procedure TPressOIDGenerators.ReleaseOID(
  AObjectClass: TPressObjectClass; const AOID: string);
begin
  InternalReleaseOID(AObjectClass, AOID);
end;

{ TPressSimpleOIDGenerators }

function TPressSimpleOIDGenerators.InternalGenerateOID(
  AObjectClass: TPressObjectClass): string;
var
  VId: array[0..15] of Byte;
  I: Integer;
begin
  OleCheck(CoCreateGUID(TGUID(VId)));
  SetLength(Result, 32);
  for I := 0 to 15 do
    Move(IntToHex(VId[I], 2)[1], Result[2*I+1], 2);
end;

{ TPressPersistenceBroker }

procedure TPressPersistenceBroker.Connect;
begin
  InternalConnect;
end;

constructor TPressPersistenceBroker.Create;
begin
  inherited Create;
  if not Assigned(_PressDefaultPersistenceBroker) then
    IsDefault := True;
  InitPersistenceBroker;
end;

destructor TPressPersistenceBroker.Destroy;
begin
  IsDefault := False;
  inherited;
end;

procedure TPressPersistenceBroker.Dispose(AProxy: TPressProxy);
begin
  Dispose(AProxy.Instance);
end;

procedure TPressPersistenceBroker.Dispose(AObject: TPressObject);
begin
  if Assigned(AObject) then
  begin
    AObject.DisableChanges;
    try
      {$IFDEF PressLogOPF}PressLogMsg(Self, 'Disposing', [AObject]);{$ENDIF}
      InternalDispose(AObject);
    finally
      AObject.EnableChanges;
    end;
  end;
end;

procedure TPressPersistenceBroker.Dispose(const AClass, AId: string);
var
  VObject: TPressObject;
begin
  VObject := Retrieve(AClass, AId);
  try
    Dispose(VObject);
  finally
    VObject.Free;
  end;
end;

function TPressPersistenceBroker.GetIdentifierQuotes: string;
begin
  Result := '"';
end;

function TPressPersistenceBroker.GetIsDefault: Boolean;
begin
  Result := _PressDefaultPersistenceBroker = Self;
end;

function TPressPersistenceBroker.GetStrQuote: Char;
begin
  Result := '''';
end;

procedure TPressPersistenceBroker.InitPersistenceBroker;
begin
end;

procedure TPressPersistenceBroker.InternalConnect;
begin
end;

function TPressPersistenceBroker.InternalOIDGeneratorsClass: TPressOIDGeneratorsClass;
begin
  Result := TPressSimpleOIDGenerators;
end;

class procedure TPressPersistenceBroker.RegisterPersistence;
begin
  PressRegisteredPersistenceBrokers.Add(Self);
end;

function TPressPersistenceBroker.Retrieve(const AClass, AId: string): TPressObject;
begin
  Result := PressFindObject(AClass, AId);
  if Assigned(Result) then
    Result.AddRef
  else
  begin
    {$IFDEF PressLogOPF}PressLogMsg(Self,
     Format('Retrieving %s(%s)', [AClass, AId]));{$ENDIF}
    { TODO : Ensure the class type of the retrieved object }
    Result := InternalRetrieve(AClass, AId);
  end;
end;

function TPressPersistenceBroker.RetrieveProxyList(
  AQuery: TPressQuery): TPressProxyList;
begin
  Result := InternalRetrieveProxyList(AQuery);
end;

procedure TPressPersistenceBroker.SetIsDefault(Value: Boolean);
begin
  if Value xor IsDefault then
    if Value then
      _PressDefaultPersistenceBroker := Self
    else
      _PressDefaultPersistenceBroker := nil;
end;

procedure TPressPersistenceBroker.Store(AObject: TPressObject);
begin
  if Assigned(AObject) and not AObject.IsOwned and not AObject.IsUpdated then
  begin
    AObject.DisableChanges;
    try
      {$IFDEF PressLogOPF}PressLogMsg(Self, 'Storing', [AObject]);{$ENDIF}
      InternalStore(AObject);
      AObject.Unchanged;
    finally
      AObject.EnableChanges;
    end;
  end;
end;

end.
