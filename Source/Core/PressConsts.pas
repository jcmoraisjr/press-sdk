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
  SPressMaxItemCount = 100;
  SPressBrackets = '()';
  SPressAttributePrefix = '_';
  SPressAttributeSeparator = '.';
  SPressIdentifierSeparator = '_';
  SPressDataSeparator = ':';
  SPressFieldDelimiter = ';';
  SPressLineBreak = #10;
  SPressTrueString = 'True';
  SPressFalseString = 'False';
  SPressNilString = 'nil';
  SPressIdString = 'Id';
  SPressIdentifierString = 'Identifier';
  SPressIntegerString = 'Integer';
  SPressLiteralString = 'Literal';
  SPressQueryItemsString = 'QueryItems';
  SPressEofString = 'final de arquivo';

resourcestring
  SAmbiguousConcreteClass = 'Classe concreta ambígua (%s e %s) para o objeto %s';
  SAttributeAccessError = 'Não é possível acessar o atributo %s(''%s'') como %s';
  SAttributeConversionError = 'Erro ao converter valor para o atributo %s(''%s''):' + #10 + '%s';
  SAttributeNotFound = 'O atributo %s(''%s'') não foi encontrado';
  SClassNotFound = 'Classe %s não encontrada';
  SComponentIsNotAControl = 'O componente %s(''%s'') não é um controle';
  SComponentNotFound = 'O componente %s(''%s'') não foi encontrado';
  SDialogClassIsAssigned = 'Classe do objeto de diálogo já está associado';
  SDisplayNameMissing = 'Falta DisplayName para o controle %s(''%s'')';
  SEnumItemNotFound = 'Enumeration ''%s'' não encontrado';
  SEnumMetadataNotFound = 'Enumeration metadata %s não encontrado';
  SInstanceNotFound = 'Instance not found: %s(%s)';
  SInvalidAttributeClass = 'O atributo %s(''%s'') requer objetos da classe %s';
  SInvalidAttributeType = 'Tipo inválido para o atributo %s (%s)';
  SInvalidAttributeValue = 'Valor ''%s'' inválido para %s(''%s'')';
  SItemCountOverflow = '<%d itens>';
  SMetadataNotFound = 'Metadata da classe %s não foi encontrada';
  SMetadataParseError = 'Erro ao interpretar metadata: "(%d,%d) %s"' + SPressLineBreak + '"%s"';
  SNonRelatedClasses = 'Classes %s e %s não são relacionadas';
  SNoLoggedUser = 'Não existe usuário logado';
  SNoReference = 'Não existe referência';
  SNoRegisteredReport = 'Nenhum relatório foi registrado';
  SPersistentClassNotFound = 'Classe persistente %s não encontrada';
  SSingletonClassNotFound = 'Classe Singleton %s não encontrada';
  SStringOverflow = 'String overflow: %s(%s)';
  STokenExpected = '''%s'' esperado, mas ''%s'' foi encontrado';
  SUnassignedAttributeType = 'Tipo de atributo não associado para %s(''%s'')';
  SUnassignedCandidateClasses = 'Classes candidata não estão associadas';
  SUnassignedTargetClass = 'Classe alvo não está associada';
  SUnassignedMainForm = 'Formulário principal não está associado';
  SUnassignedMainPresenter = 'Presenter principal não está associado';
  SUnassignedModel = 'Model não está associado';
  SUnassignedPersistenceConnector = 'Conector de persistência não foi associado';
  SUnassignedServiceType = 'Nenhum serviço %s foi associado ou registrado';
  SUnassignedSubject = 'Subject não foi associado';
  SUnexpectedEof = 'Fim de arquivo inesperado';
  SUnexpectedMVPClassParam = 'Classe MVP %s inicializada com parâmetros inesperados';
  SUnsupportedAttribute = 'O atributo %s(''%s'') não é suportado';
  SUnsupportedAttributeType = 'O tipo de atributo %s não é suportado';
  SUnsupportedComponent = 'O componente %s não é suportado';
  SUnsupportedControl = 'O controle %s(''%s'') não é suportado';
  SUnsupportedDisplayName = 'DisplayName não é suportado para o atributo %s(''%s.%s'')';
  SUnsupportedFeature = 'Feature %s não é suportada';
  SUnsupportedModel = 'Model %s não é suportado por %s';
  SUnsupportedObject = 'Nenhuma classe %s suporta objetos %s';

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
  SPressReportErrorString = ' ##Erro## ';

  SPressCancelChangesDialog = 'Cancelar alterações?';
  SPressConfirmRemoveOneItemDialog = 'Um item selecionado. Confirma remoção?';
  SPressConfirmRemoveItemsDialog = '%d itens selecionados. Confirma remoção?';
  SPressSaveChangesDialog = 'Gravar alterações?';

implementation

end.
