PHONEBOOK
=========

It's necessary to configure how the application will store and retrieve objects.

Using No persistence
--------------------

1. Check the comments inside the PhoneBook.inc file and ensure that:
   a) the "UsePressOPF" conditional symbol is NOT defined,
      and
   b) the "UseInstantObjects" conditional symbol is NOT defined;


Using PressObjects persistence
------------------------------

1. Check the comments inside the PhoneBook.inc file and ensure that:
   a) the "UsePressOPF" conditional symbol is defined,
      and
   b) the "UseInstantObjects" conditional symbol is NOT defined;
2. Change the unit Brokers.pas to choose which broker the application will use.
   Currently PressObjects has brokers for IBX, UIB, ZeosDBO and SQLdb. Follow
   the comments inside the unit;
3. Still in the Brokers.pas unit, change the TBroker.InitService implementation
   to provide the database component settings for database name, user, 
   password, and any others as required;
4. Run the application and call File | Connector to create the database
   metadata;
5. Create the database tables and constraints using the metadata provided by
   the application.


Using InstantObjects persistence
--------------------------------

Note: The following assumes a working copy of the InstantObjects persistence
      framework is installed and available.

1. Check the comments inside the PhoneBook.inc file and ensure that:
   a) the "UsePressOPF" conditional symbol is NOT defined,
      and
   b) the "UseInstantObjects" conditional symbol is defined;
2. Change the unit Brokers.pas, removing or including InstantObjects brokers,
   as required;
3. Add IOModel.pas as an InstantObjects' model unit
   (View menu item | InstantObjects Model Explorer | first tool bar button);
4. Check the 'InstantObjects' section of 'Persistence.txt' for any other
   required settings;
5. Save all project files (File menu item | Save All).
