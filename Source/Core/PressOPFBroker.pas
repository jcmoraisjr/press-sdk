(*
  PressObjects, Persistence Broker Class
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressOPFBroker;

{$I Press.inc}

interface

uses
  PressApplication,
  PressOPFConnector,
  PressOPFMapper;

const
  CPressOPFBrokerService = CPressDataAccessServicesBase + $0003;

type
  TPressOPFBroker = class(TPressService)
  private
    FConnector: TPressOPFConnector;
    function GetConnector: TPressOPFConnector;
  protected
    procedure DoneService; override;
    function InternalConnectorClass: TPressOPFConnectorClass; virtual;
    function InternalMapperClass: TPressOPFObjectMapperClass; virtual;
    procedure InternalShowConnectionManager; virtual;
    class function InternalServiceType: TPressServiceType; override;
  public
    function MapperClass: TPressOPFObjectMapperClass;
    procedure ShowConnectionManager;
    property Connector: TPressOPFConnector read GetConnector;
  end;

implementation

uses
  PressOPF;

{ TPressOPFBroker }

procedure TPressOPFBroker.DoneService;
begin
  FConnector.Free;
  inherited;
end;

function TPressOPFBroker.GetConnector: TPressOPFConnector;
begin
  if not Assigned(FConnector) then
    FConnector := InternalConnectorClass.Create;
  Result := FConnector;
end;

function TPressOPFBroker.InternalConnectorClass: TPressOPFConnectorClass;
begin
  Result := TPressOPFConnector;
end;

function TPressOPFBroker.InternalMapperClass: TPressOPFObjectMapperClass;
begin
  Result := TPressOPFObjectMapper;
end;

class function TPressOPFBroker.InternalServiceType: TPressServiceType;
begin
  Result := CPressOPFBrokerService;
end;

procedure TPressOPFBroker.InternalShowConnectionManager;
begin
end;

function TPressOPFBroker.MapperClass: TPressOPFObjectMapperClass;
begin
  Result := InternalMapperClass;
end;

procedure TPressOPFBroker.ShowConnectionManager;
begin
  InternalShowConnectionManager;
end;

end.
