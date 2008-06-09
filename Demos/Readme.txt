SimpleOPF
=========

1. Change the uses clause of the unit MainFrm.pas to choose which
   connection broker(s) the application will use.

2. Change the Projects/<IDE>/SimpleOPF.cf file to provide:
   a) the default service name for the OPFBroker registry,
      and
   b) the database component settings required for the broker used (for
      example: database name, user, password, etc.);


PHONEBOOK
=========

1. Change the unit Units/Brokers.pas to choose which connection broker(s)
   the application will use.

2. Change the Projects/<IDE>/PhoneBook.conf file to provide:
   a) the default service name for the OPFBroker registry,
      and
   b) the database component settings required for the broker used (for
      example: database name, user, password, etc.);

3. Run the application and call File | Create DDL to create the database
   metadata;

4. Create the database tables and constraints using the metadata provided by
   the application.
