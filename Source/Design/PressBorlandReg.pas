(*
  PressObjects, Borland Registration unit
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressBorlandReg;

{$I Press.inc}

interface

procedure Register;

implementation

uses
  Classes,
  PressApplication,
  PressIBXBroker,
  PressUIBBroker,
  PressDOABroker,
  PressZeosBroker,
  PressDesignConsts;

{$R Press.dcr}

procedure Register;
begin
  RegisterComponents(SPressObjectsPaletteName, [
   TPressIBXConnection,
   TPressUIBConnection,
   TPressDOAConnection,
   TPressZeosConnection]);
end;

initialization
  PressApp.InitPackage;
  { TODO : Where include DonePackage? }

end.
