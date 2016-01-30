#!/bin/bash

mysql -u radius --password=radius -h mysql radius < /usr/src/build/sql/test-data.sql