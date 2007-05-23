
// Use the PressObjects Persistence Framework
{.$DEFINE UsePressOPF}

// Use InstantObjects broker
{.$DEFINE UseInstantObjects}


(************ Do not change directives below this line ************)


{$IFDEF UsePressOPF}
  {$UNDEF UseInstantObjects}
{$ELSE}
  {$IFNDEF UseInstantObjects}
    {$DEFINE DontUsePersistence}
  {$ENDIF}
{$ENDIF}

{$IFDEF FPC}
  {$MODE ObjFPC}{$H+}
{$ENDIF}
