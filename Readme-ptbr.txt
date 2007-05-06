PressObjects SDK, Versão 0.1.1
Copyright (C) 2006-2007 Laserpress Ltda.

http://www.pressobjects.org

Vide arquivo LICENSE.txt, incluso nesta distribuição, para detalhes do
copyright.


INTRODUÇÃO
==========

PressObjects é um kit de desenvolvimento de software (SDK) composto por diversos
frameworks que auxiliam a construção de aplicações orientadas a objetos. O
código é compatível com os compiladores Delphi-Win32 e Free Pascal.


FRAMEWORKS E RECURSOS
=====================

Apresentação de objetos de negócio
----------------------------------
Através do padrão MVP, objetos de negócio são apresentados em componentes
visuais simples, tal como TEdit e TComboBox. Há diversas vantagens nesta
abordagem, tal como: separar totalmente as regras de negócio e de apresentação
da implementação do formulário; permitir o uso de outros componentes que o
framework não conhece; replicar código e comportamento apenas registrando
models, views ou interactors customizados, etc.

Persistência
------------
Objetos de negócio são lidos e armazenados através da interface IPressDAO,
que pode ser implementada por uma classe de persistência (OPF) ou um webservice.

Notificação
-----------
O framework de notificação do PressObjects é baseado no padrão
publish-subscriber, que é um padrão mais flexível do que o observer. Algumas de
suas características: observadores podem escutar um ou mais eventos de um objeto
específico ou de qualquer objeto, bem como um objeto pode gerar tipos de eventos
diferentes a partir da mesma instância; eventos podem ser enfileirados para
serem processados quando a aplicação entrar em modo Idle; eventos são objetos,
portanto podem transportar dados; classes de eventos podem ser declaradas em uma
unidade diferente daquela em que suas instâncias são criadas e disparadas,
diminuindo o acoplamento.

Relatórios
----------
Todo o metadado das classes de negócio são transformados em campos e containeres
através do framework de relatórios. Desta forma, qualquer formulário de consulta
de dados ou qualquer pesquisa pode ser transformada em um relatório pelo próprio
usuário da aplicação. Tal relatório será disponibilizado para todos os demais
usuários sem que seja necessário recompilar ou mesmo fechar e reabrir a
aplicação.

Modelagem visual (em desenvolvimento)
----------------
Classes de negócio, classes MVP, classes para relatórios entre outras são
criadas através do Project Explorer do PressObjects. As informações são gravadas
apenas nos fontes do projeto, desta forma atualizações feitas em código são
visíveis no Project Explorer e vice-versa.

Integração
----------
Formulários conhecem seus objetos de negócio, controles visuais conhecem seus
atributos. Desta forma configurar controles complexos, tal como um grid, é uma
questão de informar ao controle qual é o atributo ao qual ele se refere. A
partir deste ponto o controle visual estará apto a encontrar classes de
formulários, instanciá-los e apresentálos sem que seja necessária qualquer outra
intervenção do programador.


INSTALAÇÃO
==========

Vide ($Press)/Docs/Install-ptbr.txt


PRIMEIROS PASSOS
================

Para uma visão geral:
($Press)/Docs/Overview-ptbr.txt

Para construir uma nova aplicação:
($Press)/Docs/CreatingApplication-ptbr.txt

Consulte o aplicativo demonstração:
($Press)/Demos/


SUPORTE, BUGS, CONTATO
======================

Vide informações no site do projeto:
http://br.pressobjects.org
