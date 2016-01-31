# docker-radius
RADIUS Docker Image

![build status](https://api.travis-ci.org/realworldtech/docker-radius.svg?branch=master)

This is yet another Docker FreeRADIUS 2 image with SQL support.

This image implements a sensible SQL schema with added tables to support period-based accounting.

### What is period accounting?

By default, the SQL module for FreeRADIUS records the accounting start and accounting stop
packets into a single row. This is a thoroughly convenient storage format, and very efficient
for space. But it presents some challenges when you want to work out how much data has been
used on a more granular period set; such as for a given hour within a single session.

Also, given sessions are much longer lived than they used to be (fibre based access services
and even DSL have session times of weeks, months or years), if you need to do diagnosis on a
session it can be hard to know whether the data consumed was this week, this month, or... any
period of time.

This image extracts the accounting data every time an update is made and stores it so that you
can process the data used in a period.

### How does it work?

The SQL schema included implements an SQL trigger that extracts data updates every time an
update to the accounting table is updated and stores it. There is then another CRON based 
script that summarises the data. The schema also includes some modifications to the standard
FreeRADIUS schema based on the ARA FreeRADIUS management interface. This schema is compatible
with ARA.

The image expects a MySQL server to be running and accessible from the hostname "mysql".

On boot this image attempts to connect to the MySQL server, and will loop until it can to load
the SQL schema (if it's not there). If there is a database called 'radius' and it can connect
using the default username and password (which are radius/radius) it will assume that the database
exists and it does not need to be recreated. The init script requires the MySQL root password to
be present in an environment variable (MYSQL_ROOT_PASSWORD).

The configurations aren't designed to be secure. This image is for development and testing
purposes, and without some significant attention to security probably should not be used in
production.
