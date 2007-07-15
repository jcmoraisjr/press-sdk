(*
  PressObjects, Oracle Database Broker
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
  PressOPFMapper;

type
  TPressOracleDDLBuilder = class(TPressOPFDDLBuilder)
  protected
    function InternalFieldTypeStr(AFieldType: TPressOPFFieldType): string; override;
  end;

implementation

{ TPressOracleDDLBuilder }

function TPressOracleDDLBuilder.InternalFieldTypeStr(
  AFieldType: TPressOPFFieldType): string;
const
  CFieldTypeStr: array[TPressOPFFieldType] of string = (
   '',               //  oftUnknown
   'varchar2',       //  oftString
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

end.
