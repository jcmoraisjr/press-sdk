(*
  PressObjects, English (default) translation
  Copyright (C) 2008 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressMessages;

{$I Press.inc}

interface

procedure PressAssignDefaultMessages;

implementation

uses
  PressConsts;

resourcestring
  {$I PressMessages_en.inc}

{ TPressMessages_en }

procedure PressAssignDefaultMessages;
begin
  {$I PressMessages.inc}
end;

end.
