(*
  PressObjects, IDE Interfaces
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressIDEIntf;

{$I Press.inc}

interface

uses
  Classes,
  PressCompatibility,
  PressClasses,
  PressNotifier;

type
  TPressIDEEvent = class(TPressEvent)
  end;

  TPressIDEBeforeCompileEvent = class(TPressIDEEvent)
  end;

  TPressIDEOnSaveEvent = class(TPressIDEEvent)
  end;

  IPressIDEModule = interface(IInterface)
  ['{B4DF6D97-A048-4ADD-9A90-9A773691F2D4}']
    procedure DeleteText(ACount: Integer);
    function GetName: string;
    function GetPosition: TPressTextPos;
    procedure InsertText(const AText: string);
    function Read(AChars: Integer): string;
    procedure SetPosition(Value: TPressTextPos);
    function SourceCode: string;
    property Name: string read GetName;
    property Position: TPressTextPos read GetPosition write SetPosition;
  end;

  IPressIDEInterface = interface(IInterface)
  ['{0369D063-F29D-4C2C-9F4C-B80736B31F67}']
    procedure ClearModules;
    function GetName: string;
    function FindModule(const AName: string): IPressIDEModule;
    procedure ProjectModuleNames(AList: TStrings);
    property Name: string read GetName;
  end;

function PressIDEInterface: IPressIDEInterface;
procedure PressInstallIDEInterface(AIDEIntf: IPressIDEInterface);

implementation

uses
  PressDesignConsts;

var
  _PressIDEIntf: IPressIDEInterface;

function PressIDEInterface: IPressIDEInterface;
begin
  if not Assigned(_PressIDEIntf) then
    raise EPressError.Create(SUninstalledIDEInterface);
  Result := _PressIDEIntf;
end;

procedure PressInstallIDEInterface(AIDEIntf: IPressIDEInterface);
begin
  if Assigned(_PressIDEIntf) then
    raise EPressError.CreateFmt(
     SInterfaceAlreadyInstalled, [_PressIDEIntf.Name]);
  _PressIDEIntf := AIDEIntf;
end;

end.
