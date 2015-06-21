Threatmonitor - Packet Analysis suite  with MonetDB / RabbitMQ & PCap integration

Things you need

RabbitMQ

MonetDB

Ruby

Pcaplet - https://github.com/ahobson/ruby-pcap

To build:

You'll need PCAP / Development Header files

gem build pcap.gemspec
gem install pcap-0.7.7.gem 

GEMS: AMQP, Bunny, MonetDB, pcaplet, guid

This is all experimental but i believe it works well so far.

Features ability to push pcap data to Message Queue.

Read data from disk into message queue

Write data from message queue to disk.

Allows you to easily move IP / TCP / UDP data with ease and analyze else where

Creating your database once you've installed MonetDB

monetdbd create /path/to/dbfarm

monetdbd start /path/to/dbfarm

monetdb create threatmonitor

monetdb release threatmonitor

monetdb start threatmonitor

Import the schema from the SQL provided
 
Have fun !
