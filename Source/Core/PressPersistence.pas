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
  TPressPersistenceBrokerClass = class of TPressPersistenceBroker;

  TPressPersistenceBroker = class(TObject)
  protected
    function GetIdentifierQuotes: string; virtual;
    function GetStrQuote: Char; virtual;
    procedure InitPersistenceBroker; virtual;
    procedure InternalDispose(AObject: TPressObject); virtual; abstract;
    function InternalRetrieve(const AClass, AId: string): TPressObject; virtual; abstract;
    function InternalRetrieveProxyList(AQuery: TPressQuery): TPressProxyList; virtual; abstract;
    procedure InternalStore(AObject: TPressObject); virtual; abstract;
  public
    constructor Create; virtual;
    procedure Dispose(const AClass, AId: string); overload;
    procedure Dispose(AObject: TPressObject); overload;
    procedure Dispose(AProxy: TPressProxy); overload;
    function Retrieve(const AClass, AId: string): TPressObject;
    function RetrieveProxyList(AQuery: TPressQuery): TPressProxyList;
    procedure Store(AObject: TPressObject);
    property IdentifierQuotes: string read GetIdentifierQuotes;
    property StrQuote: Char read GetStrQuote;
  end;

procedure PressAssignPersistenceBrokerClass(APersistenceBrokerClass: TPressPersistenceBrokerClass);
function PressPersistenceBroker: TPressPersistenceBroker;

implementation

uses
  SysUtils,
  PressClasses,
  PressConsts
  {$IFDEF PressLog},PressLog{$ENDIF};

var
  _PressPersistenceBrokerClass: TPressPersistenceBrokerClass;
  _PressPersistenceBroker: TPressPersistenceBroker;

procedure PressAssignPersistenceBrokerClass(
  APersistenceBrokerClass: TPressPersistenceBrokerClass);
begin
  if Assigned(_PressPersistenceBrokerClass) then
    raise EPressError.Create(SPersistenceBrokerClassIsAssigned);
  _PressPersistenceBrokerClass := APersistenceBrokerClass;
end;

function PressPersistenceBroker: TPressPersistenceBroker;
begin
  if not Assigned(_PressPersistenceBroker) then
  begin
    if not Assigned(_PressPersistenceBrokerClass) then
      raise EPressError.Create(SUnassignedPersistenceBrokerClass);
    _PressPersistenceBroker := _PressPersistenceBrokerClass.Create;
    PressRegisterSingleObject(_PressPersistenceBroker);
  end;
  Result := _PressPersistenceBroker;
end;

{ TPressPersistenceBroker }

constructor TPressPersistenceBroker.Create;
begin
  inherited Create;
  InitPersistenceBroker;
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

function TPressPersistenceBroker.GetStrQuote: Char;
begin
  Result := '''';
end;

procedure TPressPersistenceBroker.InitPersistenceBroker;
begin
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
