(*
  PressObjects, UIB Connection Broker
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressUIBBroker;

{$I Press.inc}

interface

uses
  PressOPFBroker,
  PressOPFConnector,
  PressOPFMapper,
  PressDataSetBroker,
  jvuib,
  jvuibdataset;

type
  TPressUIBConnector = class;

  TPressUIBBroker = class(TPressOPFBroker)
  private
    function GetConnector: TPressUIBConnector;
  protected
    function InternalConnectorClass: TPressOPFConnectorClass; override;
    function InternalMapperClass: TPressOPFObjectMapperClass; override;
  public
    property Connector: TPressUIBConnector read GetConnector;
  end;

  TPressUIBConnector = class(TPressOPFConnector)
  private
    FDatabase: TJvUIBDatabase;
    FTransaction: TJvUIBTransaction;
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
    property Database: TJvUIBDatabase read FDatabase;
    property Transaction: TJvUIBTransaction read FTransaction;
  end;

  TPressUIBDataset = class(TPressOPFDBDataset)
  private
    FQuery: TJvUIBDataSet;
    function GetQuery: TJvUIBDataSet;
    function GetConnector: TPressUIBConnector;
    procedure PopulateParams;
  protected
    function InternalExecute: Integer; override;
    procedure InternalSQLChanged; override;
    property Connector: TPressUIBConnector read GetConnector;
    property Query: TJvUIBDataSet read GetQuery;
  public
    destructor Destroy; override;
  end;

  TPressUIBObjectMapper = class(TPressOPFObjectMapper)
  protected
    function InternalDDLBuilderClass: TPressOPFDDLBuilderClass; override;
  end;

implementation

uses
  PressOPFClasses,
  PressIBFbBroker,
  jvuiblib;

{ TPressUIBBroker }

function TPressUIBBroker.GetConnector: TPressUIBConnector;
begin
  Result := inherited Connector as TPressUIBConnector;
end;

function TPressUIBBroker.InternalConnectorClass: TPressOPFConnectorClass;
begin
  Result := TPressUIBConnector;
end;

function TPressUIBBroker.InternalMapperClass: TPressOPFObjectMapperClass;
begin
  Result := TPressUIBObjectMapper;
end;

{ TPressUIBConnector }

constructor TPressUIBConnector.Create;
begin
  inherited;
  FDatabase := TJvUIBDatabase.Create(nil);
  FTransaction := TJvUIBTransaction.Create(nil);
  FTransaction.DataBase := FDatabase;
end;

destructor TPressUIBConnector.Destroy;
begin
  FDatabase.Free;
  FTransaction.Free;
  inherited;
end;

function TPressUIBConnector.GetSupportTransaction: Boolean;
begin
  Result := True;
end;

procedure TPressUIBConnector.InternalCommit;
begin
  Transaction.Commit;
end;

procedure TPressUIBConnector.InternalConnect;
begin
  Database.Connected := True;
end;

function TPressUIBConnector.InternalDatasetClass: TPressOPFDatasetClass;
begin
  Result := TPressUIBDataset;
end;

procedure TPressUIBConnector.InternalRollback;
begin
  Transaction.Rollback;
end;

procedure TPressUIBConnector.InternalStartTransaction;
begin
  Transaction.StartTransaction;
end;

{ TPressUIBDataset }

destructor TPressUIBDataset.Destroy;
begin
  FQuery.Free;
  inherited;
end;

function TPressUIBDataset.GetConnector: TPressUIBConnector;
begin
  Result := inherited Connector as TPressUIBConnector;
end;

function TPressUIBDataset.GetQuery: TJvUIBDataSet;
begin
  if not Assigned(FQuery) then
  begin
    FQuery := TJvUIBDataSet.Create(nil);
    FQuery.Database := Connector.Database;
    FQuery.Transaction := Connector.Transaction;
    FQuery.FetchBlobs := True;
    {$IFNDEF FPC}
    FQuery.UniDirectional := True;
    {$ENDIF}
  end;
  Result := FQuery;
end;

function TPressUIBDataset.InternalExecute: Integer;
begin
  PopulateParams;
  if IsSelectStatement then
  begin
    PopulateOPFDataset(Query);
    Result := Count;
  end else
  begin
    Query.Execute;
    Result := Query.RowsAffected;
  end;
end;

procedure TPressUIBDataset.InternalSQLChanged;
begin
  inherited;
  Query.SQL.Text := SQL;
end;

procedure TPressUIBDataset.PopulateParams;
var
  VParam: TPressOPFParam;
  VDBParams: TSQLParams;
  VBlobParam: string;
  I: Integer;
begin
  for I := 0 to Pred(Params.Count) do
  begin
    VParam := Params[I];
    VDBParams := Query.Params;
    if not VParam.IsNull then
    begin
      case VParam.DataType of
        oftString:
          VDBParams.ByNameAsString[VParam.Name] := VParam.AsString;
        oftInt16, oftInt32:
          VDBParams.ByNameAsInteger[VParam.Name] := VParam.AsInt32;
        oftInt64:
          VDBParams.ByNameAsInt64[VParam.Name] := VParam.AsInt64;
        oftFloat:
          VDBParams.ByNameAsDouble[VParam.Name] := VParam.AsFloat;
        oftCurrency:
          VDBParams.ByNameAsCurrency[VParam.Name] := VParam.AsCurrency;
        oftBoolean:
          VDBParams.ByNameAsBoolean[VParam.Name] := VParam.AsBoolean;
        oftDate:
          VDBParams.ByNameAsDate[VParam.Name] := Trunc(VParam.AsDate);
        oftTime, oftDateTime:
          VDBParams.ByNameAsDateTime[VParam.Name] := VParam.AsDateTime;
        oftMemo, oftBinary:
        begin
          VBlobParam := VParam.AsBinary;
          Query.ParamsSetBlob(VParam.Name, VBlobParam);
        end;
      end;
    end else if VParam.IsAssigned then
      VDBParams.ByNameIsNull[VParam.Name] := True;
  end;
end;

{ TPressUIBObjectMapper }

function TPressUIBObjectMapper.InternalDDLBuilderClass: TPressOPFDDLBuilderClass;
begin
  Result := TPressIBFbDDLBuilder;
end;

initialization
  TPressUIBBroker.RegisterService;

end.
