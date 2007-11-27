PressObjects SDK, Version 0.1.1
Copyright (C) 2006-2007 Laserpress Ltda.

http://www.pressobjects.org

See the file LICENSE.txt, enclosed in this distribution,
for details about the copyright.


INTRODUCTION
============

PressObjects is a software development kit (SDK) composed of several
frameworks that assist the construction of object oriented applications.
The code is compatible with Delphi-Win32 and Free Pascal compilers.


FRAMEWORKS AND RESOURCES
========================

Business objects presentation
-----------------------------
Through the MVP pattern, business objects are presented in simple visual
components like TEdit and TComboBox. There are several advantages in this
approach, eg: to completely separate the business and the presentation rules
from the form implementation; allow the use of other components that the
framework does not know; replicate code and behavior just by registering
customized models, views or interactors, etc.

Persistence
-----------
Business objects are read and stored through the IPressDAO interface, that
can be implemented by a persistence class (OPF) or a web service.

Notification
------------
The PressObjects notification framework is based on the publish-subscriber 
pattern, which is more flexible than the observer pattern. Some of its 
features are: the publishers and the subscribers can have a many to many (NxN) 
relationship; events can be queued for processing when the application is 
idle; events are objects, therefore they can contain and transport data; event 
classes don't need to be declared with its publishers, therefore, reducing the 
coupling.

Reports
-------
All the business classes' metadata are transformed into fields and containers
through the reports framework. Any form or any query, therefore, can be used by
the application user to create a report. These reports are available to all
application users without having to recompile or even close and reopen the
application.

Visual modeling (under development)
---------------
Business classes, MVP classes, report classes among others are created through 
the PressObjects' Project Explorer in the IDE. The information is stored 
inside the project source and updates made in the code are reflected in the 
Project Explorer and vice versa.

Integration
-----------
Forms know their business objects and visual controls know their attributes. 
Configuring complex controls, such as a grid, therefore is a matter of linking 
each attribute with its respective control. After these links are established, 
the visual control will be able to find form classes and instantiate and show 
them, without the need for any further programmer intervention.


FIRST STEPS
===========

Study the demonstration applications:
($Press)/Demos/Readme.txt
($Press)/Demos/

Visit the PressObjects wiki:
http://wiki.pressobjects.org


SUPPORT, BUGS, CONTACT
======================

Go to the project web site:
http://www.pressobjects.org
