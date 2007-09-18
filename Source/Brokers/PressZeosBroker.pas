(*
  PressObjects, ZeosDBO Connection Broker
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressZeosBroker;

{$I Press.inc}

interface

uses
  Classes,
  PressOPF,
  PressOPFConnector,
  PressOPFMapper,
  PressOPFSQLBuilder,
  PressDataSetBroker,
  ZCompatibility,
  ZConnection,
  ZDataset;

type
  TPressZeosConnector = class;

  TPressZeosBroker = class(TPressOPFBroker)
  private
    function GetConnector: TPressZeosConnector;
  protected
    function InternalConnectorClass: TPressOPFConnectorClass; override;
    function InternalMapperClass: TPressOPFObjectMapperClass; override;
  public
    class function ServiceName: string; override;
  published
    property Connector: TPressZeosConnector read GetConnector;
  end;

  TPressZeosConnector = class(TPressOPFConnector)
  private
    FConnection: TZConnection;
  protected
    function GetSupportTransaction: Boolean; override;
    procedure InternalCommit; override;
    procedure InternalConnect; override;
    function InternalDatasetClass: TPressOPFDatasetClass; override;
    function InternalDBMSName: string; override;
    procedure InternalRollback; override;
    procedure InternalStartTransaction; override;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property Connection: TZConnection read FConnection;
  end;

  TPressZeosDataset = class(TPressOPFDBDataset)
  private
    FQuery: TZReadOnlyQuery;
    function GetQuery: TZReadOnlyQuery;
    function GetConnector: TPressZeosConnector;
  protected
    function InternalExecute: Integer; override;
    procedure InternalSQLChanged; override;
    property Connector: TPressZeosConnector read GetConnector;
    property Query: TZReadOnlyQuery read GetQuery;
  public
    destructor Destroy; override;
  end;

  TPressZeosObjectMapper = class(TPressOPFObjectMapper)
  protected
    function InternalDDLBuilderClass: TPressOPFDDLBuilderClass; override;
  end;

  TPressZeosConnection = class(TPressOPFConnection)
  private
    FConnection: TZConnection;
    function GetAfterConnect: TNotifyEvent;
    function GetAfterDisconnect: TNotifyEvent;
    function GetBeforeConnect: TNotifyEvent;
    function GetBeforeDisconnect: TNotifyEvent;
    function GetCatalog: string;
    function GetConnected: Boolean;
    function GetDatabase: string;
    function GetHostName: string;
    function GetLoginPrompt: Boolean;
    function GetOnLogin: TLoginEvent;
    function GetPassword: string;
    function GetPort: Integer;
    function GetProperties: TStrings;
    function GetProtocol: string;
    function GetUser: string;
    procedure SetAfterConnect(AValue: TNotifyEvent);
    procedure SetAfterDisconnect(AValue: TNotifyEvent);
    procedure SetBeforeConnect(AValue: TNotifyEvent);
    procedure SetBeforeDisconnect(AValue: TNotifyEvent);
    procedure SetCatalog(const AValue: string);
    procedure SetConnected(AValue: Boolean);
    procedure SetDatabase(const AValue: string);
    procedure SetHostName(const AValue: string);
    procedure SetLoginPrompt(AValue: Boolean);
    procedure SetOnLogin(AValue: TLoginEvent);
    procedure SetPassword(const AValue: string);
    procedure SetPort(AValue: Integer);
    procedure SetProperties(AValue: TStrings);
    procedure SetProtocol(const AValue: string);
    procedure SetUser(const AValue: string);
  protected
    function InternalBrokerClass: TPressOPFBrokerClass; override;
    property Connection: TZConnection read FConnection;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Protocol: string read GetProtocol write SetProtocol;
    property HostName: string read GetHostName write SetHostName;
    property Port: Integer read GetPort write SetPort;
    property Database: string read GetDatabase write SetDatabase;
    property User: string read GetUser write SetUser;
    property Password: string read GetPassword write SetPassword;
    property Catalog: string read GetCatalog write SetCatalog;
    property Properties: TStrings read GetProperties write SetProperties;
    property Connected: Boolean read GetConnected write SetConnected;
    property LoginPrompt: Boolean read GetLoginPrompt write SetLoginPrompt default False;
    property BeforeConnect: TNotifyEvent read GetBeforeConnect write SetBeforeConnect;
    property AfterConnect: TNotifyEvent read GetAfterConnect write SetAfterConnect;
    property BeforeDisconnect: TNotifyEvent read GetBeforeDisconnect write SetBeforeDisconnect;
    property AfterDisconnect: TNotifyEvent read GetAfterDisconnect write SetAfterDisconnect;
    property OnLogin: TLoginEvent read GetOnLogin write SetOnLogin;
  end;

implementation

uses
  SysUtils,
  PressConsts,
  PressOPFClasses,
  PressIBFbBroker,
  ZDbcIntfs;

{ TPressZeosBroker }

function TPressZeosBroker.GetConnector: TPressZeosConnector;
begin
  Result := inherited Connector as TPressZeosConnector;
end;

function TPressZeosBroker.InternalConnectorClass: TPressOPFConnectorClass;
begin
  Result := TPressZeosConnector;
end;

function TPressZeosBroker.InternalMapperClass: TPressOPFObjectMapperClass;
begin
  Result := TPressZeosObjectMapper;
end;

class function TPressZeosBroker.ServiceName: string;
begin
  Result := 'Zeos';
end;

{ TPressZeosConnector }

constructor TPressZeosConnector.Create;
begin
  inherited;
  FConnection := TZConnection.Create(nil);
  FConnection.TransactIsolationLevel := tiReadCommitted;
end;

destructor TPressZeosConnector.Destroy;
begin
  FConnection.Free;
  inherited;
end;

function TPressZeosConnector.GetSupportTransaction: Boolean;
begin
  Result := True;
end;

procedure TPressZeosConnector.InternalCommit;
begin
  Connection.Commit;
end;

procedure TPressZeosConnector.InternalConnect;
begin
  Connection.Connect;
end;

function TPressZeosConnector.InternalDatasetClass: TPressOPFDatasetClass;
begin
  Result := TPressZeosDataset;
end;

function TPressZeosConnector.InternalDBMSName: string;
begin
  if Connection.Connected then
    Result := Connection.DbcConnection.GetMetadata.GetDatabaseProductName
  else
    Result := Connection.Protocol;
end;

procedure TPressZeosConnector.InternalRollback;
begin
  Connection.Rollback;
end;

procedure TPressZeosConnector.InternalStartTransaction;
begin
  Connection.AutoCommit := False;
end;

{ TPressZeosDataset }

destructor TPressZeosDataset.Destroy;
begin
  FQuery.Free;
  inherited;
end;

function TPressZeosDataset.GetConnector: TPressZeosConnector;
begin
  Result := inherited Connector as TPressZeosConnector;
end;

function TPressZeosDataset.GetQuery: TZReadOnlyQuery;
begin
  if not Assigned(FQuery) then
  begin
    FQuery := TZReadOnlyQuery.Create(nil);
    FQuery.Connection := Connector.Connection;
    {$IFNDEF D5Down}
    FQuery.IsUniDirectional := True;
    {$ENDIF}
  end;
  Result := FQuery;
end;

function TPressZeosDataset.InternalExecute: Integer;
begin
  PopulateParams(Query.Params);
  if IsSelectStatement then
  begin
    PopulateOPFDataset(Query);
    Result := Count;
  end else
  begin
    Query.ExecSQL;
    Result := Query.RowsAffected;
  end;
end;

procedure TPressZeosDataset.InternalSQLChanged;
begin
  inherited;
  Query.SQL.Text := SQL;
end;

{ TPressZeosObjectMapper }

function TPressZeosObjectMapper.InternalDDLBuilderClass: TPressOPFDDLBuilderClass;
var
  VProtocol: string;
begin
  { TODO : Implement }
  VProtocol := (Connector as TPressZeosConnector).Connection.Protocol;
  if SameText(Copy(VProtocol, 1, 8), 'firebird') then
    Result := TPressIBFbDDLBuilder
  else
    raise EPressOPFError.CreateFmt(
     SUnsupportedConnector, [VProtocol]);
end;

{ TPressZeosConnection }

constructor TPressZeosConnection.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FConnection := (Connector as TPressZeosConnector).Connection;
end;

function TPressZeosConnection.GetAfterConnect: TNotifyEvent;
begin
  Result := Connection.AfterConnect;
end;

function TPressZeosConnection.GetAfterDisconnect: TNotifyEvent;
begin
  Result := Connection.AfterDisconnect;
end;

function TPressZeosConnection.GetBeforeConnect: TNotifyEvent;
begin
  Result := Connection.BeforeConnect;
end;

function TPressZeosConnection.GetBeforeDisconnect: TNotifyEvent;
begin
  Result := Connection.BeforeDisconnect;
end;

function TPressZeosConnection.GetCatalog: string;
begin
  Result := Connection.Catalog;
end;

function TPressZeosConnection.GetConnected: Boolean;
begin
  Result := Connection.Connected;
end;

function TPressZeosConnection.GetDatabase: string;
begin
  Result := Connection.Database;
end;

function TPressZeosConnection.GetHostName: string;
begin
  Result := Connection.HostName;
end;

function TPressZeosConnection.GetLoginPrompt: Boolean;
begin
  Result := Connection.LoginPrompt;
end;

function TPressZeosConnection.GetOnLogin: TLoginEvent;
begin
  Result := Connection.OnLogin;
end;

function TPressZeosConnection.GetPassword: string;
begin
  Result := Connection.Password;
end;

function TPressZeosConnection.GetPort: Integer;
begin
  Result := Connection.Port;
end;

function TPressZeosConnection.GetProperties: TStrings;
begin
  Result := Connection.Properties;
end;

function TPressZeosConnection.GetProtocol: string;
begin
  Result := Connection.Protocol;
end;

function TPressZeosConnection.GetUser: string;
begin
  Result := Connection.User;
end;

function TPressZeosConnection.InternalBrokerClass: TPressOPFBrokerClass;
begin
  Result := TPressZeosBroker;
end;

procedure TPressZeosConnection.SetAfterConnect(AValue: TNotifyEvent);
begin
  Connection.AfterConnect := AValue;
end;

procedure TPressZeosConnection.SetAfterDisconnect(AValue: TNotifyEvent);
begin
  Connection.AfterDisconnect := AValue;
end;

procedure TPressZeosConnection.SetBeforeConnect(AValue: TNotifyEvent);
begin
  Connection.BeforeConnect := AValue;
end;

procedure TPressZeosConnection.SetBeforeDisconnect(AValue: TNotifyEvent);
begin
  Connection.BeforeDisconnect := AValue;
end;

procedure TPressZeosConnection.SetCatalog(const AValue: string);
begin
  Connection.Catalog := AValue;
end;

procedure TPressZeosConnection.SetConnected(AValue: Boolean);
begin
  Connection.Connected := AValue;
end;

procedure TPressZeosConnection.SetDatabase(const AValue: string);
begin
  Connection.Database := AValue;
end;

procedure TPressZeosConnection.SetHostName(const AValue: string);
begin
  Connection.HostName := AValue;
end;

procedure TPressZeosConnection.SetLoginPrompt(AValue: Boolean);
begin
  Connection.LoginPrompt := AValue;
end;

procedure TPressZeosConnection.SetOnLogin(AValue: TLoginEvent);
begin
  Connection.OnLogin := AValue;
end;

procedure TPressZeosConnection.SetPassword(const AValue: string);
begin
  Connection.Password := AValue;
end;

procedure TPressZeosConnection.SetPort(AValue: Integer);
begin
  Connection.Port := AValue;
end;

procedure TPressZeosConnection.SetProperties(AValue: TStrings);
begin
  Connection.Properties := AValue;
end;

procedure TPressZeosConnection.SetProtocol(const AValue: string);
begin
  Connection.Protocol := AValue;
end;

procedure TPressZeosConnection.SetUser(const AValue: string);
begin
  Connection.User := AValue;
end;

initialization
  TPressZeosBroker.RegisterService;

finalization
  TPressZeosBroker.UnregisterService;

end.
