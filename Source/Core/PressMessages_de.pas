(*
  PressObjects, German Translation Class
  Copyright (C) 2008 Clemens Capitain, Joao Morais

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressMessages_de;

{$I Press.inc}

interface

uses
  PressApplication;

type
  TPressMessages_de = class(TPressMessages)
  protected
    procedure InternalIsDefaultChanged; override;
  end;

implementation

uses
  PressConsts;

resourcestring
  {$I PressMessages_de.inc}

{ TPressMessages_de }

procedure TPressMessages_de.InternalIsDefaultChanged;
begin
  if IsDefault then
  begin
    {$I PressMessages.inc}
  end;
  inherited;
end;

initialization
  TPressMessages_de.RegisterService;

end.
