// Define one of the following persistence options to allow
// the storing and retrieval of data entered into the application.
// If no persistence is required then undefine all persistence
// options.
{$DEFINE UsePressOPF}
{.$DEFINE UseInstantObjects}

// Define the following directive to enable runtime report
// management.
{.$DEFINE UseReport}


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
