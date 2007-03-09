unit Brokers;

{$I PhoneBook.inc}

interface

{$IFDEF UseInstantObjects}
uses
  InstantIBX, InstantBDE,
  PressInstantObjectsBroker;
{$ENDIF}

implementation

{$IFNDEF UseInstantObjects}
uses
  PressSubject, PressPersistence;

type
  TPressPhoneBookPersistence = class(TPressPersistence)
  protected
    procedure InternalCommit; override;
    procedure InternalDispose(AClass: TPressObjectClass; const AId: string); override;
    procedure InternalExecuteStatement(const AStatement: string); override;
    function InternalOQLQuery(const AOQLStatement: string): TPressProxyList; override;
    function InternalRetrieve(AClass: TPressObjectClass; const AId: string; AMetadata: TPressObjectMetadata): TPressObject; override;
    function InternalRetrieveProxyList(AQuery: TPressQuery): TPressProxyList; override;
    procedure InternalRollback; override;
    function InternalSQLForObject(const ASQLStatement: string): TPressProxyList; override;
    function InternalSQLQuery(AClass: TPressObjectClass; const ASQLStatement: string): TPressProxyList; override;
    procedure InternalStartTransaction; override;
    procedure InternalStore(AObject: TPressObject); override;
  end;

{ TPressPhoneBookPersistence }

procedure TPressPhoneBookPersistence.InternalCommit;
begin
end;

procedure TPressPhoneBookPersistence.InternalDispose(
  AClass: TPressObjectClass; const AId: string);
begin
end;

procedure TPressPhoneBookPersistence.InternalExecuteStatement(
  const AStatement: string);
begin
end;

function TPressPhoneBookPersistence.InternalOQLQuery(
  const AOQLStatement: string): TPressProxyList;
begin
  { TODO : Implement }
  Result := InternalRetrieveProxyList(nil);
end;

function TPressPhoneBookPersistence.InternalRetrieve(
  AClass: TPressObjectClass; const AId: string;
  AMetadata: TPressObjectMetadata): TPressObject;
begin
  Result := nil;
end;

function TPressPhoneBookPersistence.InternalRetrieveProxyList(
  AQuery: TPressQuery): TPressProxyList;
begin
  { TODO : Improve }
  Result := TPressProxyList.Create(True, ptShared);
  try
    with Cache.CreateIterator do
    try
      BeforeFirstItem;
      while NextItem do
        if CurrentItem is AQuery.Metadata.ItemObjectClass then
          Result.AddInstance(CurrentItem);
    finally
      Free;
    end;
  except
    Result.Free;
    raise;
  end;
end;

procedure TPressPhoneBookPersistence.InternalRollback;
begin
end;

function TPressPhoneBookPersistence.InternalSQLForObject(
  const ASQLStatement: string): TPressProxyList;
begin
  { TODO : Implement }
  Result := InternalRetrieveProxyList(nil);
end;

function TPressPhoneBookPersistence.InternalSQLQuery(
  AClass: TPressObjectClass; const ASQLStatement: string): TPressProxyList;
begin
  { TODO : Implement }
  Result := InternalRetrieveProxyList(nil);
end;

procedure TPressPhoneBookPersistence.InternalStartTransaction;
begin
end;

procedure TPressPhoneBookPersistence.InternalStore(AObject: TPressObject);
begin
  if AObject.Id = '' then
    AObject.Id := GenerateOID(AObject.ClassType, 'Id');
end;

initialization
  TPressPhoneBookPersistence.RegisterService;
{$ENDIF}

end.
