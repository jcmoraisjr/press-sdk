(*
  PressObjects, Consts unit
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

unit PressConsts;

interface

{$I Press.inc}

const
  SPressBrackets = '()';
  SPressAttributePrefix = '_';
  SPressAttributeSeparator = '.';
  SPressFieldDelimiter = ';';
  SPressLineBreak = #10;
  SPressTrueString = 'True';
  SPressFalseString = 'False';
  SPressNilString = 'nil';
  SPressIdString = 'Id';
  SPressIdentifierString = 'Identifier';
  SPressQueryItemsString = 'QueryItems';

resourcestring
  SAmbiguousConcreteClass = 'Classe concreta ambígua (%s e %s) para o objeto %s';
  SAttributeAccessError = 'Não é possível acessar o atributo %s(''%s'') como %s';
  SAttributeConversionError = 'Erro ao converter valor para o atributo %s(''%s''):' + #10 + '%s';
  SAttributeNotFound = 'O atributo %s(''%s'') não foi encontrado';
  SAttributeNotSupported = 'O atributo %s(''%s'') não é suportado';
  SClassNotFound = 'Classe %s não encontrada';
  SComponentIsNotAControl = 'O componente %s(''%s'') não é um controle';
  SComponentNotFound = 'O componente %s(''%s'') não foi encontrado';
  SComponentNotSupported = 'O componente %s não é suportado';
  SControlNotSupported = 'O controle %s(''%s'') não é suportado';
  SDialogClassIsAssigned = 'Classe do objeto de diálogo já está associado';
  SDisplayNameMissing = 'Falta DisplayName para o controle %s(''%s'')';
  SDisplayNameNotSupported = 'DisplayName não é suportado para o atributo %s(''%s.%s'')';
  SEnumMetadataNotFound = 'Enumeration metadata %s não encontrado';
  SInstanceNotFound = 'Instance not found: %s(%s)';
  SInvalidAttributeClass = 'O atributo %s(''%s'') requer objetos da classe %s';
  SInvalidAttributeType = 'Tipo inválido para o atributo %s (%s)';
  SInvalidAttributeValue = 'Valor ''%s'' inválido para %s(''%s'')';
  SMainPresenterClassIsAssigned = 'Classe do presenter principal já está associada';
  SMainPresenterIsInitialized = 'Presenter principal já está inicializado';
  SMetadataNotFound = 'Metadata da classe %s não foi encontrada';
  SMetadataParseError = 'Erro ao interpretar metadata: "(%d,%d) %s"' + SPressLineBreak + '"%s"';
  SNonRelatedClasses = 'Classes %s e %s não são relacionadas';
  SNoReference = 'Não existe referência';
  SObjectClassNotSupported = 'A classe %s não é suportada';
  SObjectNotSupported = 'Nenhuma classe %s suporta objetos %s';
  SObjectStoreNotAssigned = 'ObjectStore não associado';
  SPersistenceBrokerClassIsAssigned = 'Classe do broker de persistência já foi associado';
  SPersistentClassNotFound = 'Classe persistente %s não encontrada';
  SSubjectNotAssigned = 'Subject não foi associado';
  STokenExpected = '''%s'' esperado, mas ''%s'' foi encontrado';
  SUnassignedCandidateClasses = 'Classes candidata não estão associadas';
  SUnassignedTargetClass = 'Classe alvo não está associada';
  SUnassignedConnector = 'Conector não está associado';
  SUnassignedMainForm = 'Formulário principal não está associado';
  SUnassignedModel = 'Model não está associado';
  SUnassignedPersistenceBrokerClass = 'Classe do broker de persistência não foi associado';
  SUnassignedPersistenceConnector = 'Conector de persistência não foi associado';
  SUndefinedSelection = 'Selection não definido';
  SUnexpectedEof = 'Fim de arquivo inesperado';
  SUnexpectedMVPClassParam = 'Classe MVP %s inicializada com parâmetros inesperados';
  SUnsupportedAttributeType = 'O tipo de atributo %s não é suportado';
  SUnsupportedModel = 'Model %s não é suportado por %s';

  SConnectionManagerCaption = 'Conector';

  SPressTodayCommand = 'Hoje';
  SPressLoadPictureCommand = 'Adicionar figura';
  SPressRemovePictureCommand = 'Remover figura';
  SPressIncludeObjectCommand = 'Cadastrar novo item';
  SPressAddItemCommand = 'Adicionar item';
  SPressSelectItemCommand = 'Selecionar itens';
  SPressEditItemCommand = 'Alterar item';
  SPressRemoveItemCommand = 'Remover item';
  SPressSaveFormCommand = 'Salvar';
  SPressCancelFormCommand = 'Cancelar';
  SPressCloseFormCommand = 'Fechar';
  SPressExecuteQueryCommand = 'Executar';
  SPressAssignSelectionQueryCommand = 'Selecionar';

  SPressCancelChangesDialog = 'Cancelar alterações?';
  SPressConfirmRemoveOneItemDialog = 'Um item selecionado. Confirma remoção?';
  SPressConfirmRemoveItemsDialog = '%d itens selecionados. Confirma remoção?';
  SPressSaveChangesDialog = 'Gravar alterações?';

implementation

end.
