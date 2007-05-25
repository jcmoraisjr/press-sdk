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
  PressOPFBroker,
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
    property Connector: TPressSQLdbConnector read GetConnector;
  end;

  { TPressSQLdbConnector }

  TPressSQLdbConnector = class(TPressOPFConnector)
  private
    FConnectionDefClass: TConnectionDefClass;
    FDatabase: TSQLConnection;
    FTransaction: TSQLTransaction;
    function GetDatabase: TSQLConnection;
  protected
    function GetSupportTransaction: Boolean; override;
    procedure InternalCommit; override;
    procedure InternalConnect; override;
    function InternalDatasetClass: TPressOPFDatasetClass; override;
    procedure InternalRollback; override;
    procedure InternalStartTransaction; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure AssignConnectionDef(AConnectionDefClass: TConnectionDefClass);
    property ConnectionDefClass: TConnectionDefClass read FConnectionDefClass;
    property Database: TSQLConnection read GetDatabase;
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
  db,
  PressConsts,
  PressOPFClasses,
  PressIBFbBroker;

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

{ TPressSQLdbConnector }

procedure TPressSQLdbConnector.AssignConnectionDef(
  AConnectionDefClass: TConnectionDefClass);
begin
  FConnectionDefClass := AConnectionDefClass;
  FDatabase.Free;
  FDatabase := FConnectionDefClass.ConnectionClass.Create(nil);
  FTransaction.Database := FDatabase;
end;

constructor TPressSQLdbConnector.Create;
begin
  inherited;
  FTransaction := TSQLTransaction.Create(nil);
end;

destructor TPressSQLdbConnector.Destroy;
begin
  FDatabase.Free;
  FTransaction.Free;
  inherited;
end;

function TPressSQLdbConnector.GetDatabase: TSQLConnection;
begin
  if not Assigned(FDatabase) then
    raise EPressOPFError.Create(SUnassignedDatabase);
  Result := FDatabase;
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
    Result := 0;
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
  VConnectionDefClass: TConnectionDefClass;
  VConnectionTypeName: string;
begin
  VConnectionDefClass := (Connector as TPressSQLdbConnector).ConnectionDefClass;
  if not Assigned(VConnectionDefClass) then
    raise EPressOPFError.Create(SUnassignedDatabase);
  VConnectionTypeName := VConnectionDefClass.TypeName;
  if SameText(VConnectionTypeName, 'firebird') then
    Result := TPressIBFbDDLBuilder
  else
    raise EPressOPFError.CreateFmt(
     SUnsupportedConnector, [VConnectionTypeName]);
end;

initialization
  TPressSQLdbBroker.RegisterService;

end.
