(*
  PressObjects, InterBase / Firebird database Broker
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressIBFbBroker;

{$I Press.inc}

interface

uses
  PressOPFClasses,
  PressOPFMapper,
  PressOPFSQLBuilder;

type
  TPressIBFbDDLBuilder = class(TPressOPFDDLBuilder)
  protected
    function InternalFieldTypeStr(AFieldType: TPressOPFFieldType): string; override;
    function InternalImplicitIndexCreation: Boolean; override;
    function InternalMaxIdentLength: Integer; override;
  end;

implementation

{ TPressIBFbDDLBuilder }

function TPressIBFbDDLBuilder.InternalFieldTypeStr(
  AFieldType: TPressOPFFieldType): string;
const
  CFieldTypeStr: array[TPressOPFFieldType] of string = (
   '',                  //  oftUnknown
   'varchar',           //  oftString
   'smallint',          //  oftInt16
   'integer',           //  oftInt32
   'bigint',            //  oftInt64
   'double precision',  //  oftFloat
   'decimal(14,4)',     //  oftCurrency
   'smallint',          //  oftBoolean
   'date',              //  oftDate
   'time',              //  oftTime
   'timestamp',         //  oftDateTime
   'blob sub_type 1',   //  oftMemo
   'blob');             //  oftBinary
begin
  Result := CFieldTypeStr[AFieldType];
end;

function TPressIBFbDDLBuilder.InternalImplicitIndexCreation: Boolean;
begin
  Result := True;
end;

function TPressIBFbDDLBuilder.InternalMaxIdentLength: Integer;
begin
  Result := 32;
end;

end.
