unit Brokers;

{$I PhoneBook.inc}

{$IFDEF UseInstantObjects}

(*******************************
   INSTANTOBJECTS DECLARATIONS
 *******************************)

interface

uses
  // NOTE: navigational brokers (like BDE) aren't supported
  InstantIBX,
  // insert other InstantObjects' brokers here
  PressInstantObjectsBroker;

implementation

{$ENDIF}
{$IFDEF UsePressOPF}

(****************************
   PRESSOJECTS DECLARATIONS
 ****************************)

interface

uses
  PressSubject, PressPersistence,
{$IFDEF UseReport}
  PressFastReportBroker,
{$ENDIF}
{$IFDEF FPC}
  PressSQLdbBroker,
  // Insert other Free Pascal connection brokers and SQLdb connections here
{$ELSE}
  PressIBXBroker,
  // Insert other Delphi connection brokers here
{$ENDIF}
  PressOPF;

type
  TPhoneBookPersistence = class(TPressOPF)
  protected
    procedure InternalShowConnectionManager; override;
  end;

  TPhoneBookGenerator = class(TPressOIDGenerator)
  protected
    function InternalGenerateOID(Sender: TPressPersistence; AObjectClass: TPressObjectClass; const AAttributeName: string): string; override;
  end;

implementation

uses
  SysUtils,
  Clipbrd,
  PressDialogs;

{ TPhoneBookPersistence }

procedure TPhoneBookPersistence.InternalShowConnectionManager;
begin
  if PressDialog.ConfirmDlg(
   'Copy the database metadata to the clipboard?') then
    Clipboard.AsText :=
     AdjustLineBreaks(PressOPFService.Mapper.CreateDatabaseStatement);
end;

{ TPhoneBookGenerator }

function TPhoneBookGenerator.InternalGenerateOID(
  Sender: TPressPersistence; AObjectClass: TPressObjectClass;
  const AAttributeName: string): string;
begin
  Result :=
   inherited InternalGenerateOID(Sender, AObjectClass, AAttributeName);
end;

initialization
  TPhoneBookPersistence.RegisterService(True);
  TPhoneBookGenerator.RegisterService(True);

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
