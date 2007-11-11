// Release version
{.$DEFINE PressRelease}

// Use LOG
{.$DEFINE PressLog}
  {.$DEFINE PressLogIdle}
  {.$DEFINE PressLogMemory}
  {.$DEFINE PressLogEvents}
    {.$DEFINE PressLogSubjectEvents}
    {$DEFINE PressLogModelEvents}
    {.$DEFINE PressLogViewEvents}
      {.$DEFINE PressLogKeyboardEvents}
  {.$DEFINE PressLogSubject}
    {.$DEFINE PressLogSubjectChanges}
    {$DEFINE PressLogSubjectMemento}
  {.$DEFINE PressLogMVP}
  {.$DEFINE PressLogReport}
  {.$DEFINE PressLogDAO}
    {.$DEFINE PressLogDAOInterface}
    {.$DEFINE PressLogDAOPersistence}

{.$DEFINE PressDebugBaseUnits}

// Define how 1::1 View x Interactor relationship (like
// OnDrawCell event) must implement the View's notifications.
// Note--defining both options will create Notification classes
// (TPressEvent decendants) as well as event fields (Direct
// Event), but only the Notification will be used by default
// PressObjects' Interactors.
{.$DEFINE PressViewNotification}
{$DEFINE PressViewDirectEvent}

// Generate units with cross-reference information (only Delphi)
{$DEFINE PressCrossReferenceInfo}


(************ Do not change directives below this line ************)


{.$DEFINE PressReleaseManagedObjects}

{$IFDEF FPC}
  {$MODE OBJFPC}
  {$DEFINE SUPPORTS_WIDESTRING}
  {$DEFINE SUPPORTS_INTERFACE}
  {$DEFINE SUPPORTS_INT64}
  {$DEFINE SUPPORTS_DYNAMICARRAYS}
  {$DEFINE SUPPORTS_DEFAULTPARAMS}
  {$DEFINE SUPPORTS_OVERLOAD}
{$ENDIF}

{$BOOLEVAL OFF}
{$LONGSTRINGS ON}
{$TYPEDADDRESS ON}
{$WRITEABLECONST OFF}

{$IFNDEF PressRelease}
  {$ASSERTIONS ON}
  {$IFDEF PressDebugBaseUnits}
    {$DEBUGINFO ON}
  {$ELSE}
    {$IFDEF PressBaseUnit}
      {$DEBUGINFO OFF}
    {$ELSE}
      {$DEBUGINFO ON}
    {$ENDIF}
  {$ENDIF}
  {$IFNDEF FPC}
    {$LOCALSYMBOLS ON}
    {$IFDEF PressCrossReferenceInfo}
      {$REFERENCEINFO ON}
    {$ELSE}
      {$DEFINITIONINFO ON}
    {$ENDIF}
  {$ENDIF}
{$ELSE}
  {$ASSERTIONS OFF}
  {$DEBUGINFO OFF}
  {$LOCALSYMBOLS OFF}
  {$IFNDEF FPC}
    {$REFERENCEINFO OFF}
  {$ENDIF}
  {$UNDEF PressLog}
{$ENDIF}

{$IFNDEF PressLog}
  {$UNDEF PressLogIdle}
  {$UNDEF PressLogMemory}
  {$UNDEF PressLogEvents}
  {$UNDEF PressLogMVP}
  {$UNDEF PressLogSubject}
  {$UNDEF PressLogReport}
  {$UNDEF PressLogDAO}
{$ENDIF}

{$IFNDEF PressLogEvents}
  {$UNDEF PressLogSubjectEvents}
  {$UNDEF PressLogModelEvents}
  {$UNDEF PressLogViewEvents}
{$ENDIF}

{$IFNDEF PressLogViewEvents}
  {$UNDEF PressLogKeyboardEvents}
{$ENDIF}

{$IFNDEF PressLogSubject}
  {$UNDEF PressLogSubjectChanges}
  {$UNDEF PressLogSubjectMemento}
{$ENDIF}

{$IFNDEF PressLogDAO}
  {$UNDEF PressLogDAOInterface}
  {$UNDEF PressLogDAOPersistence}
{$ENDIF}

{$IFNDEF FPC}              // Only FPC and Delphi >= 5 are supported
  {$DEFINE BORLAND_CG}
  {$IFDEF VER130}          // D5
    {$DEFINE MSWINDOWS}
    {$DEFINE D5Up}
    {$DEFINE D5Down}
    {$DEFINE D6Down}
  {$ELSE}
    {$IFDEF VER140}        // D6
      {$DEFINE D5Up}
      {$DEFINE D6Up}
      {$DEFINE D6Down}
    {$ELSE}
      {$DEFINE D5Up}
      {$DEFINE D6Up}
      {$IF COMPILERVERSION >= 18.0}
        {$DEFINE D2006Up}
      {$IFEND}
    {$ENDIF}
  {$ENDIF}
{$ENDIF}
