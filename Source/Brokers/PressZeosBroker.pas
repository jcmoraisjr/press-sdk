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
  PressOPF,
  PressOPFConnector,
  PressOPFMapper,
  PressDataSetBroker,
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
    {$IFNDEF D5}
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

initialization
  TPressZeosBroker.RegisterService;

finalization
  TPressZeosBroker.UnregisterService;

end.
