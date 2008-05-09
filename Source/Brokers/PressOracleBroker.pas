(*
  PressObjects, Oracle database Broker
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressOracleBroker;

{$I Press.inc}

interface

uses
  PressOPFClasses,
  PressOPFSQLBuilder,
  PressOPFStorage;

type
  TPressOracleDDLBuilder = class(TPressOPFDDLBuilder)
  protected
    function InternalFieldTypeStr(AFieldType: TPressOPFFieldType): string; override;
    function InternalImplicitIndexCreation: Boolean; override;
    function InternalMaxIdentLength: Integer; override;
  public
    function CreateForeignKeyStatement(ATableMetadata: TPressOPFTableMetadata; AForeignKeyMetadata: TPressOPFForeignKeyMetadata): string; override;
    function CreateGeneratorStatement: string; override;
    function SelectGeneratorStatement: string; override;
  end;

implementation

uses
  SysUtils;

{ TPressOracleDDLBuilder }

function TPressOracleDDLBuilder.CreateForeignKeyStatement(
  ATableMetadata: TPressOPFTableMetadata;
  AForeignKeyMetadata: TPressOPFForeignKeyMetadata): string;
const
  CReferentialAction: array[TPressOPFReferentialAction] of string = (
   '', 'cascade', 'set null', '');
begin
  Result := Format(
   'alter table %s add constraint %s'#10 +
   '  foreign key (%s)'#10 +
   '  references %s (%s)', [
   ATableMetadata.Name,
   AForeignKeyMetadata.Name,
   BuildStringList(AForeignKeyMetadata.KeyFieldNames),
   AForeignKeyMetadata.ReferencedTableName,
   BuildStringList(AForeignKeyMetadata.ReferencedFieldNames)]);
  if AForeignKeyMetadata.OnDeleteAction in [raCascade, raSetNull] then
    Result := Format('%s'#10'  on delete %s', [
     Result,
     CReferentialAction[AForeignKeyMetadata.OnDeleteAction]]);
  Result := Result + ';' + #10#10;
end;

function TPressOracleDDLBuilder.CreateGeneratorStatement: string;
begin
  Result := 'create sequence %s';
end;

function TPressOracleDDLBuilder.InternalFieldTypeStr(
  AFieldType: TPressOPFFieldType): string;
const
  CFieldTypeStr: array[TPressOPFFieldType] of string = (
   '',               //  oftUnknown
   'nvarchar2',      //  oftString
   'number(5)',      //  oftInt16
   'number(10)',     //  oftInt32
   'number(19)',     //  oftInt64
   'binary_double',  //  oftFloat
   'number(14,4)',   //  oftCurrency
   'number(1)',      //  oftBoolean
   'date',           //  oftDate
   'timestamp',      //  oftTime
   'timestamp',      //  oftDateTime
   'clob',           //  oftMemo
   'blob');          //  oftBinary
begin
  Result := CFieldTypeStr[AFieldType];
end;

function TPressOracleDDLBuilder.InternalImplicitIndexCreation: Boolean;
begin
  Result := False;
end;

function TPressOracleDDLBuilder.InternalMaxIdentLength: Integer;
begin
  Result := 30;
end;

function TPressOracleDDLBuilder.SelectGeneratorStatement: string;
begin
  Result := 'select %s.nextval from dual';
end;

end.
