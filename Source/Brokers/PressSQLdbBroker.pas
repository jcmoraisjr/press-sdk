(*
  PressObjects, SQLdb Connection Broker
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressSQLdbBroker;

{$I Press.inc}

interface

uses
  PressOPF,
  PressOPFConnector,
  PressOPFMapper,
  PressDataSetBroker,
  sqldb;

type
  TPressSQLdbConnector = class;

  TPressSQLdbBroker = class(TPressOPFBroker)
  private
    function GetConnector: TPressSQLdbConnector;
  protected
    function InternalConnectorClass: TPressOPFConnectorClass; override;
    function InternalMapperClass: TPressOPFObjectMapperClass; override;
  public
    class function ServiceName: string; override;
  published
    property Connector: TPressSQLdbConnector read GetConnector;
  end;

  { TPressSQLdbConnector }

  TPressSQLdbConnector = class(TPressOPFConnector)
  private
    FDatabase: TSQLConnector;
    FTransaction: TSQLTransaction;
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
    property Database: TSQLConnector read FDatabase;
    property Transaction: TSQLTransaction read FTransaction;
  end;

  TPressSQLdbDataset = class(TPressOPFDBDataset)
  private
    FQuery: TSQLQuery;
    function GetQuery: TSQLQuery;
    function GetConnector: TPressSQLdbConnector;
  protected
    function InternalExecute: Integer; override;
    procedure InternalSQLChanged; override;
    property Connector: TPressSQLdbConnector read GetConnector;
    property Query: TSQLQuery read GetQuery;
  public
    destructor Destroy; override;
  end;

  TPressSQLdbObjectMapper = class(TPressOPFObjectMapper)
  protected
    function InternalDDLBuilderClass: TPressOPFDDLBuilderClass; override;
  end;

implementation

uses
  SysUtils,
  PressConsts,
  PressOPFClasses,
  PressIBFbBroker,
  PressOracleBroker;

{ TPressSQLdbBroker }

function TPressSQLdbBroker.GetConnector: TPressSQLdbConnector;
begin
  Result := inherited Connector as TPressSQLdbConnector;
end;

function TPressSQLdbBroker.InternalConnectorClass: TPressOPFConnectorClass;
begin
  Result := TPressSQLdbConnector;
end;

function TPressSQLdbBroker.InternalMapperClass: TPressOPFObjectMapperClass;
begin
  Result := TPressSQLdbObjectMapper;
end;

class function TPressSQLdbBroker.ServiceName: string;
begin
  Result := 'SQLdb';
end;

{ TPressSQLdbConnector }

constructor TPressSQLdbConnector.Create;
begin
  inherited;
  FDatabase := TSQLConnector.Create(nil);
  FTransaction := TSQLTransaction.Create(nil);
  FDatabase.Transaction := FTransaction;
end;

destructor TPressSQLdbConnector.Destroy;
begin
  FDatabase.Free;
  FTransaction.Free;
  inherited;
end;

function TPressSQLdbConnector.GetSupportTransaction: Boolean;
begin
  Result := True;
end;

procedure TPressSQLdbConnector.InternalCommit;
begin
  Transaction.Commit;
end;

procedure TPressSQLdbConnector.InternalConnect;
begin
  Database.Open;
end;

function TPressSQLdbConnector.InternalDatasetClass: TPressOPFDatasetClass;
begin
  Result := TPressSQLdbDataset;
end;

function TPressSQLdbConnector.InternalDBMSName: string;
begin
  Result := Database.ConnectorType;
end;

procedure TPressSQLdbConnector.InternalRollback;
begin
  Transaction.Rollback;
end;

procedure TPressSQLdbConnector.InternalStartTransaction;
begin
  Transaction.StartTransaction;
end;

{ TPressSQLdbDataset }

destructor TPressSQLdbDataset.Destroy;
begin
  FQuery.Free;
  inherited;
end;

function TPressSQLdbDataset.GetConnector: TPressSQLdbConnector;
begin
  Result := inherited Connector as TPressSQLdbConnector;
end;

function TPressSQLdbDataset.GetQuery: TSQLQuery;
begin
  if not Assigned(FQuery) then
  begin
    { TODO : Optimize }
    FQuery := TSQLQuery.Create(nil);
    FQuery.Database := Connector.Database;
    FQuery.Transaction := Connector.Transaction;
    FQuery.ReadOnly := True;
  end;
  Result := FQuery;
end;

function TPressSQLdbDataset.InternalExecute: Integer;
begin
  PopulateParams(Query.Params);
  if IsSelectStatement then
  begin
    PopulateOPFDataset(Query);
    Result := Count;
  end else
  begin
    Query.ExecSQL;
    { TODO : Implement }
    Result := 1;  // dont raise conflict exception
  end;
end;

procedure TPressSQLdbDataset.InternalSQLChanged;
begin
  inherited;
  Query.SQL.Text := SQL;
end;

{ TPressSQLdbObjectMapper }

function TPressSQLdbObjectMapper.InternalDDLBuilderClass: TPressOPFDDLBuilderClass;
var
  VConnectionTypeName: string;
begin
  VConnectionTypeName :=
   (Connector as TPressSQLdbConnector).Database.ConnectorType;
  if SameText(VConnectionTypeName, 'firebird') then
    Result := TPressIBFbDDLBuilder
  else if SameText(VConnectionTypeName, 'oracle') then
    Result := TPressOracleDDLBuilder
  else
    raise EPressOPFError.CreateFmt(
     SUnsupportedConnector, [VConnectionTypeName]);
end;

initialization
  TPressSQLdbBroker.RegisterService;

end.
