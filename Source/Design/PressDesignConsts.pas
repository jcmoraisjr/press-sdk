(*
  PressObjects, Design Consts unit
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressDesignConsts;

{$I Press.inc}

interface

const
  SPressAttributeNameMethodName = 'AttributeName';
  SPressMetadataMethodName = 'InternalMetadataStr';
  SPressRegisterEnumMethodName = 'RegisterEnumMetadata';
  SPressResultStr = 'Result';
  SPressFormClassNameStr = 'TForm';
  SPressFrameClassNameStr = 'TFrame';
  SPressOIDGeneratorClassNameStr = 'TPressOIDGenerator';

resourcestring
  SClassNameAndMetadataMismatch = 'Metadata do método %s.' + SPressMetadataMethodName + ' não percente à classe %0:s';
  SInterfaceAlreadyInstalled = 'Interface %s já está instalada';
  SModuleNotFound = 'Module ''%s'' not found';
  SUninstalledIDEInterface = 'Nenhuma interface para a IDE foi instalada';

  SPressDataTypeDeclarationMsg = 'Declaração de tipo de dado';
  SPressProcMethodDeclMsg = 'Declaração de procedimento, função ou método';
  SPressStringConstMsg = 'Constante string';

  SPressProjectBusinessClasses = 'Business classes';
  SPressProjectPersistentClasses = 'Persistent classes';
  SPressProjectQueryClasses = 'Query classes';
  SPressProjectMVPClasses = 'MVP classes';
  SPressProjectModels = 'Models';
  SPressProjectViews = 'Views';
  SPressProjectPresenters = 'Presenters';
  SPressProjectCommands = 'Commands';
  SPressProjectInteractors = 'Interactors';
  SPressProjectRegisteredClasses = 'Registered classes';
  SPressProjectRegisteredItems = 'Registered items';
  SPressProjectUserAttributes = 'User attributes';
  SPressProjectUserEnumerations = 'User enumerations';
  SPressProjectUserOIDGenerators = 'User OID generators';
  SPressProjectOtherClasses = 'Other classes';
  SPressProjectForms = 'Forms';
  SPressProjectFrames = 'Frames';
  SPressProjectUnknown = 'Unknown';

implementation

end.
