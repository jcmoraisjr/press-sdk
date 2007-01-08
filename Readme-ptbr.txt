PressObjects Framework, Versão 0.1.1
Copyright (C) 2006-2007 Laserpress Ltda.

http://www.pressobjects.org

Vide arquivo LICENSE.txt, incluso nesta distribuição,
para detalhes do copyright.

== Introdução
=============

PressObjects é um framework de aplicação que integra objetos de negócio
a componentes visuais, construído para Delphi-Win32 e Free Pascal-Lazarus.

== Recursos
===========

-- Integração

Um problema comum ao construir aplicativos é a falta de integração entre
os formulários que apresentam os objetos de negócio. O registro de
classes do PressObjects liga tais formulários através dos atributos dos
objetos de negócio, fazendo com que formulários sejam criados e
destruídos de forma totalmente transparente para o programador.

-- Modelagem de classes de negócio

(não implementado)

-- Modelagem de classes MVP

(não implementado)

-- Persistência

(não implementado, feito atualmente através de um broker de persistência)

-- Notificação

O acoplamento fraco, um ponto relevante para um projeto orientado a
objetos, faz com que determinadas classes não tenham como acessar umas
às outras. O PressObjects possui um poderoso sistema de notificação,
fazendo com que o acoplamento continue fraco e ainda assim ocorra
comunicação. A própria aplicação final pode criar novas notificações,
bem como ouvir as notificações do framework.

== Instalação
=============

Atualmente o PressObjects não possui código ou package de Design Time.

Vide ($Press)/Docs/Install-ptbr.txt para maiores informações.

== Conhecendo o framework
=========================

Para uma visão geral do framework, veja o documento
($Press)/Docs/Overview-ptbr.txt

Para uma resumida lista dos itens necessários para construir uma
aplicação com PressObjects, veja o documento
($Press)/Docs/Primer-ptbr.txt

Consulte o aplicativo demonstração:
($Press)/Demos/

== Suporte, relato de bugs, contato
===================================

Vide informações no site do projeto: http://www.pressobjects.org
