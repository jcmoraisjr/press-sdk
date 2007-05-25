unit Brokers;

{$I PhoneBook.inc}

{$IFDEF UseInstantObjects}

interface

uses
  InstantIBX, // currently navigational brokers (like BDE) aren't supported
  PressInstantObjectsBroker;

implementation

{$ENDIF}
{$IFDEF UsePressOPF}

interface

uses
{$IFDEF FPC}
  PressSQLdbBroker;
{$ELSE}
  PressIBXBroker;
{$ENDIF}

type
  TBroker = class(
{$IFDEF FPC}
  TPressSQLdbBroker
{$ELSE}
  TPressIBXBroker
{$ENDIF}
  )
  protected
    procedure InitService; override;
    procedure InternalShowConnectionManager; override;
  end;

implementation

uses
  SysUtils,
  Clipbrd,
{$IFDEF FPC}
  ibconnection,
{$ENDIF}
  PressDialogs,
  PressOPF;

procedure TBroker.InitService;
begin
{$IFDEF FPC}
  Connector.AssignConnectionDef(TIBConnectionDef);
  with Connector.Database do
  begin
    DatabaseName := // 'servername:/path/to/database';
    UserName     := // 'sysdba';
    Password     := // 'masterkey';
  end;
{$ELSE}
  with Connector.Database do
  begin
    DatabaseName               := // 'servername:c:\path\to\database';
    Params.Values['user_name'] := // 'sysdba';
    Params.Values['password']  := // 'masterkey';
  end;
{$ENDIF}
end;

procedure TBroker.InternalShowConnectionManager;
begin
  if PressDialog.ConfirmDlg(
   'Copy the database metadata to the clipboard?') then
    Clipboard.AsText :=
     AdjustLineBreaks(PressOPFService.Mapper.CreateDatabaseStatement);
end;

initialization
  TBroker.RegisterService(True);

{$ENDIF}
{$IFDEF DontUsePersistence}

interface

uses
  PressSubject, PressPersistence;

type
  TPressPhoneBookPersistence = class(TPressPersistence)
  protected
    procedure InternalCommit; override;
    procedure InternalDispose(AClass: TPressObjectClass; const AId: string); override;
    function InternalExecuteStatement(const AStatement: string): Integer; override;
    function InternalOQLQuery(const AOQLStatement: string): TPressProxyList; override;
    function InternalRetrieve(AClass: TPressObjectClass; const AId: string; AMetadata: TPressObjectMetadata): TPressObject; override;
    function InternalRetrieveProxyList(AQuery: TPressQuery): TPressProxyList; override;
    procedure InternalRollback; override;
    function InternalSQLProxy(const ASQLStatement: string): TPressProxyList; override;
    function InternalSQLQuery(AClass: TPressObjectClass; const ASQLStatement: string): TPressProxyList; override;
    procedure InternalStartTransaction; override;
    procedure InternalStore(AObject: TPressObject); override;
  end;

{ TPressPhoneBookPersistence }

implementation

procedure TPressPhoneBookPersistence.InternalCommit;
begin
end;

procedure TPressPhoneBookPersistence.InternalDispose(
  AClass: TPressObjectClass; const AId: string);
begin
end;

function TPressPhoneBookPersistence.InternalExecuteStatement(
  const AStatement: string): Integer;
begin
  Result := 0;
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

function TPressPhoneBookPersistence.InternalSQLProxy(
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
