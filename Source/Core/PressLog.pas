(*
  PressObjects, Log Classes
  Copyright (C) 2006 Laserpress Ltda.

  http://www.pressobjects.org

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
*)

unit PressLog;

interface

{$I Press.inc}

uses
  Classes,
  PressClasses;

resourcestring
  { TODO : Move to PressConsts }
  SLogCreating =                  'Creating object  %:-32s';
  SLogCreatingEvent =             'Creating event   %:-32s';
  SLogDestroying =                'Destroying       %:-32s';
  SLogQueueingNotificationEvent = 'Queueing notific %:-32s';
  SLogNotifyingEvent =            'Notifying event  %:-32s';
  SLogReleasingEvent =            'Releasing event  %:-32s';

type
  TPressLogClass = class of TPressLog;

  TPressLog = class(TPressSingleton)
  private
    { TODO : Create an abstract PressCustomLog without FLog,
      use a stream into a default concrete PressLog class}
    FLog: TStrings;
  protected
    function ArrayToString(const AParams: array of TObject): string; overload;
    procedure Finit; override;
    function FormatClassName(const AMsg: string; AObj: TObject): string;
    procedure Init; override;
    function InternalBuildMsg(Sender: TObject; const AMsg: string; const AParams: array of TObject): string; virtual;
  public
    procedure RegisterMsg(Sender: TObject; const AMsg: string; const AParams: array of TObject); virtual;
  end;

var
  PressLogClass: TPressLogClass;

procedure PressLogMsg(Sender: TObject; const AMsg: string); overload;
procedure PressLogMsg(Sender: TObject; const AMsg: string; const AParams: array of TObject); overload;

implementation

uses
  SysUtils,
  PressConsts;

var
  _PressLogInstance: TPressLog;

function PressLogInstance: TPressLog;
begin
  if not Assigned(_PressLogInstance) then
  begin
    if not Assigned(PressLogClass) then
      PressLogClass := TPressLog;
    _PressLogInstance := PressLogClass.Instance;
  end;
  Result := _PressLogInstance;
end;

procedure PressLogMsg(Sender: TObject; const AMsg: string);
begin
  PressLogInstance.RegisterMsg(Sender, AMsg, []);
end;

procedure PressLogMsg(Sender: TObject; const AMsg: string; const AParams: array of TObject);
begin
  PressLogInstance.RegisterMsg(Sender, AMsg, AParams);
end;

{ TPressLog }

function TPressLog.ArrayToString(const AParams: array of TObject): string;
const
  Comma = ', ';
var
  I: Integer;
begin
  Result := '';
  for I := Low(AParams) to High(AParams) do
  begin
    if Assigned(AParams[I]) then
      Result := Result + AParams[I].ClassName + Comma
    else
      Result := Result + SPressNilString + Comma;
  end;
  if Length(Result) >= Length(Comma) then
    SetLength(Result, Length(Result) - Length(Comma));
end;

procedure TPressLog.Finit;
begin
  inherited;
  if FLog.Count > 0 then
    FLog.SaveToFile('PressDebugLog.txt');
  FLog.Free;
end;

function TPressLog.FormatClassName(const AMsg: string; AObj: TObject): string;
const
  SClassNameFormat = '[%s] %s';
begin
  if Assigned(AObj) then
    Result := Format(SClassNameFormat, [AObj.ClassName, AMsg])
  else
    Result := Format(SClassNameFormat, [SPressNilString, AMsg]);
end;

procedure TPressLog.Init;
begin
  inherited;
  FLog := TStringList.Create;
end;

function TPressLog.InternalBuildMsg(
  Sender: TObject; const AMsg: string; const AParams: array of TObject): string;
const
  SLogFormat = '[%s] %s (%s)';
begin
  Result := Format(SLogFormat, [
   FormatDateTime('mmm/dd hh:nn:ss', Now),
   FormatClassName(AMsg, Sender),
   ArrayToString(AParams)])
end;

procedure TPressLog.RegisterMsg(
  Sender: TObject; const AMsg: string; const AParams: array of TObject);
var
  VMsg: string;
begin
  VMsg := InternalBuildMsg(Sender, AMsg, AParams);
  if VMsg <> '' then
    FLog.Add(VMsg);
end;

end.
